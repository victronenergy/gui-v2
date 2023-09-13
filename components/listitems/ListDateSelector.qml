/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Utils

ListButton {
	id: root

	property alias dataSource: dataPoint.source
	readonly property alias dataValue: dataPoint.value
	readonly property alias dataValid: dataPoint.valid
	function setDataValue(v) { dataPoint.setValue(v) }

	// data value is assumed to be in seconds
	property var date: dataValid ? new Date(dataValue * 1000) : null

	property var _dateSelector

	button.text: date == null ? "--" : Qt.formatDate(date, "yyyy-MM-dd")
	enabled: source === "" || dataValid

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
				if (dataSource.length > 0) {
					const seconds = date.getTime() / 1000
					dataPoint.setValue(seconds)
				} else {
					root.date = date
				}
			}
		}
	}

	DataPoint {
		id: dataPoint
	}
}
