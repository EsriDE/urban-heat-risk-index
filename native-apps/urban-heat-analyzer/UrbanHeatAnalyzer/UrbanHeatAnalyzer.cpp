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

#include "HeatRiskListModel.h"
#include "UrbanHeatAnalyzer.h"

#include "ArcGISSceneLayer.h"
#include "ArcGISTiledElevationSource.h"
#include "ArcGISVectorTiledLayer.h"
#include "AttributeListModel.h"
#include "Camera.h"
#include "CoreTypes.h"
#include "ElevationSourceListModel.h"
#include "Envelope.h"
#include "Feature.h"
#include "FeatureIterator.h"
#include "FeatureQueryResult.h"
#include "Geodatabase.h"
#include "GeodatabaseFeatureTable.h"
#include "Graphic.h"
#include "GraphicListModel.h"
#include "GraphicsOverlay.h"
#include "GraphicsOverlayListModel.h"
#include "LayerListModel.h"
#include "MapTypes.h"
#include "OrderBy.h"
#include "Point.h"
#include "QueryParameters.h"
#include "Scene.h"
#include "SceneQuickView.h"
#include "ServiceFeatureTable.h"
#include "SimpleFillSymbol.h"
#include "SimpleRenderer.h"
#include "SpatialReference.h"
#include "Surface.h"
#include "SymbolTypes.h"
#include "VectorTileCache.h"
#include "Viewpoint.h"

#include <QColor>
#include <QFuture>
#include <QUrl>

#include <memory>

using namespace Esri::ArcGISRuntime;

UrbanHeatAnalyzer::UrbanHeatAnalyzer(QObject *parent /* = nullptr */)
    : QObject(parent)
    , m_scene(new Scene(BasemapStyle::OsmStandard, this))
    , m_heatRiskOverlay(new GraphicsOverlay(this))
{
    // create a new scene layer from OSM Buildings rest service
    ArcGISSceneLayer *osmSceneLayer = new ArcGISSceneLayer(
        QUrl("https://basemaps3d.arcgis.com/arcgis/rest/services/"
             "OpenStreetMap3D_Buildings_v1/SceneServer"),
        this);
    osmSceneLayer->setOpacity(0.75f);

    // add the scene layer to the scene
    m_scene->operationalLayers()->append(osmSceneLayer);

    // create a new elevation source from Terrain3D rest service
    ArcGISTiledElevationSource *elevationSource = new ArcGISTiledElevationSource(
        QUrl("https://elevation3d.arcgis.com/arcgis/rest/services/"
             "WorldElevation3D/Terrain3D/ImageServer"),
        this);

    // add the elevation source to the scene to display elevation
    m_scene->baseSurface()->elevationSources()->append(elevationSource);

    // create a new vector tile cache from the exported vector tile package
    VectorTileCache *tileCache = new VectorTileCache(
        "/data/Germany/Bonn/heat_risk_index_bonn.vtpk",
        this);

    // add the vector tile layer
    ArcGISVectorTiledLayer *tiledLayer = new ArcGISVectorTiledLayer(
        tileCache,
        this);
    tiledLayer->setOpacity(0.33f);

    connect(tiledLayer, &ArcGISVectorTiledLayer::doneLoading, this, [tiledLayer, this]()
    {
        //Envelope layerExtent = tiledLayer->fullExtent();
        //Viewpoint viewpoint = Viewpoint(layerExtent);
        //m_sceneView->setViewpointAsync(viewpoint, 2.5);
        //m_sceneView->currentViewpointCamera();
        //m_sceneView->setViewpointCameraAsync()

        // Set the viewpoint on a specific target
        Point targetLocation(7.11661 , 50.718 , 343.663, SpatialReference(4326));
        Camera targetCamera(targetLocation, 93.2121 , 60.7764 , -5.68434e-14);
        Viewpoint targetViewpoint(targetLocation, targetCamera);
        if (m_sceneView)
        {
            m_sceneView->setViewpointAsync(targetViewpoint, 10);
        }

        loadHeatRiskFeatures();
    });
    m_scene->operationalLayers()->append(tiledLayer);

    // define the heat risk overlay rendering
    SimpleFillSymbol *heatRiskFillSymbol = new SimpleFillSymbol(
        SimpleFillSymbolStyle::Solid,
        QColor("cyan"),
        this);
    SimpleRenderer *heatRiskRenderer = new SimpleRenderer(
        heatRiskFillSymbol,
        this);
    m_heatRiskOverlay->setRenderer(heatRiskRenderer);
    m_heatRiskOverlay->setOpacity(0.75f);
}

UrbanHeatAnalyzer::~UrbanHeatAnalyzer() {}

SceneQuickView *UrbanHeatAnalyzer::sceneView() const
{
    return m_sceneView;
}

// Set the view (created in QML)
void UrbanHeatAnalyzer::setSceneView(SceneQuickView *sceneView)
{
    if (!sceneView || sceneView == m_sceneView)
    {
        return;
    }

    m_sceneView = sceneView;
    m_sceneView->setArcGISScene(m_scene);

    // add the graphics overlay
    m_sceneView->graphicsOverlays()->append(m_heatRiskOverlay);

    emit sceneViewChanged();
}

void UrbanHeatAnalyzer::setHeatRiskListModel(HeatRiskListModel *heatRiskListModel)
{
    if (!heatRiskListModel)
    {
        return;
    }

    m_heatRiskListModel = heatRiskListModel;
    connect(m_heatRiskListModel, &HeatRiskListModel::selectedHeatRiskItemChanged, this, [this]()
    {
        HeatRiskAnalysisGroup *riskGroup = m_heatRiskListModel->selectedGroup();
        if (!riskGroup)
        {
            return;
        }

        if (m_sceneView)
        {
            // Zoom to area of interest
            Geometry areaOfInterest = riskGroup->areaOfInterest();
            Viewpoint newViewpoint = Viewpoint(areaOfInterest);
            m_sceneView->setViewpointAsync(newViewpoint, 2.5);

            // Add a new graphic visualizing the area of interest
            m_heatRiskOverlay->graphics()->clear();
            Graphic *heatRiskArea = new Graphic(areaOfInterest, this);
            m_heatRiskOverlay->graphics()->append(heatRiskArea);
        }
    });
}

void UrbanHeatAnalyzer::loadHeatRiskFeatures()
{
    // add the features
    Geodatabase *gdb = new Geodatabase(
        "/data/Germany/Bonn/HRI Bonn.geodatabase",
        this);
    connect(gdb, &Geodatabase::doneLoading, this, [gdb, this]()
    {
        GeodatabaseFeatureTable *featureTable = gdb->geodatabaseFeatureTable("HRI_Bonn");
        connect(featureTable, &GeodatabaseFeatureTable::doneLoading, this, [featureTable, this]()
        {
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
                    if (!queryResult && !queryResult->iterator().hasNext())
                    {
                          // No results or invalid pointer
                          return;
                    }

                    QList<HeatRiskAnalysisGroup> analysisGroups;
                    HeatRiskAnalysisGroup *currentGroup = nullptr;

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
                            if (currentGroup)
                            {
                                currentGroup->addFeature(feature);
                            }
                        }
                        else if (heatRiskIndexValue < lastValue)
                        {
                            // create a new group
                            HeatRiskAnalysisGroup newGroup(heatRiskIndexValue);
                            newGroup.addFeature(feature);
                            analysisGroups.append(newGroup);
                            currentGroup = &analysisGroups.last();
                        }
                        lastValue = heatRiskIndexValue;
                    }

                    // Load the features into the model
                    if (m_heatRiskListModel)
                    {
                        m_heatRiskListModel->loadAnalysisGroups(analysisGroups);
                    }
                });
        });
        featureTable->load();
    });
    gdb->load();
}

void UrbanHeatAnalyzer::clearOverlay()
{
    if (!m_heatRiskOverlay)
    {
        return;
    }

    m_heatRiskOverlay->graphics()->clear();
}

void UrbanHeatAnalyzer::printCamera()
{
    auto camera = m_sceneView->currentViewpointCamera();
    auto location = camera.location();
    qDebug() << location.x() << "," << location.y() << "," << location.z();
    qDebug() << camera.heading() << "," << camera.pitch() << "," << camera.roll();
}
