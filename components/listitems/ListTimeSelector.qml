/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import Victron.Utils

ListButton {
	id: root

	readonly property alias dataItem: dataItem

	property int hour: Math.floor(value / 3600)
	property int minute: Math.floor(value % 3600 / 60)
	property int maximumHour: 23
	property int maximumMinute: 59

	// total value, in seconds (data value is assumed to be in seconds)
	property real value: !dataItem.isValid ? 0 : dataItem.value

	property var _timeSelector

	button.text: hour < 0 || minute < 0 ? "--" : ClockTime.formatTime(hour, minute)
	enabled: dataItem.uid === "" || dataItem.isValid

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
				if (dataItem.uid.length > 0) {
					const seconds = (minute * 60) + (hour * 60 * 60)
					dataItem.setValue(seconds)
				} else {
					root.hour = hour
					root.minute = minute
				}
			}
		}
	}

	VeQuickItem {
		id: dataItem
	}
}
