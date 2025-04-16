/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Templates as T
import Victron.VenusOS

// This doesn't extend ModalDialog, due to the custom background layering required to show the
// selected bar from the bar chart with full opacity (undimmed) behind the dialog.
T.Dialog {
	id: root

	property alias solarHistory: tableView.solarHistory
	property int day
	property int minimumDay
	property int maximumDay
	property var highlightBarForDay

	function _setDay(d) {
		if (d >= minimumDay && d <= maximumDay) {
			day = d
			_refresh()
		}
	}

	function _refresh() {
		dateLabel.text = ClockTime.formatDeltaDate(-1 * 86400 * day, "ddd d MMM")
		tableView.dayRange = [day, day + 1]
		_positionHighlightBar()
	}

	function _positionHighlightBar() {
		const sourceBar = highlightBarForDay(day)
		if (!sourceBar) {
			console.warn("No highlight bar found for day", day)
			return
		}

		// forceLayout() to ensure geometry is correct before calling mapFromItem().
		tableView.forceLayout()
		const pos = background.mapFromItem(sourceBar.parent, sourceBar.x, sourceBar.y)
		highlightBar.x = pos.x
		highlightBar.y = pos.y
		highlightBar.width = sourceBar.width
		highlightBar.height = sourceBar.height
	}

	anchors.centerIn: parent
	implicitWidth: background.implicitWidth
	implicitHeight: Theme.geometry_solarDailyHistoryDialog_header_height
					+ tableView.height
					+ (errorView.visible ? errorView.collapsedHeight + Theme.geometry_solarDetailBox_verticalMargin : 0)
	verticalPadding: 0
	horizontalPadding: 0
	modal: true
	focus: Global.keyNavigationEnabled

	// In case height changes when dialog is opened, update the highlight bar position.
	onHeightChanged: root._positionHighlightBar()

	enter: Transition {
		SequentialAnimation {
			ScriptAction {
				script: {
					// Refresh the UI here, instead of in onAboutToShow, to ensure geometry is ready
					// so that the highlight bar is correctly positioned.
					root.opacity = 0
					root._refresh()
				}
			}
			NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: Theme.animation_page_fade_duration }
		}
	}
	exit: Transition {
		NumberAnimation {
			loops: Qt.platform.os == "wasm" ? 0 : 1 // workaround wasm crash, see https://bugreports.qt.io/browse/QTBUG-121382
			property: "opacity"; from: 1.0; to: 0.0; duration: Theme.animation_page_fade_duration }
	}

	background: Rectangle {
		implicitWidth: Theme.geometry_modalDialog_width
		implicitHeight: Theme.geometry_solarDailyHistoryDialog_header_height
					+ tableView.height
					+ (errorView.visible ? errorView.collapsedHeight + Theme.geometry_solarDetailBox_verticalMargin : 0)
		radius: Theme.geometry_modalDialog_radius
		color: Theme.color_background_secondary

		DialogShadow {}

		Rectangle {
			id: highlightBar

			color: Theme.color_ok
			radius: Theme.geometry_solarChart_bar_radius
		}

		component ArrowButton : IconButton {
			icon.sourceSize.height: Theme.geometry_solarDailyHistoryDialog_arrow_icon_size
			icon.color: containsPress ? Theme.color_gray4 : Theme.color_gray5
			icon.source: "qrc:/images/icon_arrow_32.svg"
			effectEnabled: false
		}

		ArrowButton {
			anchors {
				right: parent.left
				rightMargin: Theme.geometry_solarDailyHistoryDialog_arrow_horizontalMargin
				verticalCenter: parent.verticalCenter
			}
			visible: root.day > root.minimumDay
			onClicked: root._setDay(root.day - 1)
		}

		ArrowButton {
			anchors {
				left: parent.right
				leftMargin: Theme.geometry_solarDailyHistoryDialog_arrow_horizontalMargin
				verticalCenter: parent.verticalCenter
			}
			visible: root.day < root.maximumDay
			rotation: 180
			onClicked: root._setDay(root.day + 1)
		}
	}

	// This must be a Rectangle to ensure highlightBar does not appear through the content.
	contentItem: Rectangle {
		radius: Theme.geometry_modalDialog_radius
		color: Theme.color_background_secondary
		focus: true

		Keys.onLeftPressed: root._setDay(root.day - 1)
		Keys.onRightPressed: root._setDay(root.day + 1)
		Keys.onUpPressed: errorView.expanded = true
		Keys.onDownPressed: errorView.expanded = false
		Keys.enabled: Global.keyNavigationEnabled

		Label {
			id: dateLabel

			width: parent.width
			height: Theme.geometry_solarDailyHistoryDialog_header_height
			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
			font.pixelSize: Theme.font_size_body1
		}

		IconButton {
			anchors {
				right: parent.right
				top: parent.top
			}
			width: Theme.geometry_solarDailyHistoryDialog_closeButton_icon_size + (2 * Theme.geometry_solarDailyHistoryDialog_closeButton_icon_margins)
			height: Theme.geometry_solarDailyHistoryDialog_closeButton_icon_size + (2 * Theme.geometry_solarDailyHistoryDialog_closeButton_icon_margins)
			icon.sourceSize.height: Theme.geometry_solarDailyHistoryDialog_closeButton_icon_size
			icon.color: Theme.color_ok
			icon.source: "qrc:/images/icon_close_32.svg"

			onClicked: root.close()
		}

		SolarHistoryTableView {
			id: tableView

			anchors {
				top: dateLabel.bottom
				left: parent.left
				right: parent.right
			}
			smallTextMode: true
			minimumHeight: root.solarHistory.trackerCount > 1 ? NaN
				: Theme.geometry_solarDailyHistoryDialog_minimumHeight - Theme.geometry_solarDailyHistoryDialog_header_height
		}

		PressArea {
			anchors.fill: tableView
			enabled: errorView.expanded
			onClicked: errorView.expanded = false
		}

		SolarHistoryErrorView {
			id: errorView

			anchors {
				horizontalCenter: parent.horizontalCenter
				bottom: parent.bottom
				bottomMargin: Theme.geometry_solarDetailBox_verticalMargin
			}
			width: parent.width - (2 * Theme.geometry_solarDetailBox_verticalMargin)
			model: {
				const history = root.solarHistory.dailyHistory(root.day)
				return history ? history.errorModel : null
			}
			visible: model && model.count > 0
		}
	}
}
