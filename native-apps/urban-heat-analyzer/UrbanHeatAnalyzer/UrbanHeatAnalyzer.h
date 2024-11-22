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

#ifndef URBANHEATANALYZER_H
#define URBANHEATANALYZER_H

class HeatRiskListModel;

namespace Esri::ArcGISRuntime {
class GraphicsOverlay;
class Scene;
class SceneQuickView;
} // namespace Esri::ArcGISRuntime

#include <QObject>

Q_MOC_INCLUDE("SceneQuickView.h")


class UrbanHeatAnalyzer : public QObject
{
    Q_OBJECT

    Q_PROPERTY(Esri::ArcGISRuntime::SceneQuickView *sceneView
                   READ sceneView WRITE setSceneView
                   NOTIFY sceneViewChanged)
    Q_PROPERTY(HeatRiskListModel *heatRiskListModel
                   WRITE setHeatRiskListModel)

public:
    explicit UrbanHeatAnalyzer(QObject *parent = nullptr);
    ~UrbanHeatAnalyzer() override;

    Q_INVOKABLE void clearOverlay();
    Q_INVOKABLE void printCamera();

signals:
    void sceneViewChanged();

private:
    void loadHeatRiskFeatures();

    Esri::ArcGISRuntime::SceneQuickView *sceneView() const;
    void setSceneView(Esri::ArcGISRuntime::SceneQuickView *sceneView);

    void setHeatRiskListModel(HeatRiskListModel *heatRiskListModel);

    Esri::ArcGISRuntime::Scene *m_scene = nullptr;
    Esri::ArcGISRuntime::SceneQuickView *m_sceneView = nullptr;
    HeatRiskListModel *m_heatRiskListModel = nullptr;
    Esri::ArcGISRuntime::GraphicsOverlay *m_heatRiskOverlay = nullptr;

};

#endif // URBANHEATANALYZER_H
