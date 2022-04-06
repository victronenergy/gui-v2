/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

Rectangle {
	id: root

	property real value: 0.0

	property color backgroundColor
	property color foregroundColor

	gradient: Gradient { // Take care if modifying this; be sure to test the edge cases of value == 0.0 and value == 1.0
		GradientStop { position: 0.0; color: root.value >= 1.0 ? root.foregroundColor : root.backgroundColor }
		GradientStop { position: Math.min(0.999999, (1.0 - root.value)); color: root.value >= 1.0 ? root.foregroundColor : root.backgroundColor }
		GradientStop { position: Math.min(1.0, (1.0 - root.value) + 0.001); color: root.value <= 0.0 ? root.backgroundColor : root.foregroundColor }
		GradientStop { position: 1.0; color: root.value <= 0.0 ? root.backgroundColor : root.foregroundColor }
	}

	Behavior on value {
		NumberAnimation {}
	}
}
