/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_EVCHARGERDEVICEMODEL_H
#define VICTRON_GUIV2_EVCHARGERDEVICEMODEL_H

#include <QtGlobal>
#include <QPointer>
#include <QAbstractListModel>
#include <QSortFilterProxyModel>

#include <veutil/qt/ve_qitem.hpp>

#include "device.h"

class QTimerEvent;

namespace Victron {
namespace VenusOS {

/*
	A model of all EV chargers on the system.

	Note this model is not sorted.
*/
class EvChargerDeviceModel : public QAbstractListModel
{
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(int count READ count NOTIFY countChanged FINAL)
	Q_PROPERTY(Device *firstObject READ firstObject NOTIFY firstObjectChanged FINAL)
	Q_PROPERTY(qreal totalPower READ totalPower NOTIFY totalPowerChanged FINAL)
	Q_PROPERTY(qreal totalCurrent READ totalCurrent NOTIFY totalCurrentChanged FINAL)
	Q_PROPERTY(qreal totalEnergy READ totalEnergy NOTIFY totalEnergyChanged FINAL)
	Q_PROPERTY(qreal inputPower READ inputPower NOTIFY inputPowerChanged)
	Q_PROPERTY(qreal outputPower READ outputPower NOTIFY outputPowerChanged)
	Q_PROPERTY(int inputCount READ inputCount NOTIFY inputCountChanged)
	Q_PROPERTY(int outputCount READ outputCount NOTIFY outputCountChanged)
public:
	enum Role {
		DeviceRole = Qt::UserRole,
		NameRole,
		StatusRole,
		EnergyRole,
	};
	Q_ENUM(Role)

	explicit EvChargerDeviceModel(QObject *parent = nullptr);
	~EvChargerDeviceModel();

	int count() const;
	Device *firstObject() const;

	qreal totalPower() const;
	qreal totalCurrent() const;
	qreal totalEnergy() const;
	qreal inputPower() const;
	qreal outputPower() const;
	int inputCount() const;
	int outputCount() const;

	QVariant data(const QModelIndex& index, int role) const override;
	int rowCount(const QModelIndex &parent) const override;

	Q_INVOKABLE Device *deviceAt(int index) const; // Note: object has CppOwnership.

Q_SIGNALS:
	void countChanged();
	void firstObjectChanged();
	void totalPowerChanged();
	void totalCurrentChanged();
	void totalEnergyChanged();
	void inputCountChanged();
	void outputCountChanged();
	void inputPowerChanged();
	void outputPowerChanged();

protected:
	QHash<int, QByteArray> roleNames() const override;
	void timerEvent(QTimerEvent *event) override;

private:
	struct EvCharger {
		void disconnect(EvChargerDeviceModel *model);

		QPointer<Device> device;
		QPointer<VeQItem> statusItem;
		QPointer<VeQItem> positionItem;
		QPointer<VeQItem> powerItem;
		QPointer<VeQItem> currentItem;
		QPointer<VeQItem> energyItem;
		qreal energy = qQNaN();
	};

	int indexOf(const QString &serviceUid) const;
	void clearEvChargers();
	void addAvailableEvChargers();
	void sourceDeviceAdded(const QModelIndex &parent, int first, int last);
	void sourceDeviceAboutToBeRemoved(const QModelIndex &parent, int first, int last);
	void addEvChargerDevice(Device *device);
	void scheduleUpdateTotals();
	void updateTotals();
	void updateFirstEvCharger();
	void serviceChildAdded(VeQItem *child);
	void chargerStatusChanged(QVariant value);

	QVector<EvCharger> m_chargers;
	QString m_firstUid;
	qreal m_totalPower = qQNaN();
	qreal m_totalCurrent = qQNaN();
	qreal m_totalEnergy = qQNaN();
	qreal m_inputPower = qQNaN();
	qreal m_outputPower = qQNaN();
	int m_inputCount = 0;
	int m_outputCount = 0;
	int m_timerId = 0;
};

/*
	Provides a sorted EvChargerDeviceModel.

	Devices are sorted by their device name.
*/
class SortedEvChargerDeviceModel : public QSortFilterProxyModel
{
	Q_OBJECT
	QML_ELEMENT
public:
	explicit SortedEvChargerDeviceModel(QObject *parent = nullptr);
};

} /* VenusOS */
} /* Victron */

#endif // VICTRON_GUIV2_EVCHARGERDEVICEMODEL_H

