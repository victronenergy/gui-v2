/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

ListText {
	id: root

	readonly property alias dataItem: dataItem
	property alias secondaryText: secondaryLabel.text
	property alias secondaryLabel: secondaryLabel
    property int secondaryStatus: -1

	content.children: [
		SecondaryListLabel {
			id: secondaryLabel
			anchors.verticalCenter: parent.verticalCenter
			text: dataItem.valid ? dataItem.value : ""
			width: Math.min(implicitWidth, root.maximumContentWidth)
			visible: text.length > 0
		},
        CP.ColorImage {
            id: secondaryStatusIcon
            anchors.verticalCenter: parent.verticalCenter
            source: secondaryStatus === VenusOS.Alarm_Level_OK ? "qrc:/images/icon_checkmark_32.svg" :
                secondaryStatus === VenusOS.Alarm_Level_Warning ? "qrc:/images/icon_warning_32.svg" : "qrc:/images/icon_alarm_32.svg"
            color: secondaryStatus === VenusOS.Alarm_Level_OK ? Theme.color_green :
                secondaryStatus === VenusOS.Alarm_Level_Warning ? Theme.color_orange : Theme.color_red
            visible: secondaryStatus !== -1
        }
	]
    //secondaryLabel.rightPadding: Theme.geometry_icon_size_medium + Theme.geometry_listItem_content_spacing

	VeQuickItem {
		id: dataItem
	}
}
