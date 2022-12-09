/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

Page {
	id: root

	property string settingsBindPrefix
	property string startStopBindPrefix

	SettingsListView {
		id: settingsListView

		model: ObjectModel {

			SettingsListNavigationItem {
				//% "Conditions"
				text: qsTrId("page_settings_generator_conditions")
				onClicked: Global.pageManager.pushPage("/pages/settings/PageGeneratorConditions.qml", { title: text, bindPrefix: root.settingsBindPrefix })
			}
			// TODO: "Minimum run time"
			// TODO: "Detect generator at AC input"
			// TODO: "Quiet hours"
			// TODO: "Quiet hours start time"
			// TODO: "Quiet hours end time"
			// TODO: "Reset daily run time counters"
			// TODO: "Generator total run time (hours)"
		}
	}
}

