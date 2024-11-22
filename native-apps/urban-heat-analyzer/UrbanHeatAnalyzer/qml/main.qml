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

import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

import Esri.UrbanHeatAnalyzer

ApplicationWindow {
    visible: true
    width: 800
    height: 600

    Material.theme: Material.Dark
    Material.accent: "#C9F2FF"
    Material.background: "#0289C3"
    Material.foreground: "#FFFFFF"
    Material.primary: "#035799"

    font.pixelSize: 14

    footer: ToolBar {

        RowLayout {
            anchors.fill: parent

            Label {
                id: messageLabel
                horizontalAlignment: Qt.AlignLeft
                Layout.leftMargin: 15
                Layout.fillWidth: true
                text: qsTr("Analyzing urban heat risks...")
            }

            Button {
                onClicked: {
                    mapForm.printCamera();
                }
            }
        }
    }

    UrbanHeatAnalyzerForm {
        id: mapForm
        anchors.fill: parent
    }
}
