#include <velib/qt/charger_error.hpp>
#include <velib/vecan/charger_error.h>

/* Otherwise we have to include/create velib_config_app.h */
#ifndef ARRAY_LENGTH
# define ARRAY_LENGTH(a)	(sizeof(a) / sizeof(a[0]))
#endif

const VeChargerError ChargerError::errors[] =
{
	{ CHARGER_ERROR_NONE,						QT_TR_NOOP("No error") },

	{ CHARGER_ERROR_BATTERY_TEMP_TOO_HIGH,		QT_TR_NOOP("Battery high temperature") },
	{ CHARGER_ERROR_BATTERY_VOLTAGE_TOO_HIGH,	QT_TR_NOOP("Battery high voltage") },
	{ CHARGER_ERROR_BATTERY_TSENSE_PLUS_HIGH,	QT_TR_NOOP("Battery Tsense miswired") },
	{ CHARGER_ERROR_BATTERY_TSENSE_PLUS_LOW,	QT_TR_NOOP("Battery Tsense miswired") },
	{ CHARGER_ERROR_BATTERY_TSENSE_CONN_LOST,	QT_TR_NOOP("Battery Tsense missing") },
	{ CHARGER_ERROR_BATTERY_VSENSE_PLUS_LOW,	QT_TR_NOOP("Battery Vsense miswired") },
	{ CHARGER_ERROR_BATTERY_VSENSE_MIN_HIGH,	QT_TR_NOOP("Battery Vsense miswired") },
	{ CHARGER_ERROR_BATTERY_VSENSE_CONN_LOST,	QT_TR_NOOP("Battery Vsense missing") },
	{ CHARGER_ERROR_BATTERY_VSENSE_LOSSES,		QT_TR_NOOP("Battery high wire losses") },
	{ CHARGER_ERROR_BATTERY_VOLTAGE_TOO_LOW,	QT_TR_NOOP("Battery low voltage") },
	{ CHARGER_ERROR_BATTERY_RIPPLE_VOLTAGE,		QT_TR_NOOP("Battery high ripple voltage") },
	{ CHARGER_ERROR_BATTERY_LOW_SOC,			QT_TR_NOOP("Battery low state of charge") },
	{ CHARGER_ERROR_BATTERY_MIDPOINT_VOLTAGE,	QT_TR_NOOP("Battery mid-point voltage issue") },
	{ CHARGER_ERROR_BATTERY_TEMP_TOO_LOW,		QT_TR_NOOP("Battery temperature too low") },

	{ CHARGER_ERROR_CHARGER_TEMP_TOO_HIGH,		QT_TR_NOOP("Charger high temperature") },
	{ CHARGER_ERROR_CHARGER_OVER_CURRENT,		QT_TR_NOOP("Charger excessive current") },
	{ CHARGER_ERROR_CHARGER_CURRENT_REVERSED,	QT_TR_NOOP("Charger negative current") },
	{ CHARGER_ERROR_CHARGER_BULKTIME_EXPIRED,	QT_TR_NOOP("Charger bulk time expired") },
	{ CHARGER_ERROR_CHARGER_CURRENT_SENSE,		QT_TR_NOOP("Charger current sensor issue") },
	{ CHARGER_ERROR_CHARGER_TSENSE_SHORT,		QT_TR_NOOP("Internal Tsensor miswired") },
	{ CHARGER_ERROR_CHARGER_TSENSE_CONN_LOST,	QT_TR_NOOP("Internal Tsensor missing") },
	{ CHARGER_ERROR_CHARGER_FAN_MISSING,		QT_TR_NOOP("Charger fan not detected") },
	{ CHARGER_ERROR_CHARGER_FAN_OVER_CURRENT,	QT_TR_NOOP("Charger fan over-current") },
	{ CHARGER_ERROR_CHARGER_TERMINAL_OVERHEAT,	QT_TR_NOOP("Charger terminal overheat") },
	{ CHARGER_ERROR_CHARGER_SHORT_CIRCUIT,		QT_TR_NOOP("Charger short circuit") },
	{ CHARGER_ERROR_CHARGER_CONVERTER_ISSUE,	QT_TR_NOOP("Charger power stage issue") },
	{ CHARGER_ERROR_CHARGER_OVER_CHARGE,		QT_TR_NOOP("Over-charge protection") },

	{ CHARGER_ERROR_INPUT_VOLTAGE_TOO_HIGH,		QT_TR_NOOP("Input high voltage") },
	{ CHARGER_ERROR_INPUT_OVER_CURRENT,			QT_TR_NOOP("Input excessive current") },
	{ CHARGER_ERROR_INPUT_OVER_POWER,			QT_TR_NOOP("Input excessive power") },
	{ CHARGER_ERROR_INPUT_POLARITY,				QT_TR_NOOP("Input polarity issue") },
	{ CHARGER_ERROR_INPUT_VOLTAGE_ABSENT,		QT_TR_NOOP("Input voltage absent") },
	{ CHARGER_ERROR_INPUT_SHUTDOWN,				QT_TR_NOOP("Input shutdown (no retries)") },
	{ CHARGER_ERROR_INPUT_SHUTDOWN_RETRY,		QT_TR_NOOP("Input shutdown (retry)") },
	{ CHARGER_ERROR_INTERNAL_FAILURE,			QT_TR_NOOP("Input internal failure") },

	{ CHARGER_ERROR_PVRISO_FAULT,				QT_TR_NOOP("Panel isolation failure") },
	{ CHARGER_ERROR_GFCI_FAULT,					QT_TR_NOOP("Ground fault detected") },
	{ CHARGER_ERROR_GROUND_RELAY_FAULT,			QT_TR_NOOP("Ground fault detected") },

	{ CHARGER_ERROR_INVERTER_OVERLOAD,			QT_TR_NOOP("Inverter overload") },
	{ CHARGER_ERROR_INVERTER_TEMP_TOO_HIGH,		QT_TR_NOOP("Inverter temp too high") },
	{ CHARGER_ERROR_INVERTER_OVER_CURRENT,		QT_TR_NOOP("Inverter peak current") },
	{ CHARGER_ERROR_INVERTER_DC_LEVEL,			QT_TR_NOOP("Inverter internal DC level") },
	{ CHARGER_ERROR_INVERTER_AC_LEVEL,			QT_TR_NOOP("Inverter wrong ACout level") },
	{ CHARGER_ERROR_INVERTER_DC_FAIL,			QT_TR_NOOP("Inverter powerstage fault") },
	{ CHARGER_ERROR_INVERTER_AC_FAIL,			QT_TR_NOOP("Inverter powerstage fault") },
	{ CHARGER_ERROR_INVERTER_AC_ON_OUTPUT,		QT_TR_NOOP("Inverter connected to AC") },
	{ CHARGER_ERROR_INVERTER_BRIDGE_FAULT,		QT_TR_NOOP("Inverter powerstage fault") },
	{ CHARGER_ERROR_ACIN1_RELAY_FAULT,			QT_TR_NOOP("ACIN1 relay test fault") },
	{ CHARGER_ERROR_ACIN2_RELAY_FAULT,			QT_TR_NOOP("ACIN2 relay test fault") },

	{ CHARGER_ERROR_LINK_DEVICE_MISSING,		QT_TR_NOOP("Device disappeared") },
	{ CHARGER_ERROR_LINK_CONFIGURATION,			QT_TR_NOOP("Incompatible device") },
	{ CHARGER_ERROR_LINK_BMS_MISSING,			QT_TR_NOOP("BMS connection lost") },
	{ CHARGER_ERROR_LINK_CONFIG_MISMATCH,		QT_TR_NOOP("Network misconfigured") },

	{ CHARGER_ERROR_MEMORY_WRITE_FAILURE,		QT_TR_NOOP("Memory write error") },
	{ CHARGER_ERROR_CPU_TEMP_TOO_HIGH,			QT_TR_NOOP("CPU temperature too high") },
	{ CHARGER_ERROR_COMMUNICATION_LOST,			QT_TR_NOOP("Communication lost") },
	{ CHARGER_ERROR_CALIBRATION_DATA_LOST,		QT_TR_NOOP("Calibration data lost") },
	{ CHARGER_ERROR_INVALID_FIRMWARE,			QT_TR_NOOP("Incompatible firmware") },
	{ CHARGER_ERROR_INVALID_HARDWARE,			QT_TR_NOOP("Incompatible hardware") },
	{ CHARGER_ERROR_SETTINGS_DATA_INVALID,		QT_TR_NOOP("Settings invalid") },
	{ CHARGER_ERROR_REFERENCE_VOLTAGE_FAILURE,	QT_TR_NOOP("Reference voltage failed") },
	{ CHARGER_ERROR_TESTER_FAIL,				QT_TR_NOOP("Tester fail") },
	{ CHARGER_ERROR_HISTORY_DATA_INVALID,		QT_TR_NOOP("History invalid") },

	{ CHARGER_ERROR_INTERNAL_UNDERVOLTAGE_HV,	QT_TR_NOOP("DC voltage error") },
	{ CHARGER_ERROR_INTERNAL_DCDC_FAILURE,		QT_TR_NOOP("DC voltage error") },
	{ CHARGER_ERROR_INTERNAL_UNDERVOLTAGE_3V3,	QT_TR_NOOP("3V3 supply error") },
	{ CHARGER_ERROR_INTERNAL_UNDERVOLTAGE_5V,	QT_TR_NOOP("5V supply error") },
	{ CHARGER_ERROR_INTERNAL_UNDERVOLTAGE_12V,	QT_TR_NOOP("12V supply error") },
	{ CHARGER_ERROR_INTERNAL_UNDERVOLTAGE_15V,	QT_TR_NOOP("15V supply error") },
};

ChargerError::ChargerError()
{
}

QString ChargerError::getDescription(int error)
{
	QString description = "#" + QString::number(error) + " ";

	for (size_t i = 0; i < ARRAY_LENGTH(errors); i++) {
		if (errors[i].errorId == error)
			description += tr(errors[i].description);
	}

	return description;
}

bool ChargerError::isWarning(int error)
{
	return error == CHARGER_ERROR_LINK_DEVICE_MISSING ||
		error == CHARGER_ERROR_LINK_CONFIGURATION ||
		error == CHARGER_ERROR_BATTERY_TEMP_TOO_LOW;
}
