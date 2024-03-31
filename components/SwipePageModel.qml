import QtQuick
import QtQml.Models
import Victron.VenusOS

ListModel {
	id: root

	readonly property bool showLevelsPage: (Global.tanks && Global.tanks.totalTankCount > 0) || (Global.environmentInputs && Global.environmentInputs.model.count > 0)
	property bool _completed: false

	readonly property Component briefPage: Component {
		BriefPage {}
	}

	readonly property Component overviewPage: Component {
		OverviewPage {}
	}

	readonly property Component levelsPage: Component {
		LevelsPage {}
	}

	readonly property Component notificationsPage: Component {
		NotificationsPage {}
	}

	readonly property Component settingsPage: Component {
		SettingsPage {}
	}

	Component.onCompleted: {
		append({
				   //% "Brief"
				   text: qsTrId("nav_brief"),
				   icon: "qrc:/images/brief.svg",
				   url: "qrc:/qt/qml/Victron/VenusOS/pages/BriefPage.qml",
				   sourceComponent: briefPage
			   })
		append({
				   //% "Overview"
				   text: qsTrId("nav_overview"),
				   icon: "qrc:/images/overview.svg",
				   url: "qrc:/qt/qml/Victron/VenusOS/pages/OverviewPage.qml",
				   sourceComponent: overviewPage
			   })
		if (showLevelsPage) {
			append({
					   //% "Levels"
					   text: qsTrId("nav_levels"),
					   icon: "qrc:/images/levels.svg",
					   url: "qrc:/qt/qml/Victron/VenusOS/pages/LevelsPage.qml",
					   sourceComponent: levelsPage
				   })
		}
		append({
				   //% "Notifications"
				   text: qsTrId("nav_notifications"),
				   icon: "qrc:/images/notifications.svg",
				   url: "qrc:/qt/qml/Victron/VenusOS/pages/NotificationsPage.qml",
				   sourceComponent: notificationsPage
			   })
		append({
				   //% "Settings"
				   text: qsTrId("nav_settings"),
				   icon: "qrc:/images/settings.svg",
				   url: "qrc:/qt/qml/Victron/VenusOS/pages/SettingsPage.qml",
				   sourceComponent: settingsPage
			   })

		_completed = true

	}

	onShowLevelsPageChanged: {
		if (!_completed) {
			return
		}

		if (showLevelsPage) {
			console.log("adding levels page")
			insert(2, {
					   //% "Levels"
					   text: qsTrId("nav_levels"),
					   icon: "qrc:/images/levels.svg",
					   url: "qrc:/qt/qml/Victron/VenusOS/pages/LevelsPage.qml",
					   sourceComponent: levelsPage
				   })
		} else {
			console.log("removing levels page")
			remove(2)
		}
	}

	Component.onCompleted: Global.pageModel = root
}
