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

#include <functional>

namespace Victron {
namespace VenusOS {

class BaseDevice : public QObject
{
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(bool valid READ isValid NOTIFY validChanged)
	Q_PROPERTY(QString serviceUid READ serviceUid WRITE setServiceUid NOTIFY serviceUidChanged)
	Q_PROPERTY(int deviceInstance READ deviceInstance WRITE setDeviceInstance NOTIFY deviceInstanceChanged)
	Q_PROPERTY(int productId READ productId WRITE setProductId NOTIFY productIdChanged)
	Q_PROPERTY(QString productName READ productName WRITE setProductName NOTIFY productNameChanged)
	Q_PROPERTY(QString customName READ customName WRITE setCustomName NOTIFY customNameChanged)
	Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
	Q_PROPERTY(QString description READ description WRITE setDescription NOTIFY descriptionChanged)

public:
	explicit BaseDevice(QObject *parent = nullptr);

	bool isValid() const;

	QString serviceUid() const;
	void setServiceUid(const QString &serviceUid);

	int deviceInstance() const;
	void setDeviceInstance(int deviceInstance);

	int productId() const;
	void setProductId(int productId);

	QString productName() const;
	void setProductName(const QString &productName);

	QString customName() const;
	void setCustomName(const QString &customName);

	QString name() const;
	void setName(const QString &name);

	QString description() const;
	void setDescription(const QString &description);

Q_SIGNALS:
	void validChanged();
	void serviceUidChanged();
	void deviceInstanceChanged();
	void productNameChanged();
	void customNameChanged();
	void productIdChanged();
	void nameChanged();
	void descriptionChanged();

private:
	void maybeEmitValidChanged(const std::function<void()>& propertyChangeFunc);

	QString m_serviceUid;
	QString m_name;
	QString m_description;
	QString m_productName;
	QString m_customName;
	int m_deviceInstance = -1;
	int m_productId = 0;
};


class BaseDeviceModel : public QAbstractListModel
{
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(int count READ count NOTIFY countChanged)
	Q_PROPERTY(QString modelId READ modelId WRITE setModelId NOTIFY modelIdChanged)
	Q_PROPERTY(BaseDevice *firstObject READ firstObject NOTIFY firstObjectChanged)

public:
	enum RoleNames {
		DeviceRole = Qt::UserRole
	};

	explicit BaseDeviceModel(QObject *parent = nullptr);

	BaseDevice *firstObject() const;    // the object with the lowest DeviceInstance
	int count() const;

	QString modelId() const;    // must be unique across all BaseDeviceModel instances
	void setModelId(const QString &modelId);

	int rowCount(const QModelIndex &parent) const override;
	QVariant data(const QModelIndex& index, int role) const override;

	Q_INVOKABLE bool addDevice(BaseDevice *device);
	Q_INVOKABLE bool removeDevice(const QString &serviceUid);
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

protected:
	QHash<int, QByteArray> roleNames() const override;

private:
	int insertionIndex(const BaseDevice *device) const;
	void refreshFirstObject();

	QHash<int, QByteArray> m_roleNames;
	QVector<QPointer<BaseDevice> > m_devices;
	QPointer<BaseDevice> m_firstObject;
	QString m_modelId;
};

} /* VenusOS */
} /* Victron */

#endif // BASEDEVICEMODEL_H
