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
	readonly property string _dcInputIconSource: Global.dcInputs.inputTypeIcon(Global.dcInputs.model.firstObject?.inputType)

	readonly property int _leftGaugeCount: (acInputGauge.active ? 1 : 0) + (dcInputGauge.active ? 1 : 0) + (solarYieldGauge.active ? 1 : 0)
	readonly property int _rightGaugeCount: dcLoadGauge.active ? 2 : 1  // AC load gauge is always active
	readonly property real _unexpandedHeight: Theme.geometry_screen_height - Theme.geometry_statusBar_height - Theme.geometry_navigationBar_height

	property bool _readyToInit: state === "" && !Global.splashScreenVisible
	on_ReadyToInitChanged: {
		if (_readyToInit) {
			_readyToInit = false    // break the binding
			state = "initialized"
			if (showSidePanel) {
				state = "panelOpening"
			}
		}
	}

	// Used by StartPageConfiguration when this is the start page.
	property bool showSidePanel
	onShowSidePanelChanged: {
		if (showSidePanel && state === "initialized") {
			state = "panelOpening"
		} else if (!showSidePanel && state === "panelOpened") {
			state = "initialized"
		}
	}

	// Do not animate gauge progress changes while the left/right side gauge layouts are changing.
	on_LeftGaugeCountChanged: pauseLeftGaugeAnimations.restart()
	on_RightGaugeCountChanged: pauseRightGaugeAnimations.restart()

	navButtonText: CommonWords.brief_page
	navButtonIcon: "qrc:/images/brief.svg"
	url: "qrc:/qt/qml/Victron/VenusOS/pages/BriefPage.qml"
	backgroundColor: Theme.color_briefPage_background
	fullScreenWhenIdle: true
	topLeftButton: VenusOS.StatusBar_LeftButton_ControlsInactive
	topRightButton: sidePanel.active && state !== "panelOpening"
			? VenusOS.StatusBar_RightButton_SidePanelActive
			: VenusOS.StatusBar_RightButton_SidePanelInactive

	GaugeModel {
		id: gaugeModel
	}

	Loader {
		id: mainGauge

		y: (root._unexpandedHeight - height) / 2
		width: Theme.geometry_mainGauge_size
		height: width
		x: sidePanel.x/2 - width/2
		sourceComponent: gaugeModel.count === 0 ? singleGauge : multiGauge
		onStatusChanged: if (status === Loader.Error) console.warn("Unable to load main gauge")
	}

	Component {
		id: multiGauge

		CircularMultiGauge {
			model: gaugeModel
			animationEnabled: root.animationEnabled
			labelOpacity: root._gaugeLabelOpacity
			labelMargin: root._gaugeLabelMargin
			leftGaugeCount: root._leftGaugeCount

			BriefCenterDisplay {
				anchors.centerIn: parent
				width: parent.width
				visible: gaugeModel.count <= 3
				showFullDetails: gaugeModel.count === 1
				smallTextMode: gaugeModel.count === 3
			}
		}
	}

	Component {
		id: singleGauge

		CircularSingleGauge {
			readonly property var properties: Gauges.tankProperties(VenusOS.Tank_Type_Battery)
			readonly property var battery: Global.system.battery

			value: visible && !isNaN(battery.stateOfCharge) ? battery.stateOfCharge : 0
			status: Theme.getValueStatus(value, properties.valueType)
			animationEnabled: root.animationEnabled
			shineAnimationEnabled: battery.mode === VenusOS.Battery_Mode_Charging && root.animationEnabled

			BriefCenterDisplay {
				anchors.centerIn: parent
				width: parent.width
				showFullDetails: true
			}
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
			height: active ? Gauges.gaugeHeight(root._leftGaugeCount) : 0

			// Similarly to the Overview page, show the AC input, even when it is not connected, as
			// long as one of the AC input sources are valid.
			active: Global.acInputs.findValidSource() !== VenusOS.AcInputs_InputSource_NotAvailable && root.state !== "panelOpened"

			sourceComponent: SideMultiGauge {
				readonly property var gaugeParams: Gauges.leftGaugeParameters(
													   (solarYieldGauge.active ? 1 : 0) + (dcInputGauge.active ? 1 : 0),
													   _leftGaugeCount,
													   phaseModel && phaseModel.count > 1)
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
				phaseModel: Global.acInputs.highlightedInput?.phases
				phaseModelProperty: "current"
				minimumValue: !!Global.acInputs.highlightedInput ? Global.acInputs.highlightedInput.inputInfo.minimumCurrent : NaN
				maximumValue: !!Global.acInputs.highlightedInput ? Global.acInputs.highlightedInput.inputInfo.maximumCurrent : NaN
				inputMode: true

				AcInputDirectionIcon {
					id: acInputDirectionIcon
					anchors {
						left: acInGaugeQuantity.left
						bottom: acInGaugeQuantity.top
						bottomMargin: Theme.geometry_briefPage_edgeGauge_quantityLabel_feedback_margin
					}
					input: Global.acInputs.highlightedInput
				}

				ArcGaugeQuantityRow {
					id: acInGaugeQuantity

					// When >= 2 left gauges, AC input is always the top one, so label aligns to
					// the bottom.
					alignment: Qt.AlignLeft | (gaugeParams.activeGaugeCount >= 2 ? Qt.AlignBottom : Qt.AlignVCenter)
					icon.source: Global.acInputs.sourceIcon(Global.acInputs.highlightedInput?.source ?? Global.acInputs.findValidSource())
					leftPadding: root._gaugeLabelMargin - root._gaugeArcMargin
					opacity: root._gaugeLabelOpacity
					quantityLabel.dataObject: Global.acInputs.highlightedInput
					quantityLabel.acInputMode: true
				}
			}
			onStatusChanged: if (status === Loader.Error) console.warn("Unable to load AC input edge")
		}

		Loader {
			id: dcInputGauge

			width: Theme.geometry_briefPage_edgeGauge_width
			height: active ? Gauges.gaugeHeight(root._leftGaugeCount) : 0
			active: Global.dcInputs.model.count > 0 && root.state !== "panelOpened"
			sourceComponent: SideGauge {
				readonly property var gaugeParams: Gauges.leftGaugeParameters(solarYieldGauge.active ? 1 : 0, _leftGaugeCount)

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
			height: active ? Gauges.gaugeHeight(root._leftGaugeCount) : 0
			active: (Global.solarDevices.model.count > 0 || Global.pvInverters.model.count > 0) && root.state !== "panelOpened"
			sourceComponent: SolarYieldGauge {
				readonly property var gaugeParams: Gauges.leftGaugeParameters(0, _leftGaugeCount)

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
			height: Gauges.gaugeHeight(root._rightGaugeCount)
			active: root.state !== "panelOpened"

			sourceComponent: SideMultiGauge {
				readonly property var gaugeParams: Gauges.rightGaugeParameters(0, _rightGaugeCount, phaseModel.count > 1)
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
				phaseModel: Global.system.load.ac.phases
				phaseModelProperty: "current"
				maximumValue: Global.system.load.maximumAcCurrent

				ArcGaugeQuantityRow {
					alignment: Qt.AlignRight | (gaugeParams.activeGaugeCount === 2 ? Qt.AlignBottom : Qt.AlignVCenter)
					icon.source: dcLoadGauge.active ? "qrc:/images/acloads.svg" : "qrc:/images/consumption.svg"
					rightPadding: root._gaugeLabelMargin - root._gaugeArcMargin
					opacity: root._gaugeLabelOpacity
					quantityLabel.dataObject: Global.system.load.ac
				}
			}
			onStatusChanged: if (status === Loader.Error) console.warn("Unable to load AC load edge")
		}

		Loader {
			id: dcLoadGauge

			width: Theme.geometry_briefPage_edgeGauge_width
			height: active ? Gauges.gaugeHeight(root._rightGaugeCount) : 0
			active: !isNaN(Global.system.dc.power) && root.state !== "panelOpened"
			sourceComponent: SideGauge {
				readonly property var gaugeParams: Gauges.rightGaugeParameters(1, _rightGaugeCount)

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
					value: root.visible ? Global.system.dc.power || 0 : 0
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
	}

	Connections {
		target: !!Global.pageManager ? Global.pageManager.statusBar : null
		enabled: root.isCurrentPage

		function onRightButtonClicked() {
			root.showSidePanel = !root.showSidePanel
		}
	}

	CpuInfo {
		enabled: root.isCurrentPage && root.state === "panelOpened"
		upperLimit: 90
		lowerLimit: 50
		onOverLimitChanged: {
			if (overLimit) {
				//% "System load high, closing the side panel to reduce CPU load"
				Global.showToastNotification(VenusOS.Notification_Warning, qsTrId("nav_brief_close_side_panel_high_cpu"))
				root.state = "initialized"
			}
		}
	}

	states: [
		State {
			name: "initialized"
			PropertyChanges {
				target: root
				_gaugeArcMargin: 0
				_gaugeLabelMargin: 0
				_gaugeArcOpacity: 1
				_gaugeLabelOpacity: 1
			}
		},
		State {
			name: "panelOpening"
			extend: "initialized"
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
			StateChangeScript { script: sidePanel.active = true }
		},
		State {
			name: "panelOpened"
			extend: "panelOpening"
		}
	]

	transitions: [
		Transition {
			from: ""
			to: "initialized"
			enabled: Global.allPagesLoaded
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
			to: "panelOpening"
			from: "initialized"
			enabled: Global.allPagesLoaded
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
				ScriptAction { script: root.state = "panelOpened" }
			}
		},
		Transition {
			to: "initialized"
			from: "panelOpened"
			enabled: Global.allPagesLoaded
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
