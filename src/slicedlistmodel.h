/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_SLICEDLISTMODEL_H
#define VICTRON_GUIV2_SLICEDLISTMODEL_H

#include <QList>
#include <QSortFilterProxyModel>
#include <qqmlintegration.h>

namespace Victron {
namespace VenusOS {

/*
	A list model with a slice of the rows of sourceModel: up to count rows, from the row at start.

	If count is negative, the slice has all of the rows from start to the end of sourceModel. If
	start is past the last row, or count is 0, the slice is empty. A negative start is treated as 0.

	Each row has the roles of sourceModel. Only the top-level rows are sliced; the children of the
	rows in the slice are all included.

	The slice is of positions in sourceModel, not of particular rows: when rows are inserted,
	removed or moved in sourceModel, the rows that are now at those positions are in the slice.
	The changes are passed on as rows inserted into and removed from this model, so a view keeps
	the delegates of the rows that stay in the slice.

	Usage, to show the first five rows of a model in a row, and the rest in a column:

	Row {
		Repeater {
			model: SlicedListModel {
				sourceModel: buttonModel
				count: 5
			}
			delegate: ...
		}
	}
	Column {
		Repeater {
			model: SlicedListModel {
				sourceModel: buttonModel
				start: 5
			}
			delegate: ...
		}
	}
*/
class SlicedListModel : public QSortFilterProxyModel
{
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(int start READ start WRITE setStart NOTIFY startChanged FINAL)
	Q_PROPERTY(int count READ count WRITE setCount NOTIFY countChanged FINAL)

public:
	explicit SlicedListModel(QObject *parent = nullptr);

	int start() const;
	void setStart(int start);

	// The maximum number of rows in the slice, or a negative number for all rows from start.
	// rowCount() gives the number of rows that the slice has.
	int count() const;
	void setCount(int count);

	void setSourceModel(QAbstractItemModel *sourceModel) override;

Q_SIGNALS:
	void startChanged();
	void countChanged();

protected:
	bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;

private:
	void sourceRowsChanged();

	QList<QMetaObject::Connection> m_sourceConnections;
	int m_start = 0;
	int m_count = -1;
};

} /* VenusOS */
} /* Victron */

#endif // VICTRON_GUIV2_SLICEDLISTMODEL_H
