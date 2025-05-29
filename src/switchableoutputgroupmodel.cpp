/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "switchableoutputgroupmodel.h"

#include <algorithm>

#include <QQmlInfo>
#include <QQmlEngine>

using namespace Victron::VenusOS;


SwitchableOutputGroupModel::Group SwitchableOutputGroupModel::Group::fromName(const QString &groupName)
{
	Group group;
	group.namedGroup = groupName;
	group.refreshName();
	return group;
}

SwitchableOutputGroupModel::Group SwitchableOutputGroupModel::Group::fromDevice(BaseDevice *device)
{
	if (!device) {
		qWarning() << "Cannot create group, invalid device!";
		return Group();
	}

	Group group;
	group.deviceServiceUid = device->serviceUid();
	group.refreshName(device);
	return group;
}

void SwitchableOutputGroupModel::Group::refreshName(BaseDevice *device)
{
	if (device) {
		if (!device->customName().isEmpty()) {
			name = device->customName();
		} else {
			name = QStringLiteral("%1 %2").arg(device->productName()).arg(QString::number(device->deviceInstance()));
		}
	} else {
		name = namedGroup;
	}
}

SwitchableOutputGroupModel::SwitchableOutputGroupModel(QObject *parent)
	: QAbstractListModel(parent)
{
}

SwitchableOutputGroupModel::~SwitchableOutputGroupModel()
{
	qDeleteAll(m_knownDevices.values());
}

int SwitchableOutputGroupModel::count() const
{
	return m_groups.count();
}

void SwitchableOutputGroupModel::addOutputToNamedGroup(const QString &namedGroup, const QString &outputUid, const QString &outputSortToken)
{
	m_outputSortTokens.insert(outputUid, outputSortToken);

	const int index = indexOfNamedGroup(namedGroup);
	if (index >= 0) {
		addOutputToGroup(index, outputUid);
	} else {
		Group group = Group::fromName(namedGroup);
		group.outputUids.append(outputUid);
		insertGroupAt(insertionIndex(group), group);
	}
}

void SwitchableOutputGroupModel::addOutputToDeviceGroup(const QString &serviceUid, const QString &outputUid, const QString &outputSortToken)
{
	m_outputSortTokens.insert(outputUid, outputSortToken);

	const int index = indexOfDeviceGroup(serviceUid);
	if (index >= 0) {
		addOutputToGroup(index, outputUid);
	} else {
		BaseDevice *device = m_knownDevices.value(serviceUid);
		if (!device) {
			qWarning() << "No known device with uid" << serviceUid << ", call addKnownDevice() to add it first!";
			return;
		}
		Group group = Group::fromDevice(device);
		group.outputUids.append(outputUid);
		insertGroupAt(insertionIndex(group), group);
	}
}

void SwitchableOutputGroupModel::removeOutputFromNamedGroup(const QString &namedGroup, const QString &outputUid)
{
	const int index = indexOfNamedGroup(namedGroup);
	if (index >= 0) {
		removeOutputFromGroup(index, outputUid);
	} else {
		qWarning() << "remove failed, cannot find group with name:" << namedGroup;
	}
}

void SwitchableOutputGroupModel::removeOutputFromDeviceGroup(const QString &serviceUid, const QString &outputUid)
{
	const int index = indexOfDeviceGroup(serviceUid);
	if (index >= 0) {
		removeOutputFromGroup(index, outputUid);
	} else {
		qWarning() << "remove failed, cannot find group for device:" << serviceUid;
	}
}

void SwitchableOutputGroupModel::addKnownDevice(BaseDevice *device)
{
	if (!device) {
		qWarning() << "Invalid device, cannot add known device";
		return;
	}

	if (m_knownDevices.contains(device->serviceUid())) {
		qWarning() << "Cannot add known device, entry already exists for" << device->serviceUid();
		return;
	}
	m_knownDevices.insert(device->serviceUid(), device);

	// Ensure the object is not garbage collected by the JS engine.
	QQmlEngine::setObjectOwnership(device, QQmlEngine::CppOwnership);

	// Allow group names to be updated when the device name changes.
	connect(device, &BaseDevice::customNameChanged, this, [this, device] { updateDeviceGroupName(device); });
	connect(device, &BaseDevice::productNameChanged, this, [this, device] { updateDeviceGroupName(device); });
	connect(device, &BaseDevice::deviceInstanceChanged, this, [this, device] { updateDeviceGroupName(device); });
}

bool SwitchableOutputGroupModel::hasKnownDevice(const QString &serviceUid) const
{
	return m_knownDevices.contains(serviceUid);
}

int SwitchableOutputGroupModel::indexOfNamedGroup(const QString &namedGroup) const
{
	for (int i = 0; i < m_groups.count(); ++i) {
		if (m_groups.at(i).namedGroup == namedGroup) {
			return i;
		}
	}
	return -1;
}

int SwitchableOutputGroupModel::indexOfDeviceGroup(const QString &serviceUid) const
{
	for (int i = 0; i < m_groups.count(); ++i) {
		if (m_groups.at(i).deviceServiceUid == serviceUid) {
			return i;
		}
	}
	return -1;
}

void SwitchableOutputGroupModel::updateSortTokenInGroup(int groupIndex, const QString &outputUid, const QString &outputSortToken)
{
	if (groupIndex < 0 || groupIndex >= m_groups.count()) {
		qWarning() << "Cannot update sort token, invalid group index!" << groupIndex;
		return;
	}

	m_outputSortTokens.insert(outputUid, outputSortToken);

	std::sort(m_groups[groupIndex].outputUids.begin(),
			  m_groups[groupIndex].outputUids.end(),
			  [this](const QString &uid1, const QString &uid2) {
		return outputUidLessThan(uid1, uid2);
	});
	emit dataChanged(createIndex(groupIndex, 0), createIndex(groupIndex, 0), { OutputUidsRole });
}

void SwitchableOutputGroupModel::updateDeviceGroupName(BaseDevice *device)
{
	if (!device) {
		qWarning() << "Invalid device, cannot update group name";
		return;
	}
	const int index = indexOfDeviceGroup(device->serviceUid());
	if (index < 0) {
		return;
	}

	const QString prevName = m_groups[index].name;
	m_groups[index].refreshName(device);
	if (prevName != m_groups[index].name) {
		emit dataChanged(createIndex(index, 0), createIndex(index, 0), { NameRole });

		// Move the group to preserve the sorted model order.
		moveDeviceGroupToSortedIndex(index);
	}
}

void SwitchableOutputGroupModel::moveDeviceGroupToSortedIndex(int groupIndex)
{
	if (groupIndex < 0 || groupIndex >= m_groups.count()) {
		return;
	}

	const Group &group = m_groups.at(groupIndex);
	const int sortedIndex = sortedGroupIndex(group, -1);

	if (sortedIndex > 0
			&& sortedIndex < m_groups.count()
			&& m_groups[sortedIndex].deviceServiceUid == group.deviceServiceUid) {
		// The group at the previous index is this group that was modified, so it is already at
		// the correct index.
		return;
	}

	int fromIndex = groupIndex;
	int toIndex = -1;
	if (sortedIndex < 0) {
		// Move the entry to the end of the list.
		toIndex = count() - 1;
	} else {
		// Move the entry to be immediately before the sorted index.
		toIndex = sortedIndex > fromIndex ? sortedIndex - 1 : sortedIndex;
	}
	if (fromIndex != toIndex) {
		const int destIndex = toIndex > fromIndex ? toIndex + 1 : toIndex;
		beginMoveRows(QModelIndex(), fromIndex, fromIndex, QModelIndex(), destIndex);
		m_groups.move(fromIndex, toIndex);
		endMoveRows();
	}
}

int SwitchableOutputGroupModel::insertionIndex(const Group &group) const
{
	return sortedGroupIndex(group, m_groups.count());
}

int SwitchableOutputGroupModel::sortedGroupIndex(const Group &group, int defaultValue) const
{
	for (int i = 0; i < m_groups.count(); ++i) {
		if (group.name.localeAwareCompare(m_groups.at(i).name) < 0) {
			return i;
		}
	}
	return defaultValue;
}

int SwitchableOutputGroupModel::countGroupsWithDevice(const QString &serviceUid)
{
	int matches = 0;
	for (const Group &group : m_groups) {
		if (group.deviceServiceUid == serviceUid) {
			matches++;
		}
	}
	return matches;
}

bool SwitchableOutputGroupModel::outputUidLessThan(const QString &outputUid1, const QString &outputUid2) const
{
	return m_outputSortTokens.value(outputUid1).localeAwareCompare(m_outputSortTokens.value(outputUid2)) < 0;
}

int SwitchableOutputGroupModel::outputUidInsertionIndex(const QStringList &outputUids, const QString &outputUid) const
{
	for (int i = 0; i < outputUids.count(); ++i) {
		if (outputUidLessThan(outputUid, outputUids.at(i))) {
			return i;
		}
	}
	return outputUids.count();
}

void SwitchableOutputGroupModel::addOutputToGroup(int index, const QString &outputUid)
{
	if (index >= 0
			&& index < m_groups.count()
			&& m_groups[index].outputUids.indexOf(outputUid) < 0) {
		m_groups[index].outputUids.insert(outputUidInsertionIndex(m_groups[index].outputUids, outputUid), outputUid);
		emit dataChanged(createIndex(index, 0), createIndex(index, 0), { OutputUidsRole });
	}
}

void SwitchableOutputGroupModel::removeOutputFromGroup(int index, const QString &outputUid)
{
	if (index >= 0 && index < m_groups.count()) {
		const QStringList &groupOutputUids = m_groups.at(index).outputUids;
		if (groupOutputUids.count() == 1 && groupOutputUids.first() == outputUid) {
			// Removing this output would result in an empty group, so just remove the group
			// altogether.
			removeGroupAt(index);
		} else {
			if (m_groups[index].outputUids.removeOne(outputUid)) {
				emit dataChanged(createIndex(index, 0), createIndex(index, 0), { OutputUidsRole });
			} else {
				qWarning() << "Cannot find output" << outputUid << "in group:"
						   << m_groups[index].name << m_groups[index].namedGroup;
			}
		}
		m_outputSortTokens.remove(outputUid);
	}
}

void SwitchableOutputGroupModel::insertGroupAt(int index, const Group &group)
{
	if (index >= 0 && index <= m_groups.count()) {
		beginInsertRows(QModelIndex(), index, index);
		m_groups.insert(index, group);
		endInsertRows();
		emit countChanged();
	}
}

void SwitchableOutputGroupModel::removeGroupAt(int index)
{
	if (index >= 0 && index < m_groups.count()) {
		beginRemoveRows(QModelIndex(), index, index);
		Group group = m_groups.takeAt(index);

		// If there are no more groups linked to this device, then remove the known device.
		if (countGroupsWithDevice(group.deviceServiceUid) == 0) {
			if (BaseDevice *device = m_knownDevices.take(group.deviceServiceUid)) {
				device->disconnect(this);
				delete device;
			}
		}

		endRemoveRows();
		emit countChanged();
	}
}

QVariant SwitchableOutputGroupModel::data(const QModelIndex &index, int role) const
{
	const int row = index.row();
	if (row < 0 || row >= m_groups.count()) {
		return QVariant();
	}

	const Group &group = m_groups.at(row);
	switch (role)
	{
	case NameRole:
		return group.name;
	case OutputUidsRole:
		return QVariant::fromValue(group.outputUids);
	}
	return QVariant();
}

int SwitchableOutputGroupModel::rowCount(const QModelIndex &) const
{
	return count();
}

QHash<int, QByteArray> SwitchableOutputGroupModel::roleNames() const
{
	static QHash<int, QByteArray> roles = {
		{ NameRole, "name" },
		{ OutputUidsRole, "outputUids" },
	};
	return roles;
}
