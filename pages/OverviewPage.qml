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
		OverviewWidget.Type.Grid,
		OverviewWidget.Type.Shore,
		OverviewWidget.Type.AcGenerator,
		OverviewWidget.Type.DcGenerator,
		OverviewWidget.Type.Alternator,
		OverviewWidget.Type.Wind,
		OverviewWidget.Type.Solar
	]

	// Use a delayed binding to avoid repopulating the model unnecessarily
	readonly property bool _shouldResetWidgets: (acInputs && acInputs.model.count)
			|| (dcInputs && dcInputs.model.count)
			|| (solarChargers && solarChargers.model.count)
	on_ShouldResetWidgetsChanged: Qt.callLater(_resetWidgets)

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
				widget.size = OverviewWidget.Size.XL
				break
			case 2:
				widget.size = OverviewWidget.Size.L
				break
			case 3:
			case 4:
				// Only one of the widgets can have L size, and the other ones use a reduced size.
				if (widget === firstLargeWidget) {
					widget.size = OverviewWidget.Size.L
				} else if (firstLargeWidget != null) {
					// There is a large widget, so use M or XS size to fit around it
					widget.size = _leftWidgets.length == 3 ? OverviewWidget.Size.M : OverviewWidget.Size.XS
				} else {
					// There are no large widgets; use the same size for all left widgets
					widget.size = _leftWidgets.length == 3 ? OverviewWidget.Size.M : OverviewWidget.Size.S
				}
				break
			default:
				widget.size = OverviewWidget.Size.XS
				break
			}
		}

		// Set the widget positions
		resetWidgetPositions(_leftWidgets)
		resetWidgetPositions([inverterWidget, batteryWidget])
		resetWidgetPositions([acLoadsWidget, dcLoadsWidget])
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
		const compactWidgetsTopMargin = Math.max(0, (compactPageHeight - compactWidgetHeights) / Math.max(1, widgets.length - 1))

		const expandedPageHeight = Theme.geometry.screen.height
				- Theme.geometry.statusBar.height
				- Theme.geometry.overviewPage.layout.expanded.topMargin
				- Theme.geometry.overviewPage.layout.expanded.bottomMargin
		const expandedWidgetsTopMargin = Math.max(0, (expandedPageHeight - expandedWidgetHeights) / Math.max(1, widgets.length - 1))

		let prevWidget = null
		for (i = 0; i < widgets.length; ++i) {
			widget = widgets[i]
			if (i > 0) {
				prevWidget = widgets[i-1]
				widget.compactY = prevWidget.compactY + prevWidget.getCompactHeight(prevWidget.size) + compactWidgetsTopMargin
				widget.expandedY = prevWidget.expandedY + prevWidget.getExpandedHeight(prevWidget.size) + expandedWidgetsTopMargin
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
		case OverviewWidget.Type.Grid:
			widget = gridComponent.createObject(root, args)
			break
		case OverviewWidget.Type.Shore:
			widget = shoreComponent.createObject(root, args)
			break
		case OverviewWidget.Type.AcGenerator:
			widget = acGeneratorComponent.createObject(root, args)
			break
		case OverviewWidget.Type.DcGenerator:
			widget = dcGeneratorComponent.createObject(root, args)
			break
		case OverviewWidget.Type.Alternator:
			widget = alternatorComponent.createObject(root, args)
			break
		case OverviewWidget.Type.Wind:
			widget = windComponent.createObject(root, args)
			break
		case OverviewWidget.Type.Solar:
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
			_createdWidgets[widgetType].size = OverviewWidget.Size.Zero
		}

		if (!acInputs) {
			_leftWidgets = []
			return
		}

		let widgetCandidates = []
		_addModelWidgets(acInputs.model, widgetCandidates)
		_addModelWidgets(dcInputs.model, widgetCandidates)

		if (solarChargers && solarChargers.model.count > 0) {
			widgetCandidates.splice(_leftWidgetInsertionIndex(OverviewWidget.Type.Solar, widgetCandidates),
					0, _createWidget(OverviewWidget.Type.Solar))
		}
		_leftWidgets = widgetCandidates
	}

	function _addModelWidgets(inputModel, widgetCandidates) {
		for (let i = 0; i < inputModel.count; ++i) {
			let input = inputModel.get(i).input
			let widgetType = -1
			if (inputModel === acInputs.model)  {
				switch (input.source) {
				case AcInputs.InputType.Grid:
					widgetType = OverviewWidget.Type.Grid
					break
				case AcInputs.InputType.Generator:
					widgetType = OverviewWidget.Type.AcGenerator
					break
				case AcInputs.InputType.Shore:
					widgetType = OverviewWidget.Type.Shore
					break
				default:
					break
				}
			} else {
				switch (input.source) {
				case DcInputs.InputType.Alternator:
					widgetType = OverviewWidget.Type.Alternator
					break
				case DcInputs.InputType.DcGenerator:
					widgetType = OverviewWidget.Type.DcGenerator
					break
				case DcInputs.InputType.Wind:
					widgetType = OverviewWidget.Type.Wind
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
			sideGaugeValue: value / Utils.maximumValue("grid.power")

			WidgetConnector {
				parent: root
				startWidget: gridWidget
				startLocation: WidgetConnector.Location.Right
				endWidget: inverterWidget
				endLocation: WidgetConnector.Location.Left
				expanded: PageManager.expandLayout
				animateGeometry: PageManager.animatingIdleResize
				animationRunning: !!gridWidget.input && gridWidget.input.connected
				straight: gridWidget.size > OverviewWidget.Size.M
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
				parent: root
				startWidget: shoreWidget
				startLocation: WidgetConnector.Location.Right
				endWidget: inverterWidget
				endLocation: WidgetConnector.Location.Left
				expanded: PageManager.expandLayout
				animateGeometry: PageManager.animatingIdleResize
				animationRunning: !!shoreWidget.input && shoreWidget.input.connected
				straight: shoreWidget.size > OverviewWidget.Size.M
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
				parent: root
				startWidget: acGeneratorWidget
				startLocation: WidgetConnector.Location.Right
				endWidget: inverterWidget
				endLocation: WidgetConnector.Location.Left
				expanded: PageManager.expandLayout
				animateGeometry: PageManager.animatingIdleResize
				animationRunning: !!acGeneratorWidget.input && acGeneratorWidget.input.connected
				straight: acGeneratorWidget.size > OverviewWidget.Size.M
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
				parent: root
				startWidget: dcGeneratorWidget
				startLocation: WidgetConnector.Location.Right
				endWidget: batteryWidget
				endLocation: WidgetConnector.Location.Left
				expanded: PageManager.expandLayout
				animateGeometry: PageManager.animatingIdleResize
				animationRunning: !!dcGeneratorWidget.input
						  && !isNaN(dcGeneratorWidget.input.current)
						  && dcGeneratorWidget.input.current > 0
				straight: dcGeneratorWidget.size > OverviewWidget.Size.M
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
				parent: root
				startWidget: alternatorWidget
				startLocation: WidgetConnector.Location.Right
				endWidget: batteryWidget
				endLocation: WidgetConnector.Location.Left
				expanded: PageManager.expandLayout
				animateGeometry: PageManager.animatingIdleResize
				animationRunning: !!alternatorWidget.input
						  && !isNaN(alternatorWidget.input.current)
						  && alternatorWidget.input.current > 0
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
				parent: root
				startWidget: windWidget
				startLocation: WidgetConnector.Location.Right
				endWidget: batteryWidget
				endLocation: WidgetConnector.Location.Left
				expanded: PageManager.expandLayout
				animateGeometry: PageManager.animatingIdleResize
				animationRunning: !!windWidget.input
						  && !isNaN(windWidget.input.current)
						  && windWidget.input.current > 0
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

			value: solarChargers ? solarChargers.power : 0  // TODO show amps instead if configured
			yieldHistory: solarChargers.yieldHistory

			WidgetConnector {
				parent: root
				startWidget: solarWidget
				startLocation: WidgetConnector.Location.Right
				endWidget: inverterWidget
				endLocation: WidgetConnector.Location.Left
				expanded: PageManager.expandLayout
				animateGeometry: PageManager.animatingIdleResize
				animationRunning: solarChargers && !isNaN(solarChargers.power)
			}
			WidgetConnector {
				parent: root
				startWidget: solarWidget
				startLocation: WidgetConnector.Location.Right
				endWidget: batteryWidget
				endLocation: WidgetConnector.Location.Left
				expanded: PageManager.expandLayout
				animateGeometry: PageManager.animatingIdleResize
				animationRunning: solarChargers && !isNaN(solarChargers.power)
						  && battery && !battery.idle
			}
		}
	}

	// the two central widgets are always present
	InverterWidget {
		id: inverterWidget
		anchors.horizontalCenter: parent.horizontalCenter
		size: OverviewWidget.Size.L
		expanded: PageManager.expandLayout
		animateGeometry: PageManager.animatingIdleResize
		physicalQuantity: -1
		systemState: system ? system.state : 0
	}
	WidgetConnector {
		startWidget: inverterWidget
		startLocation: WidgetConnector.Location.Right
		endWidget: acLoadsWidget
		endLocation: WidgetConnector.Location.Left
		expanded: PageManager.expandLayout
		animateGeometry: PageManager.animatingIdleResize
		animationRunning: acLoadsWidget.input != undefined
		straight: true
	}
	WidgetConnector {
		startWidget: inverterWidget
		startLocation: WidgetConnector.Location.Bottom
		endWidget: batteryWidget
		endLocation: WidgetConnector.Location.Top
		expanded: PageManager.expandLayout
		animateGeometry: PageManager.animatingIdleResize
		animationRunning: batteryWidget.batteryData && !batteryWidget.batteryData.idle
	}

	BatteryWidget {
		id: batteryWidget
		anchors.horizontalCenter: parent.horizontalCenter
		size: OverviewWidget.Size.L
		expanded: PageManager.expandLayout
		animateGeometry: PageManager.animatingIdleResize
		animationRunning: PageManager.navBar.currentUrl === "qrc:/pages/OverviewPage.qml"
		batteryData: battery
	}
	WidgetConnector {
		startWidget: batteryWidget
		startLocation: WidgetConnector.Location.Right
		endWidget: dcLoadsWidget
		endLocation: WidgetConnector.Location.Left
		expanded: PageManager.expandLayout
		animateGeometry: PageManager.animatingIdleResize
		animationRunning: batteryWidget.batteryData && !batteryWidget.batteryData.idle
	}

	// the two output widgets are always present
	AcLoadsWidget {
		id: acLoadsWidget
		anchors {
			right: parent.right
			rightMargin: Theme.geometry.page.grid.horizontalMargin
		}
		size: dcLoadsWidget.size === OverviewWidget.Size.Zero
			  ? OverviewWidget.Size.XL
			  : OverviewWidget.Size.L
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
		size: !!system && !isNaN(system.dc.power) ? OverviewWidget.Size.L : OverviewWidget.Size.Zero
		expanded: PageManager.expandLayout
		animateGeometry: PageManager.animatingIdleResize
		value: system ? system.dc.power || 0 : 0
	}
}
