/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

/*
	Displays a label and a secondary item provided by a Loader.

	Normally the label is on the left, and the secondary item on the right:

	| Label        | Secondary item |

	If the label text does not fit on a single line, it wraps at the edge of the secondary item
	(at no less than 60% of the available space) and the secondary item is vertically centered
	to the label:

	| Label text that is quite a |                |
	| bit longer than you would  | Secondary item |
	| usually expect.            |                |

	If the secondary item width is > 40% of the available space such that it would force the
	primary text to wrap, then a column layout is used instead:

	| Primary text that may be |
	| short or long.           |
	| Longer secondary item    |

	Note: the item width is limited to that of the layout, so that it does not spill over the edge.
*/
GridLayout {
	id: root

	required property string text

	readonly property bool isMultiLine: label.lineCount > 1 || _useColumnLayout
	property alias label: label
	property alias loader: secondaryItemLoader

	readonly property bool _contentWouldWrap: Math.ceil(label.implicitWidth)
			+ Math.ceil(secondaryItemLoader.implicitWidth) >= (width - Theme.geometry_listItem_content_spacing)
	readonly property bool _useColumnLayout: secondaryItemLoader.status === Loader.Null
			|| (_contentWouldWrap && Math.ceil(secondaryItemLoader.implicitWidth) > _maxSecondaryItemWidth)
	readonly property real _maxPrimaryLabelWidth: (width * Theme.geometry_listItem_primary_maximumWidthProportion) - columnSpacing
	readonly property real _maxSecondaryItemWidth: (width * Theme.geometry_listItem_secondary_maximumWidthProportion) - columnSpacing

	columns: _useColumnLayout ? 1 : 2
	columnSpacing: Theme.geometry_listItem_content_spacing
	rowSpacing: Theme.geometry_listItem_content_verticalSpacing

	Label {
		id: label

		text: root.text
		wrapMode: Text.WordWrap
		verticalAlignment: Text.AlignVCenter

		Layout.fillHeight: true
		Layout.fillWidth: true
		Layout.maximumWidth: root._useColumnLayout ? root.width
				: Math.max(root._maxPrimaryLabelWidth, root.width - root.columnSpacing - secondaryItemLoader.implicitWidth)
	}

	Loader {
		id: secondaryItemLoader

		visible: status !== Loader.Null

		Layout.alignment: Qt.AlignVCenter | (root._useColumnLayout ? Qt.AlignLeft : Qt.AlignRight)
		Layout.maximumWidth: root._useColumnLayout ? root.width
				: Math.max(root._maxSecondaryItemWidth, root.width - root.columnSpacing - label.implicitWidth)
	}
}
