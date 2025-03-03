/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

/* ListItem Visual and Behavioural Rules
   -------------------------------------

	ListItem provides its own clicked() signal which is emitted by its own ListPressArea.
	All ListItems and its derivatives are therefore potentially clickable by default and
	must follow these rules consistently:

	- ListItems shall NEVER have enabled: false; it should always be true.
	- ListItems may set interactive: true (false by default)
	- ListItems should set showAccessLevel and/or writeAccessLevel where necessary
	- ListItems should always activate the default action for the child item when clicked() emitted

	- The internal ListPressArea shall always be clickable, however whether it goes on to
	  emit ListItem's own clicked() signal depends on the following logic:

	if interactive: true

		if the system is readonly:

			Show a toast saying system is readonly
			No clicked() signal is emitted on the ListItem
			The ListPressArea press effect DOES occur

		else if userHasWriteAccess is false:

			Show toast saying you can’t edit it
			Mo clicked() signal is emitted on the ListItem
			The ListPressArea press effect DOES occur

		else
			emit ListItem clicked()
			The ListPressArea press effect DOES occur

	else // interactive: false

		No clicked() signal is emitted on the ListItem
		The  ListPressArea press effect DOES NOT occur
*/

BaseListItem {
	id: root

	property alias text: primaryLabel.text
	property alias content: content
	property alias bottomContent: bottomContent
	property alias bottomContentChildren: bottomContent.children
	property string caption
	readonly property alias down: pressArea.containsPress
	property bool flat: false
	property int leftPadding: flat ? Theme.geometry_listItem_flat_content_horizontalMargin : Theme.geometry_listItem_content_horizontalMargin
	property int rightPadding: flat ? Theme.geometry_listItem_flat_content_horizontalMargin : Theme.geometry_listItem_content_horizontalMargin

	property int showAccessLevel: VenusOS.User_AccessType_User
	property int writeAccessLevel: VenusOS.User_AccessType_Installer
	readonly property bool userHasWriteAccess: Global.systemSettings.canAccess(writeAccessLevel)
	readonly property bool userHasReadAccess: Global.systemSettings.canAccess(showAccessLevel)

	readonly property alias primaryLabel: primaryLabel
	readonly property int availableWidth: width - leftPadding - rightPadding - content.spacing
	property int maximumContentWidth: availableWidth * 0.7
	property int bottomContentSizeMode: content.height > primaryLabel.height
				? VenusOS.ListItem_BottomContentSizeMode_Compact
				: VenusOS.ListItem_BottomContentSizeMode_Stretch

	property bool interactive: false
	readonly property bool clickable: enabled && interactive && userHasWriteAccess

	signal clicked()

	function activate() {
		if (root.interactive) {
			// Issue #1964: userHasWriteAccess is ignored for ListNavigation
			if (root instanceof ListNavigation || root.userHasWriteAccess) {
				root.clicked()
			} else {
				pressArea.toast?.close(true) // close immediately
				//% "Setting locked for access level"
				pressArea.toast = Global.notificationLayer.showToastNotification(VenusOS.Notification_Info, qsTrId("listItem_no_access"))
			}
		}
	}

	effectiveVisible: preferredVisible && userHasReadAccess
	visible: effectiveVisible
	implicitHeight: effectiveVisible ? contentLayout.implicitHeight : 0
	implicitWidth: parent ? parent.width : 0
	background.visible: !root.flat

	Keys.onSpacePressed: activate()
	Keys.enabled: Global.keyNavigationEnabled

	// Show thin colored indicator on left side if settings is only visible to super/service users
	Rectangle {
		visible: root.showAccessLevel >= VenusOS.User_AccessType_SuperUser
		width: Theme.geometry_listItem_radius * 2
		height: parent.height
		color: Theme.color_listItem_highAccessLevel
		radius: Theme.geometry_listItem_radius

		Rectangle {
			x: Theme.geometry_listItem_radius
			width: Theme.geometry_listItem_radius
			height: parent.height
			color: root.background.color
		}
	}

	ListPressArea {
		id: pressArea

		property ToastNotification toast: null

		anchors.fill: parent
		radius: root.background.radius
		effectEnabled: root.interactive
		onClicked: root.activate()

		Connections {
			target: pressArea.toast
			function onDismissed() {
				pressArea.toast = null
			}
		}
	}

	GridLayout {
		id: contentLayout

		width: parent.width
		anchors.verticalCenter: parent.verticalCenter
		columns: 2
		columnSpacing: Theme.geometry_listItem_content_spacing
		rowSpacing: 0

		Label {
			id: primaryLabel

			Layout.topMargin: Theme.geometry_listItem_content_verticalMargin
			Layout.leftMargin: root.leftPadding
			Layout.fillWidth: true
			Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
			font.pixelSize: flat ? Theme.font_size_body1 : Theme.font_size_body2
			wrapMode: Text.Wrap
			width: root.availableWidth - content.width - Theme.geometry_listItem_content_spacing
		}

		Row {
			id: content

			// The topMargin ensures the content is vertically aligned with primaryLabel when the
			// content height is small and there is no bottom content.
			Layout.topMargin: height <= primaryLabel.height ? Theme.geometry_listItem_content_verticalMargin : 0
			Layout.rightMargin: root.rightPadding
			Layout.maximumWidth: root.maximumContentWidth
			Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
			Layout.rowSpan: root.bottomContentSizeMode === VenusOS.ListItem_BottomContentSizeMode_Stretch ? 1 : 2
			spacing: Theme.geometry_listItem_content_spacing
		}

		Column {
			id: bottomContent

			Layout.fillWidth: true
			Layout.columnSpan: root.bottomContentSizeMode === VenusOS.ListItem_BottomContentSizeMode_Stretch ? 2 : 1
			Layout.topMargin: height > 0 ? Theme.geometry_listItem_content_verticalMargin / 2 : 0
			Layout.bottomMargin: Theme.geometry_listItem_content_verticalMargin

			Label {
				width: parent.width
				visible: text !== ""
				topPadding: 0
				bottomPadding: 0
				leftPadding: Theme.geometry_listItem_content_horizontalMargin
				rightPadding: Theme.geometry_listItem_content_horizontalMargin
				wrapMode: Text.Wrap
				color: Theme.color_font_secondary
				text: root.caption
			}
		}
	}
}
