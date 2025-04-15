/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "basenotification.h"

using namespace Victron::VenusOS;

int BaseNotification::notificationId() const
{
	return m_notificationId;
}

void BaseNotification::setNotificationId(int notificationId)
{
	if (m_notificationId != notificationId) {
		m_notificationId = notificationId;
		Q_EMIT notificationIdChanged();
	}
}

bool BaseNotification::acknowledged() const
{
	return m_acknowledged;
}

void BaseNotification::setAcknowledged(bool acknowledged)
{
	if (m_acknowledged != acknowledged) {
		const bool prevActiveOrUnAcknowledged = activeOrUnAcknowledged();
		m_acknowledged = acknowledged;
		Q_EMIT acknowledgedChanged();
		if (activeOrUnAcknowledged() != prevActiveOrUnAcknowledged) {
			Q_EMIT activeOrUnAcknowledgedChanged();
		}
	}
}

bool BaseNotification::active() const
{
	return m_active;
}

void BaseNotification::setActive(bool active)
{
	if (m_active != active) {
		const bool prevActiveOrUnAcknowledged = activeOrUnAcknowledged();
		m_active = active;
		Q_EMIT activeChanged();
		if (activeOrUnAcknowledged() != prevActiveOrUnAcknowledged) {
			Q_EMIT activeOrUnAcknowledgedChanged();
		}
	}
}

bool BaseNotification::activeOrUnAcknowledged() const
{
	return m_active || !m_acknowledged;
}

int BaseNotification::type() const
{
	return m_type;
}

void BaseNotification::setType(int type)
{
	if (m_type != type) {
		m_type = type;
		Q_EMIT typeChanged();
	}
}

QDateTime BaseNotification::dateTime() const
{
	return m_dateTime;
}

void BaseNotification::setDateTime(const QDateTime &dateTime)
{
	if (m_dateTime != dateTime) {
		m_dateTime = dateTime;
		Q_EMIT dateTimeChanged();
	}
}

QString BaseNotification::description() const
{
	return m_description;
}

void BaseNotification::setDescription(const QString &description)
{
	if (m_description != description) {
		m_description = description;
		Q_EMIT descriptionChanged();
	}
}

QString BaseNotification::deviceName() const
{
	return m_deviceName;
}

void BaseNotification::setDeviceName(const QString &deviceName)
{
	if (m_deviceName != deviceName) {
		m_deviceName = deviceName;
		Q_EMIT deviceNameChanged();
	}
}

QString BaseNotification::value() const
{
	return m_value;
}

void BaseNotification::setValue(const QString &value)
{
	if (m_value != value) {
		m_value = value;
		Q_EMIT valueChanged();
	}
}
