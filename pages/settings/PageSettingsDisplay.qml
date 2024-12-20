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
				//% "Units"
				text: qsTrId("settings_units")
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageSettingsDisplayUnits.qml", {"title": text})
				}
			}
		}
	}
}
