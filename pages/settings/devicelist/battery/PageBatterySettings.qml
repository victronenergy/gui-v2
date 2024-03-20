/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

	// Declare ObjectModelMonitor before the model that it is monitoring. See QTBUG-123496
	ObjectModelMonitor {
		id: alarmSettingsMonitor
		model: batterySettingsAlarmModel
	}
	ObjectModelMonitor {
		id: relaySettingsMonitor
		model: batterySettingsRelayModel
	}

	BatterySettingsAlarmModel {
		id: batterySettingsAlarmModel
		bindPrefix: root.bindPrefix
	}

	BatterySettingsRelayModel {
		id: batterySettingsRelayModel
		bindPrefix: root.bindPrefix
	}

	GradientListView {
		model: ObjectModel {
			ListNavigationItem {
				//% "Battery bank"
				text: qsTrId("batterysettings_battery_bank")
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/battery/PageBatterySettingsBattery.qml",
							{ "title": text, "bindPrefix": root.bindPrefix })
				}
			}

			ListNavigationItem {
				text: CommonWords.alarms
				visible: alarmSettingsMonitor.hasVisibleItem
				onClicked: {
					Global.pageManager.pushPage(emptySettingsComponent,
							{ "title": text, "model": batterySettingsAlarmModel })
				}
			}

			ListNavigationItem {
				//% "Relay (on battery monitor)"
				text: qsTrId("batterysettings_relay_on_battery_monitor")
				visible: relaySettingsMonitor.hasVisibleItem
				onClicked: {
					Global.pageManager.pushPage(emptySettingsComponent,
							{ "title": text, "model": batterySettingsRelayModel })
				}
			}

			ListButton {
				//% "Restore factory defaults"
				text: qsTrId("batterysettings_restore_factory_defaults")
				//% "Press to restore"
				secondaryText: qsTrId("batterysettings_press_to_restore")
				visible: defaultVisible && restoreDefaults.isValid
				onClicked: Global.dialogLayer.open(confirmationDialogComponent)

				Component {
					id: confirmationDialogComponent

					ModalWarningDialog {
						dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel

						//% "Restore factory defaults?"
						title: qsTrId("batterysettings_confirm_restore_factory_defaults")

						onAccepted: restoreDefaults.setValue(1)
					}
				}

				VeQuickItem {
					id: restoreDefaults
					uid: root.bindPrefix + "/Settings/RestoreDefaults"
				}
			}

			ListSwitch {
				//% "Bluetooth Enabled"
				text: qsTrId("batterysettings_bluetooth_enabled")
				dataItem.uid: root.bindPrefix + "/Settings/BluetoothMode"
				visible: defaultVisible && dataItem.isValid
			}
		}
	}

	Component {
		id: emptySettingsComponent

		Page {
			property alias model: settingsListView.model

			GradientListView {
				id: settingsListView
			}
		}

	}
}
