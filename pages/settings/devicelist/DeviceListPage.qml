/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	title: CommonWords.devices

	GradientListView {
		id: deviceListView

		model: SortedRuntimeDeviceModel {
			sourceModel: RuntimeDeviceModel
		}

		delegate: BaseListLoader {
			id: delegateLoader

			required property BaseDevice device
			required property string cachedDeviceName
			property bool _completed

			function _resetSource() {
				if (!!device) {
					setSource("delegates/DeviceListDelegate_%1.qml".arg(device.serviceType), {
						device: Qt.binding(function() { return delegateLoader.device }),
					})
				} else {
					setSource("delegates/DisconnectedDeviceListDelegate.qml", {
						cachedDeviceName: Qt.binding(function() { return delegateLoader.cachedDeviceName }),
					})
				}
			}

			// Only set width; height is sized to the loaded item, in case preferredVisible=false and the
			// item should not be visible.
			width: parent ? parent.width : 0

			onStatusChanged: {
				if (status === Loader.Error) {
					console.warn("Failed to load Device List delegate for '%1' service from file: %2"
						.arg(BackendConnection.serviceTypeFromUid(device.serviceUid))
						.arg(source))
				}
			}

			onDeviceChanged: {
				// Reset the content when the device is disconnected/reconnected.
				if (_completed) {
					_resetSource()
				}
			}
			Component.onCompleted: {
				_resetSource()
				_completed = true
			}
		}

		footer: SettingsColumn {
			width: parent.width
			topPadding: spacing
			preferredVisible: relaysMenu.preferredVisible
					|| gensetMenu.preferredVisible
					|| tankPumpMenu.preferredVisible
					|| removeDisconnectedButton.preferredVisible

			ListNavigation {
				id: relaysMenu
				text: CommonWords.gx_device_relays
				preferredVisible: systemRelayModel.count > 0
				onClicked: Global.pageManager.pushPage(switchableOutputPageComponent)

				Component {
					id: switchableOutputPageComponent
					Page {
						title: CommonWords.gx_device_relays

						GradientListView {
							model: systemRelayModel
							delegate: SwitchableOutputListDelegate {}
						}
					}
				}

				SwitchableOutputModel {
					id: systemRelayModel

					sourceModel: VeQItemTableModel {
						uids: [ Global.system.serviceUid + "/SwitchableOutput" ]
						flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
					}
					filterType: SwitchableOutputModel.ManualFunction
				}
			}

			ListNavigation {
				id: gensetMenu
				//% "Genset"
				text: qsTrId("devicelistpage_genset")
				preferredVisible: relay0.valid && relayFunction.valid && relayFunction.value === VenusOS.SwitchableOutput_Function_GeneratorStartStop
				onClicked: Global.pageManager.pushPage("/pages/settings/PageRelayGenerator.qml", {"title": text})

				VeQuickItem {
					id: relay0
					uid: Global.system.serviceUid + "/Relay/0/State"
				}
			}

			ListNavigation {
				id: tankPumpMenu
				preferredVisible: relayFunction.valid && relayFunction.value === VenusOS.SwitchableOutput_Function_Tank_Pump
				//% "Tank pump"
				text: qsTrId("settings_tank_pump")
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsTankPump.qml", {"title": text})
			}

			ListButton {
				id: removeDisconnectedButton
				//% "Remove disconnected devices"
				text: qsTrId("devicelist_remove_disconnected_devices")
				secondaryText: CommonWords.remove
				preferredVisible: RuntimeDeviceModel.disconnectedDeviceCount > 0
				onClicked: {
					RuntimeDeviceModel.removeDisconnectedDevices()
				}
			}
		}
	}

	VeQuickItem {
		id: relayFunction
		uid: Global.systemSettings.serviceUid + "/Settings/Relay/Function"
	}
}
