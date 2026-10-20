/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include <QtQuickTest/quicktest.h>
#include <QQmlEngine>
#include <QQmlContext>
#include <QLoggingCategory>
#include <QFile>
#include <QFontDatabase>
#include <QPointer>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QtEndian>

#include "testutils.h"
#include "branding.h"
#include "colorderivation.h"
#include "guiplugins.h"
#include "language.h"
#include "themeobjects.h"

using Victron::BrandingData;
using Victron::VenusOS::GuiPluginLoader;
using Victron::VenusOS::Theme;
namespace ColorDerivation = Victron::VenusOS::ColorDerivation;

namespace {

const QString TestPluginName = QStringLiteral("TestPlugin");
const QString LightModeBackgroundFactor = QStringLiteral("light_mode_background_factor");
const QString FontFiles = QStringLiteral("font_files");
const QString FontFamily = QStringLiteral("font_family");
const QString QuantityFontFamily = QStringLiteral("quantity_font_family");
const QString SplashLogoIcon = QStringLiteral("splash_logo_icon");
const QString SplashLogoText = QStringLiteral("splash_logo_text");
const QString SplashLogoIconPreserveColors = QStringLiteral("splash_logo_icon_preserve_colors");
const QString SplashLogoTextPreserveColors = QStringLiteral("splash_logo_text_preserve_colors");
const QString SplashGaugeAnimation = QStringLiteral("splash_gauge_animation");
const QString SplashGaugeAnimationLight = QStringLiteral("splash_gauge_animation_light");

// Only the properties that are set appear in the map.
QVariantMap toVariantMap(const BrandingData &data)
{
	QVariantMap map;
	for (int i = 0; i < BrandingData::ColorCount; ++i) {
		if (data.colors[i].has_value()) {
			map.insert(BrandingData::colorPropertyName(static_cast<BrandingData::Color>(i)), *data.colors[i]);
		}
	}
	if (data.lightModeBackgroundFactor.has_value()) {
		map.insert(LightModeBackgroundFactor, *data.lightModeBackgroundFactor);
	}
	if (data.fontFiles.has_value()) {
		map.insert(FontFiles, *data.fontFiles);
	}
	if (data.fontFamily.has_value()) {
		map.insert(FontFamily, *data.fontFamily);
	}
	if (data.quantityFontFamily.has_value()) {
		map.insert(QuantityFontFamily, *data.quantityFontFamily);
	}
	if (data.splashLogoIcon.has_value()) {
		map.insert(SplashLogoIcon, data.splashLogoIcon->toString());
	}
	if (data.splashLogoText.has_value()) {
		map.insert(SplashLogoText, data.splashLogoText->toString());
	}
	if (data.splashLogoIconPreserveColors.has_value()) {
		map.insert(SplashLogoIconPreserveColors, *data.splashLogoIconPreserveColors);
	}
	if (data.splashLogoTextPreserveColors.has_value()) {
		map.insert(SplashLogoTextPreserveColors, *data.splashLogoTextPreserveColors);
	}
	if (data.splashGaugeAnimation.has_value()) {
		map.insert(SplashGaugeAnimation, data.splashGaugeAnimation->toString());
	}
	if (data.splashGaugeAnimationLight.has_value()) {
		map.insert(SplashGaugeAnimationLight, data.splashGaugeAnimationLight->toString());
	}
	return map;
}

BrandingData fromVariantMap(const QVariantMap &map)
{
	BrandingData data;
	for (int i = 0; i < BrandingData::ColorCount; ++i) {
		const QString name = BrandingData::colorPropertyName(static_cast<BrandingData::Color>(i));
		if (map.contains(name)) {
			data.colors[i] = QColor::fromString(map.value(name).toString());
		}
	}
	if (map.contains(LightModeBackgroundFactor)) {
		data.lightModeBackgroundFactor = map.value(LightModeBackgroundFactor).toDouble();
	}
	if (map.contains(FontFiles)) {
		data.fontFiles = map.value(FontFiles).toStringList();
	}
	if (map.contains(FontFamily)) {
		data.fontFamily = map.value(FontFamily).toString();
	}
	if (map.contains(QuantityFontFamily)) {
		data.quantityFontFamily = map.value(QuantityFontFamily).toString();
	}
	if (map.contains(SplashLogoIcon)) {
		data.splashLogoIcon = QUrl(map.value(SplashLogoIcon).toString());
	}
	if (map.contains(SplashLogoText)) {
		data.splashLogoText = QUrl(map.value(SplashLogoText).toString());
	}
	if (map.contains(SplashLogoIconPreserveColors)) {
		data.splashLogoIconPreserveColors = map.value(SplashLogoIconPreserveColors).toBool();
	}
	if (map.contains(SplashLogoTextPreserveColors)) {
		data.splashLogoTextPreserveColors = map.value(SplashLogoTextPreserveColors).toBool();
	}
	if (map.contains(SplashGaugeAnimation)) {
		data.splashGaugeAnimation = QUrl(map.value(SplashGaugeAnimation).toString());
	}
	if (map.contains(SplashGaugeAnimationLight)) {
		data.splashGaugeAnimationLight = QUrl(map.value(SplashGaugeAnimationLight).toString());
	}
	data.pluginName = map.value(QStringLiteral("pluginName")).toString();
	return data;
}

QVariantMap brandingColorMap(const ColorDerivation::BrandingColors &colors)
{
	QVariantMap map;
	for (int i = 0; i < BrandingData::ColorCount; ++i) {
		map.insert(BrandingData::colorPropertyName(static_cast<BrandingData::Color>(i)), colors[i].name());
	}
	return map;
}

QByteArray builtInFontData()
{
	QFile file(QStringLiteral(":/fonts/Roboto-Regular.ttf"));
	return file.open(QIODevice::ReadOnly) ? file.readAll() : QByteArray();
}

// A copy of the built-in font with "BrandF" instead of "Roboto" in its names, so that a test can
// tell a family that a plugin registers from the built-in family.
QByteArray brandFontData()
{
	QByteArray font = builtInFontData();
	if (font.isEmpty()) {
		return QByteArray();
	}
	// The table directory starts at offset 12, with one 16-byte record (tag, checksum, offset, length) per table.
	const int tableCount = qFromBigEndian<quint16>(font.constData() + 4);
	for (int i = 0; i < tableCount; ++i) {
		const char *record = font.constData() + 12 + 16 * i;
		if (QByteArrayView(record, 4) == QByteArrayView("name")) {
			const qsizetype offset = qFromBigEndian<quint32>(record + 8);
			const qsizetype length = qFromBigEndian<quint32>(record + 12);
			// Same-length replacements keep the string offsets in the table valid.
			QByteArray names = font.mid(offset, length);
			names.replace(QByteArray("\0R\0o\0b\0o\0t\0o", 12), QByteArray("\0B\0r\0a\0n\0d\0F", 12));
			names.replace("Roboto", "BrandF");
			font.replace(offset, length, names);
			return font;
		}
	}
	return QByteArray();
}

// Format 4 cmap: printable ASCII, plus the Latin-1 letters fontconfig requires
// before it will call a font English. ASCII uses Roboto's idDelta so those
// letters map to real glyphs. Each extra letter maps to glyph 37, which is
// also a real glyph. Those letters are not enough for the other Latin languages.
QByteArray basicLatinCmap()
{
	// U+00C0, U+00C7-U+00CB, U+00CF, U+00D1, U+00D4, U+00D6,
	// U+00E0, U+00E7-U+00EB, U+00EF, U+00F1, U+00F4, U+00F6.
	const quint16 englishOrthography[] = {
		0x00C0,
		0x00C7, 0x00C8, 0x00C9, 0x00CA, 0x00CB,
		0x00CF,
		0x00D1,
		0x00D4,
		0x00D6,
		0x00E0,
		0x00E7, 0x00E8, 0x00E9, 0x00EA, 0x00EB,
		0x00EF,
		0x00F1,
		0x00F4,
		0x00F6,
	};
	const int extraCount = int(sizeof englishOrthography / sizeof englishOrthography[0]);
	const int segCount = extraCount + 2;
	static_assert(sizeof englishOrthography / sizeof englishOrthography[0] + 2 <= 24);

	struct Segment {
		quint16 start;
		quint16 end;
		qint16 idDelta;
	};
	Segment segments[24];
	segments[0] = { 0x0020, 0x007E, -28 };
	for (int i = 0; i < extraCount; ++i) {
		const quint16 code = englishOrthography[i];
		segments[i + 1] = { code, code, qint16(37 - int(code)) };
	}
	segments[segCount - 1] = { 0xFFFF, 0xFFFF, 1 };

	const int platformCount = 2;
	const int headerSize = 4 + 8 * platformCount;
	const int subtableSize = 16 + 8 * segCount;
	QByteArray table(headerSize + subtableSize, '\0');
	const auto write16 = [&table](int offset, quint16 value) {
		qToBigEndian(value, table.data() + offset);
	};
	write16(2, quint16(platformCount));
	// Platform 0 encoding 3, then platform 3 encoding 1. Both use one subtable.
	write16(4, 0);
	write16(6, 3);
	qToBigEndian(quint32(headerSize), table.data() + 8);
	write16(12, 3);
	write16(14, 1);
	qToBigEndian(quint32(headerSize), table.data() + 16);

	int entrySelector = 0;
	while ((1 << (entrySelector + 1)) <= segCount) {
		++entrySelector;
	}
	const int searchRange = 2 * (1 << entrySelector);
	const int rangeShift = 2 * segCount - searchRange;
	const int sub = headerSize;
	write16(sub + 0, 4);
	write16(sub + 2, quint16(subtableSize));
	write16(sub + 6, quint16(segCount * 2));
	write16(sub + 8, quint16(searchRange));
	write16(sub + 10, quint16(entrySelector));
	write16(sub + 12, quint16(rangeShift));

	const int endAt = sub + 14;
	const int startAt = endAt + 2 * segCount + 2;
	const int deltaAt = startAt + 2 * segCount;
	for (int i = 0; i < segCount; ++i) {
		write16(endAt + 2 * i, segments[i].end);
		write16(startAt + 2 * i, segments[i].start);
		write16(deltaAt + 2 * i, quint16(segments[i].idDelta));
	}
	return table;
}

bool replaceFontTable(QByteArray *font, QByteArrayView tag, const QByteArray &table)
{
	if (font->size() < 12) {
		return false;
	}
	const int tableCount = qFromBigEndian<quint16>(font->constData() + 4);
	for (int i = 0; i < tableCount; ++i) {
		char *record = font->data() + 12 + 16 * i;
		if (QByteArrayView(record, 4) != tag) {
			continue;
		}
		const qsizetype offset = qFromBigEndian<quint32>(record + 8);
		const qsizetype length = qFromBigEndian<quint32>(record + 12);
		if (table.size() > length || offset + table.size() > font->size()) {
			return false;
		}
		font->replace(offset, table.size(), table);
		qToBigEndian(static_cast<quint32>(table.size()), record + 12);
		return true;
	}
	return false;
}

// A copy of the built-in font named "AsciiF". Its character map has printable ASCII
// and the Latin-1 letters fontconfig requires before it calls a font English.
// Same-length name replacement as brandFontData().
QByteArray asciiFontData()
{
	QByteArray font = builtInFontData();
	if (font.isEmpty() || font.size() < 12) {
		return QByteArray();
	}
	const int tableCount = qFromBigEndian<quint16>(font.constData() + 4);
	bool renamed = false;
	for (int i = 0; i < tableCount; ++i) {
		const char *record = font.constData() + 12 + 16 * i;
		if (QByteArrayView(record, 4) != QByteArrayView("name")) {
			continue;
		}
		const qsizetype offset = qFromBigEndian<quint32>(record + 8);
		const qsizetype length = qFromBigEndian<quint32>(record + 12);
		QByteArray names = font.mid(offset, length);
		names.replace(QByteArray("\0R\0o\0b\0o\0t\0o", 12), QByteArray("\0A\0s\0c\0i\0i\0F", 12));
		names.replace("Roboto", "AsciiF");
		font.replace(offset, length, names);
		renamed = true;
		break;
	}
	if (!renamed || !replaceFontTable(&font, QByteArrayView("cmap"), basicLatinCmap())) {
		return QByteArray();
	}
	return font;
}

class WarningCapture
{
public:
	QStringList warnings;
	QtMessageHandler previous = nullptr;
	static WarningCapture *active;

	WarningCapture()
	{
		active = this;
		previous = qInstallMessageHandler(&WarningCapture::handle);
	}

	~WarningCapture()
	{
		qInstallMessageHandler(previous);
		if (active == this) {
			active = nullptr;
		}
	}

	static void handle(QtMsgType type, const QMessageLogContext &context, const QString &message)
	{
		if (active && type == QtWarningMsg && context.category
				&& QLatin1String(context.category) == QLatin1String("venus.gui")) {
			active->warnings.append(message);
		}
		if (active && active->previous) {
			active->previous(type, context, message);
		}
	}
};

WarningCapture *WarningCapture::active = nullptr;

}

class BrandingTestHelper : public QObject
{
	Q_OBJECT

public:
	// Runs the loader's one-custom-branding-plugin rule on a JSON array of plugin entries.
	// Fonts registered by an accepted snapshot are removed before this returns.
	Q_INVOKABLE QVariantMap enableFirstBrandingPlugin(const QString &pluginsJson)
	{
		// pluginsFromJson() parses a compiled plugin, so it requires a version and a
		// resource. These tests only describe integrations, so fill those in.
		QJsonArray array = QJsonDocument::fromJson(pluginsJson.toUtf8()).array();
		for (qsizetype i = 0; i < array.size(); ++i) {
			if (!array.at(i).isObject()) {
				continue;
			}
			QJsonObject plugin = array.at(i).toObject();
			if (plugin.value(QStringLiteral("version")).toString().isEmpty()) {
				plugin.insert(QStringLiteral("version"), QStringLiteral("1.0.0"));
			}
			if (plugin.value(QStringLiteral("resource")).toString().isEmpty()) {
				plugin.insert(QStringLiteral("resource"), QStringLiteral("YQ=="));
			}
			array.replace(i, plugin);
		}
		const QString json = QString::fromUtf8(QJsonDocument(array).toJson(QJsonDocument::Compact));
		QVector<Victron::VenusOS::GuiPlugin> plugins = GuiPluginLoader::pluginsFromJson(json);
		QList<BrandingData> branding;
		QList<int> fontIds;
		QVector<Victron::VenusOS::GuiPlugin> removed;
		QStringList warnings;
		{
			WarningCapture capture;
			removed = GuiPluginLoader::enableFirstBrandingPlugin(m_engine, &plugins, &branding, &fontIds);
			warnings = capture.warnings;
		}
		removeFonts(fontIds);

		QVariantList remainingPlugins;
		for (const Victron::VenusOS::GuiPlugin &plugin : plugins) {
			QVariantList types;
			for (const Victron::VenusOS::GuiPluginIntegration &integration : plugin.integrations()) {
				types.append(static_cast<int>(integration.type()));
			}
			remainingPlugins.append(QVariantMap{
				{ QStringLiteral("name"), plugin.name() },
				{ QStringLiteral("types"), types },
			});
		}
		QVariantList removedNames;
		for (const Victron::VenusOS::GuiPlugin &plugin : removed) {
			removedNames.append(plugin.name());
		}
		QVariantList brandingList;
		for (const BrandingData &data : branding) {
			QVariantMap map = toVariantMap(data);
			map.insert(QStringLiteral("pluginName"), data.pluginName);
			brandingList.append(map);
		}
		return {
			{ QStringLiteral("remaining"), remainingPlugins },
			{ QStringLiteral("removed"), removedNames },
			{ QStringLiteral("branding"), brandingList },
			{ QStringLiteral("warnings"), warnings },
		};
	}

	explicit BrandingTestHelper(QObject *parent = nullptr) : QObject(parent) {}

	Q_INVOKABLE QVariantMap snapshot(QObject *object) const
	{
		const Victron::Branding *branding = qobject_cast<Victron::Branding *>(object);
		return branding ? toVariantMap(branding->snapshot()) : QVariantMap();
	}

	// Each entry is a map of Branding property names to values, as in a Branding file.
	Q_INVOKABLE void setThemeBranding(const QVariantList &pluginBranding) const
	{
		QList<BrandingData> list;
		for (const QVariant &entry : pluginBranding) {
			list.append(fromVariantMap(entry.toMap()));
		}
		Victron::VenusOS::ThemeSingleton::create()->setPluginBranding(list);
	}

	// The Branding colors that the Theme resolved from its Branding, as "#rrggbb" strings.
	Q_INVOKABLE QVariantMap resolvedBrandingColors() const
	{
		const ColorDerivation::ResolvedBrandingColors &colors
				= Victron::VenusOS::ThemeSingleton::create()->resolvedBrandingColors();
		return {
			{ QStringLiteral("darkScheme"), brandingColorMap(colors.darkScheme) },
			{ QStringLiteral("lightScheme"), brandingColorMap(colors.lightScheme) },
			{ QStringLiteral("darkerFontPrimary"), colors.darkerFontPrimary.name() },
			{ QStringLiteral("lightModeBackgroundFactorThousandths"), colors.lightModeBackgroundFactorThousandths },
		};
	}

	Q_INVOKABLE QString blendOnto(const QString &color, int alpha, const QString &background) const
	{
		return ColorDerivation::blendOnto(QColor::fromString(color), alpha, QColor::fromString(background)).name();
	}

	Q_INVOKABLE QString lightModeBackgroundColor(const QString &darkModeBackground, int factorThousandths) const
	{
		return ColorDerivation::lightModeBackgroundColor(QColor::fromString(darkModeBackground), factorThousandths)
				.name();
	}

	Q_INVOKABLE double contrastRatio(const QString &a, const QString &b) const
	{
		return ColorDerivation::contrastRatio(QColor::fromString(a), QColor::fromString(b));
	}

	Q_INVOKABLE bool setBuiltInFontRegistered(bool registered)
	{
		return setFontRegistered(&m_builtInFontId, registered, builtInFontData);
	}

	// The "BrandF" family (see brandFontData()), registered from memory.
	Q_INVOKABLE bool setBrandFontRegistered(bool registered)
	{
		return setFontRegistered(&m_brandFontId, registered, brandFontData);
	}

	// The "AsciiF" family (see asciiFontData()): basic Latin only.
	Q_INVOKABLE bool setAsciiFontRegistered(bool registered)
	{
		return setFontRegistered(&m_asciiFontId, registered, asciiFontData);
	}

	// languageCode is an ISO 639 code, such as "de".
	Q_INVOKABLE bool fontFamilyCovers(const QString &family, const QString &languageCode) const
	{
		return Victron::VenusOS::Language::fontFamilyCovers(family, QLocale::codeToLanguage(languageCode));
	}

	// Runs the loader's checks on custom branding values, as though they came from the Branding file at
	// brandingFileUrl. Fonts that font_files registers are removed again before this returns.
	Q_INVOKABLE QVariantMap checkAndResolveBrandingSnapshot(const QVariantMap &branding,
			const QString &brandingFileUrl) const
	{
		BrandingData data = fromVariantMap(branding);
		data.pluginName = TestPluginName;
		QList<int> fontIds;
		GuiPluginLoader::checkAndResolveBrandingSnapshot(&data, QUrl(brandingFileUrl), &fontIds);
		removeFonts(fontIds);
		return {
			{ QStringLiteral("data"), toVariantMap(data) },
			{ QStringLiteral("fontCount"), fontIds.count() },
		};
	}

	// The test Branding file data/<name>/Branding.qml, which CMakeLists.txt compiles into the
	// test executable.
	Q_INVOKABLE QString brandingFileUrl(const QString &name) const
	{
		return QStringLiteral("qrc:/branding-test/%1/Branding.qml").arg(name);
	}

	// Loads the test Branding file data/<name>/Branding.qml through the loader.
	Q_INVOKABLE QVariantMap loadBrandingFile(const QString &name) const
	{
		if (!m_engine) {
			qWarning() << "Cannot load" << name << ": no QML engine";
			return {};
		}
		return loadBrandingFileInEngine(m_engine, name);
	}

	// What loadBrandingFile("valid") gave when applicationAvailable() called it, before any
	// QML file had imported QtQuick.
	Q_INVOKABLE QVariantMap brandingLoadedBeforeQtQuick() const
	{
		return m_brandingLoadedBeforeQtQuick;
	}

public slots:
	// Qt Quick Test calls this before it loads any QML file, so nothing has imported QtQuick yet.
	// The app loads custom branding plugins at the same point: before it loads Main.qml.
	void applicationAvailable()
	{
		QQmlEngine engine;
		m_brandingLoadedBeforeQtQuick = loadBrandingFileInEngine(&engine, QStringLiteral("valid"));
	}

	void qmlEngineAvailable(QQmlEngine *engine)
	{
		m_engine = engine;
		engine->rootContext()->setContextProperty(QStringLiteral("BrandingTestHelper"), this);
	}

private:
	QVariantMap loadBrandingFileInEngine(QQmlEngine *engine, const QString &name) const
	{
		QVariantMap result;
		QList<int> fontIds;
		const std::optional<BrandingData> data = GuiPluginLoader::createBrandingSnapshot(
				engine, QUrl(brandingFileUrl(name)), TestPluginName, &fontIds);
		removeFonts(fontIds);
		result.insert(QStringLiteral("valid"), data.has_value());
		if (data.has_value()) {
			result.insert(QStringLiteral("data"), toVariantMap(*data));
			result.insert(QStringLiteral("pluginName"), data->pluginName);
		}
		return result;
	}

	static bool setFontRegistered(int *fontId, bool registered, QByteArray (*fontData)())
	{
		if (registered && *fontId < 0) {
			*fontId = QFontDatabase::addApplicationFontFromData(fontData());
		} else if (!registered && *fontId >= 0) {
			QFontDatabase::removeApplicationFont(*fontId);
			*fontId = -1;
		}
		return (*fontId >= 0) == registered;
	}

	static void removeFonts(const QList<int> &fontIds)
	{
		for (int fontId : fontIds) {
			QFontDatabase::removeApplicationFont(fontId);
		}
	}

	QPointer<QQmlEngine> m_engine;
	QVariantMap m_brandingLoadedBeforeQtQuick;
	int m_builtInFontId = -1;
	int m_brandFontId = -1;
	int m_asciiFontId = -1;
};

int main(int argc, char **argv)
{
	BrandingTestHelper helper;

	QTEST_SET_MAIN_SOURCE_PATH
	return quick_test_main_with_setup(argc, argv, "tst_branding",
			resolveTestSourceDir("branding", argv[0]).toLocal8Bit().constData(), &helper);
}

#include "tst_branding.moc"
