// Copyright 2024 ESRI
//
// All rights reserved under the copyright laws of the United States
// and applicable international laws, treaties, and conventions.
//
// You may freely redistribute and use this sample code, with or
// without modification, provided you include the original copyright
// notice and use restrictions.
//
// See the Sample code usage restrictions document for further information.
//
// This "Urban Heat Analyzer" sample app is licensed as
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Additional permission under GNU GPL version 3 section 4 and 5
// If you modify this Program, or any covered work, by linking or combining
// it with ArcGIS Runtime for Qt (or a modified version of that library),
// containing parts covered by the terms of ArcGIS Runtime for Qt,
// the licensors of this Program grant you additional permission to convey the resulting work.
// See <https://developers.arcgis.com/qt/> for further information.
//

#include "UrbanHeatAnalyzer.h"

#include "ArcGISTiledElevationSource.h"
#include "ArcGISVectorTiledLayer.h"
#include "AttributeListModel.h"
#include "CoreTypes.h"
#include "ElevationSourceListModel.h"
#include "Envelope.h"
#include "Feature.h"
#include "FeatureIterator.h"
#include "FeatureQueryResult.h"
#include "Geodatabase.h"
#include "GeodatabaseFeatureTable.h"
#include "LayerListModel.h"
#include "MapTypes.h"
#include "OrderBy.h"
#include "QueryParameters.h"
#include "Scene.h"
#include "SceneQuickView.h"
#include "ServiceFeatureTable.h"
#include "Surface.h"
#include "VectorTileCache.h"
#include "Viewpoint.h"

#include <QFuture>
#include <QUrl>

#include <memory>

using namespace Esri::ArcGISRuntime;

UrbanHeatAnalyzer::UrbanHeatAnalyzer(QObject *parent /* = nullptr */)
    : QObject(parent)
    , m_scene(new Scene(BasemapStyle::OsmStandard, this))
{
    // create a new elevation source from Terrain3D rest service
    ArcGISTiledElevationSource *elevationSource
        = new ArcGISTiledElevationSource(QUrl("https://elevation3d.arcgis.com/arcgis/rest/services/"
                                              "WorldElevation3D/Terrain3D/ImageServer"),
                                         this);

    // add vector tile cache
    VectorTileCache *tileCache = new VectorTileCache(
        "/data/Germany/Bonn/heat_risk_index_bonn.vtpk",
        this);

    // add the vector tile layer
    ArcGISVectorTiledLayer *tiledLayer = new ArcGISVectorTiledLayer(
        tileCache,
        this);
    connect(tiledLayer, &ArcGISVectorTiledLayer::doneLoading, this, [tiledLayer, this]()
    {
        Envelope layerExtent = tiledLayer->fullExtent();
        Viewpoint viewpoint = Viewpoint(layerExtent);
        m_sceneView->setViewpointAsync(viewpoint, 2.5);
    });
    m_scene->operationalLayers()->append(tiledLayer);

    // add the features
    Geodatabase *gdb = new Geodatabase(
        "/data/Germany/Bonn/HRI Bonn.geodatabase",
        this);
    connect(gdb, &Geodatabase::doneLoading, this, [gdb, this]()
    {
        GeodatabaseFeatureTable *featureTable = gdb->geodatabaseFeatureTable("HRI_Bonn");
        connect(featureTable, &GeodatabaseFeatureTable::doneLoading, this, [featureTable, this]()
        {
            qint64 featureCount = featureTable->numberOfFeatures();
            qDebug() << featureCount;

            // Execute the analysis
            QueryParameters analysisParameters;
            QList<OrderBy> orderByFields;
            orderByFields.append(OrderBy("HRI", SortOrder::Descending));
            analysisParameters.setOrderByFields(orderByFields);
            analysisParameters.setWhereClause("HRI > 9");
            featureTable->queryFeaturesAsync(analysisParameters, this)
                .then(this, [this](FeatureQueryResult *rawQueryResult)
                {
                    // Reference raw pointer
                    auto queryResult = std::unique_ptr<FeatureQueryResult>(rawQueryResult);
                    if (queryResult && !queryResult->iterator().hasNext())
                    {
                        // No results or invalid pointer
                        return;
                    }

                    QMap<double, QList<Feature*>> analysisGroups;
                    QList<Feature*> currentGroup;

                    // iterate over the result object
                    double lastValue = 9999;
                    while (queryResult->iterator().hasNext())
                    {
                        Feature *feature = queryResult->iterator().next(this);

                        // add every feature to the results view
                        double heatRiskIndexValue = round(feature->attributes()->attributeValue("HRI").toDouble());
                        if (lastValue == heatRiskIndexValue)
                        {
                            // add to the last group
                            currentGroup.append(feature);
                        }
                        else if (heatRiskIndexValue < lastValue)
                        {
                            // create a new group
                            analysisGroups.insert(heatRiskIndexValue, QList(currentGroup));
                            currentGroup.clear();
                            currentGroup.append(feature);
                        }
                        lastValue = heatRiskIndexValue;
                    }

                    for (auto groupIt = analysisGroups.keyValueBegin(); groupIt != analysisGroups.keyValueEnd(); ++groupIt)
                    {
                        qDebug() << groupIt->first;
                        qDebug() << groupIt->second.size();
                    }
                });
        });
        featureTable->load();
    });
    gdb->load();

    // add the elevation source to the scene to display elevation
    m_scene->baseSurface()->elevationSources()->append(elevationSource);
}

UrbanHeatAnalyzer::~UrbanHeatAnalyzer() {}

SceneQuickView *UrbanHeatAnalyzer::sceneView() const
{
    return m_sceneView;
}

// Set the view (created in QML)
void UrbanHeatAnalyzer::setSceneView(SceneQuickView *sceneView)
{
    if (!sceneView || sceneView == m_sceneView) {
        return;
    }

    m_sceneView = sceneView;
    m_sceneView->setArcGISScene(m_scene);

    emit sceneViewChanged();
}