/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

ModalDialog {
	id: root

	property var date: ClockTime.currentDateTime

	property int _year
	property int _month
	property int _day
	property bool _updating

	function _updateDate(year, month, day) {
		_updating = true
		_year = year
		_month = month
		_day = day
		date = new Date(year, month, day)
		_updating = false
	}

	onDateChanged: {
		if (_updating) {
			return
		}
		_year = date.getFullYear()
		_month = date.getMonth()
		_day = date.getDate()
		canAccept = ClockTime.isDateValid(_year, _month + 1, _day)  // js Date month is 0-11, but QDate month is 1-12
	}

	//% "Set date"
	title: qsTrId("dateselectordialog_set_date")

	horizontalPadding: Theme.geometry.modalDialog.content.horizontalMargin

	contentItem: Row {
		anchors {
			top: parent.header.bottom
			bottom: parent.footer.top
			horizontalCenter: parent.horizontalCenter
		}

		Repeater {
			model: [
				{ from: 1970, to: 2100, value: root._year },
				{ from: 0, to: 11, value: root._month },
				{ from: 1, to: 31, value: root._day }
			]

			delegate: SpinBox {
				anchors.verticalCenter: parent.verticalCenter
				width: (root.width - (Theme.geometry.modalDialog.content.horizontalMargin * 2)) / 3
				orientation: Qt.Vertical
				label.font.pixelSize: Theme.font.size.h2
				from: modelData.from
				to: modelData.to
				value: modelData.value

				textFromValue: function(value, locale) {
					if (model.index === 0) {
						// year
						return value
					} else if (model.index === 1) {
						// month
						return Qt.locale().monthName(value, Locale.ShortFormat)
					} else {
						// date
						return value
					}
				}

				onValueChanged: {
					if (model.index === 0) {
						// year
						root._updateDate(value, root._month, root._day)
					} else if (model.index === 1) {
						// month
						root._updateDate(root._year, value, root._day)
					} else {
						// date
						root._updateDate(root._year, root._month, value)
					}
				}
			}
		}
	}
}
