/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

FocusScope {
	id: root

	// Frequency graph variables
	property alias p0Value: frequencyDroopGraph.yAxisReferenceValue
	property alias p0LowerValue: frequencyDroopGraph.yAxisLowerReferenceValue
	property alias p0UpperValue: frequencyDroopGraph.yAxisUpperReferenceValue
	property alias f0Value: frequencyDroopGraph.xAxisReferenceValue
	property alias fpDroop: frequencyDroopGraph.droop

	// Volage graph variables
	property alias q0Value: voltageDroopGraph.yAxisReferenceValue
	property alias q0LowerValue: voltageDroopGraph.yAxisLowerReferenceValue
	property alias q0UpperValue: voltageDroopGraph.yAxisUpperReferenceValue
	property alias u0Value: voltageDroopGraph.xAxisReferenceValue
	property alias uqDroop: voltageDroopGraph.droop

	property alias voltage: voltageDroopGraph.xAxisOperationValue
	property alias frequency: frequencyDroopGraph.xAxisOperationValue

	property bool preferredVisible: true

	// True if the item should be made visible. This is used by VisibleItemModel to filter out
	// non-valid items. (It must filter by 'effectiveVisible' instead of `visible', as the latter is
	// affected by the parent's visible value, causing the item to be unnecessarily filtered in and
	// out of a VisibleItemModel whenever a parent page is shown/hidden.)
	property bool effectiveVisible: preferredVisible

//	property alias background: backgroundRect
	property real bottomInset

	component GraphLabel: Label {
		anchors {
			top: parent.top
			topMargin: 12 // Theme
			left: parent.left
			leftMargin: 24 //Theme
		}
		font.pixelSize: Theme.font_size_body1
		color: Theme.color_font_primary
		verticalAlignment: Text.AlignVCenter
	}

	// Allow item to receive focus within its focus scope.
	focus: false

	// Allow Utils.acceptsKeyNavigation() to accept moving focus to this item.
	focusPolicy: Qt.NoFocus

//	KeyNavigationHighlight.active: root.activeFocus

	implicitHeight: effectiveVisible ? 217  : 0
	implicitWidth: parent ? parent.width : 0

	Row {
		anchors {
			fill: parent
			bottomMargin: root.bottomInset
		}
		spacing: 4 // Theme values

		Layout.topMargin: Theme.geometry_listItem_content_verticalMargin
		Layout.bottomMargin: Theme.geometry_listItem_content_verticalMargin
		Layout.maximumWidth: root.width
		Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
		Layout.rowSpan: 2

		ListItemBackground {
			width: 374 // Theme values
			height: 217 // Theme values

			GraphLabel{
				id: frequencyLabel
				text: CommonWords.frequency
			}

			DroopGraph {
				id: frequencyDroopGraph
				anchors {
					top: frequencyLabel.bottom
					topMargin: 8 // Theme
					left: parent.left
					leftMargin: 24 // Theme
				}

				//% "P"
				yAxisLabel: qsTrId("microgrid_droopGraph_activePower_label")

				//% "f"
				xAxisLabel: qsTrId("microgrid_droopGraph_frequency_label")
				xAxisUnit: VenusOS.Units_Hertz
			}
		}
		ListItemBackground {
			width: 374 //(parent.width - parent.spacing) /2
			height: 217 //parent.height

			GraphLabel {
				id: voltageLabel
				text: CommonWords.voltage
			}

			DroopGraph {
				id: voltageDroopGraph
				anchors {
					top: voltageLabel.bottom
					topMargin: 8
					left: parent.left
					leftMargin: 24
				}

				//% "Q"
				yAxisLabel: qsTrId("microgrid_droopGraph_reactivePower_label")

				//% "U"
				xAxisLabel: qsTrId("microgrid_droopGraph_voltage_label")
				xAxisUnit: VenusOS.Units_Volt_AC
			}
		}
	}
}
