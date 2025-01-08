/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "visibleitemmodel.h"

#include <private/qqmlchangeset_p.h>
#include <QQuickItem>
#include <QQmlInfo>

using namespace Victron::VenusOS;


class VisibleItemModelPrivate : public QObjectPrivate
{
	Q_DECLARE_PUBLIC(VisibleItemModel)
public:
	VisibleItemModelPrivate()
		: QObjectPrivate() {}

	static void sourceModel_append(QQmlListProperty<QQuickItem> *prop, QQuickItem *object) {
		static_cast<VisibleItemModelPrivate *>(prop->data)->append(object);
	}

	static qsizetype sourceModel_count(QQmlListProperty<QQuickItem> *prop) {
		auto d = static_cast<VisibleItemModelPrivate *>(prop->data);
		return d->allItems.count();
	}

	static QQuickItem *sourceModel_at(QQmlListProperty<QQuickItem> *prop, qsizetype index) {
		auto d = static_cast<VisibleItemModelPrivate *>(prop->data);
		return d->allItems.value(index);
	}

	static void sourceModel_clear(QQmlListProperty<QQuickItem> *prop) {
		static_cast<VisibleItemModelPrivate *>(prop->data)->clear();
	}

	static void sourceModel_removeLast(QQmlListProperty<QQuickItem> *prop) {
		static_cast<VisibleItemModelPrivate *>(prop->data)->removeLast();
	}

	void append(QQuickItem *item) {
		Q_Q(VisibleItemModel);
		allItems.append(item);

		const QVariant effectiveVisible = item ? item->property("effectiveVisible") : QVariant();
		if (effectiveVisible.isValid()) {
			QObject::connect(item, SIGNAL(effectiveVisibleChanged()), q, SLOT(effectiveVisibleChanged()));
		}
		// Add the item to the visible item list, if effectiveVisible=true, or if it has no
		// effectiveVisible property and thus should not be filtered out.
		effectiveVisibleChanged(item, !effectiveVisible.isValid() || effectiveVisible.toBool());

		emit q->sourceModelChanged();
	}

	void removeLast() {
		Q_Q(VisibleItemModel);
		if (allItems.count() > 0) {
			QQuickItem *last = allItems.takeLast();
			if (last) {
				last->disconnect(q);
			}
			const int visibleItemIndex = visibleItems.indexOf(last);
			if (visibleItemIndex >= 0) {
				QQmlChangeSet changeSet;
				changeSet.remove(visibleItemIndex, 1);
				visibleItems.removeAt(visibleItemIndex);
				emit q->modelUpdated(changeSet, false);
				emit q->countChanged();
			}
			emit q->sourceModelChanged();
		}
	}

	void clear() {
		Q_Q(VisibleItemModel);
		if (!allItems.isEmpty()) {
			for (const QQuickItem *object : allItems) {
				if (object) {
					object->disconnect(q);
				}
			}
			allItems.clear();
			if (!visibleItems.isEmpty()) {
				QQmlChangeSet changeSet;
				changeSet.remove(0, visibleItems.count());
				visibleItems.clear();
				emit q->modelUpdated(changeSet, false);
				emit q->countChanged();
			}
			emit q->sourceModelChanged();
		}
	}

	void effectiveVisibleChanged(QQuickItem *item, bool effectiveVisible) {
		Q_Q(VisibleItemModel);

		if (effectiveVisible) {
			const int insertionIndex = visibleInsertionIndex(item);
			if (insertionIndex >= 0) {
				QQmlChangeSet changeSet;
				changeSet.insert(insertionIndex, 1);
				visibleItems.insert(insertionIndex, item);
				emit q->modelUpdated(changeSet, false);
				emit q->countChanged();
			}
		} else {
			const int removalIndex = visibleItems.indexOf(item);
			if (removalIndex >= 0) {
				QQmlChangeSet changeSet;
				changeSet.remove(removalIndex, 1);
				visibleItems.removeAt(removalIndex);
				emit q->modelUpdated(changeSet, false);
				emit q->countChanged();
			}
		}
	}

	/*
		Returns the index at which an item should be inserted into visibleItems.
		Returns -1 if the index should not be inserted.
	*/
	int visibleInsertionIndex(QQuickItem *item) {
		if (!item || visibleItems.indexOf(item) >= 0) {
			return -1;
		}

		// In the overall list: find the last item that is visible before this one.
		const int overallIndex = allItems.indexOf(item);
		if (overallIndex < 0) {
			return -1;
		}
		QQuickItem *prevVisibleItem = nullptr;
		for (int i = overallIndex - 1; i >= 0 && i < allItems.count(); --i) {
			QQuickItem *previousItem = allItems.at(i);
			const QVariant effectiveVisible = previousItem ? previousItem->property("effectiveVisible") : QVariant();
			if (!effectiveVisible.isValid() || effectiveVisible.toBool()) {
				prevVisibleItem = previousItem;
				break;
			}
		}

		// In the visible items list: find the index of that previous visible item.
		if (prevVisibleItem) {
			const int prevVisibleIndex = visibleItems.indexOf(prevVisibleItem);
			if (prevVisibleIndex >= 0) {
				// Insert the new item after that previous visible item.
				return prevVisibleIndex + 1;
			}
		}
		// There is no previous visible item, so this must be the first visible item.
		return 0;
	}

	QVector<QPointer<QQuickItem> > allItems;
	QVector<QPointer<QQuickItem> > visibleItems;
};

VisibleItemModel::VisibleItemModel(QObject *parent)
	: QQmlInstanceModel(*(new VisibleItemModelPrivate), parent)
{
}

QQmlListProperty<QQuickItem> VisibleItemModel::sourceModel()
{
	Q_D(VisibleItemModel);
	return QQmlListProperty<QQuickItem>(this, d,
									 VisibleItemModelPrivate::sourceModel_append,
									 VisibleItemModelPrivate::sourceModel_count,
									 VisibleItemModelPrivate::sourceModel_at,
									 VisibleItemModelPrivate::sourceModel_clear,
									 nullptr,
									 VisibleItemModelPrivate::sourceModel_removeLast);
}

QObject* VisibleItemModel::get(int index)
{
	return object(index, QQmlIncubator::Synchronous);
}

int VisibleItemModel::count() const
{
	Q_D(const VisibleItemModel);
	return d->visibleItems.count();
}

bool VisibleItemModel::isValid() const
{
	return true;
}

QObject *VisibleItemModel::object(int index, QQmlIncubator::IncubationMode)
{
	Q_D(VisibleItemModel);
	if (index < 0 || index >= d->visibleItems.count()) {
		return nullptr;
	}
	return d->visibleItems.at(index);
}

QQmlInstanceModel::ReleaseFlags VisibleItemModel::release(QObject *, ReusableFlag)
{
	// Always return Referenced flag. Otherwise, when a view sees the item is no longer referenced,
	// it will unparent the item.
	return QQmlInstanceModel::Referenced;
}

QVariant VisibleItemModel::variantValue(int index, const QString &role)
{
	Q_D(VisibleItemModel);
	if (index < 0 || index >= d->visibleItems.count()) {
		return QVariant();
	}
	const QQuickItem *item = d->visibleItems.at(index);
	return item ? item->property(role.toUtf8().constData()) : QVariant();
}

QQmlIncubator::Status VisibleItemModel::incubationStatus(int)
{
	// The model does not internally create objects, so any referenced objects are always available.
	return QQmlIncubator::Ready;
}

int VisibleItemModel::indexOf(QObject *item, QObject *) const
{
	Q_D(const VisibleItemModel);
	for (int i = 0; i < d->visibleItems.count(); ++i) {
		if (d->visibleItems.at(i) == item) {
			return i;
		}
	}
	return -1;
}

void VisibleItemModel::effectiveVisibleChanged()
{
	Q_D(VisibleItemModel);
	if (QQuickItem *item = qobject_cast<QQuickItem *>(sender())) {
		d->effectiveVisibleChanged(item, item->property("effectiveVisible").toBool());
	}
}
