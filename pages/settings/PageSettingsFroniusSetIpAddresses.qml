/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls as C
import Victron.VenusOS
import "/components/Utils.js" as Utils

Page {
	id: root

	property IpAddressButtonGroup ipAddresses: IpAddressButtonGroup {
		source: "com.victronenergy.settings/Settings/Fronius/IPAddresses"
	}

	SettingsListView {
		id: view

		model: ObjectModel {
			Column {
				width: view.width

				Repeater {
					model: ipAddresses.valuesAsArray
					delegate: SettingsListIpAddressField {
						onAccepted: function(text) {
							var addrs = ipAddresses.valuesAsArray
							addrs[index] = text
							ipAddresses.setValue(addrs.join(','))
						}

						content.children: [
							defaultContent,
							checkBox
						]

						text: CommonWords.ip_address.arg(index + 1)
						secondaryText: modelData

						CheckBox {
							id: checkBox

							C.ButtonGroup.group: ipAddresses.group
						}
					}
				}

				SettingsListNavigationItem {
					anchors.horizontalCenter: parent.horizontalCenter
					text: "Add new address"
					onClicked: ipAddresses.push("192.168.1.1")
				}
			}
		}
	}

	ListItemButton {
		anchors {
			horizontalCenter: parent.horizontalCenter
			bottom: parent.bottom
		}
		text: CommonWords.remove
		onClicked: ipAddresses.deleteCheckedButtons()
	}
}


