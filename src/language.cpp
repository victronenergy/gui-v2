/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "language.h"
#include "logging.h"

#include <QCoreApplication>
#include <QQmlEngine>
#include <QQmlContext>
#include <QTranslator>

using namespace Victron::VenusOS;

LanguageModel::LanguageModel(QObject *parent)
	: QAbstractListModel(parent)
{
	m_languages.append({ "English", "en", QLocale::English });
	m_languages.append({ "Čeština", "cs", QLocale::Czech });
	m_languages.append({ "Dansk", "da", QLocale::Danish });
	m_languages.append({ "Deutsch", "de", QLocale::German });
	m_languages.append({ "Español", "es", QLocale::Spanish });
	m_languages.append({ "Français", "fr", QLocale::French });
	m_languages.append({ "Italiano", "it", QLocale::Italian });
	m_languages.append({ "Nederlands", "nl", QLocale::Dutch });
	m_languages.append({ "Polski", "pl", QLocale::Polish });
	m_languages.append({ "Русский", "ru", QLocale::Russian });
	m_languages.append({ "Română", "ro", QLocale::Romanian });
	m_languages.append({ "Svenska", "sv", QLocale::Swedish });
#if not defined(VENUS_WEBASSEMBLY_BUILD)
	m_languages.append({ "ไทย", "th", QLocale::Thai }); // crashes WebAssembly.
#endif
	m_languages.append({ "Türkçe", "tr", QLocale::Turkish });
	m_languages.append({ "Українська", "uk", QLocale::Ukrainian });
	m_languages.append({ "中文", "zh", QLocale::Chinese });
	m_languages.append({ "العربية", "ar", QLocale::Arabic });
}

LanguageModel::~LanguageModel()
{
}

int LanguageModel::currentLanguage() const
{
	return m_currentLanguage;
}

void LanguageModel::setCurrentLanguage(int language)
{
	QLocale::Language lang = QLocale::Language(language);
	if (lang != m_currentLanguage) {
		for (int i = 0; i < m_languages.count(); ++i) {
			if (m_languages.at(i).language == lang) {
				m_currentLanguage = lang;
				m_currentIndex = i;
				emit currentIndexChanged();
				emit currentLanguageChanged();
				emit currentDisplayTextChanged();
				break;
			}
		}
	}
}

int LanguageModel::currentIndex() const
{
	return m_currentIndex;
}

QString LanguageModel::currentDisplayText() const
{
	if (m_currentIndex < 0 || m_currentIndex >= m_languages.count()) {
		return QString();
	}
	return m_languages.at(m_currentIndex).name;
}

int LanguageModel::languageAt(int index) const
{
	if (index < 0 || index >= m_languages.count()) {
		return QLocale::AnyLanguage;
	}
	return m_languages.at(index).language;
}

int LanguageModel::rowCount(const QModelIndex &) const
{
	return static_cast<int>(m_languages.count());
}

QVariant LanguageModel::data(const QModelIndex &index, int role) const
{
	if (role != Qt::DisplayRole || index.row() < 0 || index.row() >= m_languages.count()) {
		return QVariant();
	}
	return m_languages.at(index.row()).name;
}


Language* Language::create(QQmlEngine *, QJSEngine *)
{
	static Language* language = new Language(nullptr);
	return language;
}

Language::Language(QQmlEngine* engine) : QObject(nullptr)
{
	/* Load appropriate translations for current locale, e.g. :/i18n/venus-gui-v2_fr.qm */
	if (!installTranslatorForLanguage(QLocale().language())) {
		qCWarning(venusGui) << "Falling back to English as locale catalogue failed to load.";
		installTranslatorForLanguage(QLocale::English); // fallback to default language.
	}
}

QLocale::Language Language::getCurrentLanguage() const
{
	return m_currentLanguage;
}

QString Language::toString(QLocale::Language language) const
{
	return QLocale::languageToString(language);
}

QString Language::toCode(QLocale::Language language) const
{
	return QLocale::languageToCode(language);
}

QLocale::Language Language::fromCode(const QString &code)
{
	return QLocale::codeToLanguage(code);
}

void Language::setCurrentLanguage(QLocale::Language language)
{
	if (language != m_currentLanguage && installTranslatorForLanguage(language)) {
		emit currentLanguageChanged();
	}
}

void Language::setCurrentLanguageCode(const QString &code)
{
	const QLocale::Language lang = QLocale::codeToLanguage(code);
	if (lang != QLocale::AnyLanguage) {
		setCurrentLanguage(lang);
	} else {
		qCWarning(venusGui) << "Unknown language code specified:" << code;
	}
}

bool Language::installTranslatorForLanguage(QLocale::Language language)
{
	const bool alreadyLoaded = m_loadedTranslators.contains(language);
	QTranslator *currTranslator = m_loadedTranslators.value(m_currentLanguage);
	QTranslator *translator = alreadyLoaded ? m_loadedTranslators.value(language) : new QTranslator(this);

	if (!alreadyLoaded) {
		if (translator->load(
				QLocale(language),
				QLatin1String("venus-gui-v2"),
				QLatin1String("_"),
				QLatin1String(":/i18n"))) {
			qCDebug(venusGui) << "Successfully loaded translations for locale" << QLocale(language).name();
			m_loadedTranslators.insert(language, translator);
		} else {
			qCWarning(venusGui) << "Unable to load translations for locale" << QLocale(language).name();
			translator->deleteLater();
			if (m_loadedTranslators.value(language) == translator) {
				m_loadedTranslators.remove(language);
			}
			return false;
		}
	}

	if (!QCoreApplication::installTranslator(translator)) {
		qCWarning(venusGui) << "Unable to install translator for locale" << QLocale(language).name();
		translator->deleteLater();
		if (m_loadedTranslators.value(language) == translator) {
			m_loadedTranslators.remove(language);
		}
		return false;
	}

	if (currTranslator) {
		if (!QCoreApplication::removeTranslator(currTranslator)) {
			qCWarning(venusGui) << "Unable to remove old translator for locale" << QLocale(language).name();
		}
	}

	m_currentLanguage = language;

	return true;
}

void Language::retranslate()
{
	QQmlEngine* engine = nullptr;
	QQmlContext* context = QQmlEngine::contextForObject(this);

	if (context) {
		engine = QQmlEngine::contextForObject(this)->engine();
	}

	if (engine) {
		engine->retranslate();
	} else {
		qCWarning(venusGui) << "Unable to retranslate";
	}
}

