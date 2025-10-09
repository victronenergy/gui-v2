/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "notificationsortfilterproxymodel.h"
#include "notificationmodel.h"
#include "enums.h"

namespace Victron {

namespace VenusOS {

NotificationSortFilterProxyModel::NotificationSortFilterProxyModel(QObject *parent)
	: QSortFilterProxyModel(parent)
{
	setSortCaseSensitivity(Qt::CaseInsensitive);
	setFilterCaseSensitivity(Qt::CaseInsensitive);

	sort(0, Qt::AscendingOrder);

	connect(this, &QSortFilterProxyModel::rowsInserted,  this, &NotificationSortFilterProxyModel::updateCount);
	connect(this, &QSortFilterProxyModel::rowsRemoved,   this, &NotificationSortFilterProxyModel::updateCount);
	connect(this, &QSortFilterProxyModel::modelReset,    this, &NotificationSortFilterProxyModel::updateCount);
	connect(this, &QSortFilterProxyModel::layoutChanged, this, &NotificationSortFilterProxyModel::updateCount);

	updateCount();
}

NotificationSortFilterProxyModel::~NotificationSortFilterProxyModel()
{
}

int NotificationSortFilterProxyModel::count() const
{
	return m_count;
}

bool NotificationSortFilterProxyModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
	Q_UNUSED(sourceRow)
	Q_UNUSED(sourceParent)
	return true;
}

bool NotificationSortFilterProxyModel::lessThan(const QModelIndex &sourceLeft, const QModelIndex &sourceRight) const
{
	NotificationModel *model = qobject_cast<NotificationModel*>(sourceModel());
	if (!model) {
		qWarning() << "NotificationSortFilterProxyModel: invalid source model";
		return false;
	}

	const notificationData left = model->at(sourceLeft.row());
	const notificationData right = model->at(sourceRight.row());

	// sort active notifications before inactive notifications
	if (left.active != right.active) {
		return left.active;
	}

	// sort unacknowledged notifications before acknowledged notifications
	if (left.acknowledged != right.acknowledged) {
		return !left.acknowledged;
	}

	// sort by type: ALARM < WARNING < INFO
	if (left.type != right.type) {
		if (left.type == Enums::Notification_Alarm) {
			return true;
		}
		if (right.type == Enums::Notification_Info) {
			return true;
		}
		return false;
	}

	// sort more recent notifications before older notifications
	if (left.dateTime != right.dateTime) {
		return left.dateTime > right.dateTime;
	}

	// fall back to default sort order
	return QSortFilterProxyModel::lessThan(sourceLeft, sourceRight);
}

void NotificationSortFilterProxyModel::updateCount()
{
	const int count = rowCount();
	if (m_count != count) {
		m_count = count;
		Q_EMIT countChanged();
	}
}

} /* VenusOS */

} /* Victron */
