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

import QtQuick 2.0
import org.kde.plasma.configuration 2.0

ConfigModel {
    ConfigCategory {
         name: i18n("General")
         icon: "preferences-desktop-locale"
         source: "configGeneral.qml"
    }
    ConfigCategory {
         name: i18n("User Manual")
         icon: "help-browser"
         source: "configManual.qml"
    }
}
