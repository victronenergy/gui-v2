/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ControlCard {
	id: root

	property string serviceUid
	property string name
	readonly property string serviceType: BackendConnection.serviceTypeFromUid(serviceUid)
	readonly property int writeAccessLevel: VenusOS.User_AccessType_User
	readonly property bool userHasWriteAccess: Global.systemSettings.canAccess(writeAccessLevel)
	readonly property bool vebusInverterOnlyModel: serviceType === "vebus" && numberOfAcInputs.value === 0 // for a vebus inverter-only model, such as a "Phoenix Inverter Compact 12/1200"

	icon.source: "qrc:/images/inverter_charger.svg"
	title.text: (serviceType === "inverter" && isInverterChargerItem.value !== 1 ) || vebusInverterOnlyModel
		  //: %1 = the inverter name
		  //% "Inverter (%1)"
		? qsTrId("controlcard_inverter").arg(name)
		  //: %1 = the inverter/charger name
		  //% "Inverter / Charger (%1)"
		: qsTrId("controlcard_inverter_charger").arg(name)

	status.text: Global.system.systemStateToText(stateItem.value)

	VeQuickItem {
		id: stateItem
		uid: root.serviceUid + "/State"
	}

	VeQuickItem {
		id: essModeItem
		uid: root.serviceUid + "/Settings/Ess/Mode"
	}

	VeQuickItem {
		id: essMinSocItem
		uid: root.serviceUid + "/Settings/Ess/MinimumSocLimit"
	}

	VeQuickItem {
		id: isInverterChargerItem
		uid: root.serviceUid + "/IsInverterCharger"
	}

	VeQuickItem {
		id: numberOfAcInputs
		uid: root.serviceUid + "/Ac/NumberOfAcInputs"
	}

	SettingsColumn {
		anchors {
			top: parent.status.bottom
			topMargin: Theme.geometry_controlCard_status_bottomMargin
			left: parent.left
			right: parent.right
		}

		Repeater {
			model: AcInputSettingsModel {
				serviceUid: root.serviceUid
			}
			delegate: SettingsColumn {
				required property AcInputSettings inputSettings

				width: parent.width

				ListCurrentLimitButton {
					serviceUid: root.serviceUid
					inputNumber: inputSettings.inputNumber
					inputType: inputSettings.inputType
					flat: true
				}

				FlatListItemSeparator {}
			}
		}

		ListInverterChargerModeButton {
			serviceUid: root.serviceUid
			flat: true
		}

		FlatListItemSeparator {}

		ListButton {
			id: essStateButton
			text: CommonWords.ess
			flat: true
			preferredVisible: essModeItem.valid
			secondaryText: Global.ess.essStateToButtonText(essModeItem.value)
			// change the font size for the child button
			button.font.pixelSize: Theme.font_size_body1
			onClicked: {
				Global.dialogLayer.open(essModeDialogComponent, { essMode: essModeItem.value })
			}
		}

		ListButton {
			//% "Minimum SOC"
			text: qsTrId("controlcard_inverter_charger_ess_minimum_soc")
			flat: true
			preferredVisible: essMinSocItem.valid && [
				VenusOS.Ess_State_OptimizedWithBatteryLife,
				VenusOS.Ess_State_OptimizedWithoutBatteryLife].includes(essModeItem.value)
			secondaryText: Units.getCombinedDisplayText(VenusOS.Units_Percentage, essMinSocItem.value)
			onClicked: Global.dialogLayer.open(essMinSocDialogComponent)
		}
	}

	Component {
		id: essModeDialogComponent

		InverterChargerEssModeDialog {
			onAccepted: essModeItem.setValue(essMode)
		}
	}

	Component {
		id: essMinSocDialogComponent

		ESSMinimumSOCDialog {
			minimumStateOfCharge: essMinSocItem.value
			onAccepted: essMinSocItem.setValue(minimumStateOfCharge)
		}
	}
}
