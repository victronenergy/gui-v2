/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "units.h"

#include <veutil/qt/unit_conversion.hpp>

namespace {

Unit::Type unitToVeUnit(Victron::VenusOS::Enums::Units_Type unit)
{
	switch (unit) {
	case Victron::VenusOS::Enums::Units_Volume_CubicMeter:
		return Unit::CubicMeter;
	case Victron::VenusOS::Enums::Units_Volume_Liter:
		return Unit::Litre;
	case Victron::VenusOS::Enums::Units_Volume_GallonUS:
		return Unit::UsGallon;
	case Victron::VenusOS::Enums::Units_Volume_GallonImperial:
		return Unit::ImperialGallon;
	case Victron::VenusOS::Enums::Units_Temperature_Kelvin:
		return Unit::Kelvin;
	case Victron::VenusOS::Enums::Units_Temperature_Celsius:
		return Unit::Celsius;
	case Victron::VenusOS::Enums::Units_Temperature_Fahrenheit:
		return Unit::Fahrenheit;
	default:
		return Unit::Default;
	}
}

}

namespace Victron {
namespace Units {

QObject* Units::instance(QQmlEngine *, QJSEngine *)
{
	return new Units;
}

Units::Units(QObject *parent)
	: QObject(parent)
{
}

Units::~Units()
{
}

int Units::defaultUnitPrecision(Victron::VenusOS::Enums::Units_Type unit) const
{
	switch (unit) {
	case Victron::VenusOS::Enums::Units_Energy_KiloWattHour: return 2;
	case Victron::VenusOS::Enums::Units_Volume_CubicMeter: return 3;
	case Victron::VenusOS::Enums::Units_Volume_Liter:           // fall through
	case Victron::VenusOS::Enums::Units_Volume_GallonImperial:  // fall through
	case Victron::VenusOS::Enums::Units_Volume_GallonUS:        // fall through
	case Victron::VenusOS::Enums::Units_Percentage:             // fall through
	case Victron::VenusOS::Enums::Units_Watt:                   // fall through
	case Victron::VenusOS::Enums::Units_WattsPerSquareMeter:    // fall through
	case Victron::VenusOS::Enums::Units_Temperature_Celsius:    // fall through
	case Victron::VenusOS::Enums::Units_Temperature_Fahrenheit: // fall through
	case Victron::VenusOS::Enums::Units_Temperature_Kelvin:     // fall through
	case Victron::VenusOS::Enums::Units_RevolutionsPerMinute: return 0;
	default:
		// Volt
		// VoltAmpere
		// Amp
		// Hertz
		// AmpHour
		return 1;
	}
}

QString Units::defaultUnitString(Victron::VenusOS::Enums::Units_Type unit) const
{
	switch (unit) {
	case Victron::VenusOS::Enums::Units_Watt:
		return QStringLiteral("W");
	case Victron::VenusOS::Enums::Units_Volt:
		return QStringLiteral("V");
	case Victron::VenusOS::Enums::Units_VoltAmpere:
		return QStringLiteral("VA");
	case Victron::VenusOS::Enums::Units_Amp:
		return QStringLiteral("A");
	case Victron::VenusOS::Enums::Units_Hertz:
		return QStringLiteral("Hz");
	case Victron::VenusOS::Enums::Units_Energy_KiloWattHour:
		return QStringLiteral("kWh");
	case Victron::VenusOS::Enums::Units_AmpHour:
		return QStringLiteral("Ah");
	case Victron::VenusOS::Enums::Units_WattsPerSquareMeter:
		return QStringLiteral("W/m2");
	case Victron::VenusOS::Enums::Units_Percentage:
		return QStringLiteral("%");
	case Victron::VenusOS::Enums::Units_Temperature_Celsius:    // fall through
	case Victron::VenusOS::Enums::Units_Temperature_Fahrenheit: // fall through
	case Victron::VenusOS::Enums::Units_Temperature_Kelvin:
		// \u00b0 = degrees symbol
		return  QStringLiteral("\u00b0");
	case Victron::VenusOS::Enums::Units_Volume_Liter:
		// \u2113 = l, \u3398 = kl
		return QStringLiteral("\u2113");
	case Victron::VenusOS::Enums::Units_Volume_CubicMeter:
		// \u33A5 is not supported by the font, so use two characters \u006D\u00B3 instead.
		return QStringLiteral("m³");
	case Victron::VenusOS::Enums::Units_Volume_GallonUS: // fall through
	case Victron::VenusOS::Enums::Units_Volume_GallonImperial:
		return QStringLiteral("gal");
	case Victron::VenusOS::Enums::Units_RevolutionsPerMinute:
		return QStringLiteral("RPM");
	case Victron::VenusOS::Enums::Units_Speed_MetresPerSecond:
		return QStringLiteral("m/s");
	default:
		qWarning() << "No unit label known for unit:" << unit;
		return QString();
	}
}

QString Units::scaledUnitString(Victron::VenusOS::Enums::Units_Type unit) const
{
	switch (unit) {
	case Victron::VenusOS::Enums::Units_Watt:
		return QStringLiteral("kW");
	case Victron::VenusOS::Enums::Units_Volt:
		return QStringLiteral("kV");
	case Victron::VenusOS::Enums::Units_VoltAmpere:
		return QStringLiteral("kVA");
	case Victron::VenusOS::Enums::Units_Amp:
		return QStringLiteral("kA");
	case Victron::VenusOS::Enums::Units_Hertz:
		return QStringLiteral("kHz");
	case Victron::VenusOS::Enums::Units_Volume_Liter:
		// \u2113 = l, \u3398 = kl
		return QStringLiteral("\u3398");
	default:
		return QString();
	}
}

Victron::Units::quantityInfo Units::scaledQuantity(
	qreal value,
	qreal unitMatchValue,
	int precision,
	const QString &baseUnit,
	const QString &scaledUnit) const
{
	Victron::Units::quantityInfo quantity;
	qreal v = value;
	const qreal scaleMatch = !qIsNaN(unitMatchValue) ? unitMatchValue : value;
	if (!scaledUnit.isEmpty() && (qAbs(scaleMatch) >= 10000)) {
		quantity.unit = scaledUnit;
		v /= 1000.0;
	} else {
		quantity.unit = baseUnit;
	}

	// If value is between -1 and 1, but is not zero, show one decimal precision regardless of
	// precision parameter, to avoid showing just '0'.
	// And if showing percentages, avoid showing '100%' if value is between 99-100.
	if ((precision == 1 && v != 0 && qAbs(v) < 1)
			|| (quantity.unit.compare(QStringLiteral("%")) == 0 && v > 99 && v < 100)) {
		int vFixed = v * 10;
		v = (1.0*vFixed) / 10.0;
		quantity.number = QString::number(v, 'f', 1);
	} else {
		const qreal vFixedMultiplier = std::pow(10, precision);
		int vFixed = v * vFixedMultiplier;
		v = (1.0*vFixed) / vFixedMultiplier;
		quantity.number = QString::number(v, 'f', precision);
	}
	return quantity;
}

// Returns the physical quantity as a tuple of strings: { number, unit }.
// The number is scaled if the absolute value is >= 10,000 (e.g. 10000 W = 10kW)
Victron::Units::quantityInfo Units::getDisplayText(
	Victron::VenusOS::Enums::Units_Type unit,
	qreal value,
	int precision,
	qreal unitMatchValue) const
{
	if (unit == Victron::VenusOS::Enums::Units_None) {
		//qWarning() << "getDisplayText(): unknown unit " << unit << " with value " << value;
		Victron::Units::quantityInfo qty;
		qty.number = QStringLiteral("--");
		return qty;
	}

	if (qIsNaN(value)) {
		Victron::Units::quantityInfo qty;
		qty.number = QStringLiteral("--");
		qty.unit = defaultUnitString(unit);
		return qty;
	}

	const int p = precision < 0 ? defaultUnitPrecision(unit) : precision;
	const QString baseUnit = defaultUnitString(unit);
	const QString scaledUnit = scaledUnitString(unit);
	return scaledQuantity(value, unitMatchValue, p, baseUnit, scaledUnit);
}

QString Units::getCombinedDisplayText(Victron::VenusOS::Enums::Units_Type unit, qreal value, int precision) const
{
	const int p = precision < 0 ? defaultUnitPrecision(unit) : precision;
	const Victron::Units::quantityInfo qty = getDisplayText(unit, value, p);
	if (qty.number.compare(QStringLiteral("--")) == 0) {
		return qty.number;
	}
	return QStringLiteral("%1%2").arg(qty.number, qty.unit);
}

QString Units::getCapacityDisplayText(
	Victron::VenusOS::Enums::Units_Type unit,
	qreal capacity_m3,
	qreal remaining_m3,
	int precision) const
{
	const qreal capacity = convert(capacity_m3, Victron::VenusOS::Enums::Units_Volume_CubicMeter, unit);
	const qreal remaining = convert(remaining_m3, Victron::VenusOS::Enums::Units_Volume_CubicMeter, unit);

	const Victron::Units::quantityInfo c = getDisplayText(unit, capacity, precision);
	const Victron::Units::quantityInfo r = getDisplayText(unit, remaining, precision, capacity);
	return QStringLiteral("%1/%2%3").arg(r.number, c.number, c.unit);
}

qreal Units::convert(qreal value, Victron::VenusOS::Enums::Units_Type fromUnit, Victron::VenusOS::Enums::Units_Type toUnit) const
{
	if (qIsNaN(value)
			|| fromUnit == Victron::VenusOS::Enums::Units_None
			|| toUnit == Victron::VenusOS::Enums::Units_None) {
		return qQNaN();
	}
	if (fromUnit == toUnit) {
		return value;
	}

	Unit::Type fromVeUnit = unitToVeUnit(fromUnit);
	if (fromVeUnit == Unit::Default) {
		qWarning() << "convert() does not support conversion from unit:" << fromUnit;
		return value;
	}
	Unit::Type toVeUnit = unitToVeUnit(toUnit);
	if (toVeUnit == Unit::Default) {
		qWarning() << "convert() does not support conversion to unit:" << toUnit;
		return value;
	}
	return UnitConverters::instance().convert(value, fromVeUnit, toVeUnit);
}

// This considers whether the values are NaN. If both are NaN, the result is NaN.
qreal Units::sumRealNumbers(qreal a, qreal b) const
{
	const bool aNaN = qIsNaN(a);
	const bool bNaN = qIsNaN(b);

	return (aNaN && bNaN) ? qQNaN()
		: aNaN ? b
		: bNaN ? a
		: (a+b);
}

} // Units
} // Victron
