/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

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

	VeQuickItem {
		id: iMEIItem
		uid: bindPrefix + "/IMEI"
	}
	VeQuickItem {
		id: pINItem
		uid: settingsBindPrefix + "/PIN"
	}
	VeQuickItem {
		id: pPPStatusItem
		uid: bindPrefix + "/PPPStatus"
	}
	VeQuickItem {
		id: regStatusItem
		uid: bindPrefix + "/RegStatus"
	}

	GradientListView {
		id: settingsListView

		model: simStatus.valid ? modemConnected : notConnected

		DelegateComponentModel {
			DelegateComponent {
				id: notConnected

				PrimaryListLabel {
					//% "Connect a Victron Energy GX GSM or GX LTE 4G modem to enable mobile network connectivity."
					text: qsTrId("page_settings_connect_cellular_modem")
				}
			}
		}

		DelegateComponentModel {
			id: modemConnected

			DelegateComponent {
				id: statusDC
				dataItem: VeQuickItem { uid: bindPrefix + "/Connected" }

				ListText {
					id: status

					//% "Internet"
					text: qsTrId("page_settings_gsm_internet")
					secondaryText: dataItem.value ? CommonWords.online : CommonWords.offline
					dataItem.uid: bindPrefix + "/Connected"
				}
			}

			DelegateComponent {
				id: carrierDC
				dataItem: VeQuickItem { uid: bindPrefix + "/NetworkName" }
				ListText {
					id: carrier

					//% "Carrier"
					text: qsTrId("page_settings_gsm_carrier")
					secondaryText: dataItem.valid ? dataItem.value + " " + Utils.simplifiedNetworkType(networkType.value) : "--"
					dataItem.uid: bindPrefix + "/NetworkName"
				}
			}

			DelegateComponent {
				preferredVisible: simStatus.valid
				ListItem {
					id: signalStrength

					contentItem: RowLayout {
						spacing: signalStrength.spacing

						Label {
							text: CommonWords.signal_strength
							font: signalStrength.font
							Layout.fillWidth: true
						}
						Item {
							Layout.preferredWidth: Theme.geometry_settings_gsmModem_icon_container_width
							Layout.preferredHeight: Theme.geometry_settings_gsmModem_icon_container_height

							GsmStatusIcon {
								id: gsmStatusIcon
								height: Theme.geometry_settings_gsmModem_icon_height
								anchors.centerIn: parent
							}
						}
					}
				}
			}

			DelegateComponent {
				preferredVisible: statusDC.dataItem.value === 0 && carrierDC.dataItem.valid && simStatus.value === 1000
				PrimaryListLabel {
					//% "It may be necessary to configure the APN settings below in this page, contact your operator for details.\nIf that doesn't work, check sim-card in a phone to make sure that there is credit and/or it is registered to be used for data."
					text: qsTrId("page_settings_gsm_error_message")
				}
			}

			DelegateComponent {
				ListSwitch {
					//% "Allow roaming"
					text: qsTrId("page_settings_gsm_allow_roaming")
					dataItem.uid: settingsBindPrefix + "/RoamingPermitted"
					writeAccessLevel: VenusOS.User_AccessType_User
				}
			}

			DelegateComponent {
				ListText {
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
							//% "OK"
							return qsTrId("page_settings_gsm_ok")
						default:
							//% "Unknown error"
							return qsTrId("page_settings_gsm_unknown_error")
						}
					}
					dataItem.uid: bindPrefix + "/SimStatus"
				}
			}

			DelegateComponent {
				preferredVisible: regStatusItem.valid
				ListText {
					//% "Registration status"
					text: qsTrId("page_settings_gsm_registration_status")
					secondaryText: {
						switch (dataItem.value) {
						case 0:
							//% "Not registered, not searching for operator"
							return qsTrId("page_settings_gsm_not_registered_not_searching")
						case 1:
							//% "Registered, home network"
							return qsTrId("page_settings_gsm_registered_home_network")
						case 2:
							//% "Not registered, searching for operator"
							return qsTrId("page_settings_gsm_not_registered_searching")
						case 3:
							//% "Registration denied"
							return qsTrId("page_settings_gsm_registration_denied")
						case 4:
							//% "Unknown"
							return qsTrId("page_settings_gsm_unknown_state")
						case 5:
							//% "Registered, roaming"
							return qsTrId("page_settings_gsm_registered_roaming")
						default:
							//% "Unknown"
							return qsTrId("page_settings_gsm_unknown_value")
						}
					}
					dataItem.uid: bindPrefix + "/RegStatus"
				}
			}

			DelegateComponent {
				preferredVisible: pPPStatusItem.valid
				ListText {
					//% "Data link (PPP) status"
					text: qsTrId("page_settings_gsm_data_link_status")
					secondaryText: {
						switch (dataItem.value) {
						case 0:
							//% "Offline"
							return qsTrId("page_settings_gsm_offline")
						case 1:
							//% "Connecting"
							return qsTrId("page_settings_gsm_connecting")
						case 2:
							//% "Connected"
							return qsTrId("page_settings_gsm_connected")
						default:
							//% "Unknown"
							return qsTrId("page_settings_gsm_unknown_value")
						}
					}
					dataItem.uid: bindPrefix + "/PPPStatus"
				}
			}

			DelegateComponent {
				preferredVisible: pINItem.valid && [11, 16].indexOf(simStatus.value)  > -1
				ListTextField {
					//% "PIN"
					text: qsTrId("page_settings_gsm_pin")
					maximumLength: 35
					dataItem.uid: settingsBindPrefix + "/PIN"
					writeAccessLevel: VenusOS.User_AccessType_User
					// Show only when PIN required
				}
			}

			DelegateComponent {
				preferredVisible: statusDC.dataItem.value === 1
				ListText {
					text: CommonWords.ip_address
					dataItem.uid: bindPrefix + "/IP"
				}
			}

			DelegateComponent {
				ListNavigation {
					//% "APN"
					text: qsTrId("page_settings_gsm_apn")
					//% "Default"
					secondaryText: (!apnSetting.valid || apnSetting.value === "") ? qsTrId("page_settings_gsm_default") : apnSetting.value
					onClicked: Global.pageManager.pushPage(apnPage, { title: text })
					Component {
						id: apnPage

						Page {

							GradientListView {

								model: DelegateComponentModel {

									DelegateComponent {
										id: useDefaultApnDC
										property bool checked: apnSetting.value === ""
										ListSwitch {
											id: useDefaultApn
											//% "Use default APN"
											text: qsTrId("page_settings_gsm_use_default_apn")
											checked: apnSetting.value === ""
											checkable: true
											onCheckedChanged: {
												if (apnSetting.valid && checked) {
													apnSetting.setValue("")
												}
											}
										}
									}

									DelegateComponent {
										preferredVisible: !useDefaultApnDC.checked
										ListTextField {
											//% "APN name"
											text: qsTrId("page_settings_gsm_apn_name")
											dataItem.uid: root.settingsBindPrefix + "/APN"
											maximumLength: 50
										}
									}
								}
							}
						}
					}
				}
			}

			DelegateComponent {
				id: useAuthDC
				dataItem: VeQuickItem { uid: settingsBindPrefix + "/User" }
				property VeQuickItem authPassItem: VeQuickItem { uid: settingsBindPrefix + "/Password" }
				property bool checked: dataItem.value !== "" || authPassItem.value !== ""
				ListSwitch {
					id: useAuth
					//% "Use authentication"
					text: qsTrId("page_settings_gsm_use_authentication")
					checked: useAuthDC.checked
					checkable: true
					onCheckedChanged: {
						if (!checked) {
							useAuthDC.dataItem.setValue("")
							useAuthDC.authPassItem.setValue("")
						}
					}
				}
			}

			DelegateComponent {
				preferredVisible: useAuthDC.checked
				ListTextField {
					id: authUser

					//% "User name"
					text: qsTrId("page_settings_gsm_user_name")
					dataItem.uid: settingsBindPrefix + "/User"
				}
			}

			DelegateComponent {
				preferredVisible: useAuthDC.checked
				ListTextField {
					id: authPass

					text: CommonWords.password
					dataItem.uid: settingsBindPrefix + "/Password"
				}
			}

			DelegateComponent {
				preferredVisible: iMEIItem.valid
				ListText {
					//% "IMEI"
					text: qsTrId("page_settings_gsm_imei")
					dataItem.uid: bindPrefix + "/IMEI"
				}
			}
		}
	}
}
