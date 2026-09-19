/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "veqitemmockproducer.h"
#include "enums.h"
#include "theme.h"

namespace Victron {

namespace VenusOS {

VeQItemMock::VeQItemMock(VeQItemMockProducer *producer)
	: VeQItem(producer)
	, m_producer(producer)
{
}

int VeQItemMock::setValue(QVariant const &value)
{
	VeQItem::setValue(value);
	m_producer->trackUndefinedUid(this, value);
	produceValue(value);
	return 0;
}

void VeQItemMock::afterAdd()
{
	// The item has just been added to its parent, so it cannot have children yet and isLeaf()
	// still says how it was created: true when it was the last component of the requested uid,
	// false when it was created only to hold a deeper one. Remember that, because a child added
	// later would clear isLeaf().
	m_isRequestedPath = isLeaf();
	VeQItem::afterAdd();
}

VeQItemMockProducer::VeQItemMockProducer(VeQItem *root, const QString &id, QObject *parent)
	: VeQItemProducer(root, id, parent)
{
}

void VeQItemMockProducer::setValue(const QString &uid, const QVariant &value)
{
	if (VeQItemMock *item = qobject_cast<VeQItemMock*>(mProducerRoot->itemGetOrCreate(normalizedUid(uid), true, true))) {
		trackUndefinedUid(item, value);
		item->produceValue(value);
	}
}

QVariant VeQItemMockProducer::value(const QString &uid) const
{
	if (VeQItemMock *item = qobject_cast<VeQItemMock*>(mProducerRoot->itemGet(normalizedUid(uid)))) {
		return item->getValue();
	}
	return QVariant();
}

/*
	Records whether 'item' currently holds a deliberate omission, i.e. an undefined value meaning
	that the mocked device does not publish this path, as opposed to a gap in the mock data.

	This is called for every write to the mock backend, from wherever it comes: a mock
	configuration sets an undefined value with a JSON null, and the application can set one at
	runtime as well, after a configuration was loaded.
*/
void VeQItemMockProducer::trackUndefinedUid(VeQItem *item, const QVariant &value)
{
	if (value.isValid()) {
		m_undefinedUids.remove(item->uniqueId());
	} else {
		m_undefinedUids.insert(item->uniqueId());
	}
}

/*
	Forgets the deliberate-omission markers for 'item' and everything below it.

	The markers are keyed by uid, so without this a uid that was deliberately undefined, then
	deleted, and then recreated by a UI request would still count as a deliberate omission, and
	the resulting gap would be missing from the --mock-coverage report.
*/
void VeQItemMockProducer::forgetUndefinedUids(VeQItem *item)
{
	m_undefinedUids.remove(item->uniqueId());
	item->forAllChildren([this](VeQItem *child) {
		m_undefinedUids.remove(child->uniqueId());
	});
}

void VeQItemMockProducer::removeValue(const QString &uid)
{
	if (VeQItemMock *item = qobject_cast<VeQItemMock*>(mProducerRoot->itemGet(normalizedUid(uid)))) {
		forgetUndefinedUids(item);
		item->itemDelete();
	} else {
		qWarning() << "Value not removed, cannot find uid:" << uid;
	}
}

void VeQItemMockProducer::removeServices(const QString &serviceType)
{
	const QString prefix = QStringLiteral("com.victronenergy.%1.").arg(serviceType);
	const VeQItem::Children children = mProducerRoot->itemChildren();
	QStringList serviceUids;
	for (auto it = children.constBegin(); it != children.constEnd(); ++it) {
		if (it.key().startsWith(prefix)) {
			serviceUids.append(it.key());
		}
	}

	for (const QString &uid : serviceUids) {
		if (VeQItem *item = mProducerRoot->itemGet(uid)) {
			forgetUndefinedUids(item);
			item->itemDelete();
		}
	}
}

void VeQItemMockProducer::dumpValues()
{
	mProducerRoot->forAllChildren([this](VeQItem *item) {
		qInfo() << item->uniqueId() << item->getValue();
	});
}

QStringList VeQItemMockProducer::missingValueUids() const
{
	QStringList uids;
	mProducerRoot->forAllChildren([this, &uids](VeQItem *item) {
		const VeQItemMock *mockItem = qobject_cast<const VeQItemMock *>(item);
		// getLocalValue() rather than getValue(): the latter moves an Idle item to Requested, and a
		// diagnostic must not change the state of what it is measuring.
		if (mockItem && mockItem->isRequestedPath() && !item->getLocalValue().isValid()
				&& !m_undefinedUids.contains(item->uniqueId())) {
			uids.append(item->uniqueId());
		}
	});
	uids.sort();
	return uids;
}

VeQItem *VeQItemMockProducer::createItem()
{
	return new VeQItemMock(this);
}

QString VeQItemMockProducer::normalizedUid(const QString &uid)
{
	return uid.startsWith("mock/") ? uid.mid(5) : uid;
}


} /* VenusOS */

} /* Victron */
