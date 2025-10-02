/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "switchableoutputgroupmodel.h"
#include "allservicesmodel.h"
#include "alldevicesmodel.h"
#include "switchableoutput.h"

#include <QQmlInfo>
#include <QQmlEngine>

using namespace Victron::VenusOS;
SwitchableOutputGroup::SwitchableOutputGroup(QObject *parent, const QString &groupId)
	: QObject(parent)
	, m_groupId(groupId)
{
}

QString SwitchableOutputGroup::groupId() const
{
	return m_groupId;
}

QQmlListProperty<SwitchableOutput> SwitchableOutputGroup::outputs()
{
	return QQmlListProperty<SwitchableOutput>(this, &m_outputs);
}

QString SwitchableOutputGroup::name() const
{
	return m_name;
}

void SwitchableOutputGroup::setName(const QString &name)
{
	if (m_name != name) {
		m_name = name;
		emit nameChanged();
	}
}

bool SwitchableOutputGroup::addOutput(SwitchableOutput *output)
{
	if (!output) {
		qWarning() << "output group: cannot add invalid output!";
		return false;
	}
	if (m_outputs.contains(output)) {
		return false;
	} else {
		m_outputs.append(output);
		sortOutputs();
		connect(output, &SwitchableOutput::formattedNameChanged, this, &SwitchableOutputGroup::sortOutputs);
		emit outputsChanged();
		return true;
	}
}

bool SwitchableOutputGroup::removeOutput(const QString &outputUid)
{
	for (int i = 0; i < m_outputs.count(); ++i) {
		if (m_outputs.at(i)->uid() == outputUid) {
			m_outputs[i]->disconnect(this);
			m_outputs.removeAt(i);
			sortOutputs();
			emit outputsChanged();
			return true;
		}
	}
	return false;
}

bool SwitchableOutputGroup::isRemainingOutput(const QString &outputUid) const
{
	return m_outputs.count() == 1 && outputUid == m_outputs.at(0)->uid();
}

void SwitchableOutputGroup::sortOutputs()
{
	std::sort(m_outputs.begin(),
			  m_outputs.end(),
			  [this](SwitchableOutput *output1, SwitchableOutput *output2) {
		return output1 && output2
				&& output1->formattedName().localeAwareCompare(output2->formattedName()) < 0;
	});
}

SwitchableOutputGroup *SwitchableOutputGroup::newNamedGroup(const QString &groupName, QObject *parent)
{
	SwitchableOutputGroup *group = new SwitchableOutputGroup(parent, namedGroupId(groupName));
	group->setName(groupName);
	return group;
}

SwitchableOutputGroup *SwitchableOutputGroup::newDeviceGroup(const QString &serviceUid, QObject *parent)
{
	SwitchableOutputGroup *group = new SwitchableOutputGroup(parent, deviceGroupId(serviceUid));
	const QString serviceType = BaseDevice::serviceTypeFromUid(serviceUid);
	if (serviceType == QStringLiteral("system")) {
		//% "GX device relays"
		group->setName(qtTrId("gx_device_relays"));
	} else {
		if (BaseDevice *device = AllDevicesModel::create()->findDevice(serviceUid)) {
			connect(device, &BaseDevice::nameChanged, group, [group, device]() {
				 group->setName(device->name());
			});
			group->setName(device->name());
		}
	}
	return group;
}

QString SwitchableOutputGroup::namedGroupId(const QString &groupName)
{
	return QStringLiteral("__venus_guiv2_named_group_%1").arg(groupName);
}

QString SwitchableOutputGroup::deviceGroupId(const QString &serviceUid)
{
	return QStringLiteral("__venus_guiv2_service_group_%1").arg(serviceUid);
}


SwitchableOutputGroupModel::SwitchableOutputGroupModel(QObject *parent)
	: QAbstractListModel(parent)
{
	addAvailableServices();

	connect(AllServicesModel::create(), &AllServicesModel::serviceAdded,
			this, &SwitchableOutputGroupModel::anyServiceAdded);
	connect(AllServicesModel::create(), &AllServicesModel::serviceAboutToBeRemoved,
			this, &SwitchableOutputGroupModel::anyServiceAboutToBeRemoved);
	connect(AllServicesModel::create(), &AllServicesModel::modelAboutToBeReset, this, [this]() {
		beginResetModel();
		cleanUp();
	});
	connect(AllServicesModel::create(), &AllServicesModel::modelReset, this, [this]() {
		addAvailableServices();
		endResetModel();
		emit countChanged();
	});
}

SwitchableOutputGroupModel::~SwitchableOutputGroupModel()
{
}

int SwitchableOutputGroupModel::count() const
{
	return m_groups.count();
}

QVariant SwitchableOutputGroupModel::data(const QModelIndex &index, int role) const
{
	const int row = index.row();
	if (row < 0 || row >= m_groups.count()) {
		return QVariant();
	}

	switch (role)
	{
	case GroupRole:
		return QVariant::fromValue<SwitchableOutputGroup *>(m_groups.at(row));
	case GroupNameRole:
		return m_groups.at(row)->name();
	}
	return QVariant();
}

int SwitchableOutputGroupModel::rowCount(const QModelIndex &) const
{
	return count();
}

QHash<int, QByteArray> SwitchableOutputGroupModel::roleNames() const
{
	static const QHash<int, QByteArray> roles {
		{ GroupRole, "group" },
		{ GroupNameRole, "groupName" },
	};
	return roles;
}

void SwitchableOutputGroupModel::cleanUp()
{
	qDeleteAll(m_groups);
	m_groups.clear();

	for (auto it = m_outputs.begin(); it != m_outputs.end(); ++it) {
		SwitchableOutput *output = it.value().output;
		output->disconnect(this);
		delete output;
	}
	m_outputs.clear();
}

void SwitchableOutputGroupModel::addAvailableServices()
{
	for (int i = 0; i < AllServicesModel::create()->count(); ++i) {
		if (VeQItem *serviceItem = AllServicesModel::create()->itemAt(i)) {
			anyServiceAdded(serviceItem);
		}
	}
}

void SwitchableOutputGroupModel::anyServiceAdded(VeQItem *serviceItem)
{
	// If the service has a /SwitchableOutput path, add the children of that path as switchable
	// outputs.
	if (VeQItem *switchableOutputParentItem = serviceItem->itemGet(QStringLiteral("SwitchableOutput"))) {
		addSwitchableOutputChildren(switchableOutputParentItem);
	}

	connect(serviceItem, &VeQItem::childAdded, this, [this](VeQItem *childItem) {
		if (childItem->id() == QStringLiteral("SwitchableOutput")) {
			addSwitchableOutputChildren(childItem);
		}
	});
}

void SwitchableOutputGroupModel::addSwitchableOutputChildren(VeQItem *switchableOutputParentItem)
{
	for (auto it = switchableOutputParentItem->itemChildren().begin();
		 it != switchableOutputParentItem->itemChildren().end();
		 ++it) {
		addOutputForItem(it.value());
	}
	// If any children of the /SwitchableOutput path are added/removed in the future, add/remove
	// the children as switchable outputs.
	connect(switchableOutputParentItem, &VeQItem::childAdded,
			this, &SwitchableOutputGroupModel::addOutputForItem);
	connect(switchableOutputParentItem, &VeQItem::childAboutToBeRemoved,
			this, &SwitchableOutputGroupModel::removeOutputForItem);
}

void SwitchableOutputGroupModel::anyServiceAboutToBeRemoved(VeQItem *serviceItem)
{
	// If the service has a /SwitchableOutput path, remove all children of that path as switchable
	// outputs.
	if (VeQItem *switchableOutputParentItem = serviceItem->itemGet(QStringLiteral("SwitchableOutput"))) {
		for (auto it = switchableOutputParentItem->itemChildren().begin();
			 it != switchableOutputParentItem->itemChildren().end();
			 ++it) {
			removeOutputForItem(it.value());
		}
	}
}

void SwitchableOutputGroupModel::addOutputForItem(VeQItem *switchableOutputItem)
{
	SwitchableOutput *output = new SwitchableOutput(this, switchableOutputItem);
	m_outputs.insert(output->uid(), SwitchableOutputInfo { output, QString() });

	// Add the output to its group.
	if (output->allowedInGroupModel()) {
		addOutputToItsGroup(output);
	}

	// Update the group of the output when its group name changes, or when it is allowed/disallowed
	// in groups.
	connect(output, &SwitchableOutput::allowedInGroupModelChanged, this, [this, output]() {
		removeOutputFromItsGroup(output->uid());
		addOutputToItsGroup(output);
	});
	connect(output, &SwitchableOutput::groupChanged, this, [this, output]() {
		removeOutputFromItsGroup(output->uid());
		addOutputToItsGroup(output);
	});
}

void SwitchableOutputGroupModel::removeOutputForItem(VeQItem *switchableOutputItem)
{
	if (auto it = m_outputs.find(switchableOutputItem->uniqueId()); it != m_outputs.end()) {
		// From the output from its group, if it is in one.
		removeOutputFromItsGroup(switchableOutputItem->uniqueId());

		// Remove the output from m_outputs and delete the output object.
		SwitchableOutput *output = it.value().output;
		output->disconnect(this);
		m_outputs.erase(it);
		delete output;
	}
}

int SwitchableOutputGroupModel::indexOfGroup(const QString &groupId) const
{
	for (int i = 0; i < m_groups.count(); ++i) {
		if (m_groups.at(i)->groupId() == groupId) {
			return i;
		}
	}
	return -1;
}

void SwitchableOutputGroupModel::addOutputToItsGroup(SwitchableOutput *output)
{
	if (!output->allowedInGroupModel()) {
		return;
	}

	const QString groupId = output->group().length() > 0
			? SwitchableOutputGroup::namedGroupId(output->group())
			: SwitchableOutputGroup::deviceGroupId(output->serviceUid());
	if (const int groupIndex = indexOfGroup(groupId); groupIndex >= 0) {
		// Add the output to an existing group.
		m_groups[groupIndex]->addOutput(output);
	} else {
		// Create a new group. If the output group is set, add the output to that named group.
		// Otherwise, add it to the group for its device.
		SwitchableOutputGroup *group = output->group().length() > 0
				? SwitchableOutputGroup::newNamedGroup(output->group(), this)
				: SwitchableOutputGroup::newDeviceGroup(output->serviceUid(), this);
		group->addOutput(output);
		beginInsertRows(QModelIndex(), m_groups.count(), m_groups.count());
		m_groups.append(group);
		endInsertRows();
		emit countChanged();

		// Update the model data when the group name changes.
		connect(group, &SwitchableOutputGroup::nameChanged, this, [this, group]() {
			if (const int groupIndex = indexOfGroup(group->groupId()); groupIndex >= 0) {
				emit dataChanged(createIndex(groupIndex, 0), createIndex(groupIndex, 0), { GroupNameRole });
			}
		});
	}

	m_outputs[output->uid()].groupId = groupId;
}

void SwitchableOutputGroupModel::removeOutputFromItsGroup(const QString &outputUid)
{
	auto it = m_outputs.find(outputUid);
	if (it == m_outputs.end() || it.value().groupId.isEmpty()) {
		// Output is not currently in a group.
		return;
	}

	const int groupIndex = indexOfGroup(it.value().groupId);
	if (groupIndex < 0) {
		qWarning() << "Cannot find group" << it.value().groupId << "for output:" << outputUid;
		return;
	}

	if (m_groups.at(groupIndex)->isRemainingOutput(outputUid)) {
		// Removing this output would result in an empty group, so just remove the group
		// altogether.
		beginRemoveRows(QModelIndex(), groupIndex, groupIndex);
		delete m_groups.takeAt(groupIndex);
		endRemoveRows();
		emit countChanged();
	} else {
		if (!m_groups[groupIndex]->removeOutput(outputUid)) {
			qWarning() << "Cannot find output" << outputUid << "in group:" << m_groups.at(groupIndex)->groupId();
		}
	}

	// Indicate the output is no longer in a group.
	it.value().groupId.clear();
}


SortedSwitchableOutputGroupModel::SortedSwitchableOutputGroupModel(QObject *parent)
	: QSortFilterProxyModel(parent)
{
	setSortLocaleAware(true);
	setSortRole(SwitchableOutputGroupModel::GroupNameRole);
	sort(0, Qt::AscendingOrder);
}
