/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	required property string bindPrefix
	readonly property string title: _numberOfAcInputs.isValid && _numberOfAcInputs.value > 1
			//% "Input current limit - AC in 1"
		  ? qsTrId("rs_currentlimit_title")
		  : CommonWords.input_current_limit

	readonly property real currentLimit: _currentLimit.isValid ? _currentLimit.value : NaN
	readonly property string currentLimitText: _currentLimit.isValid
			? Units.getCombinedDisplayText(VenusOS.Units_Amp, _currentLimit.value)
			: "--"

	function openDialog() {
		if (_currentLimitIsAdjustable.isValid && _currentLimitIsAdjustable.value) {
			Global.dialogLayer.open(_currentLimitDialogComponent, { value: _currentLimit.value })
		} else {
			//% "This current limit is configured as fixed, not user changeable."
			Global.showToastNotification(VenusOS.Notification_Info, qsTrId("rs_current_limit_not_adjustable"), 5000)
		}
	}

	//--- internal members below ---

	readonly property VeQuickItem _currentLimitIsAdjustable: VeQuickItem {
		uid: root.bindPrefix + "/Ac/In/1/CurrentLimitIsAdjustable"
	}

	readonly property VeQuickItem _currentLimit: VeQuickItem {
		uid: root.bindPrefix + "/Ac/In/1/CurrentLimit"
	}

	readonly property VeQuickItem _numberOfAcInputs: VeQuickItem {
		uid: root.bindPrefix + "/Ac/NumberOfAcInputs"
	}

	readonly property Component _currentLimitDialogComponent: Component {
		CurrentLimitDialog {
			title: CommonWords.input_current_limit
			secondaryTitle: _numberOfAcInputs.isValid && _numberOfAcInputs.value > 1 ? CommonWords.acInput(0) : ""
			onAccepted: _currentLimit.setValue(value)
		}
	}
}
