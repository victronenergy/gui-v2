/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

GradientListView {
	id: root

	property string addressesUid
	property int writeAccessLevel: VenusOS.User_AccessType_Installer

	function clearAddresses() {
		ipAddresses.setValue("")
	}

	function _addOrUpdateAddress(ipAddress, index = -1) {
		let addresses = ipAddresses.value ? ipAddresses.value.split(',') : []
		if (index >= addresses.length) {
			console.warn("invalid index", index, "IPAddresses length is:", addresses.length)
			return
		}
		if (index < 0) {
			addresses.push(ipAddress)
		} else {
			addresses[index] = ipAddress
		}
		ipAddresses.setValue(addresses.join(','))
	}

	model: ipAddresses.value ? ipAddresses.value.split(',') : []

	header: ListNavigation {
		bottomInset: Theme.geometry_listItem_itemSeparator_height
		bottomPadding: bottomInset + topPadding

		//% "Add IP address"
		text: qsTrId("settings_add_ip_addresses")
		iconSource: "qrc:/images/icon_plus_32.svg"
		iconColor: Theme.color_ok
		showAccessLevel: root.writeAccessLevel
		onClicked: {
			root._addOrUpdateAddress("192.168.1.1")
		}
	}

	delegate: ListIpAddressField {
		id: ipAddressDelegate

		rightPadding: removalButton.width + spacing + horizontalContentPadding
		text: CommonWords.ip_address + ' ' + (model.index + 1)
		secondaryText: modelData
		saveInput: function() { root._addOrUpdateAddress(secondaryText, model.index) }
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
		uid: root.addressesUid
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
