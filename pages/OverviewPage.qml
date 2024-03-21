/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

SwipeViewPage {
	id: root

	property var _leftWidgets: []
	readonly property var _centerWidgets: [inverterChargerWidget, batteryWidget]
	property var _rightWidgets: []

	// Preferred order for the input widgets on the left hand side
	readonly property var _leftWidgetOrder: [
		VenusOS.OverviewWidget_Type_AcGenericInput,
		VenusOS.OverviewWidget_Type_AcGeneratorInput,
		VenusOS.OverviewWidget_Type_DcGenerator,
		VenusOS.OverviewWidget_Type_Alternator,
		VenusOS.OverviewWidget_Type_FuelCell,
		VenusOS.OverviewWidget_Type_Wind,
		VenusOS.OverviewWidget_Type_Solar
	]

	// Set a counter that updates whenever the layout should change.
	// Use a delayed binding to avoid repopulating the model unnecessarily.
	readonly property int _shouldResetWidgets: Global.dcInputs.model.count
			+ Global.acInputs.input1Info.source
			+ Global.acInputs.input1Info.connected
			+ Global.acInputs.input2Info.source
			+ Global.acInputs.input2Info.connected
			+ (Global.dcLoads.model.count === 0 || isNaN(Global.system.loads.dcPower) ? 0 : 1)
			+ (Global.solarChargers.model.count === 0 ? 0 : 1)
			+ (Global.evChargers.model.count === 0 ? 0 : 1)
			+ (Global.pvInverters.model.count === 0 ? 0 : 1)
	on_ShouldResetWidgetsChanged: Qt.callLater(_resetWidgets)
	Component.onCompleted: Qt.callLater(_resetWidgets)

	property var _createdWidgets: ({})

	property bool _expandLayout: !!Global.pageManager && Global.pageManager.expandLayout
	property bool _animateGeometry: root.isCurrentPage && !!Global.pageManager && Global.pageManager.animatingIdleResize

	// Resets the layout, setting the y pos and height for all overview widgets. This is done once
	// imperatively, instead of using anchors or y/height bindings, so that widget connector path
	// calculations are also only done once; otherwise, the recalculation/repainting of the paths
	//  and path animations is very expensive and creates jerky animations on device.
	function _resetWidgets() {
		width = Theme.geometry_screen_width

		// Reset the left/right widgets that should be shown
		for (let widgetType in _createdWidgets) {
			_createdWidgets[widgetType].size = VenusOS.OverviewWidget_Size_Zero
		}
		_resetLeftWidgets()
		_resetRightWidgets()

		let i = 0
		let firstLargeWidget = null
		let preferLargeWidgetCount = 0
		let widget = null
		for (i = 0; i < _leftWidgets.length; ++i) {
			if (_leftWidgets[i].preferLargeSize) {
				if (!firstLargeWidget) {
					firstLargeWidget = _leftWidgets[i]
				}
				preferLargeWidgetCount++
			}
		}

		// Set the left widget sizes
		for (i = 0; i < _leftWidgets.length; ++i) {
			widget = _leftWidgets[i]
			switch (_leftWidgets.length) {
			case 1:
				widget.size = VenusOS.OverviewWidget_Size_XL
				break
			case 2:
				widget.size = VenusOS.OverviewWidget_Size_L
				break
			case 3:
				if (preferLargeWidgetCount === 3) {
					// If all three prefer L size, then use M for all three.
					widget.size = VenusOS.OverviewWidget_Size_M
				} else if (preferLargeWidgetCount >= 2) {
					// If only two prefer L size, then use L for the first one, M for the other,
					// and S for the last.
					if (widget.preferLargeSize) {
						widget.size = widget.preferLargeSize ? VenusOS.OverviewWidget_Size_L : VenusOS.OverviewWidget_Size_M
					} else {
						widget.size = VenusOS.OverviewWidget_Size_S
					}
				} else if (preferLargeWidgetCount === 1) {
					// Use size L for that one, and S for the others.
					widget.size = widget === firstLargeWidget ? VenusOS.OverviewWidget_Size_L : VenusOS.OverviewWidget_Size_S
				} else {
					// Reserve size L for the bottom widget, and use S for the others.
					widget.size = i === _leftWidgets.length - 1 ? VenusOS.OverviewWidget_Size_L : VenusOS.OverviewWidget_Size_S
				}
				break
			case 4:
				// Only one of the widgets can have L size, and the other ones use a reduced size.
				if (widget === firstLargeWidget) {
					widget.size = VenusOS.OverviewWidget_Size_L
				} else if (firstLargeWidget != null) {
					// There is a large widget, so use M or XS size to fit around it
					widget.size = _leftWidgets.length == 3 ? VenusOS.OverviewWidget_Size_M : VenusOS.OverviewWidget_Size_XS
				} else {
					// There are no large widgets; use the same size for all left widgets
					widget.size = _leftWidgets.length == 3 ? VenusOS.OverviewWidget_Size_M : VenusOS.OverviewWidget_Size_S
				}
				break
			default:
				widget.size = VenusOS.OverviewWidget_Size_XS
				break
			}
		}

		// Set right widget sizes. AC Loads is always present; AC & DC Loads are sized depending on
		// whether EVCS is visible.
		const evChargerWidget = _findWidget(_rightWidgets, VenusOS.OverviewWidget_Type_Evcs)
		if (!!evChargerWidget) {
			evChargerWidget.size = VenusOS.OverviewWidget_Size_L
		}
		dcLoadsWidget.size = Global.dcLoads.model.count > 0 || !isNaN(Global.system.loads.dcPower)
				? (!!evChargerWidget ? VenusOS.OverviewWidget_Size_XS : VenusOS.OverviewWidget_Size_L)
				: VenusOS.OverviewWidget_Size_Zero
		acLoadsWidget.size = dcLoadsWidget.size === VenusOS.OverviewWidget_Size_Zero
				? (!!evChargerWidget ? VenusOS.OverviewWidget_Size_L : VenusOS.OverviewWidget_Size_XL)
				: (!!evChargerWidget ? VenusOS.OverviewWidget_Size_XS : VenusOS.OverviewWidget_Size_L)

		// Set the widget positions
		resetWidgetPositions(_leftWidgets)
		resetWidgetPositions(_centerWidgets)
		resetWidgetPositions(_rightWidgets)

		// Initialize the widget connector geometry
		resetWidgetConnectors(_leftWidgets)
		resetWidgetConnectors(_centerWidgets)
		resetWidgetConnectors(_rightWidgets)
	}

	function resetWidgetConnectors(widgets) {
		for (let i = 0; i < widgets.length; ++i) {
			const connectors = widgets[i].connectors
			for (let j = 0; j < connectors.length; ++j) {
				// For all left widgets except for solar (which has two connectors), straighten the
				// connector if there is only one widget (as it will expand to full size).
				if (widgets === _leftWidgets) {
					connectors[j].straight = connectors.length === 1 && _leftWidgets.length === 1
				}
				connectors[j].reset()
			}
		}
	}

	function resetWidgetPositions(widgets) {
		let compactWidgetHeights = 0
		let expandedWidgetHeights = 0
		let i = 0
		let widget = null

		for (i = 0; i < widgets.length; ++i) {
			widget = widgets[i]
			compactWidgetHeights += widget.getCompactHeight(widget.size)
			expandedWidgetHeights += widget.getExpandedHeight(widget.size)
		}

		const compactPageHeight = Theme.geometry_screen_height
				- Theme.geometry_statusBar_height
				- Theme.geometry_navigationBar_height

		if (compactPageHeight !== Theme.geometry_overviewPage_widget_compact_xl_height) {
			console.log("Warning: theme constants need to be updated.")
		}
		const compactWidgetsTopMargin = Math.max(0, (compactPageHeight - compactWidgetHeights) / Math.max(1, widgets.length - 1))

		const expandedPageHeight = Theme.geometry_screen_height
				- Theme.geometry_statusBar_height
				- Theme.geometry_overviewPage_layout_expanded_bottomMargin
		if (expandedPageHeight !== Theme.geometry_overviewPage_widget_expanded_xl_height) {
			console.log("Warning: theme constants need to be updated.")
		}

		const expandedWidgetsTopMargin = Math.max(0, (expandedPageHeight - expandedWidgetHeights) / Math.max(1, widgets.length - 1))

		// Set widget y and height
		let prevWidget = null
		for (i = 0; i < widgets.length; ++i) {
			// Position each widget below the previous widget in this set.
			widget = widgets[i]
			if (i > 0) {
				prevWidget = widgets[i-1]
				widget.compactY = prevWidget.compactY + prevWidget.getCompactHeight(prevWidget.size) + compactWidgetsTopMargin
				widget.expandedY = prevWidget.expandedY + prevWidget.getExpandedHeight(prevWidget.size) + expandedWidgetsTopMargin
			} else {
				widget.compactY = 0
				widget.expandedY = 0
			}
		}

		// Set widget x and width
		for (i = 0; i < widgets.length; ++i) {
			widget = widgets[i]
			if (widgets === _leftWidgets) {
				widget.width = Theme.geometry_overviewPage_widget_leftWidgetWidth
				widget.x = Theme.geometry_page_content_horizontalMargin
			} else if (widgets === _centerWidgets) {
				widget.width = Theme.geometry_overviewPage_widget_centerWidgetWidth
				widget.x = root.width/2 - widget.width/2
			} else if (widgets === _rightWidgets) {
				widget.width = Theme.geometry_overviewPage_widget_rightWidgetWidth
				widget.x = root.width - widget.width - Theme.geometry_page_content_horizontalMargin
			}
		}
	}

	function _createWidget(type, args) {
		if (_createdWidgets[type] !== undefined) {
			return _createdWidgets[type]
		}
		args = args || {}
		let widget = null
		switch (type) {
		case VenusOS.OverviewWidget_Type_AcGenericInput:
			widget = acInputComponent.createObject(root, args)
			break
		case VenusOS.OverviewWidget_Type_AcGeneratorInput:
			widget = acInputComponent.createObject(root, Object.assign(args, { type: VenusOS.OverviewWidget_Type_AcGeneratorInput }))
			break
		case VenusOS.OverviewWidget_Type_Alternator:
			widget = alternatorComponent.createObject(root, args)
			break
		case VenusOS.OverviewWidget_Type_DcGenerator:
			widget = dcGeneratorComponent.createObject(root, args)
			break
		case VenusOS.OverviewWidget_Type_FuelCell:
			widget = dcInputComponent.createObject(root, args)
			break
		case VenusOS.OverviewWidget_Type_Evcs:
			widget = evcsComponent.createObject(root, args)
			break
		case VenusOS.OverviewWidget_Type_Solar:
			widget = solarComponent.createObject(root, args)
			break
		case VenusOS.OverviewWidget_Type_Wind:
			widget = windComponent.createObject(root, args)
			break
		default:
			console.warn('Cannot create widget of unsupported type:', type)
			return null
		}
		_createdWidgets[type] = widget
		return widget
	}

	function _resetLeftWidgets() {
		let widgetType = -1
		let widgetCandidates = []
		let widget
		let i

		const inputInfos = [ Global.acInputs.input1Info, Global.acInputs.input2Info ]
		for (i = 0; i < inputInfos.length; ++i) {
			const inputInfo = inputInfos[i]
			if (!inputInfo) {
				continue
			}
			switch (inputInfo.source) {
			// Valid AC inputs:
			case VenusOS.AcInputs_InputSource_Grid:
			case VenusOS.AcInputs_InputSource_Shore:
				widgetType = VenusOS.OverviewWidget_Type_AcGenericInput
				break
			case VenusOS.AcInputs_InputSource_Generator:
				widgetType = VenusOS.OverviewWidget_Type_AcGeneratorInput
				break
			// Not a valid AC input:
			case VenusOS.AcInputs_InputSource_NotAvailable:
			case VenusOS.AcInputs_InputSource_Inverting:
				continue
			default:
				console.warn("Unknown AC input source:", inputInfo.source)
				continue
			}
			if (widgetType >= 0) {
				widget = _createWidget(widgetType)
				widget.inputInfo = inputInfo
				widgetCandidates.splice(_leftWidgetInsertionIndex(widgetType, widgetCandidates), 0, widget)
			}
		}

		// Add DC widgets. Only one widget is added per DC type, regardless of the number of inputs
		// for that type.
		let clearedWidgets = []
		for (i = 0; i < Global.dcInputs.model.count; ++i) {
			// Add the input to the DC widget
			const dcInput = Global.dcInputs.model.deviceAt(i)
			widgetType = _dcWidgetTypeForInputType(dcInput.inputType)
			widget = _createWidget(widgetType)
			if (clearedWidgets.indexOf(widget) < 0) {
				// Ensure the layout starts with a clean list of inputs for this widget.
				widget.inputs.clear()
				clearedWidgets.push(widget)
			}
			widget.inputs.addDevice(dcInput)
			if (widgetCandidates.indexOf(widget) < 0) {
				// Only show one widget for each DC input type.
				widgetCandidates.splice(_leftWidgetInsertionIndex(widgetType, widgetCandidates), 0, widget)
			}
		}

		// Add solar widget
		if (Global.solarChargers.model.count > 0 || Global.pvInverters.model.count > 0) {
			widgetCandidates.splice(_leftWidgetInsertionIndex(VenusOS.OverviewWidget_Type_Solar, widgetCandidates),
					0, _createWidget(VenusOS.OverviewWidget_Type_Solar))
		}
		_leftWidgets = widgetCandidates
	}

	function _dcWidgetTypeForInputType(dcInputType) {
		switch (dcInputType) {
		case VenusOS.DcInputs_InputType_Alternator:
			return VenusOS.OverviewWidget_Type_Alternator
		case VenusOS.DcInputs_InputType_FuelCell:
			return VenusOS.OverviewWidget_Type_FuelCell
		case VenusOS.DcInputs_InputType_Wind:
			return VenusOS.OverviewWidget_Type_Wind
		default:
			// Use DC Generator as the catch-all type for any DC power source that isn't
			// specifically handled.
			return VenusOS.OverviewWidget_Type_DcGenerator
		}
	}

	function _leftWidgetInsertionIndex(widgetType, candidateArray) {
		const orderedIndex = _leftWidgetOrder.indexOf(widgetType)
		for (let i = 0; i < candidateArray.length; ++i) {
			if (orderedIndex < _leftWidgetOrder.indexOf(candidateArray[i].type)) {
				return i
			}
		}
		return candidateArray.length
	}

	function _resetRightWidgets() {
		let widgets = [acLoadsWidget]
		if (Global.evChargers.model.count > 0) {
			widgets.push(_createWidget(VenusOS.OverviewWidget_Type_Evcs))
		}
		if (Global.dcLoads.model.count > 0 || !isNaN(Global.system.loads.dcPower)) {
			widgets.push(dcLoadsWidget)
		}
		_rightWidgets = widgets
	}

	function _findWidget(widgets, widgetType) {
		for (let i = 0; i < widgets.length; ++i) {
			if (widgets[i].type === widgetType) {
				return widgets[i]
			}
		}
		return null
	}

	function _inputConnectorAnimationMode(connectorWidget) {
		if (!isCurrentPage) {
			return VenusOS.WidgetConnector_AnimationMode_NotAnimated
		}
		// Assumes startWidget is the AC/DC input widget.
		// Use the displayed power to calculate whether the connector should be animated.
		const power = !connectorWidget.startWidget.quantityLabel.dataObject ? NaN
				: connectorWidget.startWidget.quantityLabel.dataObject.power
		if (isNaN(power) || Math.abs(power) <= Theme.geometry_overviewPage_connector_animationPowerThreshold) {
			return VenusOS.WidgetConnector_AnimationMode_NotAnimated
		}

		if (connectorWidget.endWidget === inverterChargerWidget) {
			// For AC inputs, positive power means energy is flowing towards inverter/charger,
			// and negative power means energy is flowing towards the input.
			return power > Theme.geometry_overviewPage_connector_animationPowerThreshold
					? VenusOS.WidgetConnector_AnimationMode_StartToEnd
					: VenusOS.WidgetConnector_AnimationMode_EndToStart
		} else if (connectorWidget.endWidget === batteryWidget) {
			// For DC inputs, positive power means energy is flowing towards battery.
			return power > Theme.geometry_overviewPage_connector_animationPowerThreshold
					? VenusOS.WidgetConnector_AnimationMode_StartToEnd
					: VenusOS.WidgetConnector_AnimationMode_NotAnimated
		} else {
			console.warn("Unrecognised connector end widget:",
						 connectorWidget, connectorWidget.endWidget)
			return VenusOS.WidgetConnector_AnimationMode_NotAnimated
		}
	}

	topLeftButton: VenusOS.StatusBar_LeftButton_ControlsInactive
	fullScreenWhenIdle: true

	Component {
		id: acInputComponent

		AcInputWidget {
			id: acInputWidget

			expanded: root._expandLayout
			animateGeometry: root._animateGeometry
			animationEnabled: root.animationEnabled
			connectors: [ acInputWidgetConnector ]

			WidgetConnectorAnchor {
				location: VenusOS.WidgetConnector_Location_Right
				y: acInputWidgetConnector.straight ? inverterLeftConnectorAnchor.y : defaultY
				visible: acInputWidgetConnector.visible
			}

			WidgetConnector {
				id: acInputWidgetConnector

				parent: root
				startWidget: acInputWidget
				startLocation: VenusOS.WidgetConnector_Location_Right
				endWidget: inverterChargerWidget
				endLocation: VenusOS.WidgetConnector_Location_Left
				expanded: root._expandLayout
				animateGeometry: root._animateGeometry
				animationEnabled: root.animationEnabled
				animationMode: root._inputConnectorAnimationMode(acInputWidgetConnector)
			}
		}
	}

	Component {
		id: dcGeneratorComponent

		DcGeneratorWidget {
			id: dcGeneratorWidget

			expanded: root._expandLayout
			animateGeometry: root._animateGeometry
			animationEnabled: root.animationEnabled
			connectors: [ dcGeneratorConnector ]

			WidgetConnectorAnchor {
				location: VenusOS.WidgetConnector_Location_Right
				y: dcGeneratorConnector.straight ? inverterLeftConnectorAnchor.y : defaultY
				visible: dcGeneratorConnector.visible
			}

			WidgetConnector {
				id: dcGeneratorConnector

				parent: root
				startWidget: dcGeneratorWidget
				startLocation: VenusOS.WidgetConnector_Location_Right
				endWidget: batteryWidget
				endLocation: VenusOS.WidgetConnector_Location_Left
				expanded: root._expandLayout
				animateGeometry: root._animateGeometry
				animationEnabled: root.animationEnabled
				animationMode: root._inputConnectorAnimationMode(dcGeneratorConnector)
			}
		}
	}

	Component {
		id: dcInputComponent

		DcInputWidget {
			id: dcInputWidget

			expanded: root._expandLayout
			animateGeometry: root._animateGeometry
			animationEnabled: root.animationEnabled
			connectors: [ dcInputConnector ]

			WidgetConnectorAnchor {
				location: VenusOS.WidgetConnector_Location_Right
				y: dcInputConnector.straight ? inverterLeftConnectorAnchor.y : defaultY
				visible: dcInputConnector.visible
			}

			WidgetConnector {
				id: dcInputConnector

				parent: root
				startWidget: dcInputWidget
				startLocation: VenusOS.WidgetConnector_Location_Right
				endWidget: batteryWidget
				endLocation: VenusOS.WidgetConnector_Location_Left
				expanded: root._expandLayout
				animateGeometry: root._animateGeometry
				animationEnabled: root.animationEnabled
				animationMode: root._inputConnectorAnimationMode(dcInputConnector)
			}
		}
	}

	Component {
		id: alternatorComponent

		AlternatorWidget {
			id: alternatorWidget

			expanded: root._expandLayout
			animateGeometry: root._animateGeometry
			animationEnabled: root.animationEnabled
			connectors: [ alternatorConnector ]

			WidgetConnectorAnchor {
				location: VenusOS.WidgetConnector_Location_Right
				visible: alternatorConnector.visible
			}

			WidgetConnector {
				id: alternatorConnector

				parent: root
				startWidget: alternatorWidget
				startLocation: VenusOS.WidgetConnector_Location_Right
				endWidget: batteryWidget
				endLocation: VenusOS.WidgetConnector_Location_Left
				expanded: root._expandLayout
				animateGeometry: root._animateGeometry
				animationEnabled: root.animationEnabled
				animationMode: root._inputConnectorAnimationMode(alternatorConnector)
			}
		}
	}

	Component {
		id: windComponent

		WindWidget {
			id: windWidget

			expanded: root._expandLayout
			animateGeometry: root._animateGeometry
			animationEnabled: root.animationEnabled
			connectors: [ windConnector ]

			WidgetConnectorAnchor {
				location: VenusOS.WidgetConnector_Location_Right
				visible: windConnector.visible
			}

			WidgetConnector {
				id: windConnector

				parent: root
				startWidget: windWidget
				startLocation: VenusOS.WidgetConnector_Location_Right
				endWidget: batteryWidget
				endLocation: VenusOS.WidgetConnector_Location_Left
				expanded: root._expandLayout
				animateGeometry: root._animateGeometry
				animationEnabled: root.animationEnabled
				animationMode: root._inputConnectorAnimationMode(windConnector)
			}
		}
	}

	FrameAnimation {
		id: overviewPageRootAnimation

		running: root.visible
		property int index
		property real previousElapsed

		signal update(real elapsedTime)

		onRunningChanged: {
			if (!running) {
				index = 0
				previousElapsed = previousElapsed + elapsedTime
			}
		}

		onTriggered: {
			// Limit the frame rate to 20fps on the GX products
			if (index === 0 || Qt.platform.os !== "linux" || Global.isDesktop) {
				update(elapsedTime)
			}
			index = (index + 1) % 3
		}
	}

	Component {
		id: solarComponent

		SolarYieldWidget {
			id: solarWidget

			expanded: root._expandLayout
			animateGeometry: root._animateGeometry
			animationEnabled: root.animationEnabled
			connectors: [ acSolarConnector, dcSolarConnector ]

			WidgetConnectorAnchor {
				location: VenusOS.WidgetConnector_Location_Right
				visible: acSolarConnector.visible || dcSolarConnector.visible
			}

			WidgetConnector {
				id: acSolarConnector

				parent: root
				startWidget: solarWidget
				startLocation: VenusOS.WidgetConnector_Location_Right
				endWidget: inverterChargerWidget
				endLocation: VenusOS.WidgetConnector_Location_Left
				visible: defaultVisible && Global.pvInverters.model.count > 0
				expanded: root._expandLayout
				animateGeometry: root._animateGeometry
				animationEnabled: root.animationEnabled

				// Energy flows to Inverter/Charger if there is any PV Inverter power (i.e. AC)
				animationMode: root.isCurrentPage
						&& !isNaN(Global.system.solar.acPower)
						&& Math.abs(Global.system.solar.acPower || 0) > Theme.geometry_overviewPage_connector_animationPowerThreshold
							   ? VenusOS.WidgetConnector_AnimationMode_StartToEnd
							   : VenusOS.WidgetConnector_AnimationMode_NotAnimated
			}
			WidgetConnector {
				id: dcSolarConnector

				parent: root
				startWidget: solarWidget
				startLocation: VenusOS.WidgetConnector_Location_Right
				endWidget: batteryWidget
				endLocation: VenusOS.WidgetConnector_Location_Left
				visible: defaultVisible && Global.solarChargers.model.count > 0
				expanded: root._expandLayout
				animateGeometry: root._animateGeometry
				animationEnabled: root.animationEnabled

				// Energy flows to battery if there is any PV Charger power (i.e. DC, so solar is charging battery)
				animationMode: root.isCurrentPage
						&& !isNaN(Global.system.solar.dcPower)
						&& Math.abs(Global.system.solar.dcPower) > Theme.geometry_overviewPage_connector_animationPowerThreshold
							   ? VenusOS.WidgetConnector_AnimationMode_StartToEnd
							   : VenusOS.WidgetConnector_AnimationMode_NotAnimated
			}
		}
	}

	// the two central widgets are always laid out, even if they are not visible
	InverterChargerWidget {
		id: inverterChargerWidget

		size: VenusOS.OverviewWidget_Size_L
		expanded: root._expandLayout
		animateGeometry: root._animateGeometry
		animationEnabled: root.animationEnabled
		connectors: [ inverterToAcLoadsConnector, inverterToBatteryConnector ]

		WidgetConnectorAnchor {
			id: inverterLeftConnectorAnchor
			location: VenusOS.WidgetConnector_Location_Left
			visible: Global.acInputs.activeInput
					|| Global.acInputs.generatorInput
					|| Global.pvInverters.model.count > 0
		}
		WidgetConnectorAnchor {
			location: VenusOS.WidgetConnector_Location_Right
			visible: inverterToAcLoadsConnector.visible
		}
		WidgetConnectorAnchor {
			location: VenusOS.WidgetConnector_Location_Bottom
			visible: inverterToBatteryConnector.visible
		}
	}
	WidgetConnector {
		id: inverterToAcLoadsConnector

		startWidget: inverterChargerWidget
		startLocation: VenusOS.WidgetConnector_Location_Right
		endWidget: acLoadsWidget
		endLocation: VenusOS.WidgetConnector_Location_Left
		expanded: root._expandLayout
		animateGeometry: root._animateGeometry
		animationEnabled: root.animationEnabled
		straight: _rightWidgets.length <= 2   // straight if only AC Loads is present, or AC Loads plus EVCS or DC Loads

		// If load power is positive (i.e. consumed energy), energy flows to load.
		animationMode: root.isCurrentPage
				&& !isNaN(Global.system.loads.acPower)
				&& Global.system.loads.acPower > 0
				&& Math.abs(Global.system.loads.acPower) > Theme.geometry_overviewPage_connector_animationPowerThreshold
					? VenusOS.WidgetConnector_AnimationMode_StartToEnd
					: VenusOS.WidgetConnector_AnimationMode_NotAnimated
	}
	WidgetConnector {
		id: inverterToBatteryConnector

		startWidget: inverterChargerWidget
		startLocation: VenusOS.WidgetConnector_Location_Bottom
		endWidget: batteryWidget
		endLocation: VenusOS.WidgetConnector_Location_Top
		expanded: root._expandLayout
		animateGeometry: root._animateGeometry
		animationEnabled: root.animationEnabled

		// If vebus power is positive: battery is charging, so energy flows to battery.
		// If vebus power is negative: battery is discharging, so energy flows to inverter/charger.
		animationMode: root.isCurrentPage
				&& !isNaN(Global.system.veBus.power)
				&& Math.abs(Global.system.veBus.power) > Theme.geometry_overviewPage_connector_animationPowerThreshold
						? (Global.system.veBus.power > 0
								? VenusOS.WidgetConnector_AnimationMode_StartToEnd
								: VenusOS.WidgetConnector_AnimationMode_EndToStart)
						: VenusOS.WidgetConnector_AnimationMode_NotAnimated
	}

	BatteryWidget {
		id: batteryWidget

		size: VenusOS.OverviewWidget_Size_L
		expanded: root._expandLayout
		animateGeometry: root._animateGeometry
		animationEnabled: root.animationEnabled
		connectors: [ batteryToDcLoadsConnector ]

		WidgetConnectorAnchor {
			location: VenusOS.WidgetConnector_Location_Left
			visible: Global.dcInputs.model.count > 0 || Global.solarChargers.model.count > 0
		}
		WidgetConnectorAnchor {
			location: VenusOS.WidgetConnector_Location_Right
			visible: batteryToDcLoadsConnector.visible
		}
		WidgetConnectorAnchor {
			location: VenusOS.WidgetConnector_Location_Top
		}
	}
	WidgetConnector {
		id: batteryToDcLoadsConnector

		startWidget: batteryWidget
		startLocation: VenusOS.WidgetConnector_Location_Right
		endWidget: dcLoadsWidget
		endLocation: VenusOS.WidgetConnector_Location_Left
		expanded: root._expandLayout
		animateGeometry: root._animateGeometry
		animationEnabled: root.animationEnabled

		// If load power is positive (i.e. consumed energy), energy flows to load.
		animationMode: root.isCurrentPage
				&& !isNaN(Global.system.loads.dcPower)
				&& Global.system.loads.dcPower > 0
				&& Math.abs(Global.system.loads.dcPower) > Theme.geometry_overviewPage_connector_animationPowerThreshold
					? VenusOS.WidgetConnector_AnimationMode_StartToEnd
					: VenusOS.WidgetConnector_AnimationMode_NotAnimated
	}

	// the two output widgets are always present
	AcLoadsWidget {
		id: acLoadsWidget

		expanded: root._expandLayout
		animateGeometry: root._animateGeometry
		animationEnabled: root.animationEnabled

		WidgetConnectorAnchor {
			location: VenusOS.WidgetConnector_Location_Left
			y: root._rightWidgets.length <= 2 ? inverterLeftConnectorAnchor.y : defaultY
		}

		WidgetConnectorAnchor {
			location: VenusOS.WidgetConnector_Location_Bottom
			visible: Global.evChargers.model.count > 0
		}
	}

	DcLoadsWidget {
		id: dcLoadsWidget

		expanded: root._expandLayout
		animateGeometry: root._animateGeometry
		animationEnabled: root.animationEnabled

		WidgetConnectorAnchor {
			location: VenusOS.WidgetConnector_Location_Left
		}
	}

	Component {
		id: evcsComponent

		EvcsWidget {
			id: evcsWidget

			expanded: root._expandLayout
			animateGeometry: root._animateGeometry
			animationEnabled: root.animationEnabled
			connectors: [ evcsConnector ]

			WidgetConnectorAnchor {
				location: VenusOS.WidgetConnector_Location_Top
			}

			WidgetConnector {
				id: evcsConnector

				parent: root
				startWidget: acLoadsWidget
				startLocation: VenusOS.WidgetConnector_Location_Bottom
				endWidget: evcsWidget
				endLocation: VenusOS.WidgetConnector_Location_Top
				expanded: root._expandLayout
				animateGeometry: root._animateGeometry
				animationEnabled: root.animationEnabled
				animationMode: root.isCurrentPage
					? Global.evChargers.power > Theme.geometry_overviewPage_connector_animationPowerThreshold
					  ? VenusOS.WidgetConnector_AnimationMode_StartToEnd
					  : VenusOS.WidgetConnector_AnimationMode_NotAnimated
					: VenusOS.WidgetConnector_AnimationMode_NotAnimated
			}
		}
	}

}
