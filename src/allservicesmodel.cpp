/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "allservicesmodel.h"
#include "backendconnection.h"

#include <QQmlEngine>
#include <QQmlInfo>

using namespace Victron::VenusOS;

AllServicesModel::AllServicesModel(QObject *parent)
	: QAbstractListModel(parent)
{
	backendProducerChanged();
	connect(BackendConnection::create(), &BackendConnection::producerChanged,
			this, &AllServicesModel::backendProducerChanged);
}

int AllServicesModel::count() const
{
	return m_services.count();
}

VeQItem *AllServicesModel::itemAt(int index) const
{
	if (index >= 0 && index < m_services.count()) {
		return m_services.at(index).item;
	}
	return nullptr;
}

int AllServicesModel::rowCount(const QModelIndex &) const
{
	return count();
}

QVariant AllServicesModel::data(const QModelIndex &index, int role) const
{
	const int row = index.row();
	if (row < 0 || row >= m_services.count()) {
		return QVariant();
	}

	const ServiceInfo &serviceInfo = m_services.at(row);
	switch (role)
	{
	case UidRole:
		return serviceInfo.item ? serviceInfo.item->uniqueId() : QString();
	case ServiceTypeRole:
		return serviceInfo.serviceType;
	default:
		return QVariant();
	}
}

int AllServicesModel::indexOf(const QString &uid)
{
	for (int i = 0; i < m_services.count(); ++i) {
		if (m_services.at(i).item && m_services.at(i).item->uniqueId() == uid) {
			return i;
		}
	}
	return -1;
}

QHash<int, QByteArray> AllServicesModel::roleNames() const
{
	static QHash<int, QByteArray> roles = {
		{ UidRole, "uid" },
		{ ServiceTypeRole, "serviceType" },
	};
	return roles;
}

void AllServicesModel::backendProducerChanged()
{
	const int prevCount = count();
	beginResetModel();
	m_services.clear();

	if (VeQItem *servicesRoot = BackendConnection::create()->producer()
			? BackendConnection::create()->producer()->services()
			: nullptr) {
		if (BackendConnection::create()->type() == BackendConnection::MqttSource) {
			// For MQTT, the servicesRoot contains mqtt/<service-type> items; each of these items have
			// children, which are the services to be added.
			const VeQItem::Children &serviceTypes = servicesRoot->itemChildren();
			for (auto it = serviceTypes.constBegin(); it != serviceTypes.constEnd(); ++it) {
				// Add the <x> service for each mqtt/<service-type>/<x> service.
				addServicesFromChildrenOf(it.value());
			}
			// When a new service type is added to the root mqtt item, add its children as services.
			connect(servicesRoot, &VeQItem::childAdded, this, &AllServicesModel::addServicesFromChildrenOf);

			// When a service type is removed, remove all of its children from the service list.
			connect(servicesRoot, &VeQItem::childAboutToBeRemoved, this, [this](VeQItem *child) {
				child->disconnect(this);
				for (auto it = child->itemChildren().constBegin(); it != child->itemChildren().constEnd(); ++it) {
					removeServiceItem(it.value());
				}
			});
		} else {
			// For D-Bus and Mock, the servicesRoot has children, which are the services to be added.
			addServicesFromChildrenOf(servicesRoot);
		}
	}

	endResetModel();

	if (count() != prevCount) {
		emit countChanged();
	}
}

void AllServicesModel::serviceItemDiscovered(VeQItem *serviceItem)
{
	beginInsertRows(QModelIndex(), m_services.count(), m_services.count());
	m_services.append({ BackendConnection::create()->serviceTypeFromUid(serviceItem->uniqueId()), serviceItem });
	endInsertRows();
	emit countChanged();    
	emit serviceAdded(serviceItem);
}

void AllServicesModel::removeServiceItem(VeQItem *item)
{
	item->disconnect(this);
	emit serviceAboutToBeRemoved(item);

	if (const int serviceIndex = indexOf(item->uniqueId()); serviceIndex >= 0) {
		beginRemoveRows(QModelIndex(), serviceIndex, serviceIndex);
		m_services.removeAt(serviceIndex);
		// Note the item pointer is not deleted, as we do not own it.
		endRemoveRows();
		emit countChanged();
	}
}

void AllServicesModel::addServicesFromChildrenOf(VeQItem *parentItem)
{
	// Add all children of this item as services.
	const VeQItem::Children &services = parentItem->itemChildren();
	if (services.count() > 0) {
		beginInsertRows(QModelIndex(), 0, services.count() - 1);
		for (auto it = services.constBegin(); it != services.constEnd(); ++it) {
			m_services.append({ BackendConnection::create()->serviceTypeFromUid(it.value()->uniqueId()), it.value() });
		}
		endInsertRows();
		emit countChanged();
	}

	// When a child is added/removed, then add/remove the relevant service.
	connect(parentItem, &VeQItem::childAdded, this, &AllServicesModel::serviceItemDiscovered);
	connect(parentItem, &VeQItem::childAboutToBeRemoved, this, &AllServicesModel::removeServiceItem);
}

int AllServicesModel::indexOf(const QString &uid) const
{
	for (int i = 0; i < m_services.count(); ++i) {
		if (m_services.at(i).item && m_services.at(i).item->uniqueId() == uid) {
			return i;
		}
	}
	return -1;
}

AllServicesModel* AllServicesModel::create(QQmlEngine *engine, QJSEngine *)
{
	static AllServicesModel* instance = new AllServicesModel(engine);
	return instance;
}
