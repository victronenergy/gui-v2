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

	required property SolarHistory solarHistory
	required property int minimumDay
	required property int maximumDay
	required property var highlightBarForDay

	// The currently displayed day (0=today, 1=yesterday, etc.)
	property int day

	function _setDay(d) {
		if (d >= minimumDay && d <= maximumDay) {
			day = d
			_refresh()
		}
	}

	function _refresh() {
		_positionHighlightBar()
	}

	function _positionHighlightBar() {
		const sourceBar = highlightBarForDay(day)
		if (!sourceBar) {
			console.warn("No highlight bar found for day", day)
			return
		}

		const pos = background.mapFromItem(sourceBar.parent, sourceBar.x, sourceBar.y)
		highlightBar.x = pos.x
		highlightBar.y = pos.y
		highlightBar.width = sourceBar.width
		highlightBar.height = sourceBar.height
	}

	// Use x/y positioning instead of anchors, so that the dialog can be moved by DialogDragger.
	x: (Theme.geometry_screen_width - width) / 2
	y: (Theme.geometry_screen_height - height) / 2
	implicitWidth: Math.max(
		implicitBackgroundWidth + leftInset + rightInset,
		implicitContentWidth + leftPadding + rightPadding)
	implicitHeight: Math.max(
		implicitBackgroundHeight + topInset + bottomInset,
		implicitContentHeight + topPadding + bottomPadding + (header?.height ?? 0) + (footer?.height ?? 0))
	leftMargin: Theme.geometry_solarDailyHistoryDialog_horizontalMargin
	rightMargin: Theme.geometry_solarDailyHistoryDialog_horizontalMargin
	modal: true
	focus: Global.keyNavigationEnabled

	// In case height changes when dialog is opened, update the highlight bar position.
	onHeightChanged: root._positionHighlightBar()

	// Only provide transitions if animations are enabled. Ideally the transitions would always be
	// set but with 'enabled' set to only run when needed, but due to QTBUG-142410 the enabled value
	// is not respected.
	enter: Global.animationEnabled ? enterTransition : null
	exit: Global.animationEnabled ? exitTransition : null

	Transition {
		id: enterTransition
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

	Transition {
		id: exitTransition
		NumberAnimation {
			loops: Qt.platform.os == "wasm" ? 0 : 1 // workaround wasm crash, see https://bugreports.qt.io/browse/QTBUG-121382
			property: "opacity"; from: 1.0; to: 0.0; duration: Theme.animation_page_fade_duration
		}
	}

	background: Rectangle {
		implicitWidth: Theme.geometry_screen_width - root.leftMargin - root.rightMargin
		implicitHeight: 0
		radius: Theme.geometry_solarDailyHistoryDialog_background_radius
		color: Theme.color_background_secondary
		border.color: Theme.color_modalDialog_border

		DialogDragger {
			anchors.fill: parent
			dialog: root
			shadow: dialogShadow
		}

		DialogShadow { id: dialogShadow }

		Rectangle {
			id: highlightBar

			color: Theme.color_ok
			radius: Theme.geometry_solarChart_bar_radius
		}

		component ArrowButton : IconButton {
			icon.sourceSize.height: Theme.geometry_solarDailyHistoryDialog_arrow_icon_size
			icon.color: containsPress ? Theme.color_gray4 : Theme.color_gray5
			icon.source: "qrc:/images/icon_chevron_right_32.svg"
			effectEnabled: false
		}

		ArrowButton {
			anchors {
				right: parent.left
				rightMargin: Theme.geometry_solarDailyHistoryDialog_arrow_horizontalMargin
				verticalCenter: parent.verticalCenter
			}
			visible: root.day > root.minimumDay
			rotation: 180
			onClicked: root._setDay(root.day - 1)
		}

		ArrowButton {
			anchors {
				left: parent.right
				leftMargin: Theme.geometry_solarDailyHistoryDialog_arrow_horizontalMargin
				verticalCenter: parent.verticalCenter
			}
			visible: root.day < root.maximumDay
			onClicked: root._setDay(root.day + 1)
		}
	}

	// This must be a Rectangle to ensure highlightBar does not appear through the content.
	contentItem: Rectangle {
		implicitWidth: Theme.geometry_screen_width - root.leftMargin - root.rightMargin
		implicitHeight: historyListView.y + historyListView.height
			+ (errorView.enabled ? errorView.collapsedHeight + Theme.geometry_solarDetailBox_margins : 0)

		radius: Theme.geometry_solarDailyHistoryDialog_background_radius
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
			text: ClockTime.formatDeltaDate(-1 * 86400 * root.day, "ddd d MMM")
		}

		CloseButton {
			anchors {
				right: parent.right
				top: parent.top
			}
			onClicked: root.close()
		}

		// In portrait layout, this can be flicked horizontally to view different days.
		ListView {
			id: historyListView

			anchors.top: dateLabel.bottom
			width: parent.width
			height: currentItem?.height ?? 0
			interactive: Theme.screenSize === Theme.Portrait
			orientation: Qt.Horizontal
			snapMode: ListView.SnapOneItem
			boundsBehavior: Flickable.StopAtBounds
			highlightRangeMode: ListView.StrictlyEnforceRange
			preferredHighlightBegin: 0
			preferredHighlightEnd: 0
			highlightMoveDuration: 0 // when the left/right arrows are clicked, change the index instantly without animation
			clip: true
			model: root.solarHistory.daysAvailable
			currentIndex: root.day

			delegate: PressArea {
				id: historyDelegate

				required property int index

				implicitWidth: historyListView.width
				implicitHeight: tableView.height

				enabled: errorView.expanded
				onClicked: errorView.expanded = false

				SolarHistoryTableView {
					id: tableView

					width: parent.width
					columnSpacing: Theme.geometry_quantityTable_horizontalSpacing_medium
					summaryBodyFontSize: Theme.font_solarHistoryDialog_summaryBody_size
					detailBoxFontSize: Theme.font_solarHistoryDialog_detailBox_size
					solarHistory: root.solarHistory
					dayRange: [historyDelegate.index, historyDelegate.index + 1]
				}
			}

			onCurrentIndexChanged: root._setDay(currentIndex)
		}

		SolarHistoryErrorView {
			id: errorView

			// Anchor to parent bottom so that the list opens upwards.
			anchors {
				horizontalCenter: parent.horizontalCenter
				bottom: parent.bottom
				bottomMargin: Theme.geometry_solarDetailBox_margins
			}
			width: parent.width - (2 * Theme.geometry_solarDetailBox_margins)
			model: {
				const history = root.solarHistory.dailyHistory(root.day)
				return history ? history.errorModel : null
			}
			enabled: model?.count > 0
			visible: enabled
		}
	}

	Component.onCompleted: {
		if (Global.main && Global.main.requiresRotation) {
			// we cannot manually position the header or footer.
			// just reject the dialog for now.
			// TODO: use eglfs and rotate the entire surface.
			// See: issue #2702
			Qt.callLater(reject)
		}
	}
}
