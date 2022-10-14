/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Column {
	property alias dvccActive: dvccSwitch.checked
	readonly property alias userHasWriteAccess: dvccSwitch.userHasWriteAccess

	SettingsListDvccSwitch {
		id: dvccSwitch

		//% "DVCC"
		text: qsTrId("settings_dvcc_dvcc")
		source: "com.victronenergy.settings/Settings/Services/Bol"

		onCheckedChanged: {
			if (dataPoint.value !== undefined && !checked) {
				//% "Make sure to also reset the VE.Bus system after disabling DVCC"
				Global.dialogManager.showToastNotification(VenusOS.Notification_Info, qsTrId("settings_dvcc_switch_reset_vebus_after_disabling_dvcc"))
			}
		}
	}

	SettingsListSwitch {
		id: maxChargeCurrentSwitch

		//% "Limit charge current"
		text: qsTrId("settings_dvcc_limit_charge_current")
		updateOnClick: false
		checked: maxChargeCurrent.dataPoint.value !== undefined && maxChargeCurrent.dataPoint.value >= 0
		visible: defaultVisible && dvccSwitch.checked
		onClicked: {
			maxChargeCurrent.dataPoint.setValue(maxChargeCurrent.dataPoint.value < 0 ? 50 : -1)
		}
	}

	SettingsListSpinBox {
		id: maxChargeCurrent

		//% "Maximum charge current"
		text: qsTrId("settings_dvcc_max_charge_current")
		visible: defaultVisible && maxChargeCurrentSwitch.visible && maxChargeCurrentSwitch.checked
		source: "com.victronenergy.settings/Settings/SystemSetup/MaxChargeCurrent"
		suffix: "A"
	}
}
