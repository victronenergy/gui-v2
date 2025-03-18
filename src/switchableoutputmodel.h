/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef SWITCHABLEOUTPUTMODEL_H
#define SWITCHABLEOUTPUTMODEL_H

#include <QAbstractListModel>
#include <QSortFilterProxyModel>
#include <qqmlintegration.h>

namespace Victron {
namespace VenusOS {


/*
  Provides a model for switchableOutput.

Main use of module is a data souce in the card view
 */
class SwitchableOutputModel : public QAbstractListModel
{
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(int count READ count NOTIFY countChanged FINAL)

public:

	enum Role {
		ServiceUidRole = Qt::UserRole,
		GroupRole,
		NameRole,
		SwitchTypeRole,
		RefIdRole,

	};
	Q_ENUM(Role)

	explicit SwitchableOutputModel(QObject *parent = nullptr);

	int count() const;

	int rowCount(const QModelIndex &parent) const override;
	QVariant data(const QModelIndex& index, int role) const override;

	Q_INVOKABLE void addSwitchableOutput(const QString &serviceUid, const QVariantMap &values);
	Q_INVOKABLE bool setSwitchableOutput(const QString &serviceUid, const QVariantMap &values);
	Q_INVOKABLE bool setSwitchableOutputValue(const QString &serviceUid, Role role, const QVariant &value);
	Q_INVOKABLE int indexOf(const QString &serviceUid) const;
	Q_INVOKABLE void removeAt(int index);
	Q_INVOKABLE void remove(const QString &serviceUid);

Q_SIGNALS:
	void countChanged();

protected:
	QHash<int, QByteArray> roleNames() const override;
	QStringList m_groupNames;

private:
	struct SwitchableOutput {
		QString serviceUid;
		QString group;
		QString name;
		int switchType;
		int refId;
	};

	QHash<int, QByteArray> m_roleNames;
	QVector<SwitchableOutput> m_tableData;
};

class SwitchableOutputProxyModel : public QSortFilterProxyModel
{
	Q_OBJECT
	QML_ELEMENT
	Q_ENUMS(Flags)
	Q_PROPERTY(Flags filterFlags READ filterFlags WRITE setFilterFlags NOTIFY filterFlagsChanged)
	Q_PROPERTY(QString group READ group WRITE setGroup NOTIFY groupChanged)
//	Q_PROPERTY(int sortRole READ sortRole WRITE se,tSortRole NOTIFY sortRoleChanged)
	Q_PROPERTY(int rowCount READ rowCount NOTIFY rowCountChanged)

public:
	enum Flag {
		None,
		FilterByGroup = 0,
		FilterGroupsOnly = 1,
	};

	Q_DECLARE_FLAGS(Flags, Flag)
	SwitchableOutputProxyModel(QObject* parent = 0);

	const Flags filterFlags() { return m_flags; }
	void setFilterFlags(Flags flags);

	bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const;

	const QString group(){ return m_group; }

//public slots:
	Q_INVOKABLE void setGroup(QString group);

signals:
	void modelChanged();
	void groupChanged();
	void filterFlagsChanged();
	void rowCountChanged();

private:
	QString m_group;
	Flags m_flags;
};

} /* VenusOS */
} /* Victron */

#endif // SOLARINPUTMODEL_H
