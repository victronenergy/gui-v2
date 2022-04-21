/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

Page {
	id: root

	property var _leftWidgets: []

	// Preferred order for the input widgets on the left hand side
	readonly property var _leftWidgetOrder: [
		Enums.OverviewWidget_Type_Grid,
		Enums.OverviewWidget_Type_Shore,
		Enums.OverviewWidget_Type_AcGenerator,
		Enums.OverviewWidget_Type_DcGenerator,
		Enums.OverviewWidget_Type_Alternator,
		Enums.OverviewWidget_Type_Wind,
		Enums.OverviewWidget_Type_Solar
	]

	// Set a counter that updates whenever the layout should change.
	// Use a delayed binding to avoid repopulating the model unnecessarily.
	readonly property int _shouldResetWidgets: (acInputs && acInputs.model.count)
			+ (dcInputs && dcInputs.model.count)
			+ (dcLoadsWidget.size === _laidOutDcLoadsWidgetSize ? 0 : 1)
			+ (solarChargers && solarChargers.model.count)
	on_ShouldResetWidgetsChanged: Qt.callLater(_resetWidgets)

	property int _laidOutDcLoadsWidgetSize: -1

	property var _createdWidgets: ({})

	// Resets the layout, setting the y pos and height for all overview widgets. This is done once
	// imperatively, instead of using anchors or y/height bindings, so that widget connector path
	// calculations are also only done once; otherwise, the recalculation/repainting of the paths
	//  and path animations is very expensive and creates jerky animations on device.
	function _resetWidgets() {
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

		// Set the widget sizes
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

		// Set the widget positions
		resetWidgetPositions(_leftWidgets)
		resetWidgetPositions([inverterWidget, batteryWidget])
		resetWidgetPositions([acLoadsWidget, dcLoadsWidget])

		_laidOutDcLoadsWidgetSize = dcLoadsWidget.size
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

		let prevWidget = null
		for (i = 0; i < widgets.length; ++i) {
			// Position each widget below the previous widget in this set.
			widget = widgets[i]
			if (i > 0) {
				prevWidget = widgets[i-1]
				widget.compactY = prevWidget.compactY + prevWidget.getCompactHeight(prevWidget.size) + compactWidgetsTopMargin
				widget.expandedY = prevWidget.expandedY + prevWidget.getExpandedHeight(prevWidget.size) + expandedWidgetsTopMargin
			}
			// Position the segment border correctly when showing as segments.
			widget.segmentCompactMargin = compactWidgetsTopMargin
			widget.segmentExpandedMargin = expandedWidgetsTopMargin
		}
	}

	function _createWidget(type, args) {
		if (_createdWidgets[type] !== undefined) {
			return _createdWidgets[type]
		}
		args = args || {}
		let widget = null
		switch (type) {
		case Enums.OverviewWidget_Type_Grid:
			widget = gridComponent.createObject(root, args)
			break
		case Enums.OverviewWidget_Type_Shore:
			widget = shoreComponent.createObject(root, args)
			break
		case Enums.OverviewWidget_Type_AcGenerator:
			widget = acGeneratorComponent.createObject(root, args)
			break
		case Enums.OverviewWidget_Type_DcGenerator:
			widget = dcGeneratorComponent.createObject(root, args)
			break
		case Enums.OverviewWidget_Type_Alternator:
			widget = alternatorComponent.createObject(root, args)
			break
		case Enums.OverviewWidget_Type_Wind:
			widget = windComponent.createObject(root, args)
			break
		case Enums.OverviewWidget_Type_Solar:
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
		for (let widgetType in _createdWidgets) {
			_createdWidgets[widgetType].size = Enums.OverviewWidget_Size_Zero
		}

		if (!acInputs) {
			_leftWidgets = []
			return
		}

		let widgetCandidates = []
		_addModelWidgets(acInputs.model, widgetCandidates)
		_addModelWidgets(dcInputs.model, widgetCandidates)

		if (solarChargers && solarChargers.model.count > 0) {
			widgetCandidates.splice(_leftWidgetInsertionIndex(Enums.OverviewWidget_Type_Solar, widgetCandidates),
					0, _createWidget(Enums.OverviewWidget_Type_Solar))
		}
		_leftWidgets = widgetCandidates
	}

	function _addModelWidgets(inputModel, widgetCandidates) {
		for (let i = 0; i < inputModel.count; ++i) {
			let input = inputModel.get(i).input
			let widgetType = -1
			if (inputModel === acInputs.model)  {
				switch (input.source) {
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
			} else {
				switch (input.source) {
				case Enums.DcInputs_InputType_Alternator:
					widgetType = Enums.OverviewWidget_Type_Alternator
					break
				case Enums.DcInputs_InputType_DcGenerator:
					widgetType = Enums.OverviewWidget_Type_DcGenerator
					break
				case Enums.DcInputs_InputType_Wind:
					widgetType = Enums.OverviewWidget_Type_Wind
					break
				default:
					break
				}
			}
			if (widgetType < 0) {
				console.warn("Unknown AC/DC input type:", input.source, "for model:", inputModel)
				continue
			}
			let widget = _createWidget(widgetType, { input: input })
			widgetCandidates.splice(_leftWidgetInsertionIndex(widgetType, widgetCandidates), 0, widget)
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
		// Assumes startWidget is the AC/DC input widget.
		if (!connectorWidget.startWidget.input) {
			return Enums.WidgetConnector_AnimationMode_NotAnimated
		}
		const power = connectorWidget.startWidget.input.power
		if (isNaN(power) || Math.abs(power) <= Theme.geometry.overviewPage.connector.animationPowerThreshold) {
			return Enums.WidgetConnector_AnimationMode_NotAnimated
		}

		if (connectorWidget.endWidget === inverterWidget) {
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

	SegmentedWidgetBackground {
		id: segmentedBackground

		anchors {
			top: parent.top
			left: parent.left
			leftMargin: Theme.geometry.page.grid.horizontalMargin
		}
		visible: _leftWidgets.length >= Theme.geometry.overviewPage.layout.segmentedWidgetThreshold
		segments: _leftWidgets
	}

	Component {
		id: gridComponent

		GridWidget {
			id: gridWidget

			anchors {
				left: parent.left
				leftMargin: Theme.geometry.page.grid.horizontalMargin
			}
			expanded: PageManager.expandLayout
			animateGeometry: PageManager.animatingIdleResize
			isSegment: segmentedBackground.visible
			sideGaugeValue: value / Utils.maximumValue("grid.power")    // TODO when max available

			WidgetConnector {
				id: gridWidgetConnector

				parent: root
				startWidget: gridWidget
				startLocation: Enums.WidgetConnector_Location_Right
				endWidget: inverterWidget
				endLocation: Enums.WidgetConnector_Location_Left
				expanded: PageManager.expandLayout
				animateGeometry: PageManager.animatingIdleResize
				animationMode: root._inputConnectorAnimationMode(gridWidgetConnector)
				straight: gridWidget.size > Enums.OverviewWidget_Size_M
			}
		}
	}

	Component {
		id: shoreComponent

		ShoreWidget {
			id: shoreWidget

			anchors {
				left: parent.left
				leftMargin: Theme.geometry.page.grid.horizontalMargin
			}
			expanded: PageManager.expandLayout
			animateGeometry: PageManager.animatingIdleResize
			isSegment: segmentedBackground.visible
			sideGaugeValue: 0.5 // TODO when max available

			WidgetConnector {
				id: shoreWidgetConnector

				parent: root
				startWidget: shoreWidget
				startLocation: Enums.WidgetConnector_Location_Right
				endWidget: inverterWidget
				endLocation: Enums.WidgetConnector_Location_Left
				expanded: PageManager.expandLayout
				animateGeometry: PageManager.animatingIdleResize
				animationMode: root._inputConnectorAnimationMode(shoreWidgetConnector)
				straight: shoreWidget.size > Enums.OverviewWidget_Size_M
			}
		}
	}

	Component {
		id: acGeneratorComponent

		AcGeneratorWidget {
			id: acGeneratorWidget

			anchors {
				left: parent.left
				leftMargin: Theme.geometry.page.grid.horizontalMargin
			}
			expanded: PageManager.expandLayout
			animateGeometry: PageManager.animatingIdleResize
			isSegment: segmentedBackground.visible

			WidgetConnector {
				id: acGeneratorConnector

				parent: root
				startWidget: acGeneratorWidget
				startLocation: Enums.WidgetConnector_Location_Right
				endWidget: inverterWidget
				endLocation: Enums.WidgetConnector_Location_Left
				expanded: PageManager.expandLayout
				animateGeometry: PageManager.animatingIdleResize
				animationMode: root._inputConnectorAnimationMode(acGeneratorConnector)
				straight: acGeneratorWidget.size > Enums.OverviewWidget_Size_M
			}
		}
	}

	Component {
		id: dcGeneratorComponent

		DcGeneratorWidget {
			id: dcGeneratorWidget

			anchors {
				left: parent.left
				leftMargin: Theme.geometry.page.grid.horizontalMargin
			}
			expanded: PageManager.expandLayout
			animateGeometry: PageManager.animatingIdleResize
			isSegment: segmentedBackground.visible

			WidgetConnector {
				id: dcGeneratorConnector

				parent: root
				startWidget: dcGeneratorWidget
				startLocation: Enums.WidgetConnector_Location_Right
				endWidget: batteryWidget
				endLocation: Enums.WidgetConnector_Location_Left
				expanded: PageManager.expandLayout
				animateGeometry: PageManager.animatingIdleResize
				animationMode: root._inputConnectorAnimationMode(dcGeneratorConnector)
				straight: dcGeneratorWidget.size > Enums.OverviewWidget_Size_M
			}
		}
	}

	Component {
		id: alternatorComponent

		AlternatorWidget {
			id: alternatorWidget

			anchors {
				left: parent.left
				leftMargin: Theme.geometry.page.grid.horizontalMargin
			}
			expanded: PageManager.expandLayout
			animateGeometry: PageManager.animatingIdleResize
			isSegment: segmentedBackground.visible

			WidgetConnector {
				id: alternatorConnector

				parent: root
				startWidget: alternatorWidget
				startLocation: Enums.WidgetConnector_Location_Right
				endWidget: batteryWidget
				endLocation: Enums.WidgetConnector_Location_Left
				expanded: PageManager.expandLayout
				animateGeometry: PageManager.animatingIdleResize
				animationMode: root._inputConnectorAnimationMode(alternatorConnector)
			}
		}
	}

	Component {
		id: windComponent

		WindWidget {
			id: windWidget

			anchors {
				left: parent.left
				leftMargin: Theme.geometry.page.grid.horizontalMargin
			}
			expanded: PageManager.expandLayout
			animateGeometry: PageManager.animatingIdleResize
			isSegment: segmentedBackground.visible

			WidgetConnector {
				id: windConnector

				parent: root
				startWidget: windWidget
				startLocation: Enums.WidgetConnector_Location_Right
				endWidget: batteryWidget
				endLocation: Enums.WidgetConnector_Location_Left
				expanded: PageManager.expandLayout
				animateGeometry: PageManager.animatingIdleResize
				animationMode: root._inputConnectorAnimationMode(windConnector)
			}
		}
	}

	Component {
		id: solarComponent

		SolarYieldWidget {
			id: solarWidget

			anchors {
				left: parent.left
				leftMargin: Theme.geometry.page.grid.horizontalMargin
			}
			expanded: PageManager.expandLayout
			animateGeometry: PageManager.animatingIdleResize
			isSegment: segmentedBackground.visible

			value: !!solarChargers ? solarChargers.power : 0  // TODO show amps instead if configured
			yieldHistory: solarChargers.yieldHistory

			WidgetConnector {
				id: acSolarConnector

				parent: root
				startWidget: solarWidget
				startLocation: Enums.WidgetConnector_Location_Right
				endWidget: inverterWidget
				endLocation: Enums.WidgetConnector_Location_Left
				visible: !!solarChargers && !isNaN(solarChargers.acPower)
				expanded: PageManager.expandLayout
				animateGeometry: PageManager.animatingIdleResize

				// Energy always flows towards inverter/charger, never towards solar charger.
				animationMode: !!solarChargers
						&& !isNaN(solarChargers.acPower)
						&& Math.abs(solarChargers.acPower) > Theme.geometry.overviewPage.connector.animationPowerThreshold
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
				visible: !!solarChargers && !isNaN(solarChargers.dcPower)
				expanded: PageManager.expandLayout
				animateGeometry: PageManager.animatingIdleResize

				// Energy always flows towards battery, never towards solar charger.
				animationMode: !!solarChargers
						&& !isNaN(solarChargers.dcPower)
						&& Math.abs(solarChargers.dcPower) > Theme.geometry.overviewPage.connector.animationPowerThreshold
							   ? Enums.WidgetConnector_AnimationMode_StartToEnd
							   : Enums.WidgetConnector_AnimationMode_NotAnimated
			}
		}
	}

	// the two central widgets are always present
	InverterWidget {
		id: inverterWidget
		anchors.horizontalCenter: parent.horizontalCenter
		size: Enums.OverviewWidget_Size_L
		expanded: PageManager.expandLayout
		animateGeometry: PageManager.animatingIdleResize
		physicalQuantity: -1
		systemState: system ? system.state : 0
	}
	WidgetConnector {
		startWidget: inverterWidget
		startLocation: Enums.WidgetConnector_Location_Right
		endWidget: acLoadsWidget
		endLocation: Enums.WidgetConnector_Location_Left
		expanded: PageManager.expandLayout
		animateGeometry: PageManager.animatingIdleResize
		straight: true

		// If load power is positive (i.e. consumed energy), energy flows to load.
		animationMode: !!system
				&& !isNaN(system.ac.consumption.power)
				&& system.ac.consumption.power > 0
				&& Math.abs(system.ac.consumption.power) > Theme.geometry.overviewPage.connector.animationPowerThreshold
					? Enums.WidgetConnector_AnimationMode_StartToEnd
					: Enums.WidgetConnector_AnimationMode_NotAnimated
	}
	WidgetConnector {
		startWidget: inverterWidget
		startLocation: Enums.WidgetConnector_Location_Bottom
		endWidget: batteryWidget
		endLocation: Enums.WidgetConnector_Location_Top
		expanded: PageManager.expandLayout
		animateGeometry: PageManager.animatingIdleResize

		// If battery power is positive, energy flows to battery, else flows to inverter/charger.
		animationMode: !!battery
				&& !isNaN(battery.power)
				&& Math.abs(battery.power) > Theme.geometry.overviewPage.connector.animationPowerThreshold
						? (battery.power > 0
								? Enums.WidgetConnector_AnimationMode_StartToEnd
								: Enums.WidgetConnector_AnimationMode_EndToStart)
						: Enums.WidgetConnector_AnimationMode_NotAnimated
	}

	BatteryWidget {
		id: batteryWidget
		anchors.horizontalCenter: parent.horizontalCenter
		size: Enums.OverviewWidget_Size_L
		expanded: PageManager.expandLayout
		animateGeometry: PageManager.animatingIdleResize
		animationRunning: PageManager.navBar.currentUrl === "qrc:/pages/OverviewPage.qml"
		batteryData: battery
	}
	WidgetConnector {
		startWidget: batteryWidget
		startLocation: Enums.WidgetConnector_Location_Right
		endWidget: dcLoadsWidget
		endLocation: Enums.WidgetConnector_Location_Left
		expanded: PageManager.expandLayout
		animateGeometry: PageManager.animatingIdleResize

		// If load power is positive (i.e. consumed energy), energy flows to load.
		animationMode: !!system
				&& !isNaN(system.dc.power)
				&& system.dc.power > 0
				&& Math.abs(system.dc.power) > Theme.geometry.overviewPage.connector.animationPowerThreshold
					? Enums.WidgetConnector_AnimationMode_StartToEnd
					: Enums.WidgetConnector_AnimationMode_NotAnimated
	}

	// the two output widgets are always present
	AcLoadsWidget {
		id: acLoadsWidget
		anchors {
			right: parent.right
			rightMargin: Theme.geometry.page.grid.horizontalMargin
		}
		size: dcLoadsWidget.size === Enums.OverviewWidget_Size_Zero
			  ? Enums.OverviewWidget_Size_XL
			  : Enums.OverviewWidget_Size_L
		expanded: PageManager.expandLayout
		animateGeometry: PageManager.animatingIdleResize
		value: system ? system.ac.consumption.power : NaN
		phaseModel: system ? system.ac.consumption.phases : null
		phaseModelProperty: "power"
	}

	DcLoadsWidget {
		id: dcLoadsWidget
		anchors {
			right: parent.right
			rightMargin: Theme.geometry.page.grid.horizontalMargin
		}
		size: !!system && !isNaN(system.dc.power) ? Enums.OverviewWidget_Size_L : Enums.OverviewWidget_Size_Zero
		expanded: PageManager.expandLayout
		animateGeometry: PageManager.animatingIdleResize
		value: system ? system.dc.power || NaN : NaN
	}
}
