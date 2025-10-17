/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	anchors.fill: parent
	anchors.bottomMargin: Qt.inputMethod && Qt.inputMethod.visible ? Qt.inputMethod.keyboardRectangle.height : 0

	property bool animationEnabled: Global.animationEnabled

	property Connections _toastController: Connections {
		id: toastController
		target: NotificationModel

		function onAdded(modelId) {
			let entry = NotificationModel.get(modelId)
			if (!entry.acknowledged) {
				ToastModel.addNotification(
						modelId,
						entry.type,
						"" + entry.deviceName + "\n" + entry.description)
			}
		}

		function onChanged(modelId, roles) {
			let entry = NotificationModel.get(modelId)
			if (roles.indexOf(NotificationModel.NotificationRoles.Acknowledged) >= 0) {
				if (entry.acknowledged) {
					ToastModel.removeNotification(modelId)
				} else {
					// because Notification slots are recycled, the acknowledged value
					// for "new" notifications residing in recycled slots can be updated
					// after its active value becomes true.
					if (!entry.acknowledged) {
						ToastModel.addNotification(
								modelId,
								entry.type,
								"" + entry.deviceName + "\n" + entry.description)
					}
				}
			} else if (roles.indexOf(NotificationModel.NotificationRoles.Description) >= 0) {
				let text = "" + entry.deviceName + "\n" + entry.description
				ToastModel.updateNotification(modelId, text)
			}
		}

		function onRemoved(modelId) {
			ToastModel.removeNotification(modelId)
		}
	}

	ListView {
		id: view
		anchors {
			left: parent.left
			leftMargin: Theme.geometry_toastNotification_horizontalMargin
			right: parent.right
			rightMargin: Theme.geometry_toastNotification_horizontalMargin
			bottom: parent.bottom
			bottomMargin: Theme.geometry_toastNotification_bottomMargin
		}

		height: 2*Theme.geometry_toastNotification_minHeight
		spacing: Theme.geometry_toastNotification_horizontalMargin
		orientation: Qt.Horizontal
		interactive: false
		cacheBuffer: Theme.geometry_screen_width - 2*Theme.geometry_toastNotification_horizontalMargin
		model: ToastModel

		property bool animationEnabled: true
		onAnimationEnabledChanged: {
			if (!animationEnabled) {
				Qt.callLater(view.resetAnimationEnabled)
			}
		}
		function resetAnimationEnabled() {
			animationEnabled = true
		}

		delegate: Item {
			id: toastContainer

			required property int index
			required property int modelId
			required property int notificationModelId
			required property int type
			required property string description
			required property int autoCloseInterval

			width: view.width
			height: view.height
			opacity: 1.0

			Behavior on opacity {
				enabled: root.animationEnabled
				OpacityAnimator { duration: 200 }
			}

			Component.onCompleted: checkIndex()
			onIndexChanged: checkIndex()
			function checkIndex() {
				toastContainer.opacity = index === 0 ? 1.0 : 0.0
				if (index === 0 && autoCloseInterval > 0) {
					// our index is zero, so we're the visible toast.
					// check to see if we need to autoclose.
					autoCloseTimer.interval = autoCloseInterval
					autoCloseTimer.start()
				}
			}

			Timer {
				id: autoCloseTimer
				onTriggered: ToastModel.remove(toastContainer.modelId)
			}

			ToastNotification {
				y: parent.height - height

				height: implicitHeight
				width: parent.width

				notificationModelId: toastContainer.notificationModelId
				toastModelId: toastContainer.modelId
				text: toastContainer.description
				type: toastContainer.type

				onDismissed: {
					if (toastContainer.notificationModelId !== 0) {
						NotificationModel.acknowledge(toastContainer.notificationModelId)
					}
					ToastModel.remove(toastContainer.modelId)
				}

				onClosed: {
					view.animationEnabled = false
					if (toastContainer.notificationModelId !== 0) {
						NotificationModel.acknowledge(toastContainer.notificationModelId)
					}
					ToastModel.remove(toastContainer.modelId)
				}
			}
		}

		// We cannot use XAnimator etc for view transitions, as it
		// messes with ListView's content positioning logic etc.
		// So, we have to use NumberAnimation instead.
		add: Transition {
			enabled: root.animationEnabled && view.animationEnabled
			NumberAnimation {
				properties: "x"
				from: -view.width
				duration: Theme.animation_toastNotification_fade_duration
			}
		}
		addDisplaced: Transition {
			enabled: root.animationEnabled && view.animationEnabled
			NumberAnimation {
				properties: "x"
				duration: Theme.animation_toastNotification_fade_duration
			}
		}
		remove: Transition {
			enabled: root.animationEnabled && view.animationEnabled
			NumberAnimation {
				properties: "y"
				to: view.height
				duration: Theme.animation_toastNotification_fade_duration
			}
		}
		removeDisplaced: Transition {
			enabled: root.animationEnabled && view.animationEnabled
			NumberAnimation {
				properties: "x"
				duration: Theme.animation_toastNotification_fade_duration
			}
		}
	}
}
