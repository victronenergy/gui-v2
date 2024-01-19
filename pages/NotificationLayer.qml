/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	anchors.fill: parent

	function showToastNotification(category, text, autoCloseInterval = 0) {
		var toast = toaster.createObject(toastItemsModel, { "category": category, "text": text, autoCloseInterval: autoCloseInterval })
		toastItemsModel.append(toast)
	}

	function deleteNotification(toast) {
		for (let i = 0; i < toastItemsModel.count; ++i) {
			if (toastItemsModel.get(i) === toast) {
				toastItemsModel.remove(i, 1)
				toast.destroy(1000)
				break
			}
		}
	}

	ListView {
		anchors {
			left: parent.left
			leftMargin: Theme.geometry_toastNotification_horizontalMargin
			right: parent.right
			rightMargin: Theme.geometry_toastNotification_horizontalMargin
			bottom: parent.bottom
			bottomMargin: Theme.geometry_toastNotification_bottomMargin
		}
		width: parent.width
		height: childrenRect.height
		spacing: Theme.geometry_toastNotification_bottomMargin
		layoutDirection: Qt.RightToLeft     // layout from bottom to top

		model: ObjectModel {
			id: toastItemsModel
		}
	}

	Component {
		id: toaster
		ToastNotification {
			id: toast

			// delay removal from model, else will crash
			onDismissed: root.deleteNotification(toast)
		}
	}

}
