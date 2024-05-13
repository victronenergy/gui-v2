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
	readonly property string _dcInputIconSource: Global.dcInputs.model.count === 1
		 ? Global.dcInputs.inputTypeIcon(Global.dcInputs.model.firstObject.inputType)
		 : "qrc:/images/icon_dc_24.svg"

	readonly property int _leftGaugeCount: (acInputGauge.active ? 1 : 0) + (dcInputGauge.active ? 1 : 0) + (solarYieldGauge.active ? 1 : 0)
	readonly property int _rightGaugeCount: dcLoadGauge.active ? 2 : 1  // AC load gauge is always active

	readonly property real _unexpandedHeight: Theme.geometry_screen_height - Theme.geometry_statusBar_height - Theme.geometry_navigationBar_height

	// Do not animate gauge progress changes while the left/right side gauge layouts are changing.
	on_LeftGaugeCountChanged: pauseLeftGaugeAnimations.restart()
	on_RightGaugeCountChanged: pauseRightGaugeAnimations.restart()

	function _gaugeHeight(gaugeCount) {
		return Theme.geometry_briefPage_largeEdgeGauge_height / gaugeCount
	}

	/*
	  Returns the start/end angles for the gauge at the specified activeGaugeIndex, where the index
	  indicates the gauge's index (in a clockwise direction) within the active gauges for the left
	  or right edges.
	  E.g. if both the AC input and solar gauges are active, the index of the AC input gauge is 1,
	  since it is the second gauge when listing the left gauges in a clockwise direction. If the
	  solar gauge was not active, the index would be 0 instead.
	*/
	function _sideGaugeParameters(baseAngle, activeGaugeCount, activeGaugeIndex, isMultiPhase) {
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

		let angleOffset = 0
		let phaseLabelHorizontalMargin = 0
		if (isMultiPhase) {
			// If this is a multi-phase gauge, SideMultiGauge will be used instead of SideGauge.
			// Since SideMultiGauge shows 1,2,3 labels beneath the gauges, provide an angleOffset
			// for adjusting the arc angle to make room for the labels. Also provide the edge margin
			// to horizontally align each gauge label with its gauge.
			angleOffset = activeGaugeCount === 1 ? Theme.geometry_briefPage_edgeGauge_angleOffset_one_gauge
					: activeGaugeCount === 2 ? Theme.geometry_briefPage_edgeGauge_angleOffset_two_gauge
					: Theme.geometry_briefPage_edgeGauge_angleOffset_three_gauge
			phaseLabelHorizontalMargin = activeGaugeCount === 1 ? Theme.geometry_briefPage_edgeGauge_phaseLabel_horizontalMargin_one_gauge
					: activeGaugeCount === 2 ? Theme.geometry_briefPage_edgeGauge_phaseLabel_horizontalMargin_two_gauge
					: Theme.geometry_briefPage_edgeGauge_phaseLabel_horizontalMargin_three_gauge
		}

		return {
			start: gaugeStartAngle,
			end: gaugeEndAngle,
			angleOffset: angleOffset,
			phaseLabelHorizontalMargin: phaseLabelHorizontalMargin,
			activeGaugeCount: activeGaugeCount
		}
	}

	function _leftGaugeParameters(gauge, isMultiPhase = false) {
		// Store _leftGaugeCount in a temporary var, as it may change value unexpectedly during the
		// function call if it is updated via its property binding.
		const activeGaugeCount = _leftGaugeCount
		const gaugeHeight = _gaugeHeight(activeGaugeCount)

		// In a clockwise direction, the gauges start from the solar gauge and go upwards to the AC
		// input gauge.
		const baseAngle = 270 - (Theme.geometry_briefPage_largeEdgeGauge_maxAngle / 2)
		let gaugeIndex = 0  // solar yield gauge has index=0
		if (gauge === dcInputGauge) {
			gaugeIndex = solarYieldGauge.active ? 1 : 0
		} else if (gauge === acInputGauge) {
			gaugeIndex = (solarYieldGauge.active ? 1 : 0) + (dcInputGauge.active ? 1 : 0)
		}
		const params = _sideGaugeParameters(baseAngle, activeGaugeCount, gaugeIndex, isMultiPhase)

		// Add y offset if gauge is aligned to the top or bottom.
		let arcVerticalCenterOffset = 0
		if (activeGaugeCount === 2) {
			arcVerticalCenterOffset = gaugeIndex === 0 ? -(gaugeHeight / 2) : gaugeHeight / 2
		} else if (activeGaugeCount === 3) {
			// The second (center) gauge does not need an offset, as it will be vertically centered.
			if (gaugeIndex === 0) {
				arcVerticalCenterOffset = -gaugeHeight
			} else if (gaugeIndex === 2) {
				arcVerticalCenterOffset = gaugeHeight
			}
		}
		return Object.assign(params, { arcVerticalCenterOffset: arcVerticalCenterOffset })
	}

	function _rightGaugeParameters(gauge, isMultiPhase = false) {
		// Store _rightGaugeCount in a temporary var, as it may change value unexpectedly during the
		// function call if it is updated via its property binding.
		const activeGaugeCount = _rightGaugeCount
		const gaugeHeight = _gaugeHeight(activeGaugeCount)

		// In a clockwise direction, the gauges start from the AC load gauge and go downwards to the
		// DC load gauge.
		const baseAngle = 90 - (Theme.geometry_briefPage_largeEdgeGauge_maxAngle / 2)
		const gaugeIndex = gauge === acLoadGauge ? 0 : 1
		const params = _sideGaugeParameters(baseAngle, activeGaugeCount, gaugeIndex, isMultiPhase)

		// Add y offset if gauge is aligned to the top or bottom.
		let arcVerticalCenterOffset = 0
		if (activeGaugeCount === 2) {
			arcVerticalCenterOffset = gaugeIndex === 0 ? gaugeHeight / 2 : -(gaugeHeight / 2)
		}
		return Object.assign(params, { arcVerticalCenterOffset: arcVerticalCenterOffset })
	}

	//% "Brief"
	navButtonText: qsTrId("nav_brief")
	navButtonIcon: "qrc:/images/brief.svg"
	url: "qrc:/qt/qml/Victron/VenusOS/pages/BriefPage.qml"
	backgroundColor: Theme.color_briefPage_background
	fullScreenWhenIdle: true
	topLeftButton: VenusOS.StatusBar_LeftButton_ControlsInactive
	topRightButton: sidePanel.showing
			? VenusOS.StatusBar_RightButton_SidePanelActive
			: VenusOS.StatusBar_RightButton_SidePanelInactive

	Loader {
		id: mainGauge

		y: (root._unexpandedHeight - height) / 2
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
			leftGaugeCount: root._leftGaugeCount
		}
	}

	Component {
		id: singleGauge

		CircularSingleGauge {
			readonly property var properties: Gauges.tankProperties(VenusOS.Tank_Type_Battery)
			readonly property var battery: Global.batteries.system

			name: properties.name
			icon.source: battery.icon
			value: visible && !isNaN(battery.stateOfCharge) ? battery.stateOfCharge : 0
			voltage: battery.voltage
			current: battery.current
			status: Gauges.getValueStatus(value, properties.valueType)
			caption: Global.batteries.timeToGoText(battery, VenusOS.Battery_TimeToGo_LongFormat)
			animationEnabled: root.animationEnabled
			shineAnimationEnabled: battery.mode === VenusOS.Battery_Mode_Charging && root.animationEnabled
		}
	}

	// Left gauge column
	Column {
		anchors {
			verticalCenter: mainGauge.verticalCenter
			left: parent.left
			leftMargin: Theme.geometry_briefPage_edgeGauge_horizontalMargin
		}
		width: Theme.geometry_briefPage_edgeGauge_width

		Loader {
			id: acInputGauge

			width: Theme.geometry_briefPage_edgeGauge_width
			height: active ? root._gaugeHeight(root._leftGaugeCount) : 0

			// Similarly to the Overview page, show the AC input, even when it is not connected, as
			// long as one of the AC input sources are valid.
			active: Global.acInputs.findValidSource() !== VenusOS.AcInputs_InputSource_NotAvailable

			sourceComponent: SideMultiGauge {
				readonly property var gaugeParams: root._leftGaugeParameters(acInputGauge, phaseModel && phaseModel.count > 1)
				readonly property real startAngleOffset: gaugeParams.angleOffset

				// AC input gauge progresses in clockwise direction (i.e. upwards).
				direction: PathArc.Clockwise
				startAngle: gaugeParams.start + startAngleOffset
				endAngle: gaugeParams.end
				phaseLabelHorizontalMargin: gaugeParams.phaseLabelHorizontalMargin
				arcVerticalCenterOffset: gaugeParams.arcVerticalCenterOffset
				horizontalAlignment: Qt.AlignLeft

				x: root._gaugeArcMargin
				opacity: root._gaugeArcOpacity
				animationEnabled: root.animationEnabled && !pauseLeftGaugeAnimations.running
				valueType: VenusOS.Gauges_ValueType_NeutralPercentage
				phaseModel: !!Global.acInputs.activeInput ? Global.acInputs.activeInput.phases : null
				phaseModelProperty: "current"
				minimumValue: !!Global.acInputs.activeInputInfo ? Global.acInputs.activeInputInfo.minimumCurrent : NaN
				maximumValue: !!Global.acInputs.activeInputInfo ? Global.acInputs.activeInputInfo.maximumCurrent : NaN
				inputMode: true

				AcInputDirectionIcon {
					id: acInputDirectionIcon
					anchors {
						left: acInGaugeQuantity.left
						bottom: acInGaugeQuantity.top
						bottomMargin: Theme.geometry_briefPage_edgeGauge_quantityLabel_feedback_margin
					}
				}

				ArcGaugeQuantityRow {
					id: acInGaugeQuantity

					// When >= 2 left gauges, AC input is always the top one, so label aligns to
					// the bottom.
					alignment: Qt.AlignLeft | (gaugeParams.activeGaugeCount >= 2 ? Qt.AlignBottom : Qt.AlignVCenter)
					icon.source: Global.acInputs.sourceIcon(Global.acInputs.findValidSource())
					leftPadding: root._gaugeLabelMargin - root._gaugeArcMargin
					opacity: root._gaugeLabelOpacity
					quantityLabel.dataObject: Global.acInputs.activeInput
					quantityLabel.acInputMode: true
				}
			}
			onStatusChanged: if (status === Loader.Error) console.warn("Unable to load AC input edge")
		}

		Loader {
			id: dcInputGauge

			width: Theme.geometry_briefPage_edgeGauge_width
			height: active ? root._gaugeHeight(root._leftGaugeCount) : 0
			active: Global.dcInputs.model.count > 0
			sourceComponent: SideGauge {
				readonly property var gaugeParams: root._leftGaugeParameters(dcInputGauge)

				// DC input gauge progresses in clockwise direction (i.e. upwards).
				direction: PathArc.Clockwise
				startAngle: gaugeParams.start
				endAngle: gaugeParams.end
				arcVerticalCenterOffset: gaugeParams.arcVerticalCenterOffset
				horizontalAlignment: Qt.AlignLeft

				x: root._gaugeArcMargin
				opacity: root._gaugeArcOpacity
				animationEnabled: root.animationEnabled && !pauseLeftGaugeAnimations.running
				valueType: VenusOS.Gauges_ValueType_NeutralPercentage
				value: visible ? dcInputRange.valueAsRatio * 100 : 0

				ArcGaugeQuantityRow {
					id: dcInGaugeQuantity
					alignment: gaugeParams.activeGaugeCount === 2
							// DC input gauge is the second (bottom) gauge, so label aligns to the
							// top, or is the first (top) gauge, so label aligns to the bottom.
							? Qt.AlignLeft | (acInputGauge.active ? Qt.AlignTop : Qt.AlignBottom)
							: Qt.AlignLeft| Qt.AlignVCenter
					icon.source: root._dcInputIconSource
					leftPadding: root._gaugeLabelMargin - root._gaugeArcMargin
					opacity: root._gaugeLabelOpacity
					quantityLabel.dataObject: Global.dcInputs
				}

				ValueRange {
					id: dcInputRange
					value: root.visible ? Global.dcInputs.power || 0 : 0
					maximumValue: Global.dcInputs.maximumPower
				}
			}
			onStatusChanged: if (status === Loader.Error) console.warn("Unable to load DC input edge")
		}

		Loader {
			id: solarYieldGauge

			width: Theme.geometry_briefPage_edgeGauge_width
			height: active ? root._gaugeHeight(root._leftGaugeCount) : 0
			active: Global.solarChargers.model.count > 0 || Global.pvInverters.model.count > 0
			sourceComponent: SolarYieldGauge {
				readonly property var gaugeParams: root._leftGaugeParameters(solarYieldGauge)

				// Solar gauge progresses in counter-clockwise direction (i.e. downwards).
				direction: PathArc.Counterclockwise
				startAngle: gaugeParams.end
				endAngle: gaugeParams.start
				arcVerticalCenterOffset: gaugeParams.arcVerticalCenterOffset
				horizontalAlignment: Qt.AlignLeft

				x: root._gaugeArcMargin
				opacity: root._gaugeArcOpacity
				animationEnabled: root.animationEnabled && !pauseLeftGaugeAnimations.running

				ArcGaugeQuantityRow {
					// When >= 2 left gauges, solar gauge is always the bottom one, so label aligns
					// to the top.
					alignment: Qt.AlignLeft | (gaugeParams.activeGaugeCount >= 2 ? Qt.AlignTop : Qt.AlignVCenter)
					icon.source: "qrc:/images/solaryield.svg"
					leftPadding: root._gaugeLabelMargin - root._gaugeArcMargin
					opacity: root._gaugeLabelOpacity
					quantityLabel.dataObject: Global.system.solar
				}
			}
			onStatusChanged: if (status === Loader.Error) console.warn("Unable to load solar yield gauge")
		}
	}

	// Right gauge column
	Column {
		anchors {
			verticalCenter: mainGauge.verticalCenter
			right: parent.right
			rightMargin: Theme.geometry_briefPage_edgeGauge_horizontalMargin
		}
		width: Theme.geometry_briefPage_edgeGauge_width

		Loader {
			id: acLoadGauge

			width: Theme.geometry_briefPage_edgeGauge_width
			height: root._gaugeHeight(root._rightGaugeCount)

			sourceComponent: SideMultiGauge {
				readonly property var gaugeParams: root._rightGaugeParameters(acLoadGauge, phaseModel.count > 1)
				readonly property real startAngleOffset: -gaugeParams.angleOffset

				// AC load gauge progresses in counter-clockwise direction (i.e. upwards).
				direction: PathArc.Counterclockwise
				startAngle: gaugeParams.end + startAngleOffset
				endAngle: gaugeParams.start
				phaseLabelHorizontalMargin: gaugeParams.phaseLabelHorizontalMargin
				arcVerticalCenterOffset: gaugeParams.arcVerticalCenterOffset
				horizontalAlignment: Qt.AlignRight

				x: -root._gaugeArcMargin
				opacity: root._gaugeArcOpacity
				animationEnabled: root.animationEnabled && !pauseRightGaugeAnimations.running
				valueType: VenusOS.Gauges_ValueType_RisingPercentage
				phaseModel: Global.system.ac.consumption.phases
				phaseModelProperty: "current"
				maximumValue: Global.system.ac.consumption.maximumCurrent

				ArcGaugeQuantityRow {
					alignment: Qt.AlignRight | (gaugeParams.activeGaugeCount === 2 ? Qt.AlignBottom : Qt.AlignVCenter)
					icon.source: dcLoadGauge.active ? "qrc:/images/acloads.svg" : "qrc:/images/consumption.svg"
					rightPadding: root._gaugeLabelMargin - root._gaugeArcMargin
					opacity: root._gaugeLabelOpacity
					quantityLabel.dataObject: Global.system.ac.consumption
				}
			}
			onStatusChanged: if (status === Loader.Error) console.warn("Unable to load AC load edge")
		}

		Loader {
			id: dcLoadGauge

			width: Theme.geometry_briefPage_edgeGauge_width
			height: active ? root._gaugeHeight(root._rightGaugeCount) : 0
			active: !isNaN(Global.system.loads.dcPower)
			sourceComponent: SideGauge {
				readonly property var gaugeParams: root._rightGaugeParameters(dcLoadGauge)

				// DC load gauge progresses in counter-clockwise direction (i.e. upwards).
				direction: PathArc.Counterclockwise
				startAngle: gaugeParams.end
				endAngle: gaugeParams.start
				arcVerticalCenterOffset: gaugeParams.arcVerticalCenterOffset
				horizontalAlignment: Qt.AlignRight

				x: -root._gaugeArcMargin
				opacity: root._gaugeArcOpacity
				animationEnabled: root.animationEnabled && !pauseRightGaugeAnimations.running
				valueType: VenusOS.Gauges_ValueType_RisingPercentage
				value: visible ? dcLoadsRange.valueAsRatio * 100 : 0

				ArcGaugeQuantityRow {
					alignment: Qt.AlignRight | (gaugeParams.activeGaugeCount === 2 ? Qt.AlignTop : Qt.AlignVCenter)
					icon.source: "qrc:/images/dcloads.svg"
					rightPadding: root._gaugeLabelMargin - root._gaugeArcMargin
					opacity: root._gaugeLabelOpacity
					quantityLabel.dataObject: Global.system.dc
				}

				ValueRange {
					id: dcLoadsRange
					value: root.visible ? Global.system.loads.dcPower || 0 : 0
					maximumValue: Global.system.dc.maximumPower
				}
			}
			onStatusChanged: if (status === Loader.Error) console.warn("Unable to load DC load gauge")
		}
	}

	Timer {
		id: pauseLeftGaugeAnimations
		interval: Theme.animation_progressArc_duration
	}

	Timer {
		id: pauseRightGaugeAnimations
		interval: Theme.animation_progressArc_duration
	}

	Loader {
		id: sidePanel
		width: Theme.geometry_briefPage_sidePanel_width
		sourceComponent: BriefSidePanel {
			width: parent.width
			height: Math.max(root._unexpandedHeight, implicitHeight)
			animationEnabled: root.animationEnabled
			dcInputIconSource: root._dcInputIconSource
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
