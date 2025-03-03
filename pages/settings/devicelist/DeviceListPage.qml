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

		delegate: BaseListLoader {
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
					if (source.toString().length === 0 || !_usingCustomDelegate) {
						setSource("delegates/DeviceListDelegate_%1.qml".arg(serviceType), {
							device: Qt.binding(function() { return delegateLoader.device }),
							sourceModel: Qt.binding(function() { return delegateLoader.sourceModel }),
						})
						_usingCustomDelegate = true
					}
				} else {
					if (source.toString().length === 0 || _usingCustomDelegate) {
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
			topPadding: spacing
			preferredVisible: gensetMenu.preferredVisible
					|| tankPumpMenu.preferredVisible
					|| removeDisconnectedButton.preferredVisible

			ListNavigation {
				id: gensetMenu
				//% "Genset"
				text: qsTrId("devicelistpage_genset")
				preferredVisible: relay0.valid && relayFunction.valid && relayFunction.value === VenusOS.Relay_Function_GeneratorStartStop
				onClicked: Global.pageManager.pushPage("/pages/settings/PageRelayGenerator.qml", {"title": text})

				VeQuickItem {
					id: relay0
					uid: Global.system.serviceUid + "/Relay/0/State"
				}
			}

			ListNavigation {
				id: tankPumpMenu
				preferredVisible: relayFunction.valid && relayFunction.value === VenusOS.Relay_Function_Tank_Pump
				//% "Tank pump"
				text: qsTrId("settings_tank_pump")
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsTankPump.qml", {"title": text})
			}

			ListButton {
				id: removeDisconnectedButton
				//% "Remove disconnected devices"
				text: qsTrId("devicelist_remove_disconnected_devices")
				secondaryText: CommonWords.remove
				preferredVisible: Global.allDevicesModel.disconnectedDeviceCount > 0
				onClicked: {
					Global.allDevicesModel.removeDisconnectedDevices()
				}
			}
		}
	}

	VeQuickItem {
		id: relayFunction
		uid: Global.systemSettings.serviceUid + "/Settings/Relay/Function"
	}
}
