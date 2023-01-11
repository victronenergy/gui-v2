/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Rectangle {
	id: root

	property bool checked
	property bool down

	implicitWidth: Theme.geometry.radioButton.indicator.width
	implicitHeight: implicitWidth
	radius: implicitWidth/2
	border.width: Theme.geometry.radioButton.border.width
	border.color: parent.enabled
				  ? ((parent.down || parent.checked) ? Theme.color.radioButton.indicator.on : Theme.color.radioButton.indicator.off)
				  : Theme.color.radioButton.indicator.disabled
	color: 'transparent'

	Rectangle {
		anchors.centerIn: parent
		implicitWidth: Theme.geometry.radioButton.indicator.dot.width
		implicitHeight: implicitWidth
		radius: implicitWidth/2
		color: parent.enabled ? Theme.color.radioButton.indicator.on : Theme.color.radioButton.indicator.disabled
		visible: parent.down || parent.checked
	}
}
