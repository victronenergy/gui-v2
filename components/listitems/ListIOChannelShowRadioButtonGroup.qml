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
	readonly property bool watchCapability: root._capabilities.valid && (root._capabilities.value & VenusOS.IOChannel_Capability_Watch)

	readonly property VeQuickItem _capabilities: VeQuickItem {
		uid: root.capabilitiesUid
	}

	function _generateSecondaryText () {
		if (showUiControl.value == VenusOS.IOChannel_ShowUI_Off) {
			return CommonWords.off
		}
		if (showUiControl.value == VenusOS.IOChannel_ShowUI_Always) {
			return qsTrId("iochannel_showui_always")
		}
		if (showUiControl.value == VenusOS.IOChannel_ShowUI_Local) {
			return qsTrId("iochannel_showui_local")
		}
		if (showUiControl.value == VenusOS.IOChannel_ShowUI_Remote) {
			return qsTrId("iochannel_showui_remote")
		}

		return (showUiControl.value & VenusOS.IOChannel_ShowUI_Local ? qsTrId("iochannel_showui_custom_local") + " " : "" ) +
				(showUiControl.value & VenusOS.IOChannel_ShowUI_Remote ? qsTrId("iochannel_showui_custom_vrm") + " " : "" ) +
				(showUiControl.value & VenusOS.IOChannel_ShowUI_Watch ? qsTrId("iochannel_showui_custom_watch") : "" )
	}

	//: Whether UI controls should be shown for this input/output
	//% "Show controls"
	text: qsTrId("iochannel_showui_controls")
	secondaryText: _generateSecondaryText()
	writeAccessLevel: VenusOS.User_AccessType_User

	onClicked: Global.pageManager.pushPage(showUiControlComponent, { title: text })

	VeQuickItem {
		id: showUiControl
		uid: root.showUiUid
	}

	ButtonGroup {
		id: stateRadioButtonGroup
	}

	Component {
		id: showUiControlComponent

		Page {
			GradientListView {
				model: VisibleItemModel {

					ListRadioButton {
						text: CommonWords.off
						checked: showUiControl.value == VenusOS.IOChannel_ShowUI_Off
						ButtonGroup.group: stateRadioButtonGroup
						onClicked: {
							showUiControl.setValue(VenusOS.IOChannel_ShowUI_Off)
							Global.pageManager.popPage()
						}
					}
					ListRadioButton {
						//% "Always"
						text: qsTrId("iochannel_showui_always")
						checked: showUiControl.value == VenusOS.IOChannel_ShowUI_Always
						ButtonGroup.group: stateRadioButtonGroup
						onClicked: {
							showUiControl.setValue(VenusOS.IOChannel_ShowUI_Always)
							Global.pageManager.popPage()
						}
					}
					ListRadioButton {
						//% "Only local"
						text: qsTrId("iochannel_showui_local")
						checked: showUiControl.value == VenusOS.IOChannel_ShowUI_Local
						ButtonGroup.group: stateRadioButtonGroup
						onClicked: {
							showUiControl.setValue(VenusOS.IOChannel_ShowUI_Local)
							Global.pageManager.popPage()
						}
						preferredVisible: !watchCapability
					}
					ListRadioButton {
						//% "Only on VRM"
						text: qsTrId("iochannel_showui_vrm")
						checked: showUiControl.value == VenusOS.IOChannel_ShowUI_Remote
						ButtonGroup.group: stateRadioButtonGroup
						onClicked: {
							showUiControl.setValue(VenusOS.IOChannel_ShowUI_Remote)
							Global.pageManager.popPage()
						}
						preferredVisible: !watchCapability
					}
					ListNavigation {
						id: customList

						function _generateCustomSecondaryText () {
							if (showUiControl.value == VenusOS.IOChannel_ShowUI_Off
									|| showUiControl.value == VenusOS.IOChannel_ShowUI_Always) {
								return "" // Do not display more information than is required
							}

							return (showUiControl.value & VenusOS.IOChannel_ShowUI_Local ? qsTrId("iochannel_showui_custom_local") + " " : "" ) +
									(showUiControl.value & VenusOS.IOChannel_ShowUI_Remote ? qsTrId("iochannel_showui_custom_vrm") + " " : "" ) +
									(showUiControl.value & VenusOS.IOChannel_ShowUI_Watch ? qsTrId("iochannel_showui_custom_watch") : "" )
						}

						//: Whether UI controls should be shown for this input/output
						//% "Custom"
						text: qsTrId("iochannel_showui_controls_custom")
						secondaryText: _generateCustomSecondaryText()
						writeAccessLevel: VenusOS.User_AccessType_User

						onClicked: Global.pageManager.pushPage(showCustomUiControlComponent, { title: text })
						preferredVisible: watchCapability

						Component {
							id: showCustomUiControlComponent

							Page {
								GradientListView {
									model: VisibleItemModel {
										ListRadioButton {
											//% "Local"
											text: qsTrId("iochannel_showui_custom_local")
											checked: showUiControl.value & VenusOS.IOChannel_ShowUI_Local
											onClicked: showUiControl.setValue(showUiControl.value ^ VenusOS.IOChannel_ShowUI_Local)
										}
										ListRadioButton {
											//% "VRM"
											text: qsTrId("iochannel_showui_custom_vrm")
											checked: showUiControl.value & VenusOS.IOChannel_ShowUI_Remote
											onClicked: showUiControl.setValue(showUiControl.value ^ VenusOS.IOChannel_ShowUI_Remote)
										}
										ListRadioButton {
											//% "Watch"
											text: qsTrId("iochannel_showui_custom_watch")
											checked: showUiControl.value & VenusOS.IOChannel_ShowUI_Watch
											onClicked: showUiControl.setValue(showUiControl.value ^ VenusOS.IOChannel_ShowUI_Watch)
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
}