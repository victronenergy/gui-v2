/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

/*
	Displays primary and caption labels, and a secondary item.

	In landscape, the primary text and caption are on the left, and the secondary item vertically
	stretched on the right:

	| Primary label   | Secondary |
	| Caption         |   item   |

	In portrait, if the primary text and secondary item fit together on a single line, the caption
	is stretched below:

	| Primary label   | Secondary item |
	| Caption                          |

	Otherwise, a column layout is used instead:

	| Primary label   |
	| Secondary label |
	| Caption         |
*/
GridLayout {
	id: root

	required property string primaryText
	required property Component secondaryComponent
	property alias captionText: captionLabel.text
	readonly property bool isMultiLine: captionLabel.text.length > 0 || primaryLabel.lineCount > 1 || _useColumnLayout

	property alias primaryLabel: primaryLabel
	property alias captionLabel: captionLabel

	readonly property bool _useStretchedCaptionLayout: Theme.screenSize === Theme.Portrait && !_needsWrap
	readonly property bool _useColumnLayout: Theme.screenSize === Theme.Portrait && _needsWrap
	readonly property bool _needsWrap: Math.ceil(primaryLabel.implicitWidth)
			+ Math.ceil(secondaryItemLoader.implicitWidth) >= width - Theme.geometry_listItem_content_spacing

	columns: _useColumnLayout ? 1 : 2
	columnSpacing: Theme.geometry_listItem_content_spacing
	rowSpacing: 0

	Label {
		id: primaryLabel

		text: root.primaryText
		wrapMode: Text.WordWrap
		verticalAlignment: Text.AlignVCenter

		Layout.fillWidth: true
		Layout.fillHeight: true
		Layout.preferredWidth: root._useColumnLayout ? -1 : Math.min(implicitWidth, parent.width / 2)
	}

	Loader {
		id: secondaryItemLoader

		sourceComponent: root.secondaryComponent

		Layout.alignment: root._useColumnLayout ? Qt.AlignLeft : Qt.AlignRight
		Layout.rowSpan: captionLabel.text.length > 0 && (!root._useColumnLayout && !root._useStretchedCaptionLayout) ? 2 : 1
		Layout.maximumWidth: root._useColumnLayout ? root.width : root.width / 2
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
