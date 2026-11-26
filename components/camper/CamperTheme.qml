/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick

/*
	The sizes and fonts of the RV illustration, from the "Custom Illustrations" design.

	Sizes are in design px, measured against the 333 px wide illustration. The scene draws each
	size at size * (drawn illustration width / designWidth). They are not gui-v2 Theme values, as
	the standalone app has no Theme.
*/
QtObject {
	// The illustration's width in the design.
	readonly property real designWidth: 333
	// The illustration SVGs' viewBox, 335 x 149.
	readonly property real illustrationAspectRatio: 335 / 149

	// Space around the illustration, in screen px, as the scale is derived from what is left.
	property real landscapeHorizontalMargin: 26
	property real landscapeVerticalMargin: 16
	property real portraitHorizontalMargin: 10
	property real portraitVerticalMargin: 12
	// Most of the space the illustration may fill, leaving room for the cards that overhang it.
	property real landscapeWidthFill: 0.92
	property real landscapeHeightFill: 0.94
	property real portraitWidthFill: 0.98
	property real portraitHeightFill: 0.88

	// The palette is its own object, so a host can replace it, e.g. for branding.
	property CamperColors colors: CamperColors {}

	// The host sets these to its own fonts, e.g. gui-v2 uses a different font per language.
	property string fontFamily: "Roboto"
	property string quantityFontFamily: "Roboto"

	// Card: two rows of 16, in a 3/6 padded box that hugs its content.
	property real cardHeight: 38
	property real cardRadius: 8
	property real cardBorderWidth: 1
	property real cardVerticalPadding: 3
	property real cardHorizontalPadding: 6
	property real cardRowHeight: 16
	property real cardIconSize: 16
	property real cardIconSpacing: 2
	property real cardInactiveContentOpacity: 0.7

	// The card shadow's blur (4) and opacity (30%) are in images/camper/camper_card_shadow.png.
	property real cardShadowOffsetY: 2

	// "Label XS"
	property real titleFontSize: 10
	property int titleFontWeight: Font.Bold
	property real titleLetterSpacing: 0.4

	// "Label S": card values and the battery percentage.
	property real valueFontSize: 12
	property int valueFontWeight: Font.Medium
	property real valueLetterSpacing: 0.2

	// Battery. The design gives its size and text only; the rest matches the drawn battery.
	property real batteryWidth: 50
	property real batteryHeight: 22
	property real batteryRadius: 4.4
	property real batteryBorderWidth: 1
	property real batteryNubWidth: 2
	property real batteryNubHeight: 7.3
	property real batteryIconSize: 10

	// Victron device (the hub).
	property real hubWidth: 27.89
	property real hubHeight: 25.56
	property real hubRadius: 6
	property real hubLogoSize: 15

	// Flow arrows. The design's values were not measured; these match the illustration's lines.
	property real arrowStrokeWidth: 1
	property real arrowHeadLength: 3
	property real arrowHeadWidth: 6
	property real arrowCornerRadius: 6
	property real arrowLongCornerRadius: 12
	property real arrowGap: 5.3

	// Where each node sits on the illustration: a card's centre x and top, the hub's and battery's
	// centre, in design px from the illustration's top left.
	property point solarCardPosition: Qt.point(59.9, -4.2)
	property point gridShoreCardPosition: Qt.point(33.3, 56.3)
	property point generatorCardPosition: Qt.point(99.9, 122.9)
	property point dcCardPosition: Qt.point(206.5, 3.0)
	property point acCardPosition: Qt.point(206.5, 103.7)
	property point alternatorCardPosition: Qt.point(299.7, 59.2)
	property point hubCenter: Qt.point(119.9, 88.9)
	property point batteryCenter: Qt.point(129.9, 41.5)

	// Where arrows meet a node off its centre, as a fraction of its size, to line up with the
	// illustration.
	property real solarArrowBatteryY: 0.56
	property real dcArrowCardY: 0.52
	property real alternatorArrowBatteryX: 0.8
}
