/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef NOTIFICATIONSORTFILTERPROXYMODEL_H
#define NOTIFICATIONSORTFILTERPROXYMODEL_H

#include <QObject>
#include <QQmlEngine>
#include <QSortFilterProxyModel>
#include <QDateTime>

namespace Victron {

namespace VenusOS {

class NotificationSortFilterProxyModelPrivate;

class NotificationSortFilterProxyModel : public QSortFilterProxyModel
{
	Q_OBJECT
	QML_ELEMENT

	Q_PROPERTY(int count READ count NOTIFY countChanged FINAL)
	Q_PROPERTY(QJSValue filterFunction READ filterFunction WRITE setFilterFunction NOTIFY filterFunctionChanged FINAL)
	Q_PROPERTY(QJSValue sortFunction READ sortFunction WRITE setSortFunction NOTIFY sortFunctionChanged FINAL)

public:
	explicit NotificationSortFilterProxyModel(QObject *parent = nullptr);
	~NotificationSortFilterProxyModel();

	int count() const;
	QJSValue filterFunction() const;
	void setFilterFunction(const QJSValue &callback);

	QJSValue sortFunction() const;
	void setSortFunction(const QJSValue &callback);

signals:
	void countChanged();
	void filterFunctionChanged();
	void sortFunctionChanged();

protected:
	bool filterAcceptsRow(int sourceRow, const QModelIndex & sourceParent) const override;
	bool lessThan(const QModelIndex &sourceLeft, const QModelIndex &sourceRight) const override;

private:
	void updateCount();
	NotificationSortFilterProxyModelPrivate *d = nullptr;
	QJSEngine *getJSEngine() const;
	int m_count = 0;
};

} /* VenusOS */

} /* Victron */
#endif // NOTIFICATIONSORTFILTERPROXYMODEL_H
