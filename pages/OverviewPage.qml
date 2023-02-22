/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

Page {
	id: root

	property var _leftWidgets: []
	readonly property var _centerWidgets: [inverterWidget, batteryWidget]
	readonly property var _rightWidgets: [acLoadsWidget, dcLoadsWidget]

	// Preferred order for the input widgets on the left hand side
	readonly property var _leftWidgetOrder: [
		VenusOS.OverviewWidget_Type_Grid,
		VenusOS.OverviewWidget_Type_Shore,
		VenusOS.OverviewWidget_Type_AcGenerator,
		VenusOS.OverviewWidget_Type_DcGenerator,
		VenusOS.OverviewWidget_Type_Alternator,
		VenusOS.OverviewWidget_Type_Wind,
		VenusOS.OverviewWidget_Type_Solar
	]

	// Set a counter that updates whenever the layout should change.
	// Use a delayed binding to avoid repopulating the model unnecessarily.
	readonly property int _shouldResetWidgets: Global.acInputs.model.count
			+ Global.dcInputs.model.count
			+ (Global.acInputs.connectedInput ? Global.acInputs.connectedInput.source : -1)
			+ (Global.acInputs.generatorInput ? 1 : 0)
			+ (isNaN(Global.system.loads.dcPower) ? 0 : 1)
			+ (Global.solarChargers.model.count === 0 ? 0 : 1)
	on_ShouldResetWidgetsChanged: Qt.callLater(_resetWidgets)
	Component.onCompleted: Qt.callLater(_resetWidgets)

	property var _createdWidgets: ({})

	// Resets the layout, setting the y pos and height for all overview widgets. This is done once
	// imperatively, instead of using anchors or y/height bindings, so that widget connector path
	// calculations are also only done once; otherwise, the recalculation/repainting of the paths
	//  and path animations is very expensive and creates jerky animations on device.
	function _resetWidgets() {
		width = Theme.geometry.screen.width
		_resetLeftWidgets()

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
				widget.size = VenusOS.OverviewWidget_Size_XL
				break
			case 2:
				widget.size = VenusOS.OverviewWidget_Size_L
				break
			case 3:
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

		// Set AC and DC load widget sizes
		dcLoadsWidget.size = !isNaN(Global.system.loads.dcPower)
				? VenusOS.OverviewWidget_Size_L
				: VenusOS.OverviewWidget_Size_Zero
		acLoadsWidget.size = dcLoadsWidget.size === VenusOS.OverviewWidget_Size_Zero
				? VenusOS.OverviewWidget_Size_XL
				: VenusOS.OverviewWidget_Size_L

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
		let compactWidgetsTopMargin = Math.max(0, (compactPageHeight - compactWidgetHeights) / Math.max(1, widgets.length - 1))

		const expandedPageHeight = Theme.geometry.screen.height
				- Theme.geometry.statusBar.height
				- Theme.geometry.overviewPage.layout.expanded.topMargin
				- Theme.geometry.overviewPage.layout.expanded.bottomMargin
		let expandedWidgetsTopMargin = Math.max(0, (expandedPageHeight - expandedWidgetHeights) / Math.max(1, widgets.length - 1))

		if (widgets === _leftWidgets
				&& widgets.length >= Theme.geometry.overviewPage.layout.segmentedWidgetThreshold) {
			// For a segmented widget layout, increase the widget height by a proportion of the
			// margin (so the increase is spread out over all of the widgets).
			const reductionRatio = (Theme.geometry.overviewPage.layout.segmentedWidgetThreshold - 1)
					/ Theme.geometry.overviewPage.layout.segmentedWidgetThreshold
			compactWidgetsTopMargin = compactWidgetsTopMargin * reductionRatio
			expandedWidgetsTopMargin = expandedWidgetsTopMargin * reductionRatio
		}

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

			// Position the segment border correctly when showing as segments.
			widget.segmentCompactMargin = compactWidgetsTopMargin
			widget.segmentExpandedMargin = expandedWidgetsTopMargin
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
		case VenusOS.OverviewWidget_Type_Grid:
			widget = gridComponent.createObject(root, args)
			break
		case VenusOS.OverviewWidget_Type_Shore:
			widget = shoreComponent.createObject(root, args)
			break
		case VenusOS.OverviewWidget_Type_AcGenerator:
			widget = acGeneratorComponent.createObject(root, args)
			break
		case VenusOS.OverviewWidget_Type_DcGenerator:
			widget = dcGeneratorComponent.createObject(root, args)
			break
		case VenusOS.OverviewWidget_Type_Alternator:
			widget = alternatorComponent.createObject(root, args)
			break
		case VenusOS.OverviewWidget_Type_Wind:
			widget = windComponent.createObject(root, args)
			break
		case VenusOS.OverviewWidget_Type_Solar:
			widget = solarComponent.createObject(root, args)
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
		for (widgetType in _createdWidgets) {
			_createdWidgets[widgetType].size = VenusOS.OverviewWidget_Size_Zero
		}

		// Add AC widget. Only the connected AC input is relevant. If none are connected, use the
		// generator if available.
		let widgetCandidates = []
		let widget
		if (Global.acInputs.connectedInput != null) {
			switch (Global.acInputs.connectedInput.source) {
			case VenusOS.AcInputs_InputType_Grid:
				widgetType = VenusOS.OverviewWidget_Type_Grid
				break
			case VenusOS.AcInputs_InputType_Generator:
				widgetType = VenusOS.OverviewWidget_Type_AcGenerator
				break
			case VenusOS.AcInputs_InputType_Shore:
				widgetType = VenusOS.OverviewWidget_Type_Shore
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
			widget = _createWidget(VenusOS.OverviewWidget_Type_AcGenerator)
			widgetCandidates.splice(_leftWidgetInsertionIndex(VenusOS.OverviewWidget_Type_AcGenerator, widgetCandidates), 0, widget)
		}

		// Add DC widgets
		let i
		for (i = 0; i < Global.dcInputs.model.count; ++i) {
			const dcInput = Global.dcInputs.model.get(i).input
			switch (dcInput.source) {
			case VenusOS.DcInputs_InputType_Alternator:
				widgetType = VenusOS.OverviewWidget_Type_Alternator
				break
			case VenusOS.DcInputs_InputType_DcGenerator:
				widgetType = VenusOS.OverviewWidget_Type_DcGenerator
				break
			case VenusOS.DcInputs_InputType_Wind:
				widgetType = VenusOS.OverviewWidget_Type_Wind
				break
			default:
				break
			}
			if (widgetType < 0) {
				console.warn("Unknown DC input type:", dcInput.source)
				return
			}
			widget = _createWidget(widgetType)
			widget.input = dcInput
			widgetCandidates.splice(_leftWidgetInsertionIndex(widgetType, widgetCandidates), 0, widget)
		}

		// Add solar widget
		if (Global.solarChargers.model.count > 0) {
			widgetCandidates.splice(_leftWidgetInsertionIndex(VenusOS.OverviewWidget_Type_Solar, widgetCandidates),
					0, _createWidget(VenusOS.OverviewWidget_Type_Solar))
		}
		_leftWidgets = widgetCandidates

		segmentedBackground.visible = _leftWidgets.length >= Theme.geometry.overviewPage.layout.segmentedWidgetThreshold
		for (i = 0; i < _leftWidgets.length; ++i) {
			_leftWidgets[i].isSegment = segmentedBackground.visible
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

	function _inputConnectorAnimationMode(connectorWidget) {
		if (!isCurrentPage) {
			return VenusOS.WidgetConnector_AnimationMode_NotAnimated
		}
		// Assumes startWidget is the AC/DC input widget.
		if (!connectorWidget.startWidget.input) {
			return VenusOS.WidgetConnector_AnimationMode_NotAnimated
		}
		const power = connectorWidget.startWidget.input.power
		if (isNaN(power) || Math.abs(power) <= Theme.geometry.overviewPage.connector.animationPowerThreshold) {
			return VenusOS.WidgetConnector_AnimationMode_NotAnimated
		}

		if (connectorWidget.endWidget === inverterWidget) {
			// For AC inputs, positive power means energy is flowing towards inverter/charger,
			// and negative power means energy is flowing towards the input.
			return power > Theme.geometry.overviewPage.connector.animationPowerThreshold
					? VenusOS.WidgetConnector_AnimationMode_StartToEnd
					: VenusOS.WidgetConnector_AnimationMode_EndToStart
		} else if (connectorWidget.endWidget === batteryWidget) {
			// For DC inputs, positive power means energy is flowing towards battery.
			return power > Theme.geometry.overviewPage.connector.animationPowerThreshold
					? VenusOS.WidgetConnector_AnimationMode_StartToEnd
					: VenusOS.WidgetConnector_AnimationMode_NotAnimated
		} else {
			console.warn("Unrecognised connector end widget:",
						 connectorWidget, connectorWidget.endWidget)
			return VenusOS.WidgetConnector_AnimationMode_NotAnimated
		}
	}

	fullScreenWhenIdle: true

	SegmentedWidgetBackground {
		id: segmentedBackground

		anchors {
			top: parent.top
			left: parent.left
			leftMargin: Theme.geometry.page.content.horizontalMargin
		}
		visible: false
		segments: _leftWidgets
	}

	Component {
		id: gridComponent

		GridWidget {
			id: gridWidget

			expanded: Global.pageManager.expandLayout
			animateGeometry: Global.pageManager.animatingIdleResize
			animationEnabled: root.isCurrentPage
			isSegment: segmentedBackground.visible
			connectors: [ gridWidgetConnector ]

			WidgetConnectorAnchor {
				location: VenusOS.WidgetConnector_Location_Right
				y: gridWidgetConnector.straight ? inverterLeftConnectorAnchor.y : defaultY
				visible: gridWidgetConnector.visible
			}

			WidgetConnector {
				id: gridWidgetConnector

				parent: root
				startWidget: gridWidget
				startLocation: VenusOS.WidgetConnector_Location_Right
				endWidget: inverterWidget
				endLocation: VenusOS.WidgetConnector_Location_Left
				expanded: Global.pageManager.expandLayout
				animateGeometry: root.isCurrentPage && Global.pageManager.animatingIdleResize
				animationMode: root._inputConnectorAnimationMode(gridWidgetConnector)
			}
		}
	}

	Component {
		id: shoreComponent

		ShoreWidget {
			id: shoreWidget

			expanded: Global.pageManager.expandLayout
			animateGeometry: root.isCurrentPage && Global.pageManager.animatingIdleResize
			connectors: [ shoreWidgetConnector ]

			WidgetConnectorAnchor {
				location: VenusOS.WidgetConnector_Location_Right
				y: shoreWidgetConnector.straight ? inverterLeftConnectorAnchor.y : defaultY
				visible: shoreWidgetConnector.visible
			}

			WidgetConnector {
				id: shoreWidgetConnector

				parent: root
				startWidget: shoreWidget
				startLocation: VenusOS.WidgetConnector_Location_Right
				endWidget: inverterWidget
				endLocation: VenusOS.WidgetConnector_Location_Left
				expanded: Global.pageManager.expandLayout
				animateGeometry: root.isCurrentPage && Global.pageManager.animatingIdleResize
				animationMode: root._inputConnectorAnimationMode(shoreWidgetConnector)
			}
		}
	}

	Component {
		id: acGeneratorComponent

		AcGeneratorWidget {
			id: acGeneratorWidget

			expanded: Global.pageManager.expandLayout
			animateGeometry: root.isCurrentPage && Global.pageManager.animatingIdleResize
			isSegment: segmentedBackground.visible
			connectors: [ acGeneratorConnector ]

			WidgetConnectorAnchor {
				location: VenusOS.WidgetConnector_Location_Right
				y: acGeneratorConnector.straight ? inverterLeftConnectorAnchor.y : defaultY
				visible: acGeneratorConnector.visible
			}

			WidgetConnector {
				id: acGeneratorConnector

				parent: root
				startWidget: acGeneratorWidget
				startLocation: VenusOS.WidgetConnector_Location_Right
				endWidget: inverterWidget
				endLocation: VenusOS.WidgetConnector_Location_Left
				expanded: Global.pageManager.expandLayout
				animateGeometry: root.isCurrentPage && Global.pageManager.animatingIdleResize
				animationMode: root._inputConnectorAnimationMode(acGeneratorConnector)
			}
		}
	}

	Component {
		id: dcGeneratorComponent

		DcGeneratorWidget {
			id: dcGeneratorWidget

			expanded: Global.pageManager.expandLayout
			animateGeometry: root.isCurrentPage && Global.pageManager.animatingIdleResize
			isSegment: segmentedBackground.visible
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
				expanded: Global.pageManager.expandLayout
				animateGeometry: root.isCurrentPage && Global.pageManager.animatingIdleResize
				animationMode: root._inputConnectorAnimationMode(dcGeneratorConnector)
			}
		}
	}

	Component {
		id: alternatorComponent

		AlternatorWidget {
			id: alternatorWidget

			expanded: Global.pageManager.expandLayout
			animateGeometry: root.isCurrentPage && Global.pageManager.animatingIdleResize
			isSegment: segmentedBackground.visible
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
				expanded: Global.pageManager.expandLayout
				animateGeometry: root.isCurrentPage && Global.pageManager.animatingIdleResize
				animationMode: root._inputConnectorAnimationMode(alternatorConnector)
			}
		}
	}

	Component {
		id: windComponent

		WindWidget {
			id: windWidget

			expanded: Global.pageManager.expandLayout
			animateGeometry: root.isCurrentPage && Global.pageManager.animatingIdleResize
			isSegment: segmentedBackground.visible
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
				expanded: Global.pageManager.expandLayout
				animateGeometry: root.isCurrentPage && Global.pageManager.animatingIdleResize
				animationMode: root._inputConnectorAnimationMode(windConnector)
			}
		}
	}

	Component {
		id: solarComponent

		SolarYieldWidget {
			id: solarWidget

			expanded: Global.pageManager.expandLayout
			animateGeometry: root.isCurrentPage && Global.pageManager.animatingIdleResize
			isSegment: segmentedBackground.visible
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
				endWidget: inverterWidget
				endLocation: VenusOS.WidgetConnector_Location_Left
				visible: defaultVisible && !isNaN(Global.solarChargers.acPower)
				expanded: Global.pageManager.expandLayout
				animateGeometry: root.isCurrentPage && Global.pageManager.animatingIdleResize

				// Energy always flows towards inverter/charger, never towards solar charger.
				animationMode: root.isCurrentPage
						&& !isNaN(Global.solarChargers.acPower)
						&& Math.abs(Global.solarChargers.acPower) > Theme.geometry.overviewPage.connector.animationPowerThreshold
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
				visible: !isNaN(Global.solarChargers.dcPower)
				expanded: Global.pageManager.expandLayout
				animateGeometry: root.isCurrentPage && Global.pageManager.animatingIdleResize

				// Energy always flows towards battery, never towards solar charger.
				animationMode: root.isCurrentPage
						&& !isNaN(Global.solarChargers.dcPower)
						&& Math.abs(Global.solarChargers.dcPower) > Theme.geometry.overviewPage.connector.animationPowerThreshold
							   ? VenusOS.WidgetConnector_AnimationMode_StartToEnd
							   : VenusOS.WidgetConnector_AnimationMode_NotAnimated
			}
		}
	}

	// the two central widgets are always present
	InverterWidget {
		id: inverterWidget

		size: VenusOS.OverviewWidget_Size_L
		expanded: Global.pageManager.expandLayout
		animateGeometry: root.isCurrentPage && Global.pageManager.animatingIdleResize
		systemState: Global.system.state
		connectors: [ inverterToAcLoadsConnector, inverterToBatteryConnector ]

		WidgetConnectorAnchor {
			id: inverterLeftConnectorAnchor
			location: VenusOS.WidgetConnector_Location_Left
			visible: Global.acInputs.connectedInput
					|| Global.acInputs.generatorInput
					|| !isNaN(Global.solarChargers.acPower)
		}
		WidgetConnectorAnchor {
			location: VenusOS.WidgetConnector_Location_Right
			visible: inverterToAcLoadsConnector.visible
		}
		WidgetConnectorAnchor {
			location: VenusOS.WidgetConnector_Location_Bottom
		}
	}
	WidgetConnector {
		id: inverterToAcLoadsConnector

		startWidget: inverterWidget
		startLocation: VenusOS.WidgetConnector_Location_Right
		endWidget: acLoadsWidget
		endLocation: VenusOS.WidgetConnector_Location_Left
		expanded: Global.pageManager.expandLayout
		animateGeometry: root.isCurrentPage && Global.pageManager.animatingIdleResize
		straight: true

		// If load power is positive (i.e. consumed energy), energy flows to load.
		animationMode: root.isCurrentPage
				&& !isNaN(Global.system.loads.acPower)
				&& Global.system.loads.acPower > 0
				&& Math.abs(Global.system.loads.acPower) > Theme.geometry.overviewPage.connector.animationPowerThreshold
					? VenusOS.WidgetConnector_AnimationMode_StartToEnd
					: VenusOS.WidgetConnector_AnimationMode_NotAnimated
	}
	WidgetConnector {
		id: inverterToBatteryConnector

		startWidget: inverterWidget
		startLocation: VenusOS.WidgetConnector_Location_Bottom
		endWidget: batteryWidget
		endLocation: VenusOS.WidgetConnector_Location_Top
		expanded: Global.pageManager.expandLayout
		animateGeometry: root.isCurrentPage && Global.pageManager.animatingIdleResize

		// If battery power is positive, energy flows to battery, else flows to inverter/charger.
		animationMode: root.isCurrentPage
				&& !isNaN(Global.battery.power)
				&& Math.abs(Global.battery.power) > Theme.geometry.overviewPage.connector.animationPowerThreshold
						? (Global.battery.power > 0
								? VenusOS.WidgetConnector_AnimationMode_StartToEnd
								: VenusOS.WidgetConnector_AnimationMode_EndToStart)
						: VenusOS.WidgetConnector_AnimationMode_NotAnimated
	}

	BatteryWidget {
		id: batteryWidget

		size: VenusOS.OverviewWidget_Size_L
		expanded: Global.pageManager.expandLayout
		animateGeometry: root.isCurrentPage && Global.pageManager.animatingIdleResize
		animationEnabled: root.isCurrentPage
		batteryData: Global.battery
		connectors: [ batteryToDcLoadsConnector ]

		WidgetConnectorAnchor {
			location: VenusOS.WidgetConnector_Location_Left
			visible: Global.dcInputs.model.count > 0 || !isNaN(Global.solarChargers.dcPower)
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
		expanded: Global.pageManager.expandLayout
		animateGeometry: root.isCurrentPage && Global.pageManager.animatingIdleResize

		// If load power is positive (i.e. consumed energy), energy flows to load.
		animationMode: root.isCurrentPage
				&& !isNaN(Global.system.loads.dcPower)
				&& Global.system.loads.dcPower > 0
				&& Math.abs(Global.system.loads.dcPower) > Theme.geometry.overviewPage.connector.animationPowerThreshold
					? VenusOS.WidgetConnector_AnimationMode_StartToEnd
					: VenusOS.WidgetConnector_AnimationMode_NotAnimated
	}

	// the two output widgets are always present
	AcLoadsWidget {
		id: acLoadsWidget

		expanded: Global.pageManager.expandLayout
		animateGeometry: root.isCurrentPage && Global.pageManager.animatingIdleResize

		WidgetConnectorAnchor {
			location: VenusOS.WidgetConnector_Location_Left
			y: inverterLeftConnectorAnchor.y
		}
	}

	DcLoadsWidget {
		id: dcLoadsWidget

		expanded: Global.pageManager.expandLayout
		animateGeometry: root.isCurrentPage && Global.pageManager.animatingIdleResize

		WidgetConnectorAnchor {
			location: VenusOS.WidgetConnector_Location_Left
		}
	}
}
