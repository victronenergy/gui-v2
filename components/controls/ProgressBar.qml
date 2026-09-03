/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Templates as T
import Victron.VenusOS

/*
	A progress bar control.
*/
T.ProgressBar {
	id: root

	implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
			implicitContentWidth + leftPadding + rightPadding)
	implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
			implicitContentHeight + topPadding + bottomPadding)

	// Draw our own rectangles instead of using BarGauge, so that the highlight's position can be
	// animated with an Animator on the render thread rather than a NumberAnimation on the main
	// thread, as this control is commonly used when background operations are being processed.
	// This also means the ends of the highlight are always rounded, unlike the BarGauge in the
	// Slider implementation, where the progress edge is straight until it approaches the end.
	background: Rectangle {
		x: root.leftPadding
		y: root.topPadding + (root.availableHeight / 2) - (height / 2)
		implicitWidth: Theme.geometry_control_width
		implicitHeight: Theme.geometry_progressBar_height
		width: root.availableWidth
		height: implicitHeight
		radius: Theme.geometry_progressBar_radius
		color: Theme.color_darkOk

		Rectangle {
			id: highlightRect

			width: root.indeterminate ? Theme.geometry_progressBar_highlight_width : root.availableWidth * root.visualPosition
			height: Theme.geometry_progressBar_height
			color: Theme.color_ok
			radius: Theme.geometry_progressBar_radius

			XAnimator on x {
				running: root.indeterminate
				loops: Animation.Infinite
				duration: Theme.animation_progressBar_duration
				from: 0
				to: root.availableWidth - highlightRect.width
				onStopped: highlightRect.x = 0
			}
		}
	}
}
