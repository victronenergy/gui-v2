/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

Page {
	id: root

	property string bindPrefix
	property alias alarmModel: alarmListView.model

	GradientListView {
		id: alarmListView

		delegate: ListNavigationItem {
			readonly property string modulePath: model.uid.slice(0, -3)

			text: moduleRoot.value || ""
			onClicked: {
				Global.pageManager.pushPage("/pages/settings/devicelist/battery/PageBatteryAlarms.qml",
						{ "title": text, "bindPrefix": modulePath })
			}

			VeQuickItem {
				id: moduleRoot
				uid: model.uid
			}
		}
	}
}
