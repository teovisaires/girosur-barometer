# Barómetro Giro-Sur (Plasma Applet)

**Barómetro Giro-Sur** es un widget analógico aneroide marino para KDE Plasma que muestra la presión atmosférica en tiempo real con una interfaz clásica y detallada.

Inspirado en los barómetros náuticos tradicionales, combina el encanto de la instrumentación física con datos meteorológicos actualizados automáticamente.

---

## 🌟 Características Principales

- 🌊 **Dial Marino Aneróide**: Estilo gráfico realista calibrado en hectopascales (hPa) con indicaciones de estado del tiempo (*Stormy, Rain, Change, Fair, Very Dry*).
- 🔵 **Aguja de Presión Actual**: Aguja indicadora animada que responde en tiempo real a las variaciones de presión atmosférica.
- 🟡 **Aguja de Referencia (Memoria)**: Aguja dorada secundaria para comparar manualmente la tendencia de la presión desde una lectura anterior.
- 📈 **Tendencia de 3 Horas**: Muestra si la presión atmosférica está subiendo, estable o cayendo (útil para predecir frentes meteorológicos y tormentas).
- 🌐 **Datos Meteorológicos Globales**: Integración con la API pública de **Open-Meteo**, con búsqueda sencilla de ciudades y coordenadas.
- ⚙️ **Configuración Flexible**: Selector de ubicación intuitivo con previsualización del estado del sensor y frecuencia de actualización parametrizable.
- 🖥️ **Compatibilidad Plasma**: Diseñado para funcionar en el escritorio, paneles o docks de KDE Plasma 5 y 6.

---

## 📋 Requisitos

- KDE Plasma 5.24+ o Plasma 6
- Qt / KDE Frameworks
- Herramienta de empaquetado de Plasma (`kpackagetool5` o `kpackagetool6`)

---

## 🛠️ Instalación

### Opción A: Instalación directa desde la fuente (Terminal)

1. Clonar o descargar este repositorio:
   ```bash
   git clone https://github.com/teovisaires/girosur-barometer.git
   cd girosur-barometer
   ```

2. Ejecutar el comando de instalación para KDE Plasma:
   ```bash
   # En KDE Plasma 5:
   kpackagetool5 -t Plasma/Applet -i .

   # En KDE Plasma 6:
   kpackagetool6 -t Plasma/Applet -i .
   ```

3. Si ya estaba instalado y deseas actualizarlo:
   ```bash
   kpackagetool5 -t Plasma/Applet -u .
   ```

### Opción B: Instalación desde paquete `.plasmoid`

1. Descargar el archivo `girosur-barometer-1.0.0.plasmoid` desde la sección de [Releases](https://github.com/teovisaires/girosur-barometer/releases).
2. Hacer clic derecho sobre el panel de tu escritorio KDE -> **Añadir elementos gráficos...** -> **Obtener nuevos elementos gráficos...** -> **Instalar desde archivo local...** y seleccionar el archivo `.plasmoid`.

---

## 📄 Licencia

Este proyecto está distribuido bajo la licencia **GNU General Public License v2.0 or later (GPL-2.0-or-later)**. Revisa el archivo [LICENSE](LICENSE) para más detalles.

---

## 👤 Autor

Desarrollado por **Teodoro Visaires** (<teovisaires@gmx.com>)  
Proyecto **Giro-Sur**
