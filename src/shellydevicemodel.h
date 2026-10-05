/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_SHELLYDEVICEMODEL_H
#define VICTRON_GUIV2_SHELLYDEVICEMODEL_H

#include <QAbstractListModel>
#include <QPointer>
#include <QSortFilterProxyModel>
#include <qqmlintegration.h>

class VeQItem;

namespace Victron {
namespace VenusOS {

/*
	A model of all devices on the shelly service. This information is sourced from
	"com.victronenergy.shelly/Devices".

	Each device has paths like:

	/Devices/<id>/Model
	/Devices/<id>/Name
	/Devices/<id>/Mac

	When a scan is done, the /Devices child paths are invalidated (but still exist), so only devices
	with a valid /Model value are included in the model.
*/
class ShellyDeviceModel : public QAbstractListModel
{
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(int count READ count NOTIFY countChanged FINAL)

public:
	enum Role {
		UidRole = Qt::UserRole,
		NameRole
	};
	Q_ENUM(Role)

	explicit ShellyDeviceModel(QObject *parent = nullptr);

	int count() const;

	int rowCount(const QModelIndex &parent) const override;
	QVariant data(const QModelIndex &index, int role) const override;

Q_SIGNALS:
	void countChanged();

protected:
	QHash<int, QByteArray> roleNames() const override;

private:
	struct ShellyDevice {
		QString uid;
		QString name;
	};

	void serviceAdded(VeQItem *serviceItem);
	void serviceAboutToBeRemoved(VeQItem *serviceItem);
	void setServiceItem(VeQItem *serviceItem);
	void deviceItemAdded(VeQItem *deviceItem);
	void deviceChildItemAdded(VeQItem *childItem);
	void scheduleUpdate();
	void update();

	QList<ShellyDevice> m_devices;
	QPointer<VeQItem> m_devicesItem;
	bool m_updateScheduled = false;
};

/*
	Provides a ShellyDeviceModel sorted by device name.
*/
class SortedShellyDeviceModel : public QSortFilterProxyModel
{
	Q_OBJECT
	QML_ELEMENT
public:
	explicit SortedShellyDeviceModel(QObject *parent = nullptr);
};

} /* VenusOS */
} /* Victron */

#endif // VICTRON_GUIV2_SHELLYDEVICEMODEL_H
