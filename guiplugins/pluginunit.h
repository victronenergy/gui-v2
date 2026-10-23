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
	The units that a PluginListQuantity can show its value in. In QML: PluginUnit.Watt,
	PluginUnit.Volt_DC, and so on. Temperatures use PluginListTemperature instead, which shows the
	value in the user's temperature unit.

	Plugins use these instead of the VenusOS.Units_* values, which are not part of the plugin API.
	The values are the same, so PluginListQuantity passes them straight to the internal row;
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
	Percentage = 20,
	RevolutionsPerMinute = 22,
	VoltAmpere = 34,
	Volt_AC = 36,
	Volt_DC = 37,
	Watt = 42
};
Q_ENUM_NS(Unit)

} // namespace PluginUnit

} // namespace GuiPlugins
} // namespace Victron

#endif // VICTRON_GUIPLUGINS_PLUGINUNIT_H
