/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

SettingsColumn {
	property alias dvccActive: dvccSwitch.checked
	readonly property alias userHasWriteAccess: dvccSwitch.userHasWriteAccess

	ListSwitchForced {
		id: dvccSwitch

		//% "DVCC"
		text: qsTrId("settings_dvcc_dvcc")
		dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Services/Bol"

		onCheckedChanged: {
			if (dataItem.valid && !checked && nrVebusDevices.valid && nrVebusDevices.value >= 1) {
				//% "Make sure to also reset the VE.Bus system after disabling DVCC"
				Global.showToastNotification(VenusOS.Notification_Info, qsTrId("settings_dvcc_switch_reset_vebus_after_disabling_dvcc"))
			}
		}

		VeQuickItem {
			id: nrVebusDevices
			uid: Global.system.serviceUid + "/Devices/NumberOfVebusDevices"
		}
	}

	ListSwitch {
		id: maxChargeCurrentSwitch

		//% "Limit charge current"
		text: qsTrId("settings_dvcc_limit_charge_current")
		checked: maxChargeCurrent.dataItem.valid && maxChargeCurrent.dataItem.value >= 0
		preferredVisible: dvccSwitch.checked
		onClicked: {
			maxChargeCurrent.dataItem.setValue(maxChargeCurrent.dataItem.value < 0 ? 50 : -1)
		}
	}

	ListSpinBox {
		id: maxChargeCurrent

		//% "Maximum charge current"
		text: qsTrId("settings_dvcc_max_charge_current")
		preferredVisible: maxChargeCurrentSwitch.visible && maxChargeCurrentSwitch.checked
		dataItem.uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/MaxChargeCurrent"
		suffix: Units.defaultUnitString(VenusOS.Units_Amp)
	}
}
