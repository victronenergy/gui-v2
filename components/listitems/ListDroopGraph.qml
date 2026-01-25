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
	property alias p0Value: frequencyDroopGraph.xAxisReferenceValue
	property alias p0LowerValue: frequencyDroopGraph.xAxisLowerReferenceValue
	property alias p0UpperValue: frequencyDroopGraph.xAxisUpperReferenceValue
	property alias f0Value: frequencyDroopGraph.yAxisReferenceValue

	// Volage graph variables
	property alias q0Value: voltageDroopGraph.xAxisReferenceValue
	property alias p0LowerValue: frequencyDroopGraph.xAxisLowerReferenceValue
	property alias p0UpperValue: frequencyDroopGraph.xAxisUpperReferenceValue
	property alias u0Value: voltageDroopGraph.yAxisReferenceValue

	property alias voltagePercent: voltageDroopGraph.indicatorPercent
	property alias frequencyPercent: frequencyDroopGraph.indicatorPercent

	property bool preferredVisible: true

	// True if the item should be made visible. This is used by VisibleItemModel to filter out
	// non-valid items. (It must filter by 'effectiveVisible' instead of `visible', as the latter is
	// affected by the parent's visible value, causing the item to be unnecessarily filtered in and
	// out of a VisibleItemModel whenever a parent page is shown/hidden.)
	property bool effectiveVisible: preferredVisible

//	property alias background: backgroundRect
	property real bottomInset

	// Allow item to receive focus within its focus scope.
	focus: false

	// Allow Utils.acceptsKeyNavigation() to accept moving focus to this item.
	focusPolicy: Qt.NoFocus

	KeyNavigationHighlight.active: root.activeFocus

	implicitHeight: effectiveVisible ? 290 : 0
	implicitWidth: parent ? parent.width : 0

	Row {
		anchors {
			fill: parent
			bottomMargin: root.bottomInset
		}
		spacing: 4

		Layout.topMargin: Theme.geometry_listItem_content_verticalMargin
		Layout.bottomMargin: Theme.geometry_listItem_content_verticalMargin
		Layout.maximumWidth: root.width
		Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
		Layout.rowSpan: 2

		ListItemBackground {
			width: 374
			height: frequencyLabel.height + frequencyLabel.anchors.topMargin +
					frequencyDroopGraph.height + frequencyDroopGraph.anchors.topMargin +
					6 //Theme.

			Label {
				id: frequencyLabel
				anchors {
					top: parent.top
					topMargin: 12
					left: parent.left
					leftMargin: 24
				}

				text: CommonWords.frequency
				font.pixelSize: Theme.font_size_body1
				color: Theme.color_font_primary
				verticalAlignment: Text.AlignVCenter
			}

			DroopGraph {
				id: frequencyDroopGraph
				anchors {
					top: frequencyLabel.bottom
					topMargin: 8
					left: parent.left
					leftMargin: 24
				}

				//% "P"
				xAxisLabel: qsTrId("microgrid_droopGraph_activePower_label")

				//% "f"
				yAxisLabel: qsTrId("microgrid_droopGraph_frequency_label")
				yAxisReferenceUnit: VenusOS.Units_Hertz
				yAxisOperationUnit: VenusOS.Units_Hertz

				Rectangle {
					anchors.fill: parent
					color: "transparent"
					border.color: "red"
					border.width: 1
				}
			}
		}
		ListItemBackground {
			width: 374 //(parent.width - parent.spacing) /2
			height: 247 //parent.height

			Label {
				id: voltageLabel
				anchors {
					top: parent.top
					topMargin: 12
					left: parent.left
					leftMargin: 24
				}

				text: CommonWords.voltage
				font.pixelSize: Theme.font_size_body1
				color: Theme.color_font_primary
				verticalAlignment: Text.AlignVCenter
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
				xAxisLabel: qsTrId("microgrid_droopGraph_reactivePower_label")

				//% "U"
				yAxisLabel: qsTrId("microgrid_droopGraph_voltage_label")
				yAxisReferenceUnit: VenusOS.Units_Volt_AC
				yAxisOperationUnit: VenusOS.Units_Volt_AC
			}
		}
	}
}
