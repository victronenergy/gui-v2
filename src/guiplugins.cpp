/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "guiplugins.h"
#include "logging.h"
#include "language.h"

#include <veutil/qt/ve_qitem.hpp>

#include <QResource>
#include <QTranslator>
#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QFileSystemWatcher>

#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonValue>

#include <QQmlInfo>
#include <QPointer>

using namespace Victron::VenusOS;

namespace {
	QString enabledAppsDir() {
#if defined(VENUS_GX_BUILD)
		// Custom Applications available on the GX are in:
		// /data/apps/available/[app-name]
		// and when enabled the folder will be symlinked into:
		// /data/apps/enabled/[app-name]
		// Each application may consist of a variety of different parts,
		// including Node-RED plugins, system services, and gui-v2 plugins.
		// The gui-v2 plugins will be found under a `gui-v2` subdirectory,
		// e.g.: /data/apps/enabled/[app-name]/gui-v2/
		const QString path = QStringLiteral("/data/apps/enabled/");
		QDir dir;
		if (!dir.exists(path)) {
			if (!dir.mkpath(path)) {
				qCWarning(venusGui) << "/data/apps/enabled/ does not exist and could not be created!";
				return QString();
			}
		}
		return path;
#else
		return QString();
#endif
	}

	QStringList guiPluginDirs(const QString &appsDirPath) {
#if defined(VENUS_GX_BUILD)
		// enumerate the enabled appsDirPath for application subdirectories.
		QDir appsDir = QDir::root();
		if (appsDir.cd(appsDirPath)) {
			const QStringList appDirs = appsDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot);

			// for each application subdirectory, find those which include a `gui-v2` plugins subdirectory.
			// each such directory should be appended to the list of directories to watch.
			QStringList pluginDirs;
			for (const QString &appDirPath : appDirs) {
				QDir appDir = appsDir;
				if (!appDir.cd(appDirPath)) {
					qCWarning(venusGui) << "Cannot cd into application directory:" << appDir.filePath(appDirPath);
					continue;
				}
				qCInfo(venusGui) << "Checking application directory:" << appDir.absolutePath() << "for gui-v2 plugins directory...";
				if (!appDir.cd(QStringLiteral("gui-v2"))) {
					qCWarning(venusGui) << "Application" << appDir.absolutePath() << "does not contain a gui-v2 plugins directory.";
				} else {
					qCInfo(venusGui) << "Found gui-v2 plugin directory:" << appDir.absolutePath();
					pluginDirs.append(appDir.absolutePath());
				}
			}
			return pluginDirs;
		}
		return QStringList();
#elif defined(VENUS_DESKTOP_BUILD)
		// look in ~appdir/plugins/
		const QString appDirPath = QCoreApplication::applicationDirPath();
		QDir pluginDir = QDir(appDirPath);
		if (!pluginDir.exists(QStringLiteral("plugins"))
				&& !pluginDir.mkdir(QStringLiteral("plugins"))) {
			qCWarning(venusGui) << QStringLiteral("%1/%2").arg(appDirPath, QStringLiteral("plugins"))
				<< "does not exist and could not be created!";
			return QStringList();
		}
		if (pluginDir.cd(QStringLiteral("plugins"))) {
			return QStringList { pluginDir.canonicalPath() };
		}
		return QStringList();
#else
		return QStringList();
#endif
	}
}

GuiPluginLoader* GuiPluginLoader::create(QQmlEngine *, QJSEngine *)
{
	static GuiPluginLoader* instance = new GuiPluginLoader(nullptr);
	return instance;
}

GuiPluginLoader::GuiPluginLoader(QObject *parent)
	: QObject(parent), m_invokeOnceTimer(this)
{
	Language *languageSingleton = Language::create();
	connect(languageSingleton, &Language::currentLanguageChanged,
		this, [this, languageSingleton] {
			for (const GuiPlugin &p : std::as_const(m_plugins)) {
				installPluginTranslatorForLanguage(p.name(), languageSingleton->getCurrentLanguage());
			}
		});

	// Initialise a single-shot timer for invoke-once behaviour related to plugin loading.
	// This ensures that even if multiple plugins are changed at the same time, we only
	// reload and re-initialise the plugins once.
	m_invokeOnceTimer.setSingleShot(true);
	m_invokeOnceTimer.setInterval(100); // file operations are asynchronous, so give some leeway.
	connect(&m_invokeOnceTimer, &QTimer::timeout, this, &GuiPluginLoader::initPlugins);

	// Set up a filesystem watcher on the enabled applications dir (if it exists).
	const QString appsDir = enabledAppsDir();
	if (!appsDir.isEmpty()) {
		m_enabledAppsDirWatcher = new QFileSystemWatcher(QStringList { appsDir }, this);
		connect(m_enabledAppsDirWatcher, &QFileSystemWatcher::directoryChanged,
			this, &GuiPluginLoader::watchPluginDirs);
	}

	// Set up filesystem watchers on all of the plugin dirs (if they exist),
	// and read in plugin data from those plugin dirs.
	watchPluginDirs(appsDir);

	// Now force initialisation of plugins immediately rather than waiting
	// for the invoke-once timer to complete.
	m_invokeOnceTimer.stop();
	initPlugins();
}

GuiPluginLoader::~GuiPluginLoader()
{
}

QString GuiPluginLoader::pluginsJson() const
{
	return m_pluginsJson;
}

void GuiPluginLoader::setPluginsJson(const QString &json)
{
	if (m_pluginsJson != json) {
		m_pluginsJson = json;
		Q_EMIT pluginsJsonChanged();
		populatePlugins();
	}
}

QVector<GuiPlugin> GuiPluginLoader::plugins() const
{
	return m_plugins;
}

GuiPlugin GuiPluginLoader::plugin(const QString &name) const
{
	for (const GuiPlugin &p : std::as_const(m_plugins)) {
		if (p.name() == name) {
			return p;
		}
	}

	return GuiPlugin();
}

void GuiPluginLoader::watchPluginDirs(const QString &appsDir)
{
	// first, clear the previously read plugin data.
	m_pluginDirData.clear();

	// second, delete any existing watcher.
	if (m_guiPluginDirsWatcher) {
		delete m_guiPluginDirsWatcher;
		m_guiPluginDirsWatcher = nullptr;
	}

	// third, construct the watcher if required.
	const QStringList pluginDirs = guiPluginDirs(appsDir);
	if (!pluginDirs.isEmpty()) {
		m_guiPluginDirsWatcher = new QFileSystemWatcher(pluginDirs, this);
		connect(m_guiPluginDirsWatcher, &QFileSystemWatcher::directoryChanged,
			this, &GuiPluginLoader::readFromFilesystem);
	}

	// fourth, read plugin data from each directory.
	for (const QString &dir : pluginDirs) {
		readFromFilesystem(dir);
	}

	// finally, queue up re-populating installed plugins from the data.
	// Note: we need to do this both in this function AND in readFromFilesystem()
	// in case (1) there are no valid pluginDirs now (e.g. all apps were disabled)
	// and in case (2) where pluginDirs didn't change but the content of one
	// particular pluginDir changed.
	m_invokeOnceTimer.start();
}

void GuiPluginLoader::readFromFilesystem(const QString &path)
{
	QDir pluginsDir(path);
	const QStringList files = pluginsDir.exists()
		? pluginsDir.entryList({ QStringLiteral("*.json") }, QDir::Files)
		: QStringList();

	QStringList plugins;
	for (const QString &file : files) {
		QFile f(pluginsDir.absoluteFilePath(file));
		if (f.open(QIODevice::ReadOnly)) {
			const QString plugin = QString::fromUtf8(f.readAll());
			if (!plugin.isEmpty()) {
				plugins.append(plugin);
			}
		}
	}

	if (plugins.size()) {
		m_pluginDirData.insert(path, plugins);
	}

	m_invokeOnceTimer.start();
}

void GuiPluginLoader::initPlugins()
{
	qCInfo(venusGui) << "About to initialise plugins due to filesystem trigger";
	QStringList allPlugins;
	for (const QStringList &pluginData : std::as_const(m_pluginDirData)) {
		allPlugins.append(pluginData);
	}

	// This will result in populatePlugins() being called.
	setPluginsJson(QStringLiteral("[ %1 ]").arg(allPlugins.join(QChar(','))));
}

void GuiPluginLoader::populatePlugins()
{
	// first, unload any resources and translation catalogues
	// associated with the old data.
	unloadPluginData();

	// then, load the new data.
	QVector<GuiPlugin> data;

	const QByteArray json = m_pluginsJson.toUtf8();
	const QJsonDocument doc = QJsonDocument::fromJson(json);
	const QJsonArray array = doc.array();

	qCInfo(venusGui) << "Populating plugins from array with length" << array.size();

	// each entry in the array looks like:
	// {
	//   name: "AppName",
	//   version: "version",
	//   minRequiredVersion: "version",
	//   maxRequiredVersion: "version,
	//   resource: "base64-encoded-rcc-file",
	//   translations: [ "qrc:/AppName/translations_en.qm", ... ]
	//   integrations: [ ... ]
	// }

	for (qsizetype i = 0; i < array.size(); ++i) {
		const QJsonValue v = array[i];
		if (!v.isObject()) {
			qCWarning(venusGui) << "Ignoring plugin at index" << i;
			continue;
		}

		const QJsonObject plugin = v.toObject();
		const QString pluginName = plugin.value(QStringLiteral("name")).toString();
		const QString pluginVersion = plugin.value(QStringLiteral("version")).toString();
		const QString pluginResource = plugin.value(QStringLiteral("resource")).toString();
		const QByteArray pluginDecodedResource = QByteArray::fromBase64(pluginResource.toUtf8());
		if (pluginName.isEmpty()
				|| pluginVersion.isEmpty()
				|| pluginResource.isEmpty()
				|| pluginDecodedResource.isEmpty()
				|| !plugin.contains(QStringLiteral("integrations"))) {
			qCWarning(venusGui) << "Ignoring invalid plugin at index" << i;
			continue;
		}

		bool foundClash = false;
		for (const GuiPlugin &p : std::as_const(data)) {
			if (pluginName == p.name()) {
				foundClash = true;
				break;
			}
		}
		if (foundClash) {
			qCWarning(venusGui) << "Ignoring clashing plugin at index" << i << ":" << pluginName;
			continue;
		}

		const QJsonValue iva = plugin.value(QStringLiteral("integrations"));
		if (!iva.isArray()) {
			qCWarning(venusGui) << "Ignoring plugin with invalid integrations at index" << i << ":" << pluginName;
			continue;
		}

		QVector<GuiPluginIntegration> integrations;
		const QJsonArray pluginIntegrations = iva.toArray();
		for (qsizetype j = 0; j < pluginIntegrations.size(); ++j) {
			const QJsonValue iv = pluginIntegrations[j];
			if (!iv.isObject()) {
				qCWarning(venusGui) << "Ignoring integration at index" << j << "in plugin at index" << i << ":" << pluginName;
				continue;
			}

			// each entry in the integrations array looks like one of the following:
			// {
			//     type: 1, // new settings page under Settings/Integrations/UI Plugins
			//     url: "qrc:/AppName/SettingsPage.qml"
			// },
			// {
			//     type: 2, // device list settings page integration
			//     productId: "prodId",
			//     title: "AppName_some_title_translation_id", // or a string, if no translations...
			//     url: "qrc/AppName/CustomInjectionPage.qml"
			// },
			// {
			//     type: 3, // new navigation page
			//     icon: "qrc:/AppName/icon.svg",
			//     url: "qrc:/AppName/CustomNavPage.qml"
			// },
			// {
			//     type: 4, // new quick access pane
			//     icon: "qrc:/AppName/icon.png",
			//     url: "qrc:/AppName/CustomCardsPage.qml"
			// },
			// {
			//     type: 5, // new card within a quick access pane
			//     cardType: 1/2/ ... 1 = controls card, 2 = switches card, ...
			//     url: "qrc:/AppName/CustomCard.qml"
			// }

			const QJsonObject integration = iv.toObject();
			const int integrationType = integration.value(QStringLiteral("type")).toInt(0);
			const QString integrationUrl = integration.value(QStringLiteral("url")).toString();
			const QString integrationProductId = integration.value(QStringLiteral("productId")).toString();
			const QString integrationTitle = integration.value(QStringLiteral("title")).toString();
			const QString integrationIcon = integration.value(QStringLiteral("icon")).toString();
			const int integrationCardType = integration.value(QStringLiteral("cardType")).toInt(0);

			if (integrationType == GuiPluginLoader::InvalidIntegrationType
					|| integrationType > GuiPluginLoader::QuickAccessPaneCard
					|| (integrationType == GuiPluginLoader::DeviceListSettingsPage
						&& (integrationProductId.isEmpty() || integrationTitle.isEmpty()))
					|| ((integrationType == GuiPluginLoader::NavigationPage || integrationType == GuiPluginLoader::QuickAccessPane)
						&& (integrationIcon.isEmpty()))
					|| (integrationType == GuiPluginLoader::QuickAccessPaneCard
						&& (integrationCardType != GuiPluginLoader::ControlsCard && integrationCardType != GuiPluginLoader::SwitchesCard))
					|| integrationUrl.isEmpty()) {
				qCWarning(venusGui) << "Ignoring invalid integration at index" << j << "in plugin at index" << i << ":" << pluginName;
				continue;
			}

			GuiPluginIntegration pi;
			pi.m_pluginName = pluginName;
			pi.m_type = static_cast<GuiPluginLoader::IntegrationType>(integrationType);
			pi.m_url = QUrl(integrationUrl);
			if (integrationType == GuiPluginLoader::DeviceListSettingsPage) {
				pi.m_productId = integrationProductId;
				pi.m_title = integrationTitle;
			} else if (integrationType == GuiPluginLoader::NavigationPage || integrationType == GuiPluginLoader::QuickAccessPane) {
				pi.m_icon = QUrl(integrationIcon);
			} else if (integrationType == GuiPluginLoader::QuickAccessPaneCard) {
				pi.m_cardType = static_cast<GuiPluginLoader::QuickAccessPaneCardType>(integrationCardType);
			}
			integrations.append(pi);
		}

		if (integrations.size() == 0) {
			qCWarning(venusGui) << "Ignoring plugin without integrations at index" << i << ":" << pluginName;
			continue;
		}

		GuiPlugin p;
		p.m_name = pluginName;
		p.m_color = determineColor(pluginName, data);
		p.m_version = pluginVersion;
		p.m_minRequiredVersion = plugin.value(QStringLiteral("minRequiredVersion")).toString();
		p.m_maxRequiredVersion = plugin.value(QStringLiteral("maxRequiredVersion")).toString();
		p.m_resource = pluginDecodedResource;
		p.m_integrations = integrations;

		const QJsonArray pluginTranslations = plugin.value(QStringLiteral("translations")).toArray();
		for (qsizetype t = 0; t < pluginTranslations.size(); ++t) {
			const QJsonValue tv = pluginTranslations.at(t);
			if (!tv.isString()) {
				qCWarning(venusGui) << "Ignoring invalid translation catalogue url for plugin at index" << i << ":" << pluginName;
				continue;
			}
			p.m_translations.append(QUrl(tv.toString()));
		}

		if (!loadPluginData(p)) {
			qCWarning(venusGui) << "Ignoring plugin with invalid data at index" << i << ":" << pluginName;
			continue;
		}

		qCInfo(venusGui) << "Successfully populated plugin at index" << i << ":" << pluginName;
		data.append(p);
	}

	if (!m_plugins.isEmpty() || !data.isEmpty()) {
		m_plugins = data;
		Q_EMIT pluginsChanged();
	}
}

bool GuiPluginLoader::loadPluginData(const GuiPlugin &plugin)
{
	// ensure that the version matches.
	bool guiv2VersionMeetsRequirements = true; // TODO
	if (!guiv2VersionMeetsRequirements) {
		qCWarning(venusGui) << "Required version mismatch!";
		return false;
	}

	// load the resource data.
	if (!QResource::registerResource(reinterpret_cast<const uchar*>(plugin.m_resource.constData()))) {
		qCWarning(venusGui) << "Unable to load resource data for plugin" << plugin.name();
		return false;
	}

	// load the translation catalogues.
	Language *languageSingleton = Language::create();
	QLocale::Language currentLanguage = languageSingleton->getCurrentLanguage();
	installPluginTranslatorForLanguage(plugin.name(), QLocale::English);
	if (currentLanguage != QLocale::English) {
		installPluginTranslatorForLanguage(plugin.name(), currentLanguage);
	}

	return true;
}

void GuiPluginLoader::unloadPluginData()
{
	for (const GuiPlugin &plugin : std::as_const(m_plugins)) {
		QResource::unregisterResource(reinterpret_cast<const uchar*>(plugin.m_resource.constData()));
		const QHash<QLocale::Language, QTranslator*> hash(m_pluginTranslators.value(plugin.name()));
		for (QTranslator *t : hash.values()) {
			if (t) {
				QCoreApplication::removeTranslator(t);
				t->deleteLater();
			}
		}
	}
	m_currentTranslators.clear();
	m_pluginTranslators.clear();
}

bool GuiPluginLoader::installPluginTranslatorForLanguage(const QString &pluginName, QLocale::Language language)
{
	QHash<QLocale::Language, QTranslator*> &hash = m_pluginTranslators[pluginName];
	const bool alreadyLoaded = hash.contains(language);
	QTranslator *translator = alreadyLoaded
			? hash.value(language)
			: new QTranslator(this);

	if (!alreadyLoaded) {
		if (translator->load(
				QLocale(language),
				pluginName,
				QLatin1String("_"),
				QStringLiteral(":/%1").arg(pluginName))) {
			qCDebug(venusGui) << "Successfully loaded translations for locale" << QLocale(language).name() << "for plugin" << pluginName;
			hash.insert(language, translator);
		} else {
			qCWarning(venusGui) << "Unable to load translations for locale" << QLocale(language).name() << "for plugin" << pluginName;
			translator->deleteLater();
			return false;
		}
	}

	// On language change, uninstall the old catalogue (unless it was the fallback English one).
	QPointer<QTranslator> currTranslator = m_currentTranslators.value(pluginName);
	if (currTranslator.data() && currTranslator.data() != hash.value(QLocale::English)) {
		if (!QCoreApplication::removeTranslator(currTranslator.data())) {
			qCWarning(venusGui) << "Unable to remove old translator for locale" << QLocale(language).name() << "for plugin" << pluginName;
		}
		m_currentTranslators.remove(pluginName);
	}

	// English is the fallback catalogue, so we have special handling for it:
	// ensure we install it the first time it is loaded, but never after that.
	// All other languages need to be installed, as we will remove them on language change.
	if (language != QLocale::English || !alreadyLoaded) {
		if (!QCoreApplication::installTranslator(translator)) {
			qCWarning(venusGui) << "Unable to install translator for locale" << QLocale(language).name() << "for plugin" << pluginName;
			translator->deleteLater();
			if (hash.value(language) == translator) {
				hash.remove(language);
			}
			return false;
		}
	}

	m_currentTranslators.insert(pluginName, translator);

	return true;
}

QColor GuiPluginLoader::determineColor(const QString &pluginName, const QVector<GuiPlugin> &otherPlugins) const
{
	static const QVector<QVector<QColor> > colors {
		{
			QColorConstants::Svg::darkcyan,
			QColorConstants::Svg::darkgoldenrod,
			QColorConstants::Svg::darkgreen,
			QColorConstants::Svg::darkgrey,
			QColorConstants::Svg::darkkhaki,
			QColorConstants::Svg::darkmagenta,
			QColorConstants::Svg::darkorchid,
			QColorConstants::Svg::darkred,
			QColorConstants::Svg::darksalmon,
			QColorConstants::Svg::darkseagreen,
			QColorConstants::Svg::darkturquoise
		},
		{
			QColorConstants::Svg::cyan,
			QColorConstants::Svg::goldenrod,
			QColorConstants::Svg::green,
			QColorConstants::Svg::grey,
			QColorConstants::Svg::khaki,
			QColorConstants::Svg::magenta,
			QColorConstants::Svg::orchid,
			QColorConstants::Svg::red,
			QColorConstants::Svg::salmon,
			QColorConstants::Svg::seagreen,
			QColorConstants::Svg::turquoise
		},
		{
			QColorConstants::Svg::lightsteelblue,
			QColorConstants::Svg::burlywood,
			QColorConstants::Svg::mediumspringgreen,
			QColorConstants::Svg::steelblue,
			QColorConstants::Svg::yellowgreen,
			QColorConstants::Svg::crimson,
			QColorConstants::Svg::deeppink,
			QColorConstants::Svg::mistyrose,
			QColorConstants::Svg::peachpuff,
			QColorConstants::Svg::olive,
			QColorConstants::Svg::aquamarine
		}
	};

	// Don't use qHash() because size_t has different number
	// of bits on armv7 vs aarch64 vs x86_64 etc
	// so we would end up with different colours on CerboGX
	// and WebAssembly versions, etc.
	// Instead, use a public-domain hash function which has
	// decent enough anti-collision properties for small strings.
	auto sdbmHash = [] (const QString &pluginName) -> quint32 {
		quint32 ret = 0;
		for (const QChar &c : pluginName) {
			ret = static_cast<quint32>(c.unicode()) + (ret << 6) + (ret << 16) - ret;
		}
		return ret;
	};

	const quint32 hash = sdbmHash(pluginName);
	const qsizetype idx = hash % colors[0].size();

	for (qsizetype i = 0; i < colors.size(); ++i) {
		const QColor wanted = colors[i][idx];
		bool alreadyUsed = false;
		for (const GuiPlugin &p : otherPlugins) {
			if (p.color() == wanted) {
				alreadyUsed = true;
				break;
			}
		}
		if (!alreadyUsed) {
			return wanted;
		}
	}

	return QColorConstants::Svg::yellow; // final fallback
}

GuiPluginModel::GuiPluginModel(QObject *parent)
	: QAbstractListModel(parent)
{
	GuiPluginLoader *singleton = GuiPluginLoader::create();
	connect(singleton, &GuiPluginLoader::pluginsChanged,
		this, &GuiPluginModel::updatePlugins);
}

int GuiPluginModel::count() const
{
	return static_cast<int>(m_plugins.count());
}

QVariant GuiPluginModel::data(const QModelIndex &index, int role) const
{
	const int row = index.row();

	if(row < 0 || row >= m_plugins.count()) {
		return QVariant();
	}
	switch (role)
	{
	case PluginRole:
		return QVariant::fromValue<GuiPlugin>(m_plugins.at(row));
	case NameRole:
		return QVariant(m_plugins.at(row).name());
	case VersionRole:
		return QVariant(m_plugins.at(row).version());
	case MinRequiredVersionRole:
		return QVariant(m_plugins.at(row).minRequiredVersion());
	case MaxRequiredVersionRole:
		return QVariant(m_plugins.at(row).maxRequiredVersion());
	case ColorRole:
		return QVariant(m_plugins.at(row).color());
	case ResourceRole:
		return QVariant(m_plugins.at(row).resource());
	case TranslationsRole:
		return QVariant::fromValue<QVector<QUrl> >(m_plugins.at(row).translations());
	case IntegrationsRole:
		return QVariant::fromValue<QVector<GuiPluginIntegration> >(m_plugins.at(row).integrations());
	default:
		return QVariant();
	}
}

int GuiPluginModel::rowCount(const QModelIndex &) const
{
	return static_cast<int>(m_plugins.count());
}

QHash<int, QByteArray> GuiPluginModel::roleNames() const
{
	static const QHash<int, QByteArray> roles {
		{ PluginRole, "plugin" },
		{ NameRole, "name" },
		{ VersionRole, "version" },
		{ MinRequiredVersionRole, "minRequiredVersion" },
		{ MaxRequiredVersionRole, "maxRequiredVersion" },
		{ ColorRole, "color" },
		{ ResourceRole, "resource" },
		{ TranslationsRole, "translations" },
		{ IntegrationsRole, "integrations" }
	};
	return roles;
}

void GuiPluginModel::classBegin()
{
	m_complete = false;
}

void GuiPluginModel::componentComplete()
{
	m_complete = true;
	updatePlugins();
}

void GuiPluginModel::updatePlugins()
{
	if (!m_complete) {
		return;
	}

	GuiPluginLoader *singleton = GuiPluginLoader::create();
	const QVector<GuiPlugin> data = singleton->plugins();

	// grab all data from the singleton
	// perform a model reset
	beginResetModel();
	m_plugins = data;
	endResetModel();
	Q_EMIT countChanged();
}

GuiPlugin GuiPluginModel::pluginAt(int index) const
{
	if (index < 0 || index >= m_plugins.count()) {
		return GuiPlugin();
	}
	return m_plugins.at(index);
}

GuiPluginIntegrationModel::GuiPluginIntegrationModel(QObject *parent)
	: QAbstractListModel(parent)
{
	GuiPluginLoader *singleton = GuiPluginLoader::create();
	connect(singleton, &GuiPluginLoader::pluginsChanged,
		this, &GuiPluginIntegrationModel::updateIntegrations);
}

int GuiPluginIntegrationModel::count() const
{
	return static_cast<int>(m_integrations.count());
}

QVariant GuiPluginIntegrationModel::data(const QModelIndex &index, int role) const
{
	const int row = index.row();

	if(row < 0 || row >= m_integrations.count()) {
		return QVariant();
	}
	switch (role)
	{
	case IntegrationRole:
		return QVariant::fromValue<GuiPluginIntegration>(m_integrations.at(row));
	case PluginNameRole:
		return QVariant(m_integrations.at(row).pluginName());
	case PluginColorRole:
		return QVariant(GuiPluginLoader::create()->plugin(m_integrations.at(row).pluginName()).color());
	case TitleRole:
		return QVariant(m_integrations.at(row).title());
	case ProductIdRole:
		return QVariant(m_integrations.at(row).productId());
	case IconRole:
		return QVariant(m_integrations.at(row).icon());
	case UrlRole:
		return QVariant(m_integrations.at(row).url());
	case TypeRole:
		return QVariant(m_integrations.at(row).type());
	case CardTypeRole:
		return QVariant(m_integrations.at(row).cardType());
	default:
		return QVariant();
	}
}

int GuiPluginIntegrationModel::rowCount(const QModelIndex &) const
{
	return static_cast<int>(m_integrations.count());
}

QHash<int, QByteArray> GuiPluginIntegrationModel::roleNames() const
{
	static const QHash<int, QByteArray> roles {
		{ IntegrationRole, "integration" },
		{ PluginNameRole, "pluginName" },
		{ PluginColorRole, "pluginColor" },
		{ TitleRole, "title" },
		{ ProductIdRole, "productId" },
		{ IconRole, "icon" },
		{ UrlRole, "url" },
		{ TypeRole, "type" },
		{ CardTypeRole, "cardType" }
	};
	return roles;
}

void GuiPluginIntegrationModel::classBegin()
{
	m_complete = false;
}

void GuiPluginIntegrationModel::componentComplete()
{
	m_complete = true;
	updateIntegrations();
}

void GuiPluginIntegrationModel::updateIntegrations()
{
	if (!m_complete) {
		return;
	}

	QVector<GuiPluginIntegration> data;

	// grab all data from the singleton
	// and apply our filters.
	GuiPluginLoader *singleton = GuiPluginLoader::create();
	const QVector<GuiPlugin> plugins = singleton->plugins();
	for (const GuiPlugin &p : plugins) {
		const QVector<GuiPluginIntegration> integrations = p.integrations();
		for (const GuiPluginIntegration &i : integrations) {
			if ((m_type == GuiPluginLoader::InvalidIntegrationType || i.type() == m_type)
					&& (m_productId.isEmpty() || i.productId().compare(m_productId, Qt::CaseInsensitive) == 0)) {
				data.append(i);
			}
		}
	}

	// perform a model reset
	beginResetModel();
	m_integrations = data;
	endResetModel();
	Q_EMIT countChanged();
}

GuiPluginIntegration GuiPluginIntegrationModel::integrationAt(int index) const
{
	if (index < 0 || index >= m_integrations.count()) {
		return GuiPluginIntegration();
	}
	return m_integrations.at(index);
}

GuiPluginLoader::IntegrationType GuiPluginIntegrationModel::type() const
{
	return m_type;
}

void GuiPluginIntegrationModel::setType(GuiPluginLoader::IntegrationType t)
{
	if (m_type != t) {
		m_type = t;
		Q_EMIT typeChanged();
		updateIntegrations();
	}
}

QString GuiPluginIntegrationModel::productId() const
{
	return m_productId;
}

void GuiPluginIntegrationModel::setProductId(const QString &id)
{
	if (m_productId != id) {
		m_productId = id;
		Q_EMIT productIdChanged();
		updateIntegrations();
	}
}

