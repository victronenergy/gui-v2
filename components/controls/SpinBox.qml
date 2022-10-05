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

	implicitWidth: Math.max(
		implicitBackgroundWidth + leftInset + rightInset,
		contentItem.implicitWidth + leftPadding + rightPadding,
			+ 2*spacing
			+ up.implicitIndicatorWidth
			+ down.implicitIndicatorWidth)
	implicitHeight: Math.max(
		implicitContentHeight + topPadding + bottomPadding,
		implicitBackgroundHeight,
		up.implicitIndicatorHeight,
		down.implicitIndicatorHeight)
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
		x: root.mirrored ? 0 : parent.width - width
		height: parent.height
		implicitWidth: root.indicatorImplicitWidth
		implicitHeight: Theme.geometry.spinBox.indicator.height
		radius: Theme.geometry.spinBox.indicator.radius
		color: root.up.pressed ? Theme.color.darkOk : Theme.color.ok

		Image {
			anchors.centerIn: parent
			source: 'qrc:/images/icon_plus.svg'
		}
	}

	down.indicator: Rectangle {
		x: root.mirrored ? parent.width - width : 0
		height: parent.height
		implicitWidth: root.indicatorImplicitWidth
		implicitHeight: Theme.geometry.spinBox.indicator.height
		radius: Theme.geometry.spinBox.indicator.radius
		color: root.down.pressed ? Theme.color.darkOk : Theme.color.ok
		Image {
			anchors.centerIn: parent
			source: 'qrc:/images/icon_minus.svg'
		}
	}

	background: Item {
		implicitWidth: 2*Theme.geometry.spinBox.indicator.minimumWidth + 2*Theme.geometry.spinBox.spacing
		implicitHeight: Theme.geometry.spinBox.indicator.height
	}
}
