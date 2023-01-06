/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

Page {
	id: root

	property string bindPrefix: "com.victronenergy.modem"
	property string settingsBindPrefix: "com.victronenergy.settings/Settings/Modem"

	function getScaledStrength(strength) {
		if (Utils.between(strength, 0, 3)) {
			return 0
		}
		if (Utils.between(strength, 4, 9)) {
			return 1
		}
		if (Utils.between(strength, 10, 14)) {
			return 2
		}
		if (Utils.between(strength, 15, 19) ) {
			return 3
		}
		if (Utils.between(strength, 21, 31)) {
			return 4
		}
		return 0
	}

	DataPoint {
		id: simStatus
		source: bindPrefix + "/SimStatus"
	}

	DataPoint {
		id: apnSetting
		source: settingsBindPrefix + "/APN"
	}

	DataPoint {
		id: networkType
		source: bindPrefix + "/NetworkType"
	}

	SettingsListView {
		id: settingsListView

		model: simStatus.valid ? modemConnected : notConnected

		ObjectModel {
			id: notConnected

			SettingsListItem {
				//% "No GSM modem connected"
				text: qsTrId("page_settings_no_gsm_modem_connected")
			}
		}

		ObjectModel {
			id: modemConnected

			SettingsListRadioButtonGroup {
				id: status

				//% "Internet"
				text: qsTrId("page_settings_gsm_internet")
				source: bindPrefix + "/Connected"
				optionModel: [
					{ display: CommonWords.offline, value: 0 },
					{ display: CommonWords.online, value: 1 }
				]
			}

			SettingsListTextItem {
				id: carrier

				//% "Carrier"
				text: qsTrId("page_settings_gsm_carrier")
				secondaryText: valid ? value + " " + Utils.simplifiedNetworkType(networkType.value) : "--"
				source: bindPrefix + "/NetworkName"
			}

			SettingsListItem {
				text: CommonWords.signal_strength

				content.children: [
					Rectangle { // TODO: update this when we get a design
						anchors.verticalCenter: parent.verticalCenter
						width: 32
						height: 28
						color: "#ddd"

						GsmStatusIcon {
							id: gsmStatusIcon
							height: 18
							color: "#000000"
							showNetworkType: false
							anchors.centerIn: parent
						}
					}
				]
				visible: gsmStatusIcon.valid
			}

			SettingsListItem {
				//% "It may be necessary to configure the APN settings below in this page, contact your operator for details.\nIf that doesn't work, check sim-card in a phone to make sure that there is credit and/or it is registered to be used for data."
				text: qsTrId("page_settings_gsm_error_message")
				visible: status.value === 0 && carrier.valid && simStatus.value === 1000
			}

			SettingsListSwitch {
				//% "Allow roaming"
				text: qsTrId("page_settings_gsm_allow_roaming")
				source: settingsBindPrefix + "/RoamingPermitted"
				writeAccessLevel: VenusOS.User_AccessType_User
			}

			SettingsListRadioButtonGroup {
				//% "Sim status"
				text: qsTrId("page_settings_gsm_sim_status")
				//% "Unknown"
				defaultSecondaryText: qsTrId("page_settings_gsm_unknown")
				optionModel: [
					//% "SIM not inserted"
					{ display: qsTrId("page_settings_gsm_sim_not_inserted"), value: 10},
					//% "PIN required"
					{ display: qsTrId("page_settings_gsm_pin_required"), value: 11},
					//% "PUK required"
					{ display: qsTrId("page_settings_gsm_puk_required"), value: 12},
					//% "SIM failure"
					{ display: qsTrId("page_settings_gsm_sim_failure"), value: 13},
					//% "SIM busy"
					{ display: qsTrId("page_settings_gsm_sim_busy"), value: 14},
					//% "Wrong SIM"
					{ display: qsTrId("page_settings_gsm_wrong_sim"), value: 15},
					//% "Wrong PIN"
					{ display: qsTrId("page_settings_gsm_wrong_pin"), value: 16},
					//% "Ready"
					{ display: qsTrId("page_settings_gsm_ready"), value: 1000},
					//% "Unknown error"
					{ display: qsTrId("page_settings_gsm_unknown_error"), value: 1001},
				]
				enabled: false
				source: bindPrefix + "/SimStatus"
			}

			SettingsListTextField {
				//% "PIN"
				text: qsTrId("page_settings_gsm_pin")
				textField.maximumLength: 35
				source: settingsBindPrefix + "/PIN"
				writeAccessLevel: VenusOS.User_AccessType_User
				// Show only when PIN required
				visible: valid && [11, 16].indexOf(simStatus.value)  > -1
			}

			SettingsListTextItem {
				text: CommonWords.ip_address
				source: bindPrefix + "/IP"
				visible: status.value === 1
			}

			SettingsListNavigationItem {
				//% "APN"
				text: qsTrId("page_settings_gsm_apn")
				//% "Default"
				secondaryText: (!apnSetting.valid || apnSetting.value === "") ? qsTrId("page_settings_gsm_default") : apnSetting.value
				onClicked: Global.pageManager.pushPage(apnPage, { title: text })
				Component {
					id: apnPage

					Page {

						SettingsListView {

							model: ObjectModel {

								SettingsListSwitch {
									id: useDefaultApn
									//% "Use default APN"
									text: qsTrId("page_settings_gsm_use_default_apn")
									checked: apnSetting.value === ""
									onCheckedChanged: {
										if (apnSetting.valid && checked)
											apnSetting.setValue("")
									}
								}

								SettingsListTextField {
									//% "APN name"
									text: qsTrId("page_settings_gsm_apn_name")
									source: root.settingsBindPrefix + "/APN"
									visible: !useDefaultApn.checked
									textField.maximumLength: 50
								}
							}
						}
					}
				}
			}

			SettingsListSwitch {
				id: useAuth
				//% "Use authentication"
				text: qsTrId("page_settings_gsm_use_authentication")
				checked: authUser.value !== "" && authPass.value !== ""
				onCheckedChanged: {
					if (!checked) {
						authUser.item.setValue("")
						authPass.item.setValue("")
					}
				}
			}

			SettingsListTextField {
				id: authUser

				//% "User name"
				text: qsTrId("page_settings_gsm_user_name")
				source: settingsBindPrefix + "/User"
				visible: useAuth.checked
			}

			SettingsListTextField {
				id: authPass

				text: CommonWords.password
				source: settingsBindPrefix + "/Password"
				visible: useAuth.checked
			}

			SettingsListTextItem {
				//% "IMEI"
				text: qsTrId("page_settings_gsm_imei")
				source: bindPrefix + "/IMEI"
				visible: valid
			}
		}
	}
}

