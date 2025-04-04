/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

//
// Allows the "mode" to be changed for inverter, vebus, and acsystem services. Different mode
// options are displayed depending on the service type.
//

ModalDialog {
	id: root

	property string serviceUid
	property int mode

	readonly property string serviceType: BackendConnection.serviceTypeFromUid(serviceUid)
	readonly property bool showInverterModesOnly: serviceType === "inverter" && isInverterChargerItem.value !== 1
	readonly property bool isMulti: root.serviceType === "inverter" ? isInverterChargerItem.value === 1
			: root.serviceType === "vebus" ? numberOfAcInputs.value !== 0
			: root.serviceType === "acsystem" ? true
			: false     // unsupported service
	readonly property bool vebusInverterOnlyModel: serviceType === "vebus" && numberOfAcInputs.value === 0 // for a vebus inverter-only model, such as a "Phoenix Inverter Compact 12/1200"

	title: showInverterModesOnly || vebusInverterOnlyModel
			//% "Inverter mode"
		   ? qsTrId("controlcard_inverter_mode")
			 //% "Inverter / Charger mode"
		   : qsTrId("controlcard_inverter_charger_mode")

	height: header.height + contentHeight + footer.height

	contentItem: ModalDialog.FocusableContentItem {
		anchors {
			top: root.title.bottom
			left: parent.left
			right: parent.right
			leftMargin: Theme.geometry_modalDialog_content_horizontalMargin
			rightMargin: Theme.geometry_modalDialog_content_horizontalMargin
		}
		height: contentColumn.height

		SettingsColumn {
			id: contentColumn
			width: parent.width

			Repeater {
				id: repeater

				// Options for inverter services
				readonly property var inverterModel: [
					{ value: VenusOS.Inverter_Mode_On },
					{ value: VenusOS.Inverter_Mode_Eco },
					{ value: VenusOS.Inverter_Mode_Off },
				]

				// Options for vebus and acsystem services
				readonly property var inverterChargerModel: [
					{ value: VenusOS.InverterCharger_Mode_On },
					{ value: VenusOS.InverterCharger_Mode_ChargerOnly, visible: isMulti },
					{ value: VenusOS.InverterCharger_Mode_InverterOnly, visible: isMulti },
					{ value: VenusOS.InverterCharger_Mode_Off },
					{
						value: VenusOS.InverterCharger_Mode_Passthrough,
						visible: root.serviceType === "acsystem",
						enabled: hasAcPassthroughSupport.value === 1,
					}
				]

				width: parent.width
				model: root.showInverterModesOnly ? inverterModel : inverterChargerModel
				delegate: buttonStyling
			}
		}
	}

	VeQuickItem {
		id: isInverterChargerItem
		uid: root.serviceUid + "/IsInverterCharger"
	}

	VeQuickItem {
		id: numberOfAcInputs
		uid: root.serviceUid + "/Ac/NumberOfAcInputs"
	}

	VeQuickItem {
		id: hasAcPassthroughSupport
		uid: root.serviceUid + "/Capabilities/HasAcPassthroughSupport"
	}

	Component {
		id: buttonStyling

		SettingsColumn {
			width: parent.width

			ListRadioButton {
				flat: true
				interactive: modelData.enabled !== false
				visible: modelData.visible !== false
				checked: modelData.value === root.mode
				text: root.showInverterModesOnly
						? Global.inverterChargers.inverterModeToText(modelData.value)
						: Global.inverterChargers.inverterChargerModeToText(modelData.value)
				onClicked: root.mode = modelData.value
			}

			SeparatorBar {
				width: parent.width
				visible: model.index !== repeater.count - 1
			}
		}
	}
}
