/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "pluginunit.h"

#include "enums.h"

namespace Victron {
namespace GuiPlugins {

// PluginListQuantity passes a PluginUnit straight to the internal row, which takes a
// VenusOS.Units_Type. If one of these fails, keep the PluginUnit value, and map the values in
// PluginListQuantity instead.
using VenusOS::Enums;
static_assert(int(PluginUnit::None) == int(Enums::Units_None));
static_assert(int(PluginUnit::Amp) == int(Enums::Units_Amp));
static_assert(int(PluginUnit::AmpHour) == int(Enums::Units_AmpHour));
static_assert(int(PluginUnit::Energy_KiloWattHour) == int(Enums::Units_Energy_KiloWattHour));
static_assert(int(PluginUnit::Percentage) == int(Enums::Units_Percentage));
static_assert(int(PluginUnit::RevolutionsPerMinute) == int(Enums::Units_RevolutionsPerMinute));
static_assert(int(PluginUnit::VoltAmpere) == int(Enums::Units_VoltAmpere));
static_assert(int(PluginUnit::Volt_AC) == int(Enums::Units_Volt_AC));
static_assert(int(PluginUnit::Volt_DC) == int(Enums::Units_Volt_DC));
static_assert(int(PluginUnit::Watt) == int(Enums::Units_Watt));

} // namespace GuiPlugins
} // namespace Victron
