/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

/*
	A list setting item with additional secondary text and alarm-type icon.
*/
ListSetting {
	id: root

	readonly property alias dataItem: dataItem
	property string secondaryText: dataItem.valid ? dataItem.value : ""
	property string caption
	property int alarmStatus: -1

	contentItem: RowLayout {
		spacing: root.spacing

		ListItemLabelLayout {
			primaryText: root.text
			primaryLabel.font: root.font
			primaryLabel.textFormat: root.textFormat
			secondaryText: root.secondaryText
		}

		AlarmIcon {
			alarmStatus: root.alarmStatus
		}
	}

	VeQuickItem {
		id: dataItem
	}
}
