/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtTest
import Victron.VenusOS
import Victron.GuiPlugins

TestCase {
	id: root

	name: "PluginDataItemTest"

	PluginDataItem {
		id: dataItem
	}

	SignalSpy {
		id: minSpy
		target: dataItem
		signalName: "minChanged"
	}

	SignalSpy {
		id: maxSpy
		target: dataItem
		signalName: "maxChanged"
	}

	function test_minMax_data() {
		return [
			{
				tag: "no uid",
				uid: "",
				limits: {},
				expectedMin: NaN,
				expectedMax: NaN,
			},
			{
				tag: "no limits given",
				uid: "mock/com.victronenergy.test.a/NoLimits",
				limits: {},
				expectedMin: NaN,
				expectedMax: NaN,
			},
			{
				tag: "limits given, with a minimum of 0",
				uid: "mock/com.victronenergy.test.a/Limits",
				limits: { min: 0, max: 32 },
				expectedMin: 0,
				expectedMax: 32,
			},
		]
	}

	function test_minMax(data) {
		if (data.uid !== "") {
			MockManager.setValue(data.uid, 5)
			for (const name in data.limits) {
				MockManager.setProperty(data.uid, name, data.limits[name])
			}
		}
		dataItem.uid = data.uid
		compare(dataItem.min, data.expectedMin)
		compare(dataItem.max, data.expectedMax)
	}

	function test_limitsGivenLater() {
		const uid = "mock/com.victronenergy.test.a/LimitsLater"
		MockManager.setValue(uid, 5)
		dataItem.uid = uid
		compare(dataItem.min, NaN)
		compare(dataItem.max, NaN)

		minSpy.clear()
		maxSpy.clear()
		MockManager.setProperty(uid, "min", -5)
		MockManager.setProperty(uid, "max", 32.5)
		compare(minSpy.count, 1)
		compare(maxSpy.count, 1)
		compare(dataItem.min, -5)
		compare(dataItem.max, 32.5)
	}
}
