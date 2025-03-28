/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef AGGREGATEDEVICEMODEL_H
#define AGGREGATEDEVICEMODEL_H

#include <QObject>
#include <QAbstractListModel>

#include "basedevicemodel.h"
#include "basedevice.h"

namespace Victron {

namespace VenusOS {

class AggregateDeviceModel : public QAbstractListModel
{
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(int count READ count NOTIFY countChanged)
	Q_PROPERTY(int sortBy READ sortBy WRITE setSortBy NOTIFY sortByChanged)
	Q_PROPERTY(int disconnectedDeviceCount READ disconnectedDeviceCount NOTIFY disconnectedDeviceCountChanged)
	Q_PROPERTY(QVariantList sourceModels READ sourceModels WRITE setSourceModels NOTIFY sourceModelsChanged)
	Q_PROPERTY(bool retainDevices READ retainDevices WRITE setRetainDevices NOTIFY retainDevicesChanged)

public:
	enum RoleNames {
		DeviceRole = Qt::UserRole,
		SourceModelRole,
		ConnectedRole,
		CachedDeviceNameRole
	};

	enum SortBy {
		NoSort,
		SortByDeviceName = 0x1,
		SortBySourceModel = 0x2
	};
	Q_ENUM(SortBy)
	Q_DECLARE_FLAGS(SortByOptions, SortBy)

	explicit AggregateDeviceModel(QObject *parent = nullptr);
	~AggregateDeviceModel();

	QVariantList sourceModels() const;
	void setSourceModels(const QVariantList &models);

	// True if model should keep entries even after they are removed from the source models.
	// (Only the device uid and name will be kept; the device pointer will be discarded.)
	bool retainDevices() const;
	void setRetainDevices(bool retainDevices);

	void setSortBy(int sortBy);
	int sortBy() const;

	int count() const;
	int disconnectedDeviceCount() const;

	int rowCount(const QModelIndex &parent) const override;
	QVariant data(const QModelIndex& index, int role) const override;

	Q_INVOKABLE BaseDevice *deviceAt(int index) const;
	Q_INVOKABLE BaseDeviceModel *sourceModelAt(int index) const;
	Q_INVOKABLE void removeDisconnectedDevices();

signals:
	void countChanged();
	void disconnectedDeviceCountChanged();
	void sourceModelsChanged();
	void retainDevicesChanged();
	void sortByChanged();

protected:
	QHash<int, QByteArray> roleNames() const override;

private:
	class DeviceInfo
	{
	public:
		DeviceInfo(BaseDevice *d, BaseDeviceModel *m);
		~DeviceInfo();
		bool isConnected() const;

		static QString infoId(BaseDevice *device, BaseDeviceModel *sourceModel);

		// The id uniquely identifies the device even when it is disconnected. It is a combination
		// of the sourceModel's modelId and the device serviceUid. (It cannot be just the device
		// serviceUid, since e.g. a vebus device may appear in both the vebus and AC input models.)
		QString id;
		QPointer<BaseDevice> device;
		QPointer<BaseDeviceModel> sourceModel;
		QString cachedDeviceName;
	};

	void sourceModelRowsInserted(const QModelIndex &parent, int first, int last);
	void sourceModelRowsAboutToBeRemoved(const QModelIndex &parent, int first, int last);
	int indexOf(const QString &deviceInfoId) const;
	int indexOf(const BaseDevice *device) const;
	int insertionIndex(BaseDevice *device, BaseDeviceModel *sourceModel) const;
	int sortedDeviceIndex(BaseDevice *device, BaseDeviceModel *sourceModel, int defaultValue = -1) const;
	void deviceNameChanged();
	void deviceValidChanged();
	void cleanUp();

	QHash<int, QByteArray> m_roleNames;
	QSet<QString> m_disconnectedDeviceIds;
	QVector<DeviceInfo> m_deviceInfos;
	QVariantList m_sourceModels;
	bool m_retainDevices = false;
	int m_sortBy = SortByDeviceName;
};

} /* VenusOS */

} /* Victron */

Q_DECLARE_OPERATORS_FOR_FLAGS(Victron::VenusOS::AggregateDeviceModel::SortByOptions)

#endif // AggregateDeviceModel_H
