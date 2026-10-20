/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "pluginaccesslevel.h"

#include "enums.h"

namespace Victron {
namespace GuiPlugins {

// The Plugin* rows pass a PluginAccessLevel straight to the internal rows, which take a
// VenusOS.User_AccessType. If one of these fails, map the values in the rows instead.
using VenusOS::Enums;
static_assert(int(PluginAccessLevel::User) == int(Enums::User_AccessType_User));
static_assert(int(PluginAccessLevel::Installer) == int(Enums::User_AccessType_Installer));
static_assert(int(PluginAccessLevel::SuperUser) == int(Enums::User_AccessType_SuperUser));
static_assert(int(PluginAccessLevel::Service) == int(Enums::User_AccessType_Service));

} // namespace GuiPlugins
} // namespace Victron
