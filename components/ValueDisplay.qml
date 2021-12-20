/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Column {
	id: root

	property var physicalQuantity: Units.Power // eg. Units.Voltage, Units.Current, Units.Power
	property real value // in SI units, eg. 1234 for 1234W
	property int precision: 3 // this will display 1.23kW, given a value of 1234
	property bool rightAligned: true // on the right hand side, we anchor to the right. Vice-versa for the left hand side.
	property int fontSize: Theme.font.size.xl

	property alias icon: icon
	property alias title: title
	property alias quantityRow: quantityRow
	property alias titleRow: titleRow
	readonly property var _displayValue: Units.getDisplayText(root.physicalQuantity, root.value, root.precision)

	anchors {
		right: rightAligned ? parent.right : undefined
		left: rightAligned ? undefined : parent.left
	}
	Row {
		id: titleRow

		anchors {
			right: rightAligned ? parent.right : undefined
			left: rightAligned ? undefined : parent.left
		}
		layoutDirection: rightAligned ? Qt.LeftToRight : Qt.RightToLeft
		spacing: Theme.geometry.valueDisplay.titleRow.spacing
		Label {
			id: title

			anchors.verticalCenter: parent.verticalCenter
		}
		Item {
			width: Theme.geometry.valueDisplay.icon.width
			height: width
			Image {
				id: icon

				anchors.centerIn: parent
			}
		}

	}
	Row {
		id: quantityRow

		spacing: Theme.geometry.valueDisplay.quantityRow.spacing
		anchors {
			right: rightAligned ? parent.right : undefined
			left: rightAligned ? undefined : parent.left
		}
		Label {
			anchors.verticalCenter: parent.verticalCenter
			font.pixelSize: fontSize
			//% "%1"
			text: qsTrId("value_label").arg(_displayValue.number)
		}
		Label {
			anchors.verticalCenter: parent.verticalCenter
			font.pixelSize: fontSize
			opacity: 0.7
			//% "%1"
			text: qsTrId("value_unit").arg(_displayValue.units)
		}
	}
}
