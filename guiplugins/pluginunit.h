/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIPLUGINS_PLUGINUNIT_H
#define VICTRON_GUIPLUGINS_PLUGINUNIT_H

#include <QObject>
#include <qqmlintegration.h>

namespace Victron {
namespace GuiPlugins {

/*
	The units that a PluginListQuantity or a PluginQuantityLabel can show its value in. In QML:
	PluginUnit.Watt, PluginUnit.Volt_DC, and so on. Temperatures use PluginListTemperature instead,
	which shows the value in the user's temperature unit. Other units that the user picks in the
	settings, such as volume and speed, are not here, as they would be shown in a fixed unit.

	Plugins use these instead of the VenusOS.Units_* values, which are not part of the plugin API.
	The values are the same, so the wrappers pass them straight to the internal items;
	pluginunit.cpp checks that at build time. The values are given explicitly, so that a change to
	the VenusOS values cannot change them.
*/
namespace PluginUnit {
Q_NAMESPACE
QML_ELEMENT

enum Unit {
	None = 0,
	Amp = 1,
	AmpHour = 2,
	Energy_KiloWattHour = 7,
	Hectopascal = 9,
	Hertz = 10,
	Kilopascal = 12,
	Percentage = 20,
	PowerFactor = 21,
	RevolutionsPerMinute = 22,
	Time_Day = 30,
	Time_Hour = 31,
	Time_Minute = 32,
	Time_Second = 33,
	VoltAmpere = 34,
	VoltAmpereReactive = 35,
	Volt_AC = 36,
	Volt_DC = 37,
	Watt = 42,
	WattsPerSquareMetre = 43
};
Q_ENUM_NS(Unit)

} // namespace PluginUnit

} // namespace GuiPlugins
} // namespace Victron

#endif // VICTRON_GUIPLUGINS_PLUGINUNIT_H
