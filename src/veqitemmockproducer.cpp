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

void VeQItemMockProducer::initialize()
{
	// Initialize mock values that should be present before the app is started.

	const QString systemSettingUid = QStringLiteral("com.victronenergy.settings/Settings/System/%1");
	const QString guiSettingUid = QStringLiteral("com.victronenergy.settings/Settings/Gui/%1");

	setValue(systemSettingUid.arg("AccessLevel"), Enums::User_AccessType_Service);
	setValue(systemSettingUid.arg("VolumeUnit"), Enums::Units_Volume_Liter);
	setValue(systemSettingUid.arg("Units/Temperature"), QStringLiteral("celsius"));

	setValue(guiSettingUid.arg("ColorScheme"), Theme::Light);
	setValue(guiSettingUid.arg("ElectricalPowerIndicator"), 0); // 0 = watts, 1 = amps
	setValue(guiSettingUid.arg("BriefView/ShowPercentages"), 1);

	static const QMap<int, QVariant> defaultLevels = {
		{ 0, Enums::Tank_Type_Battery },
		{ 1, Enums::Tank_Type_Fuel },
		{ 2, Enums::Tank_Type_FreshWater },
		{ 3, Enums::Tank_Type_BlackWater },
	};
	for (int i = 0; i < 4; ++i) {
		const QString uid = guiSettingUid.arg("BriefView/Level/%1").arg(QString::number(i));
		setValue(uid, defaultLevels[i]);
	}
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

