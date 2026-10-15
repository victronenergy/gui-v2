/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include <QtQuickTest/quicktest.h>
#include <QQmlEngine>
#include <QQmlContext>
#include <QFile>
#include <QFontDatabase>
#include <QImageReader>
#include <QJsonDocument>
#include <QJsonObject>
#include <QPointer>
#include <QtEndian>

#include <algorithm>

#include "testutils.h"
#include "branding.h"
#include "colorderivation.h"
#include "guiplugins.h"
#include "themeobjects.h"
#include "tintedimageprovider.h"

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

}

class BrandingTestHelper : public QObject
{
	Q_OBJECT

public:
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

	// The branding colors that the Theme resolved from its branding, as "#rrggbb" strings.
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

	// Runs the loader's checks on branding values, as though they came from the Branding file at
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
		QVariantMap result;
		if (!m_engine) {
			qWarning() << "Cannot load" << name << ": no QML engine";
			return result;
		}
		QList<int> fontIds;
		const std::optional<BrandingData> data = GuiPluginLoader::createBrandingSnapshot(
				m_engine, QUrl(brandingFileUrl(name)), TestPluginName, &fontIds);
		removeFonts(fontIds);
		result.insert(QStringLiteral("valid"), data.has_value());
		if (data.has_value()) {
			result.insert(QStringLiteral("data"), toVariantMap(*data));
			result.insert(QStringLiteral("pluginName"), data->pluginName);
		}
		return result;
	}

	// The Victron.Branding module version of this build, as "major.minor".
	Q_INVOKABLE QString brandingModuleVersion() const
	{
		return QStringLiteral("%1.%2").arg(Victron::BrandingModuleMajorVersion)
				.arg(Victron::BrandingModuleMinorVersion);
	}

	// Runs the loader's requiredBrandingVersion check on the plugin entry in pluginJson.
	Q_INVOKABLE QString checkRequiredBrandingVersion(const QString &pluginJson) const
	{
		const QJsonObject plugin = QJsonDocument::fromJson(pluginJson.toUtf8()).object();
		return GuiPluginLoader::checkRequiredBrandingVersion(plugin.value(QStringLiteral("requiredBrandingVersion")));
	}

	// The types of the integrations that the loader keeps from the plugin entry in pluginJson.
	Q_INVOKABLE QVariantList integrationTypes(const QString &pluginJson) const
	{
		const QJsonObject plugin = QJsonDocument::fromJson(pluginJson.toUtf8()).object();
		QVariantList types;
		for (const Victron::VenusOS::GuiPluginIntegration &integration
				: GuiPluginLoader::parseIntegrations(plugin, TestPluginName)) {
			types.append(static_cast<int>(integration.type()));
		}
		return types;
	}

	// Reads the image at image://tinted/<id>, with the given sourceSize (0 for "not set").
	Q_INVOKABLE QVariantMap tintedImage(const QString &id, int width, int height) const
	{
		Victron::VenusOS::TintedImageProvider provider;
		QSize originalSize;
		const QImage image = provider.requestImage(id, &originalSize, QSize(width, height));
		return {
			{ QStringLiteral("valid"), !image.isNull() },
			{ QStringLiteral("width"), image.width() },
			{ QStringLiteral("height"), image.height() },
			{ QStringLiteral("originalWidth"), originalSize.width() },
			{ QStringLiteral("originalHeight"), originalSize.height() },
		};
	}

	// Compares the resource image at path, tinted with color ("#rrggbb"), with the untinted
	// image. Both are read at width x height. The differences are in premultiplied channel values.
	Q_INVOKABLE QVariantMap compareTintedImage(const QString &color, const QString &path, int width, int height) const
	{
		Victron::VenusOS::TintedImageProvider provider;
		const QSize size(width, height);
		const QImage tinted = provider.requestImage(color.mid(1) + QLatin1Char('/') + path, nullptr, size);
		QImageReader reader(QStringLiteral(":/") + path);
		reader.setScaledSize(size);
		const QImage original = reader.read().convertToFormat(QImage::Format_ARGB32_Premultiplied);
		if (tinted.size() != size || original.size() != size) {
			return { { QStringLiteral("valid"), false } };
		}

		const QColor tint = QColor::fromString(color);
		int visiblePixels = 0;
		int alphaDifferences = 0;
		int maxDifferenceFromOriginal = 0;
		int maxDifferenceFromTint = 0;
		for (int y = 0; y < height; ++y) {
			const QRgb *tintedLine = reinterpret_cast<const QRgb *>(tinted.constScanLine(y));
			const QRgb *originalLine = reinterpret_cast<const QRgb *>(original.constScanLine(y));
			for (int x = 0; x < width; ++x) {
				const QRgb t = tintedLine[x];
				const QRgb o = originalLine[x];
				const QRgb expected = qPremultiply(qRgba(tint.red(), tint.green(), tint.blue(), qAlpha(o)));
				visiblePixels += qAlpha(o) > 0 ? 1 : 0;
				alphaDifferences += qAlpha(t) != qAlpha(o) ? 1 : 0;
				maxDifferenceFromOriginal = std::max({ maxDifferenceFromOriginal,
						std::abs(qRed(t) - qRed(o)), std::abs(qGreen(t) - qGreen(o)),
						std::abs(qBlue(t) - qBlue(o)) });
				maxDifferenceFromTint = std::max({ maxDifferenceFromTint,
						std::abs(qRed(t) - qRed(expected)), std::abs(qGreen(t) - qGreen(expected)),
						std::abs(qBlue(t) - qBlue(expected)) });
			}
		}
		return {
			{ QStringLiteral("valid"), true },
			{ QStringLiteral("visiblePixels"), visiblePixels },
			{ QStringLiteral("alphaDifferences"), alphaDifferences },
			{ QStringLiteral("maxDifferenceFromOriginal"), maxDifferenceFromOriginal },
			{ QStringLiteral("maxDifferenceFromTint"), maxDifferenceFromTint },
		};
	}

public slots:
	void qmlEngineAvailable(QQmlEngine *engine)
	{
		m_engine = engine;
		engine->rootContext()->setContextProperty(QStringLiteral("BrandingTestHelper"), this);
	}

private:
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
	int m_builtInFontId = -1;
	int m_brandFontId = -1;
};

int main(int argc, char **argv)
{
	BrandingTestHelper helper;

	QTEST_SET_MAIN_SOURCE_PATH
	return quick_test_main_with_setup(argc, argv, "tst_branding",
			resolveTestSourceDir("branding", argv[0]).toLocal8Bit().constData(), &helper);
}

#include "tst_branding.moc"
