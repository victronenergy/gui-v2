/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls as C
import Victron.VenusOS

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
		color: Theme.color.progressBar.background
	}

	contentItem: Item {
		implicitHeight: Theme.geometry.progressBar.height
		implicitWidth: Theme.geometry.progressBar.height

		Item {
			id: container
			height: parent.height
			width: root.indeterminate ? (root.width/3) : root.width
			x: isMirrored ? (root.width - width - startX) : startX
			readonly property bool isMirrored: root.position !== root.visualPosition
			property int startX: 0

			SequentialAnimation on startX {
				onRunningChanged: console.log("ProgressBar animation 1: running:", running)
				loops: Animation.Infinite
				running: root.indeterminate
				NumberAnimation {
					onRunningChanged: console.log("ProgressBar animation 2: running:", running)
					from: -container.width
					to: root.width
					duration: Theme.animation.progressBar.duration
				}
			}

			Rectangle {
				id: highlightRect
				anchors {
					left: parent.left
					right: parent.right
					leftMargin: root.indeterminate ? (parent.x < 0 ? -parent.x : 0)
							: (parent.isMirrored ? (parent.width - parent.width*root.position) : 0)
					rightMargin: root.indeterminate ? ((root.width - (parent.x + parent.width) < 0) ? (-(root.width - (parent.x + parent.width))) : 0)
							: (parent.isMirrored ? 0 : (parent.width - parent.width*root.position))
				}
				height: parent.height
				radius: Theme.geometry.progressBar.radius
				color: Theme.color.progressBar.indicator
			}
		}
	}
}

