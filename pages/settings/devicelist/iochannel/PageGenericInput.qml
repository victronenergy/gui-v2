/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	required property GenericInput genericInput

	// For Aurelia products, some settings are not visible at the user-access level. For now, hard
	// code this configuration in gui-v2, but later on we will generalise this to configure the
	// setting visibility in the backend data values instead. See #2941.
	VeQuickItem {
		id: productId

		readonly property bool isAurelia: valid && (value === ProductInfo.ProductId_Dcdb_Aurelia)

		uid: root.genericInput.serviceUid + "/ProductId"
	}

	GradientListView {
		model: VisibleItemModel {
			ListIOChannelNameField {
				dataItem.uid: root.genericInput.uid + "/Settings/CustomName"
			}

			ListIOChannelGroupField {
				dataItem.uid: root.genericInput.uid + "/Settings/Group"
			}

			ListIOChannelTypeRadioButtonGroup {
				ioChannel: root.genericInput
			}

			ListIOChannelShowRadioButtonGroup {
				dataItem.uid: root.genericInput.uid + "/Settings/ShowUIInput"
			}

			ListRadioButtonGroup {
				//% "Invert"
				text: qsTrId("page_generic_input_invert")
				writeAccessLevel: VenusOS.User_AccessType_User
				preferredVisible: dataItem.valid
				showAccessLevel: productId.isAurelia ? VenusOS.User_AccessType_Installer : VenusOS.User_AccessType_User
				dataItem.uid: root.genericInput.uid + "/Settings/Invert"
				optionModel: [
					//% "Normal"
					{ display: qsTrId("iochannel_invert_normal"), value: 0 },
					//% "Inverted"
					{ display: qsTrId("iochannel_invert_inverted"), value: 1 },
				]
			}

			ListRadioButtonGroup {
				//% "Input mode"
				text: qsTrId("iochannel_input_mode")
				writeAccessLevel: VenusOS.User_AccessType_User
				preferredVisible: dataItem.valid
				showAccessLevel: productId.isAurelia ? VenusOS.User_AccessType_Installer : VenusOS.User_AccessType_User
				dataItem.uid: root.genericInput.uid + "/Settings/DigitalInputMode"
				optionModel: [
					{ display: CommonWords.disabled, value: 0 },
					//% "Sensor | Outputs → Follow state"
					{ display: qsTrId("iochannel_digital_input_mode_follow_state"), value: 1 },
					//% "Switch | Outputs → Follow position"
					{ display: qsTrId("iochannel_digital_input_mode_follow_position"), value: 2 },
					//% "Switch | Outputs → Toggle on change"
					{ display: qsTrId("iochannel_digital_input_mode_toggle_on_change"), value: 3 },
					//% "Button | Outputs → Toggle on press"
					{ display: qsTrId("iochannel_digital_input_mode_toggle_on_press"), value: 4 },
					//% "Button | Outputs → Toggle and dim"
					{ display: qsTrId("iochannel_digital_input_mode_toggle_and_dim"), value: 5 },
				]
			}
		}
	}
}
