/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Templates as T
import Victron.VenusOS
import QtQuick.Effects as Effects

T.ProgressBar {
	id: root

	implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
			implicitContentWidth + leftPadding + rightPadding)
	implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
			implicitContentHeight + topPadding + bottomPadding)

	background: Rectangle {
		implicitHeight: Theme.geometry.progressBar.height
		implicitWidth: Theme.geometry.progressBar.height
		radius: Theme.geometry.progressBar.radius
		color: Theme.color.darkOk
	}

	contentItem: Item {
		implicitHeight: Theme.geometry.progressBar.height
		implicitWidth: Theme.geometry.progressBar.height

		Rectangle {
			id: mask
			layer.enabled: true
			visible: false
			height: parent.height
			width: parent.width
			radius: Theme.geometry.progressBar.radius
			color: "black"
		}

		Item {
			id: container
			width: parent.width   // can't use anchors here or the XAnimator breaks
			height: parent.height // see QTBUG-118848
			visible: false
			layer.enabled: true

			Rectangle {
				id: highlightRect
				readonly property bool isMirrored: root.position !== root.visualPosition
				color: Theme.color.ok
				height: container.height
				width: root.indeterminate ? (container.width/3) : (container.width * root.position)
				x: root.indeterminate
					? (highlightRect.isMirrored ? container.width : -highlightRect.width)
					: (highlightRect.isMirrored ? container.width - highlightRect.width : 0)
				radius: Theme.geometry.progressBar.radius

				XAnimator on x {
					running: root.indeterminate
					loops: Animation.Infinite
					duration: Theme.animation.progressBar.duration
					from: root.indeterminate
						? (highlightRect.isMirrored ? container.width : -highlightRect.width)
						: (highlightRect.isMirrored ? container.width - highlightRect.width : 0)
					to: root.indeterminate
						? (highlightRect.isMirrored ? -highlightRect.width : container.width)
						: (highlightRect.isMirrored ? container.width - highlightRect.width : 0) // x only animates for indeterminate bars.
				}
			}
		}

		Effects.MultiEffect {
			visible: true
			anchors.fill: parent
			maskEnabled: true
			maskSource: mask
			source: container
		}
	}
}

