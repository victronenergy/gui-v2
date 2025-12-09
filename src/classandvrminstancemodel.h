/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_CLASSANDVRMINSTANCEMODEL_H
#define VICTRON_GUIV2_CLASSANDVRMINSTANCEMODEL_H

#include <QAbstractListModel>
#include <QSortFilterProxyModel>
#include <QPointer>
#include <qqmlintegration.h>

#include <veutil/qt/ve_qitem.hpp>

#include "basedevice.h"

class VeQItem;

namespace Victron {
namespace VenusOS {

class Device;

class ClassAndVrmInstance : public QObject
{
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(QString uid READ uid WRITE setUid NOTIFY uidChanged FINAL)
	Q_PROPERTY(QString deviceClass READ deviceClass NOTIFY deviceClassChanged FINAL)
	Q_PROPERTY(int vrmInstance READ vrmInstance NOTIFY vrmInstanceChanged FINAL)
	Q_PROPERTY(QString name READ name NOTIFY nameChanged FINAL)

public:
	// Used when creating from QML.
	explicit ClassAndVrmInstance(QObject *parent = nullptr);

	// Used when creating from ClassAndVrmInstanceModel.
	ClassAndVrmInstance(QObject *parent, VeQItem *instanceItem, VeQItem *customNameItem);

	bool isValid() const;
	VeQItem *instanceItem();

	QString uid() const;
	void setUid(const QString &uid); // Used from QML to load data from a /ClassAndVrmInstance path

	int vrmInstance() const;
	QString deviceClass() const;
	QString name() const;

	bool hasVrmInstanceChanges() const;

	Q_INVOKABLE bool setVrmInstance(int newVrmInstance);

Q_SIGNALS:
	void validChanged();
	void uidChanged();
	void deviceClassChanged();
	void vrmInstanceChanged();
	void nameChanged();

private:
	void initialize(VeQItem *instanceItem, VeQItem *customNameItem);
	void setDevice(Device *device);
	void classAndVrmInstanceChanged(QVariant variant);
	void customNameChanged(QVariant variant);
	void updateName();

	QPointer<VeQItem> m_customNameItem;
	QString m_deviceClass;
	QString m_name;
	VeQItem *m_item = nullptr;
	BaseDevice *m_device = nullptr;
	int m_vrmInstance = -1;
	int m_pendingVrmInstance = -1;
	int m_initialVrmInstance = -1;
};


/*
	A model of each device class+instance available on the system, as provided in the settings under
	/Settings/Devices/.../ClassAndVrmInstance.

	com.victronenergy.settings/Settings/Devices/<unique device identifier>/ClassAndVrmInstance
	defines a "<class>:<instance>" pair, where <class> is a device class (basically a service type
	like "tank", but not always), and <instance> is a VRM instance number. The VRM instance is like
	a device instance that identifies a device; however, the VRM instance can be changed by the
	user, so that when a new device is installed on a Victron system, it can be given the same
	instance as some other device that is being replaced.
*/
class ClassAndVrmInstanceModel : public QAbstractListModel
{
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(int count READ count NOTIFY countChanged FINAL)

public:
	enum Role {
		ValidRole = Qt::UserRole,
		UidRole,
		VrmInstanceRole,
		DeviceClassRole,
		NameRole
	};
	Q_ENUM(Role)

	explicit ClassAndVrmInstanceModel(QObject *parent = nullptr);

	int count() const;

	int rowCount(const QModelIndex &parent) const override;
	QVariant data(const QModelIndex& index, int role) const override;

	// Returns the /ClassAndVrmInstance path for the given class/instance.
	Q_INVOKABLE QString findInstanceUid(const QString &deviceClass, int vrmInstance) const;

	// Returns the maximum known VRM instance number for the given device class.
	Q_INVOKABLE int maximumVrmInstance(const QString &deviceClass) const;

	// Changes the VRM instance number.
	Q_INVOKABLE bool setVrmInstance(const QString &instanceUid, int newVrmInstance);

	// Returns true if any instances have changed during the lifetime of the model.
	Q_INVOKABLE bool hasVrmInstanceChanges() const;

Q_SIGNALS:
	void countChanged();

protected:
	QHash<int, QByteArray> roleNames() const override;

private:
	void addInstanceForParentItem(VeQItem *instanceParentItem);
	void instanceParentAboutToBeRemoved(VeQItem *serviceItem);
	void emitRoleChanged(ClassAndVrmInstance *instance, Role role);

	QList<ClassAndVrmInstance *> m_instances;
};

/*
	Provides a sorted ClassAndVrmInstanceModel.
*/
class SortedClassAndVrmInstanceModel : public QSortFilterProxyModel
{
	Q_OBJECT
	QML_ELEMENT
public:
	explicit SortedClassAndVrmInstanceModel(QObject *parent = nullptr);

	bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;
	bool lessThan(const QModelIndex &sourceLeft, const QModelIndex &sourceRight) const override;
};


} /* VenusOS */
} /* Victron */

#endif // VICTRON_GUIV2_SWITCHABLEOUTPUTMODEL_H
