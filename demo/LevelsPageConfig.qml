/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property var configs: Global.pageManager.levelsTabIndex === 0
			? tankConfigs
			: environmentConfigs

	property var tankConfigs: [
		{
			name: "Check Fuel colors",
			tanks: [
				{ type: VenusOS.Tank_Type_Fuel, level: 100, capacity: 1000, remaining: 1000 },
				{ type: VenusOS.Tank_Type_Fuel, level: 75, capacity: 1000, remaining: 750 },
				{ type: VenusOS.Tank_Type_Fuel, level: 20, capacity: 1000, remaining: 200 },
				{ type: VenusOS.Tank_Type_Fuel, level: 10, capacity: 1000, remaining: 100 },
				{ type: VenusOS.Tank_Type_Fuel, level: 0, capacity: 1000, remaining: 0 },
			]
		},
		{
			name: "Check BlackWater colors (different from Fuel level colors)",
			tanks: [
				{ type: VenusOS.Tank_Type_BlackWater, level: 100, capacity: 1000, remaining: 1000 },
				{ type: VenusOS.Tank_Type_BlackWater, level: 90, capacity: 1000, remaining: 900 },
				{ type: VenusOS.Tank_Type_BlackWater, level: 85, capacity: 1000, remaining: 850 },
				{ type: VenusOS.Tank_Type_BlackWater, level: 75, capacity: 1000, remaining: 750 },
				{ type: VenusOS.Tank_Type_BlackWater, level: 0, capacity: 1000, remaining: 0 },
			]
		},
		{
			name: "1 tank",
			tanks: [
				{ type: VenusOS.Tank_Type_Fuel, level: 46.34, capacity: 1000, remaining: 463 }
			],
		},
		{
			name: "2 tanks",
			tanks: [
				{ type: VenusOS.Tank_Type_Fuel, level: 46.34, capacity: 1000, remaining: 463 } ,
				{ type: VenusOS.Tank_Type_FreshWater, level: 50, capacity: 2000, remaining: 1000 }
			],
		},
		{
			name: "3 tanks (two of same type)",
			tanks: [
				{ type: VenusOS.Tank_Type_Fuel, level: 16.34, capacity: 1000, remaining: 163 },
				{ type: VenusOS.Tank_Type_Fuel, level: 75.334, capacity: 1000, remaining: 753 },
				{ type: VenusOS.Tank_Type_FreshWater, level: 10, capacity: 2000, remaining: 100 },
			]
		},
		{
			name: "4 tanks (two of same type)",
			tanks: [
				{ type: VenusOS.Tank_Type_Fuel, level: 46.34, capacity: 1000, remaining: 463 },
				{ type: VenusOS.Tank_Type_Fuel, level: 75.334, capacity: 1000, remaining: 753 },
				{ type: VenusOS.Tank_Type_FreshWater, level: 10, capacity: 2000, remaining: 100 },
				{ type: VenusOS.Tank_Type_BlackWater, level: 25, capacity: 200, remaining: 50 },
			]
		},
		{
			name: "5 tanks (two of same type)",
			tanks: [
				{ type: VenusOS.Tank_Type_Fuel, level: 46.34, capacity: 1000, remaining: 463 },
				{ type: VenusOS.Tank_Type_Fuel, level: 75.334, capacity: 1000, remaining: 753 },
				{ type: VenusOS.Tank_Type_FreshWater, level: 10, capacity: 2000, remaining: 100 },
				{ type: VenusOS.Tank_Type_WasteWater, level: 75, capacity: 1000, remaining: 750 },
				{ type: VenusOS.Tank_Type_BlackWater, level: 25, capacity: 200, remaining: 50 },
			]
		},
		{
			name: "6 tanks (merge 2 Fuel tanks)",
			tanks: [
				{ type: VenusOS.Tank_Type_Fuel, level: 46.34, capacity: 1000, remaining: 463 },
				{ type: VenusOS.Tank_Type_Fuel, level: 75.334, capacity: 1000, remaining: 753 },
				{ type: VenusOS.Tank_Type_FreshWater, level: 10, capacity: 2000, remaining: 100 },
				{ type: VenusOS.Tank_Type_WasteWater, level: 75, capacity: 1000, remaining: 750 },
				{ type: VenusOS.Tank_Type_Oil, level: 80.2, capacity: 100, remaining: 802 },
				{ type: VenusOS.Tank_Type_BlackWater, level: 25, capacity: 200, remaining: 50 },
			]
		},
		{
			name: "7 tanks (merge 2 Freshwater tanks)",
			tanks: [
				{ type: VenusOS.Tank_Type_Fuel, level: 75.334, capacity: 1000, remaining: 753 },
				{ type: VenusOS.Tank_Type_FreshWater, level: 10, capacity: 2000, remaining: 100 },
				{ type: VenusOS.Tank_Type_FreshWater, level: 50, capacity: 2000, remaining: 1000 },
				{ type: VenusOS.Tank_Type_WasteWater, level: 75, capacity: 1000, remaining: 750 },
				{ type: VenusOS.Tank_Type_LiveWell, level: 20, capacity: 1000, remaining: 200 },
				{ type: VenusOS.Tank_Type_Oil, level: 80.2, capacity: 100, remaining: 802 },
				{ type: VenusOS.Tank_Type_BlackWater, level: 25, capacity: 200, remaining: 50 },
			]
		},
		{
			name: "8 tanks (merge 3 BlackWater tanks)",
			tanks: [
				{ type: VenusOS.Tank_Type_Fuel, level: 46.34, capacity: 1000, remaining: 463 },
				{ type: VenusOS.Tank_Type_FreshWater, level: 10, capacity: 2000, remaining: 100 },
				{ type: VenusOS.Tank_Type_WasteWater, level: 75, capacity: 1000, remaining: 750 },
				{ type: VenusOS.Tank_Type_LiveWell, level: 20, capacity: 1000, remaining: 200 },
				{ type: VenusOS.Tank_Type_Oil, level: 80.2, capacity: 100, remaining: 802 },
				{ type: VenusOS.Tank_Type_BlackWater, level: 25, capacity: 200, remaining: 50 },
				{ type: VenusOS.Tank_Type_BlackWater, level: 50, capacity: 200, remaining: 100 },
				{ type: VenusOS.Tank_Type_BlackWater, level: 75, capacity: 200, remaining: 150 },
			]
		},
		{
			name: "10 tanks (merge 3 Fuel tanks and 2 WasteWater tanks)",
			tanks: [
				{ type: VenusOS.Tank_Type_Fuel, level: 46.34, capacity: 1000, remaining: 463 },
				{ type: VenusOS.Tank_Type_Fuel, level: 75.334, capacity: 1000, remaining: 753 },
				{ type: VenusOS.Tank_Type_Fuel, level: 75.334, capacity: 1000, remaining: 753 },
				{ type: VenusOS.Tank_Type_FreshWater, level: 10, capacity: 2000, remaining: 100 },
				{ type: VenusOS.Tank_Type_WasteWater, level: 75, capacity: 1000, remaining: 750 },
				{ type: VenusOS.Tank_Type_WasteWater, level: 75, capacity: 1000, remaining: 750 },
				{ type: VenusOS.Tank_Type_LiveWell, level: 20, capacity: 1000, remaining: 200 },
				{ type: VenusOS.Tank_Type_Oil, level: 80.2, capacity: 100, remaining: 802 },
				{ type: VenusOS.Tank_Type_BlackWater, level: 25, capacity: 200, remaining: 50 },
				{ type: VenusOS.Tank_Type_Gasoline, level: 25, capacity: 200, remaining: 50 },
			]
		},
		{
			name: "10 tanks (merge 3 Fuel tanks and 2 WasteWater tanks)",
			tanks: [
				{ type: VenusOS.Tank_Type_Fuel, level: 46.34, capacity: 1000, remaining: 463 },
				{ type: VenusOS.Tank_Type_FreshWater, level: 10, capacity: 2000, remaining: 100 },
				{ type: VenusOS.Tank_Type_FreshWater, level: 10, capacity: 2000, remaining: 100 },
				{ type: VenusOS.Tank_Type_FreshWater, level: 10, capacity: 2000, remaining: 100 },
				{ type: VenusOS.Tank_Type_WasteWater, level: 75, capacity: 1000, remaining: 750 },
				{ type: VenusOS.Tank_Type_WasteWater, level: 75, capacity: 1000, remaining: 750 },
				{ type: VenusOS.Tank_Type_LiveWell, level: 20, capacity: 1000, remaining: 200 },
				{ type: VenusOS.Tank_Type_Oil, level: 80.2, capacity: 100, remaining: 802 },
				{ type: VenusOS.Tank_Type_BlackWater, level: 25, capacity: 200, remaining: 50 },
				{ type: VenusOS.Tank_Type_Gasoline, level: 25, capacity: 200, remaining: 50 },
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
		Global.demoManager.setTanksRequested(config.tanks)
		Global.demoManager.setEnvironmentInputsRequested(config.inputs)
	}
}
