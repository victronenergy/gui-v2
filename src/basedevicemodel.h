/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef BASEDEVICEMODEL_H
#define BASEDEVICEMODEL_H

#include <QObject>
#include <QPointer>
#include <QAbstractListModel>
#include <qqmlintegration.h>

#include "basedevice.h"

namespace Victron {
namespace VenusOS {

class BaseDeviceModel : public QAbstractListModel
{
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(int count READ count NOTIFY countChanged)
	Q_PROPERTY(int sortBy READ sortBy WRITE setSortBy NOTIFY sortByChanged)
	Q_PROPERTY(QString modelId READ modelId WRITE setModelId NOTIFY modelIdChanged)
	Q_PROPERTY(BaseDevice *firstObject READ firstObject NOTIFY firstObjectChanged)

public:
	enum RoleNames {
		DeviceRole = Qt::UserRole
	};

	enum SortBy {
		NoSort,
		SortByDeviceName = 0x1,
		SortByDeviceInstance = 0x2  // Sort from lowest to highest
	};
	Q_ENUM(SortBy)

	explicit BaseDeviceModel(QObject *parent = nullptr);

	BaseDevice *firstObject() const;
	int count() const;

	QString modelId() const;    // must be unique across all BaseDeviceModel instances
	void setModelId(const QString &modelId);

	void setSortBy(int sortBy);
	int sortBy() const;

	int rowCount(const QModelIndex &parent) const override;
	QVariant data(const QModelIndex& index, int role) const override;

	Q_INVOKABLE bool addDevice(BaseDevice *device);
	Q_INVOKABLE bool removeDevice(const QString &serviceUid);
	Q_INVOKABLE bool removeAt(int index);
	Q_INVOKABLE void intersect(const QStringList &serviceUids); // remove entries that are not in this list
	Q_INVOKABLE void clear();
	Q_INVOKABLE void deleteAllAndClear();

	Q_INVOKABLE int indexOf(const QString &serviceUid) const;
	Q_INVOKABLE BaseDevice *deviceForDeviceInstance(int deviceInstance) const;
	Q_INVOKABLE BaseDevice *deviceAt(int index) const;

Q_SIGNALS:
	void countChanged();
	void firstObjectChanged();
	void modelIdChanged();
	void sortByChanged();

protected:
	QHash<int, QByteArray> roleNames() const override;
	void deviceNameChanged();

private:
	int insertionIndex(const BaseDevice *device) const;
	void refreshFirstObject();
	bool lessThan(const BaseDevice *deviceA, const BaseDevice *deviceB) const;

	QHash<int, QByteArray> m_roleNames;
	QVector<QPointer<BaseDevice> > m_devices;
	QPointer<BaseDevice> m_firstObject;
	QString m_modelId;
	int m_sortBy = SortByDeviceName;
};

} /* VenusOS */
} /* Victron */

#endif // BASEDEVICEMODEL_H
