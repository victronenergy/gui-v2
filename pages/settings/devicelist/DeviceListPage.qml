/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	GradientListView {
		id: deviceListView

		model: Global.allDevicesModel

		delegate: Loader {
			id: delegateLoader

			required property bool connected
			required property BaseDevice device
			required property BaseDeviceModel sourceModel
			required property string cachedDeviceName

			readonly property bool _loadCustomDelegate: connected && !!device
			property bool _usingCustomDelegate

			function _resetSource() {
				if (_loadCustomDelegate) {
					const serviceType = BackendConnection.serviceTypeFromUid(device.serviceUid)
					if (!serviceType) {
						console.warn("DeviceList: cannot load delegate, cannot read service type from serviceUid:", device.serviceUid)
						return
					}
					if (!source || !_usingCustomDelegate) {
						setSource("delegates/DeviceListDelegate_%1.qml".arg(serviceType), {
							device: Qt.binding(function() { return delegateLoader.device }),
							sourceModel: Qt.binding(function() { return delegateLoader.sourceModel }),
						})
						_usingCustomDelegate = true
					}
				} else {
					if (!source || _usingCustomDelegate) {
						setSource("delegates/DisconnectedDeviceListDelegate.qml", {
							cachedDeviceName: Qt.binding(function() { return delegateLoader.cachedDeviceName }),
						})
						_usingCustomDelegate = false
					}
				}
			}

			// Only set width; height is sized to the loaded item, in case preferredVisible=false and the
			// item should not be visible.
			width: parent ? parent.width : 0

			onStatusChanged: {
				if (status === Loader.Error) {
					console.log("Failed to load Device List delegate for '%1' service from file: %2"
						.arg(BackendConnection.serviceTypeFromUid(device.serviceUid))
						.arg(source))
				}
			}

			on_LoadCustomDelegateChanged: _resetSource()
			Component.onCompleted: _resetSource()
		}

		footer: SettingsColumn {
			width: parent.width
			topPadding: Theme.geometry_gradientList_spacing

			ListButton {
				//% "Remove disconnected devices"
				text: qsTrId("devicelist_remove_disconnected_devices")
				secondaryText: CommonWords.remove
				preferredVisible: Global.allDevicesModel.disconnectedDeviceCount > 0
				onClicked: {
					Global.allDevicesModel.removeDisconnectedDevices()
				}
			}

			ListNavigation {
				//% "Generator start/stop"
				text: qsTrId("settings_generator_start_stop")
				preferredVisible: relay0.isValid
				onClicked: Global.pageManager.pushPage("/pages/settings/PageRelayGenerator.qml", {"title": text})

				VeQuickItem {
					id: relay0
					uid: Global.system.serviceUid + "/Relay/0/State"
				}
			}

			ListNavigation {
				//% "Tank pump"
				text: qsTrId("settings_tank_pump")
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsTankPump.qml", {"title": text})
			}

			ListNavigation {
				//% "Energy meters"
				text: qsTrId("settings_energy_meters")
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsCGwacsOverview.qml", {"title": text})
			}

			ListNavigation {
				//% "PV inverters"
				text: qsTrId("settings_pv_inverters")
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsFronius.qml", {"title": text})
			}
		}
	}
}
