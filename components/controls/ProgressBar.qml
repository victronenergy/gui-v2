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

	readonly property real _indeterminateHighlightWidth: availableWidth / 3

	implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
			implicitContentWidth + leftPadding + rightPadding)
	implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
			implicitContentHeight + topPadding + bottomPadding)

	// Draw our own rectangles instead of using BarGauge, so that the highlight width and position
	// can be animated for indeterminate progress bars.
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

			width: root.indeterminate ? 0 : root.availableWidth * root.visualPosition
			height: Theme.geometry_progressBar_height
			color: Theme.color_ok
			radius: Theme.geometry_progressBar_radius

			// For indeterminate progress bars, produce a visual effect where the bar looks as
			// though it is entering and exiting the background area, by animating the highlight x
			// and width at the same time.
			SequentialAnimation {
				running: root.indeterminate && UiConfig.applicationVisible && !ScreenBlanker.blanked
				loops: Animation.Infinite
				onStopped: {
					highlightRect.x = 0
					highlightRect.width = root.availableWidth * root.visualPosition
				}

				NumberAnimation {
					target: highlightRect
					property: "width"
					from: 0
					to: root._indeterminateHighlightWidth
					duration: Theme.animation_progressBar_duration / 2
				}

				XAnimator {
					target: highlightRect
					to: root.availableWidth - root._indeterminateHighlightWidth
					duration: Theme.animation_progressBar_duration
				}

				ParallelAnimation {
					NumberAnimation {
						target: highlightRect
						property: "x"
						to: root.availableWidth
						duration: Theme.animation_progressBar_duration / 2
					}

					NumberAnimation {
						target: highlightRect
						property: "width"
						to: 0
						duration: Theme.animation_progressBar_duration / 2
					}
				}

				PropertyAction {
					target: highlightRect
					property: "x"
					value: 0
				}
			}
		}
	}
}
