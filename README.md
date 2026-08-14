# Giro-Sur Barometer (Plasma Applet)

**Giro-Sur Barometer** is an analog marine aneroid widget for KDE Plasma that displays real-time atmospheric pressure with a classic, highly detailed interface.

Inspired by traditional nautical barometers, it combines the aesthetic charm of physical instrumentation with automatically updated weather data.

---

## 🌟 Key Features

- 🌊 **Aneroid Marine Dial**: Realistic graphical style calibrated in hectopascals (hPa) with weather condition indicators (*Stormy, Rain, Change, Fair, Very Dry*).
- 🔵 **Current Pressure Hand**: Smoothly animated blue pointer that responds to real-time atmospheric pressure variations.
- 🟡 **Reference (Memory) Hand**: Secondary gold hand to manually benchmark pressure trends against previous readings.
- 📈 **3-Hour Pressure Trend**: Shows whether atmospheric pressure is rising, steady, or falling (essential for forecasting weather fronts and storms).
- 🌐 **Global Weather Data**: Powered by the public **Open-Meteo API**, featuring easy city search and geographic coordinate lookup.
- ⚙️ **Flexible Configuration**: Intuitive location picker with live sensor state preview and customizable update frequency.
- 🖥️ **Plasma Compatibility**: Designed to work seamlessly on KDE Plasma 5 and 6 desktops, panels, and docks.

---

## 📋 Requirements

- KDE Plasma 5.24+ or Plasma 6
- Qt / KDE Frameworks
- Plasma package tool (`kpackagetool5` or `kpackagetool6`)

---

## 🛠️ Installation

### Option A: From source (Terminal)

1. Clone or download this repository:
   ```bash
   git clone https://github.com/teovisaires/girosur-barometer.git
   cd girosur-barometer
   ```

2. Run the installation command for KDE Plasma:
   ```bash
   # On KDE Plasma 5:
   kpackagetool5 -t Plasma/Applet -i .

   # On KDE Plasma 6:
   kpackagetool6 -t Plasma/Applet -i .
   ```

3. To update an existing installation:
   ```bash
   kpackagetool5 -t Plasma/Applet -u .
   ```

### Option B: From `.plasmoid` package

1. Download the `girosur-barometer-1.0.0.plasmoid` file from the [Releases](https://github.com/teovisaires/girosur-barometer/releases) section.
2. Right-click on your KDE Plasma panel -> **Add Widgets...** -> **Get New Widgets...** -> **Install from local file...** and select the `.plasmoid` file.

---

## 📄 License

Distributed under the **GNU General Public License v2.0 or later (GPL-2.0-or-later)**. See [LICENSE](LICENSE) for details.

---

## 👤 Author

Developed by **Teodoro Visaires** (<teovisaires@gmx.com>)  
**Giro-Sur Project**
