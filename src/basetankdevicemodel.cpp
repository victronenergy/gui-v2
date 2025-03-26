/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "basetankdevicemodel.h"
#include "basetankdevice.h"

using namespace Victron::VenusOS;

BaseTankDeviceModel::BaseTankDeviceModel(QObject *parent)
	: BaseDeviceModel(parent)
{
	connect(this, &BaseDeviceModel::rowsInserted, this, &BaseTankDeviceModel::modelRowsInserted);
	connect(this, &BaseDeviceModel::rowsRemoved, this, &BaseTankDeviceModel::modelRowsRemoved);
}

int BaseTankDeviceModel::type() const
{
	return m_type;
}

void BaseTankDeviceModel::setType(int type)
{
	if (m_type != type) {
		m_type = type;
		emit typeChanged();
	}
}

qreal BaseTankDeviceModel::averageLevel() const
{
	return m_averageLevel;
}

void BaseTankDeviceModel::setAverageLevel(qreal averageLevel)
{
	if (m_averageLevel != averageLevel) {
		m_averageLevel = averageLevel;
		emit averageLevelChanged();
	}
}

qreal BaseTankDeviceModel::totalCapacity() const
{
	return m_totalCapacity;
}

void BaseTankDeviceModel::setTotalCapacity(qreal totalCapacity)
{
	if (m_totalCapacity != totalCapacity) {
		m_totalCapacity = totalCapacity;
		emit totalCapacityChanged();
	}
}

qreal BaseTankDeviceModel::totalRemaining() const
{
	return m_totalRemaining;
}

void BaseTankDeviceModel::setTotalRemaining(qreal totalRemaining)
{
	if (m_totalRemaining != totalRemaining) {
		m_totalRemaining = totalRemaining;
		emit totalRemainingChanged();
	}
}

BaseTankDevice *BaseTankDeviceModel::tankAt(int index) const
{
	return qobject_cast<BaseTankDevice*>(deviceAt(index));
}

void BaseTankDeviceModel::modelRowsInserted(const QModelIndex &parent, int first, int last)
{
	for (int i = first; i <= last; ++i) {
		// Update the totals whenever the measurements change for each tank. A device typically
		// changes all of these values at the same time for each device, so delay the update until
		// the end of the event loop to minimize unnecessary recalculations.
		if (BaseTankDevice *tank = tankAt(i)) {
			connect(tank, &BaseTankDevice::levelChanged,
					this, &BaseTankDeviceModel::updateTotals,
					Qt::QueuedConnection);
			connect(tank, &BaseTankDevice::capacityChanged,
					this, &BaseTankDeviceModel::updateTotals,
					Qt::QueuedConnection);
			connect(tank, &BaseTankDevice::remainingChanged,
					this, &BaseTankDeviceModel::updateTotals,
					Qt::QueuedConnection);
		}
	}
	updateTotals();
}

void BaseTankDeviceModel::modelRowsRemoved(const QModelIndex &parent, int first, int last)
{
	for (int i = first; i <= last; ++i) {
		if (BaseTankDevice *tank = tankAt(i)) {
			tank->disconnect(this);
		}
	}
	updateTotals();
}

// TODO move this to a common place with Units::sumRealNumbers()
qreal BaseTankDeviceModel::sumOf(qreal a, qreal b) const
{
	const bool aNaN = qIsNaN(a);
	const bool bNaN = qIsNaN(b);

	return (aNaN && bNaN) ? qQNaN()
		: aNaN ? b
		: bNaN ? a
		: (a+b);
}

void BaseTankDeviceModel::updateTotals()
{
	qreal totalLevel = qQNaN();
	qreal totalCapacity = qQNaN();
	qreal totalRemaining = qQNaN();
	bool requireFallback = false;

	for (int i = 0; i < count(); ++i) {
		if (const BaseTankDevice *tank = tankAt(i)) {
			totalLevel = sumOf(totalLevel, tank->level());
			totalCapacity = sumOf(totalCapacity, tank->capacity());
			totalRemaining = sumOf(totalRemaining, tank->remaining());
			if (!requireFallback) {
				requireFallback = qIsNaN(tank->remaining()) || qIsNaN(tank->capacity());
			}
		}
	}

	setTotalCapacity(totalCapacity);
	setTotalRemaining(totalRemaining);

	if (!requireFallback && !qIsNaN(totalRemaining) && !qIsNaN(totalCapacity) && totalCapacity > 0) {
		// if we know all tank capacities and usages, we can calculate the combined level.
		setAverageLevel(totalRemaining / totalCapacity * 100);
	} else {
		// only fall back to a crude average level if we don't know all tank capacities and usages.
		setAverageLevel(qIsNaN(totalLevel) || count() == 0 ? qQNaN() : totalLevel / count());
	}
}
