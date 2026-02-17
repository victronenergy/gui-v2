/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_SWITCHABLEOUTPUTMODEL_H
#define VICTRON_GUIV2_SWITCHABLEOUTPUTMODEL_H

#include <QSortFilterProxyModel>
#include <QMap>
#include <QPointer>
#include <qqmlintegration.h>

#include <veutil/qt/ve_qitem.hpp>

class VeQItem;

namespace Victron {
namespace VenusOS {

class SwitchableOutputModel : public QSortFilterProxyModel
{
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(FilterType filterType READ filterType WRITE setFilterType NOTIFY filterTypeChanged FINAL)
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
	~SwitchableOutputModel();

	int count() const;

	FilterType filterType() const;
	void setFilterType(FilterType filterType);

	void setSourceModel(QAbstractItemModel *) override;
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
		void disconnect(QObject *object);

		QPointer<VeQItem> nameItem;
		QPointer<VeQItem> customNameItem;
		QPointer<VeQItem> functionItem;
	};

	void sourceModelRowsInserted(const QModelIndex &parent, int first, int last);
	void sourceModelRowsAboutToBeRemoved(const QModelIndex &parent, int first, int last);
	void clearEntries();
	void addEntry(const QString &outputUid);
	void updateCount();

	QMap<QString, Entry> m_entries;
	FilterType m_filterType = NoFilter;
	int m_count = 0;
};

} /* VenusOS */
} /* Victron */

#endif // VICTRON_GUIV2_SWITCHABLEOUTPUTMODEL_H
