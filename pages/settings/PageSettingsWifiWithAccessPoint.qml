/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import net.connman

Page {
	id: root

	property CmTechnology _tech: Connman.getTechnology("wifi")
	property var _confirmApDialog

	GradientListView {
		id: settingsListView

		model: ObjectModel {
			ListSwitch {
				//% "Create access point"
				text: qsTrId("settings_wifi_create_ap")
				checked: accessPoint.value === 1
				updateOnClick: false

				onClicked: {
					if (checked) {
						if (!root._confirmApDialog) {
							root._confirmApDialog = confirmApDialogComponent.createObject(Global.dialogLayer)
						}
						root._confirmApDialog.open()
					} else {
						accessPoint.setValue(1)
					}
				}
			}

			ListNavigationItem {
				//% "Wi-Fi networks"
				text: qsTrId("settings_wifi_networks")
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsWifi.qml", { title: text })
			}
		}
	}

	Component {
		id: confirmApDialogComponent

		ModalWarningDialog {
			dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel
			//% "Disable Access Point"
			title: qsTrId("settings_wifi_disable_ap")
			//% "Are you sure that you want to disable the access point?"
			description: qsTrId("settings_wifi_disable_ap_are_you_sure")

			onAccepted: {
				accessPoint.setValue(1)
			}
		}
	}

	VeQuickItem {
		id: accessPoint
		uid: Global.venusPlatform.serviceUid + "/Services/AccessPoint/Enabled"
	}
}
