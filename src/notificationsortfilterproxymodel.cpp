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

notificationData NotificationSortFilterProxyModel::at(int row) const
{
	NotificationModel *model = sourceModel() ? qobject_cast<NotificationModel*>(sourceModel()) : nullptr;
	if (model && row >= 0 && row < count()) {
		const QModelIndex pi = index(row, 0, QModelIndex());
		const QModelIndex si = mapToSource(pi);
		quint32 modelId = model->data(si, static_cast<int>(NotificationModel::NotificationRoles::ModelId)).value<quint32>();
		const notificationData ret = model->get(modelId);
		return ret;
	}
	return notificationData();
}

int NotificationSortFilterProxyModel::count() const
{
	return m_count;
}

bool NotificationSortFilterProxyModel::filterAcknowledged() const
{
	return m_filterAcknowledged;
}

void NotificationSortFilterProxyModel::setFilterAcknowledged(bool f)
{
	if (m_filterAcknowledged != f) {
		m_filterAcknowledged = f;
		Q_EMIT filterAcknowledgedChanged();
		invalidateFilter();
	}
}

bool NotificationSortFilterProxyModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
	if (m_filterAcknowledged) {
		// filter out any acknowledged notifications.
		return sourceModel() && !sourceModel()->data(
				sourceModel()->index(sourceRow, 0),
				static_cast<int>(NotificationModel::NotificationRoles::Acknowledged)).toBool();
	}
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

	// for active notifications only, sort by type before considering acknowledged status
	if (left.active && right.active) {
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
