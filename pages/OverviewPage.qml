/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

Page {
	id: root

	property bool interactive: PageManager.navBar && !PageManager.navBar.hidden

	// TODO: integrate with real data model.
	property var _inputs: [
//        gridWidget,
//        shoreWidget,
//        dcGeneratorWidget,
		generatorWidget,
//        alternatorWidget,
//        windWidget,
		solarWidget
	]

	// Preferred order for the input widgets on the left hand side
	readonly property var _inputWidgetsOrder: [ gridWidget, shoreWidget, generatorWidget,
		dcGeneratorWidget, alternatorWidget, windWidget, solarWidget ]

	function _topAnchor(widget) {
		if (_inputs.length == 1) {
			return widget.parent.top
		}
		let widgetIndex = _inputWidgetsOrder.indexOf(widget)
		if (widgetIndex < 0) {
			console.warn("Error: unknown widget")
			return undefined
		}
		if (widgetIndex == 0) {
			return widget.parent.top
		}
		for (let i = widgetIndex-1; i >= 0; i--) {
			if (_inputWidgetsOrder[i].visible) {
				return _inputWidgetsOrder[i].bottom
			}
		}
		return widget.parent.top
	}

	function _widgetSize(widget) {
		if (_inputs.indexOf(widget) < 0) {
			return OverviewWidget.Size.Zero
		}
		switch (_inputs.length) {
		case 1:
			return OverviewWidget.Size.XL
		case 2:
			return OverviewWidget.Size.L
		case 3:
			// If this widget has extraContent, prefer L size, unless there is already another
			// widget in a L size.
			if (widget.extraContent.children.length > 0) {
				let widgetIndex = _inputWidgetsOrder.indexOf(widget)
				if (widgetIndex < 0) {
					console.warn("Error: unknown widget")
					return OverviewWidget.Size.M
				}
				for (let i = 0; i < widgetIndex; ++i) {
					if (_inputWidgetsOrder[i].size >= OverviewWidget.Size.L) {
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

	function _widgetMargin(widget) {
		if (_inputs.length == 0 || _inputs.indexOf(widget) == 0) {
			return 0
		}
		switch (_inputs.length) {
		case 2:
			return Theme.geometry.overviewPage.layout.two.topMargin
		case 3:
			return Theme.geometry.overviewPage.layout.three.topMargin
		case 4:
			return Theme.geometry.overviewPage.layout.four.topMargin
		}
		return 0
	}

	SegmentedWidgetBackground {
		anchors {
			top: parent.top
			left: parent.left
			leftMargin: Theme.geometry.page.grid.horizontalMargin
		}
		visible: _inputs.length >= 5
		segments: _inputs
	}

	GridWidget {
		id: gridWidget

		anchors {
			top: _topAnchor(gridWidget)
			topMargin: _widgetMargin(gridWidget)
			left: parent.left
			leftMargin: Theme.geometry.page.grid.horizontalMargin
		}
		width: Theme.geometry.overviewPage.widget.input.width
		size: _widgetSize(gridWidget)

		value: gridMeter ? gridMeter.power : 0
		dataModel: gridMeter ? gridMeter.model : null
		sideGaugeValue: value / Utils.maximumValue("grid.power")
		phaseValueProperty: "power"
		overviewPageInteractive: root.interactive
	}
	WidgetConnector {
		startWidget: gridWidget
		startLocation: WidgetConnector.Location.Right
		endWidget: inverterWidget
		endLocation: WidgetConnector.Location.Left
		animated: gridMeter && gridMeter.power !== NaN
		straight: gridWidget.size > OverviewWidget.Size.M
	}

	ShoreWidget {
		id: shoreWidget

		anchors {
			top: _topAnchor(shoreWidget)
			topMargin: _widgetMargin(shoreWidget)
			left: parent.left
			leftMargin: Theme.geometry.page.grid.horizontalMargin
		}
		width: Theme.geometry.overviewPage.widget.input.width
		size: _widgetSize(shoreWidget)

		 // TODO
		value: 500
		sideGaugeValue: 0.5
		dataModel: ListModel {
			ListElement { name: "L1"; power: 123 }
			ListElement { name: "L2"; power: 456 }
		}
		phaseValueProperty: "power"
		overviewPageInteractive: root.interactive
	}
	WidgetConnector {
		startWidget: shoreWidget
		startLocation: WidgetConnector.Location.Right
		endWidget: inverterWidget
		endLocation: WidgetConnector.Location.Left
		animated: shoreWidget.dataModel != undefined    // TODO
		straight: shoreWidget.size > OverviewWidget.Size.M
	}

	GeneratorWidget {
		id: generatorWidget

		anchors {
			top: _topAnchor(generatorWidget)
			topMargin: _widgetMargin(generatorWidget)
			left: parent.left
			leftMargin: Theme.geometry.page.grid.horizontalMargin
		}
		width: Theme.geometry.overviewPage.widget.input.width
		size: _widgetSize(generatorWidget)

		// TODO
		value: 500
		dataModel: ListModel {
			ListElement { name: "L1"; power: 123 }
			ListElement { name: "L2"; power: 456 }
		}
		phaseValueProperty: "power"

		overviewPageInteractive: root.interactive
	}
	WidgetConnector {
		startWidget: generatorWidget
		startLocation: WidgetConnector.Location.Right
		endWidget: inverterWidget
		endLocation: WidgetConnector.Location.Left
		animated: generatorWidget.dataModel != undefined // TODO
		straight: generatorWidget.size > OverviewWidget.Size.M
	}

	GeneratorWidget {
		id: dcGeneratorWidget

		anchors {
			top: _topAnchor(dcGeneratorWidget)
			topMargin: _widgetMargin(dcGeneratorWidget)
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
			top: _topAnchor(alternatorWidget)
			topMargin: _widgetMargin(alternatorWidget)
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
			top: _topAnchor(windWidget)
			topMargin: _widgetMargin(windWidget)
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
			top: _topAnchor(solarWidget)
			topMargin: _widgetMargin(solarWidget)
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
			topMargin: Theme.geometry.overviewPage.layout.two.topMargin
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
		value: system ? system.ac.consumptionPower : NaN
		dataModel: system ? system.ac.model : null
		phaseValueProperty: "consumptionPower"
	}

	DcLoadsWidget {
		id: dcLoadsWidget
		anchors {
			top: acLoadsWidget.bottom
			topMargin: Theme.geometry.overviewPage.layout.two.topMargin
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
