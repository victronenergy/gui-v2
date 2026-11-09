/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIPLUGINS_PLUGINDEVICEMODEL_H
#define VICTRON_GUIPLUGINS_PLUGINDEVICEMODEL_H

#include <QAbstractListModel>
#include <QHash>
#include <QList>
#include <QPointer>
#include <QQmlParserStatus>
#include <QSet>
#include <QStringList>
#include <QVariant>
#include <qqmlintegration.h>

class VeQuickItem;

namespace Victron {
namespace VenusOS {
class Device;
class FilteredDeviceModel;
}
namespace GuiPlugins {

/*
	A list of the devices on the system, for plugins.

	Set serviceTypes to the short names, such as "tank". Set requiredPaths to list only the devices
	that have a valid value at each of those paths. The devices are sorted by name. Each one has a
	service uid, service type, device instance, name and product id. Read a value on that device
	with a PluginDataItem, using the device's service uid and a path. availableServiceTypes is the
	service types of every device on the system, regardless of the serviceTypes value.
*/
class PluginDeviceModel : public QAbstractListModel, public QQmlParserStatus
{
	Q_OBJECT
	QML_ELEMENT
	Q_INTERFACES(QQmlParserStatus)
	Q_PROPERTY(QStringList serviceTypes READ serviceTypes WRITE setServiceTypes NOTIFY serviceTypesChanged FINAL)
	Q_PROPERTY(QStringList requiredPaths READ requiredPaths WRITE setRequiredPaths NOTIFY requiredPathsChanged FINAL)
	Q_PROPERTY(QStringList availableServiceTypes READ availableServiceTypes NOTIFY availableServiceTypesChanged FINAL)
	Q_PROPERTY(int count READ count NOTIFY countChanged FINAL)

public:
	explicit PluginDeviceModel(QObject *parent = nullptr);

	QStringList serviceTypes() const;
	void setServiceTypes(const QStringList &serviceTypes);

	QStringList requiredPaths() const;
	void setRequiredPaths(const QStringList &requiredPaths);

	QStringList availableServiceTypes() const;

	int count() const;

	Q_INVOKABLE QString serviceUidAt(int index) const;
	Q_INVOKABLE QString serviceTypeAt(int index) const;
	Q_INVOKABLE int deviceInstanceAt(int index) const;
	Q_INVOKABLE QString nameAt(int index) const;
	Q_INVOKABLE int productIdAt(int index) const;

	int rowCount(const QModelIndex &parent = QModelIndex()) const override;
	QVariant data(const QModelIndex &index, int role) const override;
	QHash<int, QByteArray> roleNames() const override;

	void classBegin() override;
	void componentComplete() override;

Q_SIGNALS:
	void serviceTypesChanged();
	void requiredPathsChanged();
	void availableServiceTypesChanged();
	void countChanged();

private:
	enum Role {
		ServiceUidRole = Qt::UserRole,
		ServiceTypeRole,
		DeviceInstanceRole,
		NameRole,
		ProductIdRole
	};

	VenusOS::Device *deviceAt(int index) const;
	int rowOf(const VenusOS::Device *device) const;
	void watchDevice(VenusOS::Device *device);
	void deviceFieldChanged();
	void sourceDataChanged(const QModelIndex &topLeft, const QModelIndex &bottomRight, const QList<int> &roles);
	void updateFromSource();
	void updateAgain();
	void runUpdate();
	QList<QPointer<VenusOS::Device>> listedDevices();
	void updateRows(const QList<QPointer<VenusOS::Device>> &devices);
	bool hasRequiredPaths(const VenusOS::Device *device, QSet<QString> *watchedUids);
	void updateAvailableServiceTypes();

	VenusOS::FilteredDeviceModel *m_devices = nullptr;
	QList<QPointer<VenusOS::Device>> m_rows;
	QStringList m_requiredPaths;
	QHash<QString, VeQuickItem *> m_requiredItems;
	QStringList m_availableServiceTypes;
	int m_repeatedUpdates = 0;
	bool m_completed = false;
	bool m_updating = false;
	bool m_changedDuringUpdate = false;
	bool m_updateAgainPending = false;
};

} // namespace GuiPlugins
} // namespace Victron

#endif // VICTRON_GUIPLUGINS_PLUGINDEVICEMODEL_H
