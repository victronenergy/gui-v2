/*
 * Copyright (C) 2025 Victron Energy B.V.
 * See LICENSE.txt for license information.
*/

import QtTest
import QtQuick

TestCase {
	id: root

	name: "FilteredServiceModelTest"

	FilteredServiceModel {
		id: model
	}

	function test_model_data() {
		const uids = [
			"mock/com.victronenergy.a.suffix1",
			"mock/com.victronenergy.b.suffix1",
			"mock/com.victronenergy.c.suffix1",
			"mock/com.victronenergy.c.suffix2",
			"mock/com.victronenergy.c.suffix3",
		]
		return [
			{
				tag: "filter: a only",
				serviceTypes: ["a"],
				uids: uids,
				expectedUids: [ "mock/com.victronenergy.a.suffix1" ]
			},
			{
				tag: "filter: b only",
				serviceTypes: ["b"],
				uids: uids,
				expectedUids: [ "mock/com.victronenergy.b.suffix1" ]
			},
			{
				tag: "filter: c only",
				serviceTypes: ["c"],
				uids: uids,
				expectedUids: [
					"mock/com.victronenergy.c.suffix1",
					"mock/com.victronenergy.c.suffix2",
					"mock/com.victronenergy.c.suffix3",
				]
			},
			{
				tag: "filter: b + c",
				serviceTypes: ["b", "c"],
				uids: uids,
				expectedUids: [
					"mock/com.victronenergy.b.suffix1",
					"mock/com.victronenergy.c.suffix1",
					"mock/com.victronenergy.c.suffix2",
					"mock/com.victronenergy.c.suffix3",
				]
			},
			{
				tag: "filter: a + b + c",
				serviceTypes: ["a", "b", "c"],
				uids: uids,
				expectedUids: [
					"mock/com.victronenergy.a.suffix1",
					"mock/com.victronenergy.b.suffix1",
					"mock/com.victronenergy.c.suffix1",
					"mock/com.victronenergy.c.suffix2",
					"mock/com.victronenergy.c.suffix3",
				]
			},
		]
	}

	function test_model(data) {
		let uid
		let deviceInstanceCount
		let i

		// Set filter, then add services and verify model is correct.
		model.serviceTypes = data.serviceTypes ?? []
		for (uid of data.uids) {
			MockManager.setValue(uid + "/DeviceInstance", deviceInstanceCount++)
		}
		compare(model.count, data.expectedUids.length)
		for (i = 0 ; i < data.expectedUids.length; ++i) {
			compare(model.data(model.index(i, 0), AllServicesModel.UidRole), data.expectedUids[i])
		}

		// Remove services
		for (uid of data.uids) {
			MockManager.removeValue(uid)
		}
		compare(model.count, 0)

		// Add services, without a filter set...
		model.serviceTypes = []
		for (uid of data.uids) {
			MockManager.setValue(uid + "/DeviceInstance", deviceInstanceCount++)
		}
		// Check all test data is present and in the original order
		for (i = 0 ; i < data.uids.length; ++i) {
			compare(model.data(model.index(i, 0), AllServicesModel.UidRole), data.uids[i])
		}

		// ...then set filter and check model is updated
		model.serviceTypes = data.serviceTypes ?? []
		compare(model.count, data.expectedUids.length)
		for (i = 0 ; i < data.expectedUids.length; ++i) {
			compare(model.data(model.index(i, 0), AllServicesModel.UidRole), data.expectedUids[i])
		}

		// Remove services
		for (uid of data.uids) {
			MockManager.removeValue(uid)
		}
		compare(model.count, 0)
	}
}
