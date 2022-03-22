/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib
import Victron.VenusOS

QtObject {
	id: root

	property var configs: [
		{
			name: "Double gauge",
			inputs: [ { customName: "Refrigerator", temperature: 4.4223, humidity: 32.6075 } ]
		},
		{
			name: "Double gauge x 2",
			inputs: [
				{ customName: "Refrigerator", temperature: 4.4, humidity: 32.6075 },
				{ customName: "Freezer", temperature: -18.2, humidity: 28.921 },
			]
		},
		{
			name: "Double gauge x 3",
			inputs: [
				{ customName: "Refrigerator", temperature: -30, humidity: 0 },
				{ customName: "Freezer", temperature: 0, humidity: 50 },
				{ customName: "Sensor", temperature: 50, humidity: 100 }
			]
		},
		{
			name: "Double gauge x 4",
			inputs: [
				{ customName: "Refrigerator", temperature: 4.4, humidity: 32.6075 },
				{ customName: "Freezer", temperature: -18.2, humidity: 28.921 },
				{ customName: "Sensor A", temperature: 48.4122, humidity: 5.2 },
				{ customName: "Sensor B", temperature: 68.2, humidity: 7.3 },
			]
		},
		{
			name: "Mix single/double gauge layouts",
			inputs: [
				{ customName: "Refrigerator", temperature: 4.4, humidity: 32.6075 },
				{ customName: "Freezer", temperature: -18.2, humidity: 28.921 },
				{ customName: "Sensor A", temperature: 12, humidity: NaN },
				{ customName: "Sensor B", temperature: 52, humidity: NaN },
				{ customName: "Sensor C", temperature: 72, humidity: NaN },
			]
		},
		{
			name: "Single gauge",
			inputs: [ { customName: "Water tank", temperature: 17, humidity: NaN } ]
		},
		{
			name: "Single gauge x 2",
			inputs: [
				{ customName: "Water tank", temperature: 17, humidity: NaN },
				{ customName: "Sensor A", temperature: 54.2124, humidity: NaN },
			]
		},
		{
			name: "Single gauge x 3",
			inputs: [
				{ customName: "Water tank", temperature: 17, humidity: NaN },
				{ customName: "Sensor A", temperature: 64, humidity: NaN },
				{ customName: "Sensor B", temperature: 23.822, humidity: NaN },
			]
		},
		{
			name: "Single gauge x 4",
			inputs: [
				{ customName: "Sensor A", temperature: 14.12, humidity: NaN },
				{ customName: "Sensor B", temperature: 45.3234, humidity: NaN },
				{ customName: "Sensor C", temperature: -13.1123, humidity: NaN },
				{ customName: "Sensor D", temperature: 100, humidity: NaN },
			]
		},
		{
			name: "Single gauge x 5",
			inputs: [
				{ customName: "Sensor A", temperature: 64.12, humidity: NaN },
				{ customName: "Sensor B", temperature: 45.3234, humidity: NaN },
				{ customName: "Sensor C", temperature: 23.1123, humidity: NaN },
				{ customName: "Sensor D", temperature: 100, humidity: NaN },
				{ customName: "Sensor E", temperature: 0, humidity: NaN },
			]
		},
		{
			name: "Single gauge x 6",
			inputs: [
				{ customName: "Sensor A", temperature: 64.12, humidity: NaN },
				{ customName: "Sensor B", temperature: 45.3234, humidity: NaN },
				{ customName: "Sensor C", temperature: 23.1123 , humidity: NaN },
				{ customName: "Sensor D", temperature: 100, humidity: NaN },
				{ customName: "Sensor E", temperature: 0, humidity: NaN },
				{ customName: "Sensor F", temperature: 43.35 , humidity: NaN },
			]
		},
		{
			name: "Single gauge x 7",
			inputs: [
				{ customName: "Sensor A", temperature: 64.12 , humidity: NaN },
				{ customName: "Sensor B", temperature: 45.3234 , humidity: NaN },
				{ customName: "Sensor C", temperature: 23.1123 , humidity: NaN },
				{ customName: "Sensor D", temperature: 100, humidity: NaN },
				{ customName: "Sensor E", temperature: 0, humidity: NaN },
				{ customName: "Sensor F", temperature: 43.35, humidity: NaN },
				{ customName: "Sensor G", temperature: 23.35, humidity: NaN },     // scrolls off screen
			]
		},
	]

	function loadConfig(config) {
		environmentLevels.model.clear()
		for (let i = 0; i < config.inputs.length; ++i) {
			environmentLevels.addInput(config.inputs[i])
		}
	}

	function reset() {
		environmentLevels.populate()
	}
}
