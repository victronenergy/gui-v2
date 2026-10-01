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
	property int numberOfPhases: phases.valid ? phases.value : 1
	property bool isMulti

	VeQuickItem {
		id: phases

		uid: root.bindPrefix + "/Ac/NumberOfPhases"
	}

	title: CommonWords.alarm_status

	GradientListView {
		model: DelegateComponentModel {

			DelegateComponent {
				ListText {
					text: CommonWords.vebus_error
					dataItem.uid: root.bindPrefix + "/VebusError"
				}
			}

			DelegateComponent {
				id: alarmStatusDC
				property VeBusDeviceAlarmStatusModel alarmStatusModel: VeBusDeviceAlarmStatusModel {}
				preferredVisible: alarmStatusDC.alarmStatusModel.count > 0
				SettingsColumn {
					width: parent ? parent.width : 0

					Repeater {
						model: alarmStatusDC.alarmStatusModel

						VeBusAlarm {
							id: alarmDelegate

							required property int index
							required property string pathSuffix
							required property bool errorItem
							required property bool multiPhase
							required property bool showOnlyIfMulti

							text: alarmStatusDC.alarmStatusModel.displayTexts[index]
							bindPrefix: root.bindPrefix
							numOfPhases: root.numberOfPhases
							multiPhase: alarmDelegate.multiPhase
							alarmSuffix: pathSuffix
							errorItem: alarmDelegate.errorItem
							preferredVisible: !showOnlyIfMulti || root.isMulti
						}
					}
				}
			}

			DelegateComponent {
				ListNavigation {
					//% "VE.Bus Error 8 / 11 report"
					text: qsTrId("vebus_device_error_8_11_report")
					onClicked: Global.pageManager.pushPage("/pages/vebusdevice/PageVeBusError11View.qml", {
									bindPrefix: root.bindPrefix,
									title: text
					})
				}
			}
		}
	}
}
