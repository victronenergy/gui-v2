/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef AGGREGATEDEVICEMODEL_H
#define AGGREGATEDEVICEMODEL_H

#include <QObject>
#include <QAbstractListModel>

#include "basedevicemodel.h"

namespace Victron {

namespace VenusOS {

class AggregateDeviceModel : public QAbstractListModel
{
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(int count READ count NOTIFY countChanged)
	Q_PROPERTY(int disconnectedDeviceCount READ disconnectedDeviceCount NOTIFY disconnectedDeviceCountChanged)
	Q_PROPERTY(QVariantList sourceModels READ sourceModels WRITE setSourceModels NOTIFY sourceModelsChanged)

public:
	enum RoleNames {
		DeviceRole = Qt::UserRole,
		SourceModelRole,
		ConnectedRole,
		CachedDeviceDescriptionRole
	};

	explicit AggregateDeviceModel(QObject *parent = nullptr);
	~AggregateDeviceModel();

	QVariantList sourceModels() const;
	void setSourceModels(const QVariantList &models);

	int count() const;
	int disconnectedDeviceCount() const;

	int rowCount(const QModelIndex &parent) const override;
	QVariant data(const QModelIndex& index, int role) const override;

	Q_INVOKABLE void removeDisconnectedDevices();

signals:
	void countChanged();
	void disconnectedDeviceCountChanged();
	void sourceModelsChanged();

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
		QString cachedDeviceDescription;
	};

	void sourceModelRowsInserted(const QModelIndex &parent, int first, int last);
	int indexOf(const QString &deviceInfoId) const;
	int indexOf(const BaseDevice *device) const;
	int insertionIndex(BaseDevice *device) const;
	void deviceDescriptionChanged();
	void deviceValidChanged();
	void cleanUp();

	QHash<int, QByteArray> m_roleNames;
	QVector<DeviceInfo> m_deviceInfos;
	QVariantList m_sourceModels;
	int m_disconnectedDeviceCount = 0;
};

} /* VenusOS */

} /* Victron */
#endif // AggregateDeviceModel_H
