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

bool VeQItemMockProducer::hasValues() const
{
	return !m_values.isEmpty();
}

void VeQItemMockProducer::setValue(const QString &uid, const QVariant &value)
{
	const QString normalizedUid = this->normalizedUid(uid);
	m_values.insert(normalizedUid, value);

	VeQItemMock *item = qobject_cast<VeQItemMock*>(mProducerRoot->itemGetOrCreate(normalizedUid, true, true));
	item->produceValue(value);
}

QVariant VeQItemMockProducer::value(const QString &uid) const
{
	return m_values.value(normalizedUid(uid));
}

void VeQItemMockProducer::removeValue(const QString &uid)
{
	if (m_values.remove(uid)) {
		if (VeQItemMock *item = qobject_cast<VeQItemMock*>(mProducerRoot->itemGet(uid))) {
			item->itemDelete();
		}
		if (m_values.isEmpty()) {
			Q_EMIT hasValuesChanged();
		}
	}
}

void VeQItemMockProducer::removeAllValues()
{
	if (m_values.isEmpty()) {
		return;
	}

	for (auto it = m_values.constBegin(); it != m_values.constEnd(); ++it) {
		if (VeQItemMock *item = qobject_cast<VeQItemMock*>(mProducerRoot->itemGet(it.key()))) {
			item->itemDelete();
		}
	}
	m_values.clear();
	Q_EMIT hasValuesChanged();
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

