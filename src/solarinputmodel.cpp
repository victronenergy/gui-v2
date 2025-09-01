/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "solarinputmodel.h"
#include "solarinput.h"
#include "alldevicesmodel.h"
#include "device.h"

#include <veutil/qt/ve_qitem.hpp>

#include <QQmlInfo>

using namespace Victron::VenusOS;

SolarInputModel::SolarInputModel(QObject *parent)
	: QAbstractListModel(parent)
{
	addAvailableInputs();

	AllDevicesModel *allDevicesModel = AllDevicesModel::create();
	connect(allDevicesModel, &AllDevicesModel::rowsInserted,
			this, &SolarInputModel::sourceDeviceAdded);
	connect(allDevicesModel, &AllDevicesModel::rowsAboutToBeRemoved,
			this, &SolarInputModel::sourceDeviceAboutToBeRemoved);
	connect(allDevicesModel, &AllDevicesModel::modelAboutToBeReset, [this]() {
		beginResetModel();
		clearInputs();
	});
	connect(allDevicesModel, &AllDevicesModel::modelAboutToBeReset, [this]() {
		addAvailableInputs();
		endResetModel();
		emit countChanged();
	});
}

int SolarInputModel::count() const
{
	return m_enabledInputs.count();
}

QVariant SolarInputModel::data(const QModelIndex &index, int role) const
{
	const int row = index.row();
	if (row < 0 || row >= m_enabledInputs.count()) {
		return QVariant();
	}

	const SolarInput *input = m_enabledInputs.at(row);
	switch (role)
	{
	case ServiceUidRole:
		return input->serviceUid();
	case ServiceTypeRole:
		return input->serviceType();
	case GroupRole:
		return input->group();
	case EnabledRole:
		return input->isEnabled();
	case NameRole:
		return input->name();
	case TodaysYieldRole:
		return input->todaysYield();
	case PowerRole:
		return input->power();
	case CurrentRole:
		return input->current();
	case VoltageRole:
		return input->voltage();
	default:
		return QVariant();
	}
}

int SolarInputModel::rowCount(const QModelIndex &) const
{
	return count();
}

QHash<int, QByteArray> SolarInputModel::roleNames() const
{
	static const QHash<int, QByteArray> roles {
		{ ServiceUidRole, "serviceUid" },
		{ ServiceTypeRole, "serviceType" },
		{ GroupRole, "group" },
		{ EnabledRole, "enabled" },
		{ NameRole, "name" },
		{ TodaysYieldRole, "todaysYield" },
		{ PowerRole, "power" },
		{ CurrentRole, "current" },
		{ VoltageRole, "voltage" },
	};
	return roles;
}

void SolarInputModel::maybeAddDevice(Device *device)
{
	if (!device || !device->serviceItem()) {
		return;
	}

	if (device->serviceType() == QStringLiteral("solarcharger")
			|| device->serviceType() == QStringLiteral("multi")
			|| device->serviceType() == QStringLiteral("inverter")) {
		// For solarcharger/multi/inverter services, add their trackers (rather than the devices
		// themselves) to the model. The number of trackers for each service is determined by the
		// NrOfTrackers value.
		QVariant trackerCountValue;
		int trackerCount = 0;
		if (VeQItem *nrOfTrackersItem = device->serviceItem()->itemGet(QStringLiteral("NrOfTrackers"))) {
			trackerCountValue = nrOfTrackersItem->getValue();
		}
		if (trackerCountValue.isValid()) {
			bool ok = false;
			const int trackerCountInt = trackerCountValue.toInt(&ok);
			if (ok) {
				trackerCount = trackerCountInt;
			}
		} else if (device->serviceType() == QStringLiteral("solarcharger")) {
			// For solarcharger services, there is always solar data even if /NrOfTrackers is not
			// set; the first TrackerSolarInput will report the overall charger measurements.
			trackerCount = 1;
		}

		// If a tracker is disabled, do not add it to the model, but monitor it in case it becomes
		// enabled.
		QList<int> enabledTrackerIndexes;
		for (int i = 0; i < trackerCount; ++i) {
			if (TrackerSolarInput::isEnabledTracker(device->serviceItem(), i)) {
				enabledTrackerIndexes.append(i);
			} else {
				TrackerSolarInput *input = new TrackerSolarInput(device, trackerCount == 1, i, this);
				initializeInput(input);
				m_disabledInputs.append(input);
			}
		}

		// Add all enabled trackers to the model.
		if (enabledTrackerIndexes.count() > 0) {
			beginInsertRows(QModelIndex(), m_enabledInputs.count(), m_enabledInputs.count());
		}
		for (int i = 0; i < enabledTrackerIndexes.count(); ++i) {
			TrackerSolarInput *input = new TrackerSolarInput(device, trackerCount == 1, enabledTrackerIndexes.at(i), this);
			initializeInput(input);
			m_enabledInputs.append(input);
		}
		if (enabledTrackerIndexes.count() > 0) {
			endInsertRows();
			emit countChanged();
		}
	} else if (device->serviceType() == QStringLiteral("pvinverter")) {
		// For pvinverter services, add each device to the model.
		beginInsertRows(QModelIndex(), m_enabledInputs.count(), m_enabledInputs.count());
		PvInverterSolarInput *input = new PvInverterSolarInput(device, this);
		initializeInput(input);
		m_enabledInputs.append(input);
		endInsertRows();
		emit countChanged();
	}
}

void SolarInputModel::sourceDeviceAdded(const QModelIndex &parent, int first, int last)
{
	Q_UNUSED(parent)

	for (int i = first; i <= last; ++i) {
		maybeAddDevice(AllDevicesModel::create()->deviceAt(i));
	}
}

void SolarInputModel::sourceDeviceAboutToBeRemoved(const QModelIndex &parent, int first, int last)
{
	Q_UNUSED(parent)

	for (int i = first; i <= last; ++i) {
		if (BaseDevice *device = AllDevicesModel::create()->deviceAt(i)) {
			// Remove all enabled/disabled inputs that are connected to this device. If the device
			// has multiple trackers, then all of them will be removed.
			QList<int> enabledIndexesToRemove;
			for (int i = 0; i < m_enabledInputs.count(); ++i) {
				if (m_enabledInputs.at(i)->serviceUid() == device->serviceUid()) {
					enabledIndexesToRemove.append(i);
				}
			}
			for (int i = enabledIndexesToRemove.count() - 1; i >= 0; --i) {
				beginRemoveRows(QModelIndex(), enabledIndexesToRemove.at(i), enabledIndexesToRemove.at(i));
				SolarInput *input = m_enabledInputs.takeAt(enabledIndexesToRemove.at(i));
				input->disconnect(this);
				delete input;
				endRemoveRows();
				emit countChanged();
			}
			for (auto it = m_disabledInputs.begin(); it != m_disabledInputs.end();) {
				if ((*it)->serviceUid() == device->serviceUid()) {
					(*it)->disconnect(this);
					delete *it;
					it = m_disabledInputs.erase(it);
				} else {
					++it;
				}
			}
		}
	}
}

void SolarInputModel::clearInputs()
{
	qDeleteAll(m_enabledInputs);
	m_enabledInputs.clear();
	qDeleteAll(m_disabledInputs);
	m_disabledInputs.clear();
}

void SolarInputModel::addAvailableInputs()
{
	AllDevicesModel *allDevicesModel = AllDevicesModel::create();
	for (int i = 0; i < allDevicesModel->count(); ++i) {
		maybeAddDevice(allDevicesModel->deviceAt(i));
	}
}

void SolarInputModel::initializeInput(SolarInput *input)
{
	if (!input) {
		qmlWarning(this) << "cannot initialize invalid input!";
		return;
	}
	connect(input, &SolarInput::enabledChanged, this, &SolarInputModel::inputEnabledChanged);
	connect(input, &SolarInput::nameChanged, this, [this, input]() { emitInputValueChanged(input, NameRole); });
	connect(input, &SolarInput::todaysYieldChanged, this, [this, input]() { emitInputValueChanged(input, TodaysYieldRole); });
	connect(input, &SolarInput::powerChanged, this, [this, input]() { emitInputValueChanged(input, PowerRole); });
	connect(input, &SolarInput::currentChanged, this, [this, input]() { emitInputValueChanged(input, CurrentRole); });
	connect(input, &SolarInput::voltageChanged, this, [this, input]() { emitInputValueChanged(input, VoltageRole); });
}

void SolarInputModel::emitInputValueChanged(SolarInput *input, Role role)
{
	for (int i = 0; i < m_enabledInputs.count(); ++i) {
		if (m_enabledInputs.at(i) == input) {
			emit dataChanged(createIndex(i, 0), createIndex(i, 0), { role });
			break;
		}
	}
}

void SolarInputModel::inputEnabledChanged()
{
	if (TrackerSolarInput *input = qobject_cast<TrackerSolarInput *>(sender())) {
		int enabledIndex = -1;
		int disabledIndex = -1;
		for (int i = 0; i < m_enabledInputs.count(); ++i) {
			if (m_enabledInputs.at(i) == input) {
				enabledIndex = i;
				break;
			}
		}
		for (int i = 0; i < m_disabledInputs.count(); ++i) {
			if (m_disabledInputs.at(i) == input) {
				disabledIndex = i;
				break;
			}
		}

		if (input->isEnabled()) {
			// Input is now enabled, so move it from m_disabledInputs to m_enabledInputs.
			if (disabledIndex >= 0) {
				m_disabledInputs.removeAt(disabledIndex);
			}
			if (enabledIndex < 0) {
				beginInsertRows(QModelIndex(), m_enabledInputs.count(), m_enabledInputs.count());
				m_enabledInputs.append(input);
				endInsertRows();
				emit countChanged();
			}
		} else {
			// Input is now disabled, so move it from m_enabledInputs to m_disabledInputs.
			if (enabledIndex >= 0) {
				beginRemoveRows(QModelIndex(), enabledIndex, enabledIndex);
				m_enabledInputs.removeAt(enabledIndex);
				endRemoveRows();
				emit countChanged();
			}
			if (disabledIndex < 0) {
				m_disabledInputs.append(input);
			}
		}
	}
}

SortedSolarInputModel::SortedSolarInputModel(QObject *parent)
	: QSortFilterProxyModel(parent)
{
	sort(0, Qt::AscendingOrder);
}

bool SortedSolarInputModel::lessThan(const QModelIndex &sourceLeft, const QModelIndex &sourceRight) const
{
	const QString leftGroup = sourceModel()->data(
			sourceModel()->index(sourceLeft.row(), sourceLeft.column()), SolarInputModel::GroupRole).toString();
	const QString rightGroup = sourceModel()->data(
			sourceModel()->index(sourceRight.row(), sourceRight.column()), SolarInputModel::GroupRole).toString();

	if (leftGroup == rightGroup) {
		const QString leftName = sourceModel()->data(
				sourceModel()->index(sourceLeft.row(), sourceLeft.column()), SolarInputModel::NameRole).toString();
		const QString rightName = sourceModel()->data(
				sourceModel()->index(sourceRight.row(), sourceRight.column()), SolarInputModel::NameRole).toString();
		return leftName.localeAwareCompare(rightName) < 0;
	} else {
		return leftGroup.localeAwareCompare(rightGroup) < 0;
	}
}
