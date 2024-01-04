/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import Victron.Utils

Page {
	id: root

	// Model with the supported sensors for the relays, when available.
	property VeQItemSortTableModel sensors: VeQItemSortTableModel {
		filterFlags: VeQItemSortTableModel.FilterOffline
		dynamicSortFilter: true
		model: VeQItemTableModel {
			uids: [ BackendConnection.uidForServiceType("temprelay") + "/Sensor" ]
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
		model: services

		delegate: TemperatureRelayNavigationItem {
			id: relayDelegate

			function getIdFromService(service) {
				if (service.indexOf(".temperature.") > -1) {
					return service.split(".temperature.")[1]
				}
				return ""
			}

			bindPrefix: model.item.value    // e.g. com.victronenergy.temperature.ruuvi_f00f00d00001
			sensorId: getIdFromService(bindPrefix)

			onClicked: {
				Global.pageManager.pushPage(sensorRelayComponent)
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

						ObjectModel {
							id: tempRelayModel

							ListSwitch {
								id: functionEnabledSwitch

								//% "Relay activation on temperature"
								text: qsTrId("settings_relay_activate_on_temp")
								dataItem.uid: relayDelegate.tempRelayPrefix + "/Enabled"
							}

							TemperatureRelaySettings {
								relayNumber: 0
								sensorId: relayDelegate.getIdFromService(relayDelegate.bindPrefix)
								relayActivateOnTemperature: functionEnabledSwitch.checked
								hasInvalidRelayTempConfig: _hasInvalidRelayTempConfig(relayValue)
							}

							TemperatureRelaySettings {
								relayNumber: 1
								sensorId: relayDelegate.getIdFromService(relayDelegate.bindPrefix)
								relayActivateOnTemperature: functionEnabledSwitch.checked
								hasInvalidRelayTempConfig: _hasInvalidRelayTempConfig(relayValue)
							}
						}

						ObjectModel {
							id: disabledModel

							ListLabel {
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
