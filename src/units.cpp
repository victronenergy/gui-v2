/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "units.h"
#include "enums.h"

#include <veutil/qt/unit_conversion.hpp>

#include <QtMath>

namespace {

// \u33A5 is not supported by the font
static const QString CubicMetre = QStringLiteral("\u006D\u00B3");
static const QString DegreesSymbol = QStringLiteral("\u00b0");
static const QString LitreSymbol = QStringLiteral("\u2113");

struct UnitMetadata {
	QString label;
	Victron::VenusOS::Enums::Units_Type unit;
	Unit::Type veUnit;
	int precision;
	bool scalable;
};

static const std::vector<UnitMetadata> UnitTable {
	//              label                 unit                                        veUnit               defaultPrec  scalable
	{                  "",   Victron::VenusOS::Enums::Units_None,                     Unit::Default,                0,   false   },
	{                 "m",   Victron::VenusOS::Enums::Units_Altitude_Metre,           Unit::Metre,                  0,   false   },
	{                "ft",   Victron::VenusOS::Enums::Units_Altitude_Foot,            Unit::Foot,                   0,   false   },
	{                 "A",   Victron::VenusOS::Enums::Units_Amp,                      Unit::Default,                1,   true    },
	{                  "",   Victron::VenusOS::Enums::Units_AmpHour,                  Unit::Default,                1,   true    },
	{       DegreesSymbol,   Victron::VenusOS::Enums::Units_CardinalDirection,        Unit::Default,                0,   false   },
	{               "kWh",   Victron::VenusOS::Enums::Units_Energy_KiloWattHour,      Unit::Default,                3,   true    },
	{               "hPa",   Victron::VenusOS::Enums::Units_Hectopascal,              Unit::Default,                1,   false   },
	{                "Hz",   Victron::VenusOS::Enums::Units_Hertz,                    Unit::Default,                1,   true    },
	{               "kPa",   Victron::VenusOS::Enums::Units_Kilopascal,               Unit::Default,                0,   false   },
	{               "lux",   Victron::VenusOS::Enums::Units_Lux,                      Unit::Default,                0,   false   },
	{              "µg/m",   Victron::VenusOS::Enums::Units_MicrogramPerCubicMeter,   Unit::Default,                1,   false   },
	{                "Nm",   Victron::VenusOS::Enums::Units_NewtonMeter,              Unit::Default,                0,   false   },
	{               "ppm",   Victron::VenusOS::Enums::Units_PartsPerMillion,          Unit::Default,                0,   false   },
	{                 "%",   Victron::VenusOS::Enums::Units_Percentage,               Unit::Default,                0,   false   },
	{                  "",   Victron::VenusOS::Enums::Units_PowerFactor,              Unit::Default,                3,   false   },
	{               "RPM",   Victron::VenusOS::Enums::Units_RevolutionsPerMinute,     Unit::RevolutionsPerMinute,   0,   true    },
	{               "k/h",   Victron::VenusOS::Enums::Units_Speed_KilometresPerHour,  Unit::KilometresPerHour,      0,   true    },
	{                "kn",   Victron::VenusOS::Enums::Units_Speed_Knots,              Unit::Knots,                  0,   true    },
	{               "m/s",   Victron::VenusOS::Enums::Units_Speed_MetresPerSecond,    Unit::MetresPerSecond,        0,   true    },
	{               "m/h",   Victron::VenusOS::Enums::Units_Speed_MilesPerHour,       Unit::MilesPerHour,           0,   true    },
	{ DegreesSymbol + "C",   Victron::VenusOS::Enums::Units_Temperature_Celsius,      Unit::Celsius,                0,   false   },
	{ DegreesSymbol + "F",   Victron::VenusOS::Enums::Units_Temperature_Fahrenheit,   Unit::Fahrenheit,             0,   false   },
	{ DegreesSymbol + "K",   Victron::VenusOS::Enums::Units_Temperature_Kelvin,       Unit::Kelvin,                 0,   false   },
	{                 "d",   Victron::VenusOS::Enums::Units_Time_Day,                 Unit::Default,                0,   false   },
	{                 "h",   Victron::VenusOS::Enums::Units_Time_Hour,                Unit::Default,                0,   false   },
	{                 "m",   Victron::VenusOS::Enums::Units_Time_Minute,              Unit::Default,                0,   false   }, 
	{                "VA",   Victron::VenusOS::Enums::Units_VoltAmpere,               Unit::Default,                1,   true    },
	{               "var",   Victron::VenusOS::Enums::Units_VoltAmpereReactive,       Unit::Default,                1,   true    },
	{                 "V",   Victron::VenusOS::Enums::Units_Volt_AC,                  Unit::Default,                1,   true    },
	{                 "V",   Victron::VenusOS::Enums::Units_Volt_DC,                  Unit::Default,                2,   true    },
	{          CubicMetre,   Victron::VenusOS::Enums::Units_Volume_CubicMetre,        Unit::CubicMetre,             3,   true    },
	{               "gal",   Victron::VenusOS::Enums::Units_Volume_GallonImperial,    Unit::ImperialGallon,         0,   true    },
	{               "gal",   Victron::VenusOS::Enums::Units_Volume_GallonUS,          Unit::UsGallon,               0,   true    },
	{         LitreSymbol,   Victron::VenusOS::Enums::Units_Volume_Litre,             Unit::Litre,                  0,   true    },
	{                 "W",   Victron::VenusOS::Enums::Units_Watt,                     Unit::Default,                0,   true    },
	{              "W/m2",   Victron::VenusOS::Enums::Units_WattsPerSquareMetre,      Unit::Default,                0,   true    },
};

Unit::Type unitToVeUnit(Victron::VenusOS::Enums::Units_Type unit)
{
	return UnitTable[unit].veUnit;
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

QString Units::degreesSymbol() const
{
	return DegreesSymbol;
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

QString Units::formatLatitude(qreal latitude, VenusOS::Enums::GpsData_Format format) const
{
	return formatCoordinate(latitude, format,
			latitude >= 0
				? VenusOS::Enums::CardinalDirection_North
				: VenusOS::Enums::CardinalDirection_South);
}

QString Units::formatLongitude(qreal longitude, VenusOS::Enums::GpsData_Format format) const
{
	return formatCoordinate(longitude, format,
			longitude >= 0
				? VenusOS::Enums::CardinalDirection_East
				: VenusOS::Enums::CardinalDirection_West);
}

QString Units::formatCoordinate(qreal decimalDegrees, VenusOS::Enums::GpsData_Format format, VenusOS::Enums::CardinalDirection direction) const
{
	const double degrees = std::abs(decimalDegrees);
	const double minutes = std::fmod(degrees, 1) * 60.0;
	const double seconds = std::fmod(minutes, 1) * 60.0;

	switch (format) {
	case VenusOS::Enums::GpsData_Format_DegreesMinutesSeconds: // e.g. 52° 20' 41.6" N
		return QString("%1%2 %3' %4\" %5")
				.arg(formatNumber(std::floor(degrees)))
				.arg(DegreesSymbol)
				.arg(formatNumber(std::floor(minutes)))
				.arg(formatNumber(seconds, 1))
				.arg(VenusOS::Enums::create()->cardinalDirectionToShortText(direction));
	case VenusOS::Enums::GpsData_Format_DecimalDegrees: // e.g. 52.34489
		return formatNumber(decimalDegrees, 6);
	case VenusOS::Enums::GpsData_Format_DegreesMinutes: // e.g. 52° 20.693 N
		return QString("%1%2 %3 %4")
				.arg(formatNumber(std::floor(degrees)))
				.arg(DegreesSymbol)
				.arg(formatNumber(minutes, 4))
				.arg(VenusOS::Enums::create()->cardinalDirectionToShortText(direction));
	}
	return QString();
}

int Units::defaultUnitPrecision(VenusOS::Enums::Units_Type unit) const
{
	return UnitTable[unit].precision;
}

QString Units::defaultUnitString(VenusOS::Enums::Units_Type unit, int formatHints) const
{
	if (formatHints == Units::FormatHint::CompactUnitFormat) return QString(UnitTable[unit].label).first(1);
	return UnitTable[unit].label;
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
		return QString();
	}
}

bool Units::isScalingSupported(VenusOS::Enums::Units_Type unit) const
{
	return UnitTable[unit].scalable;
}

// Returns the physical quantity as a tuple of strings: { number, unit }.
// The number and unit string are displayed as scaled if the absolute value
// grows high enough (kilo, mega, giga, tera).
quantityInfo Units::getDisplayText(
	VenusOS::Enums::Units_Type unit,
	qreal value,
	int precision,
	bool precisionAdjustmentAllowed,
	qreal unitMatchValue) const
{
	return getDisplayTextWithHysteresis(unit, value, VenusOS::Enums::Units_Scale_None /* skip hysteresis */, precision, precisionAdjustmentAllowed, unitMatchValue);
}

quantityInfo Units::getDisplayTextWithHysteresis(VenusOS::Enums::Units_Type unit,
	qreal value,
	VenusOS::Enums::Units_Scale previousScale,
	int precision,
	bool precisionAdjustmentAllowed,
	qreal unitMatchValue,
	int formatHints) const
{
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

		// For some units, do not scale beyond the kilo range, as we don't want to display them in
		// mega/tera/giga format.
		if (unit == VenusOS::Enums::Units_Volume_Litre
				|| unit == VenusOS::Enums::Units_Altitude_Metre) {
			if (isOverLimit(scaleMatch, VenusOS::Enums::Units_Scale_Kilo, previousScale)) {
				quantity.unit = QStringLiteral("k%1").arg(defaultUnitString(unit));
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
	if (precisionAdjustmentAllowed && quantity.scale == VenusOS::Enums::Units_Scale_None && unit == VenusOS::Enums::Units_Energy_KiloWattHour) {
		precision = 0;
	}

	// If the scaled value is large then possibly clip the precision by 1 or 2 fractional digits depending on initial precision.
	// Only apply this logic to scaled values with 2 non fractional digits if the units are not Units_Volt_DC.
	// i.e. don't clip precision for values like 53.35 V DC.
	precision = precision < 0 ? defaultUnitPrecision(unit) : precision;
	const int digits = numberOfDigits(static_cast<int>(scaledValue));
	if (precisionAdjustmentAllowed && (unit != VenusOS::Enums::Units_Volt_DC || digits > 2)) {
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
	const int vFixed = qRound(scaledValue * vFixedMultiplier);
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
	const qreal capacity = convert(capacity_m3, VenusOS::Enums::Units_Volume_CubicMetre, unit);
	const qreal remaining = convert(remaining_m3, VenusOS::Enums::Units_Volume_CubicMetre, unit);

	const int precision = defaultUnitPrecision(unit);
	const quantityInfo c = getDisplayText(unit, capacity, precision);
	const quantityInfo r = getDisplayText(unit, remaining, precision, true, capacity);
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
