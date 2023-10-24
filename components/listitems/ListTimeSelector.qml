/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

ListButton {
	id: root

	property alias dataSource: dataPoint.source
	readonly property alias dataValue: dataPoint.value
	readonly property alias dataValid: dataPoint.valid
	readonly property alias dataSeen: dataPoint.seen
	property alias dataInvalidate: dataPoint.invalidate
	function setDataValue(v) { dataPoint.setValue(v) }

	property int hour: Math.floor(value / 3600)
	property int minute: Math.floor(value % 3600 / 60)
	property int maximumHour: 23
	property int maximumMinute: 59

	// total value, in seconds (data value is assumed to be in seconds)
	property real value: !dataValid ? 0 : dataValue

	property var _timeSelector

	button.text: hour < 0 || minute < 0 ? "--" : ClockTime.formatTime(hour, minute)
	enabled: dataSource === "" || dataValid

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
				if (dataSource.length > 0) {
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
