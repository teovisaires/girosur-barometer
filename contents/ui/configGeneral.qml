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
    id: configPage
    width: 480
    height: 520

    // Plasma Configuration Bindings (cfg_<entryName> automatically binds to plasmoid.configuration.<entryName>)
    property string cfg_countryName: ""
    property string cfg_cityName: ""
    property string cfg_coordinates: ""
    property string cfg_latitude: ""
    property string cfg_longitude: ""
    property string cfg_referencePressure: "1013.25"
    property alias cfg_updateInterval: intervalSpin.value

    ListModel {
        id: suggestionsModel
    }

    QQC2.ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true

        ColumnLayout {
            width: parent.width
            spacing: 16

            PlasmaComponents.Label {
                text: i18n("Location & Barometer Settings")
                font.bold: true
                font.pixelSize: 15
            }

            // --- SINGLE LOCATION METHOD: Global City Search ---
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: colSearch.implicitHeight + 24
                color: PlasmaCore.Theme.viewBackgroundColor
                border.color: PlasmaCore.Theme.highlightColor
                radius: 6

                ColumnLayout {
                    id: colSearch
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    PlasmaComponents.Label {
                        text: i18n("Search any city in the world:")
                        font.bold: true
                        font.pixelSize: 13
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        PlasmaComponents.TextField {
                            id: searchInput
                            Layout.fillWidth: true
                            placeholderText: i18n("Type a city (e.g. London, Tokyo, New York, Buenos Aires)...")

                            onTextChanged: {
                                if (text.length >= 2) {
                                    searchTimer.restart();
                                } else {
                                    suggestionsModel.clear();
                                }
                            }

                            onAccepted: {
                                searchTimer.stop();
                                performSearch(text);
                            }
                        }

                        PlasmaComponents.Button {
                            text: i18n("Search")
                            iconName: "system-search"
                            onClicked: {
                                searchTimer.stop();
                                performSearch(searchInput.text);
                            }
                        }
                    }

                    Timer {
                        id: searchTimer
                        interval: 400
                        repeat: false
                        onTriggered: performSearch(searchInput.text)
                    }

                    // Suggestions Results List
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Math.min(180, suggestionsView.contentHeight + 8)
                        color: PlasmaCore.Theme.backgroundColor
                        border.color: PlasmaCore.Theme.highlightColor
                        radius: 4
                        visible: suggestionsModel.count > 0

                        ListView {
                            id: suggestionsView
                            anchors.fill: parent
                            model: suggestionsModel
                            clip: true

                            delegate: Rectangle {
                                width: suggestionsView.width
                                height: 38
                                color: mouseArea.containsMouse ? PlasmaCore.Theme.highlightColor : "transparent"

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10

                                    PlasmaComponents.Label {
                                        text: model.displayName
                                        color: mouseArea.containsMouse ? PlasmaCore.Theme.highlightedTextColor : PlasmaCore.Theme.textColor
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                        font.bold: mouseArea.containsMouse
                                    }

                                    PlasmaComponents.Label {
                                        text: model.lat.toFixed(4) + ", " + model.lon.toFixed(4)
                                        color: mouseArea.containsMouse ? PlasmaCore.Theme.highlightedTextColor : PlasmaCore.Theme.disabledTextColor
                                        font.pixelSize: 11
                                    }
                                }

                                MouseArea {
                                    id: mouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        var latStr = parseFloat(model.lat).toFixed(4);
                                        var lonStr = parseFloat(model.lon).toFixed(4);
                                        configPage.cfg_cityName = model.displayName;
                                        configPage.cfg_latitude = latStr;
                                        configPage.cfg_longitude = lonStr;
                                        configPage.cfg_coordinates = latStr + "," + lonStr;
                                        configPage.cfg_countryName = model.country || "Global";

                                        cityNameField.text = model.displayName;
                                        latField.text = latStr;
                                        lonField.text = lonStr;
                                        suggestionsModel.clear();
                                        searchInput.text = "";
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // --- CONFIGURATION SUMMARY & MANUAL DETAILS ---
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: colDetails.implicitHeight + 24
                color: PlasmaCore.Theme.viewBackgroundColor
                border.color: PlasmaCore.Theme.disabledTextColor
                radius: 6

                ColumnLayout {
                    id: colDetails
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    PlasmaComponents.Label {
                        text: i18n("Configured Location Details:")
                        font.bold: true
                    }

                    GridLayout {
                        columns: 2
                        Layout.fillWidth: true
                        columnSpacing: 12
                        rowSpacing: 10

                        PlasmaComponents.Label { text: i18n("City:") }
                        PlasmaComponents.TextField {
                            id: cityNameField
                            Layout.fillWidth: true
                            onAccepted: {
                                geocodeCityName(text)
                            }
                            onEditingFinished: {
                                if (text.trim() !== "") {
                                    geocodeCityName(text)
                                }
                            }
                        }

                        PlasmaComponents.Label { text: i18n("Latitude:") }
                        PlasmaComponents.TextField {
                            id: latField
                            Layout.fillWidth: true
                        }

                        PlasmaComponents.Label { text: i18n("Longitude:") }
                        PlasmaComponents.TextField {
                            id: lonField
                            Layout.fillWidth: true
                        }

                        PlasmaComponents.Label { text: i18n("Update Interval (min):") }
                        QQC2.SpinBox {
                            id: intervalSpin
                            from: 1
                            to: 180
                            stepSize: 5
                            value: 15
                        }
                    }
                }
            }
        }
    }

    function geocodeCityName(query) {
        if (!query || query.trim().length < 2) return;
        var urlPrimary = "https://geocoding-api.open-meteo.com/v1/search?name=" + encodeURIComponent(query.trim()) + "&count=1&language=es";
        var xhr = new XMLHttpRequest();
        xhr.open("GET", urlPrimary, true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                try {
                    var data = JSON.parse(xhr.responseText);
                    if (data.results && data.results.length > 0) {
                        applyGeocodeResult(data.results[0]);
                    } else {
                        // Fallback without language filter
                        var urlFallback = "https://geocoding-api.open-meteo.com/v1/search?name=" + encodeURIComponent(query.trim()) + "&count=1";
                        var xhr2 = new XMLHttpRequest();
                        xhr2.open("GET", urlFallback, true);
                        xhr2.onreadystatechange = function() {
                            if (xhr2.readyState === XMLHttpRequest.DONE && xhr2.status === 200) {
                                try {
                                    var data2 = JSON.parse(xhr2.responseText);
                                    if (data2.results && data2.results.length > 0) {
                                        applyGeocodeResult(data2.results[0]);
                                    }
                                } catch(e2) {}
                            }
                        };
                        xhr2.send();
                    }
                } catch(e) {
                    console.log("Error auto-geocoding city:", e);
                }
            }
        };
        xhr.send();
    }

    function applyGeocodeResult(item) {
        var nameParts = [];
        if (item.name) nameParts.push(item.name);
        if (item.admin1 && item.admin1 !== item.name) nameParts.push(item.admin1);
        if (item.country) nameParts.push(item.country);
        var fullName = nameParts.join(", ");
        
        var latStr = parseFloat(item.latitude).toFixed(4);
        var lonStr = parseFloat(item.longitude).toFixed(4);
        configPage.cfg_cityName = fullName;
        configPage.cfg_latitude = latStr;
        configPage.cfg_longitude = lonStr;
        configPage.cfg_coordinates = latStr + "," + lonStr;
        configPage.cfg_countryName = item.country || "Global";

        cityNameField.text = fullName;
        latField.text = latStr;
        lonField.text = lonStr;
    }

    function performSearch(query) {
        if (!query || query.trim().length < 2) return;
        var urlPrimary = "https://geocoding-api.open-meteo.com/v1/search?name=" + encodeURIComponent(query.trim()) + "&count=10&language=es";
        var xhr = new XMLHttpRequest();
        xhr.open("GET", urlPrimary, true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                try {
                    var data = JSON.parse(xhr.responseText);
                    if (data.results && data.results.length > 0) {
                        populateSuggestions(data.results);
                    } else {
                        // Fallback without language filter
                        var urlFallback = "https://geocoding-api.open-meteo.com/v1/search?name=" + encodeURIComponent(query.trim()) + "&count=10";
                        var xhr2 = new XMLHttpRequest();
                        xhr2.open("GET", urlFallback, true);
                        xhr2.onreadystatechange = function() {
                            if (xhr2.readyState === XMLHttpRequest.DONE && xhr2.status === 200) {
                                try {
                                    var data2 = JSON.parse(xhr2.responseText);
                                    if (data2.results && data2.results.length > 0) {
                                        populateSuggestions(data2.results);
                                    } else {
                                        suggestionsModel.clear();
                                    }
                                } catch(e2) {
                                    suggestionsModel.clear();
                                }
                            }
                        };
                        xhr2.send();
                    }
                } catch(e) {
                    console.log("Error parsing geocoding response:", e);
                }
            }
        };
        xhr.send();
    }

    function populateSuggestions(results) {
        suggestionsModel.clear();
        for (var i = 0; i < results.length; i++) {
            var item = results[i];
            var nameParts = [];
            if (item.name) nameParts.push(item.name);
            if (item.admin1 && item.admin1 !== item.name) nameParts.push(item.admin1);
            if (item.country) nameParts.push(item.country);
            
            var fullName = nameParts.join(", ");
            suggestionsModel.append({
                displayName: fullName,
                lat: parseFloat(item.latitude),
                lon: parseFloat(item.longitude),
                country: item.country || ""
            });
        }
    }
}
