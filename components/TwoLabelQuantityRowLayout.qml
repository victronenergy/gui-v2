/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

/*
	Displays primary and caption text, with a QuantityRow..

	The primary text width is reduced (and elided) as much as possible to make it fit on the same
	line as the QuantityRow. After a certain point when the primary text cannot be reduced any
	further, the QuantityRow is placed on a new line instead.
*/
Flow {
	id: root

	required property string primaryText
	required property QuantityObjectModel model
	property alias captionText: captionLabel.text

	property alias primaryLabel: primaryLabel
	property alias captionLabel: captionLabel
	property alias tableMode: quantityRow.tableMode
	property bool forceColumnLayout

	readonly property bool _useColumnLayout: forceColumnLayout
			|| (Math.min(primaryLabel.implicitWidth, Theme.geometry_listItem_primaryText_minimumWidth) + quantityRow.implicitWidth > width)

	Label {
		id: primaryLabel

		bottomPadding: root._useColumnLayout ? Theme.geometry_listItem_content_verticalSpacing : 0
		width: root._useColumnLayout ? parent.width : parent.width - quantityRow.width
		text: root.primaryText
		elide: Text.ElideRight
	}

	QuantityRow {
		id: quantityRow
		model: root.model
	}

	CaptionLabel {
		id: captionLabel

		topPadding: Theme.geometry_listItem_content_verticalSpacing
		width: parent.width
		visible: text.length > 0
	}
}
