/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix
	property Page deviceSettingsPage

	VeQuickItem {
		id: phaseSettingItem
		uid: root.bindPrefix + "/PhaseSetting"
	}
	VeQuickItem {
		id: productId
		uid: root.bindPrefix + "/ProductId"
	}
	VeQuickItem {
		id: allowedRoles

		uid: root.bindPrefix + "/AllowedRoles"
		onValueChanged: {
			const roles = value
			roleDC.optionModel = roles ? roles.map(function(v) {
				return { "display": Global.acInputs.roleName(v), "value": v }
			}) : []
		}
	}
	VeQuickItem {
		id: em24SwitchPosItem
		uid: root.bindPrefix + "/SwitchPos"
	}

	/*
	 * This is a bit weird, when changing the role in a cgwacs service, it will
	 * directly disconnect, without a reply or signal that the value changed. So
	 * the gui blindly trust the remote for now to change its servicename and
	 * wait for it, which can take up to some seconds. It is not reacting in
	 * the meantime, but also not stuck. Eventually it ends up finding the new
	 * service, but it would not hurt to find a better way to do this.
	 */
	function updateServiceName(role) {
		var s = bindPrefix.split('.');

		if (s[2] === role)
			return;

		s[2] = role;
		bindPrefix = s.join('.');
	}

	function em24Locked() {
		return em24SwitchPosItem.valid && em24SwitchPosItem.value === 3
	}

	function em24SwitchText(pos) {
		switch (pos) {
		case 0:
			//% "Unlocked (kVARh)"
			return qsTrId("ac-in-setup_unlocked_(kvarh)")
		case 1:
			//% "Unlocked (2)"
			return qsTrId("ac-in-setup_unlocked_(2)")
		case 2:
			//% "Unlocked (1)"
			return qsTrId("ac-in-setup_unlocked_(1)")
		case 3:
			//% "Locked"
			return qsTrId("ac-in-setup_locked")
		}
		return CommonWords.unknown_status
	}
	GradientListView {
		id: settingsListView

		model: DelegateComponentModel {
			DelegateComponent {
				id: roleDC
				dataItem: VeQuickItem { uid: root.bindPrefix + "/Role" }
				property var currentValue: dataItem.valid ? dataItem.value : undefined
				property var optionModel: []
				ListRadioButtonGroup {
					id: role

					text: CommonWords.ac_input_role
					dataItem.uid: root.bindPrefix + "/Role"
					optionModel: roleDC.optionModel
					popDestination: undefined
					updateDataOnClick: false
					onOptionClicked: function(index) {
						//% "%1 changed role, the devices list has been updated"
						const msg = qsTrId("settings_ac-in-setup_changed_role").arg(device.name)
						Global.showToastNotification(VenusOS.Notification_Info, msg, 10000)
						role.dataItem.setValue(role.optionModel[index].value)
						Global.pageManager.popToAbovePage(root.deviceSettingsPage)
					}

					Device {
						id: device
						serviceUid: root.bindPrefix
					}
				}
			}

			DelegateComponent {
				preferredVisible: roleDC.currentValue === "pvinverter"
				ListPvInverterPositionRadioButtonGroup {
					dataItem.uid: root.bindPrefix + "/Position"
				}
			}

			DelegateComponent {
				preferredVisible: roleDC.currentValue === "acload"
						|| roleDC.currentValue === "evcharger"
						|| roleDC.currentValue === "heatpump"
				ListAcInPositionRadioButtonGroup {
					bindPrefix: root.bindPrefix
				}
			}

			DelegateComponent {
				/* EM24 settings */

				ListRadioButtonGroup {
					//% "Phase configuration"
					text: qsTrId("ac-in-setup_phase_configuration")
					preferredVisible: productId.value == ProductInfo.ProductId_EnergyMeter_Em24
					dataItem.uid: root.bindPrefix + "/PhaseConfig"
					interactive: dataItem.valid && !em24Locked()
					optionModel: [
						{ display: "3P.n", value: 0 },
						{ display: "3P.1", value: 1 },
						{ display: "2P", value: 2 },
						{ display: "1P", value: 3 },
						{ display: "3P", value: 4 }
					]
				}
			}

			DelegateComponent {
				preferredVisible: productId.value == ProductInfo.ProductId_EnergyMeter_Em24
				ListText {
					id: em24SwitchPos
					//% "Switch position"
					text: qsTrId("ac-in-setup_switch_position")
					dataItem.uid: root.bindPrefix + "/SwitchPos"
					secondaryText: dataItem.valid ? em24SwitchText(dataItem.value) : "--"
				}
			}

			DelegateComponent {
				preferredVisible: productId.value == ProductInfo.ProductId_EnergyMeter_Em24 && em24Locked()
				PrimaryListLabel {
					text: qsTr("Set the switch in an unlocked position to modify the settings.")
				}
			}

			DelegateComponent {
				/* Smappee settings */

				ListRadioButtonGroup {
					//% "Phase configuration"
					text: qsTrId("ac-in-setup_phase_configuration")
					preferredVisible: productId.value == ProductInfo.ProductId_PowerBox_Smappee
					dataItem.uid: root.bindPrefix + "/PhaseConfig"
					optionModel: [
						//% "Single phase"
						{ display: qsTrId("ac-in-setup_single_phase"), value: 0 },
						//% "2-phase"
						{ display: qsTrId("ac-in-setup_two_phase"), value: 2 },
						//% "3-phase"
						{ display: qsTrId("ac-in-setup_three_phase"), value: 1 },
					]
				}
			}

			DelegateComponent {
				preferredVisible: phaseSettingItem.valid
				ListRadioButtonGroup {
					//% "Phase Setting"
					text: qsTrId("ac-in-setup-default_phase_setting")
					dataItem.uid: root.bindPrefix + "/PhaseSetting"
					optionModel: [
						{ display: CommonWords.ac_phase_x.arg(1), value: 1 },
						{ display: CommonWords.ac_phase_x.arg(2), value: 2 },
						{ display: CommonWords.ac_phase_x.arg(3), value: 3 },
					]
				}
			}

			DelegateComponent {
				preferredVisible: productId.value == ProductInfo.ProductId_PowerBox_Smappee
				ListNavigation {
					text: CommonWords.current_transformers
					onClicked: {
						Global.pageManager.pushPage("/pages/settings/devicelist/ac-in/PageSmappeeCTList.qml",
								{ "title": text, "bindPrefix": root.bindPrefix })
					}
				}
			}

			DelegateComponent {
				preferredVisible: productId.value == ProductInfo.ProductId_PowerBox_Smappee
				ListNavigation {
					//% "Devices"
					text: qsTrId("ac-in-setup_devices")
					onClicked: {
						Global.pageManager.pushPage("/pages/settings/devicelist/ac-in/PageSmappeeDeviceList.qml",
								{ "bindPrefix": root.bindPrefix })
					}
				}
			}
		}
	}
}