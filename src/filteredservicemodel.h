/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_FILTEREDSERVICEMODEL_H
#define VICTRON_GUIV2_FILTEREDSERVICEMODEL_H

#include <QStringList>
#include <QSortFilterProxyModel>
#include <qqmlintegration.h>

namespace Victron {
namespace VenusOS {

/*
	Provides a service model that can be filtered based on the service type.
*/
class FilteredServiceModel : public QSortFilterProxyModel
{
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(int count READ count NOTIFY countChanged)
	Q_PROPERTY(QStringList serviceTypes READ serviceTypes WRITE setServiceTypes NOTIFY serviceTypesChanged)

public:
	explicit FilteredServiceModel(QObject *parent = nullptr);

	int count() const;

	QStringList serviceTypes() const;
	void setServiceTypes(const QStringList &serviceTypes);

Q_SIGNALS:
	void countChanged();
	void serviceTypesChanged();

protected:
	bool filterAcceptsRow(int sourceRow, const QModelIndex & sourceParent) const override;

private:
	void updateCount();

	QStringList m_serviceTypes;
	int m_count = 0;
};

} /* VenusOS */
} /* Victron */

#endif // VICTRON_GUIV2_FILTEREDSERVICEMODEL_H

