/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Provides a list of settings for an acsystem service.

	Note this does not extend DevicePage, as an AC system is a virtual device for managing a group
	of Multi RS devices.
*/
Page {
	id: root

	property string bindPrefix
	readonly property bool multiPhase: numberOfPhases.valid && numberOfPhases.value > 1

	AcInputSettingsModel {
		id: inputSettingsModel
		serviceUid: root.bindPrefix
	}

	title: acSystemDevice.name

	VeQuickItem {
		id: numberOfPhases
		uid: root.bindPrefix + "/Ac/NumberOfPhases"
	}

	Device {
		id: acSystemDevice
		serviceUid: root.bindPrefix
	}

	GradientListView {
		model: DelegateComponentModel {
			DelegateComponent {
				ListInverterChargerModeButton {
					serviceUid: root.bindPrefix
				}
			}

			DelegateComponent {
				ListText {
					text: CommonWords.state
					secondaryText: VenusOS.system_stateToText(dataItem.value)
					dataItem.uid: root.bindPrefix + "/State"
				}
			}

			DelegateComponent {
				preferredVisible: inputSettingsModel.count > 0
				SettingsColumn {
					width: parent ? parent.width : 0

					Repeater {
						model: inputSettingsModel
						delegate: ListCurrentLimitButton {
							required property AcInputSettings inputSettings

							serviceUid: root.bindPrefix
							inputNumber: inputSettings.inputNumber
							inputType: inputSettings.inputType
						}
					}
				}
			}

			DelegateComponent {
				ListActiveAcInput {
					bindPrefix: root.bindPrefix
				}
			}

			DelegateComponent {
				RsSystemAcIODisplay {
					serviceUid: root.bindPrefix
				}
			}

			DelegateComponent {
				ListNavigation {
					//% "System alarms"
					text: qsTrId("rssystem_system_alarms")
					onClicked: {
						Global.pageManager.pushPage("/pages/settings/devicelist/rs/PageRsSystemAlarms.qml",
								{ "title": text, "bindPrefix": root.bindPrefix })
					}
				}
			}

			DelegateComponent {
				ListNavigation {
					text: CommonWords.alarm_setup
					onClicked: {
						Global.pageManager.pushPage("/pages/settings/devicelist/rs/PageRsAlarmSettings.qml",
								{ "title": text, "bindPrefix": root.bindPrefix })
					}
				}
			}

			DelegateComponent {
				ListNavigation {
					text: CommonWords.ess
					onClicked: {
						Global.pageManager.pushPage("/pages/settings/devicelist/rs/PageRsSystemEss.qml",
								{ "title": text, "bindPrefix": root.bindPrefix })
					}
				}
			}

			DelegateComponent {
				ListNavigation {
					//% "RS devices"
					text: qsTrId("settings_rs_devices")
					onClicked: {
						Global.pageManager.pushPage("/pages/settings/devicelist/rs/PageRsSystemDevices.qml",
								{ "title": text, "bindPrefix": root.bindPrefix })
					}
				}
			}

			DelegateComponent {
				ListTextField {
					text: CommonWords.custom_name
					dataItem.uid: root.bindPrefix + "/CustomName"
				}
			}
		}
	}
}
