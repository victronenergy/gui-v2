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
	property alias q0LowerValue: voltageDroopGraph.xAxisLowerReferenceValue
	property alias q0UpperValue: voltageDroopGraph.xAxisUpperReferenceValue
	property alias u0Value: voltageDroopGraph.yAxisReferenceValue

	property alias voltageRatio: voltageDroopGraph._indicatorRatio
	property alias frequencyRatio: frequencyDroopGraph._indicatorRatio

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

	implicitHeight: effectiveVisible ? 217  : 0
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
			width: 374 // These values
			height: 217 // Theme values

			Label {
				id: frequencyLabel
				anchors {
					top: parent.top
					topMargin: 12 // Theme
					left: parent.left
					leftMargin: 24 //Theme
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
					topMargin: 8 // Theme
					left: parent.left
					leftMargin: 24 // Theme
				}

				//% "P"
				yAxisLabel: qsTrId("microgrid_droopGraph_activePower_label")

				//% "f"
				xAxisLabel: qsTrId("microgrid_droopGraph_frequency_label")
				xAxisUnit: VenusOS.Units_Hertz

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
			height: 217 //parent.height

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
				yAxisLabel: qsTrId("microgrid_droopGraph_reactivePower_label")

				//% "U"
				xAxisLabel: qsTrId("microgrid_droopGraph_voltage_label")
				xAxisUnit: VenusOS.Units_Volt_AC
			}
		}
	}
}
