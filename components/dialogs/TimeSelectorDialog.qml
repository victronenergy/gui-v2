/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

ModalDialog {
	id: root

	property alias hour: timeSelector.hour
	property alias minute: timeSelector.minute

	property alias maximumHour: timeSelector.maximumHour
	property alias maximumMinute: timeSelector.maximumMinute

	//% "Set time"
	title: qsTrId("timeselectordialog_set_time")

	contentItem: Item {
		TimeSelector {
			id: timeSelector

			anchors {
				centerIn: parent
				verticalCenterOffset: -Theme.geometry.modalDialog.content.margins
			}
		}
	}
}
