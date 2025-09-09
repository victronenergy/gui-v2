/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "evchargerstatusmodel.h"
#include "alldevicesmodel.h"
#include "enums.h"
#include "device.h"

#include <QQmlInfo>

using namespace Victron::VenusOS;

namespace {

bool includeServiceType(const QString &serviceType)
{
	return serviceType == QStringLiteral("evcharger");
}

}

EvChargerStatusModel::EvChargerStatusModel(QObject *parent)
	: QAbstractListModel(parent)
{
	// The model always has these three rows.
	m_statusInfos = {
		StatusInfo { static_cast<int>(Enums::Evcs_Status_Charging), QSet<QString>() },
		StatusInfo { static_cast<int>(Enums::Evcs_Status_Charged), QSet<QString>() },
		StatusInfo { static_cast<int>(Enums::Evcs_Status_Disconnected), QSet<QString>() },
	};

	addAllKnownDeviceStatuses();

	AllDevicesModel *allDevicesModel = AllDevicesModel::create();
	connect(allDevicesModel, &AllDevicesModel::rowsInserted,
			this, &EvChargerStatusModel::sourceDeviceAdded);
	connect(allDevicesModel, &AllDevicesModel::rowsAboutToBeRemoved,
			this, &EvChargerStatusModel::sourceDeviceAboutToBeRemoved);

	connect(allDevicesModel, &AllDevicesModel::modelAboutToBeReset, this, [this]() {
		beginResetModel();
		for (int i = 0; i < m_statusInfos.count(); ++i) {
			m_statusInfos[i].statusUids.clear();
		}
	});
	connect(allDevicesModel, &AllDevicesModel::modelReset, this, [this]() {
		addAllKnownDeviceStatuses();
		endResetModel();
	});
}

int EvChargerStatusModel::count() const
{
	return m_statusInfos.count();
}

QVariant EvChargerStatusModel::data(const QModelIndex &index, int role) const
{
	const int row = index.row();
	if (row < 0 || row >= m_statusInfos.count()) {
		return QVariant();
	}

	switch (role)
	{
	case StatusRole:
		return m_statusInfos.at(row).status;
	case StatusCountRole:
		return m_statusInfos.at(row).statusUids.count();
	default:
		break;
	}

	return QVariant();
}

int EvChargerStatusModel::rowCount(const QModelIndex &) const
{
	return count();
}

QHash<int, QByteArray> EvChargerStatusModel::roleNames() const
{
	static const QHash<int, QByteArray> roles {
		{ StatusRole, "status" },
		{ StatusCountRole, "statusCount" },
	};
	return roles;
}

void EvChargerStatusModel::addAllKnownDeviceStatuses()
{
	for (int i = 0; i < AllDevicesModel::create()->count(); ++i) {
		if (Device *device = AllDevicesModel::create()->deviceAt(i)) {
			if (includeServiceType(device->serviceType())) {
				addStatusFromDevice(device);
			}
		}
	}
}

void EvChargerStatusModel::sourceDeviceAdded(const QModelIndex &parent, int first, int last)
{
	QSet<int> updatedStatusIndexes;

	for (int i = first; i <= last; ++i) {
		if (Device *device = AllDevicesModel::create()->deviceAt(i)) {
			if (includeServiceType(device->serviceType())) {
				updatedStatusIndexes.unite(addStatusFromDevice(device));
			}
		}
	}

	emitStatusChanges(updatedStatusIndexes);
}

void EvChargerStatusModel::sourceDeviceAboutToBeRemoved(const QModelIndex &parent, int first, int last)
{
	QSet<int> updatedStatusIndexes;

	for (int i = first; i <= last; ++i) {
		Device *device = AllDevicesModel::create()->deviceAt(i);
		if (device && device->serviceItem()) {
			const int updatedStatusIndex = removeStatusUid(device->serviceItem()->uniqueId() + QStringLiteral("/Status"));
			if (updatedStatusIndex >= 0) {
				updatedStatusIndexes.insert(updatedStatusIndex);
			}
		}
	}

	emitStatusChanges(updatedStatusIndexes);
}

QSet<int> EvChargerStatusModel::addStatusItem(VeQItem *statusItem)
{
	QSet<int> updatedStatusIndexes;

	if (statusItem) {
		const QVariant value = statusItem->getValue();
		if (value.isValid()) {
			bool ok = false;
			int status = value.toInt(&ok);
			if (ok) {
				updatedStatusIndexes = setStatusForUid(statusItem->uniqueId(), status);
			}
		}
		connect(statusItem, &VeQItem::valueChanged, this, &EvChargerStatusModel::statusValueChanged);
	}

	return updatedStatusIndexes;
}

QSet<int> EvChargerStatusModel::addStatusFromDevice(Device *device)
{
	QSet<int> updatedStatusIndexes;

	if (!device) {
		qmlWarning(this) << "cannot initialize invalid device!";
		return updatedStatusIndexes;
	}

	if (VeQItem *serviceItem = device->serviceItem()) {
		// If the /Status child is available, add it to the model count for this status.
		updatedStatusIndexes = addStatusItem(device->serviceItem()->itemGet(QStringLiteral("Status")));

		// Connect signals in case /Status is added or removed.
		connect(serviceItem, &VeQItem::childAdded, this, [this](VeQItem *child) {
			if (child->id() == QStringLiteral("Status")) {
				emitStatusChanges(addStatusItem(child));
			}
		});
		connect(serviceItem, &VeQItem::childRemoved, this, [this](VeQItem *child) {
			if (child->id() == QStringLiteral("Status")) {
				const int updatedStatusIndex = removeStatusUid(child->uniqueId());
				if (updatedStatusIndex >= 0) {
					emit dataChanged(createIndex(updatedStatusIndex, 0), createIndex(updatedStatusIndex, 0), { StatusCountRole });
				}
			}
		});
	}
	return updatedStatusIndexes;
}

QSet<int> EvChargerStatusModel::setStatusForUid(const QString &statusItemUid, int status)
{
	QSet<int> updatedIndexes;

	for (int i = 0; i < m_statusInfos.count(); ++i) {
		if (m_statusInfos.at(i).status == status) {
			// This is the new status for the device with this uid. Add the uid to the set.
			m_statusInfos[i].statusUids.insert(statusItemUid);
			updatedIndexes.insert(i);
		} else if (m_statusInfos[i].statusUids.remove(statusItemUid)) {
			// This was the old status for the device with this uid, so it has been removed.
			updatedIndexes.insert(i);
		}
	}

	return updatedIndexes;
}

int EvChargerStatusModel::removeStatusUid(const QString &uid)
{
	for (int i = 0; i < m_statusInfos.count(); ++i) {
		if (m_statusInfos[i].statusUids.remove(uid)) {
			return i;
		}
	}
	return -1;
}

void EvChargerStatusModel::statusValueChanged(QVariant value)
{
	if (VeQItem *statusItem = qobject_cast<VeQItem *>(sender())) {
		bool ok = false;
		const int status = value.isValid() ? value.toInt(&ok) : -1;
		emitStatusChanges(setStatusForUid(statusItem->uniqueId(), ok ? status : -1));
	}
}

void EvChargerStatusModel::emitStatusChanges(const QSet<int> &indexes)
{
	for (auto it = indexes.constBegin(); it != indexes.constEnd(); ++it) {
		emit dataChanged(createIndex(*it, 0), createIndex(*it, 0), { StatusCountRole });
	}
}
