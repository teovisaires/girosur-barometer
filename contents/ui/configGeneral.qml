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
    property string cfg_countryName: "Búsqueda Global"
    property string cfg_cityName: "Funes, Santa Fe, Argentina"
    property string cfg_coordinates: "-32.9157,-60.8100"
    property string cfg_latitude: "-32.9157"
    property string cfg_longitude: "-60.8100"
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
                text: i18n("Configuración de Ubicación y Barómetro")
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
                        text: i18n("Buscar cualquier ciudad del mundo:")
                        font.bold: true
                        font.pixelSize: 13
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        PlasmaComponents.TextField {
                            id: searchInput
                            Layout.fillWidth: true
                            placeholderText: i18n("Escribe una ciudad (ej: Funes, Montevideo, Tokio, Barcelona)...")

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
                            text: i18n("Buscar")
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
                        text: i18n("Detalles de la Ubicación Configurada:")
                        font.bold: true
                    }

                    GridLayout {
                        columns: 2
                        Layout.fillWidth: true
                        columnSpacing: 12
                        rowSpacing: 10

                        PlasmaComponents.Label { text: i18n("Ciudad:") }
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

                        PlasmaComponents.Label { text: i18n("Latitud:") }
                        PlasmaComponents.TextField {
                            id: latField
                            Layout.fillWidth: true
                        }

                        PlasmaComponents.Label { text: i18n("Longitud:") }
                        PlasmaComponents.TextField {
                            id: lonField
                            Layout.fillWidth: true
                        }

                        PlasmaComponents.Label { text: i18n("Intervalo de actualización (min):") }
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
        var url = "https://geocoding-api.open-meteo.com/v1/search?name=" + encodeURIComponent(query.trim()) + "&count=1&language=es";
        var xhr = new XMLHttpRequest();
        xhr.open("GET", url, true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                try {
                    var data = JSON.parse(xhr.responseText);
                    if (data.results && data.results.length > 0) {
                        var item = data.results[0];
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
                } catch(e) {
                    console.log("Error auto-geocoding city:", e);
                }
            }
        };
        xhr.send();
    }

    function performSearch(query) {
        if (!query || query.trim().length < 2) return;
        var url = "https://geocoding-api.open-meteo.com/v1/search?name=" + encodeURIComponent(query.trim()) + "&count=10&language=es";
        var xhr = new XMLHttpRequest();
        xhr.open("GET", url, true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                try {
                    var data = JSON.parse(xhr.responseText);
                    suggestionsModel.clear();
                    if (data.results && data.results.length > 0) {
                        for (var i = 0; i < data.results.length; i++) {
                            var item = data.results[i];
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
                } catch(e) {
                    console.log("Error parsing geocoding response:", e);
                }
            }
        };
        xhr.send();
    }
}
