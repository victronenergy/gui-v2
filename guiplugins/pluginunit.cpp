/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "pluginunit.h"

#include "enums.h"

namespace Victron {
namespace GuiPlugins {

// PluginListQuantity and PluginQuantityLabel pass a PluginUnit straight to the internal items,
// which take a VenusOS.Units_Type. If one of these fails, keep the PluginUnit value, and map the
// values in those wrappers instead.
using VenusOS::Enums;
static_assert(int(PluginUnit::None) == int(Enums::Units_None));
static_assert(int(PluginUnit::Amp) == int(Enums::Units_Amp));
static_assert(int(PluginUnit::AmpHour) == int(Enums::Units_AmpHour));
static_assert(int(PluginUnit::Energy_KiloWattHour) == int(Enums::Units_Energy_KiloWattHour));
static_assert(int(PluginUnit::Hectopascal) == int(Enums::Units_Hectopascal));
static_assert(int(PluginUnit::Hertz) == int(Enums::Units_Hertz));
static_assert(int(PluginUnit::Kilopascal) == int(Enums::Units_Kilopascal));
static_assert(int(PluginUnit::Percentage) == int(Enums::Units_Percentage));
static_assert(int(PluginUnit::PowerFactor) == int(Enums::Units_PowerFactor));
static_assert(int(PluginUnit::RevolutionsPerMinute) == int(Enums::Units_RevolutionsPerMinute));
static_assert(int(PluginUnit::Time_Day) == int(Enums::Units_Time_Day));
static_assert(int(PluginUnit::Time_Hour) == int(Enums::Units_Time_Hour));
static_assert(int(PluginUnit::Time_Minute) == int(Enums::Units_Time_Minute));
static_assert(int(PluginUnit::Time_Second) == int(Enums::Units_Time_Second));
static_assert(int(PluginUnit::VoltAmpere) == int(Enums::Units_VoltAmpere));
static_assert(int(PluginUnit::VoltAmpereReactive) == int(Enums::Units_VoltAmpereReactive));
static_assert(int(PluginUnit::Volt_AC) == int(Enums::Units_Volt_AC));
static_assert(int(PluginUnit::Volt_DC) == int(Enums::Units_Volt_DC));
static_assert(int(PluginUnit::Watt) == int(Enums::Units_Watt));
static_assert(int(PluginUnit::WattsPerSquareMetre) == int(Enums::Units_WattsPerSquareMetre));

} // namespace GuiPlugins
} // namespace Victron
