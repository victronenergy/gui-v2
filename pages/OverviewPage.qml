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
	readonly property bool _shouldResetLeftWidgets: (acInputs && acInputs.model.count)
			|| (dcInputs && dcInputs.model.count)
			|| (solarChargers && solarChargers.model.count)
	on_ShouldResetLeftWidgetsChanged: Qt.callLater(_resetLeftWidgets)

	property var _createdWidgets: ({})

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

	function _widgetForType(widgetType) {
		for (let i = 0; i < _leftWidgets.length; ++i) {
			if (_leftWidgets[i].type === widgetType) {
				return _leftWidgets[i]
			}
		}
		return null
	}

	function _leftWidgetTopAnchor(widget) {
		if (_leftWidgets.length == 1) {
			return widget.parent.top
		}
		const widgetIndex = _leftWidgetOrder.indexOf(widget.type)
		if (widgetIndex < 0) {
			console.warn("Error: unknown widget", widget, widget.type)
			return undefined
		}
		if (widgetIndex == 0) {
			return widget.parent.top
		}
		for (let i = widgetIndex-1; i >= 0; i--) {
			const w = _widgetForType(_leftWidgetOrder[i])
			if (w && w.visible) {
				return w.bottom
			}
		}
		return widget.parent.top
	}

	function _widgetSize(widget) {
		if (_leftWidgets.indexOf(widget) < 0) {
			return OverviewWidget.Size.Zero
		}
		switch (_leftWidgets.length) {
		case 1:
			return OverviewWidget.Size.XL
		case 2:
			return OverviewWidget.Size.L
		case 3:
		case 4:
			// If this widget has extraContent, prefer L size, unless there is a previous widget
			// in a L size.
			const reducedSize = _leftWidgets.length == 3 ? OverviewWidget.Size.M : OverviewWidget.Size.XS
			let i = 0
			if (widget.extraContent.children.length > 0) {
				let widgetIndex = _leftWidgetOrder.indexOf(widget.type)
				if (widgetIndex < 0) {
					console.warn("Error: unknown widget", widget, widget.type)
					return reducedSize
				}
				for (i = 0; i < widgetIndex; ++i) {
					const w = _widgetForType(_leftWidgetOrder[i])
					if (w && w.size >= OverviewWidget.Size.L) {
						return reducedSize
					}
				}
				return OverviewWidget.Size.L
			} else {
				// If there are any other widgets in a large size, return the reduced size
				for (i = 0; i < _leftWidgets.length; ++i) {
					if (_leftWidgets[i] != widget && _leftWidgets[i].size >= OverviewWidget.Size.L) {
						return reducedSize
					}
				}
			}
			// There are no large widgets; use the same size for all left widgets
			return _leftWidgets.length == 3 ? OverviewWidget.Size.M : OverviewWidget.Size.S
		default:
			return OverviewWidget.Size.XS
		}
	}

	function _leftWidgetTopMargin(widget) {
		if (_leftWidgets.length == 0 || _leftWidgets.indexOf(widget) == 0) {
			return 0
		}
		let totalWidgetHeight = 0
		for (let i = 0; i < _leftWidgets.length; ++i) {
			totalWidgetHeight += _leftWidgets[i].height
		}
		let availableHeight = batteryWidget.y + batteryWidget.height
		return (availableHeight - totalWidgetHeight) / (_leftWidgets.length - 1)
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
				top: _leftWidgetTopAnchor(gridWidget)
				topMargin: _leftWidgetTopMargin(gridWidget)
				left: parent.left
				leftMargin: Theme.geometry.page.grid.horizontalMargin
			}
			width: Theme.geometry.overviewPage.widget.input.width
			height: PageManager.interactivity === PageManager.InteractionMode.Idle ? nonInteractiveHeight : interactiveHeight
			size: _widgetSize(gridWidget)
			isSegment: segmentedBackground.visible
			sideGaugeValue: value / Utils.maximumValue("grid.power")

			WidgetConnector {
				parent: root
				startWidget: gridWidget
				startLocation: WidgetConnector.Location.Right
				endWidget: inverterWidget
				endLocation: WidgetConnector.Location.Left
				animationRunning: !!gridWidget.input && gridWidget.input.connected
				animationPaused: PageManager.animatingIdleResize
				straight: gridWidget.size > OverviewWidget.Size.M
			}
		}
	}

	Component {
		id: shoreComponent

		ShoreWidget {
			id: shoreWidget

			anchors {
				top: _leftWidgetTopAnchor(shoreWidget)
				topMargin: _leftWidgetTopMargin(shoreWidget)
				left: parent.left
				leftMargin: Theme.geometry.page.grid.horizontalMargin
			}
			width: Theme.geometry.overviewPage.widget.input.width
			height: PageManager.interactivity === PageManager.InteractionMode.Idle ? nonInteractiveHeight : interactiveHeight
			size: _widgetSize(shoreWidget)
			isSegment: segmentedBackground.visible
			sideGaugeValue: 0.5 // TODO when max available

			WidgetConnector {
				parent: root
				startWidget: shoreWidget
				startLocation: WidgetConnector.Location.Right
				endWidget: inverterWidget
				endLocation: WidgetConnector.Location.Left
				animationRunning: !!shoreWidget.input && shoreWidget.input.connected
				animationPaused: PageManager.animatingIdleResize
				straight: shoreWidget.size > OverviewWidget.Size.M
			}
		}
	}

	Component {
		id: acGeneratorComponent

		AcGeneratorWidget {
			id: acGeneratorWidget

			anchors {
				top: _leftWidgetTopAnchor(acGeneratorWidget)
				topMargin: _leftWidgetTopMargin(acGeneratorWidget)
				left: parent.left
				leftMargin: Theme.geometry.page.grid.horizontalMargin
			}
			width: Theme.geometry.overviewPage.widget.input.width
			height: PageManager.interactivity === PageManager.InteractionMode.Idle ? nonInteractiveHeight : interactiveHeight
			size: _widgetSize(acGeneratorWidget)
			isSegment: segmentedBackground.visible

			WidgetConnector {
				parent: root
				startWidget: acGeneratorWidget
				startLocation: WidgetConnector.Location.Right
				endWidget: inverterWidget
				endLocation: WidgetConnector.Location.Left
				animationRunning: !!acGeneratorWidget.input && acGeneratorWidget.input.connected
				animationPaused: PageManager.animatingIdleResize
				straight: acGeneratorWidget.size > OverviewWidget.Size.M
			}
		}
	}

	Component {
		id: dcGeneratorComponent

		DcGeneratorWidget {
			id: dcGeneratorWidget

			anchors {
				top: _leftWidgetTopAnchor(dcGeneratorWidget)
				topMargin: _leftWidgetTopMargin(dcGeneratorWidget)
				left: parent.left
				leftMargin: Theme.geometry.page.grid.horizontalMargin
			}
			width: Theme.geometry.overviewPage.widget.input.width
			height: PageManager.interactivity === PageManager.InteractionMode.Idle ? nonInteractiveHeight : interactiveHeight
			size: _widgetSize(dcGeneratorWidget)
			isSegment: segmentedBackground.visible

			WidgetConnector {
				parent: root
				startWidget: dcGeneratorWidget
				startLocation: WidgetConnector.Location.Right
				endWidget: batteryWidget
				endLocation: WidgetConnector.Location.Left
				animationRunning: !!dcGeneratorWidget.input
				animationPaused: PageManager.animatingIdleResize
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
				top: _leftWidgetTopAnchor(alternatorWidget)
				topMargin: _leftWidgetTopMargin(alternatorWidget)
				left: parent.left
				leftMargin: Theme.geometry.page.grid.horizontalMargin
			}
			width: Theme.geometry.overviewPage.widget.input.width
			height: PageManager.interactivity === PageManager.InteractionMode.Idle ? nonInteractiveHeight : interactiveHeight
			size: _widgetSize(alternatorWidget)
			isSegment: segmentedBackground.visible

			WidgetConnector {
				parent: root
				startWidget: alternatorWidget
				startLocation: WidgetConnector.Location.Right
				endWidget: batteryWidget
				endLocation: WidgetConnector.Location.Left
				animationRunning: !!alternatorWidget.input
				animationPaused: PageManager.animatingIdleResize
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
				top: _leftWidgetTopAnchor(windWidget)
				topMargin: _leftWidgetTopMargin(windWidget)
				left: parent.left
				leftMargin: Theme.geometry.page.grid.horizontalMargin
			}
			width: Theme.geometry.overviewPage.widget.input.width
			height: PageManager.interactivity === PageManager.InteractionMode.Idle ? nonInteractiveHeight : interactiveHeight
			size: _widgetSize(windWidget)
			isSegment: segmentedBackground.visible

			WidgetConnector {
				parent: root
				startWidget: windWidget
				startLocation: WidgetConnector.Location.Right
				endWidget: batteryWidget
				endLocation: WidgetConnector.Location.Left
				animationRunning: !!windWidget.input
				animationPaused: PageManager.animatingIdleResize
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
				top: _leftWidgetTopAnchor(solarWidget)
				topMargin: _leftWidgetTopMargin(solarWidget)
				left: parent.left
				leftMargin: Theme.geometry.page.grid.horizontalMargin
			}
			width: Theme.geometry.overviewPage.widget.input.width
			height: PageManager.interactivity === PageManager.InteractionMode.Idle ? nonInteractiveHeight : interactiveHeight
			size: _widgetSize(solarWidget)
			isSegment: segmentedBackground.visible

			value: solarChargers ? solarChargers.power : 0  // TODO show amps instead if configured
			yieldHistory: solarChargers.yieldHistory

			WidgetConnector {
				parent: root
				startWidget: solarWidget
				startLocation: WidgetConnector.Location.Right
				endWidget: inverterWidget
				endLocation: WidgetConnector.Location.Left
				animationRunning: solarChargers && !isNaN(solarChargers.power)
				animationPaused: PageManager.animatingIdleResize
			}
			WidgetConnector {
				parent: root
				startWidget: solarWidget
				startLocation: WidgetConnector.Location.Right
				endWidget: batteryWidget
				endLocation: WidgetConnector.Location.Left
				animationRunning: solarChargers && !isNaN(solarChargers.power)
				animationPaused: PageManager.animatingIdleResize
						  && battery && !battery.idle
			}
		}
	}

	// the two central widgets are always present
	InverterWidget {
		id: inverterWidget
		anchors {
			top: parent.top
			horizontalCenter: parent.horizontalCenter
		}
		size: OverviewWidget.Size.L
		width: Theme.geometry.overviewPage.widget.inverter.width
		height: PageManager.interactivity === PageManager.InteractionMode.Idle ? nonInteractiveHeight : interactiveHeight
		physicalQuantity: -1
		systemState: system ? system.state : 0
	}
	WidgetConnector {
		startWidget: inverterWidget
		startLocation: WidgetConnector.Location.Right
		endWidget: acLoadsWidget
		endLocation: WidgetConnector.Location.Left
		animationRunning: acLoadsWidget.input != undefined
		animationPaused: PageManager.animatingIdleResize
		straight: true
	}
	WidgetConnector {
		startWidget: inverterWidget
		startLocation: WidgetConnector.Location.Bottom
		endWidget: batteryWidget
		endLocation: WidgetConnector.Location.Top
		animationRunning: batteryWidget.batteryData && !batteryWidget.batteryData.idle
		animationPaused: PageManager.animatingIdleResize
	}

	BatteryWidget {
		id: batteryWidget
		anchors {
			top: inverterWidget.bottom
			topMargin: Theme.geometry.overviewPage.layout.topMargin
			horizontalCenter: parent.horizontalCenter
		}
		size: OverviewWidget.Size.L
		width: Theme.geometry.overviewPage.widget.battery.width
		height: PageManager.interactivity === PageManager.InteractionMode.Idle ? nonInteractiveHeight : interactiveHeight
		animationRunning: PageManager.navBar.currentUrl === "qrc:/pages/OverviewPage.qml"
		animationPaused: PageManager.animatingIdleResize
		batteryData: battery
	}
	WidgetConnector {
		startWidget: batteryWidget
		startLocation: WidgetConnector.Location.Right
		endWidget: dcLoadsWidget
		endLocation: WidgetConnector.Location.Left
		animationRunning: batteryWidget.batteryData && !batteryWidget.batteryData.idle
		animationPaused: PageManager.animatingIdleResize
	}

	// the two output widgets are always present
	AcLoadsWidget {
		id: acLoadsWidget
		anchors {
			top: parent.top
			right: parent.right
			rightMargin: Theme.geometry.page.grid.horizontalMargin
		}
		size: dcLoadsWidget.size === OverviewWidget.Size.Zero
			  ? OverviewWidget.Size.XL
			  : OverviewWidget.Size.L
		width: Theme.geometry.overviewPage.widget.output.width
		height: PageManager.interactivity === PageManager.InteractionMode.Idle ? nonInteractiveHeight : interactiveHeight
		value: system ? system.ac.consumption.power : NaN
		phaseModel: system ? system.ac.consumption.phases : null
		phaseModelProperty: "power"
	}

	DcLoadsWidget {
		id: dcLoadsWidget
		anchors {
			top: acLoadsWidget.bottom
			topMargin: Theme.geometry.overviewPage.layout.topMargin
			right: parent.right
			rightMargin: Theme.geometry.page.grid.horizontalMargin
		}
		size: !!system && !isNaN(system.dc.power) ? OverviewWidget.Size.L : OverviewWidget.Size.Zero
		width: Theme.geometry.overviewPage.widget.output.width
		height: PageManager.interactivity === PageManager.InteractionMode.Idle ? nonInteractiveHeight : interactiveHeight
		value: system ? system.dc.power || 0 : 0
	}
}
