/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

/*
	Displays a label next to a QuantityRow.

	The text width is reduced (and elided) as much as possible to make it fit on the same line as
	the QuantityRow. After a certain point when the text cannot be reduced any further, the
	QuantityRow is placed on a new line instead.
*/
GridLayout {
	id: root

	required property string text
	required property QuantityObjectModel model

	property alias label: label
	property alias tableMode: quantityRow.tableMode
	property bool forceColumnLayout

	readonly property bool _useColumnLayout: forceColumnLayout
			|| (Math.min(label.implicitWidth, Theme.geometry_listItem_primaryText_minimumWidth) + columnSpacing + quantityRow.implicitWidth > width)

	columns: _useColumnLayout ? 1 : 2
	columnSpacing: 0
	rowSpacing: Theme.geometry_listItem_content_verticalSpacing

	Label {
		id: label
		text: root.text
		elide: Text.ElideRight
		Layout.fillWidth: true
		Layout.preferredWidth: root._useColumnLayout ? root.width
				: root.width - root.columnSpacing - quantityRow.implicitWidth
	}

	QuantityRow {
		id: quantityRow
		model: root.model
	}
}
