/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

pragma Singleton

import QtQml

/*
	The urls of common icons. Draw them with PluginIconImage, which tints them with the GUI's
	colors, for example:
	PluginIconImage { source: PluginIcons.warning; tint: PluginIconImage.Warning }

	Do not draw them with Image: they have a single color, which may not show on the background.
	An icon keeps its name here, even if the image file behind it changes.
*/
QtObject {
	readonly property url alarm: "qrc:/images/icon_alarm_32.svg"
	readonly property url warning: "qrc:/images/icon_warning_32.svg"
	readonly property url info: "qrc:/images/icon_info_32.svg"
	readonly property url checkmark: "qrc:/images/icon_checkmark_32.svg"
	readonly property url close: "qrc:/images/icon_close_32.svg"
	readonly property url plus: "qrc:/images/icon_plus_32.svg"
	readonly property url minus: "qrc:/images/icon_minus_32.svg"
	readonly property url trash: "qrc:/images/icon_trash_32.svg"
	readonly property url refresh: "qrc:/images/icon_refresh_32.svg"
	readonly property url open_link: "qrc:/images/icon_open_link_32.svg"
	readonly property url battery: "qrc:/images/icon_battery_24.svg"
	readonly property url temperature: "qrc:/images/icon_temp_32.svg"
	readonly property url humidity: "qrc:/images/icon_humidity_32.svg"
	readonly property url devices: "qrc:/images/icon_devices_32.svg"
}
