/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQml
import Victron.VenusOS

ListModel {
	readonly property var displayTexts: [
		CommonWords.low_battery_voltage,
		CommonWords.temperature,
		//% "Overload"
		qsTrId("vebus_device_overload"),
		//% "DC ripple"
		qsTrId("vebus_device_dc_ripple"),
		//% "Voltage Sensor"
		qsTrId("vebus_device_voltage_sensor"),
		CommonWords.temperature_sensor,
		//% "Phase rotation"
		qsTrId("vebus_device_phase_rotation")
	]
	ListElement { pathSuffix: "/LowBattery";		errorItem: false;	multiPhase: true	}
	ListElement { pathSuffix: "/HighTemperature";	errorItem: false;	multiPhase: true	}
	ListElement { pathSuffix: "/Overload";			errorItem: false;	multiPhase: true	}
	ListElement { pathSuffix: "/Ripple";			errorItem: false;	multiPhase: true	}
	ListElement { pathSuffix: "/VoltageSensor";		errorItem: true;	multiPhase: false	}
	ListElement { pathSuffix: "/TemperatureSensor";	errorItem: true;	multiPhase: false	}
	ListElement { pathSuffix: "/PhaseRotation";		errorItem: true;	multiPhase: false	}
}
