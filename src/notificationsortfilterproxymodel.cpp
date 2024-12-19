/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "notificationsortfilterproxymodel.h"
#include "notificationsmodel.h"

using namespace Victron::VenusOS;

NotificationSortFilterProxyModel::NotificationSortFilterProxyModel(QObject *parent) :
	QSortFilterProxyModel(parent)
{
	setSortCaseSensitivity(Qt::CaseInsensitive);
	setFilterCaseSensitivity(Qt::CaseInsensitive);

	sort(0, Qt::AscendingOrder);

	connect(this, &QSortFilterProxyModel::rowsInserted,  this, &NotificationSortFilterProxyModel::countChanged);
	connect(this, &QSortFilterProxyModel::rowsRemoved,   this, &NotificationSortFilterProxyModel::countChanged);
	connect(this, &QSortFilterProxyModel::modelReset,    this, &NotificationSortFilterProxyModel::countChanged);
	connect(this, &QSortFilterProxyModel::layoutChanged, this, &NotificationSortFilterProxyModel::countChanged);
}

int NotificationSortFilterProxyModel::count(const QModelIndex &parent) const
{
	return rowCount(parent);
}

bool NotificationSortFilterProxyModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
	const QModelIndex &index = sourceModel()->index(sourceRow, 0, sourceParent);
	return (m_filterOnAcknowledged ? index.data(NotificationsModel::NotificationRoles::Acknowledged).toBool() == m_acknowledged : true) &&
		   (m_filterOnActive ? index.data(NotificationsModel::NotificationRoles::Active).toBool() == m_active : true) &&
		   (m_filterOnType ? index.data(NotificationsModel::NotificationRoles::Type).toInt() == m_type : true);
}

bool NotificationSortFilterProxyModel::lessThan(const QModelIndex &left, const QModelIndex &right) const
{
	// sort by type, then by date
	const int leftType = left.data(NotificationsModel::NotificationRoles::Type).toInt();
	const int rightType = right.data(NotificationsModel::NotificationRoles::Type).toInt();

	const QDateTime &leftDateTime =  left.data(NotificationsModel::NotificationRoles::DateTime).toDateTime();
	const QDateTime &rightDateTime = right.data(NotificationsModel::NotificationRoles::DateTime).toDateTime();

	if(m_sortByType && m_sortByTime) {
		return leftType < rightType && leftDateTime > rightDateTime;
	}
	if(m_sortByTime) {
		return leftDateTime > rightDateTime;
	}
	if(m_sortByType) {
		return leftType < rightType;
	}
	return true;
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

bool NotificationSortFilterProxyModel::sortByType() const
{
	return m_sortByType;
}

void NotificationSortFilterProxyModel::setSortByType(bool sortByType)
{
	if (m_sortByType == sortByType) {
		return;
	}
	m_sortByType = sortByType;
	emit sortByTypeChanged();
	invalidateFilter();
}

bool NotificationSortFilterProxyModel::sortByTime() const
{
	return m_sortByTime;
}

void NotificationSortFilterProxyModel::setSortByTime(bool sortByTime)
{
	if (m_sortByTime == sortByTime) {
		return;
	}
	m_sortByTime = sortByTime;
	emit sortByTimeChanged();
	invalidateFilter();
}
