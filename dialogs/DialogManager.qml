/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

Item {
	id: root

	anchors.fill: parent

	function showToastNotification(category, text, autoCloseInterval = 0) {
		var toast = toaster.createObject(this, { "category": category, "text": text, autoCloseInterval: autoCloseInterval })
		toastItemsModel.append(toast)
	}

	Flow {
		anchors {
			left: parent.left
			leftMargin: Theme.geometry.toastNotification.horizontalMargin
			right: parent.right
			rightMargin: Theme.geometry.toastNotification.horizontalMargin
			bottom: parent.bottom
			bottomMargin: Theme.geometry.toastNotification.bottomMargin
		}
		width: parent.width
		spacing: Theme.geometry.toastNotification.bottomMargin
		layoutDirection: Qt.RightToLeft     // layout from bottom to top

		Repeater {
			model: ObjectModel {
				id: toastItemsModel
			}
		}
	}

	Component {
		id: toaster
		ToastNotification {
			id: toast

			function _cleanUp() {
				for (let i = 0; i < toastItemsModel.count; ++i) {
					if (toastItemsModel.get(i) === toast) {
						toastItemsModel.remove(i, 1)
						toast.destroy()
						break
					}
				}
			}

			// delay removal from model, else will crash
			onDismissed: Qt.callLater(_cleanUp)
		}
	}

	Component.onCompleted: Global.dialogManager = root
}
