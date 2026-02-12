/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.impl as CP
import Victron.VenusOS

ListItemControl {
	id: root

	required property string name
	property string statusText
	property real temperature: NaN
	property real power: NaN
	property real current: NaN

	property real columnWidth: NaN
	property real columnSpacing

	property bool unitAmps: false

	signal clicked

	component QuantityColumn : Column {
		property alias title: quantityTitle.text
		property alias value: quantityLabel.value
		property alias unit: quantityLabel.unit

		width: root.columnWidth || implicitWidth
		spacing: Theme.geometry_batteryListPage_item_verticalSpacing

		Label {
			id: quantityTitle
			width: parent.width
			elide: Text.ElideRight
			color: Theme.color_listItem_secondaryText
			font.pixelSize: Theme.font_size_caption
		}

		QuantityLabel {
			id: quantityLabel
			font.pixelSize: Theme.font_size_body2
		}
	}

	contentItem: RowLayout {
		spacing: 0

		Column {
			Layout.fillWidth: true
			Layout.rightMargin: root.columnSpacing
			spacing: Theme.geometry_batteryListPage_item_verticalSpacing

			Label {
				elide: Text.ElideRight
				width: parent.width
				text: root.name
				font.pixelSize: Theme.font_size_body2
			}

			Label {
				font.pixelSize: Theme.font_size_body1
				color: Theme.color_listItem_secondaryText
				text: root.statusText.length > 0
					//% "Status: %1"
					? qsTrId("load_delegate_status").arg(root.statusText)
					: ""
			}
		}

		Loader {
			Layout.rightMargin: root.columnSpacing
			active: !isNaN(root.temperature)
			sourceComponent: QuantityColumn {
				title: CommonWords.temperature
				value: root.temperature
				unit: Global.systemSettings.temperatureUnit
			}
		}

		QuantityColumn {
			title: root._unitAmps ? CommonWords.current_amps : CommonWords.total_power
			value: root._unitAmps ? root.current : root.power
			unit:  root._unitAmps ? VenusOS.Units_Amp : VenusOS.Units_Watt
		}

		CP.ColorImage {
			source: "qrc:/images/icon_arrow_32.svg"
			rotation: 180
			color: Theme.color_listItem_forwardIcon
		}
	}

	background: ListItemBackground {
		ListPressArea {
			anchors.fill: parent
			onClicked: root.clicked()
		}
	}

	Keys.onSpacePressed: clicked()
	Keys.onRightPressed: clicked()
}
