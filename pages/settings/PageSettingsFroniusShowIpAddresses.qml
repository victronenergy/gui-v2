/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls as C
import Victron.VenusOS
import Victron.Utils

Page {
	id: root

	property var _rescanDialog

	topRightButton: VenusOS.StatusBar_RightButton_Refresh

	IpAddressListView {
		id: settingsListView

		ipAddresses.source: Global.systemSettings.serviceUid + "/Settings/Fronius/KnownIPAddresses"
	}

	Connections {
		target: !!Global.pageManager ? Global.pageManager.statusBar : null
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
			icon.color: Theme.color_ok
			icon.source: "/images/toast_icon_info.svg"

			onAccepted: {
				settingsListView.ipAddresses.setValue('')
				scanItem.setValue(1)
			}
		}
	}

	DataPoint {
		id: scanItem

		source: BackendConnection.serviceUidForType("fronius") + "/AutoDetect"
	}
}
