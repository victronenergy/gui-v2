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

	// data value is assumed to be in seconds
	property var date: dataItem.isValid ? new Date(dataItem.value * 1000) : null

	property var _dateSelector

	button.text: date == null ? "--" : Qt.formatDate(date, "yyyy-MM-dd")
	enabled: dataItem.uid === "" || dataItem.isValid

	onClicked: {
		if (!_dateSelector) {
			_dateSelector = dateSelectorComponent.createObject(Global.dialogLayer)
		}
		_dateSelector.date = date
		_dateSelector.open()
	}

	Component {
		id: dateSelectorComponent

		DateSelectorDialog {
			onAccepted: {
				if (dataItem.uid.length > 0) {
					const seconds = date.getTime() / 1000
					dataItem.setValue(seconds)
				} else {
					root.date = date
				}
			}
		}
	}

	VeQuickItem {
		id: dataItem
	}
}
