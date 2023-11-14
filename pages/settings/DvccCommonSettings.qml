/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Column {
	property alias dvccActive: dvccSwitch.checked
	readonly property alias userHasWriteAccess: dvccSwitch.userHasWriteAccess

	ListDvccSwitch {
		id: dvccSwitch

		//% "DVCC"
		text: qsTrId("settings_dvcc_dvcc")
		dataSource: "com.victronenergy.settings/Settings/Services/Bol"

		onClicked: {
			if (dataValid && !checked) {
				//% "Make sure to also reset the VE.Bus system after disabling DVCC"
				Global.showToastNotification(VenusOS.Notification_Info, qsTrId("settings_dvcc_switch_reset_vebus_after_disabling_dvcc"))
			}
		}
	}

	ListSwitch {
		id: maxChargeCurrentSwitch

		//% "Limit charge current"
		text: qsTrId("settings_dvcc_limit_charge_current")
		updateOnClick: false
		checked: maxChargeCurrent.dataValid && maxChargeCurrent.dataValue >= 0
		visible: defaultVisible && dvccSwitch.checked
		onClicked: {
			maxChargeCurrent.setDataValue(maxChargeCurrent.dataValue < 0 ? 50 : -1)
		}
	}

	ListSpinBox {
		id: maxChargeCurrent

		//% "Maximum charge current"
		text: qsTrId("settings_dvcc_max_charge_current")
		visible: defaultVisible && maxChargeCurrentSwitch.visible && maxChargeCurrentSwitch.checked
		dataSource: "com.victronenergy.settings/Settings/SystemSetup/MaxChargeCurrent"
		suffix: "A"
	}
}
