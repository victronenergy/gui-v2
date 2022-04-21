/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

SettingsListRadioButtonGroup {
	id: accessLevelButtons

	//% "Access level"
	text: qsTrId("settings_access_level")
	source: "com.victronenergy.settings/Settings/System/AccessLevel"
	writeAccessLevel: User.AccessUser

	model: [
		//% "User"
		{ display: qsTrId("settings_access_user"), value: User.AccessUser },
		//% "User & Installer"
		{ display: qsTrId("settings_access_user_installer"), value: User.AccessInstaller },
		//% "Superuser"
		{ display: qsTrId("settings_access_superuser"), value: User.AccessSuperUser },
		//% "Service"
		{ display: qsTrId("settings_access_service"), value: User.AccessService },
	]
	currentIndex: {
		switch (systemSettings.accessLevel) {
		case User.AccessUser:
			return 0
		case User.AccessInstaller:
			return 1
		case User.AccessSuperUser:
			return 2
		case User.AccessService:
			return 3
		default:
			return -1
		}
	}

	onOptionClicked: function(index) {
		systemSettings.setAccessLevel(model[index].value)
	}

	// touch version to get super user
	property bool pulledDown: ListView.view.contentY < -60
	Timer {
		running: parent.pulledDown
		interval: 5000
		onTriggered: {
			if (systemSettings.accessLevel >= User.AccessInstaller) {
				systemSettings.setAccessLevel(User.AccessSuperUser)
			}
		}
	}

	// change to super user mode if the right button is pressed for a while
	property int repeatCount
	onActiveFocusChanged: {
		repeatCount = 0
	}
	Keys.onRightPressed: function(event) {
		if (systemSettings.accessLevel !== User.AccessSuperUser && ++repeatCount > 60) {
			systemSettings.setAccessLevel(User.AccessSuperUser)
			repeatCount = 0
		}
	}

	// change to service user mode if magic combination of up/down keys is pressed
	property int upCount
	property int downCount
	Keys.onUpPressed: function(event) {
		if (upCount < 5) ++upCount
		if (downCount > 0) upCount = 0
		downCount = 0
		event.accepted = false
	}
	Keys.onDownPressed: function(event) {
		if (downCount < 5) ++downCount;
		if (upCount === 5 && downCount === 5) {
			systemSettings.setAccessLevel(User.AccessService)
			upCount = 0
		}
		event.accepted = false
	}
}
