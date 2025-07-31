/*
 * Copyright (C) 2025 Victron Energy B.V.
 * See LICENSE.txt for license information.
*/

import QtTest
import QtQuick

TestCase {
	id: root

	name: "AllServicesModelTest"

	function test_model_data() {
		return [
			{
				tag: "one service",
				services: [
					{ uid: "mock/com.victronenergy.test.a", serviceType: "test" }
				]
			},
			{
				tag: "two services",
				services: [
					{ uid: "mock/com.victronenergy.test.a", serviceType: "test" },
					{ uid: "mock/com.victronenergy.test.b", serviceType: "test" },
				]
			},
			{
				tag: "different service types",
				services: [
					{ uid: "mock/com.victronenergy.test.a", serviceType: "test" },
					{ uid: "mock/com.victronenergy.test2.a", serviceType: "test2" },
				]
			},
		]
	}

	function test_model(data) {
		let uidCount = 0
		let i

		// Add services. On the first data test, this will start the model with pre-populated values.
		for (const service of data.services) {
			MockManager.setValue(service.uid + "/DeviceInstance", uidCount++)
		}
		compare(AllServicesModel.count, data.services.length)
		for (i = 0 ; i < data.services.length; ++i) {
			compare(AllServicesModel.data(AllServicesModel.index(i, 0), AllServicesModel.UidRole), data.services[i].uid)
			compare(AllServicesModel.data(AllServicesModel.index(i, 0), AllServicesModel.ServiceTypeRole), data.services[i].serviceType)
		}

		// Remove services
		for (i = data.services.length - 1; i >= 0; --i) {
			MockManager.removeValue(data.services[i].uid)
			compare(AllServicesModel.data(AllServicesModel.index(i, 0), AllServicesModel.UidRole), undefined)
			compare(AllServicesModel.data(AllServicesModel.index(i, 0), AllServicesModel.ServiceTypeRole), undefined)
			compare(AllServicesModel.count, i)
		}
		compare(AllServicesModel.count, 0)
	}
}
