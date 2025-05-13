/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "units.h"

#include <veutil/qt/unit_conversion.hpp>

#include <QtMath>

namespace {

static const QString DegreesSymbol = QStringLiteral("\u00b0");

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
	case Victron::VenusOS::Enums::Units_Speed_MetresPerSecond:
		return Unit::MetresPerSecond;
	case Victron::VenusOS::Enums::Units_Speed_KilometersPerHour:
		return Unit::KilometersPerHour;
	case Victron::VenusOS::Enums::Units_Speed_MilesPerHour:
		return Unit::MilesPerHour;
	case Victron::VenusOS::Enums::Units_Speed_Knots:
		return Unit::Knots;
	case Victron::VenusOS::Enums::Units_RevolutionsPerMinute:
		return Unit::RevolutionsPerMinute;
	case Victron::VenusOS::Enums::Units_Altitude_Meter:
		return Unit::Meter;
	case Victron::VenusOS::Enums::Units_Altitude_Foot:
		return Unit::Foot;
	default:
		return Unit::Default;
	}
}

const QLocale *formattingLocale()
{
	static const QLocale locale = QLocale::c();
	return &locale;
}

}

namespace Victron {
namespace Units {

QObject* Units::instance(QQmlEngine *, QJSEngine *)
{
	static QObject* units = new Units;
	return units;
}

Units::Units(QObject *parent)
	: QObject(parent)
{
}

Units::~Units()
{
}

QString Units::numberFormattingLocaleName() const
{
	return formattingLocale()->name();
}

QString Units::formatNumber(qreal number, int precision) const
{
	return formattingLocale()->toString(number, 'f', precision);
}

qreal Units::formattedNumberToReal(const QString &s) const
{
	bool ok = false;
	const double d = formattingLocale()->toDouble(s, &ok);
	return ok ? d : qQNaN();
}

int Units::defaultUnitPrecision(VenusOS::Enums::Units_Type unit) const
{
	switch (unit) {
	case VenusOS::Enums::Units_Energy_KiloWattHour:  return 3;
	case VenusOS::Enums::Units_PowerFactor:          return 3;
	case VenusOS::Enums::Units_Volume_CubicMeter:    return 3;
	case VenusOS::Enums::Units_Volt_DC:              return 2;
	case VenusOS::Enums::Units_Volt_AC:                // fall through
	case VenusOS::Enums::Units_Volume_Liter:           // fall through
	case VenusOS::Enums::Units_Volume_GallonImperial:  // fall through
	case VenusOS::Enums::Units_Volume_GallonUS:        // fall through
	case VenusOS::Enums::Units_Percentage:             // fall through
	case VenusOS::Enums::Units_Watt:                   // fall through
	case VenusOS::Enums::Units_WattsPerSquareMeter:    // fall through
	case VenusOS::Enums::Units_Temperature_Celsius:    // fall through
	case VenusOS::Enums::Units_Temperature_Fahrenheit: // fall through
	case VenusOS::Enums::Units_Temperature_Kelvin:     // fall through
	case VenusOS::Enums::Units_RevolutionsPerMinute:   // fall through
	case VenusOS::Enums::Units_CardinalDirection:      // fall through
	case VenusOS::Enums::Units_Time_Day:               // fall through
	case VenusOS::Enums::Units_Time_Hour:              // fall through
	case VenusOS::Enums::Units_Time_Minute:            // fall through
	case VenusOS::Enums::Units_Altitude_Meter:         // fall through
	case VenusOS::Enums::Units_Altitude_Foot:          // fall through
		return 0;
	default:
		// VoltAmpere
		// Amp
		// Hertz
		// AmpHour
		// Hectopascal
		return 1;
	}
}

QString Units::defaultUnitString(VenusOS::Enums::Units_Type unit, int formatHints) const
{
	switch (unit) {
	case VenusOS::Enums::Units_Watt:
		return QStringLiteral("W");
	case VenusOS::Enums::Units_Volt_AC: // fall through
	case VenusOS::Enums::Units_Volt_DC:
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
	case VenusOS::Enums::Units_Temperature_Celsius:
		return (formatHints & CompactUnitFormat) ? DegreesSymbol : DegreesSymbol + QLatin1Char('C');
	case VenusOS::Enums::Units_Temperature_Fahrenheit:
		return (formatHints & CompactUnitFormat) ? DegreesSymbol : DegreesSymbol + QLatin1Char('F');
	case VenusOS::Enums::Units_Temperature_Kelvin:
		return (formatHints & CompactUnitFormat) ? DegreesSymbol : DegreesSymbol + QLatin1Char('K');
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
	case VenusOS::Enums::Units_Speed_KilometersPerHour:
		return QStringLiteral("km/h");
	case VenusOS::Enums::Units_Speed_MilesPerHour:
		return QStringLiteral("mph");
	case VenusOS::Enums::Units_Speed_Knots:
		return QStringLiteral("kn");
	case VenusOS::Enums::Units_Hectopascal:
		return QStringLiteral("hPa");
	case VenusOS::Enums::Units_Kilopascal:
		return QStringLiteral("kPa");
	case VenusOS::Enums::Units_CardinalDirection:
		return DegreesSymbol;
	case VenusOS::Enums::Units_PowerFactor:
		return QString();
	case VenusOS::Enums::Units_Time_Day:
		return QStringLiteral("d");
	case VenusOS::Enums::Units_Time_Hour:
		return QStringLiteral("h");
	case VenusOS::Enums::Units_Time_Minute:
		return QStringLiteral("m");
	case VenusOS::Enums::Units_Altitude_Meter:
		return QStringLiteral("m");
	case VenusOS::Enums::Units_Altitude_Foot:
		return QStringLiteral("ft");
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
	case VenusOS::Enums::Units_Volt_AC:
	case VenusOS::Enums::Units_Volt_DC:
	case VenusOS::Enums::Units_VoltAmpere:
	case VenusOS::Enums::Units_Amp:
	case VenusOS::Enums::Units_Hertz:
	case VenusOS::Enums::Units_Energy_KiloWattHour:
	case VenusOS::Enums::Units_AmpHour:
	case VenusOS::Enums::Units_WattsPerSquareMeter:
	case VenusOS::Enums::Units_RevolutionsPerMinute:
	case VenusOS::Enums::Units_Speed_MetresPerSecond:
	case VenusOS::Enums::Units_Speed_KilometersPerHour:
	case VenusOS::Enums::Units_Speed_MilesPerHour:
	case VenusOS::Enums::Units_Speed_Knots:
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
	case VenusOS::Enums::Units_Kilopascal:
	case VenusOS::Enums::Units_CardinalDirection:
	case VenusOS::Enums::Units_PowerFactor:
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

quantityInfo Units::getDisplayTextWithHysteresis(VenusOS::Enums::Units_Type unit,
	qreal value,
	VenusOS::Enums::Units_Scale previousScale,
	int precision,
	qreal unitMatchValue,
	int formatHints) const
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
		qty.unit = defaultUnitString(unit, formatHints);
		return qty;
	}

	quantityInfo quantity;
	quantity.unit = defaultUnitString(unit, formatHints);
	quantity.scale = VenusOS::Enums::Units_Scale_None;

	// For Watts, floor values with magnitude less than 1.0 W.
	// This ensures we ignore potential noise values.
	if (unit == VenusOS::Enums::Units_Watt && qAbs(value) < 1.0) {
		quantity.number = formattingLocale()->toString(0.0, 'f', 0);
		return quantity;
	}

	// For Percentages with zero precision, if the value is between 99% and 99.9%,
	// always show 99% so that it's clear that it's not completely full.
	if (unit == VenusOS::Enums::Units_Percentage && (precision == 0 || precision == -1) && value > 99) {
		quantity.number = value < 99.9
			? formattingLocale()->toString(99.0, 'f', 0)
			: formattingLocale()->toString(100.0, 'f', 0);
		return quantity;
	}

	if (unit == VenusOS::Enums::Units_CardinalDirection) {
		value = fmod(value + 360, 360);
		quantity.unit += " " + formatWindDirection(static_cast<int>(value));
	}

	qreal scaledValue = value;

	// scale value if the unit of measure is scalable
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
				// \u2113 = litres symbol.
				// we don't use \u3398 (kilolitres symbol)
				// as it isn't available in the required font.
				quantity.unit = QStringLiteral("k\u2113");
				quantity.scale = VenusOS::Enums::Units_Scale_Kilo;
				scaledValue = scaledValue / 1000.0;
			}
		} else {
			for (const auto scale : scales) {
				if (isOverLimit(scaleMatch, scale, previousScale)) {
					quantity.unit = scaleToString(scale) + quantity.unit;
					quantity.scale = scale;
					scaledValue = scaledValue / qPow(10, 3*scale);
					break;
				}
			}

			// If value is zero prefer kWh instead of Wh
			if (scaledValue == 0 && unit == VenusOS::Enums::Units_Energy_KiloWattHour) {
				quantity.unit = defaultUnitString(unit, formatHints);
			}
		}
	}

	auto numberOfDigits = [](int value) -> int {
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

	// If the scaled value is large then possibly clip the precision by 1 or 2 fractional digits depending on initial precision.
	// Only apply this logic to scaled values with 2 non fractional digits if the units are not Units_Volt_DC.
	// i.e. don't clip precision for values like 53.35 V DC.
	precision = precision < 0 ? defaultUnitPrecision(unit) : precision;
	int digits = numberOfDigits(static_cast<int>(scaledValue));
	if (unit != VenusOS::Enums::Units_Volt_DC || digits > 2) {
		if (digits >= 4) {
			precision = 0;
		} else if (digits == 3) {
			precision = precision >= 3 ? 1 : 0;
		} else if (digits == 2) {
			precision = precision >= 3 ? 2
				: precision >= 1 ? 1
				: 0;
		}
	}

	const qreal vFixedMultiplier = std::pow(10, precision);
	int vFixed = qRound(scaledValue * vFixedMultiplier);
	scaledValue = (1.0*vFixed) / vFixedMultiplier;
	quantity.number = formattingLocale()->toString(scaledValue, 'f', precision);

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

qreal Units::sumRealNumbersList(const QList<qreal> &numbers) const
{
	qreal total = 0;
	for (qreal n : numbers) {
		total += (qIsNaN(n) ? 0 : n);
	}
	return total;
}

int Units::unitToVeUnit(VenusOS::Enums::Units_Type unit) const
{
	return static_cast<int>(::unitToVeUnit(unit));
}

QString Units::formatWindDirection(int degrees) const {
	const QString directions[] = {
		//% "N"
		qtTrId("direction_north"),
		//% "NE"
		qtTrId("direction_northeast"),
		//% "E"
		qtTrId("direction_east"),
		//% "SE"
		qtTrId("direction_southeast"),
		//% "S"
		qtTrId("direction_south"),
		//% "SW"
		qtTrId("direction_southwest"),
		//% "W"
		qtTrId("direction_west"),
		//% "NW"
		qtTrId("direction_northwest")
	};
	const int index = static_cast<int>((degrees + 22.5) / 45.0) % 8;
	return directions[index];
}

} // Units
} // Victron
