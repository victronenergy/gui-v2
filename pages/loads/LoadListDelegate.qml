/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.impl as CP
import Victron.VenusOS

BaseListItem {
	id: root

	required property string name
	property string statusText
	property real temperature: NaN
	property real power: NaN

	property real columnWidth: NaN
	property real columnSpacing

	signal clicked

	width: parent?.width ?? 0
	height: Theme.geometry_loadListPage_item_height
	hasSubMenu: pressArea.enabled

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

	RowLayout {
		width: parent.width
		height: parent.height
		spacing: 0

		Column {
			Layout.fillWidth: true
			Layout.leftMargin: Theme.geometry_listItem_content_horizontalMargin
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
			title: CommonWords.total_power
			value: root.power
			unit: VenusOS.Units_Watt
		}

		CP.ColorImage {
			Layout.rightMargin: Theme.geometry_listItem_content_horizontalMargin
			source: "qrc:/images/icon_arrow_32.svg"
			rotation: 180
			color: pressArea.containsPress ? Theme.color_listItem_down_forwardIcon : Theme.color_listItem_forwardIcon
			opacity: pressArea.enabled ? 1 : 0
		}
	}

	Keys.onSpacePressed: pressArea.clicked(null)
	Keys.onRightPressed: pressArea.clicked(null)
	Keys.enabled: Global.keyNavigationEnabled

	ListPressArea {
		id: pressArea

		anchors.fill: parent
		radius: parent.background.radius
		onClicked: root.clicked()
	}
}
