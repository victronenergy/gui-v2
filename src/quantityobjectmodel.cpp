/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "quantityobjectmodel.h"

#include <QQmlInfo>

using namespace Victron::VenusOS;

QuantityObjectModel::QuantityObjectModel(QObject *parent)
	: QAbstractListModel(parent)
{
}

int QuantityObjectModel::count() const
{
	return m_validObjects.count();
}

QQmlListProperty<QuantityObject> QuantityObjectModel::objects()
{
	return QQmlListProperty<QuantityObject>(this, this,
								 QuantityObjectModel::objects_append,
								 QuantityObjectModel::objects_count,
								 QuantityObjectModel::objects_at,
								 QuantityObjectModel::objects_clear,
								 nullptr,
								 QuantityObjectModel::objects_removeLast);
}

QuantityObjectModel::FilterType QuantityObjectModel::filterType() const
{
	return m_filterType;
}

void QuantityObjectModel::setFilterType(FilterType filterType)
{
	if (m_filterType != filterType) {
		m_filterType = filterType;

		if (m_allObjects.count()) {
			beginResetModel();
			m_validObjects.clear();
			for (auto object : m_allObjects) {
				if (filterType == NoFilter) {
					m_validObjects.append(object);
				} else {
					checkObjectHasValue(object);
				}
			}
			endResetModel();
			emit countChanged();
		}

		emit filterTypeChanged();
	}
}

QVariant QuantityObjectModel::data(const QModelIndex &index, int role) const
{
	const int row = index.row();
	if (row < 0 || row >= m_validObjects.count()) {
		return QVariant();
	}

	switch (role)
	{
	case QuantityObjectRole:
		return QVariant::fromValue<QuantityObject*>(m_validObjects.at(row));
	}
	return QVariant();
}

int QuantityObjectModel::rowCount(const QModelIndex &) const
{
	return count();
}

QHash<int, QByteArray> QuantityObjectModel::roleNames() const
{
	static QHash<int, QByteArray> roles = {
		{ QuantityObjectRole, "quantityObject" },
	};
	return roles;
}

void QuantityObjectModel::objectHasValueChanged()
{
	if (QuantityObject *object = qobject_cast<QuantityObject*>(sender())) {
		checkObjectHasValue(object);
	}
}

void QuantityObjectModel::checkObjectHasValue(QuantityObject *object)
{
	if (!object) {
		return;
	}

	// If the object is valid, insert it into the valid model, if it is not already present.
	// Otherwise, remove it from the valid model.
	if (object->hasValue() || m_filterType == NoFilter) {
		const int insertionIndex = validObjectsInsertionIndex(object);
		if (insertionIndex >= 0) {
			beginInsertRows(QModelIndex(), insertionIndex, insertionIndex);
			m_validObjects.insert(insertionIndex, object);
			endInsertRows();
			emit countChanged();
		}
	} else {
		const int removalIndex = m_validObjects.indexOf(object);
		if (removalIndex >= 0) {
			beginRemoveRows(QModelIndex(), removalIndex, removalIndex);
			m_validObjects.removeAt(removalIndex);
			endRemoveRows();
			emit countChanged();
		}
	}
}

int QuantityObjectModel::validObjectsInsertionIndex(QuantityObject *object) const
{
	if (!object || m_validObjects.indexOf(object) >= 0) {
		return -1;
	}

	const int overallIndex = m_allObjects.indexOf(object);
	if (overallIndex < 0) {
		return -1;
	}

	// If validity does not matter, then just use the index of the object in the overall list.
	if (m_filterType == NoFilter) {
		return overallIndex;
	}

	// Otherwise, in the overall list: find the last object that is valid before this one.
	QuantityObject *prevValidObject = nullptr;
	for (int i = overallIndex - 1; i >= 0 && i < m_allObjects.count(); --i) {
		QuantityObject *prevObject = m_allObjects.at(i);
		if (prevObject && prevObject->hasValue()) {
			prevValidObject = prevObject;
			break;
		}
	}

	// In the valid objects list: find the index of that previous valid object.
	if (prevValidObject) {
		const int prevValidIndex = m_validObjects.indexOf(prevValidObject);
		if (prevValidIndex >= 0) {
			// Insert the new object after that previous valid object.
			return prevValidIndex + 1;
		}
	}
	// There is no previous valid object, so this must be the first valid object.
	return 0;
}

void QuantityObjectModel::clearValidObjects()
{
	if (m_validObjects.count()) {
		beginResetModel();
		m_validObjects.clear();
		endResetModel();
		emit countChanged();
	}
}

void QuantityObjectModel::objects_append(QQmlListProperty<QuantityObject> *prop, QuantityObject *object)
{
	QuantityObjectModel *model = static_cast<QuantityObjectModel *>(prop->data);

	// Add the object to the list of all objects, and receive signals when the object validity
	// changes so that the list of valid objects can be updated accordingly.
	model->m_allObjects.append(object);
	if (object) {
		QObject::connect(object, &QuantityObject::hasValueChanged, model, &QuantityObjectModel::objectHasValueChanged);
	}
	emit model->objectsChanged();

	// If the object has a valid value, add the object to the list of valid objects.
	model->checkObjectHasValue(object);
}

qsizetype QuantityObjectModel::objects_count(QQmlListProperty<QuantityObject> *prop)
{
	const QuantityObjectModel *model = static_cast<QuantityObjectModel *>(prop->data);
	return model->m_allObjects.count();
}

QuantityObject *QuantityObjectModel::objects_at(QQmlListProperty<QuantityObject> *prop, qsizetype index)
{
	const QuantityObjectModel *model = static_cast<QuantityObjectModel *>(prop->data);
	return model->m_allObjects.at(index);
}

void QuantityObjectModel::objects_clear(QQmlListProperty<QuantityObject> *prop)
{
	QuantityObjectModel *model = static_cast<QuantityObjectModel *>(prop->data);

	// Clear the list of valid objects.
	model->clearValidObjects();

	// Clear the list of all objects.
	while (model->m_allObjects.count()) {
		QObject *object = model->m_allObjects.takeLast();
		if (object) {
			object->disconnect(model);
		}
	}
	emit model->objectsChanged();
}

void QuantityObjectModel::objects_removeLast(QQmlListProperty<QuantityObject> *prop)
{
	QuantityObjectModel *model = static_cast<QuantityObjectModel *>(prop->data);
	if (model->m_allObjects.isEmpty()) {
		return;
	}

	// Remove the object from the list of valid objects.
	const int removalIndex = model->m_validObjects.indexOf(model->m_allObjects.last());
	if (removalIndex >= 0) {
		model->beginRemoveRows(QModelIndex(), removalIndex, removalIndex);
		model->m_validObjects.removeAt(removalIndex);
		model->endRemoveRows();
		emit model->countChanged();
	}

	// Remove the object from the list of all objects.
	QuantityObject *object = model->m_allObjects.takeLast();
	if (object) {
		object->disconnect(model);
	}
	emit model->objectsChanged();
}
