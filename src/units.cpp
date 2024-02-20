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

int Units::defaultUnitPrecision(VenusOS::Enums::Units_Type unit) const
{
	switch (unit) {
	case VenusOS::Enums::Units_Energy_KiloWattHour: return 3;
	case VenusOS::Enums::Units_Volume_CubicMeter: return 3;
	case VenusOS::Enums::Units_Volume_Liter:           // fall through
	case VenusOS::Enums::Units_Volume_GallonImperial:  // fall through
	case VenusOS::Enums::Units_Volume_GallonUS:        // fall through
	case VenusOS::Enums::Units_Percentage:             // fall through
	case VenusOS::Enums::Units_Watt:                   // fall through
	case VenusOS::Enums::Units_WattsPerSquareMeter:    // fall through
	case VenusOS::Enums::Units_Temperature_Celsius:    // fall through
	case VenusOS::Enums::Units_Temperature_Fahrenheit: // fall through
	case VenusOS::Enums::Units_Temperature_Kelvin:     // fall through
	case VenusOS::Enums::Units_RevolutionsPerMinute: return 0;
	default:
		// Volt
		// VoltAmpere
		// Amp
		// Hertz
		// AmpHour
		// Hectopascal
		return 1;
	}
}

QString Units::defaultUnitString(VenusOS::Enums::Units_Type unit) const
{
	switch (unit) {
	case VenusOS::Enums::Units_Watt:
		return QStringLiteral("W");
	case VenusOS::Enums::Units_Volt:
		return QStringLiteral("V");
	case VenusOS::Enums::Units_VoltAmpere:
		return QStringLiteral("VA");
	case VenusOS::Enums::Units_Amp:
		return QStringLiteral("A");
	case VenusOS::Enums::Units_Hertz:
		return QStringLiteral("Hz");
	case VenusOS::Enums::Units_Energy_KiloWattHour:
		return QStringLiteral("kWh");
	case VenusOS::Enums::Units_AmpHour:
		return QStringLiteral("Ah");
	case VenusOS::Enums::Units_WattsPerSquareMeter:
		return QStringLiteral("W/m2");
	case VenusOS::Enums::Units_Percentage:
		return QStringLiteral("%");
	case VenusOS::Enums::Units_Temperature_Celsius:    // fall through
	case VenusOS::Enums::Units_Temperature_Fahrenheit: // fall through
	case VenusOS::Enums::Units_Temperature_Kelvin:
		// \u00b0 = degrees symbol
		return  QStringLiteral("\u00b0");
	case VenusOS::Enums::Units_Volume_Liter:
		// \u2113 = l, \u3398 = kl
		return QStringLiteral("\u2113");
	case VenusOS::Enums::Units_Volume_CubicMeter:
		// \u33A5 is not supported by the font, so use two characters \u006D\u00B3 instead.
		return QStringLiteral("m³");
	case VenusOS::Enums::Units_Volume_GallonUS: // fall through
	case VenusOS::Enums::Units_Volume_GallonImperial:
		return QStringLiteral("gal");
	case VenusOS::Enums::Units_RevolutionsPerMinute:
		return QStringLiteral("RPM");
	case VenusOS::Enums::Units_Speed_MetresPerSecond:
		return QStringLiteral("m/s");
	case VenusOS::Enums::Units_Hectopascal:
		return QStringLiteral("hPa");
	default:
		qWarning() << "No unit label known for unit:" << unit;
		return QString();
	}
}


QString Units::scaleToString(VenusOS::Enums::Units_Scale scale) const {
	switch (scale) {
	case VenusOS::Enums::Units_Scale_Tera:
		return QStringLiteral("T");
	case VenusOS::Enums::Units_Scale_Giga:
		return QStringLiteral("G");
	case VenusOS::Enums::Units_Scale_Mega:
		return QStringLiteral("M");
	case VenusOS::Enums::Units_Scale_Kilo:
		return QStringLiteral("k");
	case VenusOS::Enums::Units_Scale_None:
	default:
		return QStringLiteral("");
	}
}

bool Units::isScalingSupported(VenusOS::Enums::Units_Type unit) const
{
	switch (unit) {
	case VenusOS::Enums::Units_Watt:
	case VenusOS::Enums::Units_Volt:
	case VenusOS::Enums::Units_VoltAmpere:
	case VenusOS::Enums::Units_Amp:
	case VenusOS::Enums::Units_Hertz:
	case VenusOS::Enums::Units_Energy_KiloWattHour:
	case VenusOS::Enums::Units_AmpHour:
	case VenusOS::Enums::Units_WattsPerSquareMeter:
	case VenusOS::Enums::Units_RevolutionsPerMinute:
	case VenusOS::Enums::Units_Speed_MetresPerSecond:
	case VenusOS::Enums::Units_Volume_CubicMeter:
	case VenusOS::Enums::Units_Volume_Liter:
	case VenusOS::Enums::Units_Volume_GallonUS:
	case VenusOS::Enums::Units_Volume_GallonImperial:
		return true;
	case VenusOS::Enums::Units_Percentage:
	case VenusOS::Enums::Units_Temperature_Celsius:
	case VenusOS::Enums::Units_Temperature_Fahrenheit:
	case VenusOS::Enums::Units_Temperature_Kelvin:
	case VenusOS::Enums::Units_Hectopascal:
	default:
		return false;
	}
}

// Returns the physical quantity as a tuple of strings: { number, unit }.
// The number and unit string are displayed as scaled if the absolute value
// grows high enough (kilo, mega, giga, tera).
quantityInfo Units::getDisplayText(
	VenusOS::Enums::Units_Type unit,
	qreal value,
	int precision,
	qreal unitMatchValue) const
{
	return getDisplayTextWithHysteresis(unit, value, VenusOS::Enums::Units_Scale_None /* skip hysteresis */, precision, unitMatchValue);
}

quantityInfo Units::getDisplayTextWithHysteresis(
	VenusOS::Enums::Units_Type unit,
	qreal value,
		VenusOS::Enums::Units_Scale previousScale,
	int precision,
	qreal unitMatchValue) const
{
	// unit unknown
	if (unit == VenusOS::Enums::Units_None) {
		//qWarning() << "getDisplayText(): unknown unit " << unit << " with value " << value;
		quantityInfo qty;
		qty.number = QStringLiteral("--");
		return qty;
	}

	// value unknown
	if (qIsNaN(value)) {
		quantityInfo qty;
		qty.number = QStringLiteral("--");
		qty.unit = defaultUnitString(unit);
		return qty;
	}
	quantityInfo quantity;
	quantity.unit = defaultUnitString(unit);
	quantity.scale = VenusOS::Enums::Units_Scale_None;

	qreal scaledValue = value;

	// scale value is the unit of measure is scalable
	if (isScalingSupported(unit)) {
		qreal scaleMatch = !qIsNaN(unitMatchValue) ? unitMatchValue : scaledValue;

		// Kilowatthour is already in kilos, normalize to plain watthours before scaling
		if (unit == VenusOS::Enums::Units_Energy_KiloWattHour) {
			quantity.unit = QStringLiteral("Wh");
			scaledValue = 1000.0 * scaledValue;
			scaleMatch = 1000.0 * scaleMatch;
		}

		const QList<VenusOS::Enums::Units_Scale> scales = {
			VenusOS::Enums::Units_Scale_Tera,
			VenusOS::Enums::Units_Scale_Giga,
			VenusOS::Enums::Units_Scale_Mega,
			VenusOS::Enums::Units_Scale_Kilo,
		};

		auto isOverLimit = [](qreal value, VenusOS::Enums::Units_Scale scale, VenusOS::Enums::Units_Scale previousScale) {
			// Implement hysteresis: Move to larger scale unit when value is over 10*scale,
			// but only move back to smaller scale when value drops below 9*scale.
			bool wasPreviousScale = scale == previousScale;

			// Kilo scale has 10k limit, other scales grow by 1k
			qreal multiplier = wasPreviousScale ? 0.9 : 1;
			if (scale == VenusOS::Enums::Units_Scale_Kilo) {
				multiplier = wasPreviousScale ? 9 : 10;
			}

			return qAbs(value) >= multiplier*qPow(10, 3*scale);
		};

		// Litre scaling is special, only kilo range scaling is supported
		if (unit == VenusOS::Enums::Units_Volume_Liter) {
			if (isOverLimit(scaleMatch, VenusOS::Enums::Units_Scale_Kilo, previousScale)) {
				// \u2113 = l, \u3398 = kl
				quantity.unit = QStringLiteral("\u3398");
				quantity.scale = VenusOS::Enums::Units_Scale_Kilo;
				scaledValue = scaledValue / 1000.0;
			}
		} else {
			bool scaled = false;
			for (const auto scale : scales) {
				if (isOverLimit(scaleMatch, scale, previousScale)) {
					quantity.unit = scaleToString(scale) + quantity.unit;
					quantity.scale = scale;
					scaledValue = scaledValue / qPow(10, 3*scale);
					scaled = true;
					break;
				}
			}

			// If value is zero prefer kWh instead of Wh
			if (scaledValue == 0 && unit == VenusOS::Enums::Units_Energy_KiloWattHour) {
				quantity.unit = defaultUnitString(unit);
			}
		}
	}

	auto numberOfDigits = [](int value) {
		int digits = 0;
		while (value) {
			value /= 10;
			digits++;
		}
		return digits;
	};

	// If kilowatt-hours have not been scaled avoid decimals
	if (quantity.scale == VenusOS::Enums::Units_Scale_None && unit == VenusOS::Enums::Units_Energy_KiloWattHour) {
		precision = 0;
	}

	// If value is between -1 and 1, but is not zero, show one decimal precision regardless of
	// precision parameter, to avoid showing just '0'.
	// And if showing percentages, avoid showing '100%' if value is between 99-100.
	precision = precision < 0 ? defaultUnitPrecision(unit) : precision;
	if (precision < 2 && (scaledValue != 0 && qAbs(scaledValue) < 1)
			|| (quantity.unit.compare(QStringLiteral("%")) == 0 && scaledValue > 99 && scaledValue < 100)) {

		int vFixed = qRound(scaledValue * 10);
		scaledValue = (1.0*vFixed) / 10.0;
		quantity.number = QString::number(scaledValue, 'f', 1);
	} else {
		// if the value is large (hundreds or thousands) no need to display decimals after the decimal point
		int digits = numberOfDigits(scaledValue);
		precision = qMax(0, precision - qMax(0, digits - (precision == 1 ? 2 : 1)));

		const qreal vFixedMultiplier = std::pow(10, precision);
		int vFixed = qRound(scaledValue * vFixedMultiplier);
		scaledValue = (1.0*vFixed) / vFixedMultiplier;

		quantity.number = QString::number(scaledValue, 'f', precision);

	}
	return quantity;
}

QString Units::getCombinedDisplayText(VenusOS::Enums::Units_Type unit, qreal value, int precision) const
{
	const int p = precision < 0 ? defaultUnitPrecision(unit) : precision;
	const quantityInfo qty = getDisplayText(unit, value, p);
	if (qty.number.compare(QStringLiteral("--")) == 0) {
		return qty.number;
	}
	return QStringLiteral("%1%2").arg(qty.number, qty.unit);
}

QString Units::getCapacityDisplayText(
	VenusOS::Enums::Units_Type unit,
	qreal capacity_m3,
	qreal remaining_m3) const
{
	const qreal capacity = convert(capacity_m3, VenusOS::Enums::Units_Volume_CubicMeter, unit);
	const qreal remaining = convert(remaining_m3, VenusOS::Enums::Units_Volume_CubicMeter, unit);

	const int precision = defaultUnitPrecision(unit);
	const quantityInfo c = getDisplayText(unit, capacity, precision);
	const quantityInfo r = getDisplayText(unit, remaining, precision, capacity);
	return QStringLiteral("%1/%2%3").arg(r.number, c.number, c.unit);
}

qreal Units::convert(qreal value, VenusOS::Enums::Units_Type fromUnit, VenusOS::Enums::Units_Type toUnit) const
{
	if (qIsNaN(value)
			|| fromUnit == VenusOS::Enums::Units_None
			|| toUnit == VenusOS::Enums::Units_None) {
		return qQNaN();
	}
	if (fromUnit == toUnit) {
		return value;
	}

	Unit::Type fromVeUnit = ::unitToVeUnit(fromUnit);
	if (fromVeUnit == Unit::Default) {
		qWarning() << "convert() does not support conversion from unit:" << fromUnit;
		return value;
	}
	Unit::Type toVeUnit = ::unitToVeUnit(toUnit);
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

int Units::unitToVeUnit(VenusOS::Enums::Units_Type unit) const
{
	return static_cast<int>(::unitToVeUnit(unit));
}

} // Units
} // Victron
