/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

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

			ListTextItem {
				text: CommonWords.vebus_error
				dataItem.uid: veBusDevice.serviceUid + "/VebusError"
			}

			Column {
				width: parent ? parent.width : 0

				Repeater {
					model: VeBusDeviceAlarmStatusModel { id: alarmStatusModel }

					VeBusAlarm {
						text: alarmStatusModel.displayTexts[index]
						bindPrefix: veBusDevice.serviceUid
						numOfPhases: multiPhase ? root.numberOfPhases : 1
						alarmSuffix: pathSuffix
						errorItem: errorItem
					}
				}
			}

			ListNavigationItem {
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
