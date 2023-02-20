/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

ModalDialog {
	id: root

	property int duration

	property bool _updating

	function _update(hour, minute) {
		_updating = true
		duration = Utils.composeDuration(hour, minute)
		_updating = false
	}

	onDurationChanged: {
		if (_updating) {
			return
		}
		const parts = Utils.decomposeDuration(duration)
		timeSelector.hour = parts.h
		timeSelector.minute = parts.m
	}

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

		onHourChanged: root._update(hour, minute)
		onMinuteChanged: root._update(hour, minute)
	}
}
