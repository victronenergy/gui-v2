/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

Page {
	id: root

	property bool interactive: PageManager.navBar && !PageManager.navBar.hidden

	property var _leftWidgets: []

	// Preferred order for the input widgets on the left hand side
	readonly property var _leftWidgetOrder: [ gridWidget, shoreWidget, acGeneratorWidget,
		dcGeneratorWidget, alternatorWidget, windWidget, solarWidget ]

	// Use a delayed binding to avoid repopulating the model unnecessarily
	readonly property bool _shouldResetLeftWidgets: (acInputs && acInputs.model.count)
			|| (dcInputs && dcInputs.model.count)
			|| (solarChargers && solarChargers.model.count)
	on_ShouldResetLeftWidgetsChanged: Qt.callLater(_resetLeftWidgets)

	function _resetLeftWidgets() {
		if (!acInputs) {
			_leftWidgets = []
			return
		}

		let widgetCandidates = []
		_addModelWidgets(acInputs.model, widgetCandidates)
		_addModelWidgets(dcInputs.model, widgetCandidates)

		if (solarChargers && solarChargers.model.count > 0) {
			widgetCandidates.splice(_leftWidgetInsertionIndex(solarWidget, widgetCandidates), 0, solarWidget)
		}
		_leftWidgets = widgetCandidates
	}

	function _addModelWidgets(inputModel, widgetCandidates) {
		for (let i = 0; i < inputModel.count; ++i) {
			let input = inputModel.get(i).input
			let widget = null
			if (inputModel === acInputs.model)  {
				switch (input.source) {
				case AcInputs.InputType.Grid:
					widget = gridWidget
					break
				case AcInputs.InputType.Generator:
					widget = acGeneratorWidget
					break
				case AcInputs.InputType.Shore:
					widget = shoreWidget
					break
				}
			} else {
				switch (input.source) {
				case DcInputs.InputType.Alternator:
					widget = alternatorWidget
					break
				case DcInputs.InputType.DcGenerator:
					widget = dcGeneratorWidget
					break
				case DcInputs.InputType.Wind:
					widget = windWidget
					break
				default:
					console.warn("Unknown AC/DC input type:", input.source, "for model:", inputModel)
					continue
				}
			}
			widget.input = input
			widgetCandidates.splice(_leftWidgetInsertionIndex(widget, widgetCandidates), 0, widget)
		}
	}

	function _leftWidgetInsertionIndex(widget, candidateArray) {
		const orderedIndex = _leftWidgetOrder.indexOf(widget)
		for (let i = 0; i < candidateArray.length; ++i) {
			if (orderedIndex < _leftWidgetOrder.indexOf(candidateArray[i])) {
				return i
			}
		}
		return candidateArray.length
	}

	function _leftWidgetTopAnchor(widget) {
		if (_leftWidgets.length == 1) {
			return widget.parent.top
		}
		let widgetIndex = _leftWidgetOrder.indexOf(widget)
		if (widgetIndex < 0) {
			console.warn("Error: unknown widget")
			return undefined
		}
		if (widgetIndex == 0) {
			return widget.parent.top
		}
		for (let i = widgetIndex-1; i >= 0; i--) {
			if (_leftWidgetOrder[i].visible) {
				return _leftWidgetOrder[i].bottom
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
				let widgetIndex = _leftWidgetOrder.indexOf(widget)
				if (widgetIndex < 0) {
					console.warn("Error: unknown widget")
					return reducedSize
				}
				for (i = 0; i < widgetIndex; ++i) {
					if (_leftWidgetOrder[i].size >= OverviewWidget.Size.L) {
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

	GridWidget {
		id: gridWidget

		anchors {
			top: _leftWidgetTopAnchor(gridWidget)
			topMargin: _leftWidgetTopMargin(gridWidget)
			left: parent.left
			leftMargin: Theme.geometry.page.grid.horizontalMargin
		}
		width: Theme.geometry.overviewPage.widget.input.width
		size: _widgetSize(gridWidget)
		overviewPageInteractive: root.interactive
		isSegment: segmentedBackground.visible
		sideGaugeValue: value / Utils.maximumValue("grid.power")
	}
	WidgetConnector {
		startWidget: gridWidget
		startLocation: WidgetConnector.Location.Right
		endWidget: inverterWidget
		endLocation: WidgetConnector.Location.Left
		animated: !!gridWidget.input && gridWidget.input.connected
		straight: gridWidget.size > OverviewWidget.Size.M
	}

	ShoreWidget {
		id: shoreWidget

		anchors {
			top: _leftWidgetTopAnchor(shoreWidget)
			topMargin: _leftWidgetTopMargin(shoreWidget)
			left: parent.left
			leftMargin: Theme.geometry.page.grid.horizontalMargin
		}
		width: Theme.geometry.overviewPage.widget.input.width
		size: _widgetSize(shoreWidget)
		overviewPageInteractive: root.interactive
		isSegment: segmentedBackground.visible
		sideGaugeValue: 0.5 // TODO when max available
	}
	WidgetConnector {
		startWidget: shoreWidget
		startLocation: WidgetConnector.Location.Right
		endWidget: inverterWidget
		endLocation: WidgetConnector.Location.Left
		animated: !!shoreWidget.input && shoreWidget.input.connected
		straight: shoreWidget.size > OverviewWidget.Size.M
	}

	AcGeneratorWidget {
		id: acGeneratorWidget

		anchors {
			top: _leftWidgetTopAnchor(acGeneratorWidget)
			topMargin: _leftWidgetTopMargin(acGeneratorWidget)
			left: parent.left
			leftMargin: Theme.geometry.page.grid.horizontalMargin
		}
		width: Theme.geometry.overviewPage.widget.input.width
		size: _widgetSize(acGeneratorWidget)
		overviewPageInteractive: root.interactive
		isSegment: segmentedBackground.visible
	}
	WidgetConnector {
		startWidget: acGeneratorWidget
		startLocation: WidgetConnector.Location.Right
		endWidget: inverterWidget
		endLocation: WidgetConnector.Location.Left
		animated: !!acGeneratorWidget.input && acGeneratorWidget.input.connected
		straight: acGeneratorWidget.size > OverviewWidget.Size.M
	}

	DcGeneratorWidget {
		id: dcGeneratorWidget

		anchors {
			top: _leftWidgetTopAnchor(dcGeneratorWidget)
			topMargin: _leftWidgetTopMargin(dcGeneratorWidget)
			left: parent.left
			leftMargin: Theme.geometry.page.grid.horizontalMargin
		}
		width: Theme.geometry.overviewPage.widget.input.width
		size: _widgetSize(dcGeneratorWidget)
		overviewPageInteractive: root.interactive
		isSegment: segmentedBackground.visible
	}
	WidgetConnector {
		startWidget: dcGeneratorWidget
		startLocation: WidgetConnector.Location.Right
		endWidget: batteryWidget
		endLocation: WidgetConnector.Location.Left
		animated: !!dcGeneratorWidget.input
				  && !isNaN(dcGeneratorWidget.input.current)
				  && dcGeneratorWidget.input.current > 0
		straight: dcGeneratorWidget.size > OverviewWidget.Size.M
	}

	AlternatorWidget {
		id: alternatorWidget

		anchors {
			top: _leftWidgetTopAnchor(alternatorWidget)
			topMargin: _leftWidgetTopMargin(alternatorWidget)
			left: parent.left
			leftMargin: Theme.geometry.page.grid.horizontalMargin
		}
		width: Theme.geometry.overviewPage.widget.input.width
		size: _widgetSize(alternatorWidget)
		overviewPageInteractive: root.interactive
		isSegment: segmentedBackground.visible
	}
	WidgetConnector {
		startWidget: alternatorWidget
		startLocation: WidgetConnector.Location.Right
		endWidget: batteryWidget
		endLocation: WidgetConnector.Location.Left
		animated: !!alternatorWidget.input
				  && !isNaN(alternatorWidget.input.current)
				  && alternatorWidget.input.current > 0
	}

	WindWidget {
		id: windWidget

		anchors {
			top: _leftWidgetTopAnchor(windWidget)
			topMargin: _leftWidgetTopMargin(windWidget)
			left: parent.left
			leftMargin: Theme.geometry.page.grid.horizontalMargin
		}
		width: Theme.geometry.overviewPage.widget.input.width
		size: _widgetSize(windWidget)
		overviewPageInteractive: root.interactive
		isSegment: segmentedBackground.visible
	}
	WidgetConnector {
		startWidget: windWidget
		startLocation: WidgetConnector.Location.Right
		endWidget: batteryWidget
		endLocation: WidgetConnector.Location.Left
		animated: !!windWidget.input
				  && !isNaN(windWidget.input.current)
				  && windWidget.input.current > 0
	}

	SolarYieldWidget {
		id: solarWidget

		anchors {
			top: _leftWidgetTopAnchor(solarWidget)
			topMargin: _leftWidgetTopMargin(solarWidget)
			left: parent.left
			leftMargin: Theme.geometry.page.grid.horizontalMargin
		}
		width: Theme.geometry.overviewPage.widget.input.width
		size: _widgetSize(solarWidget)
		isSegment: segmentedBackground.visible

		value: solarChargers ? solarChargers.power : 0  // TODO show amps instead if configured
		yieldHistory: solarChargers.yieldHistory
		overviewPageInteractive: root.interactive
	}
	WidgetConnector {
		startWidget: solarWidget
		startLocation: WidgetConnector.Location.Right
		endWidget: inverterWidget
		endLocation: WidgetConnector.Location.Left
		animated: solarChargers && !isNaN(solarChargers.power)
	}
	WidgetConnector {
		startWidget: solarWidget
		startLocation: WidgetConnector.Location.Right
		endWidget: batteryWidget
		endLocation: WidgetConnector.Location.Left
		animated: solarChargers && !isNaN(solarChargers.power)
				  && battery && !battery.idle
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
		overviewPageInteractive: root.interactive
		physicalQuantity: -1
		systemState: system ? system.state : 0
	}
	WidgetConnector {
		startWidget: inverterWidget
		startLocation: WidgetConnector.Location.Right
		endWidget: acLoadsWidget
		endLocation: WidgetConnector.Location.Left
		animated: acLoadsWidget.input != undefined
		straight: true
	}
	WidgetConnector {
		startWidget: inverterWidget
		startLocation: WidgetConnector.Location.Bottom
		endWidget: batteryWidget
		endLocation: WidgetConnector.Location.Top
		animated: batteryWidget.batteryData && !batteryWidget.batteryData.idle
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
		overviewPageInteractive: root.interactive
		batteryData: battery
	}
	WidgetConnector {
		startWidget: batteryWidget
		startLocation: WidgetConnector.Location.Right
		endWidget: dcLoadsWidget
		endLocation: WidgetConnector.Location.Left
		animated: batteryWidget.batteryData && !batteryWidget.batteryData.idle
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
		overviewPageInteractive: root.interactive
		value: system ? system.ac.consumption.power : NaN
		phaseModel: system ? system.ac.consumption.phases : null
		phaseModelProperty: "power"
	}

	property real thing: NaN

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
		overviewPageInteractive: root.interactive
		value: system ? system.dc.power || 0 : 0
	}

	MouseArea {
		id: idleModeMouseArea
		width: root.interactive ? 0 : root.width
		height: root.interactive ? 0 : root.height
		onClicked: {
			PageManager.controlsVisible = true
			PageManager.navBar.show()
			idleModeTimer.start()
		}
	}

	Timer {
		id: idleModeTimer
		running: PageManager.mainPageActive
			&& PageManager.navBar.currentUrl == "qrc:/pages/OverviewPage.qml"
			&& root.interactive
		interval: Theme.animation.overviewPage.interactive.timeout
		onTriggered: {
			PageManager.navBar.hide()
			PageManager.controlsVisible = false
		}
	}
}
