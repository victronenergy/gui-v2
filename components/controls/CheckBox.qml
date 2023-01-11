/*
** Copyright (C) 2022 Victron Energy B.V.
*
* A check box with the same styling as RadioButton
*/

import QtQuick
import QtQuick.Controls as C
import Victron.VenusOS

C.CheckBox {
	id: root

	property alias label: label

	implicitWidth: Math.max(
		implicitBackgroundWidth + leftInset + rightInset,
		implicitContentWidth + leftPadding + rightPadding,
		implicitIndicatorWidth + leftPadding + rightPadding)
	implicitHeight: Math.max(
		implicitBackgroundHeight + topInset + bottomInset,
		implicitContentHeight + topPadding + bottomPadding,
		implicitIndicatorHeight + topPadding + bottomPadding)
	indicator: RadioButtonIndicator {
		anchors.verticalCenter: root.verticalCenter
		down: root.down
		checked: root.checked
	}
	contentItem: RadioButtonLabel {
		id: label
	}
}
