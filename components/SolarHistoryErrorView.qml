/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

MouseArea {
	id: root

	property var model
	property bool expanded
	readonly property int collapsedHeight: Theme.geometry_solarHistoryErrorView_itemHeight

	property real _maxErrorTitleWidth

	width: parent ? parent.width : 0
	height: errorColumn.height
	clip: true

	onClicked: expanded = !expanded

	Rectangle {
		anchors.fill: parent
		radius: Theme.geometry_solarHistoryErrorView_radius
		color: Theme.color_toastNotification_background_error

		AsymmetricRoundedRectangle {
			anchors {
				left: parent.left
				top: parent.top
				bottom: parent.bottom
			}
			width: Theme.geometry_solarHistoryErrorView_iconBackground_width
			radius: Theme.geometry_solarHistoryErrorView_radius
			color: Theme.color_toastNotification_highlight_error
			flat: true

			CP.ColorImage {
				anchors {
					top: parent.top
					topMargin: (Theme.geometry_solarHistoryErrorView_itemHeight - height) / 2
					horizontalCenter: parent.horizontalCenter
				}
				height: Theme.geometry_solarHistoryErrorView_alarmIcon_size
				fillMode: Image.PreserveAspectFit
				color: Theme.color_solarHistoryErrorView_primaryText
				source: "qrc:/images/toast_icon_alarm.svg"
			}
		}
	}

	CP.ColorImage {
		anchors {
			top: parent.top
			topMargin: root.expanded ? 0 : height / 5   // compensate for icon internal alignment
			right: parent.right
			rightMargin: Theme.geometry_solarHistoryErrorView_expandIcon_horizontalMargin
		}
		height: Theme.geometry_solarHistoryErrorView_expandIcon_size
		fillMode: Image.PreserveAspectFit
		color: Theme.color_solarHistoryErrorView_primaryText
		source: "qrc:/images/icon_back_32.svg"
		rotation: root.expanded ? 270 : 90
	}

	Column {
		id: errorColumn

		anchors {
			left: parent.left
			leftMargin: Theme.geometry_solarHistoryErrorView_iconBackground_width
					+ Theme.geometry_solarHistoryErrorView_textBackground_horizontalMargin
			right: parent.right
			rightMargin: Theme.geometry_solarHistoryErrorView_textBackground_horizontalMargin
		}
		bottomPadding: root.expanded ? Theme.geometry_solarHistoryErrorView_textBackground_bottomMargin : 0
		height: root.expanded ? implicitHeight : Theme.geometry_solarHistoryErrorView_itemHeight

		Behavior on height {
			NumberAnimation {
				duration: Theme.animation_solarHistoryErrorView_expand_duration
			}
		}

		Label {
			id: headerLabel

			width: parent.width
			height: Theme.geometry_solarHistoryErrorView_itemHeight
			rightPadding: Theme.geometry_solarHistoryErrorView_expandIcon_size
			elide: Text.ElideRight
			verticalAlignment: Text.AlignVCenter
			color: Theme.color_solarHistoryErrorView_primaryText
			//% "%1 error(s) occurred"
			text: qsTrId("charger_history_errors_occurred").arg(root.model ? root.model.count : 0)
		}

		Repeater {
			id: errorRepeater

			model: root.model

			delegate: Row {
				readonly property alias titleImplicitWidth: titleLabel.implicitWidth

				width: parent.width
				height: Theme.geometry_solarHistoryErrorView_itemHeight
				spacing: Theme.geometry_solarHistoryErrorView_textBackground_horizontalMargin

				Label {
					id: titleLabel

					anchors.verticalCenter: parent.verticalCenter
					width: root._maxErrorTitleWidth
					visible: root.model.count > 1
					color: Theme.color_solarHistoryErrorView_secondaryText
					//: Details of last error
					//% "Last"
					text: model.index === 0 ? qsTrId("charger_history_errors_last")
						  //: Details of 2nd last error
						  //% "2nd last"
						: model.index === 1 ? qsTrId("charger_history_errors_2nd_last")
						  //: Details of 3rd last error
						  //% "3rd last"
						: model.index === 2 ? qsTrId("charger_history_errors_3rd_last")
						  //: Details of 4th last error
						  //% "4th last"
						: model.index === 3 ? qsTrId("charger_history_errors_4th_last")
						: ""

					onImplicitWidthChanged: {
						let maxTitleWidth = 0
						for (let i = 0; i < errorRepeater.count; ++i) {
							const item = errorRepeater.itemAt(i)
							if (item) {
								maxTitleWidth = Math.max(maxTitleWidth, item.titleImplicitWidth)
							}
						}
						root._maxErrorTitleWidth = maxTitleWidth
					}
				}

				Label {
					anchors.verticalCenter: parent.verticalCenter
					width: parent.width - root._maxErrorTitleWidth
					elide: Text.ElideRight
					color: Theme.color_solarHistoryErrorView_primaryText
					text: ChargerError.description(model.errorCode)
				}
			}
		}
	}
}
