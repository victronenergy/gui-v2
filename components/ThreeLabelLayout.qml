/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

/*
	Displays primary, secondary label and caption labels.

	The primary and secondary text are displayed side-by-side, with the caption below:

	| Primary label   | Secondary label |
	| Caption                           |

	If stretchSecondaryText=true, the secondary text is stretched vertically instead:

	| Primary label   | Secondary |
	| Caption         |   label   |
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

	columns: secondaryText.length === 0 ? 1 : 2
	columnSpacing: 0
	rowSpacing: 0

	Label {
		id: primaryLabel

		topPadding: root.topPadding
		bottomPadding: root.secondaryText.length === 0 && root.captionText.length === 0 ? root.bottomPadding : 0
		text: root.primaryText
		wrapMode: Text.Wrap

		Layout.fillWidth: true
		Layout.preferredWidth: Math.min(implicitWidth + Theme.geometry_listItem_content_spacing, parent.width / 2)
	}

	SecondaryListLabel {
		id: secondaryLabel

		topPadding: root.topPadding
		bottomPadding: root.captionText.length === 0 ? root.bottomPadding : 0
		horizontalAlignment: Text.AlignRight
		visible: text.length > 0
		wrapMode: Text.Wrap

		Layout.fillWidth: true
		Layout.alignment: root.stretchSecondaryText ? Qt.AlignVCenter : Qt.AlignTop
		Layout.leftMargin: text.length === 0 ? 0 : Theme.geometry_listItem_content_spacing
		Layout.rowSpan: root.stretchSecondaryText ? 2 : 1
		Layout.preferredWidth: text.length === 0 ? 0 : Math.min(implicitWidth + Theme.geometry_listItem_content_spacing, parent.width / 2)
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
