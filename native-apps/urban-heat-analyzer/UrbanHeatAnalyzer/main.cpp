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

#include "ArcGISRuntimeEnvironment.h"
#include "CoreTypes.h"
#include "LicenseResult.h"
#include "SceneQuickView.h"

#include <QDir>
#include <QGuiApplication>
#include <QProcessEnvironment>
#include <QQmlApplicationEngine>
#include <QSurfaceFormat>

//------------------------------------------------------------------------------

using namespace Esri::ArcGISRuntime;

int main(int argc, char *argv[])
{
#if defined(Q_OS_LINUX) && !defined(Q_OS_ANDROID)
    // Linux requires 3.2 OpenGL Context
    // in order to instance 3D symbols
    QSurfaceFormat fmt = QSurfaceFormat::defaultFormat();
    fmt.setVersion(3, 2);
    QSurfaceFormat::setDefaultFormat(fmt);
#endif

    QGuiApplication app(argc, argv);

    // Use of ArcGIS location services, such as basemap styles, geocoding, and routing services,
    // requires an access token. For more information see
    // https://links.esri.com/arcgis-runtime-security-auth.

    // The following methods grant an access token:

    // 1. User authentication: Grants a temporary access token associated with a user's ArcGIS account.
    // To generate a token, a user logs in to the app with an ArcGIS account that is part of an
    // organization in ArcGIS Online or ArcGIS Enterprise.

    // 2. API key authentication: Get a long-lived access token that gives your application access to
    // ArcGIS location services. Go to the tutorial at https://links.esri.com/create-an-api-key.
    // Copy the API Key access token.
#ifdef QT_DEBUG
    QString accessToken;
    QString apiKeyName = "ARCGIS_API_KEY";
    QProcessEnvironment systemEnvironment = QProcessEnvironment::systemEnvironment();
    if (systemEnvironment.contains(apiKeyName))
    {
        accessToken = systemEnvironment.value(apiKeyName);
    }

    if (accessToken.isEmpty())
    {
        qWarning()
            << "Use of ArcGIS location services, such as the basemap styles service, requires"
            << "you to authenticate with an ArcGIS account or set the API Key property.";
    }
    else
    {
        ArcGISRuntimeEnvironment::setApiKey(accessToken);
    }
#else
    ArcGISRuntimeEnvironment::setApiKey("API KEY");

    // Production deployment of applications built with ArcGIS Maps SDK requires you to
    // license ArcGIS Maps SDK functionality. For more information see
    // https://links.esri.com/arcgis-runtime-license-and-deploy.

    LicenseResult licenseResult = ArcGISRuntimeEnvironment::setLicense("Place license string in here");
    switch (licenseResult.licenseStatus())
    {
    case LicenseStatus::Valid:
        break;

    default:
        qWarning()
            << "You need a runtime deployment license!";
    }
#endif

    // Register the scene view for QML
    qmlRegisterType<SceneQuickView>("Esri.UrbanHeatAnalyzer", 1, 0, "SceneView");

    // Register the UrbanHeatAnalyzer (QQuickItem) for QML
    qmlRegisterType<UrbanHeatAnalyzer>("Esri.UrbanHeatAnalyzer", 1, 0, "UrbanHeatAnalyzer");

    // Register the HeatRiskListModel for QML
    qmlRegisterType<HeatRiskListModel>("Esri.UrbanHeatAnalyzer", 1, 0, "HeatRiskListModel");

    // Initialize application view
    QQmlApplicationEngine engine;

    // Add the import Path
    engine.addImportPath(QDir(QCoreApplication::applicationDirPath()).filePath("qml"));

    // Set the source
    engine.load(QUrl("qrc:/qml/main.qml"));

    return app.exec();
}

//------------------------------------------------------------------------------
