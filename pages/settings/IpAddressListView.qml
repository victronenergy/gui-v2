/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls as C
import QtQuick.Controls.impl as CP
import Victron.VenusOS
import "/components/Utils.js" as Utils

SettingsListView {
	id: root

	property alias ipAddresses: ipAddresses

	property var _removalDialog

	model: ipAddresses.value ? ipAddresses.value.split(',') : []

	delegate: SettingsListIpAddressField {
		id: ipAddressDelegate

		property CP.ColorImage removalButton: CP.ColorImage {
			anchors.verticalCenter: parent.verticalCenter
			source: "/images/icon_minus.svg"
			color: Theme.color.ok

			MouseArea {
				anchors.fill: parent
				onClicked: {
					if (!root._removalDialog) {
						root._removalDialog = removalDialogComponent.createObject(root)
					}
					root._removalDialog.description = modelData
					root._removalDialog.open()
				}
			}
		}

		text: CommonWords.ip_address + ' ' + (model.index + 1)
		secondaryText: modelData

		content.children: [
			defaultContent,
			removalButton
		]
	}

	DataPoint {
		id: ipAddresses
	}

	Component {
		id: removalDialogComponent

		ModalWarningDialog {
			//% "Remove IP address?"
			title: qsTrId("settings_fronius_remove_ip_address")
			dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel
			icon.color: Theme.color.orange
			acceptText: CommonWords.remove

			onAccepted: {
				const addresses = ipAddresses.value ? ipAddresses.value.split(',') : []
				for (let i = 0; i < addresses.length; ++i) {
					if (addresses[i] === description) {
						addresses.splice(i, 1)
						ipAddresses.setValue(addresses.join(','))
						break
					}
				}
			}
		}
	}
}
