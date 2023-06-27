/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls as C
import QtQuick.Templates as CT
import QtQuick.Controls.impl as CP
import Victron.VenusOS

CT.SpinBox {
	id: root

	property alias label: label
	property int indicatorImplicitWidth: Theme.geometry.spinBox.indicator.minimumWidth
	property int orientation: Qt.Horizontal

	signal maxValueReached()
	signal minValueReached()

	implicitWidth: Math.max(
		implicitBackgroundWidth + leftInset + rightInset,
		contentItem.implicitWidth + leftPadding + rightPadding,
			+ 2*spacing
			+ up.implicitIndicatorWidth
			+ down.implicitIndicatorWidth)
	implicitHeight: orientation === Qt.Horizontal
		? Math.max(implicitContentHeight + topPadding + bottomPadding,
			implicitBackgroundHeight,
			up.implicitIndicatorHeight,
			down.implicitIndicatorHeight)
		: Math.max(implicitContentHeight + topPadding + bottomPadding,
			implicitBackgroundHeight,
			label.implicitHeight)

	spacing: Theme.geometry.spinBox.spacing

	contentItem: Label {
		id: label

		text: root.textFromValue(root.value, root.locale)
		color: Theme.color.font.primary
		font.pixelSize: Theme.font.size.h3
		horizontalAlignment: Qt.AlignHCenter
		verticalAlignment: Qt.AlignVCenter
	}

	up.indicator: Rectangle {
		x: orientation === Qt.Horizontal
		   ? root.mirrored ? 0 : parent.width - width
		   : label.x + (label.width / 2) - (width / 2)
		y: orientation === Qt.Horizontal
		   ? label.y + (label.height / 2) - (height / 2)
		   : label.y - Theme.geometry.spinBox.spacing - height
		implicitWidth: root.indicatorImplicitWidth
		implicitHeight: orientation === Qt.Horizontal
			? Theme.geometry.spinBox.indicator.horizontalOrientation.height
			: Theme.geometry.spinBox.indicator.verticalOrientation.height
		radius: Theme.geometry.spinBox.indicator.radius
		color: root.up.pressed ? Theme.color.darkOk : Theme.color.dimBlue

		Image {
			anchors.centerIn: parent
			source: 'qrc:/images/icon_plus.svg'
		}
	}

	down.indicator: Rectangle {
		x: orientation === Qt.Horizontal
		   ? root.mirrored ? parent.width - width : 0
		   : label.x + (label.width / 2) - (width / 2)
		y: orientation === Qt.Horizontal
		   ? label.y + (label.height / 2) - (height / 2)
		   : label.y + label.height + Theme.geometry.spinBox.spacing
		implicitWidth: root.indicatorImplicitWidth
		implicitHeight: orientation === Qt.Horizontal
			? Theme.geometry.spinBox.indicator.horizontalOrientation.height
			: Theme.geometry.spinBox.indicator.verticalOrientation.height
		radius: Theme.geometry.spinBox.indicator.radius
		color: root.down.pressed ? Theme.color.darkOk : Theme.color.dimBlue
		Image {
			anchors.centerIn: parent
			source: 'qrc:/images/icon_minus.svg'
		}
	}

	background: Item {
		implicitWidth: 2*Theme.geometry.spinBox.indicator.minimumWidth + 2*Theme.geometry.spinBox.spacing
		implicitHeight: orientation === Qt.Horizontal
			? Theme.geometry.spinBox.indicator.horizontalOrientation.height
			: Theme.geometry.spinBox.indicator.verticalOrientation.height
	}

	readonly property bool _upPressed: up.pressed
	on_UpPressed: {
		if (_upPressed) {
			if ((value + stepSize) > to ) {
				root.maxValueReached()
			}
			root.increase()
		}
	}

	readonly property bool _downPressed: down.pressed
	on_DownPressed: {
		if (_downPressed) {
			if ((value - stepSize) < from ) {
				root.minValueReached()
			}
			root.decrease()
		}
	}
}
