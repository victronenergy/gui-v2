/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import net.connman 0.1
import "/components/Utils.js" as Utils

Page {
	id: root

	property string technologyType: "ethernet"
	property string path: Connman.getServiceList(technologyType)[0] || ""
	property CmService service: path ? Connman.getService(path) : null

	readonly property string _security: service ? service.security.toString() : ""
	property bool _secured: _security.indexOf("none") === -1 && _security !== ""
	readonly property string _serviceMethod: !!service && service.ipv4Config["Method"] ? service.ipv4Config["Method"] : "--"
	readonly property bool _readOnlySettings: _serviceMethod !== "manual"
	readonly property bool _wifi: technologyType === "wifi"
	property string _agentPath: "/com/victronenergy/ccgx"
	property CmAgent _agent
	property var _forgetNetworkDialog

	function _getIpv4Property(name) {
		if (!service) {
			return ""
		}
		if (service.ipv4["Method"] === "manual") {
			return service.ipv4Config[name] || "--"
		}
		return service.ipv4[name] || "--"
	}

	function _setIpv4Property(name, value) {
		let ipv4Config = service.ipv4
		ipv4Config[name] = value
		service.ipv4Config = ipv4Config
	}

	function _setMethod(selectedMethod) {
		if (!service) {
			return
		}
		let ipv4Config = service.ipv4
		let nameserversConfig = service.nameservers
		let oldMethod = ipv4Config["Method"]

		switch (selectedMethod) {
		case "dhcp":
			if (oldMethod === "manual") {
				ipv4Config['Address'] = "255.255.255.255"
				service.ipv4Config = ipv4Config
			}
			ipv4Config["Method"] = "dhcp"
			nameserversConfig = []
			break
		case "manual":
			ipv4Config["Method"] = "manual"
			let addr = service.checkIpAddress(ipv4Config["Address"])
			/*
			 * Make sure the ip settings are valid when switching to "manual"
			 * When the ip settings are not valid, connman will continuously disconnect
			 * and reconnect the service and it is impossible to set the ip-address.
			 */
			if (!addr) {
				ipv4Config["Address"] = "169.254.1.2"
				ipv4Config["Netmask"] = "255.255.255.0"
				ipv4Config["Gateway"] = "169.254.1.1"
			}
			break
		}
		if (ipv4Config["Method"] !== oldMethod) {
			service.ipv4Config = ipv4Config
			service.nameserversConfig = nameserversConfig
		}
	}

	Component.onCompleted: {
		if (_wifi) {
			_agent = Connman.registerAgent(_agentPath)
		}
	}

	Component.onDestruction: {
		if (_wifi) {
			Connman.unRegisterAgent(_agentPath)
		}
	}

	Connections {
		target: Connman
		function onServiceRemoved(path) {
			if (path === root.path) {
				root.path = ""
			}
		}
		function onServiceAdded(path) {
			// refresh the service, else we may have a stale service object
			root.path = Connman.getServiceList(technologyType)[0]
		}
	}

	GradientListView {
		id: settingsListView
		model: root.service ? connectedModel : disconnectedModel
	}

	ObjectModel {
		id: disconnectedModel

		ListTextItem {
			text: CommonWords.state
			secondaryText: root._wifi
					 //% "Connection lost"
					? qsTrId("settings_tcpip_connection_lost")
					 //% "Unplugged"
					: qsTrId("settings_tcpip_connection_unplugged")
		}
	}

	ObjectModel {
		id: connectedModel

		ListTextItem {
			text: CommonWords.state
			secondaryText: Utils.connmanServiceState(root.service)
		}

		ListTextItem {
			//% "Name"
			text: qsTrId("settings_tcpip_name")
			//% "[Hidden]"
			secondaryText: root.service ? (service.name || qsTrId("settings_tcpip_hidden")) : ""
			visible: root._wifi
		}

		ListTextField {
			text: CommonWords.password
			textField.maximumLength: 63
			visible: root.service && root._wifi
					 && (root.service.state === "idle" || root.service.state === "failure")
					 && !root.service.favorite && root._secured
			writeAccessLevel: VenusOS.User_AccessType_User
			onAccepted: {
				root._agent.passphrase = textField.text
				root.service.connect()
			}
		}

		ListButton {
			//% "Connect to network?"
			text: qsTrId("settings_tcpip_connect_to_network")
			//% "Connect"
			button.text: qsTrId("settings_tcpip_connect")
			visible: root.service && root._wifi
					 && (root.service.state === "idle" || root.service.state === "failure")
					 && (root.service.favorite || !root._secured)
			writeAccessLevel: VenusOS.User_AccessType_User
			onClicked: {
				root.service.connect()
			}
		}

		ListButton {
			id: forgetNetworkButton

			//% "Forget network?"
			text: qsTrId("settings_tcpip_forget_network")
			//% "Forget"
			button.text: qsTrId("settings_tcpip_forget")
			visible: root.service && root._wifi && root.service.favorite
			writeAccessLevel: VenusOS.User_AccessType_User
			onClicked: {
				if (!root._forgetNetworkDialog) {
					root._forgetNetworkDialog = forgetNetworkDialogComponent.createObject(Global.dialogLayer)
				}
				root._forgetNetworkDialog.open()
			}

			Component {
				id: forgetNetworkDialogComponent

				ModalWarningDialog {
					dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel
					title: forgetNetworkButton.text
					//% "Are you sure that you want to forget this network?"
					description: qsTrId("settings_tcpip_forget_confirm")
					onAccepted: {
						root.service.remove()
					}
				}
			}
		}

		ListTextItem {
			text: CommonWords.signal_strength
			secondaryText: root.service ? service.strength + "%" : ""
			visible: root._wifi
		}

		ListTextItem {
			//% "MAC address"
			text: qsTrId("settings_tcpip_mac_address")
			secondaryText: root.service ? service.ethernet["Address"] : ""
		}

		ListRadioButtonGroup {
			id: method

			//% "IP configuration"
			text: qsTrId("settings_tcpip_ip_config")
			writeAccessLevel: VenusOS.User_AccessType_User
			optionModel: [
				//% "Automatic"
				{ display: qsTrId("settings_tcpip_auto"), value: "dhcp" },
				//% "Manual"
				{ display: qsTrId("settings_tcpip_manual"), value: "manual" },
				//% "Off"
				{ display: qsTrId("settings_tcpip_off"), value: "off", readOnly: true },
				//% "Fixed"
				{ display: qsTrId("settings_tcpip_fixed"), value: "fixed", readOnly: true },
			]
			currentIndex: {
				for (let i = 0; i < optionModel.length; ++i) {
					if (optionModel[i].value === root._serviceMethod) {
						return i
					}
				}
				return -1
			}
			onOptionClicked: function(index) {
				root._setMethod(optionModel[index].value)
			}
		}

		ListIpAddressField {
			text: CommonWords.ip_address
			enabled: method.userHasWriteAccess && !root._readOnlySettings
			textField.text: root._getIpv4Property("Address")
			onAccepted: root._setIpv4Property("Address", textField.text)
		}

		ListIpAddressField {
			//% "Netmask"
			text: qsTrId("settings_tcpip_netmask")
			enabled: method.userHasWriteAccess && !root._readOnlySettings
			textField.text: root._getIpv4Property("Netmask")
			onAccepted: root._setIpv4Property("Netmask", textField.text)
		}

		ListIpAddressField {
			//% "Gateway"
			text: qsTrId("settings_tcpip_gateway")
			enabled: method.userHasWriteAccess && !root._readOnlySettings
			textField.text: root._getIpv4Property("Gateway")
			onAccepted: root._setIpv4Property("Gateway", textField.text)
		}

		ListIpAddressField {
			//% "DNS server"
			text: qsTrId("settings_tcpip_dns_server")
			enabled: method.userHasWriteAccess && !root._readOnlySettings
			textField.text: root.service ? root.service.nameservers[0] || "" : ""
			onAccepted: root.service.nameserversConfig = textField.text
		}

		ListIpAddressField {
			id: linklocal

			//% "Link-local IP address"
			text: qsTrId("settings_tcpip_link_local")
			enabled: false
			textField.text: "TODO fetch from vePlatform"
			visible: root.technologyType === "ethernet"
		}
	}
}
