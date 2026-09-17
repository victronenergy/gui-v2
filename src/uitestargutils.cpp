/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "uitestargutils.h"

QStringList Victron::VenusOS::UiTestArgUtils::normalizeUiTestArguments(const QStringList &arguments)
{
	QStringList normalized;
	normalized.reserve(arguments.count());

	for (int i = 0; i < arguments.count(); ++i) {
		const QString &arg = arguments.at(i);
		if ((arg == QStringLiteral("--ui-test") || arg == QStringLiteral("-uit"))
				&& (i + 1) < arguments.count()) {
			const QString &value = arguments.at(i + 1);
			if (value.startsWith('/')) {
				normalized << QStringLiteral("%1=%2").arg(arg, value);
				++i;
				continue;
			}
		}
		normalized << arg;
	}

	return normalized;
}

QString Victron::VenusOS::UiTestArgUtils::parseUiTestValueFromArgs(const QStringList &arguments)
{
	for (int i = 0; i < arguments.count(); ++i) {
		const QString &arg = arguments.at(i);
		if (arg == QStringLiteral("--ui-test") || arg == QStringLiteral("-uit")) {
			return (i + 1) < arguments.count() ? arguments.at(i + 1) : QString();
		}
		if (arg.startsWith(QStringLiteral("--ui-test="))) {
			return arg.mid(QStringLiteral("--ui-test=").length());
		}
		if (arg.startsWith(QStringLiteral("-uit="))) {
			return arg.mid(QStringLiteral("-uit=").length());
		}
	}
	return QString();
}
