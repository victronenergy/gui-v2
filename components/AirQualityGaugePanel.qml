/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Victron.VenusOS

/*
	Shows the indoor air quality score (/IAQS) on a five-segment arc, with the PM2.5 and CO2 values
	that drive it.

	|      Device name      |
	|-----------------------|
	|      .-~~~~~-.        |
	|     /   86    \       |
	|    |   Good    |      |
	|     \         /       |
	|     Air quality       |
	|                       |
	|-----------------------|
	|  PM2.5      12 ug/m3  |
	|  CO2         620 ppm  |

	The score, the category word and the lit segment always appear together, so colour is never
	the only signal. Without a score, the category is taken from the worst of PM2.5 and CO2.
	When the sensor is offline, the score and values show "--" and the category shows "No data".

	In landscape, the panel stretches vertically: the arc is at the top and the values at the
	bottom. In portrait, the content is stacked and sized to fit and the device name is shown above,
	as there is no panel header.
*/
AbstractListItem {
	id: root

	required property Device device

	// Band boundaries used to categorise PM2.5 and CO2 when there is no score. Values below the
	// first boundary are Excellent, values above the last one are Very poor.
	readonly property list<real> pm25Boundaries: [5, 9, 15, 35]
	readonly property list<real> co2Boundaries: [600, 800, 1000, 1400]

	// The sensor is offline if it reports so, or if no new measurement arrived for 5 minutes.
	readonly property bool offline: (statusItem.valid && statusItem.value !== 0)
			|| (connectedItem.valid && connectedItem.value !== 1)
			|| staleTimer.stale

	// 0 = Excellent ... 4 = Very poor, -1 = no data
	readonly property int category: {
		if (offline) {
			return -1
		}
		if (iaqsItem.valid) {
			const score = iaqsItem.value
			return score > 90 ? 0
				: score > 80 ? 1
				: score > 50 ? 2
				: score >= 10 ? 3
				: 4
		}
		return Math.max(_metricCategory(pm25Item, pm25Boundaries), _metricCategory(co2Item, co2Boundaries))
	}
	readonly property string categoryText: iaqsItem.valid && !offline
			? Services.environment.airQualityToText(iaqsItem.value)
			  //% "No data"
			: qsTrId("temperature_air_quality_no_data")

	readonly property list<color> categoryColors: [
		Theme.color_green,
		Theme.color_green,
		Theme.color_levelsPage_airQuality_yellow,
		Theme.color_orange,
		Theme.color_red
	]
	readonly property list<color> categoryDimColors: [
		Theme.color_darkGreen,
		Theme.color_darkGreen,
		Theme.color_levelsPage_airQuality_darkYellow,
		Theme.color_darkOrange,
		Theme.color_darkRed
	]

	// Returns the category (0-4) of a PM2.5 or CO2 value, or -1 if it is not valid.
	function _metricCategory(item, boundaries) {
		if (!item.valid) {
			return -1
		}
		let band = 0
		while (band < boundaries.length && item.value >= boundaries[band]) {
			++band
		}
		return band
	}

	// Returns the colour of the arc segment for the given category; only the current one is lit.
	function _segmentColor(segmentCategory) {
		return offline ? Theme.color_levelsPage_airQuality_inactive
			: segmentCategory === category ? categoryColors[segmentCategory]
			: categoryDimColors[segmentCategory]
	}

	// One of the five arc segments. Segment 0 (Very poor) is at the bottom left, segment 4
	// (Excellent) at the bottom right; the arc leaves a 90 degree gap at the bottom.
	component Segment : Arc {
		required property int index

		readonly property real _sweep: 270 / 5
		// Angle covered by a round cap, plus half of the visual gap between two segments.
		readonly property real _inset: (strokeWidth * 1.25 / (radius - strokeWidth / 2)) * 180 / Math.PI

		animationEnabled: false
		startAngle: -135 + (index * _sweep) + _inset
		endAngle: -135 + ((index + 1) * _sweep) - _inset
		strokeWidth: Theme.geometry_levelsPage_airQuality_arc_strokeWidth
	}

	component ValueRow : RowLayout {
		id: valueRow

		required property string text
		required property real value
		required property int unit

		Label {
			elide: Text.ElideRight
			text: valueRow.text
			font.pixelSize: Theme.font_levelsPage_airQuality_row
		}

		QuantityLabel {
			valueColor: Theme.color_font_secondary
			value: valueRow.value
			unit: valueRow.unit
			unitText: isNaN(valueRow.value) ? "" : Units.defaultUnitString(valueRow.unit)
			decimals: 0
			font.pixelSize: Theme.font_levelsPage_airQuality_row
			Layout.alignment: Qt.AlignRight
		}
	}

	implicitWidth: Math.max(
		implicitBackgroundWidth + leftInset + rightInset,
		implicitContentWidth + leftPadding + rightPadding)
	implicitHeight: Math.max(
		implicitBackgroundHeight + topInset + bottomInset,
		implicitContentHeight + topPadding + bottomPadding)
	leftInset: Theme.geometry_levelsPage_panel_horizontalInset
	rightInset: Theme.geometry_levelsPage_panel_horizontalInset
	leftPadding: leftInset + Theme.geometry_levelsGauge_horizontalPadding
	rightPadding: rightInset + Theme.geometry_levelsGauge_horizontalPadding
	topPadding: Theme.geometry_levelsPage_panel_header_height + Theme.geometry_environmentGaugePanel_verticalPadding
	bottomPadding: Theme.geometry_environmentGaugePanel_verticalPadding

	background: EnvironmentGaugePanelBackground {
		title: root.device?.name ?? ""
	}

	contentItem: Item {
		implicitWidth: contentColumn.implicitWidth
		implicitHeight: contentColumn.y
				+ contentColumn.implicitHeight
				+ airQualityLabel.implicitHeight
				+ Theme.geometry_levelsGauge_verticalPadding // spacing between arc and bottom labels
				+ valueColumn.implicitHeight

		Column {
			id: contentColumn

			width: parent.width
			leftPadding: Theme.geometry_levelsPage_airQuality_arc_horizontalPadding
			rightPadding: Theme.geometry_levelsPage_airQuality_arc_horizontalPadding
			spacing: Theme.geometry_levelsGauge_verticalPadding

			Label {
				anchors.horizontalCenter: parent.horizontalCenter
				font.pixelSize: Theme.font_levelsGauge_title
				text: root.device?.name ?? ""
				opacity: Theme.screenSize === Theme.Portrait ? 1 : 0
			}

			Shape {
				id: arc

				anchors.horizontalCenter: parent.horizontalCenter
				width: Math.min(parent.width, Theme.geometry_levelsPage_airQuality_arc_size)

				Segment { index: 0; radius: arc.width / 2; strokeColor: root._segmentColor(4) }
				Segment { index: 1; radius: arc.width / 2; strokeColor: root._segmentColor(3) }
				Segment { index: 2; radius: arc.width / 2; strokeColor: root._segmentColor(2) }
				Segment { index: 3; radius: arc.width / 2; strokeColor: root._segmentColor(1) }
				Segment { index: 4; radius: arc.width / 2; strokeColor: root._segmentColor(0) }

				QuantityLabel {
					id: iaqsLabel
					anchors.centerIn: parent
					font.pixelSize: Theme.font_levelsPage_airQuality_score
					value: iaqsItem.valid && !root.offline ? iaqsItem.value : NaN
					unit: VenusOS.Units_None
				}

				Label {
					anchors {
						top: iaqsLabel.bottom
						left: parent.left
						right: parent.right
					}
					horizontalAlignment: Text.AlignHCenter
					elide: Text.ElideRight
					color: root.category >= 0 ? root.categoryColors[root.category] : Theme.color_font_secondary
					font.pixelSize: Theme.font_levelsPage_airQuality_category
					text: root.categoryText
				}

				Label {
					id: airQualityLabel
					anchors {
						top: parent.bottom
						left: parent.left
						right: parent.right
					}
					horizontalAlignment: Text.AlignHCenter
					elide: Text.ElideRight
					color: Theme.color_font_secondary
					font.pixelSize: Theme.font_levelsPage_airQuality_category
					//% "Air quality"
					text: qsTrId("temperature_air_quality")
				}
			}
		}

		Column {
			id: valueColumn

			anchors {
				bottom: parent.bottom
				left: parent.left
				right: parent.right
			}
			spacing: Theme.geometry_levelsGauge_verticalPadding

			SeparatorBar {
				x: Theme.geometry_levelsPage_airQuality_arc_horizontalPadding
				width: parent.width - (2 * Theme.geometry_levelsPage_airQuality_arc_horizontalPadding)
			}

			ValueRow {
				x: Theme.geometry_levelsPage_airQuality_footer_horizontalPadding
				width: parent.width - (2 * Theme.geometry_levelsPage_airQuality_footer_horizontalPadding)
				//% "PM2.5"
				text: qsTrId("temperature_pm25")
				value: pm25Item.valid && !root.offline ? pm25Item.value : NaN
				unit: VenusOS.Units_MicrogramPerCubicMeter
			}

			ValueRow {
				x: Theme.geometry_levelsPage_airQuality_footer_horizontalPadding
				width: parent.width - (2 * Theme.geometry_levelsPage_airQuality_footer_horizontalPadding)
				//% "CO₂"
				text: qsTrId("temperature_co2")
				value: co2Item.valid && !root.offline ? co2Item.value : NaN
				unit: VenusOS.Units_PartsPerMillion
			}
		}
	}

	// Marks the sensor as stale when /SeqNo has not changed for 5 minutes. Only used when the
	// sensor publishes a sequence number.
	Timer {
		id: staleTimer

		property bool stale

		interval: 5 * 60 * 1000
		running: seqNoItem.valid && !stale
		onTriggered: stale = true
	}

	VeQuickItem {
		id: seqNoItem
		uid: root.device.serviceUid ? root.device.serviceUid + "/SeqNo" : ""
		onValueChanged: {
			staleTimer.stale = false
			staleTimer.restart()
		}
	}

	VeQuickItem {
		id: statusItem
		uid: root.device.serviceUid ? root.device.serviceUid + "/Status" : ""
	}

	VeQuickItem {
		id: connectedItem
		uid: root.device.serviceUid ? root.device.serviceUid + "/Connected" : ""
	}

	VeQuickItem {
		id: iaqsItem
		uid: root.device.serviceUid ? root.device.serviceUid + "/IAQS" : ""
	}

	VeQuickItem {
		id: pm25Item
		uid: root.device.serviceUid ? root.device.serviceUid + "/PM25" : ""
	}

	VeQuickItem {
		id: co2Item
		uid: root.device.serviceUid ? root.device.serviceUid + "/CO2" : ""
	}
}
