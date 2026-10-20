/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIPLUGINS_PLUGINACCESSLEVEL_H
#define VICTRON_GUIPLUGINS_PLUGINACCESSLEVEL_H

#include <QObject>
#include <qqmlintegration.h>

namespace Victron {
namespace GuiPlugins {

/*
	The user access levels, for the showAccessLevel and writeAccessLevel properties of the
	Plugin* list items. In QML: PluginAccessLevel.User, PluginAccessLevel.Installer, and so on.

	Plugins use these instead of the VenusOS.User_AccessType_* values, which are not part of the
	plugin API. The values are the same, so the list items pass them straight to the internal
	list items; pluginaccesslevel.cpp checks that at build time. The values are given explicitly,
	so that a change to the VenusOS values cannot change them.
*/
namespace PluginAccessLevel {
Q_NAMESPACE
QML_ELEMENT

enum Level {
	User = 0,
	Installer = 1,
	SuperUser = 2,
	Service = 3
};
Q_ENUM_NS(Level)

} // namespace PluginAccessLevel

} // namespace GuiPlugins
} // namespace Victron

#endif // VICTRON_GUIPLUGINS_PLUGINACCESSLEVEL_H
