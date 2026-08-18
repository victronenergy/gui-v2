/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "delegatecomponentmodel.h"

#include <private/qqmlchangeset_p.h>
#include <QQmlContext>
#include <QQmlEngine>
#include <QQmlInfo>
#include <QQuickItem>
#include <veutil/qt/ve_quick_item.hpp>

using namespace Victron::VenusOS;

// --- DelegateComponentModelPrivate ---

class Victron::VenusOS::DelegateComponentModelPrivate : public QObjectPrivate
{
	Q_DECLARE_PUBLIC(DelegateComponentModel)
public:
	struct ObjectInfo {
		QObject *object = nullptr;
		int refCount = 0;
	};

	int visibleIndexOf(DelegateComponent *entry) const
	{
		return visibleEntries.indexOf(entry);
	}

	int visibleInsertionIndex(DelegateComponent *entry) const
	{
		const int overallIndex = allEntries.indexOf(entry);
		if (overallIndex < 0) {
			return -1;
		}
		for (int i = overallIndex - 1; i >= 0; --i) {
			const int visIndex = visibleEntries.indexOf(allEntries.at(i));
			if (visIndex >= 0) {
				return visIndex + 1;
			}
		}
		return 0;
	}

	void destroyObject(DelegateComponent *entry, DelegateComponentModel *model)
	{
		auto it = objects.find(entry);
		if (it != objects.end()) {
			if (it->object) {
				if (QQuickItem *item = qobject_cast<QQuickItem *>(it->object)) {
					const int index = visibleEntries.indexOf(entry);
					emit model->destroyingItem(item);
					Q_UNUSED(index);
				}
				it->object->deleteLater();
			}
			objects.erase(it);
		}
	}

	QVector<DelegateComponent *> allEntries;
	QVector<DelegateComponent *> visibleEntries;
	QHash<DelegateComponent *, ObjectInfo> objects;
};

// --- DelegateComponent ---

DelegateComponent::DelegateComponent(QObject *parent)
	: QObject(parent)
{
}

QQmlComponent *DelegateComponent::delegate() const
{
	return m_delegate;
}

void DelegateComponent::setDelegate(QQmlComponent *delegate)
{
	if (m_delegate != delegate) {
		m_delegate = delegate;
		emit delegateChanged();
	}
}

VeQuickItem *DelegateComponent::dataItem() const
{
	return m_dataItem;
}

void DelegateComponent::setDataItem(VeQuickItem *dataItem)
{
	if (m_dataItem != dataItem) {
		m_dataItem = dataItem;
		emit dataItemChanged();
	}
}

bool DelegateComponent::preferredVisible() const
{
	return m_preferredVisible;
}

void DelegateComponent::setPreferredVisible(bool visible)
{
	if (m_preferredVisible != visible) {
		m_preferredVisible = visible;
		emit preferredVisibleChanged();
	}
}

// --- DelegateComponentModel ---

DelegateComponentModel::DelegateComponentModel(QObject *parent)
	: QQmlInstanceModel(*(new DelegateComponentModelPrivate), parent)
{
}

DelegateComponentModel::~DelegateComponentModel()
{
	Q_D(DelegateComponentModel);
	for (auto it = d->objects.begin(); it != d->objects.end(); ++it) {
		if (it->object) {
			it->object->deleteLater();
		}
	}
}

// --- List property operations ---

void DelegateComponentModel::entries_append(QQmlListProperty<DelegateComponent> *prop, DelegateComponent *entry)
{
	auto *model = static_cast<DelegateComponentModel *>(prop->object);
	auto *d = model->d_func();
	d->allEntries.append(entry);

	QObject::connect(entry, &DelegateComponent::preferredVisibleChanged, model, [model, entry]() {
		model->entryVisibilityChanged(entry);
	});

	if (entry->preferredVisible()) {
		const int insertIndex = d->visibleEntries.count();
		d->visibleEntries.append(entry);
		QQmlChangeSet changeSet;
		changeSet.insert(insertIndex, 1);
		emit model->modelUpdated(changeSet, false);
		emit model->countChanged();
	}

	emit model->entriesChanged();
}

qsizetype DelegateComponentModel::entries_count(QQmlListProperty<DelegateComponent> *prop)
{
	return static_cast<DelegateComponentModel *>(prop->object)->d_func()->allEntries.count();
}

DelegateComponent *DelegateComponentModel::entries_at(QQmlListProperty<DelegateComponent> *prop, qsizetype index)
{
	return static_cast<DelegateComponentModel *>(prop->object)->d_func()->allEntries.value(index);
}

void DelegateComponentModel::entries_clear(QQmlListProperty<DelegateComponent> *prop)
{
	auto *model = static_cast<DelegateComponentModel *>(prop->object);
	auto *d = model->d_func();

	for (DelegateComponent *entry : d->allEntries) {
		entry->disconnect(model);
	}
	d->allEntries.clear();

	if (!d->visibleEntries.isEmpty()) {
		QQmlChangeSet changeSet;
		changeSet.remove(0, d->visibleEntries.count());
		d->visibleEntries.clear();
		emit model->modelUpdated(changeSet, false);
		emit model->countChanged();
	}

	for (auto it = d->objects.begin(); it != d->objects.end(); ++it) {
		if (it->object) {
			if (QQuickItem *item = qobject_cast<QQuickItem *>(it->object)) {
				emit model->destroyingItem(item);
			}
			it->object->deleteLater();
		}
	}
	d->objects.clear();

	emit model->entriesChanged();
}

void DelegateComponentModel::entries_removeLast(QQmlListProperty<DelegateComponent> *prop)
{
	auto *model = static_cast<DelegateComponentModel *>(prop->object);
	auto *d = model->d_func();
	if (d->allEntries.isEmpty()) {
		return;
	}

	DelegateComponent *last = d->allEntries.takeLast();
	last->disconnect(model);

	const int visIndex = d->visibleIndexOf(last);
	if (visIndex >= 0) {
		d->visibleEntries.removeAt(visIndex);
		QQmlChangeSet changeSet;
		changeSet.remove(visIndex, 1);
		emit model->modelUpdated(changeSet, false);
		emit model->countChanged();
	}

	d->destroyObject(last, model);
	emit model->entriesChanged();
}

QQmlListProperty<DelegateComponent> DelegateComponentModel::entries()
{
	return QQmlListProperty<DelegateComponent>(this, nullptr,
		entries_append,
		entries_count,
		entries_at,
		entries_clear,
		nullptr,
		entries_removeLast);
}

// --- QQmlInstanceModel implementation ---

int DelegateComponentModel::count() const
{
	Q_D(const DelegateComponentModel);
	return d->visibleEntries.count();
}

bool DelegateComponentModel::isValid() const
{
	return true;
}

QObject *DelegateComponentModel::object(int index, QQmlIncubator::IncubationMode)
{
	Q_D(DelegateComponentModel);
	if (index < 0 || index >= d->visibleEntries.count()) {
		return nullptr;
	}

	DelegateComponent *entry = d->visibleEntries.at(index);
	auto it = d->objects.find(entry);

	if (it != d->objects.end() && it->object) {
		it->refCount++;
		return it->object;
	}

	QQmlComponent *component = entry->delegate();
	if (!component) {
		qmlWarning(this) << "DelegateComponentModel: entry at index" << index << "has no delegate component";
		return nullptr;
	}

	if (component->status() != QQmlComponent::Ready) {
		qmlWarning(this) << "DelegateComponentModel: delegate component at index" << index
						 << "is not ready:" << component->errorString();
		return nullptr;
	}

	QQmlContext *context = component->creationContext();
	if (!context) {
		context = qmlContext(this);
	}

	QObject *object = component->beginCreate(context);
	if (!object) {
		qmlWarning(this) << "DelegateComponentModel: failed to create object from delegate at index" << index;
		return nullptr;
	}

	QQmlEngine::setObjectOwnership(object, QQmlEngine::CppOwnership);
	component->completeCreate();

	d->objects[entry] = { object, 1 };

	if (QQuickItem *item = qobject_cast<QQuickItem *>(object)) {
		emit initItem(index, item);
		emit createdItem(index, item);
	}

	return object;
}

QQmlInstanceModel::ReleaseFlags DelegateComponentModel::release(QObject *object, ReusableFlag)
{
	Q_D(DelegateComponentModel);
	for (auto it = d->objects.begin(); it != d->objects.end(); ++it) {
		if (it->object == object) {
			if (--it->refCount > 0) {
				return QQmlInstanceModel::Referenced;
			}
			if (QQuickItem *item = qobject_cast<QQuickItem *>(it->object)) {
				emit destroyingItem(item);
			}
			it->object->deleteLater();
			d->objects.erase(it);
			return QQmlInstanceModel::Destroyed;
		}
	}
	return {};
}

QVariant DelegateComponentModel::variantValue(int index, const QString &role)
{
	Q_D(const DelegateComponentModel);
	if (index < 0 || index >= d->visibleEntries.count()) {
		return {};
	}

	auto it = d->objects.constFind(d->visibleEntries.at(index));
	if (it == d->objects.constEnd() || !it->object) {
		return {};
	}
	return it->object->property(role.toUtf8().constData());
}

QQmlIncubator::Status DelegateComponentModel::incubationStatus(int)
{
	return QQmlIncubator::Ready;
}

int DelegateComponentModel::indexOf(QObject *object, QObject *) const
{
	Q_D(const DelegateComponentModel);
	for (auto it = d->objects.constBegin(); it != d->objects.constEnd(); ++it) {
		if (it->object == object) {
			return d->visibleEntries.indexOf(it.key());
		}
	}
	return -1;
}

// --- Visibility filtering ---

void DelegateComponentModel::entryVisibilityChanged(DelegateComponent *entry)
{
	Q_D(DelegateComponentModel);
	if (entry->preferredVisible()) {
		if (d->visibleIndexOf(entry) >= 0) {
			return;
		}
		const int insertIndex = d->visibleInsertionIndex(entry);
		if (insertIndex < 0) {
			return;
		}
		d->visibleEntries.insert(insertIndex, entry);
		QQmlChangeSet changeSet;
		changeSet.insert(insertIndex, 1);
		emit modelUpdated(changeSet, false);
		emit countChanged();
	} else {
		const int removeIndex = d->visibleIndexOf(entry);
		if (removeIndex < 0) {
			return;
		}
		d->visibleEntries.removeAt(removeIndex);
		QQmlChangeSet changeSet;
		changeSet.remove(removeIndex, 1);
		emit modelUpdated(changeSet, false);
		emit countChanged();

		// The ListView will release the object if it held one. If we still have a
		// created object with refCount 0 (should not normally happen), clean it up.
		auto objIt = d->objects.find(entry);
		if (objIt != d->objects.end() && objIt->refCount <= 0) {
			d->destroyObject(entry, this);
		}
	}
}
