/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick

/*
	The colours of the RV illustration, from the "Custom Illustrations" design.

	They are not gui-v2 Theme colours: the design uses its own palette, and the standalone app has
	no Theme. Keeping them here gives the components named roles, and lets a host override any of
	them (e.g. for branding).
*/
QtObject {
	property bool dark: false

	property color background: dark ? "#0A0C0E" : "#E9ECEF"
	property color flow: dark ? "#66B0FF" : "#005FBE"

	property color cardBackground: dark ? "#121518" : "#F8F9FA"
	property color cardActiveBackground: dark ? "#002A54" : "#CCE5FF"
	property color cardAlarmBackground: dark ? "#561400" : "#FBD2C5"
	property color cardBorder: dark ? "#1AFFFFFF" : "#1A000000"  // white or black at 10%
	property color cardActiveBorder: dark ? "#3395FF" : "#005FBE"
	property color cardAlarmBorder: "#E84A1A"
	property color primaryText: dark ? "#DEE2E6" : "#343A40"
	property color secondaryText: dark ? "#ADB5BD" : "#495057"

	property color batteryBackground: dark ? "#121518" : "#F8F9FA"
	property color batteryIdleFill: dark ? "#002A54" : "#CCE5FF"
	property color batteryChargingFill: dark ? "#042E15" : "#C0F0D4"
	property color batteryDischargingFill: dark ? "#522F00" : "#FFE4B8"
	property color batteryAlarmFill: dark ? "#561400" : "#FBD2C5"
	property color batteryIdleBorder: dark ? "#3395FF" : "#005FBE"
	property color batteryChargingBorder: dark ? "#33E47D" : "#148443"
	property color batteryDischargingBorder: "#FF9500"
	property color batteryAlarmBorder: dark ? "#FF5C28" : "#DB3500"
	property color batteryIcon: dark ? "#F1F3F5" : "#121518"
	property color batteryText: dark ? "#DEE2E6" : "#343A40"

	property color deviceInactive: dark ? "#343A40" : "#ADB5BD"
	property color deviceActive: "#005FBE"
	property color deviceAlarm: dark ? "#FF5C28" : "#DB3500"
}
