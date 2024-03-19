/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	readonly property string bindPrefix: Global.systemSettings.serviceUid
	property bool isMulti

	readonly property var defaultOptionModel: [
		{ display: CommonWords.disabled, value: 0 },
		//% "Alarm only"
		{ display: qsTrId("vebus_device_alarm_only"), value: 1 }, // no pre-alarms
		//% "Alarms & warnings"
		{ display: qsTrId("vebus_device_alarms_and_warnings"), value: 2 }
	]

	GradientListView {
		model: VeBusDeviceAlarmSettingsModel { id: alarmSettingsModel }
		delegate: AlarmLevelRadioButtonGroup {
			text: alarmSettingsModel.displayTexts[model.index]
			dataItem.uid: root.bindPrefix + "/Settings/Alarm/Vebus" + model.pathSuffix
			allowed: model.multiPhaseOnly ? isMulti : true
		}
		footer: ListRadioButtonGroup {
			text: CommonWords.vebus_error
			dataItem.uid: root.bindPrefix + "/Settings/Alarm/Vebus/VeBusError"
			optionModel: [
				{ display: CommonWords.disabled, value: 0 },
				{ display: CommonWords.enabled, value: 2 }
			]
		}
	}
}
