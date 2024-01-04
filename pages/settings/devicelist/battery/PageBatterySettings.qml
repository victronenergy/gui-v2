/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

Page {
	id: root

	property string bindPrefix

	property bool _hasVisibleAlarmSettings
	property bool _hasVisibleRelaySettings

	function _hasVisibleItem(model) {
		for (let i = 0; i < model.count; ++i) {
			if (model.get(i).visible) {
				return true
			}
		}
		return false
	}

	BatterySettingsAlarmModel {
		id: batterySettingsAlarmModel
		bindPrefix: root.bindPrefix
	}

	Instantiator {
		model: batterySettingsAlarmModel.count
		delegate: Connections {
			target: batterySettingsAlarmModel.get(model.index)
			function onVisibleChanged() {
				root._hasVisibleAlarmSettings = target.visible || root._hasVisibleItem(batterySettingsAlarmModel)
			}
			Component.onCompleted: onVisibleChanged()
		}
	}

	BatterySettingsRelayModel {
		id: batterySettingsRelayModel
		bindPrefix: root.bindPrefix
	}

	Instantiator {
		model: batterySettingsRelayModel.count
		delegate: Connections {
			target: batterySettingsRelayModel.get(model.index)
			function onVisibleChanged() {
				root._hasVisibleRelaySettings = target.visible || root._hasVisibleItem(batterySettingsRelayModel)
			}
			Component.onCompleted: onVisibleChanged()
		}
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
				visible: root._hasVisibleAlarmSettings
				onClicked: {
					Global.pageManager.pushPage(emptySettingsComponent,
							{ "title": text, "model": batterySettingsAlarmModel })
				}
			}

			ListNavigationItem {
				//% "Relay (on battery monitor)"
				text: qsTrId("batterysettings_relay_on_battery_monitor")
				visible: root._hasVisibleRelaySettings
				onClicked: {
					Global.pageManager.pushPage(emptySettingsComponent,
							{ "title": text, "model": batterySettingsRelayModel })
				}
			}

			ListButton {
				property var _confirmationDialog

				//% "Restore factory defaults"
				text: qsTrId("batterysettings_restore_factory_defaults")
				//% "Press to restore"
				secondaryText: qsTrId("batterysettings_press_to_restore")
				visible: defaultVisible && restoreDefaults.isValid
				onClicked: {
					if (!_confirmationDialog) {
						_confirmationDialog = confirmationDialogComponent.createObject(Global.dialogLayer)
					}
					_confirmationDialog.open()
				}

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

			ListRadioButtonGroupNoYes {
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
