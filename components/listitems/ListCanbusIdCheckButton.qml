/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

ListButton {
	id: root

	property string caption
	property bool testDone

	function startCheck(timeout) {
		timer.remainingTime = timeout
		timer.running = true
		testDone = false
	}

	function stopTimer() {
		timer.running = false
	}

	//% "Check unique id numbers"
	text: qsTrId("settings_canbus_unique_id_choose")
	secondaryText: timer.running ? Utils.secondsToString(timer.remainingTime) : CommonWords.check_now

	contentItem: Item {
		implicitWidth: Theme.geometry_listItem_width
		implicitHeight: contentLayout.isMultiLine || root.caption.length > 0 ? contentLayout.implicitHeight : 0

		ListItemLoaderLayout {
			id: contentLayout

			anchors.verticalCenter: parent.verticalCenter
			width: parent.width
			text: root.text
			label.font: root.font
			loader.sourceComponent: ListItemButton {
				enabled: root.clickable && !root.readOnly
				text: root.secondaryText
				focusPolicy: Qt.NoFocus
				onClicked: root.click()
			}

			CaptionLabel {
				text: root.caption
				visible: text.length > 0
				Layout.fillWidth: true
				Layout.columnSpan: parent.columns
			}
		}
	}

	Timer {
		id: timer

		property int remainingTime

		interval: 1000
		repeat: true
		onTriggered: {
			if (--remainingTime === 0) {
				running = false
				root.testDone = true
			}
		}
	}
}
