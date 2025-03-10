/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListItem {
	id: root

	property string bindPrefix
	property int numOfPhases: 1
	property bool multiPhase: numOfPhases > 1
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

				visible: {
					if (index === 0) {
						// Note: multi's connected to the CAN-bus still report these and don't
						// report per phase alarms, so hide it if per phase L1 is available.
						return modelData.valid && !alarmGroup.phase1Alarm.valid
					} else if (index === 1) {
						return modelData.valid
					} else {
						return modelData.valid && root.multiPhase && numOfPhases >= index
					}
				}
				anchors.verticalCenter: parent.verticalCenter
				width: Math.max(
						   (separator.visible
							? implicitWidth + root.content.spacing
							: implicitWidth),
						   Theme.geometry_veBusAlarm_minimumDelegateWidth)
				font.pixelSize: Theme.font_size_body2
				color: Theme.color_listItem_secondaryText
				text: modelData === undefined ? "--" : modelData.displayText
				horizontalAlignment: separator.visible ? Text.AlignHCenter : Text.AlignRight
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
