/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include <QQmlContext>

#include "notificationsortfilterproxymodel.h"

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

	connect(this, &QSortFilterProxyModel::rowsInserted,  this, &NotificationSortFilterProxyModel::countChanged);
	connect(this, &QSortFilterProxyModel::rowsRemoved,   this, &NotificationSortFilterProxyModel::countChanged);
	connect(this, &QSortFilterProxyModel::modelReset,    this, &NotificationSortFilterProxyModel::countChanged);
	connect(this, &QSortFilterProxyModel::layoutChanged, this, &NotificationSortFilterProxyModel::countChanged);
}

NotificationSortFilterProxyModel::~NotificationSortFilterProxyModel()
{
	delete d;
}

int NotificationSortFilterProxyModel::count(const QModelIndex &parent) const
{
	return rowCount(parent);
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
		const QVariantMap notification = get(sourceRow);
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
	if (d->m_engine && d->m_sortFunction.isCallable()) {
		const QVariantMap left = get(sourceLeft.row());
		const QVariantMap right = get(sourceRight.row());
		QJSValueList args = { d->m_engine->toScriptValue(left), d->m_engine->toScriptValue(right) };
		return d->m_sortFunction.call(args).toBool();
	}
	return QSortFilterProxyModel::lessThan(sourceLeft, sourceRight);
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

QVariantMap NotificationSortFilterProxyModel::get(int index) const
{
	if(!this->sourceModel()) {
		return QVariantMap();
	}

	if (index < 0 || index >= this->sourceModel()->rowCount()) {
		qWarning() << "NotificationSortFilterProxyModel::get(index): invalid index:" << index;
		return QVariantMap();
	}

	QVariantMap map;

	QHash<int, QByteArray> roles = this->sourceModel()->roleNames();
	for (auto it = roles.begin(); it != roles.end(); ++it) {
		map.insert(QLatin1String(it.value()), this->sourceModel()->data(this->sourceModel()->index(index, 0), it.key()));
	}
	return map;
}

} /* VenusOS */

} /* Victron */
