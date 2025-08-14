/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "customisations.h"
#include "logging.h"
#include "language.h"

#include <veutil/qt/ve_qitem.hpp>

#include <QResource>
#include <QTranslator>
#include <QCoreApplication>
#include <QDir>
#include <QFile>

#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonValue>

#include <QQmlInfo>
#include <QPointer>

using namespace Victron::VenusOS;

Customisations* Customisations::create(QQmlEngine *, QJSEngine *)
{
	static Customisations* instance = new Customisations(nullptr);
	return instance;
}

Customisations::Customisations(QObject *parent)
	: QObject(parent)
{
	Language *languageSingleton = Language::create();
	connect(languageSingleton, &Language::currentLanguageChanged,
		this, [this, languageSingleton] {
			for (const Customisation &c : qAsConst(m_customisations)) {
				installCustomisationTranslatorForLanguage(c.name(), languageSingleton->getCurrentLanguage());
			}
		});
}

Customisations::~Customisations()
{
}

QStringList Customisations::enabledCustomisations() const
{
	return m_enabledCustomisations;
}

void Customisations::setEnabledCustomisations(const QStringList &customisationNames)
{
	if (m_enabledCustomisations != customisationNames) {
		m_enabledCustomisations = customisationNames;
		Q_EMIT enabledCustomisationsChanged();
	}
}

QString Customisations::customisationsJson() const
{
	return m_customisationsJson;
}

void Customisations::setCustomisationsJson(const QString &json)
{
	if (m_customisationsJson != json) {
		m_customisationsJson = json;
		Q_EMIT customisationsJsonChanged();
		populateCustomisations();
	}
}

QVector<Customisation> Customisations::customisations() const
{
	return m_customisations;
}

Customisation Customisations::customisation(const QString &name) const
{
	for (const Customisation &c : qAsConst(m_customisations)) {
		if (c.name() == name) {
			return c;
		}
	}

	return Customisation();
}

// For debugging purposes only!
// On real systems, venus-platform will populate
// /Gui2/Customisations setting with appropriate data.
QString Customisations::loadFromFilesystem() const
{
	QStringList customisations;
	QStringList files;
	QDir customisationsDir;
#if defined(VENUS_DESKTOP_BUILD)
	// look in appdir/customisations/
	const QString appDir = QCoreApplication::applicationDirPath();
	customisationsDir = QDir(appDir);
	if (customisationsDir.cd(QStringLiteral("customisations"))) {
		files = customisationsDir.entryList({ QStringLiteral("*.json") }, QDir::Files);
	}
#elif !defined(VENUS_WEBASSEMBLY_BUILD)
	// look in /tmp/venus-gui-v2/customisations/
	customisationsDir = QDir(QStringLiteral("/tmp/venus-gui-v2/customisations/"));
	if (customisationsDir.exists()) {
		files = customisationsDir.entryList({ QStringLiteral("*.json") }, QDir::Files);
	}
#endif

	for (const QString &file : files) {
		QFile f(customisationsDir.absoluteFilePath(file));
		if (f.open(QIODevice::ReadOnly)) {
			const QString customisation = QString::fromUtf8(f.readAll());
			if (!customisation.isEmpty()) {
				customisations.append(customisation);
			}
		}
	}

	return QStringLiteral("[ %1 ]").arg(customisations.join(QChar(',')));
}

void Customisations::populateCustomisations()
{
	// first, unload any resources and translation catalogues
	// associated with the old data.
	unloadCustomisationData();

	// then, load the new data.
	QVector<Customisation> data;

	const QByteArray json = m_customisationsJson.toUtf8();
	const QJsonDocument doc = QJsonDocument::fromJson(json);
	const QJsonArray array = doc.array();

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
			qCWarning(venusGui) << "Ignoring customisation at index" << i;
			continue;
		}

		const QJsonObject customisation = v.toObject();
		const QString customisationName = customisation.value(QStringLiteral("name")).toString();
		const QString customisationVersion = customisation.value(QStringLiteral("version")).toString();
		const QString customisationResource = customisation.value(QStringLiteral("resource")).toString();
		const QByteArray customisationDecodedResource = QByteArray::fromBase64(customisationResource.toUtf8());
		if (customisationName.isEmpty()
				|| customisationVersion.isEmpty()
				|| customisationResource.isEmpty()
				|| customisationDecodedResource.isEmpty()
				|| !customisation.contains(QStringLiteral("integrations"))) {
			qCWarning(venusGui) << "Ignoring invalid customisation at index" << i;
			continue;
		}

		bool foundClash = false;
		for (const Customisation &c : qAsConst(data)) {
			if (customisationName == c.name()) {
				foundClash = true;
				break;
			}
		}
		if (foundClash) {
			qCWarning(venusGui) << "Ignoring clashing customisation at index" << i << ":" << customisationName;
			continue;
		}

		const QJsonValue iva = customisation.value(QStringLiteral("integrations"));
		if (!iva.isArray()) {
			qCWarning(venusGui) << "Ignoring customisation with invalid integrations at index" << i << ":" << customisationName;
			continue;
		}

		QVector<CustomisationIntegration> integrations;
		const QJsonArray customisationIntegrations = iva.toArray();
		for (qsizetype j = 0; j < customisationIntegrations.size(); ++j) {
			const QJsonValue iv = customisationIntegrations[j];
			if (!iv.isObject()) {
				qCWarning(venusGui) << "Ignoring integration at index" << j << "in customisation at index" << i << ":" << customisationName;
				continue;
			}

			// each entry in the integrations array looks like one of the following:
			// {
			//     type: 1, // new settings page under Settings/Integrations/Customisations
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

			if (integrationType == Customisations::InvalidIntegrationType
					|| integrationType > Customisations::QuickAccessPaneCard
					|| (integrationType == 2
						&& (integrationProductId.isEmpty() || integrationTitle.isEmpty()))
					|| ((integrationType == 3 || integrationType == 4)
						&& (integrationIcon.isEmpty()))
					|| (integrationType == 5
						&& (integrationCardType != 1 && integrationCardType != 2))
					|| integrationUrl.isEmpty()) {
				qCWarning(venusGui) << "Ignoring invalid integration at index" << j << "in customisation at index" << i << ":" << customisationName;
				continue;
			}

			CustomisationIntegration ci;
			ci.m_customisationName = customisationName;
			ci.m_type = static_cast<Customisations::IntegrationType>(integrationType);
			ci.m_url = QUrl(integrationUrl);
			if (integrationType == 2) {
				ci.m_productId = integrationProductId;
				ci.m_title = integrationTitle;
			} else if (integrationType == 3 || integrationType == 4) {
				ci.m_icon = QUrl(integrationIcon);
			} else if (integrationType == 5) {
				ci.m_cardType = static_cast<Customisations::QuickAccessPaneCardType>(integrationCardType);
			}
			integrations.append(ci);
		}

		if (integrations.size() == 0) {
			qCWarning(venusGui) << "Ignoring customisation without integrations at index" << i << ":" << customisationName;
			continue;
		}

		Customisation c;
		c.m_name = customisationName;
		c.m_color = determineColor(customisationName);
		c.m_version = customisationVersion;
		c.m_minRequiredVersion = customisation.value(QStringLiteral("minRequiredVersion")).toString();
		c.m_maxRequiredVersion = customisation.value(QStringLiteral("maxRequiredVersion")).toString();
		c.m_resource = customisationDecodedResource;
		c.m_integrations = integrations;

		const QJsonArray customisationTranslations = customisation.value(QStringLiteral("translations")).toArray();
		for (qsizetype t = 0; t < customisationTranslations.size(); ++t) {
			const QJsonValue tv = customisationTranslations.at(t);
			if (!tv.isString()) {
				qCWarning(venusGui) << "Ignoring invalid translation catalogue url for customisation at index" << i << ":" << customisationName;
				continue;
			}
			c.m_translations.append(QUrl(tv.toString()));
		}

		if (!loadCustomisationData(c)) {
			qCWarning(venusGui) << "Ignoring customisation with invalid data at index" << i << ":" << customisationName;
			continue;
		}

		data.append(c);
	}

	if (!m_customisations.isEmpty() || !data.isEmpty()) {
		m_customisations = data;
		Q_EMIT customisationsChanged();
	}
}

bool Customisations::loadCustomisationData(const Customisation &customisation)
{
	// ensure that the version matches.
	bool guiv2VersionMeetsRequirements = true; // TODO
	if (!guiv2VersionMeetsRequirements) {
		qCWarning(venusGui) << "Required version mismatch!";
		return false;
	}

	// load the resource data.
	if (!QResource::registerResource(reinterpret_cast<const uchar*>(customisation.m_resource.constData()))) {
		qCWarning(venusGui) << "Unable to load resource data for customisation" << customisation.name();
		return false;
	}

	// load the translation catalogues.
	Language *languageSingleton = Language::create();
	QLocale::Language currentLanguage = languageSingleton->getCurrentLanguage();
	installCustomisationTranslatorForLanguage(customisation.name(), QLocale::English);
	if (currentLanguage != QLocale::English) {
		installCustomisationTranslatorForLanguage(customisation.name(), currentLanguage);
	}

	return true;
}

void Customisations::unloadCustomisationData()
{
	for (const Customisation &customisation : qAsConst(m_customisations)) {
		QResource::unregisterResource(reinterpret_cast<const uchar*>(customisation.m_resource.constData()));
		const QHash<QLocale::Language, QTranslator*> hash(m_customisationTranslators.value(customisation.name()));
		for (QTranslator *t : hash.values()) {
			if (t) {
				QCoreApplication::removeTranslator(t);
				t->deleteLater();
			}
		}
	}
	m_currentTranslators.clear();
	m_customisationTranslators.clear();
}

bool Customisations::installCustomisationTranslatorForLanguage(const QString &customisationName, QLocale::Language language)
{
	QHash<QLocale::Language, QTranslator*> &hash = m_customisationTranslators[customisationName];
	const bool alreadyLoaded = hash.contains(language);
	QTranslator *translator = alreadyLoaded
			? hash.value(language)
			: new QTranslator(this);

	if (!alreadyLoaded) {
		if (translator->load(
				QLocale(language),
				customisationName,
				QLatin1String("_"),
				QStringLiteral(":/%1").arg(customisationName))) {
			qCDebug(venusGui) << "Successfully loaded translations for locale" << QLocale(language).name() << "for customisation" << customisationName;
			hash.insert(language, translator);
		} else {
			qCWarning(venusGui) << "Unable to load translations for locale" << QLocale(language).name() << "for customisation" << customisationName;
			translator->deleteLater();
			return false;
		}
	}

	// On language change, uninstall the old catalogue (unless it was the fallback English one).
	QPointer<QTranslator> currTranslator = m_currentTranslators.value(customisationName);
	if (currTranslator.data() && currTranslator.data() != hash.value(QLocale::English)) {
		if (!QCoreApplication::removeTranslator(currTranslator.data())) {
			qCWarning(venusGui) << "Unable to remove old translator for locale" << QLocale(language).name() << "for customisation" << customisationName;
		}
		m_currentTranslators.remove(customisationName);
	}

	// English is the fallback catalogue, so we have special handling for it:
	// ensure we install it the first time it is loaded, but never after that.
	// All other languages need to be installed, as we will remove them on language change.
	if (language != QLocale::English || !alreadyLoaded) {
		if (!QCoreApplication::installTranslator(translator)) {
			qCWarning(venusGui) << "Unable to install translator for locale" << QLocale(language).name() << "for customisation" << customisationName;
			translator->deleteLater();
			if (hash.value(language) == translator) {
				hash.remove(language);
			}
			return false;
		}
	}

	m_currentTranslators.insert(customisationName, translator);

	return true;
}

QColor Customisations::determineColor(const QString &customisationName) const
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

	const size_t hash = qHash(customisationName);
	const qsizetype idx = qAbs(hash) % colors[0].size();

	for (qsizetype i = 0; i < colors.size(); ++i) {
		const QColor wanted = colors[i][idx];
		bool alreadyUsed = false;
		for (const Customisation &c : customisations()) {
			if (c.color() == wanted) {
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

CustomisationsModel::CustomisationsModel(QObject *parent)
	: QAbstractListModel(parent)
{
	Customisations *singleton = Customisations::create();
	connect(singleton, &Customisations::customisationsChanged,
		this, &CustomisationsModel::updateCustomisations);
}

int CustomisationsModel::count() const
{
	return static_cast<int>(m_customisations.count());
}

QVariant CustomisationsModel::data(const QModelIndex &index, int role) const
{
	const int row = index.row();

	if(row < 0 || row >= m_customisations.count()) {
		return QVariant();
	}
	switch (role)
	{
	case CustomisationRole:
		return QVariant::fromValue<Customisation>(m_customisations.at(row));
	case NameRole:
		return QVariant(m_customisations.at(row).name());
	case VersionRole:
		return QVariant(m_customisations.at(row).version());
	case MinRequiredVersionRole:
		return QVariant(m_customisations.at(row).minRequiredVersion());
	case MaxRequiredVersionRole:
		return QVariant(m_customisations.at(row).maxRequiredVersion());
	case ColorRole:
		return QVariant(m_customisations.at(row).color());
	case ResourceRole:
		return QVariant(m_customisations.at(row).resource());
	case TranslationsRole:
		return QVariant::fromValue<QVector<QUrl> >(m_customisations.at(row).translations());
	case IntegrationsRole:
		return QVariant::fromValue<QVector<CustomisationIntegration> >(m_customisations.at(row).integrations());
	default:
		return QVariant();
	}
}

int CustomisationsModel::rowCount(const QModelIndex &) const
{
	return static_cast<int>(m_customisations.count());
}

QHash<int, QByteArray> CustomisationsModel::roleNames() const
{
	static const QHash<int, QByteArray> roles {
		{ CustomisationRole, "customisation" },
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

void CustomisationsModel::classBegin()
{
	m_complete = false;
}

void CustomisationsModel::componentComplete()
{
	m_complete = true;
	updateCustomisations();
}

void CustomisationsModel::updateCustomisations()
{
	if (!m_complete) {
		return;
	}

	Customisations *singleton = Customisations::create();
	const QVector<Customisation> data = singleton->customisations();

	// grab all data from the singleton
	// perform a model reset
	beginResetModel();
	m_customisations = data;
	endResetModel();
	Q_EMIT countChanged();
}

Customisation CustomisationsModel::customisationAt(int index) const
{
	if (index < 0 || index >= m_customisations.count()) {
		return Customisation();
	}
	return m_customisations.at(index);
}

CustomisationIntegrationsModel::CustomisationIntegrationsModel(QObject *parent)
	: QAbstractListModel(parent)
{
	Customisations *singleton = Customisations::create();
	connect(singleton, &Customisations::customisationsChanged,
		this, &CustomisationIntegrationsModel::updateIntegrations);
}

int CustomisationIntegrationsModel::count() const
{
	return static_cast<int>(m_integrations.count());
}

QVariant CustomisationIntegrationsModel::data(const QModelIndex &index, int role) const
{
	const int row = index.row();

	if(row < 0 || row >= m_integrations.count()) {
		return QVariant();
	}
	switch (role)
	{
	case IntegrationRole:
		return QVariant::fromValue<CustomisationIntegration>(m_integrations.at(row));
	case CustomisationNameRole:
		return QVariant(m_integrations.at(row).customisationName());
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

int CustomisationIntegrationsModel::rowCount(const QModelIndex &) const
{
	return static_cast<int>(m_integrations.count());
}

QHash<int, QByteArray> CustomisationIntegrationsModel::roleNames() const
{
	static const QHash<int, QByteArray> roles {
		{ IntegrationRole, "integration" },
		{ CustomisationNameRole, "customisationName" },
		{ TitleRole, "title" },
		{ ProductIdRole, "productId" },
		{ IconRole, "icon" },
		{ UrlRole, "url" },
		{ TypeRole, "type" },
		{ CardTypeRole, "cardType" }
	};
	return roles;
}

void CustomisationIntegrationsModel::classBegin()
{
	m_complete = false;
}

void CustomisationIntegrationsModel::componentComplete()
{
	m_complete = true;
	updateIntegrations();
}

void CustomisationIntegrationsModel::updateIntegrations()
{
	if (!m_complete) {
		return;
	}

	QVector<CustomisationIntegration> data;

	// grab all data from the singleton
	// and apply our filters.
	Customisations *singleton = Customisations::create();
	const QVector<Customisation> customisations = singleton->customisations();
	for (const Customisation &c : customisations) {
		const QVector<CustomisationIntegration> integrations = c.integrations();
		for (const CustomisationIntegration i : integrations) {
			if ((m_type == Customisations::InvalidIntegrationType || i.type() == m_type)
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

CustomisationIntegration CustomisationIntegrationsModel::integrationAt(int index) const
{
	if (index < 0 || index >= m_integrations.count()) {
		return CustomisationIntegration();
	}
	return m_integrations.at(index);
}

Customisations::IntegrationType CustomisationIntegrationsModel::type() const
{
	return m_type;
}

void CustomisationIntegrationsModel::setType(Customisations::IntegrationType t)
{
	if (m_type != t) {
		m_type = t;
		Q_EMIT typeChanged();
		updateIntegrations();
	}
}

QString CustomisationIntegrationsModel::productId() const
{
	return m_productId;
}

void CustomisationIntegrationsModel::setProductId(const QString &id)
{
	if (m_productId != id) {
		m_productId = id;
		Q_EMIT productIdChanged();
		updateIntegrations();
	}
}

