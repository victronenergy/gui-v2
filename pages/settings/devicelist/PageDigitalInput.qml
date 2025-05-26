
/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

	title: device.customName || VenusOS.digitalInput_typeToText(inputType.value)

	VeQuickItem {
		id: inputType
		uid: root.bindPrefix + "/Type"
	}

	Device {
		id: device
		serviceUid: root.bindPrefix
	}

	GradientListView {
		model: VisibleItemModel {
			ListText {
				text: CommonWords.type
				secondaryText: VenusOS.digitalInput_typeToText(inputType.value)
			}

			ListText {
				text: CommonWords.state
				dataItem.uid: root.bindPrefix + "/State"
				secondaryText: VenusOS.digitalInput_stateToText(dataItem.value)
			}

			ListNavigation {
				text: CommonWords.setup
				onClicked: {
					Global.pageManager.pushPage(settingsComponent, { "title": text })
				}

				Component {
					id: settingsComponent

					Page {
						GradientListView {
							model: VisibleItemModel {
								ListSwitch {
									id: alarmSwitch
									//% "Enable alarm"
									text: qsTrId("digitalinput_enable_alarm")
									dataItem.uid: root.bindPrefix + "/Settings/AlarmSetting"
								}

								ListSwitch {
									//% "Inverted"
									text: qsTrId("digitalinput_inverted")
									dataItem.uid: root.bindPrefix + "/Settings/InvertTranslation"
								}

								ListSwitch {
									//% "Invert alarm logic"
									text: qsTrId("digitalinput_invert_alarm_logic")
									dataItem.uid: root.bindPrefix + "/Settings/InvertAlarm"
									preferredVisible: alarmSwitch.checked
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

			ListNavigation {
				text: CommonWords.device_info_title
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageDeviceInfo.qml",
							{ "title": text, "bindPrefix": root.bindPrefix })
				}
			}
		}
	}
}
