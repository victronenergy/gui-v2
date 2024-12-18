/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "notificationsortfilterproxymodel.h"
#include "allnotificationsmodel.h"

using namespace Victron::VenusOS;

NotificationSortFilterProxyModel::NotificationSortFilterProxyModel(QObject *parent) :
	QSortFilterProxyModel(parent)
{
	setSortCaseSensitivity(Qt::CaseInsensitive);
	setFilterCaseSensitivity(Qt::CaseInsensitive);

	sort(0, Qt::AscendingOrder);
}

bool NotificationSortFilterProxyModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
	const QModelIndex &index = sourceModel()->index(sourceRow, 0, sourceParent);
	return (m_filterOnAcknowledged ? index.data(AllNotificationsModel::NotificationRoles::Acknowledged).toBool() == m_acknowledged : true) &&
		   (m_filterOnActive ? index.data(AllNotificationsModel::NotificationRoles::Active).toBool() == m_active : true) &&
		   (m_filterOnType ? index.data(AllNotificationsModel::NotificationRoles::Type).toInt() == m_type : true);
}

bool NotificationSortFilterProxyModel::lessThan(const QModelIndex &left, const QModelIndex &right) const
{
	// sort by date
	const QDateTime &leftDateTime =  left.data(AllNotificationsModel::NotificationRoles::DateTime).toDateTime();
	const QDateTime &rightDateTime = right.data(AllNotificationsModel::NotificationRoles::DateTime).toDateTime();

	return leftDateTime > rightDateTime;
}

bool NotificationSortFilterProxyModel::acknowledged() const
{
	return m_acknowledged;
}

void NotificationSortFilterProxyModel::setAcknowledged(bool acknowledged)
{
	m_filterOnAcknowledged = true;
	if(m_acknowledged == acknowledged) {
		return;
	}
	m_acknowledged = acknowledged;
	emit acknowledgedChanged();
	invalidateFilter();
}

void NotificationSortFilterProxyModel::resetAcknowledged()
{
	setAcknowledged(false);
	m_filterOnAcknowledged = false;
	invalidateFilter();
}

bool NotificationSortFilterProxyModel::active() const
{
	return m_active;
}

void NotificationSortFilterProxyModel::setActive(bool active)
{
	m_filterOnActive = true;
	if (m_active == active) {
		return;
	}
	m_active = active;
	emit activeChanged();
	invalidateFilter();
}

void NotificationSortFilterProxyModel::resetActive()
{
	setActive(false);
	m_filterOnActive = false;
	invalidateFilter();
}

int NotificationSortFilterProxyModel::type() const
{
	return m_type;
}

void NotificationSortFilterProxyModel::setType(int type)
{
	m_filterOnType = true;
	if (m_type == type) {
		return;
	}
	m_type = type;
	emit typeChanged();
	invalidateFilter();
}

void NotificationSortFilterProxyModel::resetType()
{
	setType(-1);
	m_filterOnType = false;
	invalidateFilter();
}
