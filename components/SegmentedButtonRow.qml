/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls as C
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Item {
	id: root

	property int fontPixelSize: Theme.font.size.l
	property alias model: buttonRepeater.model
	property int currentIndex

	signal buttonClicked(buttonIndex: int)

	implicitWidth: parent.width
	implicitHeight: Theme.geometry.segmentedButtonRow.height

	C.ButtonGroup {
		buttons: root.children
	}

	Row {
		id: buttonRow

		height: parent.height
		width: parent.width

		Repeater {
			id: buttonRepeater
			height: parent.height

			delegate: Button {
				id: buttonDelegate

				property int modelIndex: model.index

				width: root.width / buttonRepeater.count
				height: parent.height
				checked: model.index === root.currentIndex
				font.pixelSize: root.fontPixelSize
				flat: false
				text: qsTrId(model.text)
				roundedSide: modelIndex === 0 ? Enums.AsymmetricRoundedRectangle_RoundedSide_Left
					: modelIndex === (buttonRepeater.count-1) ? Enums.AsymmetricRoundedRectangle_RoundedSide_Right
					: Enums.AsymmetricRoundedRectangle_RoundedSide_NoneHorizontal

				onClicked: {
					root.buttonClicked(model.index)
					root.currentIndex = model.index
				}
			}
		}
	}
}
