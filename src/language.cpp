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
#include <QFontDatabase>
#include <QFile>

using namespace Victron::VenusOS;

namespace {

QString defaultFontFileName()
{
	return QStringLiteral(":/fonts/MuseoSans-500.otf");
}

QString fontFileNameForLanguage(QLocale::Language language)
{
	QString fileName;

	static const QHash<QLocale::Language, QString> fontFileNames = {
		{ QLocale::Arabic, QStringLiteral("DejaVuSans.ttf") },
		{ QLocale::Chinese, QStringLiteral("DroidSansFallback.ttf") },
		{ QLocale::Thai, QStringLiteral("NotoSansThai.ttf") },
	};

#if defined(VENUS_WEBASSEMBLY_BUILD)
	// On wasm, the root dir contains symlinks to the required font files.
	fileName = fontFileNames.value(language);
	if (!fileName.isEmpty()) {
		fileName = "/" + fileName;
	}
#elif not defined(VENUS_DESKTOP_BUILD)
	// On device, look for the system-installed font files.
	fileName = fontFileNames.value(language);
	if (!fileName.isEmpty()) {
		fileName = "/usr/lib/fonts/" + fileName;
	}
#else
	// On other platforms, use the default font for all languages.
	Q_UNUSED(language)
	fileName = defaultFontFileName();
#endif

	return !fileName.isEmpty() && QFile::exists(fileName) ? fileName : defaultFontFileName();
}

QUrl filePathToUrl(const QString &path)
{
	if (path.isEmpty()) {
		return QUrl();
	}

	if (path.startsWith(':')) {
		// Convert to QML-friendly "qrc:/" resource path.
		return QUrl(QStringLiteral("qrc%1").arg(path));
	}

	return QUrl::fromLocalFile(path);
}

QString fontFamilyForLanguage(QLocale::Language language)
{
	static QHash<QString, int> fontIds;

	const QString fontFileName = fontFileNameForLanguage(language);
	if (!fontIds.contains(fontFileName)) {
		fontIds.insert(fontFileName, QFontDatabase::addApplicationFont(fontFileName));
	}

	int fontId = fontIds.value(fontFileName, -1);
	if (fontId < 0) {
		qWarning() << "Fall back to default font, cannot load" << fontFileName << "for locale" << QLocale(language).name();
		if (!fontIds.contains(defaultFontFileName())) {
			fontIds.insert(fontFileName, QFontDatabase::addApplicationFont(defaultFontFileName()));
		}
		fontId = fontIds.value(defaultFontFileName(), -1);
		if (fontId < 0) {
			qWarning() << "Unable to fall back to default font!";
			return QString();
		}
	}

	return QFontDatabase::applicationFontFamilies(fontId).value(0);
}

}


LanguageModel::LanguageModel(QObject *parent)
	: QAbstractListModel(parent)
{
	m_roleNames[Qt::DisplayRole] = "display";
	m_roleNames[FontFileUrlRole] = "fontFileUrl";
	m_roleNames[FontFamilyRole] = "fontFamily";

	addLanguage("English", "en", QLocale::English);
	addLanguage("Čeština", "cs", QLocale::Czech);
	addLanguage("Dansk", "da", QLocale::Danish);
	addLanguage("Deutsch", "de", QLocale::German);
	addLanguage("Español", "es", QLocale::Spanish);
	addLanguage("Français", "fr", QLocale::French);
	addLanguage("Italiano", "it", QLocale::Italian);
	addLanguage("Nederlands", "nl", QLocale::Dutch);
	addLanguage("Polski", "pl", QLocale::Polish);
	addLanguage("Русский", "ru", QLocale::Russian);
	addLanguage("Română", "ro", QLocale::Romanian);
	addLanguage("Svenska", "sv", QLocale::Swedish);
	addLanguage("ไทย", "th", QLocale::Thai);
	addLanguage("Türkçe", "tr", QLocale::Turkish);
	addLanguage("Українська", "uk", QLocale::Ukrainian);
	addLanguage("中文", "zh", QLocale::Chinese);
	addLanguage("العربية", "ar", QLocale::Arabic);
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
	if (index.row() < 0 || index.row() >= m_languages.count()) {
		return QVariant();
	}

	const LanguageData &data = m_languages.at(index.row());

	switch (role) {
	case Qt::DisplayRole:
		return data.name;
	case FontFileUrlRole:
		return data.fontFileUrl;
	case FontFamilyRole:
		return data.fontFamily;
	default:
		return QVariant();
	}
}

void LanguageModel::addLanguage(const QString &name, const QString &code, const QLocale::Language &language)
{
	m_languages.append({name, code, filePathToUrl(fontFileNameForLanguage(language)), fontFamilyForLanguage(language), language });
}

QHash<int, QByteArray> LanguageModel::roleNames() const
{
	return m_roleNames;
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
		emit fontFileUrlChanged();
		emit fontFamilyChanged();
	}
}

QUrl Language::fontFileUrl() const
{
	return m_fontFileUrl;
}

QString Language::fontFamily() const
{
	return m_fontFamily;
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
	m_fontFileUrl = filePathToUrl(fontFileNameForLanguage(language));
	m_fontFamily = fontFamilyForLanguage(language);

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
