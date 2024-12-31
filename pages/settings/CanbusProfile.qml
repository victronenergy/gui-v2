/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQml
import Victron.VenusOS

QtObject {
	id: root

	property string gateway
	property int canConfig
	readonly property string profileText: {
		for (let i = 0; i < optionModel.length; ++i) {
			let description = optionModel[i]
			if (description.value === canbusProfile.value) {
				return description.display
			}
		}
		return ""
	}

	property VeQuickItem canbusProfile: VeQuickItem {
		uid: Global.systemSettings.serviceUid + "/Settings/Canbus/" + root.gateway + "/Profile"
	}

	property var optionModel: [
		{
			//% "Disabled"
			display: qsTrId("settings_disabled"),
			value: VenusOS.CanBusProfile_Disabled
		},
		{
			//% "VE.Can & Lynx Ion BMS (250 kbit/s)"
			display: qsTrId("settings_canbus_vecan_lynx_ion_bms"),
			value: VenusOS.CanBusProfile_Vecan,
			readOnly: isReadOnly(VenusOS.CanBusProfile_Vecan)
		},
		{
			//% "VE.Can & CAN-bus BMS (250 kbit/s)"
			display: qsTrId("settings_canbus_vecan_and_can_bus_bms"),
			value: VenusOS.CanBusProfile_VecanAndCanBms,
			readOnly: isReadOnly(VenusOS.CanBusProfile_VecanAndCanBms)
		},
		{
			//% "CAN-bus BMS LV (500 kbit/s)"
			display: qsTrId("settings_canbus_bms"),
			value: VenusOS.CanBusProfile_CanBms500,
			readOnly: isReadOnly(VenusOS.CanBusProfile_CanBms500)
		},
		{
			//% "CAN-bus BMS HV (500 kbit/s)"
			display: qsTrId("settings_canbus_high_voltage"),
			value: VenusOS.CanBusProfile_HighVoltage,
			readOnly: isReadOnly(VenusOS.CanBusProfile_HighVoltage)
		},
		{
			//% "Oceanvolt (250 kbit/s)"
			display: qsTrId("settings_oceanvolt"),
			value: VenusOS.CanBusProfile_Oceanvolt,
			readOnly: isReadOnly(VenusOS.CanBusProfile_Oceanvolt)
		},
		{
			//% "RV-C (250 kbit/s)"
			display: qsTrId("settings_rvc"),
			value: VenusOS.CanBusProfile_RvC,
			readOnly: isReadOnly(VenusOS.CanBusProfile_RvC)
		},
		{
			//% "Up, but no services (250 kbit/s)"
			display: qsTrId("settings_up_bu_no_services"),
			value: VenusOS.CanBusProfile_None250,
			readOnly: true
		},
		{
			//% "Up, but no services (500 kbit/s)"
			display: qsTrId("settings_up_but_no_services_500"),
			value: VenusOS.CanBusProfile_None500,
			readOnly: true
		}
	]

	function isReadOnly(profile) {
		switch (root.canConfig) {
		case VenusOS.CanBusConfig_ForcedVeCan:
			return profile !== VenusOS.CanBusProfile_Vecan
		case VenusOS.CanBusConfig_ForcedCanBusBms:
			return profile !== VenusOS.CanBusProfile_CanBms500
		// The classic CAN busses don't support CAN fd / CAN XL frames like the HV CAN bus uses.
		// All other protocols are supported.
		case VenusOS.CanBusConfig_AnyBus:
			return profile === VenusOS.CanBusProfile_HighVoltage
		// These interfaces support all profiles
		case VenusOS.CanBusConfig_AnyBusAndHv:
		default:
			return false
		}
	}
}
