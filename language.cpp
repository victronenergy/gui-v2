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
		const bool alreadyLoaded = m_loadedTranslators.contains(language);
		QTranslator *currTranslator = m_loadedTranslators.value(m_currentLanguage);
		QTranslator *translator = alreadyLoaded
				? m_loadedTranslators.value(language)
				: new QTranslator(this);
		if (!alreadyLoaded) {
			if (translator->load(
					QLocale(language),
					QLatin1String("venus-gui-v2"),
					QLatin1String("_"),
					QLatin1String(":/i18n"))) {
				qCDebug(venusGui) << "Successfully loaded translations for locale" << QLocale(language).name();
			} else {
				qCWarning(venusGui) << "Unable to load translations for locale" << QLocale().name();
				translator->deleteLater();
				return;
			}
		}

		QCoreApplication::installTranslator(translator);
		if (currTranslator) {
			QCoreApplication::removeTranslator(currTranslator);
		}
		m_currentLanguage = language;

		if (m_qmlEngine) {
			m_qmlEngine->retranslate();
			emit currentLanguageChanged();
		} else {
			qCWarning(venusGui) << "Unable to retranslate";
		}
	}
}
