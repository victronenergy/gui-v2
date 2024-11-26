/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

	GradientListView {
		id: settingsListView

		model: Global.inverterChargers.rsAlarms

		header: PrimaryListLabel {
			function updateVisibility() {
				for (let i = 0; i < settingsListView.count; ++i) {
					const listItem = settingsListView.itemAtIndex(i)
					if (listItem && listItem.visible) {
						allowed = false
						return
					}
				}
				allowed = true
			}

			//% "No alarms to be configured"
			text: qsTrId("rs_alarm_no_alarms_to_be_configured")
			allowed: false
		}

		delegate: AlarmLevelRadioButtonGroup {
			text: modelData.text
			dataItem.uid: root.bindPrefix + modelData.pathSuffix
			allowed: defaultAllowed && dataItem.isValid
			onVisibleChanged: settingsListView.headerItem.updateVisibility()
		}
	}
}
