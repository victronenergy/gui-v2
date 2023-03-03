/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

ListButton {
	id: root

	property alias source: dataPoint.source
	readonly property alias dataPoint: dataPoint     // value is assumed to be in seconds

	property int hour: Math.floor(value / 3600)
	property int minute: Math.floor(value % 3600 / 60)
	property int maximumHour: 23
	property int maximumMinute: 59

	// total value, in seconds
	property real value: !dataPoint.valid ? 0 : dataPoint.value

	property var _timeSelector

	button.text: hour < 0 || minute < 0 ? "--" : ClockTime.formatTime(hour, minute)
	enabled: source === "" || dataPoint.valid

	onClicked: {
		if (!_timeSelector) {
			_timeSelector = timeSelectorComponent.createObject(Global.dialogLayer)
		}
		_timeSelector.hour = hour
		_timeSelector.minute = minute
		_timeSelector.open()
	}

	Component {
		id: timeSelectorComponent

		TimeSelectorDialog {
			maximumHour: root.maximumHour
			maximumMinute: root.maximumMinute

			onAccepted: {
				if (source.length > 0) {
					const seconds = (minute * 60) + (hour * 60 * 60)
					dataPoint.setValue(seconds)
				} else {
					root.hour = hour
					root.minute = minute
				}
			}
		}
	}

	DataPoint {
		id: dataPoint
	}
}
