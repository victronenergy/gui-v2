/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

ListItem {
	id: root

	required property string name
	property string statusText
	property real temperature: NaN
	property real power: NaN
	property real current: NaN

	property real columnWidth: NaN
	property real columnSpacing

	property bool unitAmps: false

	readonly property string _statusLabelText: statusText.length === 0 ? ""
			//% "Status: %1"
			: qsTrId("load_delegate_status").arg(statusText)

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

	hasSubMenu: true

	// Landscape layout:
	// | Name            | "Temperature" | "Total power" | Forward |
	// | Status          | Temperature   | Power         |   icon  |
	//
	// Portrait layout:
	// | Name       | Temperature | Power | Forward |
	// | Status                           |   icon  |
	contentItem: Item {
		implicitWidth: Theme.geometry_listItem_width
		implicitHeight: layoutLoader.height

		Loader {
			id: layoutLoader
			width: parent.width - forwardIcon.width
			sourceComponent: Theme.screenSize === Theme.Portrait ? portraitLayoutComponent : landscapeLayoutComponent
		}

		ForwardIcon {
			id: forwardIcon
			anchors {
				verticalCenter: parent.verticalCenter
				right: parent.right
			}
		}

		Component {
			id: portraitLayoutComponent

			GridLayout {
				columns: primaryLabel.implicitWidth + quantityRow.width > width ? 1 : 2
				columnSpacing: root.spacing
				rowSpacing: Theme.geometry_listItem_content_verticalSpacing

				Label {
					id: primaryLabel

					text: root.name
					textFormat: root.textFormat
					font: root.font
					wrapMode: Text.Wrap

					Layout.fillWidth: true
				}

				QuantityRow {
					id: quantityRow

					model: QuantityObjectModel {
						filterType: QuantityObjectModel.HasValue
						QuantityObject { object: root; key: "temperature"; unit: Global.systemSettings.temperatureUnit }
						QuantityObject { object: root; key: root._unitAmps ? "current" : "power"; unit: root._unitAmps ? VenusOS.Units_Amp : VenusOS.Units_Watt }
					}

					Layout.alignment: parent.columns === 1 ? Qt.AlignVCenter : Qt.AlignTop
				}

				CaptionLabel {
					text: root._statusLabelText
					visible: text.length > 0

					Layout.fillWidth: true
					Layout.columnSpan: parent.columns === 1 ? 1 : 2
				}
			}
		}

		Component {
			id: landscapeLayoutComponent

			RowLayout {
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
						text: root._statusLabelText
					}
				}

				QuantityColumn {
					visible: !isNaN(root.temperature)
					title: CommonWords.temperature
					value: root.temperature
					unit: Global.systemSettings.temperatureUnit

					Layout.rightMargin: root.columnSpacing
				}

				QuantityColumn {
					title: root._unitAmps ? CommonWords.current_amps : CommonWords.total_power
					value: root._unitAmps ? root.current : root.power
					unit:  root._unitAmps ? VenusOS.Units_Amp : VenusOS.Units_Watt
				}
			}
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
