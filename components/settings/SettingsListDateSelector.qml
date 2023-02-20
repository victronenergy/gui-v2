/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

SettingsListButton {
	id: root

	property alias source: dataPoint.source
	readonly property alias dataPoint: dataPoint     // value is assumed to be in seconds

	property var date: dataPoint.valid ? new Date(dataPoint.value * 1000) : null

	property var _dateSelector

	button.text: date == null ? "--" : Qt.formatDate(date, "yyyy-MM-dd")
	enabled: source === "" || dataPoint.valid

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
				if (source.length > 0) {
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
