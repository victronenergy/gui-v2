/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	// TODO: integrate with real data model.
	property var _dataModel: ({
		"inputs": {
			"count": 2,
			"grid": {
				"widgetSize": "L",
				"L1": 140,
				"L2": 260,
				"L3": 32,
			},
			"solar": {
				"widgetSize": "L",
				"instantaneous": 2001,
				"today": 603000,
				"history": [13400, 18500, 16200, 12100, 9300, 6600, 3200, 1040, 4400, 8800]
			}
		}
	})

	function _widgetSize(sizeStr) {
		switch (sizeStr) {
		case "XS": return OverviewWidget.Size.XS
		case "S": return OverviewWidget.Size.S
		case "M": return OverviewWidget.Size.M
		case "L": return OverviewWidget.Size.L
		case "XL": return OverviewWidget.Size.XL
		default: return OverviewWidget.Size.Zero
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
		size: visible ? _widgetSize(dataModel.widgetSize) : _widgetSize("Zero")
		dataModel: _dataModel.inputs.grid
	}
	ShoreWidget {
		id: shoreWidget
		anchors {
			top: gridWidget.visible ? gridWidget.bottom : parent.top
			topMargin: !gridWidget.visible ? 0 : 8 // TODO: we need layouts defined via theme for different cases..
			left: parent.left
			leftMargin: Theme.geometry.page.grid.horizontalMargin
		}

		visible: !segmentedWidget.visible && dataModel != undefined
		width: Theme.geometry.overviewPage.widget.input.width
		size: visible ? _widgetSize(dataModel.widgetSize) : _widgetSize("Zero")
		dataModel: _dataModel.inputs.shore
	}
	GeneratorWidget {
		id: generatorWidget
		anchors {
			top: shoreWidget.visible ? shoreWidget.bottom
			   : gridWidget.visible ? gridWidget.bottom
			   : parent.top
			topMargin: !shoreWidget.visible && !gridWidget.visible ? 0 : 8 // TODO: we need layouts defined via theme for different cases..
			left: parent.left
			leftMargin: Theme.geometry.page.grid.horizontalMargin
		}

		visible: !segmentedWidget.visible && dataModel != undefined
		width: Theme.geometry.overviewPage.widget.input.width
		size: visible ? _widgetSize(dataModel.widgetSize) : _widgetSize("Zero")
		dataModel: _dataModel.inputs.generator
	}
	AlternatorWidget {
		id: alternatorWidget
		anchors {
			top: generatorWidget.visible ? generatorWidget.bottom
			   : shoreWidget.visible ? shoreWidget.bottom
			   : gridWidget.visible ? gridWidget.bottom
			   : parent.top
			topMargin: !generatorWidget.visible && !shoreWidget.visible && !gridWidget.visible ? 0 : 8 // TODO: we need layouts defined via theme for different cases..
			left: parent.left
			leftMargin: Theme.geometry.page.grid.horizontalMargin
		}

		visible: !segmentedWidget.visible && dataModel != undefined
		width: Theme.geometry.overviewPage.widget.input.width
		size: visible ? _widgetSize(dataModel.widgetSize) : _widgetSize("Zero")
		dataModel: _dataModel.inputs.alternator
	}
	SolarYieldWidget {
		id: solarWidget
		anchors {
			top: alternatorWidget.visible ? alternatorWidget.bottom
			   : generatorWidget.visible ? generatorWidget.bottom
			   : shoreWidget.visible ? shoreWidget.bottom
			   : gridWidget.visible ? gridWidget.bottom
			   : parent.top
			topMargin: !alternatorWidget.visible && !generatorWidget.visible && !shoreWidget.visible && !gridWidget.visible ? 0 : 8 // TODO: we need layouts defined via theme for different cases..
			left: parent.left
			leftMargin: Theme.geometry.page.grid.horizontalMargin
		}

		visible: !segmentedWidget.visible && dataModel != undefined
		width: Theme.geometry.overviewPage.widget.input.width
		size: visible ? _widgetSize(dataModel.widgetSize) : _widgetSize("Zero")
		dataModel: _dataModel.inputs.solar
	}
	WindWidget {
		id: windWidget
		anchors {
			top: solarWidget.visible ? solarWidget.bottom
			   : alternatorWidget.visible ? alternatorWidget.bottom
			   : generatorWidget.visible ? generatorWidget.bottom
			   : shoreWidget.visible ? shoreWidget.bottom
			   : gridWidget.visible ? gridWidget.bottom
			   : parent.top
			topMargin: !solarWidget.visible && !generatorWidget.visible && !shoreWidget.visible && !gridWidget.visible ? 0 : 8 // TODO: we need layouts defined via theme for different cases..
			left: parent.left
			leftMargin: Theme.geometry.page.grid.horizontalMargin
		}

		visible: !segmentedWidget.visible && dataModel != undefined
		width: Theme.geometry.overviewPage.widget.input.width
		size: visible ? _widgetSize(dataModel.widgetSize) : _widgetSize("Zero")
		dataModel: _dataModel.inputs.wind
	}

	// the two central widgets are always present
	InverterWidget {
		anchors {
			top: parent.top
			horizontalCenter: parent.horizontalCenter
		}
		size: OverviewWidget.Size.L
		width: Theme.geometry.overviewPage.widget.inverter.width
	}

	BatteryWidget {
		anchors {
			bottom: parent.bottom
			bottomMargin: 8
			horizontalCenter: parent.horizontalCenter
		}
		size: OverviewWidget.Size.L
		width: Theme.geometry.overviewPage.widget.battery.width
	}

	// the two output widgets are always present
	AcLoadsWidget {
		anchors {
			top: parent.top
			right: parent.right
			rightMargin: Theme.geometry.page.grid.horizontalMargin
		}
		size: OverviewWidget.Size.L
		width: Theme.geometry.overviewPage.widget.output.width
	}

	DcLoadsWidget {
		anchors {
			bottom: parent.bottom
			bottomMargin: 8
			right: parent.right
			rightMargin: Theme.geometry.page.grid.horizontalMargin
		}
		size: OverviewWidget.Size.L
		width: Theme.geometry.overviewPage.widget.output.width
	}
}
