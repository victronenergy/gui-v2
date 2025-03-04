import QtQuick
import QtQml.Models
import Victron.VenusOS
import Victron.BoatPageComponents as BoatPageComponents

ObjectModel {
	id: root

	required property SwipeView view
	readonly property bool showLevelsPage: tankCount > 0 || environmentInputCount > 0
	readonly property bool tankCount: Global.tanks ? Global.tanks.totalTankCount : 0
	readonly property bool environmentInputCount: Global.environmentInputs ? Global.environmentInputs.model.count : 0

	readonly property Component boatPage: Component {
		BoatPageComponents.BoatPage {
			view: root.view
		}
	}
	readonly property VeQuickItem showBoatPage: VeQuickItem {
		uid: !!Global.systemSettings ? Global.systemSettings.serviceUid + "/Settings/Gui/ElectricPropulsionUI/Enabled" : ""
		onValueChanged: {
			if (!_completed) {
				return
			}

			if (value) {
				root.view.insertItem(0, boatPage.createObject(parent))
			} else {
				root.view.removeItem(view.itemAt(0))
			}
		}
	}

	readonly property Component levelsPage: Component {
		LevelsPage {
			view: root.view
		}
	}

	property bool _completed: false

	BriefPage {
		view: root.view

		Image {
			width: status === Image.Null ? 0 : Theme.geometry_screen_width
			fillMode: Image.PreserveAspectFit
			source: BackendConnection.demoImageFileName
			onStatusChanged: {
				if (status === Image.Ready) {
					console.log("Loaded demo image:", source)
				}
			}
		}
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

		if (showBoatPage.value) {
			insert(0, boatPage.createObject(parent))
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
}
