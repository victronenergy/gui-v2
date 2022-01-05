/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	property var physicalQuantity: Units.Power // eg. Units.Voltage, Units.Current, Units.Power
	property var l1Value // in SI units, eg. 1234 for 1234 W
	property var l2Value // in SI units, eg. 1234 for 1234 W
	property var l3Value // in SI units, eg. 1234 for 1234 W
	property int precision: 3 // this will display 1.23 kW, given a value of 1234 W

	//% "%1 %2"
	//: The first argument is the value in SI units (e.g. 123 for 123 Watts), the second argument is the SI unit (e.g. W for 123 Watts)
	property string _valueText: qsTrId("component_threephasedisplay_valuetext")

	Label {
		id: l1Label
		anchors {
			top: parent.top
			left: parent.left
		}

		//% "L1:"
		text: qsTrId("component_threephasedisplay_l1_label")
		color: Theme.color.font.secondary
	}

	Label {
		id: l1ValueLabel
		anchors {
			verticalCenter: l1Label.verticalCenter
			right: parent.right
		}

		readonly property var displayValue: Units.getDisplayText(root.physicalQuantity, root.l1Value, root.precision)
		text: root._valueText.arg(displayValue.number).arg(displayValue.units)
		color: Theme.color.font.secondary
	}

	Label {
		id: l2Label
		anchors {
			top: l1Label.bottom
			left: parent.left
		}

		//% "L2:"
		text: qsTrId("component_threephasedisplay_l2_label")
		color: Theme.color.font.secondary
	}

	Label {
		id: l2ValueLabel
		anchors {
			verticalCenter: l2Label.verticalCenter
			right: parent.right
		}

		readonly property var displayValue: Units.getDisplayText(root.physicalQuantity, root.l2Value, root.precision)
		text: root._valueText.arg(displayValue.number).arg(displayValue.units)
		color: Theme.color.font.secondary
	}

	Label {
		id: l3Label
		anchors {
			top: l2Label.bottom
			left: parent.left
		}

		//% "L3:"
		text: qsTrId("component_threephasedisplay_l3_label")
		color: Theme.color.font.secondary
	}

	Label {
		id: l3ValueLabel
		anchors {
			verticalCenter: l3Label.verticalCenter
			right: parent.right
		}

		readonly property var displayValue: Units.getDisplayText(root.physicalQuantity, root.l3Value, root.precision)
		text: root._valueText.arg(displayValue.number).arg(displayValue.units)
		color: Theme.color.font.secondary
	}
}
