/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick

Rectangle {
	id: root

	required property CamperTheme theme

	// Screen px per design px, from the scene.
	// On a real 5" GX or VRM screen it's roughly 2.
	// It also changes at runtime. In the WASM build inside VRM, resizing the
	// browser window resizes the scene, so the scale changes continuously.
	// designScale (illustration width ÷ 333) scales every overlay size with
	// the illustration, so the overlay stays in proportion at any window size;
	// and because it scales from the Figma frame, theme values can be copied
	// from Figma unchanged.
	required property real designScale
	property bool active: true
	property bool alarm: false

	implicitWidth: Math.round(theme.hubWidth * designScale)
	implicitHeight: Math.round(theme.hubHeight * designScale)
	radius: theme.hubRadius * designScale
	color: alarm ? theme.colors.deviceAlarm
		: active ? theme.colors.deviceActive
		: theme.colors.deviceInactive

	Image {
		anchors.centerIn: parent
		width: Math.round(root.theme.hubLogoSize * root.designScale)
		height: width
		sourceSize: Qt.size(width, height)
		source: "qrc:/images/camper/camper_device.svg"
		fillMode: Image.PreserveAspectFit
		smooth: true
	}
}
