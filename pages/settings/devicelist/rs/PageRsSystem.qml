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
			ListButton {
				id: modeButton
				text: CommonWords.mode
				secondaryText: modeDetails.modeText
				writeAccessLevel: VenusOS.User_AccessType_User
				onClicked: modeDetails.openDialog()

				RsSystemModeDetails {
					id: modeDetails
					bindPrefix: root.bindPrefix
				}
			}

			ListTextItem {
				text: CommonWords.state
				secondaryText: Global.system.systemStateToText(dataItem.value)
				dataItem.uid: root.bindPrefix + "/State"
			}

			ListButton {
				text: currentLimitDetails.title
				secondaryText: currentLimitDetails.currentLimitText
				writeAccessLevel: VenusOS.User_AccessType_User
				onClicked: currentLimitDetails.openDialog()

				RsSystemCurrentLimitDetails {
					id: currentLimitDetails
					bindPrefix: root.bindPrefix
				}
			}

			ActiveAcInputTextItem {
				bindPrefix: root.bindPrefix
			}

			Loader {
				width: parent ? parent.width : 0
				sourceComponent: numberOfPhases.value === 1 ? singlePhaseAcInOut
						: numberOfPhases.value === 3 ? threePhaseTables
						: null

				Component {
					id: singlePhaseAcInOut

					Column {
						readonly property string singlePhaseName: acOutL3.isValid ? "L3"
								: acOutL2.isValid ? "L2"
								: "L1"  // _phase.value === 0 || !_phase.isValid

						VeQuickItem { id: acOutL1; uid: root.bindPrefix + "/Ac/Out/L1/P" }
						VeQuickItem { id: acOutL2; uid: root.bindPrefix + "/Ac/Out/L2/P" }
						VeQuickItem { id: acOutL3; uid: root.bindPrefix + "/Ac/Out/L3/P" }

						PVCFListQuantityGroup {
							text: CommonWords.ac_in
							data: AcPhase { serviceUid: root.bindPrefix + "/Ac/In/1/" + singlePhaseName }
						}

						PVCFListQuantityGroup {
							text: CommonWords.ac_out
							data: AcPhase { serviceUid: root.bindPrefix + "/Ac/Out/" + singlePhaseName }
						}
					}
				}

				Component {
					id: threePhaseTables

					ThreePhaseIOTable {
						width: parent ? parent.width : 0
						phaseCount: numberOfPhases.value || 0
						inputPhaseUidPrefix: root.bindPrefix + "/Ac/In/1"
						outputPhaseUidPrefix: root.bindPrefix + "/Ac/Out"
						totalInputPowerUid: root.multiPhase ? root.bindPrefix + "/Ac/In/1/P" : ""
						totalOutputPowerUid: root.multiPhase ? root.bindPrefix + "/Ac/Out/P" : ""
						voltPrecision: 2
					}
				}
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
