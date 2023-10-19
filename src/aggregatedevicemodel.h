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
	Q_PROPERTY(int count READ count NOTIFY countChanged)
	Q_PROPERTY(QVariantList sourceModels READ sourceModels WRITE setSourceModels NOTIFY sourceModelsChanged)

public:
	enum RoleNames {
		DeviceRole = Qt::UserRole,
		SourceModelRole
	};

	explicit AggregateDeviceModel(QObject *parent = nullptr);
	~AggregateDeviceModel();

	QVariantList sourceModels() const;
	void setSourceModels(const QVariantList &models);

	int count() const;

	int rowCount(const QModelIndex &parent) const override;
	QVariant data(const QModelIndex& index, int role) const override;

	// TODO Q_INVOKABLE void removeDisconnectedDevices();

signals:
	void countChanged();
	void sourceModelsChanged();

protected:
	QHash<int, QByteArray> roleNames() const override;

private:
	struct DeviceInfo {
		QPointer<BaseDevice> device;
		QPointer<BaseDeviceModel> sourceModel;
	};

	void sourceModelRowsInserted(const QModelIndex &parent, int first, int last);
	void sourceModelRowsAboutToBeRemoved(const QModelIndex &parent, int first, int last);
	int indexOf(const BaseDevice *device) const;
	int insertionIndex(BaseDevice *device) const;
	void deviceDescriptionChanged();
	void cleanUp();

	QHash<int, QByteArray> m_roleNames;
	QVector<DeviceInfo> m_deviceInfos;
	QVariantList m_sourceModels;
};

} /* VenusOS */

} /* Victron */
#endif // AggregateDeviceModel_H
