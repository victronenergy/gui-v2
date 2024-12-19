/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef NOTIFICATIONSORTFILTERPROXYMODEL_H
#define NOTIFICATIONSORTFILTERPROXYMODEL_H

#include <QObject>
#include <qqmlintegration.h>
#include <QSortFilterProxyModel>
#include <QDateTime>

namespace Victron {

namespace VenusOS {

class NotificationSortFilterProxyModel : public QSortFilterProxyModel
{
	Q_OBJECT
	QML_ELEMENT

	Q_PROPERTY(bool acknowledged READ acknowledged WRITE setAcknowledged RESET resetAcknowledged NOTIFY acknowledgedChanged FINAL)
	Q_PROPERTY(bool active READ active WRITE setActive RESET resetActive NOTIFY activeChanged FINAL)
	Q_PROPERTY(int type READ type WRITE setType RESET resetType NOTIFY typeChanged FINAL)
	Q_PROPERTY(bool sortByType READ sortByType WRITE setSortByType NOTIFY sortByTypeChanged FINAL)
	Q_PROPERTY(bool sortByTime READ sortByTime WRITE setSortByTime NOTIFY sortByTimeChanged FINAL)

public:
	explicit NotificationSortFilterProxyModel(QObject *parent = 0);

	bool acknowledged() const;
	void setAcknowledged(bool acknowledged);
	void resetAcknowledged();

	bool active() const;
	void setActive(bool active);
	void resetActive();

	int type() const;
	void setType(int type);
	void resetType();

	bool sortByType() const;
	void setSortByType(bool sortByType);
	bool sortByTime() const;
	void setSortByTime(bool sortByTime);

signals:
	void acknowledgedChanged();
	void activeChanged();
	void typeChanged();
	void sortByTypeChanged();
	void sortByTimeChanged();

protected:
	virtual bool filterAcceptsRow(int sourceRow, const QModelIndex & sourceParent) const;
	bool lessThan(const QModelIndex &left, const QModelIndex &right) const;

private:
	bool m_acknowledged = false;
	bool m_filterOnAcknowledged = false;

	bool m_active = false;
	bool m_filterOnActive = false;

	int m_type = -1;
	bool m_filterOnType = false;
	bool m_sortByType = false;
	bool m_sortByTime = true;
};

} /* VenusOS */

} /* Victron */
#endif // NOTIFICATIONSORTFILTERPROXYMODEL_H
