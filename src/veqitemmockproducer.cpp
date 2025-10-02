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
	produceValue(value);
	return 0;
}

VeQItemMockProducer::VeQItemMockProducer(VeQItem *root, const QString &id, QObject *parent)
	: VeQItemProducer(root, id, parent)
{
}

void VeQItemMockProducer::setValue(const QString &uid, const QVariant &value)
{
	if (VeQItemMock *item = qobject_cast<VeQItemMock*>(mProducerRoot->itemGetOrCreate(normalizedUid(uid), true, true))) {
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

void VeQItemMockProducer::removeValue(const QString &uid)
{
	if (VeQItemMock *item = qobject_cast<VeQItemMock*>(mProducerRoot->itemGet(normalizedUid(uid)))) {
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
