/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	// Model with the supported sensors for the relays, when available.
	property VeQItemSortTableModel sensors: VeQItemSortTableModel {
		filterFlags: VeQItemSortTableModel.FilterOffline
		dynamicSortFilter: true
		model: VeQItemTableModel {
			uids: [ BackendConnection.serviceUidForType("temprelay") + "/Sensor" ]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}
	}

	// Model with the actual service names of above sensors, when valid.
	property VeQItemSortTableModel services: VeQItemSortTableModel {
		filterFlags: VeQItemSortTableModel.FilterInvalid
		dynamicSortFilter: true
		model: VeQItemChildModel {
			model: sensors
			childId: "ServiceName"
		}
	}

	GradientListView {
		id: listView

		model: services

		header: PrimaryListLabel {
			//% "No temperature sensors have been added yet."
			text: qsTrId("settings_relay_no_temperature_sensors")
			preferredVisible: listView.count === 0
		}

		delegate: ListTemperatureRelay {
			id: relayDelegate

			function getIdFromService(service) {
				// if service = com.victronenergy.temperature.ruuvi_f00f00d00001 then the sensor id
				// is ruuvi_f00f00d00001
				if (service.indexOf(".temperature.") > -1) {
					return service.split(".temperature.")[1]
				} else if (service.indexOf(".battery.") > -1) {
					return service.split(".battery.")[1]
				}
				return ""
			}

			// model.item.value is e.g. com.victronenergy.temperature.ruuvi_f00f00d00001
			bindPrefix: BackendConnection.serviceUidFromName(model.item.value, serviceInstance.value)
			sensorId: getIdFromService(model.item.value)

			onClicked: {
				Global.pageManager.pushPage(sensorRelayComponent)
			}

			VeQuickItem {
				id: serviceInstance
				uid: "%1/Sensor/%2/ServiceInstance".arg(BackendConnection.serviceUidForType("temprelay")).arg(sensorId)
			}

			Component {
				id: sensorRelayComponent

				Page {
					function _hasInvalidRelayTempConfig(relayNr) {
						if (relayNr === 0) {
							return relay0FunctionItem.value !== VenusOS.Relay_Function_Temperature
						} else if (relayNr === 1) {
							return relay1FunctionItem.value !== VenusOS.Relay_Function_Temperature
						}
						return false
					}

					title: relayDelegate.text

					VeQuickItem {
						id: relay0FunctionItem
						uid: Global.systemSettings.serviceUid + "/Settings/Relay/Function"
					}

					VeQuickItem {
						id: relay1FunctionItem
						uid: Global.systemSettings.serviceUid + "/Settings/Relay/1/Function"
					}

					GradientListView {
						model: relay0FunctionItem.value === VenusOS.Relay_Function_Temperature || relay1FunctionItem.value === VenusOS.Relay_Function_Temperature
							   ? tempRelayModel
							   : disabledModel

						VisibleItemModel {
							id: tempRelayModel

							ListSwitch {
								id: functionEnabledSwitch

								//% "Relay activation on temperature"
								text: qsTrId("settings_relay_activate_on_temp")
								dataItem.uid: relayDelegate.tempRelayPrefix + "/Enabled"
							}

							TemperatureRelaySettings {
								relayNumber: 0
								sensorId: relayDelegate.sensorId
								relayActivateOnTemperature: functionEnabledSwitch.checked
								hasInvalidRelayTempConfig: _hasInvalidRelayTempConfig(relayValue)
							}

							TemperatureRelaySettings {
								relayNumber: 1
								sensorId: relayDelegate.sensorId
								relayActivateOnTemperature: functionEnabledSwitch.checked
								hasInvalidRelayTempConfig: _hasInvalidRelayTempConfig(relayValue)
							}
						}

						VisibleItemModel {
							id: disabledModel

							PrimaryListLabel {
								//% "No relay is configured to be activated by temperature. Go to the relay settings page located in the main settings menu and set the relay function to \"Temperature\"."
								text: qsTrId("settings_relay_no_temperature_relay")
							}
						}
					}
				}
			}
		}
	}
}
