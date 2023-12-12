/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Utils

Page {
	id: root

	property var _leftWidgets: []
	readonly property var _centerWidgets: [veBusDeviceWidget, batteryWidget]
	property var _rightWidgets: []

	// Preferred order for the input widgets on the left hand side
	readonly property var _leftWidgetOrder: [
		Enums.OverviewWidget_Type_Grid,
		Enums.OverviewWidget_Type_Shore,
		Enums.OverviewWidget_Type_AcGenerator,
		Enums.OverviewWidget_Type_DcGenerator,
		Enums.OverviewWidget_Type_Alternator,
		Enums.OverviewWidget_Type_FuelCell,
		Enums.OverviewWidget_Type_Wind,
		Enums.OverviewWidget_Type_Solar
	]

	// Set a counter that updates whenever the layout should change.
	// Use a delayed binding to avoid repopulating the model unnecessarily.
	readonly property int _shouldResetWidgets: Global.acInputs.model.count
			+ Global.dcInputs.model.count
			+ (Global.acInputs.connectedInput ? Global.acInputs.connectedInput.source : -1)
			+ (Global.acInputs.generatorInput ? 1 : 0)
			+ (isNaN(Global.system.loads.dcPower) ? 0 : 1)
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
		width = Theme.geometry.screen.width

		// Reset the left/right widgets that should be shown
		for (let widgetType in _createdWidgets) {
			_createdWidgets[widgetType].size = Enums.OverviewWidget_Size_Zero
		}
		_resetLeftWidgets()
		_resetRightWidgets()

		let i = 0
		let firstLargeWidget = null
		let widget = null
		for (i = 0; i < _leftWidgets.length; ++i) {
			if (_leftWidgets[i].extraContent.children.length > 0) {
				firstLargeWidget = _leftWidgets[i]
				break
			}
		}

		// Set the left widget sizes
		for (i = 0; i < _leftWidgets.length; ++i) {
			widget = _leftWidgets[i]
			switch (_leftWidgets.length) {
			case 1:
				widget.size = Enums.OverviewWidget_Size_XL
				break
			case 2:
				widget.size = Enums.OverviewWidget_Size_L
				break
			case 3:
			case 4:
				// Only one of the widgets can have L size, and the other ones use a reduced size.
				if (widget === firstLargeWidget) {
					widget.size = Enums.OverviewWidget_Size_L
				} else if (firstLargeWidget != null) {
					// There is a large widget, so use M or XS size to fit around it
					widget.size = _leftWidgets.length == 3 ? Enums.OverviewWidget_Size_M : Enums.OverviewWidget_Size_XS
				} else {
					// There are no large widgets; use the same size for all left widgets
					widget.size = _leftWidgets.length == 3 ? Enums.OverviewWidget_Size_M : Enums.OverviewWidget_Size_S
				}
				break
			default:
				widget.size = Enums.OverviewWidget_Size_XS
				break
			}
		}

		// Set right widget sizes. AC Loads is always present; AC & DC Loads are sized depending on
		// whether EVCS is visible.
		const evChargerWidget = _findWidget(_rightWidgets, Enums.OverviewWidget_Type_Evcs)
		if (!!evChargerWidget) {
			evChargerWidget.size = Enums.OverviewWidget_Size_L
		}
		dcLoadsWidget.size = !isNaN(Global.system.loads.dcPower)
				? (!!evChargerWidget ? Enums.OverviewWidget_Size_XS : Enums.OverviewWidget_Size_L)
				: Enums.OverviewWidget_Size_Zero
		acLoadsWidget.size = dcLoadsWidget.size === Enums.OverviewWidget_Size_Zero
				? (!!evChargerWidget ? Enums.OverviewWidget_Size_L : Enums.OverviewWidget_Size_XL)
				: (!!evChargerWidget ? Enums.OverviewWidget_Size_XS : Enums.OverviewWidget_Size_L)

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

		const compactPageHeight = Theme.geometry.screen.height
				- Theme.geometry.statusBar.height
				- Theme.geometry.navigationBar.height
				- Theme.geometry.overviewPage.layout.compact.topMargin
				- Theme.geometry.overviewPage.layout.compact.bottomMargin
		if (compactPageHeight !== Theme.geometry.overviewPage.widget.compact.xl.height) {
			console.log("Warning: theme constants need to be updated.")
		}
		const compactWidgetsTopMargin = Math.max(0, (compactPageHeight - compactWidgetHeights) / Math.max(1, widgets.length - 1))

		const expandedPageHeight = Theme.geometry.screen.height
				- Theme.geometry.statusBar.height
				- Theme.geometry.overviewPage.layout.expanded.topMargin
				- Theme.geometry.overviewPage.layout.expanded.bottomMargin
		if (expandedPageHeight !== Theme.geometry.overviewPage.widget.expanded.xl.height) {
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
				widget.width = Theme.geometry.overviewPage.widget.leftWidgetWidth
				widget.x = Theme.geometry.page.content.horizontalMargin
			} else if (widgets === _centerWidgets) {
				widget.width = Theme.geometry.overviewPage.widget.centerWidgetWidth
				widget.x = root.width/2 - widget.width/2
			} else if (widgets === _rightWidgets) {
				widget.width = Theme.geometry.overviewPage.widget.rightWidgetWidth
				widget.x = root.width - widget.width - Theme.geometry.page.content.horizontalMargin
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
		case Enums.OverviewWidget_Type_AcGenerator:
			widget = acGeneratorComponent.createObject(root, args)
			break
		case Enums.OverviewWidget_Type_Alternator:
			widget = alternatorComponent.createObject(root, args)
			break
		case Enums.OverviewWidget_Type_DcGenerator:
			widget = dcGeneratorComponent.createObject(root, args)
			break
		case Enums.OverviewWidget_Type_FuelCell:
			widget = dcInputComponent.createObject(root, args)
			break
		case Enums.OverviewWidget_Type_Evcs:
			widget = evcsComponent.createObject(root, args)
			break
		case Enums.OverviewWidget_Type_Grid:
			widget = gridComponent.createObject(root, args)
			break
		case Enums.OverviewWidget_Type_Shore:
			widget = shoreComponent.createObject(root, args)
			break
		case Enums.OverviewWidget_Type_Solar:
			widget = solarComponent.createObject(root, args)
			break
		case Enums.OverviewWidget_Type_Wind:
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
		// Add AC widget. Only the connected AC input is relevant. If none are connected, use the
		// generator if available.
		let widgetType = -1
		let widgetCandidates = []
		let widget
		if (Global.acInputs.connectedInput != null) {
			switch (Global.acInputs.connectedInput.source) {
			case Enums.AcInputs_InputType_Grid:
				widgetType = Enums.OverviewWidget_Type_Grid
				break
			case Enums.AcInputs_InputType_Generator:
				widgetType = Enums.OverviewWidget_Type_AcGenerator
				break
			case Enums.AcInputs_InputType_Shore:
				widgetType = Enums.OverviewWidget_Type_Shore
				break
			default:
				break
			}
			if (widgetType < 0) {
				console.warn("Unknown AC input type:", Global.acInputs.connectedInput.source)
			} else {
				widget = _createWidget(widgetType)
				widgetCandidates.splice(_leftWidgetInsertionIndex(widgetType, widgetCandidates), 0, widget)
			}
		} else if (Global.acInputs.generatorInput != null) {
			widget = _createWidget(Enums.OverviewWidget_Type_AcGenerator)
			widgetCandidates.splice(_leftWidgetInsertionIndex(Enums.OverviewWidget_Type_AcGenerator, widgetCandidates), 0, widget)
		}

		// Add DC widgets
		let i
		for (i = 0; i < Global.dcInputs.model.count; ++i) {
			const dcInput = Global.dcInputs.model.deviceAt(i)
			switch (dcInput.inputType) {
			case Enums.DcInputs_InputType_Alternator:
				widgetType = Enums.OverviewWidget_Type_Alternator
				break
			case Enums.DcInputs_InputType_FuelCell:
				widgetType = Enums.OverviewWidget_Type_FuelCell
				break
			case Enums.DcInputs_InputType_Wind:
				widgetType = Enums.OverviewWidget_Type_Wind
				break
			default:
				// Use DC Generator as the catch-all type for any DC power source that isn't
				// specifically handled.
				widgetType = Enums.OverviewWidget_Type_DcGenerator
				break
			}
			if (widgetType < 0) {
				console.warn("Unknown DC input type:", dcInput.inputType)
				return
			}
			widget = _createWidget(widgetType)
			widget.input = dcInput
			widgetCandidates.splice(_leftWidgetInsertionIndex(widgetType, widgetCandidates), 0, widget)
		}

		// Add solar widget
		if (Global.solarChargers.model.count > 0 || Global.pvInverters.model.count > 0) {
			widgetCandidates.splice(_leftWidgetInsertionIndex(Enums.OverviewWidget_Type_Solar, widgetCandidates),
					0, _createWidget(Enums.OverviewWidget_Type_Solar))
		}
		_leftWidgets = widgetCandidates
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
			widgets.push(_createWidget(Enums.OverviewWidget_Type_Evcs))
		}
		if (!isNaN(Global.system.loads.dcPower)) {
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
			return Enums.WidgetConnector_AnimationMode_NotAnimated
		}
		// Assumes startWidget is the AC/DC input widget.
		if (!connectorWidget.startWidget.input) {
			return Enums.WidgetConnector_AnimationMode_NotAnimated
		}
		const power = connectorWidget.startWidget.input.power
		if (isNaN(power) || Math.abs(power) <= Theme.geometry.overviewPage.connector.animationPowerThreshold) {
			return Enums.WidgetConnector_AnimationMode_NotAnimated
		}

		if (connectorWidget.endWidget === veBusDeviceWidget) {
			// For AC inputs, positive power means energy is flowing towards inverter/charger,
			// and negative power means energy is flowing towards the input.
			return power > Theme.geometry.overviewPage.connector.animationPowerThreshold
					? Enums.WidgetConnector_AnimationMode_StartToEnd
					: Enums.WidgetConnector_AnimationMode_EndToStart
		} else if (connectorWidget.endWidget === batteryWidget) {
			// For DC inputs, positive power means energy is flowing towards battery.
			return power > Theme.geometry.overviewPage.connector.animationPowerThreshold
					? Enums.WidgetConnector_AnimationMode_StartToEnd
					: Enums.WidgetConnector_AnimationMode_NotAnimated
		} else {
			console.warn("Unrecognised connector end widget:",
						 connectorWidget, connectorWidget.endWidget)
			return Enums.WidgetConnector_AnimationMode_NotAnimated
		}
	}

	topLeftButton: Enums.StatusBar_LeftButton_ControlsInactive
	fullScreenWhenIdle: true

	Component {
		id: gridComponent

		GridWidget {
			id: gridWidget

			expanded: root._expandLayout
			animateGeometry: root._animateGeometry
			animationEnabled: root.animationEnabled
			connectors: [ gridWidgetConnector ]

			WidgetConnectorAnchor {
				location: Enums.WidgetConnector_Location_Right
				y: gridWidgetConnector.straight ? inverterLeftConnectorAnchor.y : defaultY
				visible: gridWidgetConnector.visible
			}

			WidgetConnector {
				id: gridWidgetConnector

				parent: root
				startWidget: gridWidget
				startLocation: Enums.WidgetConnector_Location_Right
				endWidget: veBusDeviceWidget
				endLocation: Enums.WidgetConnector_Location_Left
				expanded: root._expandLayout
				animateGeometry: root._animateGeometry
				animationEnabled: root.animationEnabled
				animationMode: root._inputConnectorAnimationMode(gridWidgetConnector)
			}
		}
	}

	Component {
		id: shoreComponent

		ShoreWidget {
			id: shoreWidget

			expanded: root._expandLayout
			animateGeometry: root._animateGeometry
			animationEnabled: root.animationEnabled
			connectors: [ shoreWidgetConnector ]

			WidgetConnectorAnchor {
				location: Enums.WidgetConnector_Location_Right
				y: shoreWidgetConnector.straight ? inverterLeftConnectorAnchor.y : defaultY
				visible: shoreWidgetConnector.visible
			}

			WidgetConnector {
				id: shoreWidgetConnector

				parent: root
				startWidget: shoreWidget
				startLocation: Enums.WidgetConnector_Location_Right
				endWidget: veBusDeviceWidget
				endLocation: Enums.WidgetConnector_Location_Left
				expanded: root._expandLayout
				animateGeometry: root._animateGeometry
				animationEnabled: root.animationEnabled
				animationMode: root._inputConnectorAnimationMode(shoreWidgetConnector)
			}
		}
	}

	Component {
		id: acGeneratorComponent

		AcGeneratorWidget {
			id: acGeneratorWidget

			expanded: root._expandLayout
			animateGeometry: root._animateGeometry
			animationEnabled: root.animationEnabled
			connectors: [ acGeneratorConnector ]

			WidgetConnectorAnchor {
				location: Enums.WidgetConnector_Location_Right
				y: acGeneratorConnector.straight ? inverterLeftConnectorAnchor.y : defaultY
				visible: acGeneratorConnector.visible
			}

			WidgetConnector {
				id: acGeneratorConnector

				parent: root
				startWidget: acGeneratorWidget
				startLocation: Enums.WidgetConnector_Location_Right
				endWidget: veBusDeviceWidget
				endLocation: Enums.WidgetConnector_Location_Left
				expanded: root._expandLayout
				animateGeometry: root._animateGeometry
				animationEnabled: root.animationEnabled
				animationMode: root._inputConnectorAnimationMode(acGeneratorConnector)
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
				location: Enums.WidgetConnector_Location_Right
				y: dcGeneratorConnector.straight ? inverterLeftConnectorAnchor.y : defaultY
				visible: dcGeneratorConnector.visible
			}

			WidgetConnector {
				id: dcGeneratorConnector

				parent: root
				startWidget: dcGeneratorWidget
				startLocation: Enums.WidgetConnector_Location_Right
				endWidget: batteryWidget
				endLocation: Enums.WidgetConnector_Location_Left
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
				location: Enums.WidgetConnector_Location_Right
				y: dcInputConnector.straight ? inverterLeftConnectorAnchor.y : defaultY
				visible: dcInputConnector.visible
			}

			WidgetConnector {
				id: dcInputConnector

				parent: root
				startWidget: dcInputWidget
				startLocation: Enums.WidgetConnector_Location_Right
				endWidget: batteryWidget
				endLocation: Enums.WidgetConnector_Location_Left
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
				location: Enums.WidgetConnector_Location_Right
				visible: alternatorConnector.visible
			}

			WidgetConnector {
				id: alternatorConnector

				parent: root
				startWidget: alternatorWidget
				startLocation: Enums.WidgetConnector_Location_Right
				endWidget: batteryWidget
				endLocation: Enums.WidgetConnector_Location_Left
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
				location: Enums.WidgetConnector_Location_Right
				visible: windConnector.visible
			}

			WidgetConnector {
				id: windConnector

				parent: root
				startWidget: windWidget
				startLocation: Enums.WidgetConnector_Location_Right
				endWidget: batteryWidget
				endLocation: Enums.WidgetConnector_Location_Left
				expanded: root._expandLayout
				animateGeometry: root._animateGeometry
				animationEnabled: root.animationEnabled
				animationMode: root._inputConnectorAnimationMode(windConnector)
			}
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
				location: Enums.WidgetConnector_Location_Right
				visible: acSolarConnector.visible || dcSolarConnector.visible
			}

			WidgetConnector {
				id: acSolarConnector

				parent: root
				startWidget: solarWidget
				startLocation: Enums.WidgetConnector_Location_Right
				endWidget: veBusDeviceWidget
				endLocation: Enums.WidgetConnector_Location_Left
				visible: defaultVisible && Global.pvInverters.model.count > 0
				expanded: root._expandLayout
				animateGeometry: root._animateGeometry
				animationEnabled: root.animationEnabled

				// Energy flows to Inverter/Charger if there is any PV Inverter power (i.e. AC)
				animationMode: root.isCurrentPage
						&& !isNaN(Global.system.solar.acPower)
						&& Math.abs(Global.system.solar.acPower || 0) > Theme.geometry.overviewPage.connector.animationPowerThreshold
							   ? Enums.WidgetConnector_AnimationMode_StartToEnd
							   : Enums.WidgetConnector_AnimationMode_NotAnimated
			}
			WidgetConnector {
				id: dcSolarConnector

				parent: root
				startWidget: solarWidget
				startLocation: Enums.WidgetConnector_Location_Right
				endWidget: batteryWidget
				endLocation: Enums.WidgetConnector_Location_Left
				visible: defaultVisible && Global.solarChargers.model.count > 0
				expanded: root._expandLayout
				animateGeometry: root._animateGeometry
				animationEnabled: root.animationEnabled

				// Energy flows to battery if there is any PV Charger power (i.e. DC, so solar is charging battery)
				animationMode: root.isCurrentPage
						&& !isNaN(Global.system.solar.dcPower)
						&& Math.abs(Global.system.solar.dcPower) > Theme.geometry.overviewPage.connector.animationPowerThreshold
							   ? Enums.WidgetConnector_AnimationMode_StartToEnd
							   : Enums.WidgetConnector_AnimationMode_NotAnimated
			}
		}
	}

	// the two central widgets are always laid out, even if they are not visible
	VeBusDeviceWidget {
		id: veBusDeviceWidget

		size: Enums.OverviewWidget_Size_L
		expanded: root._expandLayout
		animateGeometry: root._animateGeometry
		animationEnabled: root.animationEnabled
		connectors: [ inverterToAcLoadsConnector, inverterToBatteryConnector ]

		WidgetConnectorAnchor {
			id: inverterLeftConnectorAnchor
			location: Enums.WidgetConnector_Location_Left
			visible: Global.acInputs.connectedInput
					|| Global.acInputs.generatorInput
					|| Global.pvInverters.model.count > 0
		}
		WidgetConnectorAnchor {
			location: Enums.WidgetConnector_Location_Right
			visible: inverterToAcLoadsConnector.visible
		}
		WidgetConnectorAnchor {
			location: Enums.WidgetConnector_Location_Bottom
			visible: inverterToBatteryConnector.visible
		}
	}
	WidgetConnector {
		id: inverterToAcLoadsConnector

		startWidget: veBusDeviceWidget
		startLocation: Enums.WidgetConnector_Location_Right
		endWidget: acLoadsWidget
		endLocation: Enums.WidgetConnector_Location_Left
		expanded: root._expandLayout
		animateGeometry: root._animateGeometry
		animationEnabled: root.animationEnabled
		straight: _rightWidgets.length <= 2   // straight if only AC Loads is present, or AC Loads plus EVCS or DC Loads

		// If load power is positive (i.e. consumed energy), energy flows to load.
		animationMode: root.isCurrentPage
				&& !isNaN(Global.system.loads.acPower)
				&& Global.system.loads.acPower > 0
				&& Math.abs(Global.system.loads.acPower) > Theme.geometry.overviewPage.connector.animationPowerThreshold
					? Enums.WidgetConnector_AnimationMode_StartToEnd
					: Enums.WidgetConnector_AnimationMode_NotAnimated
	}
	WidgetConnector {
		id: inverterToBatteryConnector

		startWidget: veBusDeviceWidget
		startLocation: Enums.WidgetConnector_Location_Bottom
		endWidget: batteryWidget
		endLocation: Enums.WidgetConnector_Location_Top
		expanded: root._expandLayout
		animateGeometry: root._animateGeometry
		animationEnabled: root.animationEnabled

		// If vebus power is positive: battery is charging, so energy flows to battery.
		// If vebus power is negative: battery is discharging, so energy flows to inverter/charger.
		animationMode: root.isCurrentPage
				&& !isNaN(Global.system.veBus.power)
				&& Math.abs(Global.system.veBus.power) > Theme.geometry.overviewPage.connector.animationPowerThreshold
						? (Global.system.veBus.power > 0
								? Enums.WidgetConnector_AnimationMode_StartToEnd
								: Enums.WidgetConnector_AnimationMode_EndToStart)
						: Enums.WidgetConnector_AnimationMode_NotAnimated
	}

	BatteryWidget {
		id: batteryWidget

		size: Enums.OverviewWidget_Size_L
		expanded: root._expandLayout
		animateGeometry: root._animateGeometry
		animationEnabled: root.animationEnabled
		connectors: [ batteryToDcLoadsConnector ]

		WidgetConnectorAnchor {
			location: Enums.WidgetConnector_Location_Left
			visible: Global.dcInputs.model.count > 0 || Global.solarChargers.model.count > 0
		}
		WidgetConnectorAnchor {
			location: Enums.WidgetConnector_Location_Right
			visible: batteryToDcLoadsConnector.visible
		}
		WidgetConnectorAnchor {
			location: Enums.WidgetConnector_Location_Top
		}
	}
	WidgetConnector {
		id: batteryToDcLoadsConnector

		startWidget: batteryWidget
		startLocation: Enums.WidgetConnector_Location_Right
		endWidget: dcLoadsWidget
		endLocation: Enums.WidgetConnector_Location_Left
		expanded: root._expandLayout
		animateGeometry: root._animateGeometry
		animationEnabled: root.animationEnabled

		// If load power is positive (i.e. consumed energy), energy flows to load.
		animationMode: root.isCurrentPage
				&& !isNaN(Global.system.loads.dcPower)
				&& Global.system.loads.dcPower > 0
				&& Math.abs(Global.system.loads.dcPower) > Theme.geometry.overviewPage.connector.animationPowerThreshold
					? Enums.WidgetConnector_AnimationMode_StartToEnd
					: Enums.WidgetConnector_AnimationMode_NotAnimated
	}

	// the two output widgets are always present
	AcLoadsWidget {
		id: acLoadsWidget

		expanded: root._expandLayout
		animateGeometry: root._animateGeometry
		animationEnabled: root.animationEnabled

		WidgetConnectorAnchor {
			location: Enums.WidgetConnector_Location_Left
			y: root._rightWidgets.length <= 2 ? inverterLeftConnectorAnchor.y : defaultY
		}

		WidgetConnectorAnchor {
			location: Enums.WidgetConnector_Location_Bottom
			visible: Global.evChargers.model.count > 0
		}
	}

	DcLoadsWidget {
		id: dcLoadsWidget

		expanded: root._expandLayout
		animateGeometry: root._animateGeometry
		animationEnabled: root.animationEnabled

		WidgetConnectorAnchor {
			location: Enums.WidgetConnector_Location_Left
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
				location: Enums.WidgetConnector_Location_Top
			}

			WidgetConnector {
				id: evcsConnector

				parent: root
				startWidget: acLoadsWidget
				startLocation: Enums.WidgetConnector_Location_Bottom
				endWidget: evcsWidget
				endLocation: Enums.WidgetConnector_Location_Top
				expanded: root._expandLayout
				animateGeometry: root._animateGeometry
				animationEnabled: root.animationEnabled
				animationMode: root.isCurrentPage
					? Global.evChargers.power > Theme.geometry.overviewPage.connector.animationPowerThreshold
					  ? Enums.WidgetConnector_AnimationMode_StartToEnd
					  : Enums.WidgetConnector_AnimationMode_NotAnimated
					: Enums.WidgetConnector_AnimationMode_NotAnimated
			}
		}
	}

}
