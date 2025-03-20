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
