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
	writeAccessLevel: VenusOS.User_AccessType_User

	optionModel: [
		//% "User"
		{ display: qsTrId("settings_access_user"), value: VenusOS.User_AccessType_User },
		//% "User & Installer"
		{ display: qsTrId("settings_access_user_installer"), value: VenusOS.User_AccessType_Installer },
		//% "Superuser"
		{ display: qsTrId("settings_access_superuser"), value: VenusOS.User_AccessType_SuperUser },
		//% "Service"
		{ display: qsTrId("settings_access_service"), value: VenusOS.User_AccessType_Service },
	]
	currentIndex: {
		switch (Global.systemSettings.accessLevel.value) {
		case VenusOS.User_AccessType_User:
			return 0
		case VenusOS.User_AccessType_Installer:
			return 1
		case VenusOS.User_AccessType_SuperUser:
			return 2
		case VenusOS.User_AccessType_Service:
			return 3
		default:
			return -1
		}
	}

	onOptionClicked: function(index) {
		Global.systemSettings.accessLevel.setValue(optionModel[index].value)
	}

	// touch version to get super user
	property bool pulledDown: ListView.view.contentY < -60
	Timer {
		running: parent.pulledDown
		interval: 5000
		onTriggered: {
			if (Global.systemSettings.accessLevel.value >= VenusOS.User_AccessType_Installer) {
				Global.systemSettings.accessLevel.setValue(VenusOS.User_AccessType_SuperUser)
			}
		}
	}

	// change to super user mode if the right button is pressed for a while
	property int repeatCount
	onActiveFocusChanged: {
		repeatCount = 0
	}
	Keys.onRightPressed: function(event) {
		if (Global.systemSettings.accessLevel.value !== VenusOS.User_AccessType_SuperUser && ++repeatCount > 60) {
			Global.systemSettings.accessLevel.setValue(VenusOS.User_AccessType_SuperUser)
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
			Global.systemSettings.accessLevel.setValue(VenusOS.User_AccessType_Service)
			upCount = 0
		}
		event.accepted = false
	}
}
