/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListItem {
	id: root

	readonly property alias button: button
	property alias secondaryText: button.text

	// Override ListItem right padding to give Switch a larger touch area for users
	rightPadding: 0

	content.children: [
		ListItemButton {
			id: button

			leftInset: Theme.geometry_listItem_content_spacing
			rightInset: root.flat ? Theme.geometry_listItem_flat_content_horizontalMargin : Theme.geometry_listItem_content_horizontalMargin

			down: pressed || checked || root.down
			width: Math.min(implicitWidth, root.maximumContentWidth)
			enabled: root.enabled && root.userHasWriteAccess
			focusPolicy: Qt.NoFocus

			onClicked: root.clicked()
		}
	]
}
