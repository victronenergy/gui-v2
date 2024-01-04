/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP
import Victron.Utils

PageDeviceInfo {
	id: root

	Component.onCompleted: {
		settingsListView.model.append(veBusDeviceInfoComponent.createObject(root))
	}

	Component {
		id: veBusDeviceInfoComponent
		Column {
			width: parent ? parent.width : 0

			Repeater {
				model: VeBusDeviceInfoModel { }

				ListTextItem {
					text: displayText
					dataItem.uid: root.bindPrefix + pathSuffix
				}
			}

			// TODO: this crashes when running with '--mock'
			ListNavigationItem {
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
