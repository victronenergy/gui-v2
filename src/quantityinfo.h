/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef QUANTITYINFO_H
#define QUANTITYINFO_H

#include <QObject>
#include <QQmlEngine>
#include <QElapsedTimer>
#include <QQmlPropertyValueSource>
#include <QQmlProperty>
#include "units.h"

namespace Victron {
namespace Units {

class QuantityInfo : public QObject
{
	Q_OBJECT
	QML_ELEMENT

	Q_PROPERTY(QString number READ getNumber NOTIFY updated)
	Q_PROPERTY(QString unit READ getUnit NOTIFY updated)
	Q_PROPERTY(VenusOS::Enums::Units_Scale scale READ getScale NOTIFY updated)

	Q_PROPERTY(qreal value MEMBER value NOTIFY inputChanged)
	Q_PROPERTY(qreal unitMatchValue MEMBER unitMatchValue NOTIFY inputChanged)
	Q_PROPERTY(int precision MEMBER precision NOTIFY inputChanged)
	Q_PROPERTY(Victron::VenusOS::Enums::Units_Type unitType MEMBER unitType NOTIFY inputChanged)

public:
	explicit QuantityInfo(QObject *parent = nullptr);
	~QuantityInfo() override;

	QString getNumber() const { return quantity.number; }
	QString getUnit() const { return quantity.unit; }
	VenusOS::Enums::Units_Scale getScale() const { return quantity.scale; }

signals:
	void updated();
	void inputChanged();
private:
	void update();

	quantityInfo quantity;

	qreal value = qQNaN();
	Victron::VenusOS::Enums::Units_Type unitType;
	int precision = -1;
	qreal unitMatchValue = qQNaN();
	bool completed = false;
};

}
}

#endif // VICTRON_VENUSOS_GUI_V2_UNITS_H
