/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property bool interactive: PageManager.navBar && !PageManager.navBar.hidden

	// TODO: integrate with real data model.
	property var _dataModel: ({
		"inputs": {
			"count": 2,
			"grid": {
				"L1": 140,
				"L2": 260,
				"L3": 32,
			},
			"solar": {
				"instantaneous": 2001,
				"today": 603000,
				"history": [13400, 18500, 16200, 12100, 9300, 6600, 3200, 1040, 4400, 8800]
			}
		}
	})

	// determine the layout we should use, based on the
	// available data in the data model.
	property var _layoutName: _determineLayoutName()
	function _determineLayoutName() {
		if (_dataModel.inputs.count === 0) {
			return "zero"
		} else if (_dataModel.inputs.count === 1) {
			return "one"
		} else if (_dataModel.inputs.count === 2) {
			return "two"
		} else if (_dataModel.inputs.count === 3) {
			return "three"
		} else if (_dataModel.inputs.count === 4) {
			return "four"
		} else {
			return "segmented"
		}
	}

	function _isLastWidgetInTripleLayout(widgetType) {
		// figure out if we're the last active input
		var expectedOrder = ["grid", "shore", "generator", "alternator", "wind", "solar"]
		var activeCount = 0
		var isLast = false
		expectedOrder.foreach(function(value) {
			if (value == widgetType) {
				isLast = activeCount === 2
			}
			if (_dataModel.inputs[value] != undefined && !isLast) {
				activeCount++
			}
		})
		return isLast
	}

	function _widgetSize(widgetType) {
		if (_layoutName === "segmented"
				|| !Object.keys(_dataModel.inputs).includes(widgetType)) {
			return OverviewWidget.Size.Zero
		}

		var sizeStr = "Zero"
		if (_layoutName === "three") {
			sizeStr = _isLastWidgetInTripleLayout(widgetType)
				? Theme.geometry.overviewPage.layout.three.last.size
				: Theme.geometry.overviewPage.layout.three.size
		} else {
			sizeStr = Theme.geometry.overviewPage.layout[_layoutName].size
		}

		switch (sizeStr) {
		case "XS": return OverviewWidget.Size.XS
		case "S": return OverviewWidget.Size.S
		case "M": return OverviewWidget.Size.M
		case "L": return OverviewWidget.Size.L
		case "XL": return OverviewWidget.Size.XL
		default: return OverviewWidget.Size.Zero
		}
	}

	function _widgetMargin(widgetType) {
		if (_layoutName === "segmented"
				|| !Object.keys(_dataModel.inputs).includes(widgetType)) {
			return 0
		}

		if (_layoutName === "three") {
			return _isLastWidgetInTripleLayout(widgetType)
				? Theme.geometry.overviewPage.layout.three.last.topMargin
				: Theme.geometry.overviewPage.layout.three.topMargin
		} else {
			return Theme.geometry.overviewPage.layout[_layoutName].topMargin
		}
	}

	// the input widgets are dynamically populated from data model.
	SegmentedWidget {
		id: segmentedWidget
		anchors {
			top: parent.top
			left: parent.left
			leftMargin: Theme.geometry.page.grid.horizontalMargin
		}

		visible: _dataModel.count >= 5
		width: Theme.geometry.overviewPage.widget.input.width
		overviewPageInteractive: root.interactive
	}


	GridWidget {
		id: gridWidget
		anchors {
			top: parent.top
			left: parent.left
			leftMargin: Theme.geometry.page.grid.horizontalMargin
		}

		visible: !segmentedWidget.visible && dataModel != undefined
		width: Theme.geometry.overviewPage.widget.input.width
		size: visible ? _widgetSize("grid") : OverviewWidget.Size.Zero
		dataModel: _dataModel.inputs.grid
		overviewPageInteractive: root.interactive
	}
	ShoreWidget {
		id: shoreWidget
		anchors {
			top: gridWidget.visible ? gridWidget.bottom : parent.top
			topMargin: !gridWidget.visible ? 0 : _widgetMargin("shore")
			left: parent.left
			leftMargin: Theme.geometry.page.grid.horizontalMargin
		}

		visible: !segmentedWidget.visible && dataModel != undefined
		width: Theme.geometry.overviewPage.widget.input.width
		size: visible ? _widgetSize("shore") : OverviewWidget.Size.Zero
		dataModel: _dataModel.inputs.shore
		overviewPageInteractive: root.interactive
	}
	GeneratorWidget {
		id: generatorWidget
		anchors {
			top: shoreWidget.visible ? shoreWidget.bottom
			   : gridWidget.visible ? gridWidget.bottom
			   : parent.top
			topMargin: !shoreWidget.visible && !gridWidget.visible
				? 0 : _widgetMargin("generator")
			left: parent.left
			leftMargin: Theme.geometry.page.grid.horizontalMargin
		}

		visible: !segmentedWidget.visible && dataModel != undefined
		width: Theme.geometry.overviewPage.widget.input.width
		size: visible ? _widgetSize("generator") : OverviewWidget.Size.Zero
		dataModel: _dataModel.inputs.generator
		overviewPageInteractive: root.interactive
	}
	AlternatorWidget {
		id: alternatorWidget
		anchors {
			top: generatorWidget.visible ? generatorWidget.bottom
			   : shoreWidget.visible ? shoreWidget.bottom
			   : gridWidget.visible ? gridWidget.bottom
			   : parent.top
			topMargin: !generatorWidget.visible && !shoreWidget.visible && !gridWidget.visible
				? 0 : _widgetMargin("alternator")
			left: parent.left
			leftMargin: Theme.geometry.page.grid.horizontalMargin
		}

		visible: !segmentedWidget.visible && dataModel != undefined
		width: Theme.geometry.overviewPage.widget.input.width
		size: visible ? _widgetSize("alternator") : OverviewWidget.Size.Zero
		dataModel: _dataModel.inputs.alternator
		overviewPageInteractive: root.interactive
	}
	WindWidget {
		id: windWidget
		anchors {
			top: alternatorWidget.visible ? alternatorWidget.bottom
			   : generatorWidget.visible ? generatorWidget.bottom
			   : shoreWidget.visible ? shoreWidget.bottom
			   : gridWidget.visible ? gridWidget.bottom
			   : parent.top
			topMargin: !alternatorWidget.visible && !generatorWidget.visible && !shoreWidget.visible && !gridWidget.visible
				? 0 : _widgetMargin("wind")
			left: parent.left
			leftMargin: Theme.geometry.page.grid.horizontalMargin
		}

		visible: !segmentedWidget.visible && dataModel != undefined
		width: Theme.geometry.overviewPage.widget.input.width
		size: visible ? _widgetSize("wind") : OverviewWidget.Size.Zero
		dataModel: _dataModel.inputs.wind
		overviewPageInteractive: root.interactive
	}
	SolarYieldWidget {
		id: solarWidget
		anchors {
			top: windWidget.visible ? windWidget.bottom
			   : alternatorWidget.visible ? alternatorWidget.bottom
			   : generatorWidget.visible ? generatorWidget.bottom
			   : shoreWidget.visible ? shoreWidget.bottom
			   : gridWidget.visible ? gridWidget.bottom
			   : parent.top
			topMargin: !windWidget.visible && !alternatorWidget.visible && !generatorWidget.visible && !shoreWidget.visible && !gridWidget.visible
				? 0 : _widgetMargin("solar")
			left: parent.left
			leftMargin: Theme.geometry.page.grid.horizontalMargin
		}

		visible: !segmentedWidget.visible && dataModel != undefined
		width: Theme.geometry.overviewPage.widget.input.width
		size: visible ? _widgetSize("solar") : OverviewWidget.Size.Zero
		dataModel: _dataModel.inputs.solar
		overviewPageInteractive: root.interactive
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

	BatteryWidget {
		anchors {
			top: inverterWidget.bottom
			topMargin: Theme.geometry.overviewPage.layout.two.topMargin
			horizontalCenter: parent.horizontalCenter
		}
		size: OverviewWidget.Size.L
		width: Theme.geometry.overviewPage.widget.battery.width
		overviewPageInteractive: root.interactive
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
	}

	DcLoadsWidget {
		anchors {
			top: acLoadsWidget.bottom
			topMargin: Theme.geometry.overviewPage.layout.two.topMargin
			right: parent.right
			rightMargin: Theme.geometry.page.grid.horizontalMargin
		}
		size: OverviewWidget.Size.L
		width: Theme.geometry.overviewPage.widget.output.width
		overviewPageInteractive: root.interactive
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
