/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	readonly property string loggerServiceUid: BackendConnection.serviceUidForType("logger")

	function timeAgo(timestamp) {
		const timeNow = Math.round(new Date() / 1000)
		let timeAgo = "--"
		if (timestamp !== undefined && timestamp > 0) {
			const point = timeNow - timestamp
			if (point < 0) {
				//: %1 = number of seconds
				//% "Deferred by %1s"
				timeAgo = qsTrId("settings_logging_time_ago_deferred").arg(Math.abs(point))
			} else {
				timeAgo = Utils.secondsToString(point)
			}
		}
		return timeAgo

	}

	GradientListView {
		id: settingsListView

		model: VisibleItemModel {

			ListRadioButtonGroup {
				id: vrmPortalMode

				function setMode(mode) {
					dataItem.setValue(mode)
					Global.pageManager.popPage(root)
				}

				//% "VRM Portal"
				text: qsTrId("settings_logging_vrm_portal")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Network/VrmPortal"
				updateDataOnClick: false
				updateCurrentIndexOnClick: false // track backend value, set only when confirmation dialog is accepted.
				popDestination: undefined   // do not automatically pop page when value is selected
				optionModel: [
					{ display: CommonWords.off, value: VenusOS.Vrm_PortalMode_Off },
					//% "Read-only"
					{ display: qsTrId("settings_vrm_portal_readonly"), value: VenusOS.Vrm_PortalMode_ReadOnly },
					//% "Full"
					{ display: qsTrId("settings_vrm_portal_full"), value: VenusOS.Vrm_PortalMode_Full }
				]
				onOptionClicked: (index, password) => {
					// When connecting via VRM, confirm mode changes that will lock the user out
					// of the VRM portal connection.
					const newMode = optionModel[index].value
					if (newMode !== VenusOS.Vrm_PortalMode_Full && Qt.platform.os == "wasm" && BackendConnection.vrm) {
						Global.dialogLayer.open(modeConfirmationDialogComponent, { mode: newMode })
					} else {
						setMode(newMode)
					}
				}

				Component {
					id: modeConfirmationDialogComponent

					ModalWarningDialog {
						property int mode

						//% "Are you sure?"
						title: qsTrId("settings_vrm_portal_mode_confirm_title")
						//% "Changing this setting to Read-only or Off will lock you out."
						description: qsTrId("settings_vrm_portal_mode_confirm_description")
						dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel
						onAccepted: vrmPortalMode.setMode(mode)
					}
				}
			}

			ListText {
				id: portalId
				//% "VRM Portal ID"
				text: qsTrId("settings_vrm_portal_id")
				dataItem.uid: Global.venusPlatform.serviceUid + "/Device/UniqueId"
			}

			ListLink {
				preferredVisible: portalId.dataItem.valid && productId.valid

				//% "VRM Device Registration"
				text: qsTrId("settings_vrm_device_registration")
				url: "https://vrm.victronenergy.com/login?installationIdentifier=%1&productId=%2".arg(portalId.dataItem.value).arg(productId.value)

				VeQuickItem {
					id: productId
					uid: Global.venusPlatform.serviceUid + "/Device/ProductId"
				}
			}

			ListNavigation {
				//% "VRM device instances"
				text: qsTrId("settings_vrm_device_instances")
				onClicked: Global.pageManager.pushPage("/pages/settings/PageVrmDeviceInstances.qml", {"title": text })
			}

			ListRadioButtonGroup {
				//% "Log interval"
				text: qsTrId("settings_log_interval")
				optionModel: [
					//% "1 min"
					{ display: qsTrId("settings_1_min"), value: 60 },
					//% "5 min"
					{ display: qsTrId("settings_5_min"), value: 300 },
					//% "10 min"
					{ display: qsTrId("settings_10_min"), value: 600 },
					//% "15 min"
					{ display: qsTrId("settings_15_min"), value: 900 },
					//% "30 min"
					{ display: qsTrId("settings_30_min"), value: 1800 },
					//% "1 hour"
					{ display: qsTrId("settings_1_hr"), value: 3600 },
					//% "2 hours"
					{ display: qsTrId("settings_2_hr"), value: 7200 },
					//% "4 hours"
					{ display: qsTrId("settings_4_hr"), value: 14400 },
					//% "12 hours"
					{ display: qsTrId("settings_12_hr"), value: 43200 },
					//% "1 day"
					{ display: qsTrId("settings_1_day"), value: 86400 },
				]
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Vrmlogger/LogInterval"
				preferredVisible: vrmPortalMode.dataItem.valid && vrmPortalMode.dataItem.value > 0
			}

			ListSwitch {
				id: useHttps

				//% "Use secure connection (HTTPS)"
				text: qsTrId("settings_https_enabled")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Vrmlogger/HttpsEnabled"
				preferredVisible: securityProfile.value !== VenusOS.Security_Profile_Secured

				VeQuickItem {
					id: securityProfile
					uid: Global.systemSettings.serviceUid + "/Settings/System/SecurityProfile"
				}
			}

			ListText {
				//% "Last contact"
				text: qsTrId("settings_last_contact")
				dataItem.uid: root.loggerServiceUid + "/Vrm/TimeLastContact"
				preferredVisible: vrmPortalMode.dataItem.valid && vrmPortalMode.dataItem.value !== VenusOS.Vrm_PortalMode_Off

				Timer {
					interval: 1000
					running: parent.visible && root.animationEnabled
					repeat: true
					triggeredOnStart: true
					onTriggered: parent.secondaryText = root.timeAgo(parent.dataItem.value)
				}
			}

			ListText {
				id: connectionStatus

				// Status of vrmlogger
				property VeQuickItem httpsConnectionError: VeQuickItem {
					uid: root.loggerServiceUid + "/Vrm/ConnectionError"
				}

				/*
				 * Status of the MQTT bridges, type bool, set to undefined when the bridge is not
				 * supposed to run. In other words: when it has a value and is false, then there is a problem.
				 */
				property VeQuickItem mqttRealtimeConnected: VeQuickItem {
					uid: Global.venusPlatform.serviceUid + "/Mqtt/Bridges/GXdbus/Connected"
				}
				property VeQuickItem mqttRealtimeStatus: VeQuickItem {
					uid: Global.venusPlatform.serviceUid + "/Mqtt/Bridges/GXdbus/ConnectionStatus"
				}
				property VeQuickItem mqttRpcConnected: VeQuickItem {
					uid: Global.venusPlatform.serviceUid + "/Mqtt/Bridges/GXrpc/Connected"
				}
				property VeQuickItem mqttRpcStatus: VeQuickItem {
					uid: Global.venusPlatform.serviceUid + "/Mqtt/Bridges/GXrpc/ConnectionStatus"
				}

				readonly property bool anyError:
					httpsConnectionError.value ||
					mqttRealtimeConnected.value === false ||
					mqttRpcConnected.value === false

				//% "Connection status"
				text: qsTrId("settings_connection_status")
				secondaryText: CommonWords.no_error
				preferredVisible: !anyError
			}

			ListText {
				function stringForErrorCode(errorCode) {
					switch (errorCode) {
					case 0:
						return CommonWords.no_error
					case 150:
						//% "#150 Unexpected response text"
						return qsTrId("settings_connection_error_150")
					case 151:
						//% "#151 Unexpected HTTP response"
						return qsTrId("settings_connection_error_151")
					case 152:
						//% "#152 Connection timeout"
						return qsTrId("settings_connection_error_152")
					case 153:
						//% "#153 Connection error"
						return qsTrId("settings_connection_error_153")
					case 154:
						//% "#154 DNS failure"
						return qsTrId("settings_connection_error_154")
					case 155:
						//% "#155 Routing error"
						return qsTrId("settings_connection_error_155")
					case 156:
						//% "#156 VRM unavailable"
						return qsTrId("settings_connection_error_156")
					case 157:
						//% "#159 Unknown error"
						return qsTrId("settings_connection_error_157")
					default:
						return ""
					}
				}

				text: useHttps.dataItem.value ?
					//% "Connection status (HTTPS channel)"
					qsTrId("settings_connection_error_https_channel") :
					//% "Connection status (HTTP channel)"
					qsTrId("settings_connection_error_http_channel")
				secondaryText: stringForErrorCode(connectionStatus.httpsConnectionError.value)
				preferredVisible: !connectionStatus.preferredVisible
			}

			ListItem {
				//% "Error message: \n%1"
				text: qsTrId("settings_vrm_error_message").arg(errorMessage.value)
				preferredVisible: !!errorMessage.value

				VeQuickItem {
					id: errorMessage
					uid: root.loggerServiceUid + "/Vrm/ConnectionErrorMessage"
				}
			}

			ListText {
				//% "Connection status (MQTT Real-time channel)"
				text: qsTrId("settings_connection_error_realtime_channel")
				secondaryText: connectionStatus.mqttRealtimeStatus.value || ''
				preferredVisible: !connectionStatus.preferredVisible && connectionStatus.mqttRealtimeConnected.valid
			}

			ListText {
				//% "Connection status (MQTT RPC channel)"
				text: qsTrId("settings_connection_error_rpc_channel")
				secondaryText: connectionStatus.mqttRpcStatus.value || ''
				preferredVisible: !connectionStatus.preferredVisible && connectionStatus.mqttRpcConnected.valid
			}

			ListSwitch {
				//% "Reboot device when no contact"
				text: qsTrId("settings_no_contact_reboot")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Watchdog/VrmTimeout"
				updateDataOnClick: false
				checked: dataItem.value !== 0
				onClicked: dataItem.setValue(checked ? 0 : 3600)
			}

			ListTimeSelector {
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Watchdog/VrmTimeout"
				//% "No contact reset delay (hh:mm)"
				text: qsTrId("settings_vrm_no_contact_reset_delay")
				preferredVisible: !!dataItem.value && dataItem.value > 0
			}

			ListRadioButtonGroup {
				//% "Storage location"
				text: qsTrId("settings_vrm_storage_location")
				//% "No buffer active"
				defaultSecondaryText: qsTrId("settings_vrm_no_buffer_active")
				optionModel: [
					//% "Internal storage"
					{ display: qsTrId("settings_vrm_internal_storage"), value: 0 },
					//% "Transferring"
					{ display: qsTrId("settings_vrm_transferring"), value: 1 },
					//% "External storage"
					{ display: qsTrId("settings_vrm_external_storage"), value: 2 },
				]
				dataItem.uid: root.loggerServiceUid + "/Buffer/Location"
				interactive: dataItem.value !== undefined
			}

			ListRadioButtonGroup {
				text: CommonWords.error
				//% "Unknown error"
				defaultSecondaryText: qsTrId("settings_vrm_unknown_error")
				optionModel: [
					//% "No Error"
					{ display: qsTrId("settings_vrm_no_error"), value: 0 },
					//% "No space left on storage"
					{ display: qsTrId("settings_vrm_no_space_error"), value: 1 },
					//% "IO error"
					{ display: qsTrId("settings_vrm_io_error"), value: 2 },
					//% "Mount error"
					{ display: qsTrId("settings_vrm_mount_error"), value: 3 },
					//% "Contains firmware image. Not using."
					{ display: qsTrId("settings_vrm_storage_contains_firmware_error"), value: 4 },
					//% "SD card / USB stick not writable"
					{ display: qsTrId("settings_vrm_storage_not_writable_error"), value: 5 },
				]
				interactive: false
				dataItem.uid: root.loggerServiceUid + "/Buffer/ErrorState"
				preferredVisible: !!dataItem.value
			}

			ListText { // This 'flickers' between values for ~30s after inserting a usb stick. Dbus-spy shows that the underlying data point flickers also. Old gui also flickers.
				//% "Free disk space"
				text: qsTrId("settings_vrm_free_disk_space")
				secondaryText: Utils.qtyToString(dataItem.value,
												 //% "byte"
												 qsTrId("settings_vrm_byte"),
												 //% "bytes"
												 qsTrId("settings_vrm_bytes"))
				dataItem.uid: root.loggerServiceUid + "/Buffer/FreeDiskSpace"
			}

			ListMountStateButton {}

			ListText {
				//% "Stored records"
				text: qsTrId("settings_vrm_stored_records")
				dataItem.uid: root.loggerServiceUid + "/Buffer/Count"
				//% "%1 records"
				secondaryText: qsTrId("settings_vrm_records_count").arg(dataItem.value ? dataItem.value : 0)
			}

			ListText {
				id: oldestBacklogItemAge

				property var timeNow: Math.round(new Date() / 1000)
				//% "Oldest record age"
				text: qsTrId("settings_vrm_oldest_record_age")
				dataItem.uid: root.loggerServiceUid + "/Buffer/OldestTimestamp"

				Timer {
					interval: 1000
					running: !!parent.dataItem.value && root.animationEnabled
					repeat: true
					triggeredOnStart: true
					onTriggered: parent.secondaryText = root.timeAgo(parent.dataItem.value)
				}
			}
		}
	}
}
