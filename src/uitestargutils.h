/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_UITESTARGUTILS_H
#define VICTRON_GUIV2_UITESTARGUTILS_H

#include <QString>
#include <QStringList>

namespace Victron {
namespace VenusOS {
namespace UiTestArgUtils {

QStringList normalizeUiTestArguments(const QStringList &arguments);
QString parseUiTestValueFromArgs(const QStringList &arguments);

}
}
}

#endif // VICTRON_GUIV2_UITESTARGUTILS_H
