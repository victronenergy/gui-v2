/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "filteredservicemodel.h"
#include "allservicesmodel.h"

#include <QQmlInfo>

using namespace Victron::VenusOS;

FilteredServiceModel::FilteredServiceModel(QObject *parent)
	: QSortFilterProxyModel(parent)
{
	connect(this, &QSortFilterProxyModel::rowsInserted, this, &FilteredServiceModel::updateCount);
	connect(this, &QSortFilterProxyModel::rowsRemoved, this, &FilteredServiceModel::updateCount);
	connect(this, &QSortFilterProxyModel::modelReset, this, &FilteredServiceModel::updateCount);
	connect(this, &QSortFilterProxyModel::layoutChanged, this, &FilteredServiceModel::updateCount);

	setSourceModel(AllServicesModel::create());
	updateCount();
}

int FilteredServiceModel::count() const
{
	return m_count;
}

QStringList FilteredServiceModel::serviceTypes() const
{
	return m_serviceTypes;
}

void FilteredServiceModel::setServiceTypes(const QStringList &serviceTypes)
{
	if (m_serviceTypes != serviceTypes) {
		m_serviceTypes = serviceTypes;
		if (m_completed) {
			invalidateFilter();
		}
		emit serviceTypesChanged();
	}
}

void FilteredServiceModel::classBegin()
{
}

void FilteredServiceModel::componentComplete()
{
	m_completed = true;
	invalidateFilter();
}

bool FilteredServiceModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
	Q_UNUSED(sourceParent)

	// Do not include any services if serviceTypes is not yet set. Otherwise, from QML, we will
	// initially see all services present in the model.
	if (!m_completed) {
		return false;
	}

	if (m_serviceTypes.isEmpty()) {
		return true;
	}

	return m_serviceTypes.contains(sourceModel()->data(sourceModel()->index(sourceRow, 0), 
			AllServicesModel::ServiceTypeRole).toString());
}

void FilteredServiceModel::updateCount()
{
	const int count = rowCount();
	if (m_count != count) {
		m_count = count;
		emit countChanged();
	}
}

