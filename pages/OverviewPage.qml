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
			|| (solarChargers && solarChargers.model.count)
	on_ShouldResetLeftWidgetsChanged: Qt.callLater(_resetLeftWidgets)

	function _resetLeftWidgets() {
		if (!acInputs) {
			_leftWidgets = []
			return
		}

		let widgetCandidates = []
		for (let i = 0; i < acInputs.model.count; ++i) {
			let input = acInputs.model.get(i).input
			let widget = null
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
			widget.dataModel = input
			widgetCandidates.splice(_leftWidgetInsertionIndex(widget, widgetCandidates), 0, widget)
		}

		// TODO add DC inputs (DC generator, alternator, wind) when dbus backend available

		if (solarChargers && solarChargers.model.count > 0) {
			widgetCandidates.splice(_leftWidgetInsertionIndex(solarWidget, widgetCandidates), 0, solarWidget)
		}
		_leftWidgets = widgetCandidates
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
			// If this widget has extraContent, prefer L size, unless there is already another
			// widget in a L size.
			if (widget.extraContent.children.length > 0) {
				let widgetIndex = _leftWidgetOrder.indexOf(widget)
				if (widgetIndex < 0) {
					console.warn("Error: unknown widget")
					return OverviewWidget.Size.M
				}
				for (let i = 0; i < widgetIndex; ++i) {
					if (_leftWidgetOrder[i].size >= OverviewWidget.Size.L) {
						return OverviewWidget.Size.M
					}
				}
				return OverviewWidget.Size.L
			}
			return OverviewWidget.Size.M
		case 4:
			return OverviewWidget.Size.S
		case 5:
			return OverviewWidget.Size.XS
		}
		return OverviewWidget.Size.L
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

		value: dataModel ? dataModel.power : NaN
		sideGaugeValue: value / Utils.maximumValue("grid.power")
		phaseModel: dataModel ? dataModel.phases : null
		phaseModelProperty: "power"
		overviewPageInteractive: root.interactive
	}
	WidgetConnector {
		startWidget: gridWidget
		startLocation: WidgetConnector.Location.Right
		endWidget: inverterWidget
		endLocation: WidgetConnector.Location.Left
		animated: !!gridWidget.dataModel && gridWidget.dataModel.connected
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

		value: dataModel ? dataModel.power : NaN
		sideGaugeValue: 0.5 // TODO when max available
		phaseModel: dataModel ? dataModel.phases : null
		phaseModelProperty: "power"
		overviewPageInteractive: root.interactive
	}
	WidgetConnector {
		startWidget: shoreWidget
		startLocation: WidgetConnector.Location.Right
		endWidget: inverterWidget
		endLocation: WidgetConnector.Location.Left
		animated: !!shoreWidget.dataModel && shoreWidget.dataModel.connected
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
		value: dataModel ? dataModel.power : NaN
		phaseModel: dataModel ? dataModel.phases : null
		phaseModelProperty: "power"
		overviewPageInteractive: root.interactive
	}
	WidgetConnector {
		startWidget: acGeneratorWidget
		startLocation: WidgetConnector.Location.Right
		endWidget: inverterWidget
		endLocation: WidgetConnector.Location.Left
		animated: !!acGeneratorWidget.dataModel && acGeneratorWidget.dataModel.connected
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

		// TODO
		value: 500
		overviewPageInteractive: root.interactive
	}
	WidgetConnector {
		startWidget: dcGeneratorWidget
		startLocation: WidgetConnector.Location.Right
		endWidget: batteryWidget
		endLocation: WidgetConnector.Location.Left
		animated: dcGeneratorWidget.dataModel != undefined // TODO
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

		value: 500 // TODO
		overviewPageInteractive: root.interactive
	}
	WidgetConnector {
		startWidget: alternatorWidget
		startLocation: WidgetConnector.Location.Right
		endWidget: batteryWidget
		endLocation: WidgetConnector.Location.Left
		animated: alternatorWidget.dataModel != undefined // TODO
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

		value: 500 // TODO
		overviewPageInteractive: root.interactive
	}
	WidgetConnector {
		startWidget: windWidget
		startLocation: WidgetConnector.Location.Right
		endWidget: batteryWidget
		endLocation: WidgetConnector.Location.Left
		animated: windWidget.dataModel != undefined // TODO
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

		value: solarChargers ? solarChargers.power : 0  // TODO show amps instead if configured
		dataModel: solarChargers
		overviewPageInteractive: root.interactive
	}
	WidgetConnector {
		startWidget: solarWidget
		startLocation: WidgetConnector.Location.Right
		endWidget: inverterWidget
		endLocation: WidgetConnector.Location.Left
		animated: solarChargers && solarChargers.power !== NaN
	}
	WidgetConnector {
		startWidget: solarWidget
		startLocation: WidgetConnector.Location.Right
		endWidget: batteryWidget
		endLocation: WidgetConnector.Location.Left
		animated: solarChargers && solarChargers.power !== NaN
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
	}
	WidgetConnector {
		startWidget: inverterWidget
		startLocation: WidgetConnector.Location.Right
		endWidget: acLoadsWidget
		endLocation: WidgetConnector.Location.Left
		animated: acLoadsWidget.dataModel != undefined
		straight: true
	}
	WidgetConnector {
		startWidget: inverterWidget
		startLocation: WidgetConnector.Location.Bottom
		endWidget: batteryWidget
		endLocation: WidgetConnector.Location.Top
		animated: true // TODO set based on the battery status?
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
		value: battery ? battery.stateOfCharge : 0
		dataModel: battery
	}
	WidgetConnector {
		startWidget: batteryWidget
		startLocation: WidgetConnector.Location.Right
		endWidget: dcLoadsWidget
		endLocation: WidgetConnector.Location.Left
		animated: dcLoadsWidget.dataModel != undefined
	}

	// the two output widgets are always present
	AcLoadsWidget {
		id: acLoadsWidget
		anchors {
			top: parent.top
			right: parent.right
			rightMargin: Theme.geometry.page.grid.horizontalMargin
		}
		size: OverviewWidget.Size.L
		width: Theme.geometry.overviewPage.widget.output.width
		overviewPageInteractive: root.interactive
		dataModel: system ? system.ac.consumption : null
		value: dataModel ? dataModel.power : NaN
		phaseModel: dataModel ? dataModel.phases : null
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
		size: OverviewWidget.Size.L
		width: Theme.geometry.overviewPage.widget.output.width
		overviewPageInteractive: root.interactive
		value: system ? system.dc.power : 0
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
