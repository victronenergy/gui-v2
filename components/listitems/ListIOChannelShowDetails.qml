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

	//: Whether UI controls should be shown for this input/output
	//% "Show controls"
	text: qsTrId("iochannel_showui_controls")
	secondaryText: {
		if (!(showUiControl.value & VenusOS.IOChannel_ShowUI_Controller)) {
			return CommonWords.off
		}
		if (showUiControl.value === VenusOS.IOChannel_ShowUI_All) {
			return CommonWords.always
		}

		var arr = []
		if (showUiControl.value & VenusOS.IOChannel_ShowUI_Local) {
			arr.push(CommonWords.local)
		}
		if (showUiControl.value & VenusOS.IOChannel_ShowUI_Remote) {
			arr.push(CommonWords.vrm)
		}
		if (showUiControl.value & VenusOS.IOChannel_ShowUI_Watch) {
			arr.push(CommonWords.watch_app)
		}

		return arr.length === 0 ? CommonWords.none_option : arr.join(', ')
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
						text: root.text
						checked: showUiControl.value & VenusOS.IOChannel_ShowUI_Controller
						writeAccessLevel: root.writeAccessLevel
						onClicked: showUiControl.setValue(showUiControl.value ^ VenusOS.IOChannel_ShowUI_Controller)
					}
					SectionHeader {
						leftPadding: Theme.geometry_listItem_content_horizontalMargin
						//% "Show on"
						text: qsTrId("iochannel_showui_show_on")
						preferredVisible: showUiControl.value & VenusOS.IOChannel_ShowUI_Controller
					}
					ListSwitch {
						text: CommonWords.local
						//% "GX screen and local LAN"
						caption: qsTrId("iochannel_showui_custom_local_caption")
						checked: showUiControl.value & VenusOS.IOChannel_ShowUI_Local
						writeAccessLevel: root.writeAccessLevel
						onClicked: showUiControl.setValue(showUiControl.value ^ VenusOS.IOChannel_ShowUI_Local)
						preferredVisible: showUiControl.value & VenusOS.IOChannel_ShowUI_Controller
					}
					ListSwitch {
						text: CommonWords.vrm
						//% "VRM Portal"
						caption: qsTrId("iochannel_showui_custom_vrm_caption")
						checked: showUiControl.value & VenusOS.IOChannel_ShowUI_Remote
						writeAccessLevel: root.writeAccessLevel
						onClicked: showUiControl.setValue(showUiControl.value ^ VenusOS.IOChannel_ShowUI_Remote)
						preferredVisible: showUiControl.value & VenusOS.IOChannel_ShowUI_Controller
					}
					ListSwitch {
						text: CommonWords.watch_app
						//% "Victron watch app"
						caption: qsTrId("iochannel_showui_custom_watch_caption")
						checked: showUiControl.value & VenusOS.IOChannel_ShowUI_Watch
						writeAccessLevel: root.writeAccessLevel
						onClicked: showUiControl.setValue(showUiControl.value ^ VenusOS.IOChannel_ShowUI_Watch)
						preferredVisible: (showUiControl.value & VenusOS.IOChannel_ShowUI_Controller)
								&& capabilities.valid && (capabilities.value & VenusOS.IOChannel_Capability_Watch)
					}
					SecondaryListLabel {
						//% "Choose where this switch can be operated. The switch keeps working when its control is hidden."
						text: qsTrId("iochannel_showui_note")
						font.pixelSize: Theme.font_size_caption
						leftPadding: Theme.geometry_page_content_horizontalMargin
						visible: showUiControl.value & VenusOS.IOChannel_ShowUI_Controller
								&& root.capabilitiesUid !== ""
					}
				}
			}
		}
	}
}

