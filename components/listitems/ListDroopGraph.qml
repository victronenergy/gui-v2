/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

ListItem {
	id: root

	// Frequency graph variables
	property real p0Value
	property real p0LowerValue
	property real p0UpperValue
	property real f0Value
	property real fpDroop
	property real frequency

	// Voltage graph variables
	property real q0Value
	property real q0LowerValue
	property real q0UpperValue
	property real u0Value
	property real uqDroop
	property real voltage

	component GraphLabel: Label {
		anchors {
			top: parent.top
			topMargin: Theme.geometry_droopGraph_container_label_topMargin
			left: parent.left
			leftMargin: Theme.geometry_droopGraph_container_label_leftMargin
		}
		font.pixelSize: Theme.font_size_body1
		color: Theme.color_font_primary
		verticalAlignment: Text.AlignVCenter
	}

	leftPadding: 0
	rightPadding: 0
	topPadding: 0
	bottomPadding: 0

	contentItem: RowLayout {

		spacing: Theme.geometry_droopGraph_container_spacing

		ListItemBackground {
			id: frequencyBackground
			implicitWidth: Theme.geometry_droopGraph_container_width
			implicitHeight: Theme.geometry_droopGraph_container_height

			GraphLabel {
				id: frequencyLabel
				text: CommonWords.frequency
			}

			DroopGraph {
				id: frequencyDroopGraph
				anchors {
					top: frequencyLabel.bottom
					topMargin: Theme.geometry_droopGraph_topMargin
					left: parent.left
					leftMargin: Theme.geometry_droopGraph_leftMargin
				}

				//% "P"
				yAxisLabel: qsTrId("microgrid_droopGraph_activePower_label")

				//% "f"
				xAxisLabel: qsTrId("microgrid_droopGraph_frequency_label")

				yAxisReferenceValue: root.p0Value
				yAxisLowerReferenceValue: root.p0LowerValue
				yAxisUpperReferenceValue: root.p0UpperValue
				xAxisReferenceValue: root.f0Value
				droop: root.fpDroop

				xAxisOperationValue: root.frequency
				xAxisUnit: VenusOS.Units_Hertz
			}
		}
		ListItemBackground {
			id: voltageBackground
			implicitWidth: Theme.geometry_droopGraph_container_width
			implicitHeight: Theme.geometry_droopGraph_container_height

			GraphLabel {
				id: voltageLabel
				text: CommonWords.voltage
			}

			DroopGraph {
				id: voltageDroopGraph
				anchors {
					top: voltageLabel.bottom
					topMargin: Theme.geometry_droopGraph_topMargin
					left: parent.left
					leftMargin: Theme.geometry_droopGraph_leftMargin
				}

				//% "Q"
				yAxisLabel: qsTrId("microgrid_droopGraph_reactivePower_label")

				//% "U"
				xAxisLabel: qsTrId("microgrid_droopGraph_voltage_label")

				yAxisReferenceValue: root.q0Value
				yAxisLowerReferenceValue: root.q0LowerValue
				yAxisUpperReferenceValue: root.q0UpperValue
				xAxisReferenceValue: root.u0Value
				droop: root.uqDroop

				xAxisOperationValue: root.voltage
				xAxisUnit: VenusOS.Units_Volt_AC
			}
		}
	}

	background: null
}
