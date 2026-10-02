/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Shapes
import Victron.VenusOS

/*
	Shows the indoor air quality score (/IAQS) on a five-segment arc, with the PM2.5 and CO2 values
	that drive it.

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

	In portrait, the device name is shown above, as there is no panel header.
*/
Item {
	id: root

	required property string serviceUid
	required property string name

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
	readonly property string categoryText: {
		switch (category) {
		case 0:
			//% "Excellent"
			return qsTrId("temperature_air_quality_excellent")
		case 1:
			//% "Good"
			return qsTrId("temperature_air_quality_good")
		case 2:
			//% "Fair"
			return qsTrId("temperature_air_quality_fair")
		case 3:
			//% "Poor"
			return qsTrId("temperature_air_quality_poor")
		case 4:
			//% "Very poor"
			return qsTrId("temperature_air_quality_very_poor")
		default:
			//% "No data"
			return qsTrId("temperature_air_quality_no_data")
		}
	}

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

	component ValueRow : Item {
		id: valueRow

		required property string text
		required property real value
		required property int unit

		height: Math.max(rowLabel.implicitHeight, rowQuantity.implicitHeight)

		Label {
			id: rowLabel

			anchors {
				left: parent.left
				right: rowQuantity.left
				rightMargin: Theme.geometry_levelsGauge_horizontalSpacing
				verticalCenter: parent.verticalCenter
			}
			elide: Text.ElideRight
			font.pixelSize: Theme.font_levelsPage_airQuality_row
			text: valueRow.text
		}

		QuantityLabel {
			id: rowQuantity

			anchors {
				right: parent.right
				verticalCenter: parent.verticalCenter
			}
			alignment: Qt.AlignRight | Qt.AlignVCenter
			font.pixelSize: Theme.font_levelsPage_airQuality_row
			valueColor: Theme.color_font_secondary
			value: valueRow.value
			unit: valueRow.unit
			unitText: isNaN(valueRow.value) ? "" : Units.defaultUnitString(valueRow.unit)
			decimals: 0
		}
	}

	// Width available to the content, inside the horizontal padding.
	readonly property real _innerWidth: width - (2 * Theme.geometry_levelsGauge_horizontalSpacing)

	// In landscape, the panel stretches vertically: the arc is at the top and the values at the
	// bottom. In portrait, the content is stacked and sized to fit.
	implicitHeight: Theme.screenSize === Theme.Portrait ? valueColumn.y + valueColumn.height : 0

	Column {
		id: arcColumn

		x: Theme.geometry_levelsGauge_horizontalSpacing
		y: Theme.screenSize === Theme.Portrait ? 0
			: (Global.pageManager?.expandLayout ?? false) ? Theme.geometry_levelsPage_airQuality_expanded_topPadding
			: Theme.geometry_levelsGauge_verticalSpacing
		width: root._innerWidth
		spacing: Theme.geometry_levelsGauge_verticalPadding

		Label {
			width: parent.width
			horizontalAlignment: Text.AlignHCenter
			elide: Text.ElideRight
			font.pixelSize: Theme.font_levelsGauge_title
			text: root.name
			visible: Theme.screenSize === Theme.Portrait
		}

		Shape {
			id: arc

			// In landscape, shrink the arc if needed so that it fits above the values.
			readonly property real _availableHeight: Theme.screenSize === Theme.Portrait ? Infinity
					: valueColumn.y - arcColumn.y - arcColumn.spacing - arcLabel.height
						- Theme.geometry_levelsGauge_verticalPadding

			anchors.horizontalCenter: parent.horizontalCenter
			// The arc is open at the bottom, so the height only covers the drawn part: down to the
			// end caps at +/-135 degrees. This keeps the label below close to the arc.
			readonly property real _heightRatio: 0.5 + (0.5 * Math.SQRT1_2)

			width: Math.max(0, Math.min(Theme.geometry_levelsPage_airQuality_arc_size, parent.width,
					_availableHeight / _heightRatio))
			height: Math.ceil(width * _heightRatio)

			Segment { index: 0; radius: arc.width / 2; strokeColor: root._segmentColor(4) }
			Segment { index: 1; radius: arc.width / 2; strokeColor: root._segmentColor(3) }
			Segment { index: 2; radius: arc.width / 2; strokeColor: root._segmentColor(2) }
			Segment { index: 3; radius: arc.width / 2; strokeColor: root._segmentColor(1) }
			Segment { index: 4; radius: arc.width / 2; strokeColor: root._segmentColor(0) }

			Column {
				// Centre on the centre of the circle, not of the (shorter) item.
				anchors.horizontalCenter: parent.horizontalCenter
				y: (parent.width - height) / 2

				QuantityLabel {
					anchors.horizontalCenter: parent.horizontalCenter
					font.pixelSize: Theme.font_levelsPage_airQuality_score
					value: iaqsItem.valid && !root.offline ? iaqsItem.value : NaN
					unit: VenusOS.Units_None
				}

				Label {
					anchors.horizontalCenter: parent.horizontalCenter
					color: root.category >= 0 ? root.categoryColors[root.category] : Theme.color_font_secondary
					font.pixelSize: Theme.font_levelsPage_airQuality_category
					text: root.categoryText
				}
			}
		}

		Label {
			id: arcLabel

			width: parent.width
			horizontalAlignment: Text.AlignHCenter
			elide: Text.ElideRight
			color: Theme.color_font_secondary
			font.pixelSize: Theme.font_levelsGauge_title
			//% "Air quality"
			text: qsTrId("temperature_air_quality")
		}
	}

	Column {
		id: valueColumn

		x: Theme.geometry_levelsGauge_horizontalSpacing
		y: Theme.screenSize === Theme.Portrait ? arcColumn.height + Theme.geometry_levelsGauge_verticalPadding
			: root.height - height
		width: root._innerWidth
		bottomPadding: Theme.screenSize === Theme.Portrait ? 0 : Theme.geometry_levelsGauge_verticalSpacing
		spacing: Theme.geometry_levelsGauge_verticalPadding

		SeparatorBar {
			width: parent.width
		}

		ValueRow {
			width: parent.width
			//% "PM2.5"
			text: qsTrId("temperature_pm25")
			value: pm25Item.valid && !root.offline ? pm25Item.value : NaN
			unit: VenusOS.Units_MicrogramPerCubicMeter
		}

		ValueRow {
			width: parent.width
			//% "CO₂"
			text: qsTrId("temperature_co2")
			value: co2Item.valid && !root.offline ? co2Item.value : NaN
			unit: VenusOS.Units_PartsPerMillion
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
		uid: root.serviceUid ? root.serviceUid + "/SeqNo" : ""
		onValueChanged: {
			staleTimer.stale = false
			staleTimer.restart()
		}
	}

	VeQuickItem {
		id: statusItem
		uid: root.serviceUid ? root.serviceUid + "/Status" : ""
	}

	VeQuickItem {
		id: connectedItem
		uid: root.serviceUid ? root.serviceUid + "/Connected" : ""
	}

	VeQuickItem {
		id: iaqsItem
		uid: root.serviceUid ? root.serviceUid + "/IAQS" : ""
	}

	VeQuickItem {
		id: pm25Item
		uid: root.serviceUid ? root.serviceUid + "/PM25" : ""
	}

	VeQuickItem {
		id: co2Item
		uid: root.serviceUid ? root.serviceUid + "/CO2" : ""
	}
}
