/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_SWITCHABLEOUTPUTGROUPMODEL_H
#define VICTRON_GUIV2_SWITCHABLEOUTPUTGROUPMODEL_H

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

class SwitchableOutput;
class SwitchableOutputGroupModel;
class Device;

/*
	A group of of switchable outputs.

	This is either a named group, with a custom user-defined name, or the group for a device on the
	system.
*/
class SwitchableOutputGroup : public QObject
{
	Q_OBJECT
	QML_ELEMENT
	QML_UNCREATABLE("Created by SwitchableOutputGroupModel")
	Q_PROPERTY(QString name READ name NOTIFY nameChanged FINAL)
	Q_PROPERTY(QQmlListProperty<SwitchableOutput> outputs READ outputs NOTIFY outputsChanged FINAL)
public:
	QString groupId() const;
	QQmlListProperty<SwitchableOutput> outputs();

	// Returns the group name (either the named group, or the service/device name)
	QString name() const;
	void setName(const QString &name);

	bool addOutput(SwitchableOutput *output);
	bool removeOutput(const QString &outputUid);
	bool isRemainingOutput(const QString &outputUid) const;

	static SwitchableOutputGroup *newNamedGroup(const QString &groupName, QObject *parent);
	static SwitchableOutputGroup *newDeviceGroup(const QString &serviceUid, QObject *parent);
	static QString namedGroupId(const QString &groupName);
	static QString deviceGroupId(const QString &serviceUid);

Q_SIGNALS:
	void nameChanged();
	void outputsChanged();

private:
	explicit SwitchableOutputGroup(QObject *parent, const QString &groupId);
	void sortOutputs();
	void initializeDevice(Device *device);

	QList<SwitchableOutput *> m_outputs;
	QString m_groupId;
	QString m_name;
};


/*
	A model of switchable output groups.

	If /SwitchableOutput/x/Settings/Group is set for a switchable output, then the output should
	be added to the group with that name; otherwise, it should be added to the group for its
	device.

	When all switchable outputs are removed from a named group or device group, that group is
	automatically removed from the model.
*/
class SwitchableOutputGroupModel : public QAbstractListModel
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

	explicit SwitchableOutputGroupModel(QObject *parent = nullptr);
	~SwitchableOutputGroupModel();

	int count() const;

	int rowCount(const QModelIndex &parent) const override;
	QVariant data(const QModelIndex& index, int role) const override;

Q_SIGNALS:
	void countChanged();

protected:
	QHash<int, QByteArray> roleNames() const override;

private:
	struct SwitchableOutputInfo {
		SwitchableOutput *output = nullptr;
		QString groupId; // The current group of the output
	};

	void cleanUp();
	void addAvailableServices();
	void anyServiceAdded(VeQItem *serviceItem);
	void addSwitchableOutputChildren(VeQItem *switchableOutputParentItem);
	void anyServiceAboutToBeRemoved(VeQItem *serviceItem);
	void addOutputForItem(VeQItem *switchableOutputItem);
	void removeOutputForItem(VeQItem *switchableOutputItem);
	int indexOfGroup(const QString &groupId) const;
	void addOutputToItsGroup(SwitchableOutput *output);
	void removeOutputFromItsGroup(const QString &outputUid);

	QList<SwitchableOutputGroup *> m_groups;
	QHash<QString, SwitchableOutputInfo> m_outputs;
};

/*
	Provides a sorted SwitchableOutputGroupModel.

	Groups are sorted by name.
*/
class SortedSwitchableOutputGroupModel : public QSortFilterProxyModel
{
	Q_OBJECT
	QML_ELEMENT
public:
	explicit SortedSwitchableOutputGroupModel(QObject *parent = nullptr);
};


} /* VenusOS */
} /* Victron */

#endif // VICTRON_GUIV2_SWITCHABLEOUTPUTMODEL_H
