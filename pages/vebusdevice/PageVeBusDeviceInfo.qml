/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

PageDeviceInfo {
	id: root

	settingsListView.footer: SettingsColumn {
		width: parent ? parent.width : 0
		topPadding: spacing
		preferredVisible: deviceInfoModel.count > 0

		Repeater {
			model: VeBusDeviceInfoModel { id: deviceInfoModel }

			ListText {
				text: displayText
				dataItem.uid: root.bindPrefix + pathSuffix
			}
		}

		ListNavigation {
			//% "Serial numbers"
			text: qsTrId("vebus_device_serial_numbers")
			onClicked: {
				Global.pageManager.pushPage("/pages/vebusdevice/PageVeBusSerialNumbers.qml", {
					//% "Serial numbers"
					"title": qsTrId("vebus_device_serial_numbers"),
					"bindPrefix": root.bindPrefix
				})
			}
		}
	}
}
