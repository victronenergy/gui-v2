#ifndef BASEDEVICEMODEL_H
#define BASEDEVICEMODEL_H

#include <QObject>
#include <QPointer>
#include <QAbstractListModel>

namespace Victron {

namespace VenusOS {

class BaseDevice : public QObject
{
	Q_OBJECT
	Q_PROPERTY(QString serviceUid READ serviceUid WRITE setServiceUid NOTIFY serviceUidChanged)
	Q_PROPERTY(int deviceInstance READ deviceInstance WRITE setDeviceInstance NOTIFY deviceInstanceChanged)
	Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
	Q_PROPERTY(QString description READ description WRITE setDescription NOTIFY descriptionChanged)

public:
	explicit BaseDevice(QObject *parent = nullptr);

	QString serviceUid() const;
	void setServiceUid(const QString &serviceUid);

	int deviceInstance() const;
	void setDeviceInstance(int deviceInstance);

	QString name() const;
	void setName(const QString &name);

	QString description() const;
	void setDescription(const QString &description);

Q_SIGNALS:
	void serviceUidChanged();
	void deviceInstanceChanged();
	void nameChanged();
	void descriptionChanged();

private:
	QString m_serviceUid;
	QString m_name;
	QString m_description;
	int m_deviceInstance = -1;
};


class BaseDeviceModel : public QAbstractListModel
{
	Q_OBJECT
	Q_PROPERTY(int count READ count NOTIFY countChanged)
	Q_PROPERTY(BaseDevice *firstObject READ firstObject NOTIFY firstObjectChanged)

public:
	enum RoleNames {
		DeviceRole = Qt::UserRole
	};

	explicit BaseDeviceModel(QObject *parent = nullptr);

	BaseDevice *firstObject() const;    // the object with the lowest DeviceInstance
	int count() const;

	int rowCount(const QModelIndex &parent) const override;
	QVariant data(const QModelIndex& index, int role) const override;

	Q_INVOKABLE bool addDevice(BaseDevice *device);
	Q_INVOKABLE bool removeDevice(const QString &serviceUid);
	Q_INVOKABLE void clear();

	Q_INVOKABLE int indexOf(const QString &serviceUid) const;
	Q_INVOKABLE BaseDevice *deviceForDeviceInstance(int deviceInstance) const;
	Q_INVOKABLE BaseDevice *deviceAt(int index) const;

Q_SIGNALS:
	void countChanged();
	void firstObjectChanged();

protected:
	QHash<int, QByteArray> roleNames() const override;

private:
	int insertionIndex(const BaseDevice *device) const;
	void refreshFirstObject();

	QHash<int, QByteArray> m_roleNames;
	QVector<QPointer<BaseDevice> > m_devices;
	QPointer<BaseDevice> m_firstObject;
};

} /* VenusOS */

} /* Victron */
#endif // BASEDEVICEMODEL_H
