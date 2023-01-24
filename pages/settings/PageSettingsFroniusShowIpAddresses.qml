/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls as C
import Victron.VenusOS
import "/components/Utils.js" as Utils

Page {
	id: root

	property string settingsPrefix: "com.victronenergy.settings"

	property DataPoint scanItem: DataPoint { source: "com.victronenergy.fronius/AutoDetect" }

	property IpAddressButtonGroup knownIpAddresses: IpAddressButtonGroup {
		source: settingsPrefix + "/Settings/Fronius/KnownIPAddresses"
	}

	function rescan()
	{
		knownIpAddresses.setValue('')
		scanItem.setValue(1)
	}

	SettingsListView {
		id: view

		model: knownIpAddresses.valuesAsArray
		delegate: SettingsListTextItem {
			text: CommonWords.ip_address.arg(index + 1)
			secondaryText: modelData
			content.children: [
				defaultContent,
				radioButton
			]

			RadioButton {
				id: radioButton

				C.ButtonGroup.group: knownIpAddresses.group
			}
		}
	}

	Row {
		anchors {
			bottom: parent.bottom
			horizontalCenter: parent.horizontalCenter
		}
		spacing: parent.width / 4

		ListItemButton {
			//% "Rescan"
			text: qsTrId("page_settings_fronius_show_ip_addresses_rescan")
			onClicked: rescan()
		}

		ListItemButton {
			text: CommonWords.remove
			onClicked: knownIpAddresses.deleteCheckedButtons()
		}
	}
}
