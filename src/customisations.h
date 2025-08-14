/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_CUSTOMISATIONS_H
#define VICTRON_GUIV2_CUSTOMISATIONS_H

#include <QAbstractListModel>
#include <QUrl>
#include <QString>
#include <QColor>
#include <QVector>
#include <QPointer>

#include <QLocale>
#include <QTranslator>

#include <qqmlintegration.h>
#include <QQmlEngine>
#include <QQmlParserStatus>

namespace Victron {
namespace VenusOS {

class Customisation;

// needs to be initialised before loading the UI.
// any changes to customisations property will result in rebuild UI.
class Customisations : public QObject
{
	Q_OBJECT
	QML_ELEMENT
	QML_SINGLETON

	Q_PROPERTY(QStringList enabledCustomisations READ enabledCustomisations WRITE setEnabledCustomisations NOTIFY enabledCustomisationsChanged)
	Q_PROPERTY(QString customisationsJson READ customisationsJson WRITE setCustomisationsJson NOTIFY customisationsJsonChanged)
	Q_PROPERTY(QVector<Customisation> customisations READ customisations NOTIFY customisationsChanged)

public:
	enum IntegrationType {
		InvalidIntegrationType,
		CustomisationSettingsPage,
		DeviceListSettingsPage,
		NavigationPage,
		QuickAccessPane,
		QuickAccessPaneCard
	};
	Q_ENUM(IntegrationType)

	enum QuickAccessPaneCardType {
		InvalidCardType,
		ControlsCard,
		SwitchesCard
	};
	Q_ENUM(QuickAccessPaneCardType)

	static Customisations* create(QQmlEngine *engine = nullptr, QJSEngine *jsEngine = nullptr);
	Customisations() = delete;
	Customisations(const Customisations&) = delete;
	Customisations& operator=(const Customisations&) = delete;
	Customisations(QObject *parent);
	~Customisations() override;

	QStringList enabledCustomisations() const;
	void setEnabledCustomisations(const QStringList &customisationNames);

	QString customisationsJson() const;
	void setCustomisationsJson(const QString &json);

	QVector<Customisation> customisations() const;
	Q_INVOKABLE Customisation customisation(const QString &name) const;
	Q_INVOKABLE QString loadFromFilesystem() const;
	Q_INVOKABLE void populateCustomisations();

Q_SIGNALS:
	void enabledCustomisationsChanged();
	void customisationsJsonChanged();
	void customisationsChanged();

private:
	QColor determineColor(const QString &customisationName) const;
	bool loadCustomisationData(const Customisation &customisation);
	void unloadCustomisationData();
	bool installCustomisationTranslatorForLanguage(const QString &customisationName, QLocale::Language language);
	QStringList m_enabledCustomisations;
	QString m_customisationsJson;
	QVector<Customisation> m_customisations;
	QHash<QString, QHash<QLocale::Language, QTranslator*> > m_customisationTranslators;
	QHash<QString, QPointer<QTranslator> > m_currentTranslators;
};

/*
Each customisation can specify one or more integrations.

Each integration is associated with a customisation,
which is identified by the customisationName property.

There are currently 5 supported types of integrations:
  1) a customisation settings page
     - causes the customisation entry in Settings/Integrations/Customisations
       to become a drill-down to the custom settings page.
  2) a device list settings page
     - causes a new navigation list item to be injected into
       the device list settings page associated with any
       device whose productId matches the specified productId.
  3) a navigation page
     - causes a new icon to be added to the navigation bar,
       and an associated page to be added to be navigation
       swipe view.
  4) a quick access pane
     - causes a new icon to be added to the status bar,
       which opens an associated custom quick access pane
       when pressed.
  5) a quick access pane card
     - causes a new card to be injected into one of the
       existing quick action pane views (i.e. either a
       controls card, or a switches card).

** TODO: actually support 3/4/5. **
In the prototype, only type 1 and 2 are supported.
*/
class CustomisationIntegration
{
	Q_GADGET

	// valid for all integrations:
	Q_PROPERTY(QString customisationName READ customisationName)
	Q_PROPERTY(Customisations::IntegrationType type READ type)
	Q_PROPERTY(QUrl url READ url)

	// valid for navigation page and quick access pane integrations
	Q_PROPERTY(QUrl icon READ icon)

	// valid for device list settings page integrations only
	Q_PROPERTY(QString title READ title)
	Q_PROPERTY(QString productId READ productId)

	// valid for quick access pane card integrations only
	Q_PROPERTY(Customisations::QuickAccessPaneCardType cardType READ cardType)

public:
	QString customisationName() const { return m_customisationName; }
	QString title() const { return m_title; }
	QString productId() const { return m_productId; }
	QUrl icon() const { return m_icon; }
	QUrl url() const { return m_url; }
	Customisations::IntegrationType type() const { return m_type; }
	Customisations::QuickAccessPaneCardType cardType() const { return m_cardType; }

private:
	friend class Customisations;
	QString m_customisationName;
	QString m_title;
	QString m_productId;
	QUrl m_icon;
	QUrl m_url;
	Customisations::IntegrationType m_type = Customisations::InvalidIntegrationType;
	Customisations::QuickAccessPaneCardType m_cardType = Customisations::InvalidCardType;
};

/*
Each customisation is specified as a .json blob
which is generated by the customisation-compiler.sh script.
Each customisation can include one or more integrations.
*/
class Customisation
{
	Q_GADGET
	Q_PROPERTY(QString name READ name)
	Q_PROPERTY(QString version READ version)
	Q_PROPERTY(QString minRequiredVersion READ minRequiredVersion)
	Q_PROPERTY(QString maxRequiredVersion READ maxRequiredVersion)
	Q_PROPERTY(QString resource READ resource)
	Q_PROPERTY(QVector<QUrl> translations READ translations)
	Q_PROPERTY(QVector<CustomisationIntegration> integrations READ integrations)
	Q_PROPERTY(QColor color READ color)

public:
	QString name() const { return m_name; }
	QString version() const { return m_version; }
	QString minRequiredVersion() const { return m_minRequiredVersion; }
	QString maxRequiredVersion() const { return m_maxRequiredVersion; }
	QString resource() const { return QString::fromUtf8(m_resource.toBase64()); }
	QVector<QUrl> translations() const { return m_translations; }
	QVector<CustomisationIntegration> integrations() const { return m_integrations; }
	QColor color() const { return m_color; }

private:
	friend class Customisations;
	QString m_name;
	QString m_version;
	QString m_minRequiredVersion;
	QString m_maxRequiredVersion;
	QColor m_color;
	QByteArray m_resource;
	QVector<QUrl> m_translations;
	QVector<CustomisationIntegration> m_integrations;
};

class CustomisationsModel : public QAbstractListModel, public QQmlParserStatus
{
	Q_OBJECT
	QML_ELEMENT
	Q_INTERFACES(QQmlParserStatus)

	Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
	enum RoleNames {
		CustomisationRole = Qt::UserRole,
		NameRole,
		VersionRole,
		MinRequiredVersionRole,
		MaxRequiredVersionRole,
		ColorRole,
		ResourceRole,
		TranslationsRole,
		IntegrationsRole
	};

	explicit CustomisationsModel(QObject *parent = nullptr);

	int rowCount(const QModelIndex &parent) const override;
	QVariant data(const QModelIndex& index, int role) const override;

	int count() const;
	Q_INVOKABLE Customisation customisationAt(int index) const;

Q_SIGNALS:
	void countChanged();

protected:
	QHash<int, QByteArray> roleNames() const override;

	// QQmlParserStatus
	void classBegin() override;
	void componentComplete() override;

private:
	void updateCustomisations();
	QVector<Customisation> m_customisations;
	bool m_complete = false;
};

class CustomisationIntegrationsModel : public QAbstractListModel, public QQmlParserStatus
{
	Q_OBJECT
	QML_ELEMENT
	Q_INTERFACES(QQmlParserStatus)

	Q_PROPERTY(int count READ count NOTIFY countChanged)

	// filtering
	Q_PROPERTY(Customisations::IntegrationType type READ type WRITE setType NOTIFY typeChanged)
	Q_PROPERTY(QString productId READ productId WRITE setProductId NOTIFY productIdChanged)
	// TODO: add filtering for cardType also.

public:
	enum RoleNames {
		IntegrationRole = Qt::UserRole,
		CustomisationNameRole,
		TitleRole,
		ProductIdRole,
		IconRole,
		UrlRole,
		TypeRole,
		CardTypeRole
	};

	explicit CustomisationIntegrationsModel(QObject *parent = nullptr);

	int rowCount(const QModelIndex &parent) const override;
	QVariant data(const QModelIndex& index, int role) const override;

	int count() const;
	Q_INVOKABLE CustomisationIntegration integrationAt(int index) const;

	Customisations::IntegrationType type() const;
	void setType(Customisations::IntegrationType t);
	QString productId() const;
	void setProductId(const QString &productId);

Q_SIGNALS:
	void countChanged();
	void typeChanged();
	void productIdChanged();

protected:
	QHash<int, QByteArray> roleNames() const override;

	// QQmlParserStatus
	void classBegin() override;
	void componentComplete() override;

private:
	void updateIntegrations();
	QVector<CustomisationIntegration> m_integrations;
	QString m_productId;
	Customisations::IntegrationType m_type = Customisations::InvalidIntegrationType;
	bool m_complete = false;
};

} /* VenusOS */
} /* Victron */

Q_DECLARE_METATYPE(Victron::VenusOS::CustomisationIntegration)
Q_DECLARE_METATYPE(Victron::VenusOS::Customisation)

#endif // VICTRON_GUIV2_CUSTOMISATIONS_H
