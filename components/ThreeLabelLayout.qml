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
*/
GridLayout {
	id: root

	required property string primaryText
	property alias secondaryText: secondaryLabel.text
	property alias captionText: captionLabel.text
	property bool stretchSecondaryText
	property real topPadding
	property real bottomPadding

	property alias primaryLabel: primaryLabel
	property alias secondaryLabel: secondaryLabel
	property alias captionLabel: captionLabel

	readonly property bool _useColumnLayout: Theme.screenSize === Theme.Portrait
		&& ((secondaryText.length > 0 && captionText.length > 0) || _mainTextWouldWrap)
	readonly property bool _mainTextWouldWrap: Math.ceil(primaryLabel.implicitWidth)
			+ Math.ceil(secondaryLabel.implicitWidth) >= (width - Theme.geometry_listItem_content_spacing)

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
	}

	SecondaryListLabel {
		id: secondaryLabel

		topPadding: root._useColumnLayout ? 0 : root.topPadding
		bottomPadding: root.captionText.length === 0 ? root.bottomPadding : 0
		horizontalAlignment: root._useColumnLayout ? Text.AlignLeft : Text.AlignRight
		visible: text.length > 0
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
	}

	CaptionLabel {
		id: captionLabel

		topPadding: Theme.geometry_listItem_content_verticalSpacing
		bottomPadding: root.bottomPadding
		visible: text.length > 0

		Layout.fillWidth: true
		Layout.columnSpan: root.columns === 1 || root.stretchSecondaryText ? 1 : 2
	}
}
