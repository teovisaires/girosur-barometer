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
import QtQuick.Layouts 1.12
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.plasmoid 2.0

Item {
    id: root

    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation
    implicitWidth: PlasmaCore.Units.gridUnit * 16
    implicitHeight: PlasmaCore.Units.gridUnit * 16
    width: implicitWidth
    height: implicitHeight

    property double currentHpa: 1013.25
    property double previousHpa: 1013.25
    property string weatherStatus: "CHANGE"
    property string lastUpdated: ""
    property bool isLoading: false

    // Reactive Configuration bindings (Default empty on clean install)
    property string cityName: plasmoid.configuration.cityName ? plasmoid.configuration.cityName.toString().trim() : ""
    property string coordinatesStr: plasmoid.configuration.coordinates ? plasmoid.configuration.coordinates.toString().trim() : 
                                     (plasmoid.configuration.latitude && plasmoid.configuration.longitude ? 
                                      (plasmoid.configuration.latitude.toString().trim() + "," + plasmoid.configuration.longitude.toString().trim()) : "")
    property int updateIntervalMinutes: plasmoid.configuration.updateInterval || 15
    property double referenceHpa: parseFloat(plasmoid.configuration.referencePressure || "1013.25")

    property bool isLocationConfigured: (cityName !== "") && (coordinatesStr !== "")

    property int activeRequestId: 0
    property string lastFetchedCoords: ""

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    Plasmoid.toolTipMainText: isLocationConfigured ? cityName : i18n("Giro-Sur Barometer")
    Plasmoid.toolTipSubText: isLocationConfigured ?
                             ("Pressure: " + (isNaN(currentHpa) ? "---" : currentHpa.toFixed(1)) + " hPa (" + weatherStatus + ")\n" +
                              "Reference: " + (isNaN(referenceHpa) ? "1013.25" : referenceHpa.toFixed(1)) + " hPa\n" +
                              "Updated: " + (lastUpdated ? lastUpdated : "Loading...")) :
                             i18n("Location not configured.\nClick to set your city.")

    // Calibrated scale factor: 2.7° per hPa relative to 1013.25 hPa top center
    function hpaToAngle(hpa) {
        var val = parseFloat(hpa);
        if (isNaN(val)) val = 1013.25;
        var clamped = Math.max(960.0, Math.min(1060.0, val));
        return (clamped - 1013.25) * 2.7;
    }

    Item {
        id: barometerContainer
        anchors.fill: parent
        anchors.margins: 4

        // 1. Clean Base Dial Background
        Image {
            id: dialBase
            anchors.fill: parent
            source: "../images/barometro_sin_agujas.png"
            cache: false
            fillMode: Image.PreserveAspectFit
            smooth: true
            z: 0
        }

        // 2. Classic Main Pressure Needle (classic_needle.png - in back)
        Image {
            id: pressureNeedle
            anchors.fill: parent
            source: "../images/classic_needle.png"
            cache: false
            fillMode: Image.PreserveAspectFit
            smooth: true
            transformOrigin: Item.Center
            rotation: hpaToAngle(root.isLocationConfigured ? root.currentHpa : 1013.25)
            z: 1

            Behavior on rotation {
                NumberAnimation { duration: 1200; easing.type: Easing.OutCubic }
            }
        }

        // 3. Bronze Reference Pointer Needle (reference_needle.png - ON TOP in front)
        Image {
            id: referenceNeedle
            anchors.fill: parent
            source: "../images/reference_needle.png"
            cache: false
            fillMode: Image.PreserveAspectFit
            smooth: true
            transformOrigin: Item.Center
            rotation: hpaToAngle(root.isLocationConfigured ? root.referenceHpa : 1013.25)
            z: 2

            Behavior on rotation {
                NumberAnimation { duration: 1000; easing.type: Easing.OutCubic }
            }
        }

        // Loading indicator overlay
        PlasmaComponents.BusyIndicator {
            anchors.centerIn: parent
            width: parent.width * 0.2
            height: width
            running: root.isLoading
            visible: root.isLoading
            z: 10
        }

        // --- FIRST RUN OVERLAY: Location Not Configured ---
        Rectangle {
            id: unconfiguredOverlay
            anchors.centerIn: parent
            width: parent.width * 0.88
            height: parent.height * 0.55
            color: PlasmaCore.Theme.viewBackgroundColor
            border.color: PlasmaCore.Theme.highlightColor
            border.width: 2
            radius: 12
            visible: !root.isLocationConfigured
            opacity: 0.96
            z: 50

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    plasmoid.action("configure").trigger();
                }
            }

            ColumnLayout {
                anchors.centerIn: parent
                width: parent.width - 24
                spacing: 10

                PlasmaCore.IconItem {
                    source: "mark-location"
                    Layout.alignment: Qt.AlignHCenter
                    implicitWidth: 36
                    implicitHeight: 36
                }

                PlasmaComponents.Label {
                    text: i18n("Location Not Set")
                    font.bold: true
                    font.pixelSize: 14
                    Layout.alignment: Qt.AlignHCenter
                    horizontalAlignment: Text.AlignHCenter
                }

                PlasmaComponents.Label {
                    text: i18n("Click to select your city")
                    font.pixelSize: 11
                    opacity: 0.8
                    Layout.alignment: Qt.AlignHCenter
                    horizontalAlignment: Text.AlignHCenter
                }

                PlasmaComponents.Button {
                    text: i18n("Configure Location")
                    iconName: "system-search"
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: {
                        plasmoid.action("configure").trigger();
                    }
                }
            }
        }

        // Single click timer to distinguish single click from double click
        Timer {
            id: singleClickTimer
            interval: 250
            repeat: false
            onTriggered: fetchPressureData()
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            z: 20
            enabled: root.isLocationConfigured
            onClicked: {
                singleClickTimer.restart()
            }
            onDoubleClicked: {
                singleClickTimer.stop()
                root.referenceHpa = root.currentHpa
                plasmoid.configuration.referencePressure = root.currentHpa.toString()
            }
        }
    }

    // Auto-update timer
    Timer {
        id: updateTimer
        interval: Math.max(1, root.updateIntervalMinutes) * 60 * 1000
        repeat: true
        running: root.isLocationConfigured
        onTriggered: fetchPressureData()
    }

    // Direct listener for Plasmoid configuration changes from KDE preferences dialog
    Connections {
        target: plasmoid.configuration
        function onValueChanged() {
            if (root.isLocationConfigured) {
                root.fetchPressureData();
            }
        }
    }

    onIsLocationConfiguredChanged: {
        if (isLocationConfigured) {
            fetchPressureData();
        }
    }

    onCoordinatesStrChanged: {
        if (isLocationConfigured) {
            fetchPressureData();
        }
    }

    onCityNameChanged: {
        if (isLocationConfigured) {
            fetchPressureData();
        }
    }

    Component.onCompleted: {
        if (root.isLocationConfigured) {
            fetchPressureData();
        }
    }

    function fetchPressureData() {
        if (!root.isLocationConfigured) return;

        var rawCoords = root.coordinatesStr;
        if (!rawCoords || rawCoords.trim() === "") return;

        var parts = rawCoords.split(",");
        if (parts.length < 2) return;
        var lat = parseFloat(parts[0]);
        var lon = parseFloat(parts[1]);
        if (isNaN(lat) || isNaN(lon)) return;

        root.activeRequestId++;
        var currentReqId = root.activeRequestId;

        root.isLoading = true;

        var url = "https://api.open-meteo.com/v1/forecast?latitude=" + lat +
                  "&longitude=" + lon +
                  "&current=pressure_msl,surface_pressure&_t=" + Date.now();

        var xhr = new XMLHttpRequest();
        xhr.open("GET", url, true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (currentReqId !== root.activeRequestId) {
                    return;
                }
                root.isLoading = false;
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText);
                        if (response.current && response.current.pressure_msl !== undefined) {
                            root.lastFetchedCoords = rawCoords;
                            root.previousHpa = root.currentHpa;
                            var press = parseFloat(response.current.pressure_msl);
                            if (!isNaN(press)) {
                                root.currentHpa = press;
                            }

                            if (root.currentHpa < 975) root.weatherStatus = "STORMY";
                            else if (root.currentHpa < 995) root.weatherStatus = "RAIN";
                            else if (root.currentHpa < 1020) root.weatherStatus = "CHANGE";
                            else if (root.currentHpa < 1045) root.weatherStatus = "FAIR";
                            else root.weatherStatus = "VERY DRY";

                            var now = new Date();
                            var hours = now.getHours().toString().padStart(2, '0');
                            var minutes = now.getMinutes().toString().padStart(2, '0');
                            root.lastUpdated = hours + ":" + minutes;
                        }
                    } catch(e) {
                        console.log("Error parsing weather data:", e);
                    }
                }
            }
        };
        xhr.onerror = function() {
            if (currentReqId === root.activeRequestId) {
                root.isLoading = false;
            }
        };
        xhr.send();
    }
}
