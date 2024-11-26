/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

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
		return em24SwitchPos.dataItem.isValid && em24SwitchPos.dataItem.value === 3
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

	VeQuickItem {
		id: productId
		uid: root.bindPrefix + "/ProductId"
	}

	VeQuickItem {
		id: allowedRoles

		uid: root.bindPrefix + "/AllowedRoles"
		onValueChanged: {
			const roles = value
			role.optionModel = roles ? roles.map(function(v) {
				// heatpump feature is not properly supported yet. So, hide it unless it is the
				// currently selected option.
				return { "display": Global.acInputs.roleName(v), "value": v, "readOnly": v === "heatpump" }
			}) : []
		}
	}

	GradientListView {
		id: settingsListView

		model: ObjectModel {
			ListRadioButtonGroup {
				id: role

				text: CommonWords.ac_input_role
				dataItem.uid: root.bindPrefix + "/Role"
				popDestination: null
				onOptionClicked: function(index) {
					// Changing the role invalidates this whole page, so close the radio buttons
					// page before updating the role.
					secondaryText = optionModel[index].display
					Global.pageManager.popPage()
					root.updateServiceName(optionModel[index].value)
				}
			}

			PvInverterPositionRadioButtonGroup {
				dataItem.uid: root.bindPrefix + "/Position"
				allowed: role.currentValue === "pvinverter"
			}

			/* EM24 settings */

			ListRadioButtonGroup {
				//% "Phase configuration"
				text: qsTrId("ac-in-setup_phase_configuration")
				allowed: productId.value == ProductInfo.ProductId_EnergyMeter_Em24
				dataItem.uid: root.bindPrefix + "/PhaseConfig"
				enabled: !em24Locked()
				optionModel: [
					{ display: "3P.n", value: 0 },
					{ display: "3P.1", value: 1 },
					{ display: "2P", value: 2 },
					{ display: "1P", value: 3 },
					{ display: "3P", value: 4 }
				]
			}

			ListTextItem {
				id: em24SwitchPos
				//% "Switch position"
				text: qsTrId("ac-in-setup_switch_position")
				allowed: productId.value == ProductInfo.ProductId_EnergyMeter_Em24
				dataItem.uid: root.bindPrefix + "/SwitchPos"
				secondaryText: dataItem.isValid ? em24SwitchText(dataItem.value) : "--"
			}

			PrimaryListLabel {
				text: qsTr("Set the switch in an unlocked position to modify the settings.")
				allowed: productId.value == ProductInfo.ProductId_EnergyMeter_Em24 && em24Locked()
			}

			/* Smappee settings */

			ListRadioButtonGroup {
				//% "Phase configuration"
				text: qsTrId("ac-in-setup_phase_configuration")
				allowed: productId.value == ProductInfo.ProductId_PowerBox_Smappee
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

			ListNavigationItem {
				text: CommonWords.current_transformers
				allowed: productId.value == ProductInfo.ProductId_PowerBox_Smappee
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/ac-in/PageSmappeeCTList.qml",
							{ "title": text, "bindPrefix": root.bindPrefix })
				}
			}

			ListNavigationItem {
				//% "Devices"
				text: qsTrId("ac-in-setup_devices")
				allowed: productId.value == ProductInfo.ProductId_PowerBox_Smappee
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/ac-in/PageSmappeeDeviceList.qml",
							{ "bindPrefix": root.bindPrefix })
				}
			}
		}
	}
}
