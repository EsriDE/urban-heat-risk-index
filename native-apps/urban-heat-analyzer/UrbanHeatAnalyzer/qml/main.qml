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
import QtQuick.Controls.Material
import QtQuick.Layouts

import Esri.UrbanHeatAnalyzer

ApplicationWindow {
    visible: true
    width: 800
    height: 600

    title: "Urban Heat Analyzer"

    Material.theme: Material.Dark
    Material.accent: "#C9F2FF"
    Material.background: "#0289C3"
    Material.foreground: "#FFFFFF"
    Material.primary: "#035799"

    font.pixelSize: 14

    header: ToolBar {
        id: toolbar

        RowLayout {
            anchors.fill: parent

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Material.background

                Component {
                    id: riskDelegate

                    Item {
                        width: 200
                        height: toolbar.height

                        ColumnLayout {
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                Layout.alignment: Qt.AlignLeft
                                Layout.leftMargin: 10
                                color: Material.foreground
                                text: "<b>Name:</b>  " + name
                            }
                            Text {
                                Layout.alignment: Qt.AlignLeft
                                Layout.leftMargin: 10
                                color: Material.foreground
                                text: "<b>Risk:</b>  " + risk
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                riskView.currentIndex = index;
                                mapForm.heatRiskListModel.select(index);
                            }
                        }
                    }
                }

                ListView {
                    id: riskView
                    anchors.fill: parent
                    orientation: Qt.Horizontal

                    model: mapForm.heatRiskListModel
                    delegate: riskDelegate
                    highlight: Rectangle { color: Material.primary; radius: 5 }
                    focus: false
                }
            }

            ToolButton {
                text: qsTr("Clear")
                onClicked: {
                    mapForm.clearOverlay();
                }
            }
        }
    }

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
        }
    }

    UrbanHeatAnalyzerForm {
        id: mapForm
        anchors.fill: parent
    }
}
