/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "basetankdevice.h"

#include <QQmlInfo>

using namespace Victron::VenusOS;

BaseTankDevice::BaseTankDevice(QObject *parent)
	: BaseDevice(parent)
{
}

void BaseTankDevice::updateMeasurements()
{
	// If one of the measurements are unavailable, calculate it from the other two (if available).
	if (qIsNaN(m_level) && !qIsNaN(m_capacity) && !qIsNaN(m_remaining)) {
		// Calculate level
		if (m_capacity > 0) {
			m_level = m_remaining / m_capacity * 100;
		}
	} else if (!qIsNaN(m_level) && qIsNaN(m_capacity) && !qIsNaN(m_remaining)) {
		// Calculate capacity
		if (m_level > 0) {
			m_capacity = m_remaining / (m_level / 100);
		}
	} else if (!qIsNaN(m_level) && !qIsNaN(m_capacity) && qIsNaN(m_remaining)) {
		// Calculate remaining
		m_remaining = m_capacity * (m_level / 100);
	}
}

int BaseTankDevice::type() const
{
	return m_type;
}

void BaseTankDevice::setType(int type)
{
	if (m_type != type) {
		m_type = type;
		emit typeChanged();
	}
}

qreal BaseTankDevice::level() const
{
	return m_level;
}

void BaseTankDevice::setLevel(qreal level)
{
	if (m_level != level) {
		m_level = level;
		updateMeasurements();
		emit levelChanged();
	}
}

qreal BaseTankDevice::capacity() const
{
	return m_capacity;
}

void BaseTankDevice::setCapacity(qreal capacity)
{
	if (m_capacity != capacity) {
		m_capacity = capacity;
		updateMeasurements();
		emit capacityChanged();
	}
}

qreal BaseTankDevice::remaining() const
{
	return m_remaining;
}

void BaseTankDevice::setRemaining(qreal remaining)
{
	if (m_remaining != remaining) {
		m_remaining = remaining;
		updateMeasurements();
		emit remainingChanged();
	}
}
