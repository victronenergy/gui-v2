/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Units

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
		id:  gradientListView
		model: ObjectModel {

			Column {
				width: parent ? parent.width : 0

				Repeater {
					model: VeBusDeviceAlarmSettingsModel { id: alarmSettingsModel }

					ListRadioButtonGroup {
						text: alarmSettingsModel.displayTexts[index]
						dataItem.uid: bindPrefix + "/Settings/Alarm/Vebus" + pathSuffix
						visible: multiPhaseOnly ? isMulti : true
						optionModel: pathSuffix !== "/VeBusError"
						? defaultOptionModel
						: [
							  { display: CommonWords.disabled, value: 0 },
							  { display: CommonWords.enabled, value: 2 }
						  ]
					}
				}
			}
		}
	}
}
