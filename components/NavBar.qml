/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

FocusScope {  // Use an opaque background so that page disappears behind nav bar when scrolled
	id: root

	required property var model
	readonly property int currentIndex: _currentIndex

	// External components should not write to these properties.
	property int _currentIndex

	signal clicked
	signal released

	function setCurrentPage(pageName) {
		for (let i = 0; i < model.count; ++i) {
			const url = model.get(i).url
			if (url.endsWith("/" + pageName)) {
				_currentIndex = i
				return
			}
		}
		console.warn("setCurrentPage(): cannot find page", pageName)
	}

	function goToPreviousPage() {
		setCurrentIndex((_currentIndex + model.count - 1) % model.count)
	}

	function goToNextPage() {
		setCurrentIndex((_currentIndex + 1) % model.count)
	}

	function setCurrentIndex(index) {
		if (index === _currentIndex) {
			return
		}
		if (index < 0 || index >= model.count) {
			console.log("setCurrentIndex(): invalid index", index, "nav bar count is:", model.count)
			return
		}
		_currentIndex = index
	}

	width: parent.width
	height: Theme.geometry_navigationBar_height

	property alias color: background.color

	Rectangle {
		id: background
		anchors.fill: parent
	}

	Row {
		x: Theme.geometry_page_content_horizontalMargin
		width: parent.width - 2*Theme.geometry_page_content_horizontalMargin
		height: parent.height
		spacing: (width - (repeater.count * Theme.geometry_navigationBar_button_width)) / Math.max(repeater.count - 1, 1)

		Repeater {
			id: repeater

			// The model for this repeater is a 'visual' model (i.e. an ObjectModel), and is used as the model for the SwipeView in MainView.qml.
			// If you use an ObjectModel as the model for more than 1 view, the Items in the ObjectModel only appear in 1 of the views.
			// To work around this shortcoming, we have to use 'root.model.count' instead of 'root.model' as the Repeater model,
			// and other awkward syntax to access model properties.
			model: root.model ? root.model.count : null
			delegate: NavButton {
				readonly property var _modelData: root.model.get(index)
				height: root.height
				width: Theme.geometry_navigationBar_button_width
				text: _modelData.navButtonText
				icon.source: _modelData.navButtonIcon
				checked: root.currentIndex === model.index
				backgroundColor: "transparent"
				focus: model.index === root.currentIndex
				onClicked: {
					root._currentIndex = model.index
					root.clicked()
				}
				onReleased: root.released()
				KeyNavigation.left: repeater.itemAt((model.index - 1) % repeater.count)
				KeyNavigation.right: repeater.itemAt((model.index + 1) % repeater.count)
				MouseArea {
					anchors.fill: parent
					enabled: root.currentIndex === model.index
				}

				Rectangle {
					anchors {
						top: parent.top
						topMargin: Theme.geometry_navigationBar_notifications_redDot_topMargin
						horizontalCenter: parent.horizontalCenter
						horizontalCenterOffset: Theme.geometry_navigationBar_notifications_redDot_horizontalCenterOffset
					}
					width: Theme.geometry_notificationsPage_delegate_marker_width
					height: width
					radius: Theme.geometry_notificationsPage_delegate_marker_radius
					color: Theme.color_critical
					visible: _modelData.url.endsWith("NotificationsPage.qml")
							 && !!Global.notifications
							 && Global.notifications.alert
				}
			}
		}
	}
}
