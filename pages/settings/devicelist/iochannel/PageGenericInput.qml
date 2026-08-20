/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	required property string inputUid

	VeQuickItem {
		id: digitalInputModeItem
		uid: genericInput.uid + "/Settings/DigitalInputMode"
	}
	VeQuickItem {
		id: invertItem
		uid: genericInput.uid + "/Settings/Invert"
	}
	VeQuickItem {
		id: productId

		readonly property bool isAurelia: valid && (value === ProductInfo.ProductId_Dcdb_Aurelia)

		uid: genericInput.serviceUid + "/ProductId"
	}

	GenericInput {
		id: genericInput
		uid: root.inputUid
	}

	// For Aurelia products, some settings are not visible at the user-access level. For now, hard
	// code this configuration in gui-v2, but later on we will generalise this to configure the
	// setting visibility in the backend data values instead. See #2941.
	GradientListView {
		model: DelegateComponentModel {
			DelegateComponent {
				ListIOChannelNameField {
					dataItem.uid: genericInput.uid + "/Settings/CustomName"
				}
			}

			DelegateComponent {
				ListIOChannelGroupField {
					dataItem.uid: genericInput.uid + "/Settings/Group"
				}
			}

			DelegateComponent {
				ListIOChannelTypeRadioButtonGroup {
					ioChannel: genericInput
				}
			}

			DelegateComponent {
				ListIOChannelShowRadioButtonGroup {
					dataItem.uid: genericInput.uid + "/Settings/ShowUIInput"
				}
			}

			DelegateComponent {
				preferredVisible: invertItem.valid
				ListRadioButtonGroup {
					//% "Invert"
					text: qsTrId("page_generic_input_invert")
					writeAccessLevel: VenusOS.User_AccessType_User
					showAccessLevel: productId.isAurelia ? VenusOS.User_AccessType_Installer : VenusOS.User_AccessType_User
					dataItem.uid: genericInput.uid + "/Settings/Invert"
					optionModel: [
						//% "Normal"
						{ display: qsTrId("iochannel_invert_normal"), value: 0 },
						//% "Inverted"
						{ display: qsTrId("iochannel_invert_inverted"), value: 1 },
					]
				}
			}

			DelegateComponent {
				preferredVisible: digitalInputModeItem.valid
				ListRadioButtonGroup {
					//% "Input mode"
					text: qsTrId("iochannel_input_mode")
					writeAccessLevel: VenusOS.User_AccessType_User
					showAccessLevel: productId.isAurelia ? VenusOS.User_AccessType_Installer : VenusOS.User_AccessType_User
					dataItem.uid: genericInput.uid + "/Settings/DigitalInputMode"
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
}