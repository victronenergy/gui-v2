/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include <QQmlContext>

#include "notificationsortfilterproxymodel.h"
#include "notificationsmodel.h"
#include "basenotification.h"
#include "enums.h"

namespace Victron {

namespace VenusOS {

class NotificationSortFilterProxyModelPrivate
{
public:
	QJSEngine *m_engine = nullptr;
	QJSValue m_filterFunction;
	QJSValue m_sortFunction;
};

NotificationSortFilterProxyModel::NotificationSortFilterProxyModel(QObject *parent) :
	QSortFilterProxyModel(parent),
	d(new NotificationSortFilterProxyModelPrivate())
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
	delete d;
}

int NotificationSortFilterProxyModel::count() const
{
	return m_count;
}

bool NotificationSortFilterProxyModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
	Q_UNUSED(sourceParent)
	if (!d->m_engine) {
		d->m_engine = getJSEngine();
		if (!d->m_engine)
			qWarning() << "NotificationSortFilterProxyModel can't filter without a JavaScript engine";
	}
	if (d->m_engine && d->m_filterFunction.isCallable()) {
		BaseNotification *notification = this->sourceModel()->data(this->sourceModel()->index(sourceRow, 0),
																   NotificationsModel::Notification).value<BaseNotification*>();
		QJSValueList args = { d->m_engine->toScriptValue(notification) };
		return d->m_filterFunction.call(args).toBool();
	}
	return true;
}

bool NotificationSortFilterProxyModel::lessThan(const QModelIndex &sourceLeft, const QModelIndex &sourceRight) const
{
	if (!d->m_engine) {
		d->m_engine = getJSEngine();
		if (!d->m_engine)
			qWarning() << "NotificationSortFilterProxyModel can't sort without a JavaScript engine";
	}

	BaseNotification *leftNotification = this->sourceModel()->data(
			this->sourceModel()->index(sourceLeft.row(), sourceLeft.column()),
			NotificationsModel::Notification).value<BaseNotification*>();
	BaseNotification *rightNotification = this->sourceModel()->data(
			this->sourceModel()->index(sourceRight.row(), sourceRight.column()),
			NotificationsModel::Notification).value<BaseNotification*>();

	if (d->m_engine && d->m_sortFunction.isCallable()) {
		QJSValueList args = { d->m_engine->toScriptValue(leftNotification), d->m_engine->toScriptValue(rightNotification) };
		return d->m_sortFunction.call(args).toBool();
	} else {
		// Use the default sort order.
		if (leftNotification->activeOrUnAcknowledged() != rightNotification->activeOrUnAcknowledged()) {
			return leftNotification->activeOrUnAcknowledged() && !rightNotification->activeOrUnAcknowledged();
		}

		if (leftNotification->active() != rightNotification->active()) {
			return leftNotification->active() && !rightNotification->active();
		}

		if (leftNotification->type() != rightNotification->type()) {
			if (leftNotification->type() == Enums::Notification_Alarm && rightNotification->type() != Enums::Notification_Alarm) {
				return true;
			}
			if (leftNotification->type() == Enums::Notification_Warning && rightNotification->type() == Enums::Notification_Info) {
				return true;
			}
			return false;
		}
		return leftNotification->dateTime() > rightNotification->dateTime();
	}

	return QSortFilterProxyModel::lessThan(sourceLeft, sourceRight);
}

void NotificationSortFilterProxyModel::updateCount()
{
	const int count = rowCount();

	if (m_count == count) {
		return;
	}
	m_count = count;
	emit countChanged();
}

QJSEngine * NotificationSortFilterProxyModel::getJSEngine() const
{
	QQmlContext *context = QQmlEngine::contextForObject(this);
	return context ? reinterpret_cast<QJSEngine*>(context->engine()) : nullptr;
}

QJSValue NotificationSortFilterProxyModel::filterFunction() const
{
	return d->m_filterFunction;
}

void NotificationSortFilterProxyModel::setFilterFunction(const QJSValue &callback)
{
	if (!callback.isCallable() && !callback.isNull() && !callback.isUndefined()) {
		qWarning() << "NotificationSortFilterProxyModel::setFilterFunction: The filterFunction property of NotificationSortFilterProxyModel needs to be either callable, or undefined/null to clear it.";
	}
	if (!callback.equals(d->m_filterFunction)) {
		d->m_filterFunction = callback;
		emit filterFunctionChanged();
		invalidateFilter();
	}
}

QJSValue NotificationSortFilterProxyModel::sortFunction() const
{
	return d->m_sortFunction;
}

void NotificationSortFilterProxyModel::setSortFunction(const QJSValue &callback)
{
	if (!callback.isCallable() && !callback.isNull() && !callback.isUndefined()) {
		qWarning() << "NotificationSortFilterProxyModel::setSortFunction: The sortFunction property of NotificationSortFilterProxyModel needs to be either callable, or undefined/null to clear it.";
	}
	if (!callback.equals(d->m_sortFunction)) {
		d->m_sortFunction = callback;
		emit sortFunctionChanged();
		invalidate();
		sort(0);
	}
}

} /* VenusOS */

} /* Victron */
