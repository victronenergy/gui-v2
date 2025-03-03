/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

PageDeviceInfo {
	id: root

	Component.onCompleted: {
		settingsListView.model.append(veBusDeviceInfoComponent.createObject(root))
	}

	Component {
		id: veBusDeviceInfoComponent
		SettingsColumn {
			width: parent ? parent.width : 0
			preferredVisible: deviceInfoModel.count > 0

			Repeater {
				model: VeBusDeviceInfoModel { id: deviceInfoModel }

				ListText {
					text: displayText
					dataItem.uid: root.bindPrefix + pathSuffix
				}
			}

			// TODO: this crashes when running with '--mock'
			ListNavigation {
				//% "Serial numbers"
				text: qsTrId("vebus_device_serial_numbers")
				onClicked: {
					Global.pageManager.pushPage("/pages/vebusdevice/PageVeBusSerialNumbers.qml", {
													//% "Serial numbers"
													"title": qsTrId("vebus_device_serial_numbers"),
													"bindPrefix": root.bindPrefix
												}
												)
				}
			}
		}
	}

}
