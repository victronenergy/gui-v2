/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick

Rectangle {
	id: root

	property bool active: true
	property bool alarm: false
	property int colorScheme: 0

	readonly property var _deviceColor: colorScheme === 0 ? [ "#ADB5BD", "#005FBE", "#DB3500"] : [ "#343A40", "#005FBE", "#FF5C28" ]

	radius: Math.max(4, Math.round(width * 0.22))
	color: alarm ? _deviceColor[2]
		: active ? _deviceColor[1]
		: _deviceColor[0]
	Image {
		anchors.centerIn: parent
		width: Math.max(16, Math.round(parent.width * 0.54))
		height: width
		source: "qrc:/images/camper/camper_victron.svg"
		fillMode: Image.PreserveAspectFit
		smooth: true
	}
}