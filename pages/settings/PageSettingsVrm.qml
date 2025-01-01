/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	GradientListView {
		model: ObjectModel {
			ListNavigation {
				//% "VRM Portal mode"
				text: qsTrId("settings_vrm_portal_mode")
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsLogger.qml", {"title": text })
			}

			ListNavigation {
				//% "VRM device instances"
				text: qsTrId("settings_vrm_device_instances")
				onClicked: Global.pageManager.pushPage("/pages/settings/PageVrmDeviceInstances.qml", {"title": text })
			}
		}
	}
}
