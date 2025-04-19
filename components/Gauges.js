/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

.pragma library
.import Victron.VenusOS as V

const briefCentralGauges = [V.VenusOS.Tank_Type_Battery].concat(V.Global.tanks.tankTypes)

function tankProperties(type) {
	switch (type) {
	case V.VenusOS.Tank_Type_Battery:
		return {
			icon: "qrc:/images/icon_battery_24.svg",
			valueType: V.VenusOS.Gauges_ValueType_FallingPercentage,
			color: V.Theme.color_ok,
			//% "Battery"
			name: qsTrId("gauges_battery")
		}
	case V.VenusOS.Tank_Type_Fuel:
		return {
			icon: "qrc:/images/icon_fuel_24.svg",
			valueType: V.VenusOS.Gauges_ValueType_FallingPercentage,
			color: V.Theme.color_fuel,
			//% "Fuel"
			name: qsTrId("gauges_fuel")
		}
	case V.VenusOS.Tank_Type_FreshWater:
		return {
			icon: "qrc:/images/icon_fresh_water_24.svg",
			valueType: V.VenusOS.Gauges_ValueType_FallingPercentage,
			color: V.Theme.color_freshWater,
			//% "Fresh water"
			name: qsTrId("gauges_fresh_water")
		}
	case V.VenusOS.Tank_Type_WasteWater:
		return {
			icon: "qrc:/images/icon_waste_water_24.svg",
			valueType: V.VenusOS.Gauges_ValueType_RisingPercentage,
			color: V.Theme.color_wasteWater,
			//% "Waste water"
			name: qsTrId("gauges_waste_water")
		}
	case V.VenusOS.Tank_Type_LiveWell:
		return {
			icon: "qrc:/images/icon_livewell_24.svg",
			valueType: V.VenusOS.Gauges_ValueType_FallingPercentage,
			color: V.Theme.color_liveWell,
			//% "Live well"
			name: qsTrId("gauges_live_well")
		}
	case V.VenusOS.Tank_Type_Oil:
		return {
			icon: "qrc:/images/icon_oil_24.svg",
			valueType: V.VenusOS.Gauges_ValueType_FallingPercentage,
			color: V.Theme.color_oil,
			//% "Oil"
			name: qsTrId("gauges_oil")
		}
	case V.VenusOS.Tank_Type_BlackWater:
		return {
			icon: "qrc:/images/icon_black_water_24.svg",
			valueType: V.VenusOS.Gauges_ValueType_RisingPercentage,
			color: V.Theme.color_blackWater,
			//% "Black water"
			name: qsTrId("gauges_black_water")
		}
	case V.VenusOS.Tank_Type_Gasoline:
		return {
			icon: "qrc:/images/icon_fuel_24.svg", // same as "Fuel"
			valueType: V.VenusOS.Gauges_ValueType_FallingPercentage,
			color: V.Theme.color_gasoline,
			//% "Gasoline"
			name: qsTrId("gauges_gasoline")
		}
	case V.VenusOS.Tank_Type_Diesel:
		return {
			icon: "qrc:/images/icon_fuel_24.svg", // same as "Fuel"
			valueType: V.VenusOS.Gauges_ValueType_FallingPercentage,
			color: V.Theme.color_diesel,
			//% "Diesel"
			name: qsTrId("gauges_diesel")
		}
	case V.VenusOS.Tank_Type_LPG:
		return {
			icon: "qrc:/images/icon_lpg_24.svg",
			valueType: V.VenusOS.Gauges_ValueType_FallingPercentage,
			color: V.Theme.color_lpg,
			//% "LPG"
			name: qsTrId("gauges_lpg")
		}
	case V.VenusOS.Tank_Type_LNG:
		return {
			icon: "qrc:/images/icon_lng_24.svg",
			valueType: V.VenusOS.Gauges_ValueType_FallingPercentage,
			color: V.Theme.color_lng,
			//% "LNG"
			name: qsTrId("gauges_lng")
		}
	case V.VenusOS.Tank_Type_HydraulicOil:
		return {
			icon: "qrc:/images/icon_hydraulic_oil_24.svg",
			valueType: V.VenusOS.Gauges_ValueType_FallingPercentage,
			color: V.Theme.color_hydraulicOil,
			//% "Hydraulic oil"
			name: qsTrId("gauges_hydraulic_oil")
		}
	case V.VenusOS.Tank_Type_RawWater:
		return {
			icon: "qrc:/images/icon_raw_water_24.svg",
			valueType: V.VenusOS.Gauges_ValueType_FallingPercentage,
			color: V.Theme.color_rawWater,
			//% "Raw water"
			name: qsTrId("gauges_raw_water")
		}
	}
	console.warn("Unknown tank type", type)
	return {}
}

function width(count, maxCount, availableSpace){
	const _count = Math.min(maxCount, count)
	if (_count <= 3) {
		return V.Theme.geometry_levelsPage_panel_max_width
	} else {
		const _spacing = spacing(_count)
		const margin = V.Theme.geometry_levelsPage_environment_horizontalMargin
		return Math.round((availableSpace - 2*margin + _spacing)/_count) - _spacing
	}
}

function height(expanded) {
	return expanded ? V.Theme.geometry_levelsPage_panel_expanded_height
					: V.Theme.geometry_levelsPage_panel_compact_height
}

function spacing(count) {
	if (count <= 1) {
		return 0
	} else if (count === 2) {
		return V.Theme.geometry_levelsPage_gauge_spacing_large
	} else if (count === 3) {
		return V.Theme.geometry_levelsPage_gauge_spacing_medium
	} else if (count === 4) {
		return V.Theme.geometry_levelsPage_gauge_spacing_small
	} else {
		return V.Theme.geometry_levelsPage_gauge_spacing_tiny
	}
}

/*
  Returns the start/end angles for the gauge at the specified activeGaugeIndex, where the index
  indicates the gauge's index (in a clockwise direction) within the active gauges for the left
  or right edges.
  E.g. if both the AC input and solar gauges are active, the index of the AC input gauge is 1,
  since it is the second gauge when listing the left gauges in a clockwise direction. If the
  solar gauge was not active, the index would be 0 instead.
*/
function sideGaugeParameters(baseAngle, activeGaugeCount, activeGaugeIndex, isMultiPhase) {
	// Start/end angles are those for the large single-gauge case if there is only one gauge,
	// otherwise this angle is split into equal segments for each active gauge (minus spacing).
	let maxSideAngle
	let baseAngleOffset
	if (activeGaugeCount === 1) {
		maxSideAngle = V.Theme.geometry_briefPage_largeEdgeGauge_maxAngle
		baseAngleOffset = 0
	} else {
		const totalSpacingAngle = V.Theme.geometry_briefPage_edgeGauge_spacingAngle * (activeGaugeCount - 1)
		maxSideAngle = (V.Theme.geometry_briefPage_largeEdgeGauge_maxAngle - totalSpacingAngle) / activeGaugeCount
		baseAngleOffset = V.Theme.geometry_briefPage_edgeGauge_spacingAngle * activeGaugeIndex
	}
	const gaugeStartAngle = baseAngle + (activeGaugeIndex * maxSideAngle) + baseAngleOffset
	const gaugeEndAngle = gaugeStartAngle + maxSideAngle

	let angleOffset = 0
	let phaseLabelHorizontalMargin = 0
	if (isMultiPhase) {
		// If this is a multi-phase gauge, SideMultiGauge will be used instead of SideGauge.
		// Since SideMultiGauge shows 1,2,3 labels beneath the gauges, provide an angleOffset
		// for adjusting the arc angle to make room for the labels. Also provide the edge margin
		// to horizontally align each gauge label with its gauge.
		angleOffset = activeGaugeCount === 1 ? V.Theme.geometry_briefPage_edgeGauge_angleOffset_one_gauge
				: activeGaugeCount === 2 ? V.Theme.geometry_briefPage_edgeGauge_angleOffset_two_gauge
				: V.Theme.geometry_briefPage_edgeGauge_angleOffset_three_gauge
		phaseLabelHorizontalMargin = activeGaugeCount === 1 ? V.Theme.geometry_briefPage_edgeGauge_phaseLabel_horizontalMargin_one_gauge
				: activeGaugeCount === 2 ? V.Theme.geometry_briefPage_edgeGauge_phaseLabel_horizontalMargin_two_gauge
				: V.Theme.geometry_briefPage_edgeGauge_phaseLabel_horizontalMargin_three_gauge
	}

	return {
		start: gaugeStartAngle,
		end: gaugeEndAngle,
		angleOffset: angleOffset,
		phaseLabelHorizontalMargin: phaseLabelHorizontalMargin,
		activeGaugeCount: activeGaugeCount
	}
}

function gaugeHeight(gaugeCount) {
	return V.Theme.geometry_briefPage_largeEdgeGauge_height / gaugeCount
}

function leftGaugeParameters(gaugeIndex, gaugeCount, isMultiPhase = false) {
	// Store gaugeCount in a temporary var, as it may change value unexpectedly during the
	// function call if it is updated via its property binding.
	const activeGaugeCount = gaugeCount
	const _gaugeHeight = gaugeHeight(activeGaugeCount)

	// In a clockwise direction, the gauges start from the bottom left (eg. solar gauge on the brief page)
	// and go upwards to the top left (eg. AC input gauge on the brief page).
	const baseAngle = 270 - (V.Theme.geometry_briefPage_largeEdgeGauge_maxAngle / 2)

	const params = sideGaugeParameters(baseAngle, activeGaugeCount, gaugeIndex, isMultiPhase)

	// Add y offset if gauge is aligned to the top or bottom.
	let arcVerticalCenterOffset = 0
	if (activeGaugeCount === 2) {
		arcVerticalCenterOffset = gaugeIndex === 0 ? -(_gaugeHeight / 2) : _gaugeHeight / 2
	} else if (activeGaugeCount === 3) {
		// The second (center) gauge does not need an offset, as it will be vertically centered.
		if (gaugeIndex === 0) {
			arcVerticalCenterOffset = -_gaugeHeight
		} else if (gaugeIndex === 2) {
			arcVerticalCenterOffset = _gaugeHeight
		}
	}
	return Object.assign(params, { arcVerticalCenterOffset: arcVerticalCenterOffset })
}

function rightGaugeParameters(gaugeIndex, gaugeCount, isMultiPhase = false) {
	// Store gaugeCount in a temporary var, as it may change value unexpectedly during the
	// function call if it is updated via its property binding.
	const activeGaugeCount = gaugeCount
	const _gaugeHeight = gaugeHeight(activeGaugeCount)

	// In a clockwise direction, the gauges start from the top right (eg. AC load gauge on the brief page)
	// and go downwards to the bottom right (eg. DC load gauge on the brief page).
	const baseAngle = 90 - (V.Theme.geometry_briefPage_largeEdgeGauge_maxAngle / 2)
	const params = sideGaugeParameters(baseAngle, activeGaugeCount, gaugeIndex, isMultiPhase)

	// Add y offset if gauge is aligned to the top or bottom.
	let arcVerticalCenterOffset = 0
	if (activeGaugeCount === 2) {
		arcVerticalCenterOffset = gaugeIndex === 0 ? _gaugeHeight / 2 : -(_gaugeHeight / 2)
	}
	return Object.assign(params, { arcVerticalCenterOffset: arcVerticalCenterOffset })
}

