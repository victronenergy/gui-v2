/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListButton {
	id: root

	readonly property alias dataItem: dataItem

	property bool showMinuteSecondOnly: false

	property int hour: showMinuteSecondOnly ? 0 : Math.floor(value / 3600)
	property int minute: showMinuteSecondOnly ? Math.floor(value / 60) : Math.floor(value % 3600 / 60)
	property int second: value % 60
	property int maximumHour: 23
	property int maximumMinute: showMinuteSecondOnly ? 999 : 59
	property int maximumSecond: 59

	// total value, in seconds (data value is assumed to be in seconds)
	property real value: !dataItem.valid ? 0 : dataItem.value

	secondaryText: hour < 0 || minute < 0 ? "--"
				 : root.showMinuteSecondOnly ? Utils.pad(minute, 2) + ":" + Utils.pad(second, 2)
				 : ClockTime.formatTime(hour, minute)
	interactive: (dataItem.uid === "" || dataItem.valid)

	onClicked: Global.dialogLayer.open(timeSelectorComponent, {hour: hour, minute: minute, second: second})

	Component {
		id: timeSelectorComponent

		TimeSelectorDialog {
			showMinuteSecondOnly: root.showMinuteSecondOnly
			maximumHour: root.maximumHour
			maximumMinute: root.maximumMinute
			maximumSecond: root.maximumSecond

			onAccepted: {
				if (dataItem.uid.length > 0) {
					const total = second + (minute * 60) + (hour * 60 * 60)
					dataItem.setValue(total)
				} else {
					root.hour = hour
					root.minute = minute
					root.second = second
				}
			}
		}
	}

	VeQuickItem {
		id: dataItem
	}
}
