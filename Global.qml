/*
** Copyright (C) 2022 Victron Energy B.V.
*/
pragma Singleton

import QtQml

// QTBUG-66976: if a QML-defined singleton imports the QML module
// into which it is installed, it results in a cyclic dependency.
//
// So, to work around this issue:
// - declare the other types as non-singleton instances in main.qml
// - define a single singleton which does NOT import Victron.VenusOS
// - initialize the properties of this singleton to point to the
//   instance objects declared in main, in onCompleted or similar.

QtObject {
	property var pageManager
	property var mockDataSimulator    // only valid when mock mode is active
	property var dataManager
	property var locale: Qt.locale()
	property var dataServiceModel: null
	property var firmwareUpdate

	property var inputPanel
	property var dialogLayer
	property var notificationLayer

	// data sources
	property var acInputs
	property var batteries
	property var dcInputs
	property var environmentInputs
	property var ess
	property var evChargers
	property var generators
	property var inverters
	property var notifications
	property var relays
	property var solarChargers
	property var system
	property var systemSettings
	property var tanks
	property var venusPlatform

	property bool splashScreenVisible: true
	property bool dataManagerLoaded
	property bool allPagesLoaded

	signal aboutToFocusTextField(var textField, int toTextFieldY, var flickable)

	function showToastNotification(category, text, autoCloseInterval = 0) {
		notificationLayer.showToastNotification(category, text, autoCloseInterval)
	}

	function deviceModelsForClass(deviceClass) {
		if (deviceClass === "com.victronenergy.battery") {
			return [batteries.model]
		} else if (deviceClass === "com.victronenergy.solarcharger" || deviceClass === "solarcharger") {
			return [solarChargers.model]
		} else if (deviceClass === "analog") {
			return Global.tanks.allTankModels.concat([Global.environmentInputs.model])
		}
		return []
	}
}

