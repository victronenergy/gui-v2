/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

/*
	Displays primary and secondary labels.

	The primary and secondary text are displayed side-by-side:

	| Primary label      | Secondary label |

	If the primary text does not fit on a single line, it wraps, and the secondary text is
	vertically centered to the primary text:

	| Primary label that |                 |
	| is quite a bit     | Secondary label |
	| longer than usual  |                 |

	If the secondary text width is > 40% of the available space (i.e. the layout width minus the
	spacing), then a column layout is used instead:

	| Primary label                        |
	| Longer secondary label               |
*/
GridLayout {
	id: root

	required property string primaryText
	property alias secondaryText: secondaryLabel.text
	property alias primaryLabel: primaryLabel
	property alias secondaryLabel: secondaryLabel

	readonly property real _maxSecondaryLabelWidth: (width * Theme.geometry_listItem_secondary_maximumWidthProportion)  - columnSpacing
	readonly property bool _mainTextWouldWrap: Math.ceil(primaryLabel.implicitWidth)
			+ Math.ceil(secondaryLabel.implicitWidth) >= (width - Theme.geometry_listItem_content_spacing)
	readonly property bool _useColumnLayout: secondaryText.length === 0
			|| (_mainTextWouldWrap && Math.ceil(secondaryLabel.implicitWidth) > _maxSecondaryLabelWidth)

	columns: 2
	columnSpacing: Theme.geometry_listItem_content_spacing
	rowSpacing: Theme.geometry_listItem_content_verticalSpacing

	Label {
		id: primaryLabel

		text: root.primaryText
		wrapMode: Text.WordWrap

		Layout.fillWidth: true
		Layout.columnSpan: root._useColumnLayout ? 2 : 1
	}

	SecondaryListLabel {
		id: secondaryLabel

		horizontalAlignment: root._useColumnLayout ? Text.AlignLeft : Text.AlignRight
		visible: text.length > 0
		wrapMode: Text.WordWrap
		fontSizeMode: Text.HorizontalFit
		minimumPixelSize: Theme.font_size_tiny

		Layout.alignment: Qt.AlignVCenter
		Layout.fillWidth: root._useColumnLayout
		Layout.columnSpan: root._useColumnLayout ? 2 : 1
	}
}
