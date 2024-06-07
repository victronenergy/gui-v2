import QtQuick
import QtQml.Models
import Victron.VenusOS

ObjectModel {
	id: root

	required property SwipeView view
	readonly property bool showLevelsPage: tankCount > 0 || environmentInputCount > 0
	readonly property bool showLogoutPage: Qt.platform.os === "wasm" && !BackendConnection.vrm
	readonly property bool tankCount: Global.tanks ? Global.tanks.totalTankCount : 0
	readonly property bool environmentInputCount: Global.environmentInputs ? Global.environmentInputs.model.count : 0

	property bool _completed: false
	readonly property Component levelsPage: Component {
		LevelsPage {
			view: root.view
		}
	}
	readonly property Component logoutPage: Component {
		LogoutPage {
			view: root.view
		}
	}

	BriefPage {
		view: root.view
	}

	OverviewPage {
		view: root.view
	}

	NotificationsPage {
		view: root.view
	}

	SettingsPage {
		view: root.view
	}

	Component.onCompleted: {
		if (showLevelsPage) {
			insert(2, levelsPage.createObject(parent))
		}
		if (showLogoutPage) {
			append(logoutPage.createObject(parent))
		}
		_completed = true
	}

	onShowLevelsPageChanged: {
		if (!_completed) {
			return
		}

		if (showLevelsPage) {
			root.view.insertItem(2, levelsPage.createObject(parent))
		} else {
			root.view.removeItem(view.itemAt(2))
		}
	}

	onShowLogoutPageChanged: {
		if (!_completed) {
			return
		}

		if (showLevelsPage) {
			root.view.append(logoutPage.createObject(parent))
		} else {
			root.view.removeItem(view.itemAt(view.count - 1))
		}
	}
}
