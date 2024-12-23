/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	GradientListView {
		id: settingsListView

		model: ObjectModel {
			ListNavigation {
				text: CommonWords.add_device
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsModbusAddDevice.qml", {"title": text})
			}
		}
	}
}
