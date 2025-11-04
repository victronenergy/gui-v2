/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "evchargerdevicemodel.h"
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

void EvChargerDeviceModel::EvCharger::disconnect(EvChargerDeviceModel *model)
{
	if (statusItem) {
		statusItem->disconnect(model);
	}
	if (positionItem) {
		positionItem->disconnect(model);
	}
	if (powerItem) {
		powerItem->disconnect(model);
	}
	if (currentItem) {
		currentItem->disconnect(model);
	}
	if (energyItem) {
		energyItem->disconnect(model);
	}
}

EvChargerDeviceModel::EvChargerDeviceModel(QObject *parent)
	: QAbstractListModel(parent)
{
	addAvailableEvChargers();
	updateTotals();
	updateFirstEvCharger();

	AllDevicesModel *allDevicesModel = AllDevicesModel::create();
	connect(allDevicesModel, &AllDevicesModel::rowsInserted,
			this, &EvChargerDeviceModel::sourceDeviceAdded);
	connect(allDevicesModel, &AllDevicesModel::rowsAboutToBeRemoved,
			this, &EvChargerDeviceModel::sourceDeviceAboutToBeRemoved);
	connect(allDevicesModel, &AllDevicesModel::modelAboutToBeReset, [this]() {
		beginResetModel();
		clearEvChargers();
	});
	connect(allDevicesModel, &AllDevicesModel::modelReset, [this]() {
		addAvailableEvChargers();
		endResetModel();
		updateTotals();
		updateFirstEvCharger();
		emit countChanged();
	});
}

EvChargerDeviceModel::~EvChargerDeviceModel()
{
	if (m_timerId > 0) {
		killTimer(m_timerId);
		m_timerId = 0;
	}
}

int EvChargerDeviceModel::count() const
{
	return m_chargers.count();
}

Device *EvChargerDeviceModel::firstObject() const
{
	return deviceAt(0);
}

qreal EvChargerDeviceModel::totalPower() const
{
	return m_totalPower;
}

qreal EvChargerDeviceModel::totalCurrent() const
{
	return m_totalCurrent;
}

qreal EvChargerDeviceModel::totalEnergy() const
{
	return m_totalEnergy;
}

qreal EvChargerDeviceModel::inputPower() const
{
	return m_inputPower;
}

qreal EvChargerDeviceModel::outputPower() const
{
	return m_outputPower;
}

int EvChargerDeviceModel::inputCount() const
{
	return m_inputCount;
}

int EvChargerDeviceModel::outputCount() const
{
	return m_outputCount;
}

QVariant EvChargerDeviceModel::data(const QModelIndex &index, int role) const
{
	const int row = index.row();
	if (row < 0 || row >= m_chargers.count()) {
		return QVariant();
	}

	switch (role)
	{
	case DeviceRole:
		return QVariant::fromValue<Device *>(m_chargers.at(row).device);
	case NameRole:
		return m_chargers.at(row).device ? m_chargers.at(row).device->name() : QString();
	case StatusRole:
		if (m_chargers.at(row).statusItem) {
			const QVariant value = m_chargers.at(row).statusItem->getValue();
			if (value.isValid()) {
				bool ok = false;
				const int status = value.toInt(&ok);
				return ok ? status : -1;
			}
		}
		break;
	case EnergyRole:
		return m_chargers.at(row).energy;
	default:
		break;
	}

	return QVariant();
}

int EvChargerDeviceModel::rowCount(const QModelIndex &) const
{
	return count();
}

QHash<int, QByteArray> EvChargerDeviceModel::roleNames() const
{
	static const QHash<int, QByteArray> roles {
		{ DeviceRole, "device" },
		{ NameRole, "name" },
		{ StatusRole, "status" },
		{ EnergyRole, "energy" },
	};
	return roles;
}

Device *EvChargerDeviceModel::deviceAt(int index) const
{
	if (index >= 0 && index < m_chargers.count()) {
		return m_chargers.at(index).device;
	}
	return nullptr;
}

int EvChargerDeviceModel::indexOf(const QString &serviceUid) const
{
	for (int i = 0; i < m_chargers.count(); ++i) {
		if (m_chargers.at(i).device && m_chargers.at(i).device->serviceUid() == serviceUid) {
			return i;
		}
	}
	return -1;
}

void EvChargerDeviceModel::clearEvChargers()
{
	for (EvCharger &meter : m_chargers) {
		meter.disconnect(this);
	}
	m_chargers.clear();
}

void EvChargerDeviceModel::addAvailableEvChargers()
{
	AllDevicesModel *allDevicesModel = AllDevicesModel::create();
	for (int i = 0; i < allDevicesModel->count(); ++i) {
		if (Device *device = allDevicesModel->deviceAt(i)) {
			if (includeServiceType(device->serviceType())) {
				addEvChargerDevice(device);
			}
		}
	}
}

void EvChargerDeviceModel::sourceDeviceAdded(const QModelIndex &parent, int first, int last)
{
	bool chargerAdded = false;
	for (int i = first; i <= last; ++i) {
		if (Device *device = AllDevicesModel::create()->deviceAt(i)) {
			if (includeServiceType(device->serviceType())) {
				beginInsertRows(QModelIndex(), m_chargers.count(), m_chargers.count());
				addEvChargerDevice(device);
				endInsertRows();
				chargerAdded = true;
			}
		}
	}
	if (chargerAdded) {
		updateTotals();
		updateFirstEvCharger();
		emit countChanged();
	}
}

void EvChargerDeviceModel::sourceDeviceAboutToBeRemoved(const QModelIndex &parent, int first, int last)
{
	for (int i = first; i <= last; ++i) {
		Device *device = AllDevicesModel::create()->deviceAt(i);
		if (!device) {
			qmlWarning(this) << "remove: cannot find device for index:" << i;
			continue;
		}
		const int deviceIndex = indexOf(device->serviceUid());
		if (deviceIndex >= 0 && deviceIndex < m_chargers.count()) {
			beginRemoveRows(QModelIndex(), deviceIndex, deviceIndex);
			m_chargers[deviceIndex].disconnect(this);
			m_chargers.removeAt(deviceIndex);
			endRemoveRows();
		}
	}
	updateTotals();
	updateFirstEvCharger();
	emit countChanged();
}

void EvChargerDeviceModel::addEvChargerDevice(Device *device)
{
	if (!device) {
		qmlWarning(this) << "cannot initialize invalid device!";
		return;
	}

	if (VeQItem *serviceItem = device->serviceItem()) {
		EvCharger info;
		info.device = device;

		connect(device, &Device::nameChanged, this, [this, serviceItem]() {
			if (const int deviceIndex = indexOf(serviceItem->uniqueId()); deviceIndex >= 0) {
				emit dataChanged(createIndex(deviceIndex, 0), createIndex(deviceIndex, 0), { NameRole });
			}
		});

		// For the measurement items (power, current and energy), assume they are always available
		// (or will become available), so use itemGetOrCreate() instead of itemGet().
		info.powerItem = serviceItem->itemGetOrCreate(QStringLiteral("Ac/Power"));
		if (info.powerItem) {
			connect(info.powerItem, &VeQItem::valueChanged,
					this, &EvChargerDeviceModel::scheduleUpdateTotals);
		}
		info.currentItem = serviceItem->itemGetOrCreate(QStringLiteral("Current"));
		if (info.currentItem) {
			connect(info.currentItem, &VeQItem::valueChanged,
					this, &EvChargerDeviceModel::scheduleUpdateTotals);
		}
		info.energyItem = serviceItem->itemGetOrCreate(QStringLiteral("Session/Energy"));
		if (info.energyItem) {
			connect(info.energyItem, &VeQItem::valueChanged,
					this, &EvChargerDeviceModel::scheduleUpdateTotals);
		}

		// The Status and Position may not be available (e.g. Status is not set for energy meters
		// and Position may not be present on older devices), so for those, call itemGet() and avoid
		// creating them unnecessarily.
		info.statusItem = serviceItem->itemGet(QStringLiteral("Status"));
		if (info.statusItem) {
			connect(info.statusItem, &VeQItem::valueChanged,
					this, &EvChargerDeviceModel::chargerStatusChanged);
		}
		info.positionItem = serviceItem->itemGet(QStringLiteral("Position"));
		if (info.positionItem) {
			connect(info.positionItem, &VeQItem::valueChanged,
					this, &EvChargerDeviceModel::scheduleUpdateTotals);
		}
		connect(serviceItem, &VeQItem::childAdded, this, &EvChargerDeviceModel::serviceChildAdded);
		// Don't to worry about when a child is removed, as the VeQItem QPointer will be cleared
		// automatically when the VeQItem is deleted.

		m_chargers.append(info);
	}
}

void EvChargerDeviceModel::chargerStatusChanged(QVariant value)
{
	Q_UNUSED(value)

	if (VeQItem *statusItem = qobject_cast<VeQItem *>(sender())) {
		if (VeQItem *serviceItem = statusItem->itemParent()) {
			if (const int deviceIndex = indexOf(serviceItem->uniqueId()); deviceIndex >= 0) {
				emit dataChanged(createIndex(deviceIndex, 0), createIndex(deviceIndex, 0), { StatusRole });
			}
		}
	}
}

void EvChargerDeviceModel::serviceChildAdded(VeQItem *child)
{
	if (child->id() != QStringLiteral("Status")
			&& child->id() != QStringLiteral("Position")) {
		return;
	}

	if (VeQItem *serviceItem = child->itemParent()) {
		if (const int deviceIndex = indexOf(serviceItem->uniqueId()); deviceIndex >= 0) {
			if (child->id() == QStringLiteral("Status")) {
				m_chargers[deviceIndex].statusItem = child;
				connect(m_chargers[deviceIndex].statusItem, &VeQItem::valueChanged,
						this, &EvChargerDeviceModel::chargerStatusChanged);
			} else if (child->id() == QStringLiteral("Position")) {
				m_chargers[deviceIndex].positionItem = child;
				connect(m_chargers[deviceIndex].positionItem, &VeQItem::valueChanged,
						this, &EvChargerDeviceModel::scheduleUpdateTotals);
			}
		}
	}
}

void EvChargerDeviceModel::scheduleUpdateTotals()
{
	if (m_timerId == 0) {
		m_timerId = startTimer(1000);
	}
}

void EvChargerDeviceModel::timerEvent(QTimerEvent *event)
{
	Q_UNUSED(event)

	if (m_timerId > 0) {
		killTimer(m_timerId);
		m_timerId = 0;
	}
	updateTotals();
}

void EvChargerDeviceModel::updateTotals()
{
	qreal totalPower = 0;
	qreal totalCurrent = 0;
	qreal totalEnergy = 0;
	qreal totalInputPower = 0;
	qreal totalOutputPower = 0;
	int inputCount = 0;
	int outputCount = 0;

	if (m_chargers.count() == 0) {
		totalPower = qQNaN();
		totalCurrent = qQNaN();
		totalEnergy = qQNaN();
	} else {
		for (int i = 0; i < m_chargers.count(); ++i) {
			EvCharger &info = m_chargers[i];
			qreal power = 0;
			qreal prevEnergy = info.energy;
			if (info.powerItem) {
				const QVariant value = info.powerItem->getValue();
				if (value.isValid()) {
					power = value.value<qreal>();
					totalPower += power;
				}
			}
			if (info.currentItem) {
				const QVariant value = info.currentItem->getValue();
				if (value.isValid()) {
					totalCurrent += value.value<qreal>();
				}
			}
			if (info.energyItem) {
				const QVariant value = info.energyItem->getValue();
				if (value.isValid()) {
					info.energy = value.value<qreal>();
					totalEnergy += info.energy;
				}
			}
			if (info.positionItem) {
				const QVariant value = info.positionItem->getValue();
				if (value.isValid()) {
					bool ok = false;
					const int position = value.toInt(&ok);
					if (ok) {
						if (position == Enums::AcPosition_AcOutput) {
							totalOutputPower += power;
							outputCount++;
						} else if (position == Enums::AcPosition_AcInput) {
							totalInputPower += power;
							inputCount++;
						}
					}
				}
			}
			if (prevEnergy != info.energy) {
				emit dataChanged(createIndex(i, 0), createIndex(i, 0), { EnergyRole });
			}
		}
	}

	if (inputCount == 0) {
		totalInputPower = qQNaN();
	}
	if (outputCount == 0) {
		totalOutputPower = qQNaN();
	}

	if (m_totalPower != totalPower) {
		m_totalPower = totalPower;
		emit totalPowerChanged();
	}
	if (m_totalCurrent != totalCurrent) {
		m_totalCurrent = totalCurrent;
		emit totalCurrentChanged();
	}
	if (m_totalEnergy != totalEnergy) {
		m_totalEnergy = totalEnergy;
		emit totalEnergyChanged();
	}
	if (m_inputPower != totalInputPower) {
		m_inputPower = totalInputPower;
		emit inputPowerChanged();
	}
	if (m_outputPower != totalOutputPower) {
		m_outputPower = totalOutputPower;
		emit outputPowerChanged();
	}
	if (m_inputCount != inputCount) {
		m_inputCount = inputCount;
		emit inputCountChanged();
	}
	if (m_outputCount != outputCount) {
		m_outputCount = outputCount;
		emit outputCountChanged();
	}
}

void EvChargerDeviceModel::updateFirstEvCharger()
{
	const QString prevFirstUid = m_firstUid;
	m_firstUid = deviceAt(0) ? deviceAt(0)->serviceUid() : QString();

	if (prevFirstUid != m_firstUid) {
		emit firstObjectChanged();
	}
}

SortedEvChargerDeviceModel::SortedEvChargerDeviceModel(QObject *parent)
	: QSortFilterProxyModel(parent)
{
	setSortLocaleAware(true);
	setSortRole(EvChargerDeviceModel::NameRole);
	sort(0, Qt::AscendingOrder);
}
