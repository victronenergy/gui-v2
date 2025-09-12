/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_EVCHARGERSTATUSMODEL_H
#define VICTRON_GUIV2_EVCHARGERSTATUSMODEL_H

#include <QtGlobal>
#include <QPointer>
#include <QSet>
#include <QAbstractListModel>

#include <veutil/qt/ve_qitem.hpp>

namespace Victron {
namespace VenusOS {

class Device;

/*
	A model of the status of EV chargers on the system.

	It provides the number of EV chargers with the following status codes:
	- Charging
	- Charged
	- Disconnected
*/
class EvChargerStatusModel : public QAbstractListModel
{
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(int count READ count CONSTANT)
public:
	enum Role {
		StatusRole = Qt::UserRole,
		StatusCountRole,
	};
	Q_ENUM(Role)

	explicit EvChargerStatusModel(QObject *parent = nullptr);

	int count() const;

	QVariant data(const QModelIndex& index, int role) const override;
	int rowCount(const QModelIndex &parent) const override;

protected:
	QHash<int, QByteArray> roleNames() const override;

private:
	struct StatusInfo {
		int status = -1;
		QSet<QString> statusUids;
	};

	void addAllKnownDeviceStatuses();
	void sourceDeviceAdded(const QModelIndex &parent, int first, int last);
	void sourceDeviceAboutToBeRemoved(const QModelIndex &parent, int first, int last);
	QSet<int> addStatusItem(VeQItem *statusItem);
	QSet<int> addStatusFromDevice(Device *device);
	QSet<int> setStatusForUid(const QString &statusItemUid, int status);
	int removeStatusUid(const QString &uid);
	void statusValueChanged(QVariant value);
	void emitStatusChanges(const QSet<int> &indexes);

	QList<StatusInfo> m_statusInfos;
};

} /* VenusOS */
} /* Victron */

#endif // VICTRON_GUIV2_EVCHARGERSTATUSMODEL_H

