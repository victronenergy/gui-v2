/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix
	property alias rsModel: settingsListView.model

	GradientListView {
		id: settingsListView

		header: ListLabel {
			function updateVisibility() {
				for (let i = 0; i < settingsListView.count; ++i) {
					const listItem = settingsListView.itemAtIndex(i)
					if (listItem && listItem.visible) {
						visible = false
						return
					}
				}
				visible = true
			}

			//% "No alarms to be configured"
			text: qsTrId("rs_alarm_no_alarms_to_be_configured")
			visible: false
		}

		delegate: AlarmLevelRadioButtonGroup {
			text: modelData.text
			dataItem.uid: root.bindPrefix + modelData.pathSuffix
			allowed: defaultAllowed && dataItem.isValid
			onVisibleChanged: settingsListView.headerItem.updateVisibility()
		}
	}
}
