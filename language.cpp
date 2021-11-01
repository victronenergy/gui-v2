/*
** Copyright (C) 2021 Victron Energy B.V.
*/

#include "language.h"
#include "logging.h"

#include <QCoreApplication>
#include <QQmlEngine>
#include <QTranslator>

using namespace Victron::VenusOS;

Language::Language(QQmlEngine* engine) : QObject(nullptr),
	m_qmlEngine(engine)
{
}

QLocale::Language Language::getCurrentLanguage() const
{
	return m_currentLanguage;
}

QString Language::toString(QLocale::Language language) const
{
	return QVariant::fromValue(language).toString();
}

void Language::setCurrentLanguage(QLocale::Language language)
{
	if (language != m_currentLanguage) {
		QTranslator translator;
		if (translator.load(
				QLocale(language),
				QLatin1String("venus-gui-v2"),
				QLatin1String("_"),
				QLatin1String(":/i18n"))) {
			QCoreApplication::installTranslator(&translator);
			qCDebug(venusGui) << "Successfully loaded translations for locale" << QLocale(language).name();
			if (m_qmlEngine) {
				m_currentLanguage = language;
				m_qmlEngine->retranslate();
				emit currentLanguageChanged();
			} else {
				qCWarning(venusGui) << "Unable to retranslate";
			}
		} else {
			qCWarning(venusGui) << "Unable to load translations for locale" << QLocale().name();
		}
	}
}
