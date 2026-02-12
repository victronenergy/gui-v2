/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "iochannelgroupmodel.h"
#include "allservicesmodel.h"
#include "alldevicesmodel.h"
#include "switchableoutput.h"

#include <QQmlInfo>
#include <QQmlEngine>

using namespace Victron::VenusOS;

IOChannelGroup::IOChannelGroup(QObject *parent, const QString &groupId)
	: QObject(parent)
	, m_groupId(groupId)
{
}

QString IOChannelGroup::groupId() const
{
	return m_groupId;
}

QQmlListProperty<IOChannel> IOChannelGroup::channels()
{
	return QQmlListProperty<IOChannel>(this, &m_channels);
}

QString IOChannelGroup::name() const
{
	return m_name;
}

void IOChannelGroup::setName(const QString &name)
{
	if (m_name != name) {
		m_name = name;
		emit nameChanged();
	}
}

bool IOChannelGroup::addChannel(IOChannel *channel)
{
	if (!channel) {
		qWarning() << "channel group: cannot add invalid channel!";
		return false;
	}
	if (m_channels.contains(channel)) {
		return false;
	} else {
		m_channels.append(channel);
		sortChannels();
		connect(channel, &IOChannel::formattedNameChanged, this, &IOChannelGroup::sortChannels);
		emit channelsChanged();
		return true;
	}
}

bool IOChannelGroup::removeChannel(const QString &channelUid)
{
	for (int i = 0; i < m_channels.count(); ++i) {
		if (m_channels.at(i)->uid() == channelUid) {
			m_channels[i]->disconnect(this);
			m_channels.removeAt(i);
			sortChannels();
			emit channelsChanged();
			return true;
		}
	}
	return false;
}

bool IOChannelGroup::isRemainingChannel(const QString &channelUid) const
{
	return m_channels.count() == 1 && channelUid == m_channels.at(0)->uid();
}

void IOChannelGroup::sortChannels()
{
	std::sort(m_channels.begin(),
			  m_channels.end(),
			  [this](IOChannel *channel1, IOChannel *channel2) {
		return channel1 && channel2
				&& channel1->formattedName().localeAwareCompare(channel2->formattedName()) < 0;
	});
}

IOChannelGroup *IOChannelGroup::newNamedGroup(const QString &groupName, QObject *parent)
{
	IOChannelGroup *group = new IOChannelGroup(parent, namedGroupId(groupName));
	group->setName(groupName);
	return group;
}

IOChannelGroup *IOChannelGroup::newDeviceGroup(const QString &serviceUid, QObject *parent)
{
	IOChannelGroup *group = new IOChannelGroup(parent, deviceGroupId(serviceUid));
	const QString serviceType = BaseDevice::serviceTypeFromUid(serviceUid);
	if (serviceType == QStringLiteral("system")) {
		//% "GX device relays"
		group->setName(qtTrId("gx_device_relays"));
	} else {
		if (Device *device = AllDevicesModel::create()->findDevice(serviceUid)) {
			group->initializeDevice(device);
		} else {
			connect(AllDevicesModel::create(), &AllDevicesModel::deviceAdded,
					group, &IOChannelGroup::initializeDevice);
		}
	}
	return group;
}

void IOChannelGroup::initializeDevice(Device *device)
{
	if (deviceGroupId(device->serviceUid()) == m_groupId) {
		AllDevicesModel::create()->disconnect(this);
		connect(device, &BaseDevice::nameChanged, this, [this, device]() {
			 setName(device->name());
		});
		setName(device->name());
	}
}

QString IOChannelGroup::namedGroupId(const QString &groupName)
{
	return QStringLiteral("__venus_guiv2_named_group_%1").arg(groupName);
}

QString IOChannelGroup::deviceGroupId(const QString &serviceUid)
{
	return QStringLiteral("__venus_guiv2_service_group_%1").arg(serviceUid);
}


IOChannelGroupModel::IOChannelGroupModel(QObject *parent)
	: QAbstractListModel(parent)
{
	addAvailableServices();

	connect(AllServicesModel::create(), &AllServicesModel::serviceAdded,
			this, &IOChannelGroupModel::anyServiceAdded);
	connect(AllServicesModel::create(), &AllServicesModel::serviceAboutToBeRemoved,
			this, &IOChannelGroupModel::anyServiceAboutToBeRemoved);
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

IOChannelGroupModel::~IOChannelGroupModel()
{
}

int IOChannelGroupModel::count() const
{
	return m_groups.count();
}

QVariant IOChannelGroupModel::data(const QModelIndex &index, int role) const
{
	const int row = index.row();
	if (row < 0 || row >= m_groups.count()) {
		return QVariant();
	}

	switch (role)
	{
	case GroupRole:
		return QVariant::fromValue<IOChannelGroup *>(m_groups.at(row));
	case GroupNameRole:
		return m_groups.at(row)->name();
	}
	return QVariant();
}

int IOChannelGroupModel::rowCount(const QModelIndex &) const
{
	return count();
}

QHash<int, QByteArray> IOChannelGroupModel::roleNames() const
{
	static const QHash<int, QByteArray> roles {
		{ GroupRole, "group" },
		{ GroupNameRole, "groupName" },
	};
	return roles;
}

void IOChannelGroupModel::cleanUp()
{
	qDeleteAll(m_groups);
	m_groups.clear();

	for (auto it = m_channels.begin(); it != m_channels.end(); ++it) {
		IOChannel *channel = it.value().channel;
		channel->disconnect(this);
		delete channel;
	}
	m_channels.clear();
}

void IOChannelGroupModel::addAvailableServices()
{
	for (int i = 0; i < AllServicesModel::create()->count(); ++i) {
		if (VeQItem *serviceItem = AllServicesModel::create()->itemAt(i)) {
			anyServiceAdded(serviceItem);
		}
	}
}

void IOChannelGroupModel::anyServiceAdded(VeQItem *serviceItem)
{
	// If the service has a /SwitchableOutput path, add the children of that path as channels.
	if (VeQItem *channelParentItem = serviceItem->itemGet(QStringLiteral("SwitchableOutput"))) {
		addChannelChildren(channelParentItem);
	}

	connect(serviceItem, &VeQItem::childAdded, this, [this](VeQItem *childItem) {
		if (childItem->id() == QStringLiteral("SwitchableOutput")) {
			addChannelChildren(childItem);
		}
	});
}

void IOChannelGroupModel::addChannelChildren(VeQItem *channelParentItem)
{
	for (auto it = channelParentItem->itemChildren().begin();
		 it != channelParentItem->itemChildren().end();
		 ++it) {
		addChannelForItem(it.value());
	}
	// If any children of the /SwitchableOutput path are added/removed in the future, add/remove
	// the children as channels.
	connect(channelParentItem, &VeQItem::childAdded,
			this, &IOChannelGroupModel::addChannelForItem);
	connect(channelParentItem, &VeQItem::childAboutToBeRemoved,
			this, &IOChannelGroupModel::removeChannelForItem);
}

void IOChannelGroupModel::anyServiceAboutToBeRemoved(VeQItem *serviceItem)
{
	// If the service has a /SwitchableOutput path, remove all children of that path as channels
	if (VeQItem *channelParentItem = serviceItem->itemGet(QStringLiteral("SwitchableOutput"))) {
		for (auto it = channelParentItem->itemChildren().begin();
			 it != channelParentItem->itemChildren().end();
			 ++it) {
			removeChannelForItem(it.value());
		}
	}
}

void IOChannelGroupModel::addChannelForItem(VeQItem *channelItem)
{
	IOChannel *channel = new SwitchableOutput(this, channelItem);
	m_channels.insert(channel->uid(), ChannelInfo { channel, QString() });

	// Add the channel to its group.
	if (channel->allowedInGroupModel()) {
		addChannelToItsGroup(channel);
	}

	// Update the group of the channel when its group name changes, or when it is allowed/disallowed
	// in groups.
	connect(channel, &IOChannel::allowedInGroupModelChanged, this, [this, channel]() {
		removeChannelFromItsGroup(channel->uid());
		addChannelToItsGroup(channel);
	});
	connect(channel, &IOChannel::groupChanged, this, [this, channel]() {
		removeChannelFromItsGroup(channel->uid());
		addChannelToItsGroup(channel);
	});
}

void IOChannelGroupModel::removeChannelForItem(VeQItem *channelItem)
{
	if (auto it = m_channels.find(channelItem->uniqueId()); it != m_channels.end()) {
		// From the channel from its group, if it is in one.
		removeChannelFromItsGroup(channelItem->uniqueId());

		// Remove the channel from m_channels and delete the channel object.
		IOChannel *channel = it.value().channel;
		channel->disconnect(this);
		m_channels.erase(it);
		delete channel;
	}
}

int IOChannelGroupModel::indexOfGroup(const QString &groupId) const
{
	for (int i = 0; i < m_groups.count(); ++i) {
		if (m_groups.at(i)->groupId() == groupId) {
			return i;
		}
	}
	return -1;
}

void IOChannelGroupModel::addChannelToItsGroup(IOChannel *channel)
{
	if (!channel->allowedInGroupModel()) {
		return;
	}

	const QString groupId = channel->group().length() > 0
			? IOChannelGroup::namedGroupId(channel->group())
			: IOChannelGroup::deviceGroupId(channel->serviceUid());
	if (const int groupIndex = indexOfGroup(groupId); groupIndex >= 0) {
		// Add the channel to an existing group.
		m_groups[groupIndex]->addChannel(channel);
	} else {
		// Create a new group. If the channel group is set, add the channel to that named group.
		// Otherwise, add it to the group for its device.
		IOChannelGroup *group = channel->group().length() > 0
				? IOChannelGroup::newNamedGroup(channel->group(), this)
				: IOChannelGroup::newDeviceGroup(channel->serviceUid(), this);
		group->addChannel(channel);
		beginInsertRows(QModelIndex(), m_groups.count(), m_groups.count());
		m_groups.append(group);
		endInsertRows();
		emit countChanged();

		// Update the model data when the group name changes.
		connect(group, &IOChannelGroup::nameChanged, this, [this, group]() {
			if (const int groupIndex = indexOfGroup(group->groupId()); groupIndex >= 0) {
				emit dataChanged(createIndex(groupIndex, 0), createIndex(groupIndex, 0), { GroupNameRole });
			}
		});
	}

	m_channels[channel->uid()].groupId = groupId;
}

void IOChannelGroupModel::removeChannelFromItsGroup(const QString &channelUid)
{
	auto it = m_channels.find(channelUid);
	if (it == m_channels.end() || it.value().groupId.isEmpty()) {
		// Channel is not currently in a group.
		return;
	}

	const int groupIndex = indexOfGroup(it.value().groupId);
	if (groupIndex < 0) {
		qWarning() << "Cannot find group" << it.value().groupId << "for channel:" << channelUid;
		return;
	}

	if (m_groups.at(groupIndex)->isRemainingChannel(channelUid)) {
		// Removing this channel would result in an empty group, so just remove the group
		// altogether.
		beginRemoveRows(QModelIndex(), groupIndex, groupIndex);
		delete m_groups.takeAt(groupIndex);
		endRemoveRows();
		emit countChanged();
	} else {
		if (!m_groups[groupIndex]->removeChannel(channelUid)) {
			qWarning() << "Cannot find channel" << channelUid << "in group:" << m_groups.at(groupIndex)->groupId();
		}
	}

	// Indicate the channel is no longer in a group.
	it.value().groupId.clear();
}


SortedIOChannelGroupModel::SortedIOChannelGroupModel(QObject *parent)
	: QSortFilterProxyModel(parent)
{
	setSortLocaleAware(true);
	setSortRole(IOChannelGroupModel::GroupNameRole);
	sort(0, Qt::AscendingOrder);
}
