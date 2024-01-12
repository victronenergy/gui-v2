
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

	GradientListView {
		model: ObjectModel {
			ListTextItem {
				text: CommonWords.state
				dataItem.uid: root.bindPrefix + "/State"
				secondaryText: Global.digitalInputs.inputStateToText(dataItem.value)
			}

			ListNavigationItem {
				text: CommonWords.setup
				onClicked: {
					Global.pageManager.pushPage(settingsComponent, { "title": text })
				}

				Component {
					id: settingsComponent

					Page {
						readonly property string settingsBindPrefix: Global.systemSettings.serviceUid + "/Settings/DigitalInput/" + (deviceInstance.value || 0)

						GradientListView {
							model: ObjectModel {
								ListSwitch {
									id: alarmSwitch
									//% "Enable alarm"
									text: qsTrId("digitalinput_enable_alarm")
									dataItem.uid: settingsBindPrefix + "/AlarmSetting"
								}

								ListSwitch {
									//% "Inverted"
									text: qsTrId("digitalinput_inverted")
									dataItem.uid: settingsBindPrefix + "/InvertTranslation"
								}

								ListSwitch {
									//% "Invert alarm logic"
									text: qsTrId("digitalinput_invert_alarm_logic")
									dataItem.uid: settingsBindPrefix + "/InvertAlarm"
									visible: alarmSwitch.checked
								}
							}
						}

						VeQuickItem {
							id: deviceInstance
							uid: bindPrefix + "/DeviceInstance"
						}
					}
				}
			}

			ListNavigationItem {
				text: CommonWords.device_info_title
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageDeviceInfo.qml",
							{ "title": text, "bindPrefix": root.bindPrefix })
				}
			}
		}
	}
}
