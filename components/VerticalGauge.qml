/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

Rectangle {
	id: root

	property real value: 0.0
	property real _value: isNaN(value) || value < 0 ? 0 : Math.min(1.0, value)

	property color backgroundColor
	property color foregroundColor
	property alias animationEnabled: animation.enabled

	gradient: Gradient { // Take care if modifying this; be sure to test the edge cases of _value == 0.0 and _value == 1.0
		GradientStop { position: 0.0; color: root._value >= 1.0 ? root.foregroundColor : root.backgroundColor }
		GradientStop { position: Math.min(0.999999, (1.0 - root._value)); color: root._value >= 1.0 ? root.foregroundColor : root.backgroundColor }
		GradientStop { position: Math.min(1.0, (1.0 - root._value) + 0.001); color: root._value <= 0.0 ? root.backgroundColor : root.foregroundColor }
		GradientStop { position: 1.0; color: root._value <= 0.0 ? root.backgroundColor : root.foregroundColor }
	}

	Behavior on _value {
		id: animation

		NumberAnimation {}
	}
}
