/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

ModalDialog {
	id: root

	property int duration: Utils.composeDuration(timeSelector.hour, timeSelector.minute)

	//% "Duration"
	title: qsTrId("controlcard_generator_durationselectordialog_title")

	contentItem: TimeSelector {
		id: timeSelector

		anchors {
			top: parent.top
			topMargin: Theme.geometry.generatorDurationSelectorDialog.content.topMargin
			bottom: parent.footer.top
		}
		maximumHour: 59
	}
}
