#include "language.h"
#include "logging.h"

#include <QCoreApplication>
#include <QLocale>
#include <QTranslator>

using namespace Victron::VenusOS;

Language::Language(QQmlEngine *engine, QObject *parent)
	: QObject(parent)
	, m_engine(engine)
	, m_currentLanguage("eng")
{

}

QString Language::getCurrentLanguage() const
{
	return m_currentLanguage;
}

void Language::setCurrentLanguage(const QString &language)
{
	if (language != m_currentLanguage)
	{
		m_currentLanguage = language;
		emit currentLanguageChanged();

		QTranslator translator;
		if (translator.load(
			QLocale(language == QStringLiteral("eng") ? QLocale::English : QLocale::French),
			QLatin1String("venus-gui-v2"),
			QLatin1String("_"),
			QLatin1String(":/i18n"))) {
			QCoreApplication::installTranslator(&translator);
			qCDebug(venusGui) << "Successfully loaded translations for locale" << QLocale().name();
		} else {
			qCWarning(venusGui) << "Unable to load translations for locale" << QLocale().name();
		}

		m_engine->retranslate();
	}
}
