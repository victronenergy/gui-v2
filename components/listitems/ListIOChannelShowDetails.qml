/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListNavigation {
	id: root
	required property string capabilitiesUid
	required property string showUiUid

	function calculatedShowUiControlValue(platformBit, switchCurrentlyOn) {
		let value = VenusOS.IOChannel_ShowUI_Off
		if (switchCurrentlyOn) {
			// the switch is currently on, and the user is toggling it to off.
			if (showUiControl.value & VenusOS.IOChannel_ShowUI_Always) {
				value = VenusOS.IOChannel_ShowUI_AllPlatforms
			} else {
				value = showUiControl.value
			}
			value &= ~platformBit
		} else {
			// the switch is currently off, and the user is toggling it to on.
			value = showUiControl.value | platformBit;

			// if all specific bits are set; set Always bit and unset platform bits.
			let localBit = value & VenusOS.IOChannel_ShowUI_Local
			let remoteBit = value & VenusOS.IOChannel_ShowUI_Remote
			let watchBit = value & VenusOS.IOChannel_ShowUI_Watch
			if (localBit && remoteBit && watchBit) {
				value = VenusOS.IOChannel_ShowUI_Always
			}
		}
		return value
	}

	//: Whether UI controls should be shown for this input/output
	//% "Show controls"
	text: qsTrId("iochannel_showui_controls")
	secondaryText: {
		if (showUiControl.value === VenusOS.IOChannel_ShowUI_Off) {
			return CommonWords.off
		}
		if (showUiControl.value === VenusOS.IOChannel_ShowUI_Always) {
			return CommonWords.always
		}

		var arr = []
		if (showUiControl.value & VenusOS.IOChannel_ShowUI_Local) {
			arr.push(CommonWords.local)
		}
		if (showUiControl.value & VenusOS.IOChannel_ShowUI_Remote) {
			arr.push(CommonWords.vrm)
		}
		if ((capabilities.value & VenusOS.IOChannel_Capability_Watch)
			&& (showUiControl.value & VenusOS.IOChannel_ShowUI_Watch)) {
			arr.push(CommonWords.watch_app)
		}

		return arr.length === 0 ? CommonWords.off : arr.join(', ')
	}
	writeAccessLevel: VenusOS.User_AccessType_User
	preferredVisible: showUiControl.valid

	onClicked: Global.pageManager.pushPage(showUiControlComponent, { title: text })

	VeQuickItem {
		id: showUiControl
		uid: root.showUiUid
	}

	VeQuickItem {
		id: capabilities
		uid: root.capabilitiesUid
	}

	Component {
		id: showUiControlComponent

		Page {
			GradientListView {
				model: VisibleItemModel {

					ListSwitch {
						text: CommonWords.local
						//% "GX screen and local LAN"
						caption: qsTrId("iochannel_showui_custom_local_caption")
						checked: showUiControl.value & VenusOS.IOChannel_ShowUI_Always
								|| showUiControl.value & VenusOS.IOChannel_ShowUI_Local
						writeAccessLevel: root.writeAccessLevel
						onClicked: showUiControl.setValue(calculatedShowUiControlValue(VenusOS.IOChannel_ShowUI_Local, checked))
					}
					ListSwitch {
						text: CommonWords.vrm
						//% "VRM Portal"
						caption: qsTrId("iochannel_showui_custom_vrm_caption")
						checked: showUiControl.value & VenusOS.IOChannel_ShowUI_Always
								|| showUiControl.value & VenusOS.IOChannel_ShowUI_Remote
						writeAccessLevel: root.writeAccessLevel
						onClicked: showUiControl.setValue(calculatedShowUiControlValue(VenusOS.IOChannel_ShowUI_Remote, checked))
					}
					ListSwitch {
						text: CommonWords.watch_app
						//% "Victron watch app"
						caption: qsTrId("iochannel_showui_custom_watch_caption")
						checked: showUiControl.value & VenusOS.IOChannel_ShowUI_Always
								|| showUiControl.value & VenusOS.IOChannel_ShowUI_Watch
						writeAccessLevel: root.writeAccessLevel
						onClicked: showUiControl.setValue(calculatedShowUiControlValue(VenusOS.IOChannel_ShowUI_Watch, checked))
						preferredVisible: (capabilities.value & VenusOS.IOChannel_Capability_Watch)
					}
					PrimaryListLabel {
						//% "Choose where this switch can be operated. The switch keeps working when its control is hidden."
						text: qsTrId("iochannel_showui_note")
						font.pixelSize: Theme.font_size_caption
						color: Theme.color_listItem_secondaryText
						leftPadding: Theme.geometry_page_content_horizontalMargin
						preferredVisible: root.capabilitiesUid !== ""
					}
				}
			}
		}
	}
}

