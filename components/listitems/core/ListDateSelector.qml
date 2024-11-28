/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListButton {
	id: root

	readonly property alias dataItem: dataItem

	// data value is assumed to be in seconds
	property var date: dataItem.isValid ? new Date(dataItem.value * 1000) : null

	button.text: date == null ? "--" : Qt.formatDate(date, "yyyy-MM-dd")
	enabled: userHasWriteAccess && (dataItem.uid === "" || dataItem.isValid)

	onClicked: Global.dialogLayer.open(dateSelectorComponent, {
		year: date ? date.getFullYear() : ClockTime.year,
		month: date ? date.getMonth() : ClockTime.month,
		day: date ? date.getDate() : ClockTime.day
	})

	Component {
		id: dateSelectorComponent

		DateSelectorDialog {
			onAccepted: {
				const seconds = ClockTime.otherClockTime(year, month, day, date ? date.getHours() : 0, date ? date.getSeconds() : 0)
				if (dataItem.uid.length > 0) {
					dataItem.setValue(seconds)
				} else {
					root.date = new Date(seconds * 1000)
				}
			}
		}
	}

	VeQuickItem {
		id: dataItem
	}
}
