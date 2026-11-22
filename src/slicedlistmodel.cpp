/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "slicedlistmodel.h"

#include <algorithm>

using namespace Victron::VenusOS;

SlicedListModel::SlicedListModel(QObject *parent)
	: QSortFilterProxyModel(parent)
{
}

int SlicedListModel::start() const
{
	return m_start;
}

void SlicedListModel::setStart(int start)
{
	start = std::max(start, 0);
	if (m_start != start) {
		m_start = start;
		invalidateRowsFilter();
		emit startChanged();
	}
}

int SlicedListModel::count() const
{
	return m_count;
}

void SlicedListModel::setCount(int count)
{
	count = std::max(count, -1);
	if (m_count != count) {
		m_count = count;
		invalidateRowsFilter();
		emit countChanged();
	}
}

void SlicedListModel::setSourceModel(QAbstractItemModel *sourceModel)
{
	for (const QMetaObject::Connection &connection : std::as_const(m_sourceConnections)) {
		disconnect(connection);
	}
	m_sourceConnections.clear();

	// The base class connects to the source model's signals first, so these are called after it
	// has passed on each change.
	QSortFilterProxyModel::setSourceModel(sourceModel);

	if (sourceModel) {
		m_sourceConnections = {
			connect(sourceModel, &QAbstractItemModel::rowsInserted, this,
					[this](const QModelIndex &parent) {
				if (!parent.isValid()) {
					sourceRowsChanged();
				}
			}),
			connect(sourceModel, &QAbstractItemModel::rowsRemoved, this,
					[this](const QModelIndex &parent) {
				if (!parent.isValid()) {
					sourceRowsChanged();
				}
			}),
			connect(sourceModel, &QAbstractItemModel::rowsMoved, this,
					[this](const QModelIndex &sourceParent, int, int, const QModelIndex &destinationParent) {
				if (!sourceParent.isValid() || !destinationParent.isValid()) {
					sourceRowsChanged();
				}
			}),
		};
	}
}

// The base class only filters the rows that are inserted, and keeps the rows that it has already
// accepted or rejected. But rows inserted, removed or moved before the end of the slice move other
// rows into or out of it, so filter all of the rows again.
void SlicedListModel::sourceRowsChanged()
{
	invalidateRowsFilter();
}

bool SlicedListModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
	if (sourceParent.isValid()) {
		return true;
	}
	if (sourceRow < m_start) {
		return false;
	}
	return m_count < 0 || sourceRow - m_start < m_count;
}
