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
	property var dialogManager
	property var inputPanel
	property var locale: Qt.locale()
	property var dataServices: []
	property var dataServiceModel: null
	property var firmwareUpdate

	// data sources
	property var acInputs
	property var battery
	property var dcInputs
	property var environmentInputs
	property var ess
	property var generators
	property var inverters
	property var notifications
	property var relays
	property var solarChargers
	property var system
	property var systemSettings
	property var tanks

	property bool splashScreenVisible: true
	property bool dataManagerLoaded
	property bool allPagesLoaded

	signal aboutToFocusTextField(var textField, int toTextFieldY, var flickable)
}

