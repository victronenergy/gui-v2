/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

/*
	Displays primary, secondary label and caption labels.

	In landscape, the primary and secondary text are displayed side-by-side, with the caption below:

	| Primary label   | Secondary label |
	| Caption                           |

	If stretchSecondaryText=true, the secondary text is stretched vertically instead:

	| Primary label   | Secondary |
	| Caption         |   label   |

	In portrait, if the secondary and caption text are both present, or if the primary and secondary
	text would not fit together on a single line, a column layout is used instead:

	| Primary label   |
	| Secondary label |
	| Caption         |

	Secondary and caption labels are created only when their text is non-empty. A later binding that
	fills the text creates the label then (first use of that string).
*/
GridLayout {
	id: root

	required property string primaryText
	property string secondaryText
	property string captionText
	property bool stretchSecondaryText
	property real topPadding
	property real bottomPadding

	property alias primaryLabel: primaryLabel
	property Item secondaryLabel
	property Item captionLabel
	property color secondaryLabelColor: Theme.color_listItem_secondaryText
	property int secondaryLabelElide: Text.ElideNone
	property int secondaryLabelMaximumLineCount: Global.int32Max

	readonly property bool _useColumnLayout: Theme.screenSize === Theme.Portrait
		&& ((secondaryText.length > 0 && captionText.length > 0) || _mainTextWouldWrap)
	readonly property bool _mainTextWouldWrap: Theme.screenSize === Theme.Portrait
			&& (Math.ceil(primaryLabel.implicitWidth)
				+ Math.ceil(secondaryLabel ? secondaryLabel.implicitWidth : 0)
				>= (width - Theme.geometry_listItem_content_spacing))

	function _syncSecondaryLabel() {
		if (root.secondaryText.length > 0) {
			if (!root.secondaryLabel) {
				root.secondaryLabel = secondaryLabelComponent.createObject(root)
			}
		} else if (root.secondaryLabel) {
			root.secondaryLabel.destroy()
			root.secondaryLabel = null
		}
	}

	function _syncCaptionLabel() {
		if (root.captionText.length > 0) {
			if (!root.captionLabel) {
				root.captionLabel = captionLabelComponent.createObject(root)
			}
		} else if (root.captionLabel) {
			root.captionLabel.destroy()
			root.captionLabel = null
		}
	}

	onSecondaryTextChanged: root._syncSecondaryLabel()
	onCaptionTextChanged: root._syncCaptionLabel()
	Component.onCompleted: {
		root._syncSecondaryLabel()
		root._syncCaptionLabel()
	}

	columns: _useColumnLayout || secondaryText.length === 0 ? 1 : 2
	columnSpacing: Theme.geometry_listItem_content_spacing
	rowSpacing: 0

	Label {
		id: primaryLabel

		topPadding: root.topPadding
		bottomPadding: root.secondaryText.length === 0 && root.captionText.length === 0 ? root.bottomPadding : 0
		text: root.primaryText
		wrapMode: Text.WordWrap

		Layout.fillWidth: true
		Layout.row: 0
		Layout.column: 0
	}

	Component {
		id: secondaryLabelComponent

		SecondaryListLabel {
			text: root.secondaryText
			color: root.secondaryLabelColor
			elide: root.secondaryLabelElide
			maximumLineCount: root.secondaryLabelMaximumLineCount
			topPadding: root._useColumnLayout ? 0 : root.topPadding
			bottomPadding: root.captionText.length === 0 ? root.bottomPadding : 0
			horizontalAlignment: root._useColumnLayout ? Text.AlignLeft : Text.AlignRight
			wrapMode: Text.WordWrap

			// In a non-column layout, keep the default secondary font size so that the secondary text
			// visually aligns with the font size of the adjacent primary text.
			// In a column layout where the secondary label is on a newline rather than adjacent to the
			// primary text, shrink the secondary text if necessary to fit it on a single line, in case
			// the text is a really long word (e.g. a hash key) that should not be wrapped halfway.
			fontSizeMode: root._useColumnLayout ? Text.HorizontalFit : Text.FixedSize
			minimumPixelSize: Theme.font_size_tiny

			Layout.alignment: (root._useColumnLayout ? Qt.AlignLeft : Qt.AlignRight)
					| (root.stretchSecondaryText ? Qt.AlignVCenter : Qt.AlignTop)
			Layout.rowSpan: root._useColumnLayout ? 1 : 2
			Layout.fillWidth: true
			Layout.row: root._useColumnLayout ? 1 : 0
			Layout.column: root._useColumnLayout ? 0 : 1
		}
	}

	Component {
		id: captionLabelComponent

		CaptionLabel {
			text: root.captionText
			topPadding: Theme.geometry_listItem_content_verticalSpacing
			bottomPadding: root.bottomPadding

			Layout.fillWidth: true
			Layout.columnSpan: root.columns === 1 || root.stretchSecondaryText ? 1 : 2
			Layout.row: root._useColumnLayout
					? (root.secondaryText.length > 0 ? 2 : 1)
					: 1
			Layout.column: 0
		}
	}
}
