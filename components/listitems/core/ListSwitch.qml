/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListItem {
	id: root

	readonly property alias dataItem: dataItem
	property alias checked: switchItem.checked
	property alias checkable: switchItem.checkable
	property alias secondaryText: secondaryLabel.text
	property bool updateDataOnClick: true
	property bool invertSourceValue: false

	property int valueTrue: 1
	property int valueFalse: 0

	property bool backendValue: false

	content.children: [
		Label {
			id: secondaryLabel
			anchors.verticalCenter: switchItem.verticalCenter
			color: Theme.color_font_secondary
			font.pixelSize: Theme.font_size_body2
			width: Math.min(implicitWidth, root.maximumContentWidth - switchItem.width - root.content.spacing)
			wrapMode: Text.Wrap
		},
		Switch {
			id: switchItem

			checked: root.backendValue //invertSourceValue ? dataItem.value === valueFalse : dataItem.value === valueTrue
			checkable: false
			enabled: root.enabled &&
					 root.editable &&
					 root.userHasWriteAccess &&
					 (dataItem.uid === "" || dataItem.isValid)

			onClicked: root.clicked()
		}
	]

	onClicked: {

		if(switchItem.enabled && updateDataOnClick) {

			//console.log("ListSwitch internal (guarded) onClicked handler", root.objectName)

			// if (root.dataItem.uid.length > 0) {
			//     // Note: this logic only holds so long as checkable is false so we can use
			//     // the current unmodified checked state at the point of onClicked.
			//     // (dataItem might not be valid until the first write so we can't simply use
			//     // the comparison of dataItem.value === valueFalse) and forget invertSourceValue).
			//
			//     if (invertSourceValue) {
			//         dataItem.setValue(switchItem.checked ? valueTrue : valueFalse)
			//     } else {
			//         dataItem.setValue(switchItem.checked ? valueFalse : valueTrue)
			//     }
			// }

			timer.restart()
		}

		// else strictly don't do anything here
	}

	Timer {
		id: timer
		repeat: false
		interval: 250 // mock a DBUS round-trip delay
		onTriggered: root.backendValue = !root.backendValue
	}

	VeQuickItem {
		id: dataItem
	}
}
