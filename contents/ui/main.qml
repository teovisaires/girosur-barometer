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
    property string weatherStatus: "CAMBIO"
    property string lastUpdated: ""
    property bool isLoading: false

    // Reactive Configuration bindings
    property string cityName: plasmoid.configuration.cityName || "Funes, Santa Fe, Argentina"
    property string coordinatesStr: plasmoid.configuration.coordinates || (plasmoid.configuration.latitude && plasmoid.configuration.longitude ? (plasmoid.configuration.latitude + "," + plasmoid.configuration.longitude) : "-32.9157,-60.8100")
    property int updateIntervalMinutes: plasmoid.configuration.updateInterval || 15
    property double referenceHpa: parseFloat(plasmoid.configuration.referencePressure || "1013.25")

    property int activeRequestId: 0
    property string lastFetchedCoords: ""

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    Plasmoid.toolTipMainText: cityName
    Plasmoid.toolTipSubText: "Presión: " + (isNaN(currentHpa) ? "---" : currentHpa.toFixed(1)) + " hPa (" + weatherStatus + ")\n" +
                             "Referencia: " + (isNaN(referenceHpa) ? "1013.25" : referenceHpa.toFixed(1)) + " hPa\n" +
                             "Actualizado: " + (lastUpdated ? lastUpdated : "Cargando...")

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

        // 1. Clean Base Dial Background (barometro_sin_agujas.png)
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
            rotation: hpaToAngle(root.currentHpa)
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
            rotation: hpaToAngle(root.referenceHpa)
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

        // Single click timer to distinguish single click from double click
        Timer {
            id: singleClickTimer
            interval: 250
            repeat: false
            onTriggered: scheduleFetch()
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            z: 20
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

    // Debounce timer for configuration updates
    Timer {
        id: fetchDebounceTimer
        interval: 300
        repeat: false
        onTriggered: fetchPressureData()
    }

    // Auto-update timer
    Timer {
        id: updateTimer
        interval: Math.max(1, root.updateIntervalMinutes) * 60 * 1000
        repeat: true
        running: true
        onTriggered: fetchPressureData()
    }

    Component.onCompleted: {
        fetchPressureData();
    }

    function scheduleFetch() {
        fetchDebounceTimer.restart();
    }

    onCoordinatesStrChanged: scheduleFetch()

    function fetchPressureData() {
        var rawCoords = plasmoid.configuration.coordinates || (plasmoid.configuration.latitude && plasmoid.configuration.longitude ? (plasmoid.configuration.latitude + "," + plasmoid.configuration.longitude) : "-32.9157,-60.8100");
        var parts = rawCoords.split(",");
        if (parts.length < 2) return;
        var lat = parseFloat(parts[0]);
        var lon = parseFloat(parts[1]);
        if (isNaN(lat) || isNaN(lon)) return;

        root.activeRequestId++;
        var currentReqId = root.activeRequestId;

        root.isLoading = true;

        // Append timestamp parameter Date.now() to prevent HTTP response caching
        var url = "https://api.open-meteo.com/v1/forecast?latitude=" + lat +
                  "&longitude=" + lon +
                  "&current=pressure_msl,surface_pressure&_t=" + Date.now();

        var xhr = new XMLHttpRequest();
        xhr.open("GET", url, true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (currentReqId !== root.activeRequestId) {
                    // Discard response if a newer request was dispatched
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

                            if (root.currentHpa < 975) root.weatherStatus = "TEMPESTAD";
                            else if (root.currentHpa < 995) root.weatherStatus = "LLUVIA";
                            else if (root.currentHpa < 1020) root.weatherStatus = "CAMBIO";
                            else if (root.currentHpa < 1045) root.weatherStatus = "BUEN TIEMPO";
                            else root.weatherStatus = "MUY SECO";

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
