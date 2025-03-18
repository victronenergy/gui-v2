/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "switchableoutputmodel.h"

using namespace Victron::VenusOS;

/*------------------ SwitchableOutputProxyModel ----------------------------------------*/

SwitchableOutputProxyModel::SwitchableOutputProxyModel(QObject *parent): QSortFilterProxyModel(parent),
	m_group(""), m_flags(FilterByGroup)
{
	connect(this, SIGNAL(rowsRemoved(QModelIndex, int, int)), SIGNAL(rowCountChanged()));
	connect(this, SIGNAL(rowsInserted(QModelIndex, int, int)), SIGNAL(rowCountChanged()));
	QSortFilterProxyModel::setDynamicSortFilter(true);
}

void SwitchableOutputProxyModel::setFilterFlags(Flags flags)
{
	if ( m_flags != flags ){
		m_flags = flags;
		if (flags == FilterGroupsOnly){
			sort(0,Qt::AscendingOrder);
			setSortRole(SwitchableOutputModel::GroupRole);
		}else {
			sort(0,Qt::AscendingOrder);
			setSortRole(SwitchableOutputModel::NameRole);
		}
		emit filterFlagsChanged();
		invalidateFilter();
	}
}

void SwitchableOutputProxyModel::setGroup(QString group){
	if (m_group != group){
		m_group = group;
		emit groupChanged();
		invalidateFilter();
	}
}

bool SwitchableOutputProxyModel::filterAcceptsRow(int source_row,
								  const QModelIndex &source_parent) const{

	 QModelIndex sourceIndex = sourceModel()->index(source_row, 0, source_parent);
	 QString group = sourceModel()->data(sourceIndex,SwitchableOutputModel::GroupRole).toString();

	 if (m_flags == FilterGroupsOnly) {
		 for (int i = 0; i < rowCount(); ++i) {
			 if (data(index(i, 0), SwitchableOutputModel::GroupRole).toString() == group) {
				 return false;
			 }
		 }
		 return true;
	 }
	 if (m_flags == FilterByGroup) {
		return group == m_group;
	 }
	 return true;
}

/*----------------- SwitchableOutputModel ----------------------------------------*/

SwitchableOutputModel::SwitchableOutputModel(QObject *parent)
	: QAbstractListModel(parent)
{
}

int SwitchableOutputModel::count() const
{
	return m_tableData.count();
}

void SwitchableOutputModel::addSwitchableOutput(const QString &serviceUid, const QVariantMap &values)
{
	SwitchableOutput inputRec = {
		.serviceUid = serviceUid,
		.group = values["group"].toString(),
		.name = values["name"].toString(),
		.switchType = values["switchType"].toInt(),
		.refId = values["refId"].toInt(),
	};

	// Add the input in a sorted order, based on the name and group.
	int index = count();
	beginInsertRows(QModelIndex(), index, index);
	m_tableData.insert(index, inputRec);
	endInsertRows();
	emit countChanged();
}

bool SwitchableOutputModel::setSwitchableOutput(const QString &serviceUid, const QVariantMap &values)
{
	 const int index = indexOf(serviceUid);
	 if (index < 0) return false;

	 SwitchableOutput inputRec = {
		.serviceUid = serviceUid,
		.group = values["group"].toString(),
		.name = values["name"].toString(),
		.switchType = values["switchType"].toInt(),
		.refId = values["refId"].toInt(),

	};
	beginInsertRows(QModelIndex(), index, index);
	m_tableData.insert(index, inputRec);
	endInsertRows();
	emit countChanged();
	return true;
}

bool SwitchableOutputModel::setSwitchableOutputValue(const QString &serviceUid, Role role, const QVariant &value )
{

	const int index = indexOf(serviceUid);
	if (index < 0) {
		return false;
	}
	beginInsertRows(QModelIndex(), index, index);
	SwitchableOutput &currentData = m_tableData[index];
	switch (role)
	{
	case ServiceUidRole:
		qWarning() << "serviceUid is read-only";
		break;
	case GroupRole:
		currentData.group = value.toString();
		emit dataChanged(createIndex(index, 0), createIndex(index, 0), { GroupRole });
		break;
	case NameRole:
		currentData.name = value.toString();
		emit dataChanged(createIndex(index, 0), createIndex(index, 0), { NameRole });
		break;
	case SwitchTypeRole:
		currentData.switchType = value.toInt();
		emit dataChanged(createIndex(index, 0), createIndex(index, 0), { SwitchTypeRole });
		break;
	case RefIdRole:
		currentData.refId = value.toInt();
		emit dataChanged(createIndex(index, 0), createIndex(index, 0), { RefIdRole });
		break;

	default:
		break;
	}
	endInsertRows();
	return true;
}

int SwitchableOutputModel::indexOf(const QString &serviceUid) const
{
	for (int i = 0; i < m_tableData.count(); ++i) {
		const SwitchableOutput &currentData = m_tableData.at(i);
		if (currentData.serviceUid == serviceUid) {
			return i;
		}
	}
	return -1;
}

void SwitchableOutputModel::remove(const QString &serviceUid){
	removeAt(indexOf(serviceUid));
}
void SwitchableOutputModel::removeAt(int index)
{
	if (index >= 0 && index < count()) {
		beginRemoveRows(QModelIndex(), index, index);
		m_tableData.removeAt(index);
		endRemoveRows();
		emit countChanged();
	}
}

QVariant SwitchableOutputModel::data(const QModelIndex &index, int role) const
{
	const int row = index.row();
	if (row < 0 || row >= m_tableData.count()) {
		return QVariant();
	}

	const SwitchableOutput &currentData = m_tableData.at(row);
	switch (role)
	{
	case ServiceUidRole:
		return currentData.serviceUid;
	case GroupRole:
		return currentData.group;
	case NameRole:
		return currentData.name;
	case SwitchTypeRole:
		return currentData.switchType;

	default:
		return QVariant();
	}
}

int SwitchableOutputModel::rowCount(const QModelIndex &) const
{
	return count();
}

QHash<int, QByteArray> SwitchableOutputModel::roleNames() const
{
	static QHash<int, QByteArray> roles = {
		{ ServiceUidRole, "uid" },
		{ GroupRole, "group" },
		{ NameRole, "name" },
		{ SwitchTypeRole, "switchType" },
		{ RefIdRole, "refId" },

	};
	return roles;
}
