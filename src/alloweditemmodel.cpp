/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "alloweditemmodel.h"

#include <private/qqmlchangeset_p.h>
#include <QQuickItem>
#include <QQmlInfo>

using namespace Victron::VenusOS;


class AllowedItemModelPrivate : public QObjectPrivate
{
	Q_DECLARE_PUBLIC(AllowedItemModel)
public:
	AllowedItemModelPrivate()
		: QObjectPrivate() {}

	static void sourceModel_append(QQmlListProperty<QObject> *prop, QObject *object) {
		static_cast<AllowedItemModelPrivate *>(prop->data)->append(object);
	}

	static qsizetype sourceModel_count(QQmlListProperty<QObject> *prop) {
		auto d = static_cast<AllowedItemModelPrivate *>(prop->data);
		return d->allObjects.count();
	}

	static QObject *sourceModel_at(QQmlListProperty<QObject> *prop, qsizetype index) {
		auto d = static_cast<AllowedItemModelPrivate *>(prop->data);
		return d->allObjects.value(index);
	}

	static void sourceModel_clear(QQmlListProperty<QObject> *prop) {
		static_cast<AllowedItemModelPrivate *>(prop->data)->clear();
	}

	static void sourceModel_removeLast(QQmlListProperty<QObject> *prop) {
		static_cast<AllowedItemModelPrivate *>(prop->data)->removeLast();
	}

	void append(QObject *object) {
		Q_Q(AllowedItemModel);
		allObjects.append(object);

		if (QQuickItem *item = qobject_cast<QQuickItem *>(object)) {
			const QVariant allowedProperty = item->property("allowed");
			if (allowedProperty.isValid()) {
				QObject::connect(item, SIGNAL(allowedChanged()), q, SLOT(allowedChanged()));
				itemAllowedChanged(item, allowedProperty.toBool());
			}
		}

		emit q->sourceModelChanged();
	}

	void removeLast() {
		Q_Q(AllowedItemModel);
		if (allObjects.count() > 0) {
			QObject *last = allObjects.takeLast();
			last->disconnect(q);
			const int allowedIndex = allowedItems.indexOf(last);
			if (allowedIndex >= 0) {
				QQmlChangeSet changeSet;
				changeSet.remove(allowedIndex, 1);
				allowedItems.removeAt(allowedIndex);
				emit q->modelUpdated(changeSet, false);
				emit q->countChanged();
			}
			emit q->sourceModelChanged();
		}
	}

	void clear() {
		Q_Q(AllowedItemModel);
		if (!allObjects.isEmpty()) {
			for (const QObject *object : allObjects) {
				object->disconnect(q);
			}
			allObjects.clear();
			if (!allowedItems.isEmpty()) {
				QQmlChangeSet changeSet;
				changeSet.remove(0, allowedItems.count());
				allowedItems.clear();
				emit q->modelUpdated(changeSet, false);
				emit q->countChanged();
			}
			emit q->sourceModelChanged();
		}
	}

	void itemAllowedChanged(QQuickItem *item, bool allowed) {
		Q_Q(AllowedItemModel);

		if (allowed) {
			const int insertionIndex = allowedItemsInsertionIndex(item);
			if (insertionIndex >= 0) {
				QQmlChangeSet changeSet;
				changeSet.insert(insertionIndex, 1);
				allowedItems.insert(insertionIndex, item);
				emit q->modelUpdated(changeSet, false);
				emit q->countChanged();
			}
		} else {
			const int removalIndex = allowedItems.indexOf(item);
			if (removalIndex >= 0) {
				QQmlChangeSet changeSet;
				changeSet.remove(removalIndex, 1);
				allowedItems.removeAt(removalIndex);
				emit q->modelUpdated(changeSet, false);
				emit q->countChanged();
			}
		}
	}

	/*
		Returns the index at which an item should be inserted into allowedItems.
		Returns -1 if the index should not be inserted.
	*/
	int allowedItemsInsertionIndex(QQuickItem *item) {
		if (!item || allowedItems.indexOf(item) >= 0) {
			return -1;
		}

		// In the overall list: find the last item that is allowed before this one.
		const int overallIndex = allObjects.indexOf(item);
		if (overallIndex < 0) {
			return -1;
		}
		QObject *prevAllowedItem = nullptr;
		for (int i = overallIndex - 1; i >= 0 && i < allObjects.count(); --i) {
			if (QQuickItem *previousItem = qobject_cast<QQuickItem *>(allObjects.at(i))) {
				if (previousItem->property("allowed").toBool()) {
					prevAllowedItem = previousItem;
					break;
				}
			}
		}

		// In the allowed items list: find the index of that previous allowed item.
		if (prevAllowedItem) {
			const int prevAllowedIndex = allowedItems.indexOf(prevAllowedItem);
			if (prevAllowedIndex >= 0) {
				// Insert the new item after that previous allowed item.
				return prevAllowedIndex + 1;
			}
		}
		// There is no previous allowed item, so this must be the first allowed item.
		return 0;
	}

	QVector<QObject *> allObjects;
	QVector<QObject *> allowedItems;
};

AllowedItemModel::AllowedItemModel(QObject *parent)
	: QQmlInstanceModel(*(new AllowedItemModelPrivate), parent)
{
}

QQmlListProperty<QObject> AllowedItemModel::sourceModel()
{
	Q_D(AllowedItemModel);
	return QQmlListProperty<QObject>(this, d,
									 AllowedItemModelPrivate::sourceModel_append,
									 AllowedItemModelPrivate::sourceModel_count,
									 AllowedItemModelPrivate::sourceModel_at,
									 AllowedItemModelPrivate::sourceModel_clear,
									 nullptr,
									 AllowedItemModelPrivate::sourceModel_removeLast);
}

QObject* AllowedItemModel::get(int index)
{
	return object(index, QQmlIncubator::Synchronous);
}

int AllowedItemModel::count() const
{
	Q_D(const AllowedItemModel);
	return d->allowedItems.count();
}

bool AllowedItemModel::isValid() const
{
	return true;
}

QObject *AllowedItemModel::object(int index, QQmlIncubator::IncubationMode)
{
	Q_D(AllowedItemModel);
	if (index < 0 || index >= d->allowedItems.count()) {
		return nullptr;
	}
	return d->allowedItems.at(index);
}

QQmlInstanceModel::ReleaseFlags AllowedItemModel::release(QObject *, ReusableFlag)
{
	// Always return Referenced flag. Otherwise, when a view sees the item is no longer referenced,
	// it will unparent the item.
	return QQmlInstanceModel::Referenced;
}

QVariant AllowedItemModel::variantValue(int index, const QString &role)
{
	Q_D(AllowedItemModel);
	if (index < 0 || index >= d->allowedItems.count()) {
		return QString();
	}
	return d->allowedItems.at(index)->property(role.toUtf8().constData());
}

QQmlIncubator::Status AllowedItemModel::incubationStatus(int)
{
	// The model does not internally create objects, so any referenced objects are always available.
	return QQmlIncubator::Ready;
}

int AllowedItemModel::indexOf(QObject *item, QObject *context) const
{
	Q_D(const AllowedItemModel);
	for (int i = 0; i < d->allowedItems.count(); ++i) {
		if (d->allowedItems.at(i) == item) {
			return i;
		}
	}
	return -1;
}

void AllowedItemModel::allowedChanged()
{
	Q_D(AllowedItemModel);
	if (QQuickItem *item = qobject_cast<QQuickItem *>(sender())) {
		d->itemAllowedChanged(item, item->property("allowed").toBool());
	}
}
