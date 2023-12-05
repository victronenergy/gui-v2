/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_VENUSOS_GUI_V2_UNITS_H
#define VICTRON_VENUSOS_GUI_V2_UNITS_H

#include <QtGlobal>
#include <QQmlEngine>
#include <QObject>

#include "enums.h"

namespace Victron {
namespace Units {

class Quantity
{
	Q_GADGET
	Q_PROPERTY(QString number MEMBER number)
	Q_PROPERTY(QString unit MEMBER unit)

public:
	QString number;
	QString unit;
};

class Units : public QObject
{
	Q_OBJECT
	QML_ELEMENT
	QML_SINGLETON

public:
	explicit Units(QObject *parent = nullptr);
	~Units() override;

	static QObject* instance(QQmlEngine *engine, QJSEngine *);

	Q_INVOKABLE int defaultUnitPrecision(Victron::VenusOS::Enums::Units_Type unit) const;
	Q_INVOKABLE QString defaultUnitString(Victron::VenusOS::Enums::Units_Type unit) const;
	Q_INVOKABLE QString scaledUnitString(Victron::VenusOS::Enums::Units_Type unit) const;

	Q_INVOKABLE qreal convertVolumeForUnit(
		qreal value_m3,
		Victron::VenusOS::Enums::Units_Type toUnit) const;

	Q_INVOKABLE qreal celsiusToFahrenheit(qreal celsius) const;
	Q_INVOKABLE qreal fromKelvin(qreal value, Victron::VenusOS::Enums::Units_Type toUnit) const;
	Q_INVOKABLE qreal toKelvin(qreal value, Victron::VenusOS::Enums::Units_Type fromUnit) const;
	Q_INVOKABLE qreal convertFromCelsius(qreal celsius, Victron::VenusOS::Enums::Units_Type unit) const;

	Q_INVOKABLE Victron::Units::Quantity scaledQuantity(
		qreal value,
		qreal unitMatchValue,
		int precision,
		const QString &baseUnit,
		const QString &scaledUnit = QString()) const;

	Q_INVOKABLE Victron::Units::Quantity getDisplayText(
		Victron::VenusOS::Enums::Units_Type unit,
		qreal value,
		int precision = -1,
		qreal unitMatchValue = qQNaN()) const;

	Q_INVOKABLE QString getCombinedDisplayText(
		Victron::VenusOS::Enums::Units_Type unit,
		qreal value) const;

	Q_INVOKABLE QString getCapacityDisplayText(
		Victron::VenusOS::Enums::Units_Type unit,
		qreal capacity_m3,
		qreal remaining_m3,
		int precision) const;

	Q_INVOKABLE qreal sumRealNumbers(qreal a, qreal b) const;
};

}
}

Q_DECLARE_METATYPE(Victron::Units::Quantity)

#endif // VICTRON_VENUSOS_GUI_V2_UNITS_H
