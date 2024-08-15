/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix
	readonly property bool multiPhase: numberOfPhases.isValid && numberOfPhases.value > 1

	VeQuickItem {
		id: numberOfPhases
		uid: root.bindPrefix + "/Ac/NumberOfPhases"
	}

	GradientListView {
		model: ObjectModel {
			ListItem {
				id: modeListButton

				text: CommonWords.mode
				writeAccessLevel: VenusOS.User_AccessType_User
				content.children: [
					InverterChargerModeButton {
						width: Math.min(implicitWidth, modeListButton.maximumContentWidth)
						serviceUid: root.bindPrefix
					}
				]
			}

			ListTextItem {
				text: CommonWords.state
				secondaryText: Global.system.systemStateToText(dataItem.value)
				dataItem.uid: root.bindPrefix + "/State"
			}

			ListItem {
				id: currentLimitListButton

				text: numberOfAcInputs.isValid && numberOfAcInputs.value > 1
							//% "Input current limit - AC in 1"
						  ? qsTrId("rs_currentlimit_title")
						  : CommonWords.input_current_limit
				writeAccessLevel: VenusOS.User_AccessType_User
				content.children: [
					CurrentLimitButton {
						width: Math.min(implicitWidth, currentLimitListButton.maximumContentWidth)
						serviceUid: root.bindPrefix
						inputNumber: 1  // Only show details for AC input 1
					}
				]

				VeQuickItem {
					id: numberOfAcInputs
					uid: root.bindPrefix + "/Ac/NumberOfAcInputs"
				}
			}

			ActiveAcInputTextItem {
				bindPrefix: root.bindPrefix
			}

			RsSystemAcIODisplay {
				serviceUid: root.bindPrefix
			}

			ListNavigationItem {
				text: CommonWords.alarm_setup
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/rs/PageRsAlarmSettings.qml",
							{ "title": text, "bindPrefix": root.bindPrefix })
				}
			}

			ListNavigationItem {
				text: CommonWords.ess
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/rs/PageRsSystemEss.qml",
							{ "title": text, "bindPrefix": root.bindPrefix })
				}
			}

			ListNavigationItem {
				//% "RS devices"
				text: qsTrId("settings_rs_devices")
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/rs/PageRsSystemDevices.qml",
							{ "title": text, "bindPrefix": root.bindPrefix })
				}
			}

			ListTextField {
				text: CommonWords.custom_name
				dataItem.uid: root.bindPrefix + "/CustomName"
			}
		}
	}
}
