/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_IOCHANNELGROUPMODEL_H
#define VICTRON_GUIV2_IOCHANNELGROUPMODEL_H

#include <QAbstractListModel>
#include <QSortFilterProxyModel>
#include <QStringList>
#include <QMap>
#include <QPointer>
#include <QQmlListProperty>
#include <qqmlintegration.h>

#include "basedevice.h"

class VeQItem;

namespace Victron {
namespace VenusOS {

class IOChannel;
class IOChannelGroupModel;
class Device;

/*
	A group of of channels.

	This is either a named group, with a custom user-defined name, or the group for a device on the
	system.
*/
class IOChannelGroup : public QObject
{
	Q_OBJECT
	QML_ELEMENT
	QML_UNCREATABLE("Created by IOChannelGroupModel")
	Q_PROPERTY(QString name READ name NOTIFY nameChanged FINAL)
	Q_PROPERTY(QQmlListProperty<IOChannel> channels READ channels NOTIFY channelsChanged FINAL)
public:
	QString groupId() const;
	QQmlListProperty<IOChannel> channels();

	// Returns the group name (either the named group, or the service/device name)
	QString name() const;
	void setName(const QString &name);

	bool addChannel(IOChannel *channel);
	bool removeChannel(const QString &channelUid);
	bool isRemainingChannel(const QString &channelUid) const;

	static IOChannelGroup *newNamedGroup(const QString &groupName, QObject *parent);
	static IOChannelGroup *newDeviceGroup(const QString &serviceUid, QObject *parent);
	static QString namedGroupId(const QString &groupName);
	static QString deviceGroupId(const QString &serviceUid);

Q_SIGNALS:
	void nameChanged();
	void channelsChanged();

private:
	explicit IOChannelGroup(QObject *parent, const QString &groupId);
	void sortChannels();
	void initializeDevice(Device *device);

	QList<IOChannel *> m_channels;
	QString m_groupId;
	QString m_name;
};


/*
	A model of IO channel groups.

	If /Settings/Group is set for a channel, then the channel is added to the group with that name;
	otherwise, it is added to the group for its device.

	When all channels are removed from a named group or device group, that group is automatically
	removed from the model.
*/
class IOChannelGroupModel : public QAbstractListModel
{
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(int count READ count NOTIFY countChanged FINAL)

public:
	enum Role {
		GroupRole = Qt::UserRole,
		GroupNameRole
	};
	Q_ENUM(Role)

	explicit IOChannelGroupModel(QObject *parent = nullptr);
	~IOChannelGroupModel();

	int count() const;

	int rowCount(const QModelIndex &parent) const override;
	QVariant data(const QModelIndex& index, int role) const override;

Q_SIGNALS:
	void countChanged();

protected:
	QHash<int, QByteArray> roleNames() const override;

private:
	struct ChannelInfo {
		IOChannel *channel = nullptr;
		QString groupId; // The current group of the channel
	};

	void cleanUp();
	void addAvailableServices();
	void anyServiceAdded(VeQItem *serviceItem);
	void addChannelChildren(VeQItem *channelParentItem);
	void anyServiceAboutToBeRemoved(VeQItem *serviceItem);
	void addChannelForItem(VeQItem *channelItem);
	void removeChannelForItem(VeQItem *channelItem);
	int indexOfGroup(const QString &groupId) const;
	void addChannelToItsGroup(IOChannel *channel);
	void removeChannelFromItsGroup(const QString &channelUid);

	QList<IOChannelGroup *> m_groups;
	QHash<QString, ChannelInfo> m_channels;
};

/*
	Provides a sorted IOChannelGroupModel.

	Groups are sorted by name.
*/
class SortedIOChannelGroupModel : public QSortFilterProxyModel
{
	Q_OBJECT
	QML_ELEMENT
public:
	explicit SortedIOChannelGroupModel(QObject *parent = nullptr);
};


} /* VenusOS */
} /* Victron */

#endif // VICTRON_GUIV2_IOCHANNELGROUPMODEL_H
