/*
 *   GiroSur Barometer – Marine Aneroid Barometer Plasmoid
 *   Barómetro Marino Aneroide “GiroSur” para KDE Plasma
 *   Copyright (C) 2026 Teodoro Visaires <teovisaires@gmx.com>
 *   Created in pair programming with Antigravity (Google DeepMind)
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 *
 *   This program is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 2 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import QtQuick 2.12
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.12
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

Item {
    id: manualPage
    width: 480
    height: 520

    QQC2.ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true

        ColumnLayout {
            width: parent.width
            spacing: 16

            // Header Section
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                PlasmaComponents.Label {
                    text: i18n("Giro-Sur Barometer - User Guide")
                    font.bold: true
                    font.pixelSize: 16
                }

                PlasmaComponents.Label {
                    text: i18n("Analog marine aneroid barometer widget for KDE Plasma 5")
                    opacity: 0.7
                    font.pixelSize: 12
                }
            }

            // --- Card 1: Main Features & Controls ---
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: colCard1.implicitHeight + 24
                color: PlasmaCore.Theme.viewBackgroundColor
                border.color: PlasmaCore.Theme.buttonHoverColor
                border.width: 1
                radius: 6

                ColumnLayout {
                    id: colCard1
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    RowLayout {
                        spacing: 8
                        PlasmaCore.IconItem {
                            source: "dialog-information"
                            implicitWidth: 20
                            implicitHeight: 20
                        }
                        PlasmaComponents.Label {
                            text: i18n("Key Features & Interactivity")
                            font.bold: true
                            font.pixelSize: 13
                        }
                    }

                    PlasmaComponents.Label {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        text: i18n("<b>• Main Blue Hand:</b> Shows the real-time atmospheric pressure updated automatically via the Open-Meteo API.")
                    }

                    PlasmaComponents.Label {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        text: i18n("<b>• Gold Reference Hand:</b> Secondary memory hand to mark your baseline pressure reading and track barometric shifts over time.")
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: PlasmaCore.Theme.buttonHoverColor
                        opacity: 0.4
                    }

                    PlasmaComponents.Label {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        font.pixelSize: 12
                        text: i18n("<b>🎯 Quick Tip (Double-Click):</b> Double-click anywhere on the widget dial to instantly align the gold reference hand with the current pressure hand. Use this to easily start monitoring pressure trends!")
                    }
                }
            }

            // --- Card 2: Dial Readings & Weather Zones ---
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: colCard2.implicitHeight + 24
                color: PlasmaCore.Theme.viewBackgroundColor
                border.color: PlasmaCore.Theme.buttonHoverColor
                border.width: 1
                radius: 6

                ColumnLayout {
                    id: colCard2
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    RowLayout {
                        spacing: 8
                        PlasmaCore.IconItem {
                            source: "weather-clear"
                            implicitWidth: 20
                            implicitHeight: 20
                        }
                        PlasmaComponents.Label {
                            text: i18n("Dial Markings & Weather Condition Zones")
                            font.bold: true
                            font.pixelSize: 13
                        }
                    }

                    PlasmaComponents.Label {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        text: i18n("The dial is calibrated in <b>hectopascals (hPa)</b> with traditional marine indicators:")
                    }

                    PlasmaComponents.Label {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        font.pixelSize: 12
                        text: i18n("• <b>STORMY:</b> Pressure below 980 hPa — Intense low pressure, storm or heavy gale likely.<br>" +
                                   "• <b>RAIN:</b> 980 - 1000 hPa — Low pressure area, rain and windy conditions.<br>" +
                                   "• <b>CHANGE:</b> 1000 - 1020 hPa — Transitional barometric zone, variable weather.<br>" +
                                   "• <b>FAIR:</b> 1020 - 1040 hPa — High pressure area, clear skies and calm weather.<br>" +
                                   "• <b>VERY DRY:</b> Above 1040 hPa — Strong anticyclone, dry and stable conditions.")
                    }
                }
            }

            // --- Card 3: How to Interpret Barometric Trends ---
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: colCard3.implicitHeight + 24
                color: PlasmaCore.Theme.viewBackgroundColor
                border.color: PlasmaCore.Theme.buttonHoverColor
                border.width: 1
                radius: 6

                ColumnLayout {
                    id: colCard3
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    RowLayout {
                        spacing: 8
                        PlasmaCore.IconItem {
                            source: "help-about"
                            implicitWidth: 20
                            implicitHeight: 20
                        }
                        PlasmaComponents.Label {
                            text: i18n("Interpreting Barometric Trends")
                            font.bold: true
                            font.pixelSize: 13
                        }
                    }

                    PlasmaComponents.Label {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        font.pixelSize: 12
                        text: i18n("<b>📈 Rising Pressure:</b> Indicates improving weather, clearing skies, and dry, stable air.<br><br>" +
                                   "<b>📉 Rapidly Falling Pressure:</b> Warns of an approaching front or cyclone. Stronger drops signal wind, rain, or storm intensity.<br><br>" +
                                   "<b>⚖️ Steady High Pressure:</b> Indicates prolonged settled, sunny, or clear weather.")
                    }
                }
            }

            // --- Card 4: Location Search & Settings ---
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: colCard4.implicitHeight + 24
                color: PlasmaCore.Theme.viewBackgroundColor
                border.color: PlasmaCore.Theme.buttonHoverColor
                border.width: 1
                radius: 6

                ColumnLayout {
                    id: colCard4
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    RowLayout {
                        spacing: 8
                        PlasmaCore.IconItem {
                            source: "configure"
                            implicitWidth: 20
                            implicitHeight: 20
                        }
                        PlasmaComponents.Label {
                            text: i18n("Configuration & Data Source")
                            font.bold: true
                            font.pixelSize: 13
                        }
                    }

                    PlasmaComponents.Label {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        font.pixelSize: 12
                        text: i18n("In the <b>General</b> tab, you can search for any city in the world. Weather data is fetched directly from the open-access <b>Open-Meteo API</b> without requiring API keys. You can also customize the update interval (default: 15 minutes).")
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                implicitHeight: 12
            }
        }
    }
}
