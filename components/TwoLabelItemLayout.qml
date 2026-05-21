/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

/*
	Displays primary and caption labels, and a secondary item.

	Normally the primary text and caption are on the left, and the secondary item on the right:

	| Primary label   | Secondary item |
	| Caption                          |

	If the primary text and secondary item do not fit on a single line, the primary text width is
	reduced (with wrapping) down to a minimum width. After a certain point when the primary text
	cannot be reduced any further, the item is placed on a new line instead:

	| Primary label   |
	| Secondary label |
	| Caption         |

	Note: the item width is limited to that of the layout, so that it does not spill over the edge.
*/
GridLayout {
	id: root

	required property string primaryText
	required property Component secondaryComponent
	property alias captionText: captionLabel.text
	readonly property bool isMultiLine: captionLabel.text.length > 0 || primaryLabel.lineCount > 1 || _useColumnLayout

	property alias primaryLabel: primaryLabel
	property alias captionLabel: captionLabel

	readonly property bool _useStretchedCaptionLayout: Theme.screenSize === Theme.Portrait && !_useColumnLayout
	readonly property bool _useColumnLayout: Theme.geometry_listItem_primaryText_minimumWidth + Theme.geometry_listItem_content_spacing + secondaryItemLoader.implicitWidth > width

	columns: _useColumnLayout ? 1 : 2
	columnSpacing: Theme.geometry_listItem_content_spacing
	rowSpacing: 0

	Label {
		id: primaryLabel

		text: root.primaryText
		wrapMode: Text.WordWrap
		verticalAlignment: Text.AlignVCenter

		Layout.fillHeight: true
		Layout.fillWidth: true
		Layout.minimumWidth: Theme.geometry_listItem_primaryText_minimumWidth
		Layout.maximumWidth: root.width
	}

	Loader {
		id: secondaryItemLoader

		sourceComponent: root.secondaryComponent

		Layout.alignment: root._useColumnLayout ? Qt.AlignLeft : Qt.AlignRight
		Layout.rowSpan: captionLabel.text.length > 0 && (!root._useColumnLayout && !root._useStretchedCaptionLayout) ? 2 : 1
		Layout.preferredWidth: root._useColumnLayout ? Math.min(implicitWidth, parent.width) : implicitWidth
		Layout.topMargin: root._useColumnLayout ? Theme.geometry_listItem_content_verticalSpacing : 0
	}

	CaptionLabel {
		id: captionLabel

		visible: text.length > 0

		Layout.fillWidth: true
		Layout.columnSpan: root._useStretchedCaptionLayout ? 2 : 1
		Layout.topMargin: Theme.geometry_listItem_content_verticalSpacing
	}
}
