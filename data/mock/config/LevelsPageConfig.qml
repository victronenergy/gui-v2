/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property var tankConfigs: [
		{
			name: "Check Fuel colors",
			tanks: [
				{ type: VenusOS.Tank_Type_Fuel, level: 100, capacity: 1.1 },
				{ type: VenusOS.Tank_Type_Fuel, level: 75, capacity: 1 },
				{ type: VenusOS.Tank_Type_Fuel, level: 20, capacity: 1 },
				{ type: VenusOS.Tank_Type_Fuel, level: 10, capacity: 1 },
				{ type: VenusOS.Tank_Type_Fuel, level: 0, capacity: 1 },
			]
		},
		{
			name: "Check BlackWater colors (different from Fuel level colors)",
			tanks: [
				{ type: VenusOS.Tank_Type_BlackWater, level: 100, capacity: 1 },
				{ type: VenusOS.Tank_Type_BlackWater, level: 90, capacity: 1 },
				{ type: VenusOS.Tank_Type_BlackWater, level: 85, capacity: 1 },
				{ type: VenusOS.Tank_Type_BlackWater, level: 75, capacity: 1 },
				{ type: VenusOS.Tank_Type_BlackWater, level: 0, capacity: 1 },
			]
		},
		{
			name: "1 tank",
			tanks: [
				{ type: VenusOS.Tank_Type_Fuel, level: 46.34, capacity: 1 },
			],
		},
		{
			name: "2 tanks",
			tanks: [
				{ type: VenusOS.Tank_Type_Fuel, level: 46.34, capacity: 1 },
				{ type: VenusOS.Tank_Type_FreshWater, level: 50, capacity: 2 },
			],
		},
		{
			name: "3 tanks (two of same type)",
			tanks: [
				{ type: VenusOS.Tank_Type_Fuel, level: 16.34, capacity: 1 },
				{ type: VenusOS.Tank_Type_Fuel, level: 75.334, capacity: 1 },
				{ type: VenusOS.Tank_Type_FreshWater, level: 10, capacity: 2 },
			]
		},
		{
			name: "4 tanks (two of same type)",
			tanks: [
				{ type: VenusOS.Tank_Type_Fuel, level: 46.34, capacity: 1 },
				{ type: VenusOS.Tank_Type_Fuel, level: 75.334, capacity: 1 },
				{ type: VenusOS.Tank_Type_FreshWater, level: 10, capacity: 2 },
				{ type: VenusOS.Tank_Type_BlackWater, level: 25, capacity: .2 },
			]
		},
		{
			name: "5 tanks (two of same type)",
			tanks: [
				{ type: VenusOS.Tank_Type_Fuel, level: 46.34, capacity: 1 },
				{ type: VenusOS.Tank_Type_Fuel, level: 75.334, capacity: 1 },
				{ type: VenusOS.Tank_Type_FreshWater, level: 10, capacity: 2 },
				{ type: VenusOS.Tank_Type_WasteWater, level: 75, capacity: 1 },
				{ type: VenusOS.Tank_Type_BlackWater, level: 25, capacity: .2 },
			]
		},
		{
			name: "6 tanks (merge 2 Fuel tanks)",
			tanks: [
				{ type: VenusOS.Tank_Type_Fuel, level: 46.34, capacity: 1 },
				{ type: VenusOS.Tank_Type_Fuel, level: 75.334, capacity: 1 },
				{ type: VenusOS.Tank_Type_FreshWater, level: 10, capacity: 2 },
				{ type: VenusOS.Tank_Type_WasteWater, level: 75, capacity: 1 },
				{ type: VenusOS.Tank_Type_Oil, level: 80.2, capacity: .1 },
				{ type: VenusOS.Tank_Type_BlackWater, level: 25, capacity: .2 },
			]
		},
		{
			name: "7 tanks (merge 2 Freshwater tanks)",
			tanks: [
				{ type: VenusOS.Tank_Type_Fuel, level: 75.334, capacity: 1 },
				{ type: VenusOS.Tank_Type_FreshWater, level: 10, capacity: 2 },
				{ type: VenusOS.Tank_Type_FreshWater, level: 50, capacity: 2 },
				{ type: VenusOS.Tank_Type_Fuel, level: 75.334, capacity: 1 },
				{ type: VenusOS.Tank_Type_LiveWell, level: 20, capacity: 1 },
				{ type: VenusOS.Tank_Type_Oil, level: 80.2, capacity: .1 },
				{ type: VenusOS.Tank_Type_BlackWater, level: 25, capacity: .2 },
			]
		},
		{
			name: "8 tanks (merge 3 BlackWater tanks)",
			tanks: [
				{ type: VenusOS.Tank_Type_Fuel, level: 75.334, capacity: 1 },
				{ type: VenusOS.Tank_Type_FreshWater, level: 10, capacity: 2 },
				{ type: VenusOS.Tank_Type_FreshWater, level: 50, capacity: 2 },
				{ type: VenusOS.Tank_Type_Fuel, level: 75.334, capacity: 1 },
				{ type: VenusOS.Tank_Type_LiveWell, level: 20, capacity: 1 },
				{ type: VenusOS.Tank_Type_Oil, level: 80.2, capacity: .1 },
				{ type: VenusOS.Tank_Type_BlackWater, level: 25, capacity: .2 },
				{ type: VenusOS.Tank_Type_BlackWater, level: 50, capacity: .2 },
				{ type: VenusOS.Tank_Type_BlackWater, level: 75, capacity: .2 },
			]
		},
		{
			name: "10 tanks (merge 3 Fuel tanks and 2 WasteWater tanks)",
			tanks: [
				{ type: VenusOS.Tank_Type_Fuel, level: 46.34, capacity: 1 },
				{ type: VenusOS.Tank_Type_Fuel, level: 75.334, capacity: 1 },
				{ type: VenusOS.Tank_Type_Fuel, level: 75.334, capacity: 1 },
				{ type: VenusOS.Tank_Type_FreshWater, level: 10, capacity: 2 },
				{ type: VenusOS.Tank_Type_WasteWater, level: 75.334, capacity: 1 },
				{ type: VenusOS.Tank_Type_WasteWater, level: 75.334, capacity: 1 },
				{ type: VenusOS.Tank_Type_LiveWell, level: 20, capacity: 1 },
				{ type: VenusOS.Tank_Type_Oil, level: 80.2, capacity: .1 },
				{ type: VenusOS.Tank_Type_BlackWater, level: 25, capacity: .2 },
				{ type: VenusOS.Tank_Type_Gasoline, level: 75, capacity: .2 },
			]
		},
		{
			name: "15 tanks (merge 3 Fuel tanks and 2 WasteWater tanks)",
			tanks: [
				{ type: VenusOS.Tank_Type_Fuel, level: 46.34, capacity: 1 },
				{ type: VenusOS.Tank_Type_Fuel, level: 75.334, capacity: 1 },
				{ type: VenusOS.Tank_Type_Fuel, level: 75.334, capacity: 1 },
				{ type: VenusOS.Tank_Type_FreshWater, level: 10, capacity: 2 },
				{ type: VenusOS.Tank_Type_WasteWater, level: 75.334, capacity: 1 },
				{ type: VenusOS.Tank_Type_WasteWater, level: 75.334, capacity: 1 },
				{ type: VenusOS.Tank_Type_LiveWell, level: 20, capacity: 1 },
				{ type: VenusOS.Tank_Type_Oil, level: 80.2, capacity: .1 },
				{ type: VenusOS.Tank_Type_BlackWater, level: 25, capacity: .2 },
				{ type: VenusOS.Tank_Type_Gasoline, level: 75, capacity: .2 },
				{ type: VenusOS.Tank_Type_Diesel, level: 75, capacity: .25 },
				{ type: VenusOS.Tank_Type_LPG, level: 80, capacity: .3 },
				{ type: VenusOS.Tank_Type_LNG, level: 85, capacity: .4 },
				{ type: VenusOS.Tank_Type_HydraulicOil, level: 90, capacity: .5 },
				{ type: VenusOS.Tank_Type_RawWater, level: 95, capacity: .6 },
			]
		},
		{
			name: "Merge 2 tanks with average level of 50%, no capacity/remaining",
			tanks: [
				// Should get an average level of 50%
				{ type: VenusOS.Tank_Type_Fuel, level: 25 },
				{ type: VenusOS.Tank_Type_Fuel, level: 75 },

				{ type: VenusOS.Tank_Type_FreshWater, level: 10 },
				{ type: VenusOS.Tank_Type_WasteWater, level: 75.334 },
				{ type: VenusOS.Tank_Type_LiveWell, capacity: 1, remaining: 2.5 },
				{ type: VenusOS.Tank_Type_Oil, level: 80.2, capacity: .1 },
				{ type: VenusOS.Tank_Type_BlackWater, level: 25, capacity: .2 },
			]
		},
		{
			// crude average level = 25+75/2 = 50%, but actual combined average = 15.5/22 = 70%
			name: "Merge 2 Freshwater tanks with vastly different capacities",
			tanks: [
				{ type: VenusOS.Tank_Type_FreshWater, level: 25, capacity: 2 },
				{ type: VenusOS.Tank_Type_FreshWater, level: 75, capacity: 20 },
			]
		},
	]

	property var environmentConfigs: [
		{
			name: "Double gauge",
			inputs: [ { customName: "Refrigerator", temperature: 4.4223, humidity: 32.6075 } ]
		},
		{
			name: "Double gauge x 2",
			inputs: [
				{ customName: "Refrigerator", temperature: 4.4, humidity: 32.6075 },
				{ customName: "Freezer", temperature: -48.2, humidity: 28.921 },
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
				{ customName: "Freezer", temperature: 100, humidity: 100 },
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
		{
			name: "Single gauge x 8",
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

	function configCount() {
		return Math.max(tankConfigs.length, environmentConfigs.length)
	}

	function loadConfig(configIndex) {
		let configName = ""
		if (configIndex < tankConfigs.length) {
			configName = "TANKS: " + tankConfigs[configIndex].name
			Global.mockDataSimulator.setTanksRequested(tankConfigs[configIndex].tanks)
		}
		if (configIndex < environmentConfigs.length) {
			configName += "\nTEMPS: " + environmentConfigs[configIndex].name
			Global.mockDataSimulator.setEnvironmentInputsRequested(environmentConfigs[configIndex].inputs)
		}
		return configName
	}
}
