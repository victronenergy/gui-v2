/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_SWITCHABLEOUTPUTMODEL_H
#define VICTRON_GUIV2_SWITCHABLEOUTPUTMODEL_H

#include <QAbstractListModel>
#include <QStringList>
#include <QMap>
#include <qqmlintegration.h>

#include "basedevice.h"

namespace Victron {
namespace VenusOS {

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
	Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
	enum Role {
		NameRole = Qt::UserRole,
		OutputUidsRole
	};
	Q_ENUM(Role)

	explicit SwitchableOutputGroupModel(QObject *parent = nullptr);
	~SwitchableOutputGroupModel();

	int count() const;

	Q_INVOKABLE void addOutputToNamedGroup(const QString &namedGroup, const QString &outputUid, const QString &outputSortToken);
	Q_INVOKABLE void addOutputToDeviceGroup(const QString &serviceUid, const QString &outputUid, const QString &outputSortToken);

	Q_INVOKABLE void removeOutputFromNamedGroup(const QString &namedGroup, const QString &outputUid);
	Q_INVOKABLE void removeOutputFromDeviceGroup(const QString &serviceUid, const QString &outputUid);

	// Device groups require addKnownDevice() to be called first, to provide an appropriate device.
	// Note: this model takes ownership of the device.
	Q_INVOKABLE void addKnownDevice(BaseDevice *device);
	Q_INVOKABLE bool hasKnownDevice(const QString &serviceUid) const;

	Q_INVOKABLE int indexOfNamedGroup(const QString &namedGroup) const;
	Q_INVOKABLE int indexOfDeviceGroup(const QString &serviceUid) const;

	Q_INVOKABLE void updateSortTokenInGroup(int groupIndex, const QString &outputUid, const QString &outputSortToken);

	int rowCount(const QModelIndex &parent) const override;
	QVariant data(const QModelIndex& index, int role) const override;

Q_SIGNALS:
	void countChanged();

protected:
	QHash<int, QByteArray> roleNames() const override;

private:
	struct Group {
		static Group fromName(const QString &groupName);
		static Group fromDevice(BaseDevice *device);

		void refreshName(BaseDevice *device = nullptr);

		QStringList outputUids;
		QString deviceServiceUid; // only set if this is a device group
		QString namedGroup; // only set if this is a named group
		QString name;
	};

	void updateDeviceGroupName(BaseDevice *device);
	int insertionIndex(const Group &group) const;
	int sortedGroupIndex(const Group &group, int defaultValue) const;
	int countGroupsWithDevice(const QString &serviceUid);
	void addOutputToGroup(int index, const QString &outputUid);
	void removeOutputFromGroup(int index, const QString &outputUid);
	void insertGroupAt(int index, const Group &group);
	void removeGroupAt(int index);
	void moveDeviceGroupToSortedIndex(int groupIndex);

	bool outputUidLessThan(const QString &outputUid1, const QString &outputUid2) const;
	int outputUidInsertionIndex(const QStringList &outputUids, const QString &outputUid) const;

	QMap<QString, BaseDevice *> m_knownDevices;
	QMap<QString, QString> m_outputSortTokens;
	QList<Group> m_groups;
};

} /* VenusOS */
} /* Victron */

#endif // VICTRON_GUIV2_SWITCHABLEOUTPUTMODEL_H
