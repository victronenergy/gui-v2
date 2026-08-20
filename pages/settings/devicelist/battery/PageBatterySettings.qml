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

	VeQuickItem {
		id: bluetoothModeItem
		uid: root.bindPrefix + "/Settings/BluetoothMode"
	}

	ObjectModelMonitor {
		id: batteryBankModelMonitor
		model: batteryBankModel
	}
	ObjectModelMonitor {
		id: alarmSettingsMonitor
		model: batterySettingsAlarmModel
	}
	ObjectModelMonitor {
		id: relaySettingsMonitor
		model: batterySettingsRelayModel
	}

	BatteryBankModel {
		id: batteryBankModel
		bindPrefix: root.bindPrefix
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
		model: DelegateComponentModel {
			DelegateComponent {
				preferredVisible: batteryBankModelMonitor.hasVisibleItem
				ListNavigation {
					//% "Battery bank"
					text: qsTrId("batterysettings_battery_bank")
					onClicked: {
						Global.pageManager.pushPage(emptySettingsComponent,
								{ "title": text, "model": batteryBankModel })
					}
				}
			}

			DelegateComponent {
				preferredVisible: alarmSettingsMonitor.hasVisibleItem
				ListNavigation {
					text: CommonWords.alarms
					onClicked: {
						Global.pageManager.pushPage(emptySettingsComponent,
								{ "title": text, "model": batterySettingsAlarmModel })
					}
				}
			}

			DelegateComponent {
				preferredVisible: relaySettingsMonitor.hasVisibleItem
				ListNavigation {
					//% "Relay (on battery monitor)"
					text: qsTrId("batterysettings_relay_on_battery_monitor")
					onClicked: {
						Global.pageManager.pushPage(emptySettingsComponent,
								{ "title": text, "model": batterySettingsRelayModel })
					}
				}
			}

			DelegateComponent {
				id: restoreDefaultsDC
				dataItem: VeQuickItem { uid: root.bindPrefix + "/Settings/RestoreDefaults" }
				preferredVisible: restoreDefaultsDC.dataItem.valid
				ListButton {
					//% "Restore factory defaults"
					text: qsTrId("batterysettings_restore_factory_defaults")
					//% "Restore"
					secondaryText: qsTrId("batterysettings_restore")
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
			}

			DelegateComponent {
				preferredVisible: bluetoothModeItem.valid
				ListSwitch {
					//% "Bluetooth Enabled"
					text: qsTrId("batterysettings_bluetooth_enabled")
					dataItem.uid: root.bindPrefix + "/Settings/BluetoothMode"
				}
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