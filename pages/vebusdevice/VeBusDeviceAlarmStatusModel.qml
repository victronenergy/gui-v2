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
		CommonWords.alarm_setting_overload,
		CommonWords.alarm_setting_dc_ripple,
		//% "Voltage Sensor"
		qsTrId("vebus_device_voltage_sensor"),
		CommonWords.temperature_sensor,
		//% "Phase rotation"
		qsTrId("vebus_device_phase_rotation")
	]
	ListElement { pathSuffix: "/LowBattery";		errorItem: false;	multiPhase: true;	showOnlyIfMulti: false	}
	ListElement { pathSuffix: "/HighTemperature";	errorItem: false;	multiPhase: true;	showOnlyIfMulti: false	}
	ListElement { pathSuffix: "/Overload";			errorItem: false;	multiPhase: true;	showOnlyIfMulti: false	}
	ListElement { pathSuffix: "/Ripple";			errorItem: false;	multiPhase: true;	showOnlyIfMulti: false	}
	ListElement { pathSuffix: "/VoltageSensor";		errorItem: true;	multiPhase: false;	showOnlyIfMulti: true	}
	ListElement { pathSuffix: "/TemperatureSensor";	errorItem: true;	multiPhase: false;	showOnlyIfMulti: true	}
	ListElement { pathSuffix: "/PhaseRotation";		errorItem: true;	multiPhase: false;	showOnlyIfMulti: true	}
}
