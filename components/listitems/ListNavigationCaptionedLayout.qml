/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

GridLayout {
	id: root

	property alias primaryText: mainLayout.primaryText
	readonly property alias primaryLabel: mainLayout.primaryLabel
	property alias secondaryText: mainLayout.secondaryText
	readonly property alias secondaryLabel: mainLayout.secondaryLabel
	property string caption
	property bool interactive: true

	columns: interactive ? 2 : 1
	columnSpacing: Theme.geometry_listItem_content_spacing
	rowSpacing: Theme.geometry_listItem_content_verticalSpacing

	ListItemLabelLayout {
		id: mainLayout
		Layout.fillWidth: true
	}

	ForwardIcon {
		visible: root.interactive
	}

	CaptionLabel {
		text: root.caption
		visible: root.caption.length > 0
		Layout.fillWidth: true
		Layout.columnSpan: parent.columns
	}
}