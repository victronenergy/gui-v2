#include "systemservicelistener.h"
#include "allservicesmodel.h"

using namespace Victron::VenusOS;

SystemServiceListener* SystemServiceListener::create(QQmlEngine *engine, QJSEngine *)
{
	static SystemServiceListener* instance = new SystemServiceListener(engine);
	return instance;
}

SystemServiceListener::SystemServiceListener(QObject *parent)
	: QObject(parent), m_allServicesModel(AllServicesModel::create())
{
	connect(m_allServicesModel, &AllServicesModel::serviceAdded,
		this, &SystemServiceListener::handleServiceAdded);
	connect(m_allServicesModel, &AllServicesModel::serviceAboutToBeRemoved,
		this, &SystemServiceListener::handleServiceAboutToBeRemoved);
	for (int i = 0; i < m_allServicesModel->count(); ++i) {
		handleServiceAdded(m_allServicesModel->itemAt(i));
	}
}

void SystemServiceListener::handleServiceAdded(VeQItem *serviceItem)
{
	const QString serviceType = m_allServicesModel ? m_allServicesModel->serviceTypeOf(serviceItem->uniqueId()) : QString();
	if (serviceType == QStringLiteral("settings")) {
		listenToSettingsItem(serviceItem);
	} else if (serviceType == QStringLiteral("platform")) {
		listenToPlatformItem(serviceItem);
	}
}

void SystemServiceListener::handleServiceAboutToBeRemoved(VeQItem *serviceItem)
{
	const QString serviceType = m_allServicesModel ? m_allServicesModel->serviceTypeOf(serviceItem->uniqueId()) : QString();
	if (serviceType == QStringLiteral("settings")) {
		serviceItem->disconnect(this);
		m_settingsItem.clear();
	} else if (serviceType == QStringLiteral("platform")) {
		serviceItem->disconnect(this);
		m_platformItem.clear();
	}
}

void SystemServiceListener::listenToSettingsItem(VeQItem *serviceItem)
{
	auto updateSettingsOnline = [this] {
		const bool oldOnline = m_settingsOnline;
		m_settingsOnline = m_settingsItem->getState() != VeQItem::Offline;
		if (m_settingsOnline != oldOnline) {
			emit settingsOnlineChanged();
		}
	};

	if (m_settingsItem) {
		m_settingsItem->disconnect(this);
	}
	m_settingsItem = serviceItem;
	connect(m_settingsItem, &VeQItem::stateChanged,
		[this, updateSettingsOnline] (VeQItem::State) {
			updateSettingsOnline();
		});
	updateSettingsOnline();
}

void SystemServiceListener::listenToPlatformItem(VeQItem *serviceItem)
{
	auto updatePlatformOnline = [this] {
		const bool oldOnline = m_platformOnline;
		m_platformOnline = m_platformItem->getState() != VeQItem::Offline;
		if (m_platformOnline != oldOnline) {
			emit platformOnlineChanged();
		}
	};

	if (m_platformItem) {
		m_platformItem->disconnect(this);
	}
	m_platformItem = serviceItem;
	connect(m_platformItem, &VeQItem::stateChanged,
		[this, updatePlatformOnline] (VeQItem::State state) {
			updatePlatformOnline();
		});
	updatePlatformOnline();
}

