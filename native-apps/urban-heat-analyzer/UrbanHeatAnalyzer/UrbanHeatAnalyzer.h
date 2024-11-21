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

#ifndef URBANHEATANALYZER_H
#define URBANHEATANALYZER_H

namespace Esri::ArcGISRuntime {
class Scene;
class SceneQuickView;
} // namespace Esri::ArcGISRuntime

#include <QObject>

Q_MOC_INCLUDE("SceneQuickView.h")

class UrbanHeatAnalyzer : public QObject
{
    Q_OBJECT

    Q_PROPERTY(Esri::ArcGISRuntime::SceneQuickView *sceneView READ sceneView WRITE setSceneView
                   NOTIFY sceneViewChanged)

public:
    explicit UrbanHeatAnalyzer(QObject *parent = nullptr);
    ~UrbanHeatAnalyzer() override;

signals:
    void sceneViewChanged();

private:
    Esri::ArcGISRuntime::SceneQuickView *sceneView() const;
    void setSceneView(Esri::ArcGISRuntime::SceneQuickView *sceneView);

    Esri::ArcGISRuntime::Scene *m_scene = nullptr;
    Esri::ArcGISRuntime::SceneQuickView *m_sceneView = nullptr;
};

#endif // URBANHEATANALYZER_H
