/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "uitestresultutils.h"

int Victron::VenusOS::UiTestResultUtils::countNewRuntimeWarningTexts(
		const QStringList &warningTexts,
		QSet<QString> *recordedWarnings,
		QStringList *newWarningTexts)
{
	if (!recordedWarnings) {
		return 0;
	}

	int newCount = 0;
	for (const QString &warningTextRaw : warningTexts) {
		const QString warningText = warningTextRaw.trimmed();
		if (warningText.isEmpty() || recordedWarnings->contains(warningText)) {
			continue;
		}
		recordedWarnings->insert(warningText);
		if (newWarningTexts) {
			newWarningTexts->append(warningText);
		}
		++newCount;
	}
	return newCount;
}

int Victron::VenusOS::UiTestResultUtils::countNewRuntimeQmlWarnings(
		const QList<QQmlError> &warnings,
		QSet<QString> *recordedWarnings,
		QStringList *newWarningTexts)
{
	QStringList warningTexts;
	warningTexts.reserve(warnings.count());
	for (const QQmlError &warning : warnings) {
		warningTexts.append(warning.toString());
	}
	return countNewRuntimeWarningTexts(warningTexts, recordedWarnings, newWarningTexts);
}

int Victron::VenusOS::UiTestResultUtils::exitCodeForFailures(int stepFailures, int runtimeQmlErrors)
{
	return (stepFailures + runtimeQmlErrors) > 0 ? 1 : 0;
}
