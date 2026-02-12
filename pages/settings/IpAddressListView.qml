/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

GradientListView {
	id: root

	property alias ipAddresses: ipAddresses
	property int writeAccessLevel: VenusOS.User_AccessType_Installer

	signal ipAddressUpdated(index : int, ipAddress : string)

	model: ipAddresses.value ? ipAddresses.value.split(',') : []

	delegate: ListIpAddressField {
		id: ipAddressDelegate

		rightPadding: removalButton.width + spacing + horizontalContentPadding
		text: CommonWords.ip_address + ' ' + (model.index + 1)
		secondaryText: modelData
		saveInput: function() { root.ipAddressUpdated(model.index, secondaryText) }
		interactive: true
		writeAccessLevel: root.writeAccessLevel

		RemoveButton {
			id: removalButton

			anchors {
				right: parent.right
				rightMargin: ipAddressDelegate.horizontalContentPadding
				verticalCenter: parent.verticalCenter
			}
			visible: ipAddressDelegate.clickable
			onClicked: {
				Global.dialogLayer.open(removalDialogComponent, { description: modelData })
			}
		}
	}

	VeQuickItem {
		id: ipAddresses
	}

	Component {
		id: removalDialogComponent

		ModalWarningDialog {
			//% "Remove IP address?"
			title: qsTrId("settings_fronius_remove_ip_address")
			dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel
			icon.color: Theme.color_orange
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
