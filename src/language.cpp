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
#include <QFont>
#include <QFontDatabase>
#include <QRawFont>
#include <QFile>

using namespace Victron::VenusOS;

namespace {

QUrl fontUrlForLanguage(QLocale::Language language, const QString &urlPrefix = QString())
{
	static const QHash<QLocale::Language, QString> fontFileNames = {
		{ QLocale::Arabic, QStringLiteral("DejaVuSans.ttf") },
		{ QLocale::Chinese, QStringLiteral("DroidSansFallback.ttf") },
		{ QLocale::Japanese, QStringLiteral("DroidSansFallback.ttf") },
		{ QLocale::Thai, QStringLiteral("NotoSansThai.ttf") },
	};

	static const QUrl defaultFontUrl = QUrl("qrc:/fonts/Roboto-Regular.ttf");

#if defined(VENUS_WEBASSEMBLY_BUILD)
	// On wasm, load the custom font files from relative path /fonts/<fontfile>
	const QString fileName = fontFileNames.value(language);
	if (!fileName.isEmpty()) {
		return QUrl(QStringLiteral("%1%2").arg(urlPrefix, fileName));
	}
#elif not defined(VENUS_DESKTOP_BUILD)
	// On device, look for the system-installed font files.
	const QString fileName = fontFileNames.value(language);
	if (!fileName.isEmpty()) {
		return QUrl::fromLocalFile("/usr/lib/fonts/" + fileName);
	}
#else
	Q_UNUSED(language);
#endif

	// Use the default font on other platforms.
	return defaultFontUrl;
}

QFontDatabase::WritingSystem writingSystemForLanguage(QLocale::Language language)
{
	switch (QLocale(language).script()) {
	case QLocale::LatinScript: return QFontDatabase::Latin;
	case QLocale::CyrillicScript: return QFontDatabase::Cyrillic;
	case QLocale::GreekScript: return QFontDatabase::Greek;
	case QLocale::ArabicScript: return QFontDatabase::Arabic;
	case QLocale::HebrewScript: return QFontDatabase::Hebrew;
	case QLocale::ThaiScript: return QFontDatabase::Thai;
	case QLocale::SimplifiedHanScript: return QFontDatabase::SimplifiedChinese;
	case QLocale::TraditionalHanScript: return QFontDatabase::TraditionalChinese;
	case QLocale::JapaneseScript: return QFontDatabase::Japanese;
	case QLocale::KoreanScript: return QFontDatabase::Korean;
	default: return QFontDatabase::Any;
	}
}

// A selection of letters other than A-Z and a-z which are commonly
// required in the language. Used to decide whether a font should be
// treated as supporting that language. Not a complete alphabet, and
// it does not have to be updated when translations change.
//
// English returns none because it needs no such letters.
// Russian, Ukrainian, Arabic, Chinese, Japanese and Thai return none
// because this table only lists Latin letters.
QList<char32_t> sampleCharacters(QLocale::Language language)
{
	switch (language) {
	case QLocale::Afrikaans:
		return { 0x00E8, 0x00EA, 0x00EB, 0x00EF, 0x00F3, 0x00FB };
	case QLocale::Czech:
		return { 0x00E1, 0x00E9, 0x00ED, 0x00F3, 0x00FA, 0x00FD, 0x010D, 0x010F, 0x011B, 0x0148, 0x0159, 0x0161,
				0x0165, 0x016F, 0x017E, 0x00C1, 0x00C9, 0x00CD, 0x00DA, 0x00DD,
				0x010C, 0x011A, 0x0158, 0x0160, 0x017D };
	case QLocale::Danish:
		return { 0x00E5, 0x00E6, 0x00E9, 0x00F8, 0x00C5, 0x00C6, 0x00D8 };
	case QLocale::German:
		return { 0x00DF, 0x00E4, 0x00F6, 0x00FC, 0x00C4, 0x00D6, 0x00DC };
	case QLocale::Spanish:
		return { 0x00AA, 0x00BA, 0x00E1, 0x00E9, 0x00ED, 0x00F1, 0x00F3, 0x00FA, 0x00C1, 0x00CD, 0x00D3, 0x00DA };
	case QLocale::French:
		return { 0x00E0, 0x00E2, 0x00E7, 0x00E8, 0x00E9, 0x00EA, 0x00EB, 0x00EE, 0x00EF, 0x00F4, 0x00F9, 0x00FB,
				0x0153, 0x00C0, 0x00C9, 0x00CA };
	case QLocale::Italian:
		return { 0x00E0, 0x00E8, 0x00E9, 0x00EC, 0x00F2, 0x00F9, 0x00C8 };
	case QLocale::Dutch:
		return { 0x00E8, 0x00E9, 0x00EB, 0x00EF, 0x00F3, 0x00FC };
	case QLocale::Polish:
		return { 0x00F3, 0x0105, 0x0107, 0x0119, 0x0142, 0x0144, 0x015B, 0x017A, 0x017C, 0x0141, 0x015A, 0x0179,
				0x017B };
	case QLocale::Portuguese:
		return { 0x00BA, 0x00E0, 0x00E1, 0x00E2, 0x00E3, 0x00E7, 0x00E8, 0x00E9, 0x00EA, 0x00ED, 0x00F3, 0x00F5,
				0x00FA, 0x00C1, 0x00C3, 0x00C7, 0x00C9, 0x00CD, 0x00D3, 0x00DA };
	case QLocale::Romanian:
		return { 0x00E2, 0x00EE, 0x0103, 0x015F, 0x0163, 0x0219, 0x021B, 0x00CE, 0x0162, 0x0218, 0x021A };
	case QLocale::Swedish:
		return { 0x00E4, 0x00E5, 0x00F6, 0x00C4, 0x00C5, 0x00D6 };
	case QLocale::Turkish:
		return { 0x00E7, 0x00F6, 0x00FC, 0x011F, 0x0131, 0x015F, 0x00C7, 0x00D6,
				0x00DC, 0x011E, 0x0130, 0x015E };
	default:
		return {};
	}
}

bool isLanguageRenderingSupported(QLocale::Language language)
{
#if defined(VENUS_WEBASSEMBLY_BUILD)
	// On wasm, the scripts for these languages cannot be rendered by an available font.
	switch (language) {
	default:
		break;
	}
#else
	Q_UNUSED(language);
#endif
	return true;
}

}


LanguageModel::LanguageModel(QObject *parent)
	: QAbstractListModel(parent)
{
	m_roleNames[Qt::DisplayRole] = "display";
	m_roleNames[FontFileUrlRole] = "fontFileUrl";
	m_roleNames[FontFamilyRole] = "fontFamily";

	addLanguage("English", "en", QLocale::English);
	addLanguage("Afrikaans", "af", QLocale::Afrikaans);
	addLanguage("Čeština", "cs", QLocale::Czech);
	addLanguage("Dansk", "da", QLocale::Danish);
	addLanguage("Deutsch", "de", QLocale::German);
	addLanguage("Español", "es", QLocale::Spanish);
	addLanguage("Français", "fr", QLocale::French);
	addLanguage("Italiano", "it", QLocale::Italian);
	addLanguage("日本語", "ja", QLocale::Japanese);
	addLanguage("Nederlands", "nl", QLocale::Dutch);
	addLanguage("Polski", "pl", QLocale::Polish);
	addLanguage("Português", "pt", QLocale::Portuguese);
	addLanguage("Русский", "ru", QLocale::Russian);
	addLanguage("Română", "ro", QLocale::Romanian);
	addLanguage("Svenska", "sv", QLocale::Swedish);
	addLanguage("ไทย", "th", QLocale::Thai);
	addLanguage("Türkçe", "tr", QLocale::Turkish);
	addLanguage("Українська", "uk", QLocale::Ukrainian);
	addLanguage("中文", "zh_CN", QLocale::Chinese);
	addLanguage("العربية", "ar", QLocale::Arabic);

	setCurrentLanguage(Language::create()->getCurrentLanguage());
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
	const LanguageData &data = m_languages.at(m_currentIndex);
	return languageDisplayName(data.language, data.name);
}

int LanguageModel::languageAt(int index) const
{
	if (index < 0 || index >= m_languages.count()) {
		return QLocale::AnyLanguage;
	}
	return m_languages.at(index).language;
}

void LanguageModel::setFontFamily(const QUrl &fontUrl, const QString &fontFamily)
{
	for (int i = 0; i < m_languages.count(); ++i) {
		if (m_languages.at(i).fontFileUrl == fontUrl) {
			m_languages[i].fontFamily = fontFamily;
			static const QList<int> roles = { FontFamilyRole };
			emit dataChanged(createIndex(i, 0), createIndex(i, 0), roles);
			break;
		}
	}
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
		return languageDisplayName(data.language, data.name);
	case FontFileUrlRole:
		return data.fontFileUrl;
	case FontFamilyRole:
		return data.fontFamily;
	default:
		return QVariant();
	}
}

void LanguageModel::addLanguage(const QString &name, const QString &code, QLocale::Language language)
{
	m_languages.append({name, code, fontUrlForLanguage(language, Language::create()->fontUrlPrefix()), QString(), language });
}

QString LanguageModel::languageDisplayName(QLocale::Language language, const QString &name) const
{
	return name;
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

Language::Language(QQmlEngine*) : QObject(nullptr)
{
}

void Language::init() // call this after setting the fontUrlPrefix if required.
{
	// Install English as the default fallback catalogue.
	installTranslatorForLanguage(QLocale::English);

	// Load appropriate translations for current locale, e.g. :/i18n/venus-gui-v2_fr.qm
	if (QLocale().language() != QLocale::English
			 && !installTranslatorForLanguage(QLocale().language())) {
		qCWarning(venusGui) << "Falling back to English as locale catalogue failed to load.";
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

bool Language::setCurrentLanguage(QLocale::Language language)
{
	if (language != m_currentLanguage && installTranslatorForLanguage(language)) {
		emit currentLanguageChanged();
		emit fontFileUrlChanged();
		return true;
	} else {
		emit languageChangeFailed();
		return false;
	}
}

QString Language::getCurrentLocaleName() const
{
	return QLocale(m_currentLanguage).name();
}

QUrl Language::fontFileUrl() const
{
	return m_fontFileUrl;
}

bool Language::fontFamilyCovers(const QString &family, QLocale::Language language)
{
	const QFontDatabase::WritingSystem writingSystem = writingSystemForLanguage(language);
	if (writingSystem != QFontDatabase::Any
			&& !QFontDatabase::writingSystems(family).contains(writingSystem)) {
		return false;
	}
	const QList<char32_t> samples = sampleCharacters(language);
	if (!samples.isEmpty()) {
		const QRawFont rawFont = QRawFont::fromFont(QFont(family));
		for (char32_t c : samples) {
			if (!rawFont.supportsCharacter(c)) {
				return false;
			}
		}
	}
	return true;
}

QString Language::fontUrlPrefix() const
{
	return m_fontUrlPrefix;
}

void Language::setFontUrlPrefix(const QString &prefix)
{
	if (m_fontUrlPrefix != prefix) {
		m_fontUrlPrefix = prefix;
		emit fontUrlPrefixChanged();
	}
}

bool Language::setCurrentLanguageCode(const QString &code)
{
	const QLocale::Language lang = QLocale::codeToLanguage(code);
	if (lang != QLocale::AnyLanguage) {
		return setCurrentLanguage(lang);
	} else {
		qCWarning(venusGui) << "Unknown language code specified:" << code;
		return false;
	}
}

bool Language::installTranslatorForLanguage(QLocale::Language language)
{
#if defined(VENUS_WEBASSEMBLY_BUILD)
	if (!isLanguageRenderingSupported(language)) {
		qCWarning(venusGui) << "Cannot render language" << QLocale(language).name()
				<< "with the default font on WASM";
		return false;
	}
#endif

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

	// English is the fallback catalogue, so we have special handling for it:
	// ensure we install it the first time it is loaded, but never after that.
	// All other languages need to be installed, as we will remove them on language change.
	if ((language != QLocale::English || !alreadyLoaded)
			&& !QCoreApplication::installTranslator(translator)) {
		qCWarning(venusGui) << "Unable to install translator for locale" << QLocale(language).name();
		translator->deleteLater();
		if (m_loadedTranslators.value(language) == translator) {
			m_loadedTranslators.remove(language);
		}
		return false;
	}

	// On language change, uninstall the old catalogue (unless it was the fallback English one).
	if (m_currentLanguage != QLocale::English && currTranslator) {
		if (!QCoreApplication::removeTranslator(currTranslator)) {
			qCWarning(venusGui) << "Unable to remove old translator for locale" << QLocale(language).name();
		}
	}

	m_currentLanguage = language;
	m_fontFileUrl = fontUrlForLanguage(language, fontUrlPrefix());

	return true;
}
