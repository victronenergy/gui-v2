/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	An abstract type for setting-type list items, with title text and access control parameters.

	When extending this type:

	- Implement your own contentItem that displays the specified text and caption, along with other
	  items relevant to your custom type. The text should respect the font and textFormat, as
	  provided by ListItem.
	- If you need to override the background, you can use ListSettingBackground to ensure the
	  backgroundIndicatorColor is still shown on the left edge as expected.

	----------------------------------------
	Interaction visual and behavioural rules
	----------------------------------------

	A list item may contain clickable items (such as a button), or the whole item may be clickable
	(such as radio button delegates, or list items with sub-menu pages). If so, they must follow
	these rules:

	- Set interactive=true when part/all of the item is clickable.
	- Use 'clickable' to determine whether a child item should be enabled (such as a button).
	- Call checkWriteAccessLevel() when part/all of the item is clicked, before invoking a custom
	action, so that the action can be aborted (and a toast notification can be automatically shown
	by ListSetting) if the writeAccessLevel should prevent an action from taking place.

	NEVER set enabled=false; it should always be true, so that the key navigation highlight is shown
	when the user navigates over the item, even when it is not clickable.

	If the entire item is clickable, you can use ListPressArea in the background to highlight the
	whole item when clicked.
*/
ListItem {
	id: root

	property string text
	property string caption

	property int showAccessLevel: root.delegateComponent
			? root.delegateComponent.showAccessLevel
			: VenusOS.User_AccessType_User
	property int writeAccessLevel: VenusOS.User_AccessType_Installer
	readonly property bool userHasWriteAccess: Global.systemSettings.canAccess(writeAccessLevel)
	readonly property bool userHasReadAccess: Global.systemSettings.canAccess(showAccessLevel)

	// Set to true if the user can interact with the control with the mouse or key presses.
	// This is provided as a convenience for determining whether an item can be activated,
	// according to some condition.
	property bool interactive

	// True if the control is currently interactive and able to provide write-type interactions.
	// This is provided as a convenience for setting 'enabled' for child items.
	readonly property bool clickable: enabled && interactive && userHasWriteAccess

	property color indicatorColor: Qt.rgba(0,0,0,0) // fully transparent by default.

	// The color to show on the left edge of the background, to indicate the access level or
	// the custom indicatorColor.
	readonly property color backgroundIndicatorColor: showAccessLevel >= VenusOS.User_AccessType_SuperUser
			? Theme.color_listItem_highAccessLevel
			: indicatorColor

	property int toast
	property bool _toastConnected

	function checkWriteAccessLevel() {
		if (root.userHasWriteAccess) {
			return true
		} else {
			if (root.toast) {
				ToastModel.requestClose(root.toast)
			}
			//% "Setting locked for access level"
			root.toast = Global.showToastNotification(VenusOS.Notification_Info, qsTrId("listItem_no_access"))
			root._connectToastSignals()
			return false
		}
	}

	function _onToastGone(modelId) {
		if (root.toast === modelId) {
			root.toast = 0
			root._disconnectToastSignals()
		}
	}

	function _connectToastSignals() {
		if (root._toastConnected) {
			return
		}
		ToastModel.dismissRequested.connect(root._onToastGone)
		ToastModel.closeRequested.connect(root._onToastGone)
		ToastModel.removed.connect(root._onToastGone)
		root._toastConnected = true
	}

	function _disconnectToastSignals() {
		if (!root._toastConnected) {
			return
		}
		ToastModel.dismissRequested.disconnect(root._onToastGone)
		ToastModel.closeRequested.disconnect(root._onToastGone)
		ToastModel.removed.disconnect(root._onToastGone)
		root._toastConnected = false
	}

	// With a DelegateComponent, the model already applied access-level membership. Still honour
	// this item's preferredVisible. Without a DelegateComponent (SettingsColumn, headers, etc.),
	// keep the VisibleItemModel formula.
	effectiveVisible: root.delegateComponent
		? root.delegateComponent.effectiveVisible && preferredVisible
		: (preferredVisible && userHasReadAccess)

	background: ListSettingBackground {
		color: root.flat ? "transparent" : Theme.color_listItem_background
		indicatorColor: root.backgroundIndicatorColor
	}

	Component.onDestruction: root._disconnectToastSignals()
}
