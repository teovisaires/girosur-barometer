# Giro-Sur Barometer (Plasma Applet)

**Giro-Sur Barometer** is an analog marine aneroid widget for KDE Plasma 5 that displays real-time atmospheric pressure with a classic, highly detailed interface.

Inspired by traditional nautical barometers, it combines the aesthetic charm of physical instrumentation with automatically updated weather data.

---

## 🌟 Key Features

- 🌊 **Aneroid Marine Dial**: Realistic graphical style calibrated in hectopascals (hPa) with weather condition indicators (*Stormy, Rain, Change, Fair, Very Dry*).
- 🔵 **Current Pressure Hand**: Smoothly animated main pointer that responds in real time to atmospheric pressure variations.
- 🟡 **Reference (Memory) Hand**: Secondary gold hand used to mark baseline readings and visually monitor barometric shifts over time.
- 🎯 **Double-Click Reference Alignment**: Double-clicking anywhere on the widget instantly aligns/matches the gold reference hand with the current pressure hand, making it effortless to establish a baseline for tracking pressure changes.
- 🌐 **Global Weather Data**: Powered by the public **Open-Meteo API**, featuring easy city search and geographic coordinate lookup.
- ⚙️ **Flexible Configuration**: Intuitive location picker with live sensor state preview and customizable update frequency.
- 🖥️ **Plasma 5 Native**: Optimized and tested for KDE Plasma 5 desktops, panels, and docks.

---

## 📋 Requirements

- KDE Plasma 5.24+ / 5.27 LTS
- Qt 5 / KDE Frameworks 5
- Plasma 5 package tool (`kpackagetool5`)

---

## 🛠️ Installation

### Option A: From source (Terminal)

1. Clone or download this repository:
   ```bash
   git clone https://github.com/teovisaires/girosur-barometer.git
   cd girosur-barometer
   ```

2. Run the installation command for KDE Plasma 5:
   ```bash
   kpackagetool5 -t Plasma/Applet -i .
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
