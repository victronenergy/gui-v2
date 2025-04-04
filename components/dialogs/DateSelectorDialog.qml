/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ModalDialog {
	id: root

	property alias year: dateSelector.year
	property alias month: dateSelector.month
	property alias day: dateSelector.day

	//% "Set date"
	title: qsTrId("dateselectordialog_set_date")

	contentItem: ModalDialog.FocusableContentItem {
		DateSelector {
			id: dateSelector

			availableWidth: parent.width - 2*Theme.geometry_modalDialog_content_horizontalMargin
			anchors {
				centerIn: parent
				verticalCenterOffset: -Theme.geometry_modalDialog_content_margins
			}
			focus: true
			KeyNavigation.up: dateSelector
			KeyNavigation.down: root.footer
		}
	}
}
