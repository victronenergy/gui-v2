/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_UITESTRESULTUTILS_H
#define VICTRON_GUIV2_UITESTRESULTUTILS_H

#include <QList>
#include <QQmlError>
#include <QSet>
#include <QString>
#include <QStringList>

namespace Victron {
namespace VenusOS {
namespace UiTestResultUtils {

int countNewRuntimeWarningTexts(
		const QStringList &warningTexts,
		QSet<QString> *recordedWarnings,
		QStringList *newWarningTexts = nullptr);

int countNewRuntimeQmlWarnings(
		const QList<QQmlError> &warnings,
		QSet<QString> *recordedWarnings,
		QStringList *newWarningTexts = nullptr);

int exitCodeForFailures(int stepFailures, int runtimeQmlErrors);

}
}
}

#endif // VICTRON_GUIV2_UITESTRESULTUTILS_H
