/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix
	property var veBusDevice
	property int numberOfPhases: phases.isValid ? phases.value : 1
	property bool isMulti

	VeQuickItem {
		id: phases

		uid: veBusDevice.serviceUid + "/Ac/NumberOfPhases"
	}

	title: CommonWords.alarm_status

	GradientListView {
		model: ObjectModel {

			ListText {
				text: CommonWords.vebus_error
				dataItem.uid: veBusDevice.serviceUid + "/VebusError"
			}

			Column {
				width: parent ? parent.width : 0

				Repeater {
					model: VeBusDeviceAlarmStatusModel { id: alarmStatusModel }

					VeBusAlarm {
						id: alarmDelegate

						required property int index
						required property string pathSuffix
						required property bool errorItem
						required property bool multiPhase
						required property bool showOnlyIfMulti

						text: alarmStatusModel.displayTexts[index]
						bindPrefix: veBusDevice.serviceUid
						numOfPhases: root.numberOfPhases
						multiPhase: alarmDelegate.multiPhase
						alarmSuffix: pathSuffix
						errorItem: alarmDelegate.errorItem
						allowed: defaultAllowed && (!showOnlyIfMulti || root.isMulti)
					}
				}
			}

			ListNavigation {
				//% "VE.Bus Error 8 / 11 report"
				text: qsTrId("vebus_device_error_8_11_report")
				onClicked: Global.pageManager.pushPage("/pages/vebusdevice/PageVeBusError11View.qml", {
								bindPrefix: veBusDevice.serviceUid,
								title: text
				})
			}
		}
	}
}
