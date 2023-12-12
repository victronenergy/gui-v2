/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Utils

Page {
	id: root

	property string bindPrefix: "com.victronenergy.modem"
	property string settingsBindPrefix: "com.victronenergy.settings/Settings/Modem"

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

	GradientListView {
		id: settingsListView

		model: simStatus.valid ? modemConnected : notConnected

		ObjectModel {
			id: notConnected

			ListItem {
				//% "No GSM modem connected"
				text: qsTrId("page_settings_no_gsm_modem_connected")
			}
		}

		ObjectModel {
			id: modemConnected

			ListTextItem {
				id: status

				//% "Internet"
				text: qsTrId("page_settings_gsm_internet")
				secondaryText: dataValue === 1 ? CommonWords.online : CommonWords.offline
				dataSource: bindPrefix + "/Connected"
			}

			ListTextItem {
				id: carrier

				//% "Carrier"
				text: qsTrId("page_settings_gsm_carrier")
				secondaryText: dataValid ? dataValue + " " + Utils.simplifiedNetworkType(networkType.value) : "--"
				dataSource: bindPrefix + "/NetworkName"
			}

			ListItem {
				text: CommonWords.signal_strength

				content.children: [
					Item {
						anchors.verticalCenter: parent.verticalCenter
						width: Theme.geometry.settings.gsmModem.icon.container.width
						height: Theme.geometry.settings.gsmModem.icon.container.height

						GsmStatusIcon {
							id: gsmStatusIcon
							height: Theme.geometry.settings.gsmModem.icon.height
							anchors.centerIn: parent
						}
					}
				]
				visible: gsmStatusIcon.valid
			}

			ListItem {
				//% "It may be necessary to configure the APN settings below in this page, contact your operator for details.\nIf that doesn't work, check sim-card in a phone to make sure that there is credit and/or it is registered to be used for data."
				text: qsTrId("page_settings_gsm_error_message")
				visible: status.dataValue === 0 && carrier.dataValid && simStatus.value === 1000
			}

			ListSwitch {
				//% "Allow roaming"
				text: qsTrId("page_settings_gsm_allow_roaming")
				dataSource: settingsBindPrefix + "/RoamingPermitted"
				writeAccessLevel: Enums.User_AccessType_User
			}

			ListTextItem {
				//% "Sim status"
				text: qsTrId("page_settings_gsm_sim_status")
				secondaryText: {
					switch (dataValue) {
					case 10:
						//% "SIM not inserted"
						return qsTrId("page_settings_gsm_sim_not_inserted")
					case 11:
						//% "PIN required"
						return qsTrId("page_settings_gsm_pin_required")
					case 12:
						//% "PUK required"
						return qsTrId("page_settings_gsm_puk_required")
					case 13:
						//% "SIM failure"
						return qsTrId("page_settings_gsm_sim_failure")
					case 14:
						//% "SIM busy"
						return qsTrId("page_settings_gsm_sim_busy")
					case 15:
						//% "Wrong SIM"
						return qsTrId("page_settings_gsm_wrong_sim")
					case 16:
						//% "Wrong PIN"
						return qsTrId("page_settings_gsm_wrong_pin")
					case 1000:
						//% "Ready"
						return qsTrId("page_settings_gsm_ready")
					default:
						//% "Unknown error"
						return qsTrId("page_settings_gsm_unknown_error")
					}
				}
				dataSource: bindPrefix + "/SimStatus"
			}

			ListTextField {
				//% "PIN"
				text: qsTrId("page_settings_gsm_pin")
				textField.maximumLength: 35
				dataSource: settingsBindPrefix + "/PIN"
				writeAccessLevel: Enums.User_AccessType_User
				// Show only when PIN required
				visible: dataValid && [11, 16].indexOf(simStatus.value)  > -1
			}

			ListTextItem {
				text: CommonWords.ip_address
				dataSource: bindPrefix + "/IP"
				visible: status.dataValue === 1
			}

			ListNavigationItem {
				//% "APN"
				text: qsTrId("page_settings_gsm_apn")
				//% "Default"
				secondaryText: (!apnSetting.valid || apnSetting.value === "") ? qsTrId("page_settings_gsm_default") : apnSetting.value
				onClicked: Global.pageManager.pushPage(apnPage, { title: text })
				Component {
					id: apnPage

					Page {

						GradientListView {

							model: ObjectModel {

								ListSwitch {
									id: useDefaultApn
									//% "Use default APN"
									text: qsTrId("page_settings_gsm_use_default_apn")
									checked: apnSetting.value === ""
									onCheckedChanged: {
										if (apnSetting.valid && checked) {
											apnSetting.setValue("")
										}
									}
								}

								ListTextField {
									//% "APN name"
									text: qsTrId("page_settings_gsm_apn_name")
									dataSource: root.settingsBindPrefix + "/APN"
									visible: !useDefaultApn.checked
									textField.maximumLength: 50
								}
							}
						}
					}
				}
			}

			ListSwitch {
				id: useAuth
				//% "Use authentication"
				text: qsTrId("page_settings_gsm_use_authentication")
				checked: authUser.value !== "" && authPass.value !== ""
				onCheckedChanged: {
					if (!checked) {
						authUser.setDataValue("")
						authPass.setDataValue("")
					}
				}
			}

			ListTextField {
				id: authUser

				//% "User name"
				text: qsTrId("page_settings_gsm_user_name")
				dataSource: settingsBindPrefix + "/User"
				visible: useAuth.checked
			}

			ListTextField {
				id: authPass

				text: CommonWords.password
				dataSource: settingsBindPrefix + "/Password"
				visible: useAuth.checked
			}

			ListTextItem {
				//% "IMEI"
				text: qsTrId("page_settings_gsm_imei")
				dataSource: bindPrefix + "/IMEI"
				visible: dataValid
			}
		}
	}
}

