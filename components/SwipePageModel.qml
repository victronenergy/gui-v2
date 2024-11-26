import QtQuick
import QtQml.Models
import Victron.VenusOS

ObjectModel {
	id: root

	required property SwipeView view
	readonly property bool showLevelsPage: tankCount > 0 || environmentInputCount > 0
	readonly property bool tankCount: Global.tanks ? Global.tanks.totalTankCount : 0
	readonly property bool environmentInputCount: Global.environmentInputs ? Global.environmentInputs.model.count : 0

	property bool _completed: false
	readonly property Component levelsPage: Component {
		LevelsPage {
			view: root.view
		}
	}

	BriefPage {
		view: root.view

		Image {
			width: status === Image.Null ? 0 : Theme.geometry_screen_width
			fillMode: Image.PreserveAspectFit
			source: BackendConnection.demoImageFileName
			onStatusChanged: {
				if (status === Image.Ready) {
					console.log("Loaded demo image:", source);
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
			insert(2, levelsPage.createObject(parent));
		}
		_completed = true;
	}

	onShowLevelsPageChanged: {
		if (!_completed) {
			return;
		}
		if (showLevelsPage) {
			root.view.insertItem(2, levelsPage.createObject(parent));
		} else {
			root.view.removeItem(view.itemAt(2));
		}
	}
}
