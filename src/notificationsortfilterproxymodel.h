/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_VENUSOS_GUI_V2_NOTIFICATIONSORTFILTERPROXYMODEL_H
#define VICTRON_VENUSOS_GUI_V2_NOTIFICATIONSORTFILTERPROXYMODEL_H

#include "notificationmodel.h"

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

public:
	explicit NotificationSortFilterProxyModel(QObject *parent = nullptr);
	~NotificationSortFilterProxyModel();

	int count() const;

	Q_INVOKABLE notificationData at(int row) const;

signals:
	void countChanged();

protected:
	bool filterAcceptsRow(int sourceRow, const QModelIndex & sourceParent) const override;
	bool lessThan(const QModelIndex &sourceLeft, const QModelIndex &sourceRight) const override;

private:
	void updateCount();
	int m_count = 0;
};

} /* VenusOS */

} /* Victron */

#endif // VICTRON_VENUSOS_GUI_V2_NOTIFICATIONSORTFILTERPROXYMODEL_H
