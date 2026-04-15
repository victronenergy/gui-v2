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
	required property string secondaryText
	required property string captionText

	required property font primaryFont
	required property int primaryTextFormat
	property alias secondaryTextColor: secondaryLabel.color
	property bool stretchSecondaryText
	property real topPadding
	property real bottomPadding

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
		textFormat: root.primaryTextFormat
		font: root.primaryFont
		wrapMode: Text.Wrap

		Layout.fillWidth: true
		Layout.preferredWidth: root._useColumnLayout ? -1 : Math.min(implicitWidth, parent.width / 2)
	}

	SecondaryListLabel {
		id: secondaryLabel

		topPadding: root._useColumnLayout ? 0 : root.topPadding
		bottomPadding: root.captionText.length === 0 ? root.bottomPadding : 0
		horizontalAlignment: root._useColumnLayout ? Text.AlignLeft : Text.AlignRight
		visible: text.length > 0
		text: root.secondaryText
		wrapMode: Text.Wrap

		Layout.fillWidth: true
		Layout.alignment: (root._useColumnLayout ? Qt.AlignLeft : Qt.AlignRight)
				| (root.stretchSecondaryText ? Qt.AlignVCenter : Qt.AlignTop)
		Layout.rowSpan: root._useColumnLayout ? 1 : 2
		Layout.preferredWidth: text.length === 0 ? 0
				: root._useColumnLayout ? -1
				: Math.min(implicitWidth, parent.width / 2)
	}

	CaptionLabel {
		topPadding: Theme.geometry_listItem_content_verticalSpacing
		bottomPadding: root.bottomPadding
		text: root.captionText
		visible: text.length > 0

		Layout.fillWidth: true
		Layout.columnSpan: root.columns === 1 || root.stretchSecondaryText ? 1 : 2
	}
}
