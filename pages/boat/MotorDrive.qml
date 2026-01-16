/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

    required property string serviceUid

    readonly property VeQuickItemsQuotient rpm: VeQuickItemsQuotient {
		numeratorUid: root.serviceUid ? root.serviceUid + "/Motor/RPM" : ""
		denominatorUid: Global.systemSettings ? Global.systemSettings.serviceUid  + "/Settings/Gui/Gauges/MotorDrive/RPM/Max" : ""
		sourceUnit: VenusOS.Units_RevolutionsPerMinute
		displayUnit: VenusOS.Units_RevolutionsPerMinute
	}

    readonly property VeQuickItemsQuotient power: VeQuickItemsQuotient {
		numeratorUid: root.serviceUid ? root.serviceUid + "/Dc/0/Power" : ""
		denominatorUid : Global.systemSettings ? Global.systemSettings.serviceUid  + "/Settings/Gui/Gauges/MotorDrive/Power/Max" : ""
		sourceUnit: VenusOS.Units_Watt
		displayUnit: VenusOS.Units_Watt
	}

    readonly property QtObject dcConsumption: QtObject {
		readonly property VeQuickItemsQuotient quotient: root.power
		readonly property QtObject scalar: QtObject {
			readonly property real power: root.power._numerator.value ?? NaN
			readonly property real current: _scalarCurrent.value ?? NaN

			readonly property VeQuickItem _scalarCurrent: VeQuickItem {
				uid: root.serviceUid ? root.serviceUid + "/Dc/0/Current" : ""
			}
		}
	}

    readonly property VeQuickItem direction: VeQuickItem { //  0=neutral, 1=reverse, 2=forward (optional)
        uid: root.serviceUid ? root.serviceUid + "/Motor/Direction" : ""
    }

    readonly property VeQuickItem motorTemperature: VeQuickItem {
        uid: root.serviceUid ? root.serviceUid + "/Motor/Temperature" : ""
        sourceUnit: Units.unitToVeUnit(VenusOS.Units_Temperature_Celsius)
        displayUnit: Units.unitToVeUnit(Global.systemSettings.temperatureUnit)
    }

    readonly property VeQuickItem controllerTemperature: VeQuickItem {
        uid: root.serviceUid ? root.serviceUid + "/Controller/Temperature" : ""
        sourceUnit: Units.unitToVeUnit(VenusOS.Units_Temperature_Celsius)
        displayUnit: Units.unitToVeUnit(Global.systemSettings.temperatureUnit)
    }

    readonly property VeQuickItem coolantTemperature: VeQuickItem {
        uid: root.serviceUid ? root.serviceUid + "/Coolant/Temperature" : ""
        sourceUnit: Units.unitToVeUnit(VenusOS.Units_Temperature_Celsius)
        displayUnit: Units.unitToVeUnit(Global.systemSettings.temperatureUnit)
    }
}
