/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

Item {
	id: root

	property alias hour: hrSpinbox.value
	property alias minute: minSpinbox.value

	property int maximumHour: 23
	property int maximumMinute: 59

	implicitWidth: minSpinbox.x + minSpinbox.width
	implicitHeight: hrSpinbox.y + hrSpinbox.height

	Label {
		id: hrLabel
		anchors.horizontalCenter: hrSpinbox.horizontalCenter

		//% "hr"
		text: qsTrId("timeselector_hr")
		color: Theme.color.font.secondary
	}

	Label {
		id: minLabel
		anchors.horizontalCenter: minSpinbox.horizontalCenter

		//% "min"
		text: qsTrId("timeselector_min")
		color: Theme.color.font.secondary
	}

	SpinBox {
		id: hrSpinbox
		anchors {
			top: hrLabel.bottom
			topMargin: Theme.geometry.timeSelector.timeLabel.spacing
			right: parent.horizontalCenter
			rightMargin: Theme.geometry.timeSelector.spacing
		}

		width: Theme.geometry.timeSelector.spinBox.width
		height: Theme.geometry.timeSelector.spinBox.height
		from: 0
		to: root.maximumHour
		label.text: Utils.pad(value, 2)
	}

	Label {
		id: colonLabel
		anchors {
			verticalCenter: hrSpinbox.verticalCenter
			horizontalCenter: parent.horizontalCenter
		}

		text: ":"
		color: Theme.color.font.secondary
		font.pixelSize: Theme.font.size.h3
	}

	SpinBox {
		id: minSpinbox
		anchors {
			top: minLabel.bottom
			topMargin: Theme.geometry.timeSelector.timeLabel.spacing
			left: parent.horizontalCenter
			leftMargin: Theme.geometry.timeSelector.spacing
		}

		width: Theme.geometry.timeSelector.spinBox.width
		height: Theme.geometry.timeSelector.spinBox.height
		from: 0
		to: root.maximumMinute
		label.text: Utils.pad(value, 2)
	}
}
