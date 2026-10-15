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

	If the primary text does not fit on a single line, it wraps at the edge of the secondary item
	(at no less than 60% of the available space) and the secondary item is vertically centered
	to the primary text:

	| Primary label that is quite |                |
	| a bit longer than you would | Secondary item |
	| usually expect.             |                |
	| Caption                                      |

	If the secondary item width is > 40% of the available space such that it would force the
	primary text to wrap, then a column layout is used instead:

	| Primary label that may be |
	| short or long             |
	| Longer secondary item     |
	| Caption                   |

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

	readonly property bool _mainTextWouldWrap: Math.ceil(primaryLabel.implicitWidth)
			+ Math.ceil(secondaryItemLoader.implicitWidth) >= (width - Theme.geometry_listItem_content_spacing)
	readonly property bool _useColumnLayout: secondaryItemLoader.status === Loader.Null
			|| (_mainTextWouldWrap && Math.ceil(secondaryItemLoader.implicitWidth) > _maxSecondaryItemWidth)
	readonly property real _maxPrimaryLabelWidth: (width * Theme.geometry_listItem_primary_maximumWidthProportion) - columnSpacing
	readonly property real _maxSecondaryItemWidth: (width * Theme.geometry_listItem_secondary_maximumWidthProportion) - columnSpacing

	columns: 2
	columnSpacing: Theme.geometry_listItem_content_spacing
	rowSpacing: Theme.geometry_listItem_content_verticalSpacing

	Label {
		id: primaryLabel

		text: root.primaryText
		wrapMode: Text.WordWrap
		verticalAlignment: Text.AlignVCenter
		color: root.enabled ? Theme.color_font_primary : Theme.color_font_disabled

		Layout.fillHeight: true
		Layout.fillWidth: true
		Layout.columnSpan: root._useColumnLayout ? 2 : 1
		Layout.maximumWidth: root._useColumnLayout ? root.width
				: Math.max(root._maxPrimaryLabelWidth, root.width - root.columnSpacing - secondaryItemLoader.implicitWidth)
	}

	Loader {
		id: secondaryItemLoader

		sourceComponent: root.secondaryComponent
		visible: status !== Loader.Null

		Layout.alignment: Qt.AlignVCenter | (root._useColumnLayout ? Qt.AlignLeft : Qt.AlignRight)
		Layout.columnSpan: root._useColumnLayout ? 2 : 1
		Layout.maximumWidth: root._useColumnLayout ? root.width
				: Math.max(root._maxSecondaryItemWidth, root.width - root.columnSpacing - primaryLabel.implicitWidth)
	}

	CaptionLabel {
		id: captionLabel

		visible: text.length > 0

		Layout.fillWidth: true
		Layout.columnSpan: 2
	}
}
