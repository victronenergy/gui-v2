/*
 * Copyright (C) 2026 Victron Energy B.V.
 * See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtTest

TestCase {
	id: root

	readonly property string platformUid: "mock/com.victronenergy.platform"
	readonly property string servicesUid: platformUid + "/Network/Services"
	readonly property string ethernetService: "/net/connman/service/ethernet_1234556789_cable"

	name: "NetworkServicesTest"

	Component {
		id: networkServicesComponent

		NetworkServices {}
	}

	function setEthernet(ethernet) {
		MockManager.setValue(servicesUid, JSON.stringify({ "ethernet": ethernet, "wifi": {} }))
	}

	function pluggedIn(address) {
		return {
			"Wired": {
				"Address": address,
				"Gateway": "192.168.1.254",
				"Mac": "11:22:33:AA:BB:CC",
				"Method": "dhcp",
				"Nameservers": ["192.168.1.254"],
				"Netmask": "255.255.255.0",
				"Service": ethernetService,
				"State": "ready"
			}
		}
	}

	function initTestCase() {
		Global.venusPlatform = { serviceUid: platformUid }
	}

	function cleanupTestCase() {
		Global.venusPlatform = null
	}

	function test_unplugCable() {
		setEthernet(pluggedIn("192.168.1.10"))

		const services = createTemporaryObject(networkServicesComponent, root)
		tryCompare(services, "valid", true)
		compare(services.service, ethernetService)
		compare(services.networkState, "ready")
		compare(services.ipAddress, "192.168.1.10")
		verify(services.ready)

		// connman removes the ethernet service when the cable is unplugged.
		setEthernet({})
		tryCompare(services, "ipAddress", "")
		compare(services.networkState, "")
		compare(services.service, "")
		compare(services.gateway, "")
		verify(!services.ready)

		// Plugging the cable back in finds the service again by name.
		setEthernet(pluggedIn("192.168.1.11"))
		tryCompare(services, "ipAddress", "192.168.1.11")
		compare(services.service, ethernetService)
		compare(services.networkState, "ready")
		verify(services.ready)
	}

	function test_missingTechnology() {
		MockManager.setValue(servicesUid, JSON.stringify({ "wifi": {} }))
		const services = createTemporaryObject(networkServicesComponent, root)
		tryCompare(services, "valid", true)
		compare(services.ipAddress, "")
		compare(services.networkState, "")
	}
}
