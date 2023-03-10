/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls as C
import Victron.VenusOS
import "/components/Utils.js" as Utils

ListPage {
	id: root

	property var _rescanDialog

	topRightButton: VenusOS.StatusBar_RightButton_Refresh

	listView: IpAddressListView {
		id: settingsListView
		ipAddresses.source: "com.victronenergy.settings/Settings/Fronius/KnownIPAddresses"
	}

	Connections {
		target: Global.pageManager.statusBar
		enabled: root.isCurrentPage

		function onRightButtonClicked() {
			if (!root._rescanDialog) {
				root._rescanDialog = rescanDialogComponent.createObject(root)
			}
			root._rescanDialog.open()
		}
	}

	Component {
		id: rescanDialogComponent

		ModalWarningDialog {
			//% "Rescan for IP addresses?"
			title: qsTrId("settings_fronius_rescan_title")
			//% "Rescan"
			acceptText: qsTrId("settings_fronius_rescan")
			dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel
			icon.color: Theme.color.ok
			icon.source: "/images/toast_icon_info.svg"

			onAccepted: {
				settingsListView.ipAddresses.setValue('')
				scanItem.setValue(1)
			}
		}
	}

	DataPoint {
		id: scanItem

		source: "com.victronenergy.fronius/AutoDetect"
	}
}
