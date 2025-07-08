/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_SWITCHABLEOUTPUTMODEL_H
#define VICTRON_GUIV2_SWITCHABLEOUTPUTMODEL_H

#include <QSortFilterProxyModel>
#include <QMap>
#include <qqmlintegration.h>

class VeQItemTableModel;
class VeQItem;

namespace Victron {
namespace VenusOS {

class SwitchableOutputModel : public QSortFilterProxyModel
{
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(FilterType filterType READ filterType WRITE setFilterType NOTIFY filterTypeChanged FINAL)
	// Q_PROPERTY(QString systemUid READ systemUid WRITE setSystemUid NOTIFY systemUidChanged FINAL REQUIRED)
	Q_PROPERTY(int count READ count NOTIFY countChanged FINAL)

public:
	enum Role {
		UidRole = Qt::UserRole,
		NameRole
	};
	Q_ENUM(Role)

	enum FilterType {
		NoFilter,
		ManualFunction,
	};
	Q_ENUM(FilterType)

	explicit SwitchableOutputModel(QObject *parent = nullptr);

	int count() const;

	FilterType filterType() const;
	void setFilterType(FilterType filterType);

	void setSourceModel(QAbstractItemModel *) override;
	// int rowCount(const QModelIndex &parent) const override;
	QVariant data(const QModelIndex& index, int role) const override;

Q_SIGNALS:
	void countChanged();
	void filterTypeChanged();

protected:
	QHash<int, QByteArray> roleNames() const override;
	bool filterAcceptsRow(int sourceRow, const QModelIndex &) const override;
	bool lessThan(const QModelIndex &sourceLeft, const QModelIndex &sourceRight) const override;

private:
	class Entry {
	public:
		QString name() const;

		VeQItem *nameItem = nullptr;
		VeQItem *customNameItem = nullptr;
		VeQItem *functionItem = nullptr;
	};

	void addEntry(const QString &outputUid);
	void removeEntry(const QString &outputUid);
	// void outputNameChanged();
	// void outputCustomNameChanged();
	// void outputValueChanged();
	void sourceModelRowsInserted(const QModelIndex &parent, int first, int last);
	void sourceModelRowsAboutToBeRemoved(const QModelIndex &parent, int first, int last);

	QMap<QString, Entry> m_entries;
	VeQItemTableModel *m_model = nullptr;
	QString m_systemUid;
	FilterType m_filterType = NoFilter;
};

} /* VenusOS */
} /* Victron */

#endif // VICTRON_GUIV2_SWITCHABLEOUTPUTMODEL_H
