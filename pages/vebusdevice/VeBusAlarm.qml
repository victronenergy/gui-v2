/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListItem {
	id: root

	property string bindPrefix
	property alias textModel: repeater.model
	property int numOfPhases: 1
	property bool _multiPhase: numOfPhases > 1
	property bool errorItem: false
	property string alarmSuffix

	VeBusDeviceAlarmGroup {
		id: alarmGroup

		bindPrefix: root.bindPrefix
		alarmSuffix: root.alarmSuffix
		errorItem: root.errorItem
		numOfPhases: root.numOfPhases
	}

	content.children: [
		Repeater {
			id: repeater

			model: alarmGroup.alarms

			delegate: Label {
				id: label
				visible: index === 0
						 ? modelData.isValid && !alarmGroup.phase1Alarm.isValid
						 : modelData.isValid && numOfPhases >= index
				anchors.verticalCenter: parent.verticalCenter
				width: Math.max(
						   (separator.visible
							? implicitWidth + root.content.spacing
							: implicitWidth),
						   Theme.geometry_veBusAlarm_minimumDelegateWidth)
				font.pixelSize: Theme.font_size_body2
				color: Theme.color_listItem_secondaryText
				text: modelData === undefined ? "--" : modelData.displayText
				horizontalAlignment: numOfPhases === 1 ? Text.AlignRight : Text.AlignHCenter
				elide: Text.ElideRight

				Rectangle {
					id: separator

					anchors {
						right: parent.right
						rightMargin: -root.content.spacing / 2
					}
					width: Theme.geometry_listItem_separator_width
					height: parent.implicitHeight
					color: Theme.color_listItem_separator
					visible: model.index !== repeater.count - 1 && repeater.itemAt(index + 1).visible
				}
			}
		}
	]
}
