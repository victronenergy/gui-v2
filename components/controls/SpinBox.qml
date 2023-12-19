/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Templates as CT
import QtQuick.Controls.impl as CP
import Victron.VenusOS

CT.SpinBox {
	id: root

	property alias label: primaryLabel
	property string secondaryText
	property int indicatorImplicitWidth: Theme.geometry.spinBox.indicator.minimumWidth
	property int orientation: Qt.Horizontal
	property int _scalingFactor: 1

	signal maxValueReached()
	signal minValueReached()

	implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
		orientation === Qt.Horizontal
			? valueColumn.width + up.indicator.width + down.indicator.width + (2 * Theme.geometry.spinBox.spacing) + leftPadding + rightPadding
			: valueColumn.width + leftPadding + rightPadding)
	implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
		orientation === Qt.Horizontal
			? Math.max(valueColumn.height, up.indicator.height, down.indicator.height) + topPadding + bottomPadding
			: valueColumn.height + up.indicator.height + down.indicator.height + (2 * Theme.geometry.spinBox.spacing) + topPadding + bottomPadding)

	spacing: Theme.geometry.spinBox.spacing
	onValueModified: {
		if (value === to) {
			root.maxValueReached()
		} else if (value === from) {
			root.minValueReached()
		}
	}

	contentItem: Item {
		Column {
			id: valueColumn

			width: Math.max(primaryLabel.implicitWidth, secondaryLabel.implicitWidth)
			anchors.centerIn: parent

			Label {
				id: primaryLabel

				width: parent.width
				text: root.textFromValue(root.value, root.locale)
				color: root.enabled ? Theme.color.font.primary : Theme.color.font.disabled
				font.pixelSize: root.secondaryText.length ? Theme.font.size.h2 : Theme.font.size.h3
				horizontalAlignment: Qt.AlignHCenter
				verticalAlignment: Qt.AlignVCenter
			}

			Label {
				id: secondaryLabel

				width: primaryLabel.width
				height: text.length ? implicitHeight : 0
				text: root.secondaryText
				color: Theme.color.font.secondary
				font.pixelSize: Theme.font.size.caption
				horizontalAlignment: Qt.AlignHCenter
			}
		}
	}

	up.indicator: Rectangle {
		x: orientation === Qt.Horizontal
		   ? parent.width - width
		   : contentItem.x + (contentItem.width / 2) - (width / 2)
		y: orientation === Qt.Horizontal
		   ? contentItem.y + (contentItem.height / 2) - (height / 2)
		   : contentItem.y + contentItem.height - height
		implicitWidth: root.indicatorImplicitWidth
		implicitHeight: Theme.geometry.spinBox.indicator.height
		radius: Theme.geometry.spinBox.indicator.radius
		color: root.enabled
			   ? (root.up.pressed ? Theme.color.darkOk : Theme.color.dimBlue)
			   : Theme.color.background.disabled

		Image {
			anchors.centerIn: parent
			source: 'qrc:/images/icon_plus.svg'
			opacity: root.enabled ? 1.0 : 0.7   // TODO add Theme opacity constants
		}
	}

	down.indicator: Rectangle {
		x: orientation === Qt.Horizontal
		   ? 0
		   : contentItem.x + (contentItem.width / 2) - (width / 2)
		y: orientation === Qt.Horizontal
		   ? contentItem.y + (contentItem.height / 2) - (height / 2)
		   : contentItem.y
		implicitWidth: root.indicatorImplicitWidth
		implicitHeight: Theme.geometry.spinBox.indicator.height
		radius: Theme.geometry.spinBox.indicator.radius
		color: root.enabled
			   ? (root.down.pressed ? Theme.color.darkOk : Theme.color.dimBlue)
			   : Theme.color.background.disabled
		Image {
			anchors.centerIn: parent
			source: 'qrc:/images/icon_minus.svg'
			opacity: root.enabled ? 1.0 : 0.7   // TODO add Theme opacity constants
		}
	}

	Timer {
		id: pressTimer

		interval: 1000
		repeat: true
		running: up.pressed || down.pressed
		onTriggered: _scalingFactor *= 2
		onRunningChanged: {
			if (!running) {
				_scalingFactor = 1
			}
		}
	}

	Timer {
		interval: 100
		repeat: true
		running: pressTimer.running
		onTriggered: {
			for (let i = 0; i < _scalingFactor; ++i) {
				up.pressed ? root.increase() : root.decrease()
			}
		}
	}
}
