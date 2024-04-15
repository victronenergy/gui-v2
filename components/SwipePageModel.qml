import QtQuick
import QtQml.Models
import Victron.VenusOS

ObjectModel {
	id: root

	required property SwipeView view
	readonly property bool showLevelsPage: (Global.tanks && Global.tanks.totalTankCount > 0) || (Global.environmentInputs && Global.environmentInputs.model.count > 0)
	property bool _completed: false
	readonly property Component levelsPage: Component {
		LevelsPage {
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
		_completed = true
	}

	onShowLevelsPageChanged: {
		if (!_completed) {
			return
		}

		if (showLevelsPage) {
			insert(2, levelsPage.createObject(parent))
		} else {
			remove(2)
		}
	}
}
