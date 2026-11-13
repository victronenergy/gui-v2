/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

/*
	A list item with the plugin's own content, for list items that the other Plugin* types do not
	cover.

	The list item provides the standard background, the key navigation highlight, and access-level
	handling. If text is set, the list item shows it, and puts the content on the right, at its own
	size. If the content does not fit beside the text, it goes below the text. If text is empty, the
	content fills the width of the list item. Declare the content directly inside the list item; the
	list item is as tall as its text and content.

	Key presses go to the list item when it has the key navigation focus, so handle them on the
	list item, for example with Keys.onSpacePressed. They run only while key navigation is active.
	Before changing a setting, call checkWriteAccessLevel().
*/
PluginListItem {
	id: root

	// The content of the list item.
	default property alias content: contentArea.data

	property string text

	// The lowest access level that can change the setting.
	property int writeAccessLevel: PluginAccessLevel.Installer
	// Set to true if the content can be clicked.
	property bool interactive
	// True if the content can be clicked now: interactive is true, and the user has
	// writeAccessLevel. Use it to enable buttons in the content.
	readonly property bool clickable: inner.clickable

	// Returns true if the user has writeAccessLevel. If not, shows a message saying so.
	function checkWriteAccessLevel() {
		return inner.checkWriteAccessLevel()
	}

	implicitWidth: inner.implicitWidth
	implicitHeight: inner.implicitHeight

	ListSetting {
		id: inner

		flat: root.flat
		text: root.text
		preferredVisible: root.preferredVisible
		showAccessLevel: root.showAccessLevel
		writeAccessLevel: root.writeAccessLevel
		interactive: root.interactive

		contentItem: Item {
			implicitWidth: Theme.geometry_listItem_width
			implicitHeight: contentLayout.implicitHeight

			// Laid out as in TwoLabelItemLayout, which cannot be used here because it takes a
			// Component for the item on the right, not items that are already declared.
			GridLayout {
				id: contentLayout

				readonly property bool hasText: root.text.length > 0
				readonly property bool useColumnLayout: hasText
						&& Theme.geometry_listItem_primaryText_minimumWidth + columnSpacing + contentArea.implicitWidth > width

				anchors.verticalCenter: parent.verticalCenter
				width: parent.width
				columns: hasText && !useColumnLayout ? 2 : 1
				columnSpacing: Theme.geometry_listItem_content_spacing
				rowSpacing: 0

				Label {
					text: root.text
					font: inner.font
					textFormat: inner.textFormat
					wrapMode: Text.WordWrap
					verticalAlignment: Text.AlignVCenter
					visible: contentLayout.hasText

					Layout.fillHeight: true
					Layout.fillWidth: true
					Layout.minimumWidth: Theme.geometry_listItem_primaryText_minimumWidth
					Layout.maximumWidth: contentLayout.width
				}

				Item {
					id: contentArea

					// Without text, the content fills the list item, so its own width is not used.
					implicitWidth: contentLayout.hasText ? childrenRect.width : 0
					implicitHeight: childrenRect.height

					Layout.alignment: contentLayout.useColumnLayout || !contentLayout.hasText ? Qt.AlignLeft : Qt.AlignRight
					Layout.fillWidth: !contentLayout.hasText
					Layout.preferredWidth: !contentLayout.hasText ? -1
						: contentLayout.useColumnLayout ? Math.min(implicitWidth, contentLayout.width)
						: implicitWidth
					Layout.topMargin: contentLayout.useColumnLayout ? Theme.geometry_listItem_content_verticalSpacing : 0
				}
			}
		}
	}
}
