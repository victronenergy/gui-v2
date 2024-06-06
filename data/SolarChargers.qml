/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	// Model of all solar chargers
	property DeviceModel model: DeviceModel {
		modelId: "solarChargers"
	}

	function addCharger(charger) {
		model.addDevice(charger)
	}

	function removeCharger(charger) {
		model.removeDevice(charger.serviceUid)
	}

	function reset() {
		model.clear()
	}

	function formatTrackerName(trackerName, trackerIndex, totalTrackerCount, deviceName, format) {
		if (format === VenusOS.TrackerName_WithDevicePrefix) {
			if (trackerName.length > 0) {
				return "%1-%2".arg(deviceName).arg(trackerName)
			} else if (totalTrackerCount > 1) {
				return "%1-#%2".arg(deviceName).arg(trackerIndex + 1)
			} else {
				return deviceName
			}
		} else {    // format === VenusOS.TrackerName_NoDevicePrefix
			if (trackerName.length > 0) {
				return trackerName
			} else {
				return "#%2".arg(deviceName).arg(trackerIndex + 1)
			}
		}
	}

	function chargerStateToText(state) {
		switch (state) {
		case VenusOS.SolarCharger_State_Off:
			//% "Off"
			return qsTrId("solarchargers_state_off")
		case VenusOS.SolarCharger_State_Fault:
			//% "Fault"
			return qsTrId("solarchargers_state_fault")
		case VenusOS.SolarCharger_State_Bulk:
			//% "Bulk"
			return qsTrId("solarchargers_state_bulk")
		case VenusOS.SolarCharger_State_Absorption:
			//% "Absorption"
			return qsTrId("solarchargers_state_absorption")
		case VenusOS.SolarCharger_State_Float:
			//% "Float"
			return qsTrId("solarchargers_state_float")
		case VenusOS.SolarCharger_State_Storage:
			//% "Storage"
			return qsTrId("solarchargers_state_storage")
		case VenusOS.SolarCharger_State_Equalize:
			//% "Equalize"
			return qsTrId("solarchargers_state_equalize")
		case VenusOS.SolarCharger_State_ExternalControl:
			//% "External control"
			return qsTrId("solarchargers_state_external control")
		default:
			return ""
		}
	}

	Component.onCompleted: Global.solarChargers = root
}
