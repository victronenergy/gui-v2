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
	property var demoManager    // only valid when demo mode is active
	property var dialogManager
	property var inputPanel
	property var locale: Qt.locale()
	property var dataServices: []

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

	readonly property bool ready: pageManager != null && dataBackendLoaded
	property bool splashScreenVisible: true
	property bool dataBackendLoaded
	property bool allPagesLoaded

	signal aboutToFocusTextField(var textField, int toTextFieldY, var flickable)

	function secondsToString(secs)
	{
		if (secs === undefined) {
			return "---"
		}
		const days = Math.floor(secs / 86400);
		const hours = Math.floor((secs - (days * 86400)) / 3600);
		const minutes = Math.floor((secs - (hours * 3600)) / 60);
		const seconds = Math.floor(secs - (minutes * 60));
		if (days > 0) {
			//% "%1d %2h"
			return qsTrId("global_format_days_hours").arg(days).arg(hours);
		}
		if (hours) {
			//% "%1h %2m"
			return qsTrId("global_format_hours_min").arg(hours).arg(minutes);
		}
		if (minutes) {
			//% "%1m %2s"
			return qsTrId("global_format_min_sec").arg(minutes).arg(seconds);
		}
		//% "%1s"
		return qsTrId("global_format_sec").arg(seconds);
	}
}

