/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "units.h"

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

qreal Units::convertVolumeForUnit(qreal value_m3, Victron::VenusOS::Enums::Units_Type toUnit) const
{
	if (qIsNaN(value_m3)) {
		return qQNaN();
	}

	switch (toUnit) {
	case Victron::VenusOS::Enums::Units_Volume_CubicMeter:
		return value_m3;
	case Victron::VenusOS::Enums::Units_Volume_Liter:
		return value_m3 * 1000;
	case Victron::VenusOS::Enums::Units_Volume_GallonUS:
		return value_m3 * 264.1720523581;
	case Victron::VenusOS::Enums::Units_Volume_GallonImperial:
		return value_m3 * 219.9692483;
	default:
		qWarning() << "convertVolumeForUnit(): cannot convert m3 to unit" << toUnit;
		return value_m3;
	}
}

qreal Units::celsiusToFahrenheit(qreal celsius) const
{
	return qIsNaN(celsius) ? celsius: ((celsius * 9/5) + 32);
}

qreal Units::fromKelvin(qreal value, Victron::VenusOS::Enums::Units_Type toUnit) const
{
	if (toUnit == Victron::VenusOS::Enums::Units_Temperature_Kelvin) {
		return value;
	}
	const qreal celsiusValue = value - 273.15;
	if (toUnit == Victron::VenusOS::Enums::Units_Temperature_Celsius) {
		return celsiusValue;
	}
	if (toUnit == Victron::VenusOS::Enums::Units_Temperature_Fahrenheit) {
		return celsiusToFahrenheit(celsiusValue);
	}

	qWarning() << "Invalid temperature unit:" << toUnit;
	return value;
}

qreal Units::toKelvin(qreal value, Victron::VenusOS::Enums::Units_Type fromUnit) const
{
	if (fromUnit == Victron::VenusOS::Enums::Units_Temperature_Kelvin) {
		return value;
	}
	if (fromUnit == Victron::VenusOS::Enums::Units_Temperature_Celsius) {
		return value + 273.15;
	}
	if (fromUnit == Victron::VenusOS::Enums::Units_Temperature_Fahrenheit) {
		return (value + 459.67) * 5/9;
	}

	qWarning() << "Invalid temperature unit:" << fromUnit;
	return value;
}

qreal Units::convertFromCelsius(qreal celsius, Victron::VenusOS::Enums::Units_Type unit) const
{
	return unit == Victron::VenusOS::Enums::Units_Temperature_Celsius ? celsius
		: unit == Victron::VenusOS::Enums::Units_Temperature_Fahrenheit ? celsiusToFahrenheit(celsius)
		: (celsius + 273.15);
}

Victron::Units::Quantity Units::scaledQuantity(
	qreal value,
	qreal unitMatchValue,
	int precision,
	const QString &baseUnit,
	const QString &scaledUnit) const
{
	Victron::Units::Quantity quantity;
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
		quantity.number = QStringLiteral("%L1").arg(v, 0, 'f', 1);
	} else {
		const qreal vFixedMultiplier = std::pow(10, precision);
		int vFixed = v * vFixedMultiplier;
		v = (1.0*vFixed) / vFixedMultiplier;
		quantity.number = QStringLiteral("%L1").arg(v, 0, 'f', precision);
	}
	return quantity;
}

// Returns the physical quantity as a tuple of strings: { number, unit }.
// The number is scaled if the absolute value is >= 10,000 (e.g. 10000 W = 10kW)
Quantity Units::getDisplayText(
	Victron::VenusOS::Enums::Units_Type unit,
	qreal value,
	int precision,
	qreal unitMatchValue) const
{
	if (unit == Victron::VenusOS::Enums::Units_None) {
		//qWarning() << "getDisplayText(): unknown unit " << unit << " with value " << value;
		Quantity qty;
		qty.number = QStringLiteral("--");
		return qty;
	}

	if (qIsNaN(value)) {
		Quantity qty;
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
	const Quantity qty = getDisplayText(unit, value, p);
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
	const qreal capacity = convertVolumeForUnit(capacity_m3, unit);
	const qreal remaining = convertVolumeForUnit(remaining_m3, unit);
	const Quantity c = getDisplayText(unit, capacity, precision);
	const Quantity r = getDisplayText(unit, remaining, precision, capacity);
	return QStringLiteral("%1/%2%3").arg(r.number, c.number, c.unit);
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
