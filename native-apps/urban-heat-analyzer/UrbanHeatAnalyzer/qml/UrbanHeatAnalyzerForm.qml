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

import QtQuick
import QtQuick.Controls
import Esri.UrbanHeatAnalyzer

Item {

    // Define a property for HeatRiskListModel
    property HeatRiskListModel heatRiskListModel: riskModel

    function clearOverlay() {
        model.clearOverlay();
    }

    function printCamera() {
        model.printCamera();
    }

    // Create HeatRiskListModel here
    HeatRiskListModel {
        id: riskModel
    }

    // Create SceneQuickView here, and create its Scene etc. in C++ code
    SceneView {
        id: view
        anchors.fill: parent
    }

    // Declare the C++ instance which creates the scene etc. and supply the view
    UrbanHeatAnalyzer {
        id: model
        sceneView: view
        heatRiskListModel: riskModel
    }
}
