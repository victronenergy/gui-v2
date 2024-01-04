/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import Victron.Utils

Page {
	id: root

	readonly property string bindPrefix: BackendConnection.serviceUidForType("modem")
	property string settingsBindPrefix: Global.systemSettings.serviceUid + "/Settings/Modem"

	VeQuickItem {
		id: simStatus
		uid: bindPrefix + "/SimStatus"
	}

	VeQuickItem {
		id: apnSetting
		uid: settingsBindPrefix + "/APN"
	}

	VeQuickItem {
		id: networkType
		uid: bindPrefix + "/NetworkType"
	}

	GradientListView {
		id: settingsListView

		model: simStatus.isValid ? modemConnected : notConnected

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
				secondaryText: dataItem.value === 1 ? CommonWords.online : CommonWords.offline
				dataItem.uid: bindPrefix + "/Connected"
			}

			ListTextItem {
				id: carrier

				//% "Carrier"
				text: qsTrId("page_settings_gsm_carrier")
				secondaryText: dataItem.isValid ? dataItem.value + " " + Utils.simplifiedNetworkType(networkType.value) : "--"
				dataItem.uid: bindPrefix + "/NetworkName"
			}

			ListItem {
				text: CommonWords.signal_strength

				content.children: [
					Item {
						anchors.verticalCenter: parent.verticalCenter
						width: Theme.geometry_settings_gsmModem_icon_container_width
						height: Theme.geometry_settings_gsmModem_icon_container_height

						GsmStatusIcon {
							id: gsmStatusIcon
							height: Theme.geometry_settings_gsmModem_icon_height
							anchors.centerIn: parent
						}
					}
				]
				visible: gsmStatusIcon.isValid
			}

			ListItem {
				//% "It may be necessary to configure the APN settings below in this page, contact your operator for details.\nIf that doesn't work, check sim-card in a phone to make sure that there is credit and/or it is registered to be used for data."
				text: qsTrId("page_settings_gsm_error_message")
				visible: status.dataItem.value === 0 && carrier.dataItem.isValid && simStatus.value === 1000
			}

			ListSwitch {
				//% "Allow roaming"
				text: qsTrId("page_settings_gsm_allow_roaming")
				dataItem.uid: settingsBindPrefix + "/RoamingPermitted"
				writeAccessLevel: VenusOS.User_AccessType_User
			}

			ListTextItem {
				//% "Sim status"
				text: qsTrId("page_settings_gsm_sim_status")
				secondaryText: {
					switch (dataItem.value) {
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
				dataItem.uid: bindPrefix + "/SimStatus"
			}

			ListTextField {
				//% "PIN"
				text: qsTrId("page_settings_gsm_pin")
				textField.maximumLength: 35
				dataItem.uid: settingsBindPrefix + "/PIN"
				writeAccessLevel: VenusOS.User_AccessType_User
				// Show only when PIN required
				visible: dataItem.isValid && [11, 16].indexOf(simStatus.value)  > -1
			}

			ListTextItem {
				text: CommonWords.ip_address
				dataItem.uid: bindPrefix + "/IP"
				visible: status.dataItem.value === 1
			}

			ListNavigationItem {
				//% "APN"
				text: qsTrId("page_settings_gsm_apn")
				//% "Default"
				secondaryText: (!apnSetting.isValid || apnSetting.value === "") ? qsTrId("page_settings_gsm_default") : apnSetting.value
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
										if (apnSetting.isValid && checked) {
											apnSetting.setValue("")
										}
									}
								}

								ListTextField {
									//% "APN name"
									text: qsTrId("page_settings_gsm_apn_name")
									dataItem.uid: root.settingsBindPrefix + "/APN"
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
						authUser.dataItem.setValue("")
						authPass.dataItem.setValue("")
					}
				}
			}

			ListTextField {
				id: authUser

				//% "User name"
				text: qsTrId("page_settings_gsm_user_name")
				dataItem.uid: settingsBindPrefix + "/User"
				visible: useAuth.checked
			}

			ListTextField {
				id: authPass

				text: CommonWords.password
				dataItem.uid: settingsBindPrefix + "/Password"
				visible: useAuth.checked
			}

			ListTextItem {
				//% "IMEI"
				text: qsTrId("page_settings_gsm_imei")
				dataItem.uid: bindPrefix + "/IMEI"
				visible: dataItem.isValid
			}
		}
	}
}

