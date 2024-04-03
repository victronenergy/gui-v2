/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Gauges

SwipeViewPage {
	id: root

	property real _gaugeArcMargin: Theme.geometry_briefPage_edgeGauge_initialize_margin
	property real _gaugeLabelMargin: Theme.geometry_briefPage_edgeGauge_label_initialize_margin
	property real _gaugeArcOpacity: 0
	property real _gaugeLabelOpacity: 0
	readonly property string _inputsIconSource: {
		const totalInputs = (Global.acInputs.activeInput != null ? 1 : 0)
				+ Global.dcInputs.model.count
		if (totalInputs <= 1) {
			if (Global.acInputs.activeInput != null) {
				return Global.acInputs.sourceIcon(Global.acInputs.activeInput.source)
			} else if (Global.dcInputs.model.count > 0) {
				return VenusOS.dcInputIcon(Global.dcInputs.model.deviceAt(0).source)
			}
		}
		return "qrc:/images/icon_input_24.svg"
	}

	/*
	  Returns the start/end angles for the gauge at the specified activeGaugeIndex, where the index
	  indicates the gauge's index (in a clockwise direction) within the active gauges for the left
	  or right edges.
	  E.g. if both the AC input and solar gauges are active, the index of the AC input gauge is 1,
	  since it is the second gauge when listing the left gauges in a clockwise direction. If the
	  solar gauge was not active, the index would be 0 instead.
	*/
	function sideGaugeParameters(baseAngle, activeGaugeCount, activeGaugeIndex) {
		// Start/end angles are those for the large single-gauge case if there is only one gauge,
		// otherwise this angle is split into equal segments for each active gauge (minus spacing).
		let maxSideAngle
		let baseAngleOffset
		if (activeGaugeCount === 1) {
			maxSideAngle = Theme.geometry_briefPage_largeEdgeGauge_maxAngle
			baseAngleOffset = 0
		} else {
			const totalSpacingAngle = Theme.geometry_briefPage_edgeGauge_spacingAngle * (activeGaugeCount - 1)
			maxSideAngle = (Theme.geometry_briefPage_largeEdgeGauge_maxAngle - totalSpacingAngle) / activeGaugeCount
			baseAngleOffset = Theme.geometry_briefPage_edgeGauge_spacingAngle * activeGaugeIndex
		}
		const gaugeStartAngle = baseAngle + (activeGaugeIndex * maxSideAngle) + baseAngleOffset
		const gaugeEndAngle = gaugeStartAngle + maxSideAngle

		// Gauge height is the height for the single-gauge case, split into equal segments for each
		// active gauge.
		let gaugeHeight
		if (activeGaugeCount === 1) {
			gaugeHeight = Theme.geometry_briefPage_largeEdgeGauge_height
		} else {
			const totalSpacing = Theme.geometry_briefPage_edgeGauge_spacing * (activeGaugeCount - 1)
			gaugeHeight = (Theme.geometry_briefPage_largeEdgeGauge_height - totalSpacing) / activeGaugeCount
		}

		return { start: gaugeStartAngle, end: gaugeEndAngle, height: gaugeHeight }
	}

	function leftGaugeParameters(gauge) {
		// In a clockwise direction, the gauges start from the solar gauge and go upwards to the AC
		// input gauge.
		const baseAngle = 270 - (Theme.geometry_briefPage_largeEdgeGauge_maxAngle / 2)
		const activeGaugeCount = (acInputGauge.active ? 1 : 0) + (solarYieldGauge.active ? 1 : 0)
		const gaugeIndex = gauge === solarYieldGauge ? 0 : (solarYieldGauge.active ? 1 : 0)
		const params = sideGaugeParameters(baseAngle, activeGaugeCount, gaugeIndex)

		const verticalAlignment = activeGaugeCount === 1
				? Qt.AlignVCenter
				: (gaugeIndex === 0 ? Qt.AlignBottom : Qt.AlignTop)
		return Object.assign(params, { alignment: Qt.AlignLeft | verticalAlignment })
	}

	function rightGaugeParameters(gauge) {
		// In a clockwise direction, the gauges start from the AC load gauge and go downwards to the
		// DC load gauge.
		const activeGaugeCount = (acLoadGauge.active ? 1 : 0) + (dcLoadGauge.active ? 1 : 0)
		const baseAngle = 90 - (Theme.geometry_briefPage_largeEdgeGauge_maxAngle / 2)
		const gaugeIndex = gauge === acLoadGauge ? 0 : (acLoadGauge.active ? 1 : 0)
		const params = sideGaugeParameters(baseAngle, activeGaugeCount, gaugeIndex)

		const verticalAlignment = activeGaugeCount === 1
				? Qt.AlignVCenter
				: (gaugeIndex === 0 ? Qt.AlignTop : Qt.AlignBottom)
		return Object.assign(params, { alignment: Qt.AlignRight | verticalAlignment })
	}

	backgroundColor: Theme.color_briefPage_background
	fullScreenWhenIdle: true
	topLeftButton: VenusOS.StatusBar_LeftButton_ControlsInactive
	topRightButton: sidePanel.showing
			? VenusOS.StatusBar_RightButton_SidePanelActive
			: VenusOS.StatusBar_RightButton_SidePanelInactive

	Loader {
		id: mainGauge

		// vertically center to the unexpanded height of the page
		y: (Theme.geometry_screen_height - Theme.geometry_statusBar_height - Theme.geometry_navigationBar_height - height) / 2
		width: Theme.geometry_mainGauge_size
		height: width
		x: sidePanel.x/2 - width/2
		sourceComponent: Global.tanks.totalTankCount === 0 ? singleGauge : multiGauge
		onStatusChanged: if (status === Loader.Error) console.warn("Unable to load main gauge")
	}

	Component {
		id: multiGauge

		CircularMultiGauge {
			model: GaugeModel {
				sourceModel: Gauges.briefCentralGauges
				maximumGaugeCount: Theme.geometry_briefPage_centerGauge_maximumGaugeCount
			}
			animationEnabled: root.animationEnabled
			labelOpacity: root._gaugeLabelOpacity
			labelMargin: root._gaugeLabelMargin
		}
	}

	Component {
		id: singleGauge

		CircularSingleGauge {
			readonly property var properties: Gauges.tankProperties(VenusOS.Tank_Type_Battery)
			readonly property var battery: Global.batteries.system

			name: properties.name
			icon.source: battery.icon
			value: (!visible || isNaN(battery.stateOfCharge)) ? 0 : Math.round(battery.stateOfCharge)
			voltage: battery.voltage
			current: battery.current
			status: Gauges.getValueStatus(value, properties.valueType)
			caption: Global.batteries.timeToGoText(battery, VenusOS.Battery_TimeToGo_LongFormat)
			animationEnabled: root.animationEnabled
			shineAnimationEnabled: battery.mode === VenusOS.Battery_Mode_Charging && root.animationEnabled
		}
	}

	Loader {
		id: acInputGauge

		anchors {
			verticalCenter: mainGauge.verticalCenter
			verticalCenterOffset: solarYieldGauge.active ? -(height / 2) : 0
			left: parent.left
			leftMargin: Theme.geometry_briefPage_edgeGauge_horizontalMargin
			right: mainGauge.left
		}
		active: !!Global.acInputs.activeInput || Global.dcInputs.model.count > 0
		sourceComponent: SideGauge {
			readonly property var gaugeParams: root.leftGaugeParameters(acInputGauge)

			// AC input gauge progresses in clockwise direction (i.e. upwards).
			direction: PathArc.Clockwise
			startAngle: gaugeParams.start || 0
			endAngle: gaugeParams.end || 0
			height: gaugeParams.height || 0
			alignment: gaugeParams.alignment || 0

			x: root._gaugeArcMargin
			opacity: root._gaugeArcOpacity
			animationEnabled: root.animationEnabled
			value: !visible ? 0 : inputsRange.valueAsRatio * 100

			// Gauge color changes only apply when there is a maximum value.
			valueType: isNaN(inputsRange.maximumValue)
					   ? VenusOS.Gauges_ValueType_NeutralPercentage
					   : VenusOS.Gauges_ValueType_RisingPercentage

			AcInGaugeQuantityRow {
				id: acInGaugeQuantity

				alignment: parent.alignment
				icon.source: root._inputsIconSource
				leftMargin: root._gaugeLabelMargin - root._gaugeArcMargin
				opacity: root._gaugeLabelOpacity

				// AC and DC amp values cannot be combined. If there are both AC and DC values, show
				// Watts even if Amps is preferred.
				quantityLabel.unit: Global.systemSettings.electricalQuantity === VenusOS.Units_Amp
					&& ((Global.acInputs.current || 0) === 0 || (Global.dcInputs.current || 0) === 0)
					   ? VenusOS.Units_Amp
					   : VenusOS.Units_Watt
				quantityLabel.value: quantityLabel.unit === VenusOS.Units_Amp
					? (Global.acInputs.current || 0) === 0
					  ? Global.dcInputs.current
					  : Global.acInputs.current
					: Units.sumRealNumbers(Global.acInputs.power, Global.dcInputs.power)
			}

			ValueRange {
				id: inputsRange

				value: acInGaugeQuantity.quantityLabel.value

				// When showing current instead of power, set a max value to change the gauge colors
				// when the value approaches the currentLimit.
				maximumValue: acInGaugeQuantity.quantityLabel.unit === VenusOS.Units_Amp
					? Global.acInputs.currentLimit
					: NaN
			}
		}
		onStatusChanged: if (status === Loader.Error) console.warn("Unable to load AC input edge")
	}

	Loader {
		id: solarYieldGauge

		anchors {
			verticalCenter: mainGauge.verticalCenter
			verticalCenterOffset: acInputGauge.active ? (height / 2) : 0
			left: parent.left
			leftMargin: Theme.geometry_briefPage_edgeGauge_horizontalMargin
			right: mainGauge.left
		}
		active: Global.solarChargers.model.count > 0 || Global.pvInverters.model.count > 0
		sourceComponent: SolarYieldGauge {
			readonly property var gaugeParams: root.leftGaugeParameters(solarYieldGauge)

			// Solar gauge progresses in counter-clockwise direction (i.e. downwards).
			direction: PathArc.Counterclockwise
			startAngle: gaugeParams.end || 0
			endAngle: gaugeParams.start || 0
			height: gaugeParams.height || 0
			alignment: gaugeParams.alignment || 0

			x: root._gaugeArcMargin
			opacity: root._gaugeArcOpacity
			animationEnabled: root.animationEnabled

			ArcGaugeQuantityRow {
				alignment: parent.alignment
				icon.source: "qrc:/images/solaryield.svg"
				leftMargin: root._gaugeLabelMargin - root._gaugeArcMargin
				opacity: root._gaugeLabelOpacity
				quantityLabel.dataObject: Global.system.solar
			}
		}
		onStatusChanged: if (status === Loader.Error) console.warn("Unable to load solar yield gauge")
	}

	Loader {
		id: acLoadGauge

		anchors {
			verticalCenter: mainGauge.verticalCenter
			verticalCenterOffset: dcLoadGauge.active ? -(height / 2) : 0
			right: parent.right
			rightMargin: Theme.geometry_briefPage_edgeGauge_horizontalMargin
			left: mainGauge.right
		}
		active: !isNaN(Global.system.loads.acPower)
		sourceComponent: SideGauge {
			readonly property var gaugeParams: root.rightGaugeParameters(acLoadGauge)

			// AC load gauge progresses in counter-clockwise direction (i.e. upwards).
			direction: PathArc.Counterclockwise
			startAngle: gaugeParams.end || 0
			endAngle: gaugeParams.start || 0
			height: gaugeParams.height || 0
			alignment: gaugeParams.alignment || 0

			x: -root._gaugeArcMargin
			opacity: root._gaugeArcOpacity
			animationEnabled: root.animationEnabled
			value: !visible ? 0 : acLoadsRange.valueAsRatio * 100

			ArcGaugeQuantityRow {
				alignment: parent.alignment
				icon.source: dcLoadGauge.active ? "qrc:/images/acloads.svg" : "qrc:/images/consumption.svg"
				leftMargin: -root._gaugeLabelMargin + root._gaugeArcMargin
				opacity: root._gaugeLabelOpacity
				quantityLabel.dataObject: Global.system.ac.consumption
			}

			ValueRange {
				id: acLoadsRange
				value: root.visible ? Global.system.loads.acPower || 0 : 0
				maximumValue: Global.system.loads.maximumAcPower
			}
		}
		onStatusChanged: if (status === Loader.Error) console.warn("Unable to load AC load edge")
	}

	Loader {
		id: dcLoadGauge

		anchors {
			verticalCenter: mainGauge.verticalCenter
			verticalCenterOffset: acInputGauge.active ? (height / 2) : 0
			right: parent.right
			rightMargin: Theme.geometry_briefPage_edgeGauge_horizontalMargin
			left: mainGauge.right
		}
		active: !isNaN(Global.system.loads.dcPower)
		sourceComponent: SideGauge {
			readonly property var gaugeParams: root.rightGaugeParameters(dcLoadGauge)

			// DC load gauge progresses in counter-clockwise direction (i.e. upwards).
			direction: PathArc.Counterclockwise
			startAngle: gaugeParams.end || 0
			endAngle: gaugeParams.start || 0
			height: gaugeParams.height || 0
			alignment: gaugeParams.alignment || 0

			x: -root._gaugeArcMargin
			opacity: root._gaugeArcOpacity
			animationEnabled: root.animationEnabled
			value: visible ? dcLoadsRange.valueAsRatio * 100 : 0

			ArcGaugeQuantityRow {
				alignment: parent.alignment
				icon.source: "qrc:/images/dcloads.svg"
				leftMargin: -root._gaugeLabelMargin + root._gaugeArcMargin
				opacity: root._gaugeLabelOpacity
				quantityLabel.dataObject: Global.system.dc
			}

			ValueRange {
				id: dcLoadsRange
				value: root.visible ? Global.system.loads.dcPower || 0 : 0
			}
		}
		onStatusChanged: if (status === Loader.Error) console.warn("Unable to load DC load gauge")
	}

	Loader {
		id: sidePanel
		anchors {
			verticalCenter: mainGauge.verticalCenter
			verticalCenterOffset: Theme.geometry_briefPage_sidePanel_verticalCenterOffset
		}
		width: Theme.geometry_briefPage_sidePanel_width
		sourceComponent: BriefMonitorPanel {
			inputsIconSource: root._inputsIconSource
			animationEnabled: root.animationEnabled
		}

		// the brief monitor panel has animations which mess with the asynchronous heuristic
		// and cause the object hierarchy to take multiple seconds to load.
		asynchronous: false

		// hidden by default.
		active: false
		x: root.width
		opacity: 0.0
		property bool showing // intermediate, used only to trigger loading.
		property bool showingAndLoaded: showing && active && status == Loader.Ready
		onShowingChanged: if (showing) active = true // trigger creation.
	}

	Connections {
		target: !!Global.pageManager ? Global.pageManager.statusBar : null
		enabled: root.isCurrentPage

		function onRightButtonClicked() {
			sidePanel.showing = !sidePanel.showing
		}
	}

	states: [
		State {
			name: "initialized"
			when: !Global.splashScreenVisible && !sidePanel.showingAndLoaded
			PropertyChanges {
				target: root
				_gaugeArcMargin: 0
				_gaugeLabelMargin: 0
				_gaugeArcOpacity: 1
				_gaugeLabelOpacity: 1
			}
		},
		State {
			name: "panelOpen"
			extend: "initialized"
			when: sidePanel.showingAndLoaded
			PropertyChanges {
				target: sidePanel
				x: root.width - sidePanel.width - Theme.geometry_page_content_horizontalMargin
				opacity: 1
			}
			PropertyChanges {
				target: root
				_gaugeArcOpacity: 0
				_gaugeLabelOpacity: 1
			}
		}
	]

	transitions: [
		Transition {
			from: ""
			to: "initialized"
			SequentialAnimation {
				ParallelAnimation {
					NumberAnimation {
						target: root
						properties: "_gaugeArcOpacity,_gaugeArcMargin"
						duration: Theme.animation_briefPage_gaugeArc_initialize_duration
					}
					SequentialAnimation {
						PauseAnimation {
							duration: Theme.animation_briefPage_gaugeLabel_initialize_delayedStart_duration
						}
						NumberAnimation {
							target: root
							properties: "_gaugeLabelOpacity,_gaugeLabelMargin"
							duration: Theme.animation_briefPage_gaugeLabel_initialize_duration
						}
					}
				}
			}
		},
		Transition {
			to: "panelOpen"
			from: "initialized"
			SequentialAnimation {
				NumberAnimation {
					target: root
					properties: "_gaugeArcOpacity,_gaugeLabelOpacity"
					duration: Theme.animation_briefPage_edgeGauge_fade_duration
				}
				NumberAnimation {
					target: sidePanel
					properties: 'x,opacity'
					duration: Theme.animation_briefPage_sidePanel_slide_duration
					easing.type: Easing.InQuad
				}
			}
		},
		Transition {
			to: "initialized"
			from: "panelOpen"
			SequentialAnimation {
				NumberAnimation {
					target: sidePanel
					properties: 'x,opacity'
					duration: Theme.animation_briefPage_sidePanel_slide_duration
					easing.type: Easing.InQuad
				}
				NumberAnimation {
					target: root
					properties: "_gaugeArcOpacity,_gaugeLabelOpacity"
					duration: Theme.animation_briefPage_edgeGauge_fade_duration
				}
				ScriptAction { script: sidePanel.active = false }
			}
		}
	]
}
