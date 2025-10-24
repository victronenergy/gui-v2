/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	topRightButton: Global.systemSettings.canAccess(VenusOS.User_AccessType_Installer)
			? VenusOS.StatusBar_RightButton_Refresh
			: VenusOS.StatusBar_RightButton_None

	IpAddressListView {
		id: settingsListView

		ipAddresses.uid: Global.systemSettings.serviceUid + "/Settings/Fronius/KnownIPAddresses"
	}

	Connections {
		target: Global.mainView?.statusBar ?? null
		enabled: root.isCurrentPage

		function onRightButtonClicked() {
			Global.dialogLayer.open(rescanDialogComponent)
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
			icon.source: "qrc:/images/icon_info_32.svg"

			onAccepted: {
				settingsListView.ipAddresses.setValue('')
				scanItem.setValue(1)
			}
		}
	}

	VeQuickItem {
		id: scanItem

		uid: BackendConnection.serviceUidForType("fronius") + "/AutoDetect"
	}
}
