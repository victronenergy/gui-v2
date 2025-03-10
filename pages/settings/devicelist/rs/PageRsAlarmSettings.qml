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
						preferredVisible = false
						return
					}
				}
				preferredVisible = true
			}

			//% "No alarms to be configured"
			text: qsTrId("rs_alarm_no_alarms_to_be_configured")
			preferredVisible: false
		}

		delegate: ListAlarmLevelRadioButtonGroup {
			text: modelData.text
			dataItem.uid: root.bindPrefix + modelData.pathSuffix
			preferredVisible: dataItem.valid
			onVisibleChanged: settingsListView.headerItem.updateVisibility()
		}
	}
}
