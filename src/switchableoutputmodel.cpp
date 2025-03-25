/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "switchableoutputmodel.h"

using namespace Victron::VenusOS;

#define GROUP_ROLE_TEXT "group"

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

SwitchableOutputModel::SwitchableOutputModel(QString group, QObject *parent)
	: QAbstractListModel(parent), m_group(group)
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
		.name = values["name"].toString(),
		.switchType = values["switchType"].toInt(),
		.refId = values["refId"].toInt(),
	};
	// Add the input in a sorted order, based on the name and group.
	int index = insertionIndex(inputRec.name);
	beginInsertRows(QModelIndex(), index, index);
	m_tableData.insert(index, inputRec);
	endInsertRows();
	emit countChanged();
}

int SwitchableOutputModel::insertionIndex(const QString &name) const
{
	for (int i = 0; i < m_tableData.count(); ++i) {
		if (m_tableData.at(i).name.localeAwareCompare(name) > 0) {
			return i;
		}
	}
	return m_tableData.count();
}

void SwitchableOutputModel::setGroup(QString group)
{
	m_group = group;
	emit dataChanged(createIndex(0, 0), createIndex(m_tableData.count(), 0), { GroupRole });
}

bool SwitchableOutputModel::setSwitchableOutput(const QString &serviceUid, const QVariantMap &values)
{

	const int index = indexOf(serviceUid);
	if (index < 0) {
		return false;
	}
	return setSwitchableOutput(index,values);
}

bool SwitchableOutputModel::setSwitchableOutput(const int itemIndex, const QVariantMap & values)
{
	SwitchableOutput &currentData = m_tableData[itemIndex];
	int returnIndex  = -1;

	if (values["group"].toString() != m_group) return false;

	currentData.switchType = values["switchtype"].toInt();
	currentData.refId = values["refId"].toInt();

	if (currentData.name != values["name"].toString()){
		currentData.name = values["name"].toString();
		removeAt(itemIndex);
		beginInsertRows(QModelIndex(), returnIndex, returnIndex);
		m_tableData.insert(returnIndex, currentData);
		endInsertRows();
		emit countChanged();
	} else {
		emit dataChanged(createIndex(itemIndex, 0), createIndex(itemIndex, 0), {NameRole, SwitchTypeRole, RefIdRole});
	}
	return true;
}


bool SwitchableOutputModel::setSwitchableOutputValue(const QString & serviceUid, Role role, const QVariant & value)
{

	int index = indexOf(serviceUid);
	if (index < 0) {
		return false;
	}
	SwitchableOutput currentData = m_tableData[index];
	switch (role)
	{
	case ServiceUidRole:
		qWarning() << "serviceUid is read-only";
		break;
	case NameRole:
		removeAt(index);
		currentData.name = value.toString();
		index = insertionIndex(currentData.name);
		beginInsertRows(QModelIndex(),index,index);
		m_tableData.insert(index,currentData);
		endInsertRows();
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
	return true;
}

int SwitchableOutputModel::indexOf(const QString &serviceUid) const
{
	for (int i = 0; i < m_tableData.count();i++) {
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
		return m_group;
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
	return m_tableData.count();
}

QHash<int, QByteArray> SwitchableOutputModel::roleNames() const
{
	static QHash<int, QByteArray> roles = {
		{ ServiceUidRole, "uid" },
		{ GroupRole, GROUP_ROLE_TEXT },
		{ NameRole, "name" },
		{ SwitchTypeRole, "switchType" },
		{ RefIdRole, "refId" },

	};
	return roles;
}


/*!
* @brief moves a low level record between list
 *
 * Moves a low level record between lists. Item inserted in destinationModel at the location aware
 * alphanumerical ordered location. Routine intended for use only by parent card model.
 *
 * @param sourceIndex	index of item to be removed from this list
 * @param destinationModel reference to model in which the remove item should be inserted
 */

int SwitchableOutputModel::moveLists(int sourceIndex,SwitchableOutputModel &destinationModel)
{
	SwitchableOutput item = m_tableData.at(sourceIndex);
	int index = destinationModel.insertionIndex(item.name);
	removeAt(sourceIndex);
	destinationModel.beginInsertRows(QModelIndex(),index,index);
	destinationModel.m_tableData.insert(index, item);
	destinationModel.endInsertRows();
	return index;
}


/*------------------ SwitchableOutputCardModel ----------------------------------------*/

SwitchableOutputCardModel::SwitchableOutputCardModel(QObject *parent)
	: QAbstractListModel(parent)
{
}
int SwitchableOutputCardModel::insertionIndex(const QString &group) const
{
	for (int i = 0; i < m_itemModels.count(); ++i) {
		if (m_itemModels.at(i)->m_group.localeAwareCompare(group) > 0) {
			return i;
		}
	}
	return m_itemModels.count();
}

int SwitchableOutputCardModel::indexOf(const QString &serviceUid,int &itemIndex) const
{
	for (int i = 0; i < m_itemModels.count(); ++i) {
		int index = m_itemModels.at(i)->indexOf(serviceUid);
		if (index >= 0){
			itemIndex = index;
			return i;
		}
	}
	return -1;
}

int SwitchableOutputCardModel::indexOfGroup(const QString &group) const
{
	for (int i = 0; i < m_itemModels.count(); ++i) {
		if (m_itemModels.at(i)->group() == group){
			return i;
		}
	}
	return -1;
}

int SwitchableOutputCardModel::addGroup(QString &group){
	int index = insertionIndex(group);
	addGroupAt(group,index);
	return index;
}

void SwitchableOutputCardModel::addGroupAt(QString group, int index){
	beginInsertRows(QModelIndex(), index, index);
	m_itemModels.insert(index,new SwitchableOutputModel(group, this));
	endInsertRows();
	emit countChanged();
}

void SwitchableOutputCardModel::addSwitchableOutput(const QString &serviceUid, const QVariantMap &values)
{
	int i;
	QString group =  values[GROUP_ROLE_TEXT].toString();
	for ( i = 0; i < m_itemModels.count(); ++i) {
		int compResult = m_itemModels.at(i)->group().localeAwareCompare(group);
		if (compResult == 0) {
			//add in group
			m_itemModels.at(i)->addSwitchableOutput(serviceUid, values);
			return;
		}else if (compResult >= 0) {
			//create new
			break;
		}
	}
	addGroupAt(group, i);
	m_itemModels.at(i)->addSwitchableOutput(serviceUid, values);
}


bool SwitchableOutputCardModel::setSwitchableOutput(const QString &serviceUid, const QVariantMap &values)
{

	//Change to get group from rec
	int sourceItemIndex;
	int sourceGroupIndex = indexOf(serviceUid,sourceItemIndex);
	if (sourceGroupIndex<0) return false;
	QString valueGroup =  values[GROUP_ROLE_TEXT].toString();

	if (valueGroup != m_itemModels.at(sourceGroupIndex)->group()){
		int destGroupIndex;
		m_itemModels.at(sourceGroupIndex)->removeAt(sourceItemIndex);
		//find new group
		destGroupIndex = indexOfGroup(valueGroup);
		if (destGroupIndex < 0) destGroupIndex = addGroup(valueGroup); //new group
		m_itemModels.at(destGroupIndex)->addSwitchableOutput(serviceUid, values);
		if (m_itemModels.at(sourceGroupIndex)->count()==0) {
			removeGroup(sourceGroupIndex);
		}
		return true;
	}else {
		return m_itemModels.at(sourceGroupIndex)->setSwitchableOutput(serviceUid, values);
	}
}

void SwitchableOutputCardModel::setSwitchableOutputValue(const QString &serviceUid, SwitchableOutputModel::Role role, const QVariant &value)
{
	QString valueGroup = value.toString();
	if (role == SwitchableOutputModel::GroupRole){
		SwitchableOutputModel* sourceModel = NULL;
		SwitchableOutputModel* destModel = NULL;
		int sourceItemIndex;
		int itemIndex;
		int indexSourceModel = -1;
		int indexDestModel = indexOfGroup (valueGroup);
		if (indexDestModel < 0) indexDestModel = addGroup(valueGroup); //new group
		indexSourceModel = indexOf(serviceUid,sourceItemIndex);  ///find SwitchableOutput in
		sourceModel =  m_itemModels.at(indexSourceModel);  //read source index after add as order may have changed

		// move data between groups
		itemIndex = sourceModel->moveLists(sourceItemIndex,*(m_itemModels.at(indexDestModel)));
		m_itemModels.at(itemIndex)->setSwitchableOutputValue(serviceUid, role, value);
		if (m_itemModels.at(indexSourceModel)->count()==0) {
			removeGroup(indexSourceModel);
		}
	}else {
		int itemIndex;
		int groupIndex = indexOf(serviceUid,itemIndex);
		m_itemModels.at(groupIndex)->setSwitchableOutputValue(serviceUid, role, value);
	}
}
void SwitchableOutputCardModel::removeGroup(int index){
	if (index > m_itemModels.count()) return;
	SwitchableOutputModel* item = m_itemModels.at(index);
	beginRemoveRows(QModelIndex(),index,index);
	m_itemModels.remove(index);
	endRemoveRows();
	//emit countChanged();
	//delete(item);
}

void SwitchableOutputCardModel::remove(const QString &serviceUid){
	int itemIndex;
	int groupIndex = indexOf(serviceUid, itemIndex);
	const QVariantMap deletedRecored;
	if (groupIndex>0){
		m_itemModels.at(groupIndex)->removeAt(itemIndex);
	}
	if (m_itemModels.at(groupIndex)->count()==0) {
		removeGroup(groupIndex);
	}
}
int SwitchableOutputCardModel::rowCount(const QModelIndex &) const
{
	return m_itemModels.count();
}

QVariant SwitchableOutputCardModel::data(const QModelIndex &index, int role = Qt::DisplayRole) const
{
	if (!index.isValid()) return QVariant();
	switch (role)
	{
	case Qt::DisplayRole:
	case GroupRole:
		return m_itemModels.at(index.row())->group();

	case ChildModelRole:
		return QVariant::fromValue<QObject *>(m_itemModels.at(index.row()));
	default:
		return QVariant();
	}

}

QHash<int, QByteArray> SwitchableOutputCardModel::roleNames() const
{
	static QHash<int, QByteArray> roles = {
		{ GroupRole, GROUP_ROLE_TEXT },
		{ ChildModelRole, "childModel" },
	};
	return roles;
}

