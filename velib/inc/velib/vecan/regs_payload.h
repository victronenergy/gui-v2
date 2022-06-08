#ifndef _VELIB_VECAN_REGS_PAYLOAD_H_
#define _VELIB_VECAN_REGS_PAYLOAD_H_

/**
 * @addtogroup VELIB_VECAN_REG
 * @{
 */

/// Generic OK.
#define VACK_OK						0x0000
/// Used by UDF to indicate it is ready.
#define VACK_BEGIN					0x0100
/// Used by UDF to poll for more data.
#define VACK_CONT					0x0200

/// VE_REG_UPDATE_DATA specific
/// Used by UDF to signal that the real ACK is delayed by 1 data packet.
/// The updater is expected to send a VE_REG_UPDATE_DATA packet without
/// actual update data (but with the reserved byte) at the end of the
/// update for every VACK_DELAYED that is received.
#define VACK_DELAYED				0x4000

/// Error flag.
#define VACK_ERR					0x8000
/// Erroneous request, register unknown.
#define VACK_ERR_REQ				0x8000
/// Erroneous command, register unknown.
#define VACK_ERR_CMD				0x8100

/// Temporary failure.
#define VACK_ERR_BUSY				0x8200
/// Fatal error, invalid format etc.
#define VACK_ERR_INVALID			0x8300
/// Remote timeout.
#define VACK_ERR_TIMEOUT			0x8400
/// Too many invalid requests etc.
#define VACK_ERR_OVERFLOW			0x8500
/// Temporary failure, not completely initialiazed yet.
#define VACK_ERR_INITIALIZING		0x8600

/// Specific for VE_REG_UPDATE_DATA, can't boot (no valid application)
#define VACK_ERR_UPD_INVALID		0xC000

/// Specific for VE_REG_UPDATE_DATA
#define VACK_ERR_ERASING			0xC100

/// Specific for VE_REG_UPDATE_DATA
#define VACK_ERR_WRITE				0xC200

/// Specific for VE_REG_UPDATE_DATA/BEGIN/ENABLE/END
#define VACK_ERR_INVALID_INSTANCE	0xC300

/// Specific for VE_REG_UPDATE_DATA, incorrect manufacturer id
#define VACK_ERR_MANUFACTURER_ID	0xC400

/// Specific for VE_REG_UPDATE_DATA, incorrect header length
#define VACK_ERR_HEADER_LENGTH		0xC500

/// Specific for VE_REG_UPDATE_DATA, image is not for this product
#define VACK_ERR_PRODUCT_ID			0xC600

/// Specific for VE_REG_UPDATE_DATA, image type is incorrect
#define VACK_ERR_IMAGE_TYPE			0xC700

/// Specific for VE_REG_UPDATE_DATA, prevent incompatible downgrades (application version)
#define VACK_ERR_APP_VER_MIN		0xC800

/// Specific for VE_REG_UPDATE_DATA, prevent incompatible downgrades (bootloader version)
#define VACK_ERR_UDF_VER_MIN		0xC900

/// Specific for VE_REG_UPDATE_DATA, invalid image length
#define VACK_ERR_APP_LEN			0xCA00

/// Specific for VE_REG_UPDATE_DATA, invalid key
#define VACK_ERR_KEY				0xCB00

/// Specific for VE_REG_UPDATE_ENABLE, cannot update (e.g. battery voltage too low)
#define VACK_ERR_CANNOT_UPDATE		0xCC00

/// Specific for VE_REG_CONTROL, multi's can only controlled by 1 panel.
#define VACK_ERR_PANEL_PRESENT		0xC001

/// Internal, local timeout; not response reveived in time.
#define VACK_ERR_LOCAL_TIMEOUT		0xFFFE
/// Internal
#define VACK_INVALID				0xFFFF
/// Internal as well, used to not automatically send the value after a command
#define VACK_DO_NOT_SEND_VREG		0xFFFF

/// Register id is un16
typedef un16 VeRegAckCode;

/*
 * VE_REG_BLE_MODE - 0x0090
 *
 *  un8 mode
 */

#define VE_REG_MODE_BLE_DISABLED	0x00 /* BLE disabled */
#define VE_REG_MODE_BLE_ENABLED		0x01 /* BLE enabled */

/*
 * VE_REG_DEVICE_MODE	- 0x0200
 *
 *	un8 mode
 */
#define VE_REG_MODE_CHARGER				0x01
#define VE_REG_MODE_INVERTER			0x02
#define VE_REG_MODE_ON					0x03
#define VE_REG_MODE_OFF					0x04
#define VE_REG_MODE_ECO					0x05
#define VE_REG_MODE_STANDBY				0xFC
#define VE_REG_MODE_HIBERNATE			0xFD

/*
 * VE_REG_DEVICE_STATE	- 0x0201
 *
 *	un8 state
 *
 *  please see nmea2k/n2k.h DD342 (enum N2kConverterState)
 */
#define VE_REG_STATE_OFF				0x00 /*!< deprecated for new designs: use N2kConverterState::N2K_CONVERTER_STATE_OFF */
#define VE_REG_STATE_LOW_POWER_MODE			0x01 /*!< deprecated for new designs: use N2kConverterState::N2K_CONVERTER_STATE_LOW_POWER_MODE */
#define VE_REG_STATE_FAULT				0x02 /*!< deprecated for new designs: use N2kConverterState::N2K_CONVERTER_STATE_FAULT */
#define VE_REG_STATE_BULK				0x03 /*!< deprecated for new designs: use N2kConverterState::N2K_CONVERTER_STATE_BULK */
#define VE_REG_STATE_ABSORPTION				0x04 /*!< deprecated for new designs: use N2kConverterState::N2K_CONVERTER_STATE_ABSORPTION */
#define VE_REG_STATE_FLOAT				0x05 /*!< deprecated for new designs: use N2kConverterState::N2K_CONVERTER_STATE_FLOAT */
#define VE_REG_STATE_STORAGE				0x06 /*!< deprecated for new designs: use N2kConverterState::N2K_CONVERTER_STATE_STORAGE */
#define VE_REG_STATE_EQUALISE				0x07 /*!< deprecated for new designs: use N2kConverterState::N2K_CONVERTER_STATE_EQUALIZE */
#define VE_REG_STATE_PASSTHRU				0x08 /*!< deprecated for new designs: use N2kConverterState::N2K_CONVERTER_STATE_PASSTHRU */
#define VE_REG_STATE_INVERTING				0x09 /*!< deprecated for new designs: use N2kConverterState::N2K_CONVERTER_STATE_INVERTING */
#define VE_REG_STATE_ASSISTING				0x0A /*!< deprecated for new designs: use N2kConverterState::N2K_CONVERTER_STATE_ASSISTING */
#define VE_REG_STATE_POWER_SUPPLY_MODE			0x0B /*!< deprecated for new designs: use N2kConverterState::N2K_CONVERTER_STATE_PSU */
#define VE_REG_STATE_ON					0xF9 /*!< deprecated for new designs: N2kConverterState has no match for this meaning, value 0xF9 overlaps with N2K_CONVERTER_STATE_LOAD_DETECT */
#define VE_REG_STATE_BLOCKED				0xFA /*!< deprecated for new designs: use N2kConverterState::N2K_CONVERTER_STATE_BLOCKED */
#define VE_REG_STATE_TEST_MODE				0xFB /*!< deprecated for new designs: use N2kConverterState::N2K_CONVERTER_STATE_TEST */
#define VE_REG_STATE_HUB_1				0xFC /*!< deprecated for new designs: use N2kConverterState::N2K_CONVERTER_STATE_EXTERNAL_CONTROL */

/*
 * VE_REG_REMOTE_CONTROL_USED	- 0x0202
 *
 *	un32 flags
 */
#define VE_REG_RC_AC1_IN_LIMIT			0x00000001
#define VE_REG_RC_ON_OFF_MODE			0x00000002
#define VE_REG_RC_AC2_IN_LIMIT			0x00000004
#define VE_REG_RC_SEND_LEDS				0x00000100
#define VE_REG_RC_SEND_CELL_VOLTAGES	0x00010000
#define VE_REG_RC_SEND_RELAYS			0x00020000

/*
 * VE_REG_DEVICE_OFF_REASON - 0x0205
 *
 *  un8 reason
 */

#define VE_REG_DEVICE_OFF_NO_INPUT_POWER		0x01 /* no/low mains/panel/battery power */
#define VE_REG_DEVICE_OFF_HARD_POWER_SWITCH		0x02 /* physical switch */
#define VE_REG_DEVICE_OFF_SOFT_POWER_SWITCH		0x04 /* remote via device_mode and/or push-button */
#define VE_REG_DEVICE_OFF_REMOTE_INPUT			0x08 /* remote input connector */
#define VE_REG_DEVICE_OFF_INTERNAL_REASON		0x10 /* internal condition preventing start-up */
#define VE_REG_DEVICE_OFF_PAYGO					0x20 /* need token for operation */
#define VE_REG_DEVICE_OFF_BMS					0x40 /* allow-to-charge/allow-to-discharge signals from BMS */
#define VE_REG_DEVICE_OFF_ENGINE_SD_DETECTION	0x80 /* engine shutdown detected through low input voltage */

/*
 * VE_REG_DEVICE_FUNCTION - 0x0206
 *
 *  un8 function
 */
#define VE_REG_FUNCTION_CHARGER			0x00
#define VE_REG_FUNCTION_PSU				0x01

/*
 * VE_REG_DEVICE_OFF_REASON_2 - 0x0207
 *
 *  un32 reason
 */

#define VE_REG_DEVICE_OFF_2_NO_INPUT_POWER			0x00000001 /* no/low mains/panel/battery power */
#define VE_REG_DEVICE_OFF_2_HARD_POWER_SWITCH		0x00000002 /* physical switch */
#define VE_REG_DEVICE_OFF_2_SOFT_POWER_SWITCH		0x00000004 /* remote via device_mode and/or push-button */
#define VE_REG_DEVICE_OFF_2_REMOTE_INPUT			0x00000008 /* remote input connector */
#define VE_REG_DEVICE_OFF_2_INTERNAL_REASON			0x00000010 /* internal condition preventing start-up */
#define VE_REG_DEVICE_OFF_2_PAYGO					0x00000020 /* need token for operation */
#define VE_REG_DEVICE_OFF_2_BMS						0x00000040 /* allow-to-charge/allow-to-discharge signals from BMS */
#define VE_REG_DEVICE_OFF_2_ENGINE_SD_DETECTION		0x00000080 /* engine shutdown detected through low input voltage */
#define VE_REG_DEVICE_OFF_2_ANALYZING_INPUT_VOLTAGE	0x00000100 /* converter off to check input voltage without cable losses */
#define VE_REG_DEVICE_OFF_2_LOW_BATTERY_TEMPERATURE	0x00000200 /* low temperature cut-off */
#define VE_REG_DEVICE_OFF_2_NO_PV_POWER				0x00000400 /* no/low panel power */
#define VE_REG_DEVICE_OFF_2_LOW_BATTERY				0x00000800 /* no/low battery power */
#define VE_REG_DEVICE_OFF_2_LOW_MAINS				0x00001000 /* no/low mains power */
#define VE_REG_DEVICE_OFF_2_NO_CANSYNC				0x00002000 /* parallel operation: slave inverter out of sync */
#define VE_REG_DEVICE_OFF_2_NOT_ENOUGH_INVERTERS_SYNC_CAN	0x00004000 /* parallel operation: insufficient inverters */
#define VE_REG_DEVICE_OFF_2_ACTIVE_ALARM			0x00008000 /* an active alarm prevents the unit from starting see vreg 0x031E */

/*
 * VE_REG_BPR_MODE	- 0xE900
 *
 *	un8 mode
 */
#define VE_REG_BPR_MODE_NORMAL			0x00
#define VE_REG_BPR_MODE_LI_ION			0x01

/*
 * VE_REG_BPR_PROFILE	- 0xE901
 *
 *	un8 profile
 */
#define VE_REG_BPR_PROFILE_USER			0xFF /* User defined (under voltage) profile setting */


/*
 * VE_REG_DISCHARGE_OFF_REASON			- 0xEC44
 * VE_REG_CHARGE_OFF_REASON				- 0xEC45
 * VE_REG_ALLOW_DISCHARGE_OFF_REASON	- 0xEC46
 * VE_REG_ALLOW_CHARGE_OFF_REASON		- 0xEC47
 *
 *	un16 reason
 */
#define VE_REG_OFF_REASON_BATTERY				0x0001 /* Not allowed by battery */
#define VE_REG_OFF_REASON_LOW_INPUT_VOLTAGE		0x0002 /* Input voltage too low */
#define VE_REG_OFF_REASON_HIGH_TEMPERATURE		0x0004 /* Temperature too high */
#define VE_REG_OFF_REASON_REMOTE_INPUT			0x0008 /* Remote input connector */
#define VE_REG_OFF_REASON_INTERNAL				0x0010 /* Internal condition */
#define VE_REG_OFF_REASON_OVERLOAD				0x0020 /* Overload */
#define VE_REG_OFF_REASON_HIGH_BATTERY_VOLTAGE	0x0040 /* Battery voltage too high */
#define VE_REG_OFF_REASON_SOFT_POWER_SWITCH		0x0080 /* remote via device_mode and/or push-button */

/*
 * VE_REG_FUSE_TYPE	- 0xEC48
 *
 *	un8 type
 */
#define VE_REG_FUSE_TYPE_2_7A					0x00 /* 2x 7.5A */
#define VE_REG_FUSE_TYPE_2_10A					0x01 /* 2x 10A */
#define VE_REG_FUSE_TYPE_2_15A					0x02 /* 2x 15A */
#define VE_REG_FUSE_TYPE_2_20A					0x03 /* 2x 20A */
#define VE_REG_FUSE_TYPE_2_30A					0x04 /* 2x 30A */
#define VE_REG_FUSE_TYPE_1_60A					0x05 /* 1x 60A */
#define VE_REG_FUSE_TYPE_1_80A					0x06 /* 1x 80A */
#define VE_REG_FUSE_TYPE_1_100A					0x07 /* 1x 100A */
#define VE_REG_FUSE_TYPE_1_125A					0x08 /* 1x 125A */

/*
 * VE_REG_BLE_ADVERTISEMENT_MODE - 0xEC7D
 *
 *  un8 mode
 */

#define VE_REG_MODE_BLE_ADVERTISEMENT_CLASSIC_DATA		0x00 /* Service UUIDs enabled, extra manufacturer data disabled */
#define VE_REG_MODE_BLE_ADVERTISEMENT_MANUF_DATA		0x01 /* Service UUIDs disabled, extra manufacturer data enabled */

/*
 * VE_REG_BLE_GATT_VEREG_SERVICE_MODE - 0xEC7E
 *
 *  un8 mode
 */

#define VE_REG_MODE_BLE_GATT_VEREG_SERVICE_DISABLED		0x00 /* VE-Reg BLE service disabled */
#define VE_REG_MODE_BLE_GATT_VEREG_SERVICE_ENABLED		0x01 /* VE-Reg BLE service enabled */

/*
 * VE_REG_BAT_CHEMISTRY	- 0xED2F
 *
 *	un8 chemistry
 */
#define VE_REG_BAT_CHEMISTRY_OPZS_OPZV		0x00 /*!< OPzS/OPzV */
#define VE_REG_BAT_CHEMISTRY_GEL_AGM		0x01 /*!< Gel/AGM */
#define VE_REG_BAT_CHEMISTRY_LIFEPO4		0x02 /*!< Lithium Iron Phosphate (LiFePo4) */

/*
 * VE_REG_CHR_CUSTOM_STATE	- 0xEDD4
 *
 *	un8 state
 */
#define VE_REG_CUSTOM_STATE_SAFE_MODE		0x01 /*!< deprecated for new designs: use N2kConverterState::N2K_CONVERTER_STATE_BATTERYSAFE */
#define VE_REG_CUSTOM_STATE_TPTB_MODE		0x02 /*!< deprecated for new designs: use N2kConverterState::N2K_CONVERTER_STATE_AUTO_EQUALIZE */
#define VE_REG_CUSTOM_STATE_REPEATED_ABS	0x04 /*!< deprecated for new designs: use N2kConverterState::N2K_CONVERTER_STATE_BATTERYSAFE */
#define VE_REG_CUSTOM_STATE_LOW_INP_DIM		0x08
#define VE_REG_CUSTOM_STATE_TEMP_DIM		0x10
#define VE_REG_CUSTOM_STATE_SENSE_DIM		0x20
#define VE_REG_CUSTOM_STATE_INP_CUR_DIM		0x40
#define VE_REG_CUSTOM_STATE_LOW_CUR_MODE	0x80

/*
 * VE_REG_CHR_RELAY_MODE - 0xEDD9
 *
 *  un8 mode
 */
#define VE_REG_CHR_RELAY_MODE_CHARGING				0x00 /*!< Skylla chargers only */
#define VE_REG_CHR_RELAY_MODE_ALWAYS_OFF			0x00
#define VE_REG_CHR_RELAY_MODE_HIGH_PANEL_VOLTAGE	0x01
#define VE_REG_CHR_RELAY_MODE_HIGH_TEMPERATURE		0x02
#define VE_REG_CHR_RELAY_MODE_LOW_BATTERY_VOLTAGE	0x03
#define VE_REG_CHR_RELAY_MODE_EQUALIZATION			0x04
#define VE_REG_CHR_RELAY_MODE_ERROR_STATE			0x05
#define VE_REG_CHR_RELAY_MODE_LOW_TEMPERATURE		0x06
#define VE_REG_CHR_RELAY_MODE_HIGH_BATTERY_VOLTAGE	0x07
#define VE_REG_CHR_RELAY_MODE_FLOAT_OR_STORAGE		0x08
#define VE_REG_CHR_RELAY_MODE_PANEL_IRRADIATED		0x09
#define VE_REG_CHR_RELAY_MODE_LOAD_OUTPUT			0x0A
#define VE_REG_CHR_RELAY_MODE_RESERVED				0xFE /*!< VE_REG_RELAY_MODE in use */
#define VE_REG_CHR_RELAY_MODE_REMOTE_CONTROL		0xFF

/* The following defines map the deprecated VE_REG_RELAY_MODE_xxxxxxx values to the new
 * (and correct) VE_REG_CHR_RELAY_MODE_xxxxx values.
 * Do not add new VE_REG_RELAY_MODE_xxxx values here, as they are just to keep old code compiling.
 * When a new value has to be added, it should only be added as VE_REG_CHR_RELAY_MODE_xxxxx
 * and all code should be converted to use the VE_REG_CHR_RELAY_MODE_xxxxx values.
 * This might allow deleting the deprecated VE_REG_RELAY_MODE_xxxxx defines in the future. */

#define VE_REG_RELAY_MODE_CHARGING				VE_REG_CHR_RELAY_MODE_CHARGING
#define VE_REG_RELAY_MODE_HIGH_PANEL_VOLTAGE	VE_REG_CHR_RELAY_MODE_HIGH_PANEL_VOLTAGE
#define VE_REG_RELAY_MODE_HIGH_TEMPERATURE		VE_REG_CHR_RELAY_MODE_HIGH_TEMPERATURE
#define VE_REG_RELAY_MODE_LOW_BATTERY_VOLTAGE	VE_REG_CHR_RELAY_MODE_LOW_BATTERY_VOLTAGE
#define VE_REG_RELAY_MODE_EQUALIZATION			VE_REG_CHR_RELAY_MODE_EQUALIZATION
#define VE_REG_RELAY_MODE_ERROR_STATE			VE_REG_CHR_RELAY_MODE_ERROR_STATE
#define VE_REG_RELAY_MODE_LOW_TEMPERATURE		VE_REG_CHR_RELAY_MODE_LOW_TEMPERATURE
#define VE_REG_RELAY_MODE_HIGH_BATTERY_VOLTAGE	VE_REG_CHR_RELAY_MODE_HIGH_BATTERY_VOLTAGE
#define VE_REG_RELAY_MODE_FLOAT_OR_STORAGE		VE_REG_CHR_RELAY_MODE_FLOAT_OR_STORAGE
#define VE_REG_RELAY_MODE_PANEL_IRRADIATED		VE_REG_CHR_RELAY_MODE_PANEL_IRRADIATED
#define VE_REG_RELAY_MODE_LOAD_OUTPUT			VE_REG_CHR_RELAY_MODE_LOAD_OUTPUT
#define VE_REG_RELAY_MODE_REMOTE_CONTROL		VE_REG_CHR_RELAY_MODE_REMOTE_CONTROL

/*
 * VE_REG_DC_OUTPUT_STATUS	- 0xEDA8
 *
 *	un8 status
 */
#define VE_REG_DC_OUTPUT_STATUS_OFF		0x00	/* Output off */
#define VE_REG_DC_OUTPUT_STATUS_ON		0x01	/* Output on */
#define VE_REG_DC_OUTPUT_STATUS_CONNECTING	0x02	/* Connecting: Output scheduled to be activated */
#define VE_REG_DC_OUTPUT_STATUS_ACTIVATING	0x03	/* Activating: Attempting to activate output */

/*
 * VE_REG_DC_OUTPUT_CONTROL	- 0xEDAB
 *
 *	un8 mode
 */
#define VE_REG_DC_OUTPUT_CTRL_MASK			0x0F
#define VE_REG_DC_OUTPUT_CTRL_FORCE_OFF		0x00
#define VE_REG_DC_OUTPUT_CTRL_AUTO			0x01
#define VE_REG_DC_OUTPUT_CTRL_ALT1			0x02
#define VE_REG_DC_OUTPUT_CTRL_ALT2			0x03
#define VE_REG_DC_OUTPUT_CTRL_FORCE_ON		0x04
#define VE_REG_DC_OUTPUT_CTRL_USER1			0x05
#define VE_REG_DC_OUTPUT_CTRL_USER2			0x06
#define VE_REG_DC_OUTPUT_CTRL_AES			0x07
#define VE_REG_DC_OUTPUT_CTRL_LIGHT_FLAG	0x80

/*
 * VE_REG_VEDIRECT_PORT_TX_FUNCTION - 0xED9E
 *
 * un8 mode
 */
#define VE_REG_PORT_TX_VE_DIRECT			0x00
#define VE_REG_PORT_TX_001KWH_PULSES		0x01
#define VE_REG_PORT_TX_LIGHT_PWM_NORMAL		0x02
#define VE_REG_PORT_TX_LIGHT_PWM_INVERTED	0x03
#define VE_REG_PORT_TX_VIRTUAL_LOAD_OUTPUT	0x04
#define VE_REG_PORT_TX_VIRTUAL_RELAY		0x05

/*
 * VE_REG_VEDIRECT_PORT_RX_FUNCTION - 0xED98
 *
 * un8 mode
 */
#define VE_REG_PORT_RX_REMOTE_ON_OFF				0x00 /* 0=do-not-charge, 1=allow-to-charge (default) */
#define VE_REG_PORT_RX_LOAD_OUTPUT_CONFIG			0x01 /* 0=alt1, 1=battery_life (default), RX/TX shorted=alt2 */
#define VE_REG_PORT_RX_LOAD_OUTPUT_ON_OFF_INVERTED	0x02 /* 0=load output on, 1=load output off (default) */
#define VE_REG_PORT_RX_LOAD_OUTPUT_ON_OFF_NORMAL	0x03 /* 0=load output off, 1=load output on (default) */

/*
 * VE_REG_LINK_COMMAND	- 0x2004
 *
 *	un8 command
 */
#define VE_REG_COMMAND_START_EQUALISE		0x01
#define VE_REG_COMMAND_STOP_EQUALISE		0x02
#define VE_REG_COMMAND_GUI_SYNC				0x03
#define VE_REG_COMMAND_DAY_SYNC				0x04

/*
 * VE_REG_LINK_NETWORK_INFO - 0x200D
 *
 * un16 info
 */
#define VE_REG_NETWORK_INFO_BMS						0x0001
#define VE_REG_NETWORK_INFO_EXTERNAL_VCONTROL		0x0002
#define VE_REG_NETWORK_INFO_CHARGE_SLAVE			0x0004
#define VE_REG_NETWORK_INFO_CHARGE_MASTER			0x0008
#define VE_REG_NETWORK_INFO_ICHARGE					0x0010
#define VE_REG_NETWORK_INFO_ISENSE					0x0020
#define VE_REG_NETWORK_INFO_TSENSE					0x0040
#define VE_REG_NETWORK_INFO_VSENSE					0x0080
#define VE_REG_NETWORK_INFO_STANDBY					0x0100
#define VE_REG_NETWORK_INFO_EXTERNAL_ICONTROL		0x0200

/*
 * VE_REG_LINK_NETWORK_MODE - 0x200E
 *
 * un8 mode
 */
#define VE_REG_NETWORK_MODE_STANDALONE			0x00
#define VE_REG_NETWORK_MODE_NETWORKED			0x01
#define VE_REG_NETWORK_MODE_REMOTE_CHARGE		0x02
#define VE_REG_NETWORK_MODE_EXTERNAL_CONTROL	0x04
#define VE_REG_NETWORK_MODE_REMOTE_BMS			0x08
#define VE_REG_NETWORK_MODE_GROUP_MASTER		0x10
#define VE_REG_NETWORK_MODE_INSTANCE_MASTER		0x20
#define VE_REG_NETWORK_MODE_STANDBY_CHARGER		0x40
#define VE_REG_NETWORK_MODE_STANDBY_INVERTER	0x80

//deprecated names:
#define VE_REG_NETWORK_MODE_STANDBY VE_REG_NETWORK_MODE_STANDBY_CHARGER
#define VE_REG_NETWORK_MODE_REMOTE_HUB1	VE_REG_NETWORK_MODE_EXTERNAL_CONTROL
#define VE_REG_NETWORK_MODE_REMOTE_ESS VE_REG_NETWORK_MODE_EXTERNAL_CONTROL

/*
 * VE_REG_LINK_NETWORK_STATUS - 0x200F
 *
 * un8 status
 */
#define VE_REG_NETWORK_STATUS_SLAVE				0x00
#define VE_REG_NETWORK_STATUS_GROUP_MASTER		0x01
#define VE_REG_NETWORK_STATUS_INSTANCE_MASTER	0x02
#define VE_REG_NETWORK_STATUS_STANDALONE		0x04
#define VE_REG_NETWORK_STATUS_USING_ICHARGE		0x10
#define VE_REG_NETWORK_STATUS_USING_ISENSE		0x20
#define VE_REG_NETWORK_STATUS_USING_TSENSE		0x40
#define VE_REG_NETWORK_STATUS_USING_VSENSE		0x80

/*
 * VE_REG_LINK_DISABLE_NETWORK_DATA - 0x201A
 *
 * un8 disable
 */
#define VE_REG_LINK_DISABLE_NETWORK_DATA_SYNC_CHRG	0x01
#define VE_REG_LINK_DISABLE_NETWORK_DATA_ISENSE		0x02
#define VE_REG_LINK_DISABLE_NETWORK_DATA_TSENSE		0x04
#define VE_REG_LINK_DISABLE_NETWORK_DATA_VSENSE		0x08

/*
 * VE_REG_BACKLIGHT_ALWAYS_ON - 0x0400
 *
 * un8 mode
 */
#define VE_REG_BACKLIGHT_ALWAYS_ON_STAY_OFF		0x00
#define VE_REG_BACKLIGHT_ALWAYS_ON_STAY_ON		0x01
#define VE_REG_BACKLIGHT_ALWAYS_ON_AUTOMATIC	0x02

/*
 * VE_REG_BACKLIGHT_MODE - 0x0408
 *
 * un8 mode
 */
#define VE_REG_BACKLIGHT_MODE_ALWAYS_OFF	0x00
#define VE_REG_BACKLIGHT_MODE_ALWAYS_ON		0x01
#define VE_REG_BACKLIGHT_MODE_AUTOMATIC		0x02

/*
 * VE_REG_RELAY_MODE	- 0x034F
 *
 *	un8 mode
 */
#define VE_REG_RELAY_MODE_ALARM				0x00 /*!< All available relay thresholds are or-ed (BMV) All available warnings and alarms are or-ed (Inverter) */
#define VE_REG_RELAY_MODE_CHARGER			0x01 /*!< Battery needs to be charged, due to low soc/voltage (BMV,BPR) */
#define VE_REG_RELAY_MODE_REMOTE			0x02 /*!< Remote control of the relay, use VE_REG_RELAY_CONTROL */
#define VE_REG_RELAY_MODE_ALWAYS_OPEN		0x03 /*!< Relay always in the open position */
#define VE_REG_RELAY_MODE_INVERTER			0x04 /*!< Relay on when inverter active (ac out present or searching in eco mode) */
#define VE_REG_RELAY_MODE_BATTERY_LOW		0x05 /*!< Inverter in battery low warning (using levels as defined by VE_REG_ALARM_LOW_VOLTAGE_SET and VE_REG_ALARM_LOW_VOLTAGE_CLEAR) */
#define VE_REG_RELAY_MODE_FAN				0x06 /*!< Internal fan active */
#define VE_REG_RELAY_MODE_INDICATOR			0x07 /*!< Can be used to drive a LED or a buzzer */
#define VE_REG_RELAY_MODE_IS_CHARGING		0x08 /*!< Battery within limits and charging (i.e. no error and not off) */
#define VE_REG_RELAY_MODE_GENERATOR			0x09 /*!< Generator start/stop control */
#define VE_REG_RELAY_MODE_ALWAYS_CLOSED		0x0A /*!< Relay always in the closed position */
#define VE_REG_RELAY_MODE_RESERVED			0xFE /*!< VE_REG_CHR_RELAY_MODE in use */

/*
 * VE_REG_DC_OUTPUT_OFF_REASON	- 0xED91
 *
 *	un8 mask
 */
#define VE_REG_DC_OUTPUT_OFF_BATTERY_LOW	0x01
#define VE_REG_DC_OUTPUT_OFF_OVER_CURRENT	0x02
#define VE_REG_DC_OUTPUT_OFF_TIMER_PROGRAM	0x04
#define VE_REG_DC_OUTPUT_OFF_REMOTE_OFF		0x08
#define VE_REG_DC_OUTPUT_OFF_LUMETER_OFF	0x10
#define VE_REG_DC_OUTPUT_OFF_PAYGO_OFF		0x20
#define VE_REG_DC_OUTPUT_OFF_SYSTEM_STARTUP	0x80

/*
 * VE_REG_DC_INPUT_MPP_MODE - 0xEDB3
 *
 * un8 mode
 */
#define VE_REG_DC_INPUT_MPP_MODE_OFF		0x00
#define VE_REG_DC_INPUT_MPP_MODE_VI			0x01
#define VE_REG_DC_INPUT_MPP_MODE_MPPT		0x02

/*
 * VE_REG_LINK_RTC_SOLAR - 0x2030
 *
 *	un8 state
 */
#define VE_REG_LINK_RTC_SOLAR_STATE_NIGHT	0x00
#define VE_REG_LINK_RTC_SOLAR_STATE_DAY		0x01
#define VE_REG_LINK_RTC_SOLAR_STATE_UNKNOWN	0xFF

/*
 * VE_REG_LYNX_ION_BMS_STATE - 0x0371
 *
 *	un8 state
 */
#define VE_VDATA_ION_BMS_STATE_WAIT_START				0
#define VE_VDATA_ION_BMS_STATE_BEFORE_BOOT				1
#define VE_VDATA_ION_BMS_STATE_BEFORE_BOOT_DELAY		2
#define VE_VDATA_ION_BMS_STATE_WAIT_BOOT				3
#define VE_VDATA_ION_BMS_STATE_INIT						4
#define VE_VDATA_ION_BMS_STATE_MEAS_BAT_VOLTAGE			5
#define VE_VDATA_ION_BMS_STATE_CALC_BAT_VOLTAGE			6
#define VE_VDATA_ION_BMS_STATE_WAIT_BUS_VOLTAGE			7
#define VE_VDATA_ION_BMS_STATE_WAIT_SHUNT				8
#define VE_VDATA_ION_BMS_STATE_RUNNING					9
#define VE_VDATA_ION_BMS_STATE_ERROR					10
#define VE_VDATA_ION_BMS_STATE_UNUSED_11				11
#define VE_VDATA_ION_BMS_STATE_SHUTDOWN					12
#define VE_VDATA_ION_BMS_STATE_SLAVE_UPDATING			13
#define VE_VDATA_ION_BMS_STATE_STANDBY					14
#define VE_VDATA_ION_BMS_STATE_GOING_TO_RUN				15
#define VE_VDATA_ION_BMS_STATE_PRE_CHARGING				16

/// @ingroup VELIB_VECAN_REG
/// @defgroup VE_REG_ALARM_REASON
/// @{
/* VE_REG_ALARM_REASON_XXXX.. are flags/bitmasks (un16) for:
 *   VE_REG_ALARM_REASON     (0x031E)
 *   VE_REG_WARNING_REASON   (0x031C)
 *
 * The flags are ALARMS according BMV60 (not in regs.h).  The Macros are renamed to avoid lib conflicts
 * For MultiC/inverter not all alarms are supported and extra alarms are added (bit 8 and higher)
 * Also
 *   VE_REG_ALARM_REASON is triggered and defined by the first active protection, typically that is one reason.
 *   VE_REG_ALARM_REASON is not cleared until the inverter is operating normal again (e.g. by user reset or time out)
 *   VE_REG_WARNING_REASON always represents the current state of the protected levels.
 * @note regs_helpers has macros to detect multiple flags for grouped alarms.
 */
#define VE_REG_ALARM_REASON_LOW_VOLTAGE			0x0001		/* low battery voltage alarm */
#define VE_REG_ALARM_REASON_HIGH_VOLTAGE		0x0002		/* high battery voltage alarm */
#define VE_REG_ALARM_REASON_LOW_SOC				0x0004		/* low State Of Charge alarm */
#define VE_REG_ALARM_REASON_LOW_VOLTAGE2		0x0008		/* low voltage2 alarm */
#define VE_REG_ALARM_REASON_HIGH_VOLTAGE2		0x0010		/* high voltage2 alarm */
#define VE_REG_ALARM_REASON_LOW_TEMPERATURE		0x0020		/* low temperature alarm (also not connected transformer NTC)*/
#define VE_REG_ALARM_REASON_HIGH_TEMPERATURE	0x0040		/* high temperature alarm */
#define VE_REG_ALARM_REASON_MID_VOLTAGE			0x0080		/* mid voltage alarm */
#define VE_REG_ALARM_REASON_OVERLOAD			0x0100		/* e.g. based on Iinv^2 or Ipeak events count*/
#define VE_REG_ALARM_REASON_DC_RIPPLE			0x0200		/* e.g. indication for poor battery connection */
#define VE_REG_ALARM_REASON_LOW_V_AC_OUT		0x0400		/* e.g. in case of large load and low battery */
#define VE_REG_ALARM_REASON_HIGH_V_AC_OUT		0x0800		/* e.g. typ. when connected to other "mains" source, this will prevent the inverter-only to start*/
#define VE_REG_ALARM_REASON_SHORT_CIRCUIT		0x1000		/* short circuit alarm */
#define VE_REG_ALARM_REASON_BMS_LOCKOUT			0x2000		/* BMS Lockout alarm (used in Smart Battery Protect) */
#define VE_REG_ALARM_REASON_BMS_CABLE_FAILURE	0x4000		/* Battery M8 BMS Cable not connected or defect  (used in Smart BMS)*/
/// @}

/// @ingroup VELIB_VECAN_REG
/// @defgroup VELIB_VECAN_REG_SCB Skylla-i Control Board Vregs
/*
 * VE_REG_TST_TST_EXEC_CMD	- 0xEE7D
 *
 *	un16 command
 */
#define VE_REG_SCB_TST_CMD_INIT_CAL			0xF000 //Initialise factory calibration (reset to defaults)
#define VE_REG_SCB_TST_CMD_RELEASE			0xEF00 //Release set-points to application
#define VE_REG_SCB_TST_CMD_SET_RELAY		0xEE00 //LOW BYTE: 0=OFF, 1=ON
#define VE_REG_SCB_TST_CMD_SET_LEDS			0xED00 //LOW BYTE: 0=OFF, 1=ON (all)
#define VE_REG_SCB_TST_CMD_SET_DISPLAY		0xED00 //LOW BYTE: 0=OFF, 1=ON (all)
#define VE_REG_SCB_TST_CMD_SET_BUZZER		0xEC00 //LOW BYTE: 0=OFF, 1=ON
#define VE_REG_SCB_TST_CMD_SET_FAN			0xEB00 //LOW BYTE: SPEED (0=OFF)
#define VE_REG_SCB_TST_CMD_SET_ISET			0xEA00 //LOW BYTE: VALUE (0=OFF)
#define VE_REG_SCB_TST_CMD_SET_BACKLIGHT	0xE900 //LOW BYTE: 0=OFF, 1=ON
#define VE_REG_SCB_TST_CMD_SET_VSET			0xE800 //LOW BYTE: VALUE (0=OFF)
#define VE_REG_SCB_TST_CMD_SET_REM			0xE700 //LOW BYTE: VALUE (0=OFF)
/// @}

/// @ingroup VELIB_VECAN_REG
/// @defgroup VELIB_VECAN_REG_PPP Peak Power Pack Vregs
/// @{
/*
* VE_REG_TST_TST_EXEC_CMD	- 0xEE7D
*
*	un8 command, payload depends on command
*/
#define VE_REG_PPP_TST_CMD_INIT_CAL				0xF000	// Initialise factory calibration (reset to defaults)
#define VE_REG_PPP_TST_CMD_RELEASE				0xEF00	// Store calibration to flash -> no payload
#define VE_REG_PPP_TST_CMD_SET_CHARGE_DISABLE	0xEE00	// LSB: 0:charge enable, 1:charge disable
#define VE_REG_PPP_TST_CMD_SET_LED				0xED00	// LSB: 0:off, 1:blue, 2:red
#define VE_REG_PPP_TST_CMD_SET_MOVER			0xEC00	// LSB: 0:off, 1:on
#define VE_REG_PPP_TST_CMD_SET_COMFORT			0xEB00	// LSB: 0:off, 1:on
#define VE_REG_PPP_TST_CMD_CLEAR_STATS			0xEA00	// Clear stats -> no payload
/// @}

/// @ingroup VELIB_VECAN_REG
/// @defgroup VELIB_VECAN_REG_SRP Skylla-i Remote Panel Vregs
/*
 * VE_REG_TST_TST_EXEC_CMD	- 0xEE7D
 *
 *	un16 command
 */
#define VE_REG_SRP_TST_CMD_RELEASE			0xEF00 //Release set-points to application
#define VE_REG_SRP_TST_CMD_SET_LEDS			0xED00 //LOW BYTE: 0=OFF, 1=ON (all)
#define VE_REG_SRP_TST_CMD_SET_DISPLAY		0xEC00 //LOW BYTE: 0=OFF, 1=ON
/// @}

/// @ingroup VELIB_VECAN_REG
/// @defgroup VELIB_VECAN_REG_MPPT Blue Solar MPPT Vregs
/// @{
/*
 * VE_REG_TST_TST_EXEC_CMD	- 0xEE7D
 *
 *	un16 command
 */
#define VE_REG_MPPT_TST_CMD_INIT_CAL		0xF000 //Initialise factory calibration (reset to defaults)
#define VE_REG_MPPT_TST_CMD_RELEASE			0xEF00 //Release set-points to application
#define VE_REG_MPPT_TST_CMD_SET_RELAY		0xEE00 //LOW BYTE: 0=OFF, 1=ON
#define VE_REG_MPPT_TST_CMD_SET_DISPLAY		0xED00 //LOW BYTE: 0=OFF, 1=ON (all)
#define VE_REG_MPPT_TST_CMD_SET_BUZZER		0xEC00 //LOW BYTE: 0=OFF, 1=ON
#define VE_REG_MPPT_TST_CMD_SET_FAN			0xEB00 //LOW BYTE: SPEED (0=OFF)
#define VE_REG_MPPT_TST_CMD_SET_PWM1		0xEA00 //LOW BYTE: VALUE (0=OFF)
#define VE_REG_MPPT_TST_CMD_SET_BACKLIGHT	0xE900 //LOW BYTE: 0=OFF, 1=ON
#define VE_REG_MPPT_TST_CMD_SET_PWM2		0xE800 //LOW BYTE: VALUE (0=OFF)
#define VE_REG_MPPT_TST_CMD_SET_MODE		0xE700 //LOW BYTE: VALUE (0=DISCONTINUOUS,1=CONTINUOUS)
#define VE_REG_MPPT_TST_CMD_SET_PVSHORT		0xE600 //LOW BYTE: VALUE (0=OPEN,1=SHORT)
#define VE_REG_MPPT_TST_CMD_SET_REVERSE		0xE500 //LOW BYTE: VALUE (0=OPEN,1=SHORT)
#define VE_REG_MPPT_TST_CMD_SET_LUMETER		0xE400 //LOW BYTE: VALUE (0=ON,1=OFF)
/// @}

/*
 * VE_REG_BPC_LED_STATE	- 0xE000
 *
 * un32 led state
 *
 * To get the led value: (value >> VE_REG_BPC_LED_POS_xxx) & VE_REG_BPC_LED_VALUE_MASK
 */
#define VE_REG_BPC_LED_VALUE_OFF				0
#define VE_REG_BPC_LED_VALUE_ON					1
#define VE_REG_BPC_LED_VALUE_BLINK				2
#define VE_REG_BPC_LED_VALUE_BLINK_INVERTED		3
#define VE_REG_BPC_LED_VALUE_INVALID			7
#define VE_REG_BPC_LED_VALUE_MASK				7

#define VE_REG_BPC_LED_POS_TEST					0
#define VE_REG_BPC_LED_POS_BULK					3
#define VE_REG_BPC_LED_POS_ABS					6
#define VE_REG_BPC_LED_POS_FLOAT				9
#define VE_REG_BPC_LED_POS_STORAGE				12
#define VE_REG_BPC_LED_POS_NORMAL				15
#define VE_REG_BPC_LED_POS_HIGH					18
#define VE_REG_BPC_LED_POS_RECON				21
#define VE_REG_BPC_LED_POS_LI_ION				23

/*
 * VE_REG_TST_TST_EXEC_CMD	- 0xEE7D
 *
 *	un16 command
 */
#define VE_REG_BPC_TST_CMD_INIT_CAL			0xF000 //Initialise factory calibration (reset to defaults)
#define VE_REG_BPC_TST_CMD_RELEASE			0xEF00 //Release set-points to application
#define VE_REG_BPC_TST_CMD_SET_RELAY		0xEE00 //LOW BYTE: 0=OFF, 1=ON
#define VE_REG_BPC_TST_CMD_SET_LED			0xED00 //LOW BYTE: 0=OFF, 1=Led0, 2=Led1, etc
#define VE_REG_BPC_TST_CMD_SET_SUPPLY_ON	0xEC00 //LOW BYTE: 0=Supply off, 1=Supply on
#define VE_REG_BPC_TST_CMD_SET_SHUTDOWN		0xEB00 //LOW BYTE: 0=Converter on, 1=Converter off
#define VE_REG_BPC_TST_CMD_SET_3V3			0xEA00 //LOW BYTE: 0=3V3 off, 1=3V3 on
#define VE_REG_BPC_TST_CMD_SET_5V			0xE900 //LOW BYTE: 0=5V off, 1=5V on
#define VE_REG_BPC_TST_CMD_SET_VREF			0xE800 //LOW BYTE: 0=VREF off, 1=VREF on

/*
 * VE_REG_TST_TST_EXEC_CMD	- 0xEE7D
 *
 *	un16 command
 */
#define VE_REG_BPR_TST_CMD_INIT_CAL			0xF000 //Initialise factory calibration (reset to defaults)
#define VE_REG_BPR_TST_CMD_RELEASE			0xEF00 //Release set-points to application
#define VE_REG_BPR_TST_CMD_SET_DISPLAY			0xEE00 //LOW BYTE: bitmask of segs + dp (0=OFF, 1=ON), SEGA..SEGG = bit[0..6], DP = bit 7
#define VE_REG_BPR_TST_CMD_SET_CHARGE_PUMPS		0xED00 //LOW BYTE: 0=OFF, 1=ON (both)
#define VE_REG_BPR_TST_CMD_SET_ALARM			0xEC00 //LOW BYTE: 0=OFF, 1=ON
#define VE_REG_BPR_TST_CMD_GENERATE_PULSE		0xEB00 //Generate Pulse to release Short Circuit state
#define VE_REG_BPR_TST_CMD_SET_LED			0xEA00 //LOW BYTE: 0=OFF, 1=Led0, 2=Led1, etc

/*
 * VE_REG_TST_TST_EXEC_CMD	- 0xEE7D (Smart BMS)
 *
 *	un16 command
 */
#define VE_REG_SMART_BMS_TST_CMD_INIT_CAL				0xF000 //Initialise factory calibration (reset to defaults)
#define VE_REG_SMART_BMS_TST_CMD_RELEASE				0xEF00 //Release set-points to application
#define VE_REG_SMART_BMS_TST_CMD_SET_OUTPUT				0xEE00 //Set output on. LOW BYTE: bit0=Output1, bit1=Output2, etc
#define VE_REG_SMART_BMS_TST_CMD_CLEAR_OUTPUT			0xED00 //Set output off LOW BYTE: bit0=Output1, bit1=Output2, etc
#define VE_REG_SMART_BMS_TST_CMD_SET_VICHARGE_ZERO		0xEC00 //Set Charge Current Voltage for Icharge=0A.
#define VE_REG_SMART_BMS_TST_CMD_CLEAR_LED				0xEB00 //Set LED off, bit0=Led0, bit1=Led1, etc
#define VE_REG_SMART_BMS_TST_CMD_SET_LED				0xEA00 //Set LED on, bit0=Led0, bit1=Led1, etc
#define VE_REG_SMART_BMS_TST_CMD_GENERATE_PULSE			0xE900 //Generate Pulse

/*
 * VE_REG_TST_TST_EXEC_CMD	- 0xEE7D
 *
 *   un16 command
 *
 * LED TEST COMMANDS FOR PHOENIX_INVERTER, red, yellow and green commands can be ORed *
 *	(un16)command = (un16) ((0xED << 8) & (patternRed<<4) & (patternYellow<<2) & patternGreen)
 *  pattern (2bit per LED): 0=normal, 1=blink, 2=off, 3=on *
 *  patterns can be OR-ed, eg 0xED11 = blinking red and green led
 *
 * LOOP-OPTIONS TEST COMMANDS FOR PHOENIX_INVERTER
 * (un16)command = (0xEE << 8) & ((Set ? 1 : 0) << 4) & loopOption
 * loopOption: 0x0=Close loop, 0xB=Feedback on RMS
 *
 * ADC LOWPASSFILTER TEST COMMANDS FOR PHOENIX_INVERTER
 * 1st order lowpass-filter reduces noise in the measurments adcUinvHarm1 and adcIinvHarm1
 * (un16) command  = 0xEF00 &  (0xF & filterSpeed)
 * So 0 <= filterSpeed <= 15 *
 * filterSpeed = 0 disable the filters
 * RCtime = 2^filterSpeed * 20ms (or 16ms)
 * A measurement amplitude stepsize over 2*filterSpeed is not filtered
 * */
#define VE_REG_INV_TST_CMD_SET_LED_NORMAL		0xED00 // sdsdsd
#define VE_REG_INV_TST_CMD_SET_LED_GREEN_BLINK	0xED01
#define VE_REG_INV_TST_CMD_SET_LED_GREEN_OFF	0xED02
#define VE_REG_INV_TST_CMD_SET_LED_GREEN_ON		0xED03
#define VE_REG_INV_TST_CMD_SET_LED_YELLOW_BLINK	0xED04
#define VE_REG_INV_TST_CMD_SET_LED_YELLOW_OFF	0xED08
#define VE_REG_INV_TST_CMD_SET_LED_YELLOW_ON	0xED0C
#define VE_REG_INV_TST_CMD_SET_LED_RED_BLINK	0xED10
#define VE_REG_INV_TST_CMD_SET_LED_RED_OFF		0xED20
#define VE_REG_INV_TST_CMD_SET_LED_RED_ON		0xED30

#define VE_REG_INV_TST_CMD_CLEAR_LOOP_CLOSED	0xEE00
#define VE_REG_INV_TST_CMD_CLEAR_LOOP_RMS		0xEE0B
#define VE_REG_INV_TST_CMD_SET_LOOP_CLOSED		0xEE10
#define VE_REG_INV_TST_CMD_SET_LOOP_RMS			0xEE1B

#define VE_REG_INV_TST_CMD_CAL_LOWPASS_ADC		0xEF00
#define VE_REG_INV_TST_CMD_CAL_LOWPASS_ADC_MASK 0x000F


/*
 * VE_REG_TST_TST_EXEC_CMD	- 0xEE7D
 *
 *	un16 command
 *
 * SmartBatterySense
 */
#define VE_REG_SBS_TST_CMD_INIT_CAL           0xF000 //Initialise factory calibration (reset to defaults)
#define VE_REG_SBS_TST_CMD_RELEASE            0xEF00 //Release set-points to application (store in flash)
#define VE_REG_SBS_TST_CMD_SET_LEDS           0xED00 //LOW BYTE: bitmask of led array (0=OFF, 1=ON), BLUE=0x01, RED=0x02
#define VE_REG_SBS_TST_CMD_SWITCH_REF         0xEC00 //Switch Reference Voltage supply. LOW BYTE: 0x00=OFF, 0x01=ON


/*
 * VE_REG_TST_TST_EXEC_CMD	- 0xEE7D
 *
 *	un16 command
 *
 * OrionSmart
 */
#define VE_REG_ORION_TST_CMD_INIT_CAL		0xF000 //Initialise factory calibration (reset to defaults)
#define VE_REG_ORION_TST_CMD_RELEASE		0xEF00 //Release set-points to application
#define VE_REG_ORION_TST_CMD_SET_LED		0xEE00 //LOW BYTE: 0=OFF, 1=Led0, 2=Led1
#define VE_REG_ORION_TST_CMD_SET_STANDBY	0xED00 //LOW BYTE: 0=Standby off, 1=Standby on
#define VE_REG_ORION_TST_CMD_SET_SHUTDOWN	0xEC00 //LOW BYTE: 0=Converter on, 1=Converter off
#define VE_REG_ORION_TST_CMD_SET_OUTPUT_5V	0xEB00 //LOW BYTE: 0=Output +5V off, 1=Output +5V off


/*
 * VE_REG_TST_TST_EXEC_CMD	- 0xEE7D (Smart BMV (All-In-1))
 *
 *	un16 command
 */
#define VE_REG_SMART_BMV_TST_CMD_INIT_CAL		0xF000  //Initialise factory calibration (reset to defaults)
#define VE_REG_SMART_BMV_TST_CMD_SET_OUTPUT		0xEF00  //Set output on. LOW BYTE: bit0=Output1, bit1=Output2, etc
#define VE_REG_SMART_BMV_TST_CMD_CLEAR_OUTPUT	0xEE00  //Set output off LOW BYTE: bit0=Output1, bit1=Output2, etc


/*
 * VE_REG_MULTIC_2WIRE_BMS - 0xD01F
 * un8 flags
 */
#define VE_REG_MULTIC_2WIRE_BMS_INPUT_ENABLED			(1ul << 0) //User configuration: '1' in case the user connects a 2-wire bms to the unit
#define VE_REG_MULTIC_2WIRE_BMS_ALLOW_TO_DISCHARGE		(1ul << 1)
#define VE_REG_MULTIC_2WIRE_BMS_ALLOW_TO_CHARGE			(1ul << 2)

/*
 * VE_REG_LYNX_ION_FLAGS - 0x0370
 * un32 flags
 */
#define VE_VDATA_ION_FLG_CHARGED						(1ul << 0)
#define VE_VDATA_ION_FLG_ALMOST_CHARGED					(1ul << 1)
#define VE_VDATA_ION_FLG_DISCHARGED						(1ul << 2)
#define VE_VDATA_ION_FLG_ALMOST_DISCHARGED				(1ul << 3)
#define VE_VDATA_ION_FLG_CHARGING						(1ul << 4)
#define VE_VDATA_ION_FLG_DISCHARGING					(1ul << 5)
#define VE_VDATA_ION_FLG_BALANCING						(1ul << 6)
#define VE_VDATA_ION_FLG_RELAY_DISCHARGED				(1ul << 7)
#define VE_VDATA_ION_FLG_RELAY_CHARGED					(1ul << 8)
#define VE_VDATA_ION_FLG_ALRM_OVER_VOLTAGE				(1ul << 9)
#define VE_VDATA_ION_FLG_WARN_OVER_VOLTAGE				(1ul << 10)
#define VE_VDATA_ION_FLG_ALRM_UNDER_VOLTAGE				(1ul << 11)
#define VE_VDATA_ION_FLG_WARN_UNDER_VOLTAGE				(1ul << 12)
#define VE_VDATA_ION_FLG_WARN_CHARGE_CURRENT			(1ul << 13)
#define VE_VDATA_ION_FLG_WARN_DISCHARGE_CURRENT			(1ul << 14)
#define VE_VDATA_ION_FLG_ALRM_OVER_TEMPERATURE			(1ul << 15)
#define VE_VDATA_ION_FLG_WARN_OVER_TEMPERATURE			(1ul << 16)
#define VE_VDATA_ION_FLG_WARN_UNDR_TEMPERATURE_CHRG		(1ul << 17)
#define VE_VDATA_ION_FLG_ALRM_UNDR_TEMPERATURE_CHRG		(1ul << 18)
#define VE_VDATA_ION_FLG_WARN_UNDR_TEMPERATURE_DCHRG	(1ul << 19)
#define VE_VDATA_ION_FLG_ALRM_UNDR_TEMPARATURE_DCHRG	(1ul << 20)
#define VE_VDATA_ION_FLG_LOW_SOC						(1ul << 21)

/* Old names, for comaptibility */
#define VE_VDATA_ION_FLG_BALANCE						VE_VDATA_ION_FLG_BALANCING

/*
 * VE_REG_LYNX_ION_BMS_ERROR_FLAGS - 0x0372
 * un32 flags
 */
#define VE_VDATA_ION_BMS_ERROR_NONE						0	/* Note that this is a value, not a bit mask. */
#define VE_VDATA_ION_BMS_ERROR_RESERVED_1				(1ul << 0)
#define VE_VDATA_ION_BMS_ERROR_BAT_INIT					(1ul << 1)
#define VE_VDATA_ION_BMS_ERROR_NO_BAT					(1ul << 2)
#define VE_VDATA_ION_BMS_ERROR_UNKNOWN_PC				(1ul << 3)
#define VE_VDATA_ION_BMS_ERROR_BAT_TYPE					(1ul << 4)
#define VE_VDATA_ION_BMS_ERROR_NR_OF_BAT				(1ul << 5)
#define VE_VDATA_ION_BMS_ERROR_NO_SHUNT_FND				(1ul << 6)
#define VE_VDATA_ION_BMS_ERROR_MEASURE					(1ul << 7)
#define VE_VDATA_ION_BMS_ERROR_CALCULATE				(1ul << 8)
#define VE_VDATA_ION_BMS_ERROR_BAT_NR_SER				(1ul << 9)
#define VE_VDATA_ION_BMS_ERROR_BAT_NR					(1ul << 10)
#define VE_VDATA_ION_BMS_ERROR_HW						(1ul << 11)
#define VE_VDATA_ION_BMS_ERROR_HW_WDT					(1ul << 12)
#define VE_VDATA_ION_BMS_ERROR_OV						(1ul << 13)
#define VE_VDATA_ION_BMS_ERROR_UV						(1ul << 14)
#define VE_VDATA_ION_BMS_ERROR_OTEMP					(1ul << 15)
#define VE_VDATA_ION_BMS_ERROR_UTEMP					(1ul << 16)
#define VE_VDATA_ION_BMS_ERROR_HW_IO_EXPANDER			(1ul << 17)
#define VE_VDATA_ION_BMS_ERROR_STANDBY					(1ul << 18)
#define VE_VDATA_ION_BMS_ERROR_HW_PRE_CHARGE_CHARGE		(1ul << 19)
#define VE_VDATA_ION_BMS_ERROR_HW_CONTACTOR_CHECK		(1ul << 20)
#define VE_VDATA_ION_BMS_ERROR_HW_PRE_CHARGE_DISCHARGE	(1ul << 21)
#define VE_VDATA_ION_BMS_ERROR_HW_ADC_DATA				(1ul << 22)
#define VE_VDATA_ION_BMS_ERROR_SLAVE					(1ul << 23)
#define VE_VDATA_ION_BMS_WARNING_SLAVE_WARNING			(1ul << 24)
#define VE_VDATA_ION_BMS_ERROR_HW_PRE_CHARGE_CONTACTOR	(1ul << 25)
#define VE_VDATA_ION_BMS_ERROR_HW_CONTACTOR				(1ul << 26)
#define VE_VDATA_ION_BMS_WARNING_OUTPUT_OC				(1ul << 27)

/* Old names, for comaptibility */
#define VE_VDATA_ION_BMS_ERROR_HW_CHARGE_PLUG			VE_VDATA_ION_BMS_ERROR_HW_IO_EXPANDER
#define VE_VDATA_ION_BMS_ERROR_HW_CHARGE				VE_VDATA_ION_BMS_ERROR_STANDBY
#define VE_VDATA_ION_BMS_ERROR_HW_DISCHARGE				VE_VDATA_ION_BMS_ERROR_HW_CONTACTOR_CHECK
#define VE_VDATA_ION_BMS_ERROR_SLAVE_WARNING			VE_VDATA_ION_BMS_WARNING_SLAVE_WARNING
#define VE_VDATA_ION_BMS_ERROR_OUTPUT_OC				VE_VDATA_ION_BMS_WARNING_OUTPUT_OC

/*
 * VE_REG_BMS_FLAGS - 0x2100
 *
 * @remark Bit 0-21 maps 1-on-1 on VE_REG_LYNX_ION_FLAGS (0x0370). The
 * Lynx Ion (+ Shunt) has been develop by an external company (MG Electronics).
 * In order to prevent conflicts for bit 22-31 a new register has been
 * defined.
 * un32 flags
 */
#define VE_REG_BMS_FLG_CHARGED						(1ul << 0)
#define VE_REG_BMS_FLG_ALMOST_CHARGED				(1ul << 1)
#define VE_REG_BMS_FLG_DISCHARGED					(1ul << 2)
#define VE_REG_BMS_FLG_ALMOST_DISCHARGED			(1ul << 3)
#define VE_REG_BMS_FLG_CHARGING						(1ul << 4)
#define VE_REG_BMS_FLG_DISCHARGING					(1ul << 5)
#define VE_REG_BMS_FLG_BALANCE						(1ul << 6)
#define VE_REG_BMS_FLG_RELAY_DISCHARGED				(1ul << 7)
#define VE_REG_BMS_FLG_RELAY_CHARGED				(1ul << 8)
#define VE_REG_BMS_FLG_ALRM_OVER_VOLTAGE			(1ul << 9)
#define VE_REG_BMS_FLG_WARN_OVER_VOLTAGE			(1ul << 10)
#define VE_REG_BMS_FLG_ALRM_UNDER_VOLTAGE			(1ul << 11)
#define VE_REG_BMS_FLG_WARN_UNDER_VOLTAGE			(1ul << 12)
#define VE_REG_BMS_FLG_WARN_CHARGE_CURRENT			(1ul << 13)
#define VE_REG_BMS_FLG_WARN_DISCHARGE_CURRENT		(1ul << 14)
#define VE_REG_BMS_FLG_ALRM_OVER_TEMPERATURE		(1ul << 15)
#define VE_REG_BMS_FLG_WARN_OVER_TEMPERATURE		(1ul << 16)
#define VE_REG_BMS_FLG_WARN_UNDR_TEMPERATURE_CHRG	(1ul << 17)
#define VE_REG_BMS_FLG_ALRM_UNDR_TEMPERATURE_CHRG	(1ul << 18)
#define VE_REG_BMS_FLG_WARN_UNDR_TEMPERATURE_DCHRG	(1ul << 19)
#define VE_REG_BMS_FLG_ALRM_UNDR_TEMPARATURE_DCHRG	(1ul << 20)
#define VE_REG_BMS_FLG_LOW_SOC						(1ul << 21)
#define VE_REG_BMS_FLG_ALRM_UNDR_TEMPERATURE		(1ul << 22)
#define VE_REG_BMS_FLG_ALRM_SHORT_CIRCUIT			(1ul << 23)
#define VE_REG_BMS_FLG_ALRM_HARDWARE_FAILURE		(1ul << 24)
#define VE_REG_BMS_FLG_ALLOWED_TO_CHARGE			(1ul << 25)
#define VE_REG_BMS_FLG_ALLOWED_TO_DISCHARGE			(1ul << 26)
#define VE_REG_BMS_FLG_PRE_ALARM					(1ul << 27)	// Pre-alarm active
#define VE_REG_BMS_FLG_WARN_BAD_CONTACTOR			(1ul << 28)
#define VE_REG_BMS_FLG_ALRM_HIGH_CURRENT			(1ul << 29)

/*
 * VE_REG_BMS_ERROR - 0x2101
 * @note Bit 1-27 of VE_REG_LYNX_ION_BMS_ERROR_FLAGS maps to value 1-27 of VE_REG_BMS_ERROR.
 * un8 error
 */
#define VE_VDATA_BMS_ERROR_NONE 					0
#define VE_VDATA_BMS_ERROR_BATTERY_INIT				1
#define VE_VDATA_BMS_ERROR_NO_BATTERY_FOUND			2
#define VE_VDATA_BMS_ERROR_UNKNOWN_PRODUCT			3
#define VE_VDATA_BMS_ERROR_BAT_TYPE					4
#define VE_VDATA_BMS_ERROR_NR_OF_BAT				5
#define VE_VDATA_BMS_ERROR_NO_SHUNT_FND				6
#define VE_VDATA_BMS_ERROR_MEASURE					7
#define VE_VDATA_BMS_ERROR_CALCULATE				8
#define VE_VDATA_BMS_ERROR_BAT_NR_SER				9
#define VE_VDATA_BMS_ERROR_BAT_NR					10
#define VE_VDATA_BMS_ERROR_HARDWARE_FAILURE			11
#define VE_VDATA_BMS_ERROR_WATCHDOG					12
#define VE_VDATA_BMS_ERROR_OVER_VOLTAGE				13
#define VE_VDATA_BMS_ERROR_UNDER_VOLTAGE			14
#define VE_VDATA_BMS_ERROR_OVER_TEMPERATURE			15
#define VE_VDATA_BMS_ERROR_UNDER_TEMPERATURE		16
#define VE_VDATA_BMS_ERROR_IO_EXPANDER				17
#define VE_VDATA_BMS_ERROR_UNDER_CHARGE_STANDBY		18
#define VE_VDATA_BMS_ERROR_RESERVED_19				19
#define VE_VDATA_BMS_ERROR_CONTACTOR_STARTUP		20
#define VE_VDATA_BMS_ERROR_RESERVED_21				21
#define VE_VDATA_BMS_ERROR_ADC_FAILURE				22
#define VE_VDATA_BMS_ERROR_SLAVE_FAILURE			23
#define VE_VDATA_BMS_ERROR_RESERVED_24				24
#define VE_VDATA_BMS_ERROR_PRE_CHARGE				25
#define VE_VDATA_BMS_ERROR_CONTACTOR				26
#define VE_VDATA_BMS_ERROR_RESERVED_27				27
#define VE_VDATA_BMS_ERROR_SLAVE_UPDATE				28
#define VE_VDATA_BMS_ERROR_SLAVE_UPDATE_UNAVAILABLE	29
#define VE_VDATA_BMS_ERROR_CALIBRATION_DATA_LOST_OLD	30 // Deprecated; use #116 instead
#define VE_VDATA_BMS_ERROR_SETTINGS_DATA_INVALID_OLD	31 // Deprecated; use #119 instead
#define VE_VDATA_BMS_ERROR_BMS_CABLE				32 // BMS cable error
#define VE_VDATA_BMS_ERROR_REF_VOLTAGE_FAILURE		33 // Reference voltage failure
#define VE_VDATA_BMS_ERROR_WRONG_SYSTEM_VOLTAGE		34
#define VE_VDATA_BMS_ERROR_PRE_CHARGE_TIMEOUT		35
#define VE_VDATA_BMS_ERROR_ATC_ATD_FAILURE			36
#define VE_VDATA_BMS_ERROR_RESERVED_101				101 // Do not use; taken by Lynx Smart BMS
#define VE_VDATA_BMS_ERROR_RESERVED_102				102 // Do not use; taken by Lynx Smart BMS
#define VE_VDATA_BMS_ERROR_RESERVED_103				103 // Do not use; taken by Lynx Smart BMS
#define VE_VDATA_BMS_ERROR_RESERVED_104				104 // Do not use; taken by Lynx Smart BMS
#define VE_VDATA_BMS_ERROR_RESERVED_105				105 // Do not use; taken by Lynx Smart BMS
#define VE_VDATA_BMS_ERROR_RESERVED_106				106 // Do not use; taken by Lynx Smart BMS
#define VE_VDATA_BMS_ERROR_RESERVED_107				107 // Do not use; taken by Lynx Smart BMS
#define VE_VDATA_BMS_ERROR_RESERVED_108				108 // Do not use; taken by Lynx Smart BMS
#define VE_VDATA_BMS_ERROR_RESERVED_109				109 // Do not use; taken by Lynx Smart BMS
#define VE_VDATA_BMS_ERROR_RESERVED_110				110 // Do not use; taken by Lynx Smart BMS
#define VE_VDATA_BMS_ERROR_RESERVED_111				111 // Do not use; taken by Lynx Smart BMS
#define VE_VDATA_BMS_ERROR_RESERVED_112				112 // Do not use; taken by Lynx Smart BMS
#define VE_VDATA_BMS_ERROR_RESERVED_113				113 // Do not use; taken by Lynx Smart BMS
#define VE_VDATA_BMS_ERROR_CALIBRATION_DATA_LOST	116 // Non-volatile calibration data lost (same as charger error)
#define VE_VDATA_BMS_ERROR_SETTINGS_DATA_INVALID	119 // Non-volatile settings data invalid/corrupted (same as charger error)
#define VE_VDATA_BMS_ERROR_RESERVED_201				201 // Do not use; taken by Lynx Smart BMS
#define VE_VDATA_BMS_ERROR_RESERVED_202				202 // Do not use; taken by Lynx Smart BMS
#define VE_VDATA_BMS_ERROR_RESERVED_203				203 // Do not use; taken by Lynx Smart BMS
#define VE_VDATA_BMS_ERROR_RESERVED_204				204 // Do not use; taken by Lynx Smart BMS
#define VE_VDATA_BMS_ERROR_RESERVED_205				205 // Do not use; taken by Lynx Smart BMS
#define VE_VDATA_BMS_ERROR_RESERVED_206				206 // Do not use; taken by Lynx Smart BMS
#define VE_VDATA_BMS_ERROR_RESERVED_207				207 // Do not use; taken by Lynx Smart BMS
#define VE_VDATA_BMS_ERROR_RESERVED_208				208 // Do not use; taken by Lynx Smart BMS
#define VE_VDATA_BMS_ERROR_RESERVED_209				209 // Do not use; taken by Lynx Smart BMS
#define VE_VDATA_BMS_ERROR_RESERVED_210				210 // Do not use; taken by Lynx Smart BMS
#define VE_VDATA_BMS_ERROR_RESERVED_211				211 // Do not use; taken by Lynx Smart BMS
#define VE_VDATA_BMS_ERROR_RESERVED_212				212 // Do not use; taken by Lynx Smart BMS
#define VE_VDATA_BMS_ERROR_RESERVED_213				213 // Do not use; taken by Lynx Smart BMS
#define VE_VDATA_BMS_ERROR_RESERVED_214				214 // Do not use; taken by Lynx Smart BMS
#define VE_VDATA_BMS_ERROR_RESERVED_215				215 // Do not use; taken by Lynx Smart BMS
#define VE_VDATA_BMS_ERROR_RESERVED_216				216 // Do not use; taken by Lynx Smart BMS
#define VE_VDATA_BMS_ERROR_RESERVED_217				217 // Do not use; taken by Lynx Smart BMS
#define VE_VDATA_BMS_ERROR_RESERVED_218				218 // Do not use; taken by Lynx Smart BMS
#define VE_VDATA_BMS_ERROR_RESERVED_219				219 // Do not use; taken by Lynx Smart BMS
#define VE_VDATA_BMS_ERROR_RESERVED_220				220 // Do not use; taken by Lynx Smart BMS
#define VE_VDATA_BMS_ERROR_RESERVED_221				221 // Do not use; taken by Lynx Smart BMS
#define VE_VDATA_BMS_ERROR_RESERVED_222				222 // Do not use; taken by Lynx Smart BMS
#define VE_VDATA_BMS_ERROR_RESERVED_223				223 // Do not use; taken by Lynx Smart BMS
#define VE_VDATA_BMS_ERROR_RESERVED_224				224 // Do not use; taken by Lynx Smart BMS

/*
 * VE_REG_BMS_SETTINGS - 0x2103
 * un32 settings
 */
#define VE_REG_BMS_SETTING_USE_PRE_ALARM				(1ul << 0)	// 0:pre-alarm not available, 1: use pre-alarm
#define VE_REG_BMS_SETTING_ALARM_CONTINUOUS				(1ul << 1)	// 0:intermittent, 1: continuous
#define VE_REG_BMS_SETTING_FOLLOW_REMOTE				(1ul << 2)	// 0:REMOTE ignored, 1:BMS disabled, when REMOTE is off
#define VE_REG_BMS_SETTING_PREALARM_DCL					(1ul << 3)  // 0:no DCL, 1:DCL is 0A during pre-alarm,
#define VE_REG_BMS_SETTING_ENABLE_DVCC					(1ul << 4)  // 0:DVCC disabled, 1:DVCC enabled

/*
 * VE_REG_BMS_RELAY_MODE - 0x2104
 *
 *	un8 mode
 */
#define VE_REG_BMS_RELAY_MODE_ALARM					0
#define VE_REG_BMS_RELAY_MODE_ALTERNATOR_ATC 		1

/*
 * VE_REG_LYNX_ERROR - 0x2122
 * un8 error
 */
#define VE_VDATA_LYNX_ERROR_NONE 					0
#define VE_VDATA_LYNX_ERROR_BAT_NR_SER				9
#define VE_VDATA_LYNX_ERROR_HARDWARE_FAILURE		11
#define VE_VDATA_LYNX_ERROR_WRONG_SYSTEM_VOLTAGE	34
#define VE_VDATA_LYNX_ERROR_CALIBRATION_DATA_LOST	116 // Non-volatile calibration data lost (same as charger error)
#define VE_VDATA_LYNX_ERROR_SETTINGS_DATA_INVALID	119 // Non-volatile settings data invalid/corrupted (same as charger error)

/*
 * VE_REG_SMART_LITHIUM_ERROR_FLAGS - 0xEC80
 *
 * un32 flags
 */
#define VE_REG_SMART_LITHIUM_ERROR_NONE						0 /* Note that this is a value, not a bit mask. */
#define VE_REG_SMART_LITHIUM_ERROR_BALANCER_FAILURE			(1ul << 0)	// One of the balancers has a critical failure. This is one of the following:
																		// CHARGER_ERROR_CALIBRATION_DATA_LOST, CHARGER_ERROR_REFERENCE_VOLTAGE_FAILURE,
																		// CHARGER_ERROR_TESTER_FAIL
#define VE_REG_SMART_LITHIUM_ERROR_COMM_ERROR				(1ul << 1)	// No data was received from the balancers for a long time
#define VE_REG_SMART_LITHIUM_ERROR_VOLTAGE01_ERROR			(1ul << 2)	// Balancer 0 and 1 got a different voltage (>250mV) for the same cell (#1 of 0..3)
#define VE_REG_SMART_LITHIUM_ERROR_VOLTAGE12_ERROR			(1ul << 3)	// Balancer 1 and 2 got a different voltage (>250mV) for the same cell (#2 of 0..3)
#define VE_REG_SMART_LITHIUM_ERROR_BALANCER0_UPDATE_ERROR	(1ul << 4)	// The update of Balancer 0 failed
#define VE_REG_SMART_LITHIUM_ERROR_BALANCER1_UPDATE_ERROR	(1ul << 5)	// The update of Balancer 1 failed
#define VE_REG_SMART_LITHIUM_ERROR_BALANCER2_UPDATE_ERROR	(1ul << 6)	// The update of Balancer 2 failed
#define VE_REG_SMART_LITHIUM_ERROR_SETTINGS_DATA_INVALID	(1ul << 7)  // The internal storage is corrupted and settings cannot be read
#define VE_REG_SMART_LITHIUM_ERROR_OVERLAPPED_VOLTAGE_ERROR	(1ul << 8)	// There are 2 balancers with a different voltage (>250mV) for the same cell
#define VE_REG_SMART_LITHIUM_ERROR_BALANCER_UPDATE_ERROR	(1ul << 9)	// The update of a balancer failed
#define VE_REG_SMART_LITHIUM_ERROR_WRONG_BALANCER_PRODID	(1ul << 10)  // The balancer reported an unexpected product id

/*
 * VE_REG_BLEP_POWER_MODE - 0x2342
 *
 *	un16 mode
 */
#define VE_REG_BLEP_POWER_MODE_ON                   0x0000
#define VE_REG_BLEP_POWER_MODE_STANDBY              0x0001
#define VE_REG_BLEP_POWER_MODE_UPDATE               0x0002
#define VE_REG_BLEP_POWER_MODE_HIBERNATE            0x0010

/*
 * VE_REG_CAPABILITIES1	- 0x0140
 *
 *	un32 capabilities
 */
#define VE_REG_CAPABILITIES1_HAS_LOAD_OUTPUT		(1ul)
#define VE_REG_CAPABILITIES1_HAS_ROTARY_ENCODER		(1ul << 1)
#define VE_REG_CAPABILITIES1_HAS_HISTORY_SUPPORT	(1ul << 2)
#define VE_REG_CAPABILITIES1_HAS_BATTERYSAFE_MODE	(1ul << 3)
#define VE_REG_CAPABILITIES1_HAS_ADAPTIVE_MODE		(1ul << 4)
#define VE_REG_CAPABILITIES1_HAS_MANUAL_EQUALISE	(1ul << 5)
#define VE_REG_CAPABILITIES1_HAS_AUTO_EQUALISE		(1ul << 6)
#define VE_REG_CAPABILITIES1_HAS_STORAGE_MODE		(1ul << 7)
#define VE_REG_CAPABILITIES1_HAS_REMOTE_ONOFF		(1ul << 8)
#define VE_REG_CAPABILITIES1_HAS_SOLAR_TIMER		(1ul << 9)
#define VE_REG_CAPABILITIES1_HAS_ALT_TX_FUNCTION	(1ul << 10)
#define VE_REG_CAPABILITIES1_HAS_USER_LOAD_SWITCH	(1ul << 11)
#define VE_REG_CAPABILITIES1_HAS_LOAD_CURRENT		(1ul << 12)
#define VE_REG_CAPABILITIES1_HAS_PANEL_CURRENT		(1ul << 13)
#define VE_REG_CAPABILITIES1_HAS_BMS_SUPPORT		(1ul << 14)
#define VE_REG_CAPABILITIES1_HAS_EXTERNAL_CONTROL_SUPPORT (1ul << 15)
#define VE_REG_CAPABILITIES1_HAS_REMOTE_SENSE_SUPPORT (1ul << 16)
#define VE_REG_CAPABILITIES1_HAS_ALARM_RELAY1		(1ul << 17)
#define VE_REG_CAPABILITIES1_HAS_ALT_RX_FUNCTION	(1ul << 18)
#define VE_REG_CAPABILITIES1_HAS_VIRTUAL_LOAD_OUTPUT (1ul << 19)
#define VE_REG_CAPABILITIES1_HAS_VIRTUAL_RELAY		(1ul << 20)
#define VE_REG_CAPABILITIES1_HAS_DISPLAY			(1ul << 21)
#define VE_REG_CAPABILITIES1_HAS_LOW_CURRENT_MODE	(1ul << 22)
#define VE_REG_CAPABILITIES1_HAS_NIGHT_MODE			(1ul << 23)
#define VE_REG_CAPABILITIES1_HAS_LUMETER_SUPPORT	(1ul << 24) // Lumeter=pay-as-you-go solution
#define VE_REG_CAPABILITIES1_HAS_LOAD_AES_MODE		(1ul << 25) // AES=Automatic Energy Selector
#define VE_REG_CAPABILITIES1_HAS_BATTERY_TEST		(1ul << 26)
#define VE_REG_CAPABILITIES1_HAS_PAYGO_SUPPORT		(1ul << 27) // Token library pay-as-you-go solution
#define VE_REG_CAPABILITIES1_HAS_HIBERNATE_MODE		(1ul << 28) // Support of ultra low power mode (possible with reduced wakeup functionality or longer response time)
#define VE_REG_CAPABILITIES1_HAS_AC_OUT_APPARENT_POWER (1ul << 29) // ac load power measurement in VA, also for load sens power threshold setting
#define VE_REG_CAPABILITIES1_HAS_PSU_FUNCTION		(1ul << 30) // Support for VE_REG_FUNCTION_PSU
#define VE_REG_CAPABILITIES1_NEEDS_BATTERY_TO_SHUTDOWN (1ul << 31) // Battery needs to be connected to internal supply before converter can shutdown

//deprecated names:
#define VE_REG_CAPABILITIES1_HAS_HUB1_SUPPORT VE_REG_CAPABILITIES1_HAS_EXTERNAL_CONTROL_SUPPORT
#define VE_REG_CAPABILITIES1_HAS_ESS_SUPPORT VE_REG_CAPABILITIES1_HAS_EXTERNAL_CONTROL_SUPPORT
#define VE_REG_CAPABILITIES1_HAS_PARALLEL_SUPPORT VE_REG_CAPABILITIES1_HAS_REMOTE_SENSE_SUPPORT

/*
 * VE_REG_CAPABILITIES2	- 0x0141
 *
 *	un32 capabilities
 */
#define VE_REG_CAPABILITIES2_HAS_NO_TEXT			(1ul)
#define VE_REG_CAPABILITIES2_HAS_NO_ASYNC_HEX		(1ul << 1)
#define VE_REG_CAPABILITIES2_HAS_NO_HEX				(1ul << 2)
#define VE_REG_CAPABILITIES2_HAS_BUS_ON_OFF			(1ul << 3)

/*
 * VE_REG_CAPABILITIES3	- 0x0142
 *
 *	un32 capabilities
 */
#define VE_REG_CAPABILITIES3_HAS_TUNNEL_SUPPORT		(1ul)

/*
 * VE_REG_CAPABILITIES4	- 0x0143
 *
 *	un32 capabilities
 */
#define VE_REG_CAPABILITIES4_HAS_NO_DEVICE_OFF_MODE		(1ul << 0)
#define VE_REG_CAPABILITIES4_HAS_SYNC_CHARGING_SUPPORT	(1ul << 1)
#define VE_REG_CAPABILITIES4_HAS_MPPT_BOOST_CONVERTER	(1ul << 2)
#define VE_REG_CAPABILITIES4_HAS_AC_CHARGER				(1ul << 3)
#define VE_REG_CAPABILITIES4_HAS_AC_IN_CURRENT			(1ul << 4)
#define VE_REG_CAPABILITIES4_HAS_SYNC_INVERTER_SUPPORT	(1ul << 5)

/*
 * VE_REG_CAPABILITIES5	- 0x0144
 *
 *	un32 BMS capabilities
 */
#define VE_REG_CAPABILITIES5_HAS_PREALARM	(1ul << 0)

/*
 * VE_REG_CAPABILITIES_BLE - 0x0150
 *
 * un32 capabilities
 */
#define VE_REG_CAPABILITIES_BLE_HAS_SUPPORT_FOR_VE_REG_BLE_MODE				(1ul << 0)
#define VE_REG_CAPABILITIES_BLE_BLE_MODE_OFF_IS_PERMANENT					(1ul << 1)
#define VE_REG_CAPABILITIES_BLE_HAS_SUPPORT_FOR_BLE_OFF_RECOVERY_TIME		(1ul << 2)
#define VE_REG_CAPABILITIES_BLE_BLE_OFF_RECOVERY_TIME_ZERO_IS_PERMANENT		(1ul << 3)
#define VE_REG_CAPABILITIES_BLE_HAS_SUPPORT_FOR_VE_REG_SERVICE_MODE			(1ul << 4)
#define VE_REG_CAPABILITIES_BLE_HAS_SUPPORT_FOR_TRENDS						(1ul << 5)
#define VE_REG_CAPABILITIES_BLE_HAS_SUPPORT_FOR_ADVERTISEMENT_KEY			(1ul << 6)

/*
 * VE_REG_REMOTE_MODE - 0xD0C0
 *
 * un8 mode
 */
#define VE_REG_REMOTE_MODE_ON_OFF	0
#define VE_REG_REMOTE_MODE_BMS		1

/*
 * VE_REG_FIRST_USE_SETUP - 0xEF00
 *
 * un16 First-use settings setup status flags
 *
 * Individual settings-setup status flags are device/application specific
 */
#define VE_REG_FIRST_USE_SETUP__SETUP_IS_ACTIVE                         (1 << 0)
/** For BMV and SmartShunt */
#define VE_REG_FIRST_USE_SETUP__SETUP_BATTERY_CAPACITY_IS_ACTIVE        (1 << 1)
#define VE_REG_FIRST_USE_SETUP__SETUP_AUXILIARY_INPUT_IS_ACTIVE         (1 << 2)

/*
 * VE_REG_BAT_TEMPERATURE_SENSE_SOURCE - 0xEE10
 * VE_REG_BAT_VOLTAGE_SENSE_SOURCE - 0xEE11
 *
 * un8 source
 */
#define VE_VDATA_SENSE_SOURCE_CHANNEL_0				0 //Connection through external sense input terminals
#define VE_VDATA_SENSE_SOURCE_CHANNEL_1				1
#define VE_VDATA_SENSE_SOURCE_CHANNEL_2				2
#define VE_VDATA_SENSE_SOURCE_CHANNEL_3				3
#define VE_VDATA_SENSE_SOURCE_ON_BOARD				4 //For instance VE.Bus Smart sensor NRF internal temperature sensor
#define VE_VDATA_SENSE_SOURCE_BLE_NETWORKING		5 //Sensor value received through BLE networking. For instance Smart batteries can broadcast their own temperature and voltage
#define VE_VDATA_SENSE_SOURCE_VEDIRECT				6 //Sensor value received through a VE.Direct interface. Usually set by a GX device.
#define VE_VDATA_SENSE_SOURCE_VECAN					7 //Sensor value received through a VE.CAN interface. Pick-up a broadcast from a GX device or another inverter/charger.
#define VE_VDATA_SENSE_SOURCE_UNKNOWN				0xFF

/*
 * VE_REG_BAT_RE_BULK_METHOD - 0xEE17
 *
 *  un8 method
 */
#define VE_REG_BAT_RE_BULK_METHOD_VOLTAGE			0x00
#define VE_REG_BAT_RE_BULK_METHOD_CONSTANT_CURRENT	0x01

/*
 * VE_REG_BALANCER_STATUS - 0xEA15
 *
 *  un8 status
 */
#define VE_REG_BALANCER_STATUS_UNKNOWN				0
#define VE_REG_BALANCER_STATUS_BALANCED				1
#define VE_REG_BALANCER_STATUS_BALANCING			2
#define VE_REG_BALANCER_STATUS_CELL_IMBALANCE		3

/*
 * VE_REG_BMV_MONITOR_MODE - 0xEEB8
 *
 *  sn16 mode
 */
#define VE_REG_BMV_MONITOR_MODE_SOLAR_CHARGER     -9
#define VE_REG_BMV_MONITOR_MODE_WIND_CHARGER      -8
#define VE_REG_BMV_MONITOR_MODE_SHAFT_CHARGER     -7
#define VE_REG_BMV_MONITOR_MODE_ALTERNATOR        -6
#define VE_REG_BMV_MONITOR_MODE_FUEL_CELL         -5
#define VE_REG_BMV_MONITOR_MODE_WATER_GENERATOR   -4
#define VE_REG_BMV_MONITOR_MODE_DCDC_CHARGER      -3
#define VE_REG_BMV_MONITOR_MODE_AC_CHARGER        -2
#define VE_REG_BMV_MONITOR_MODE_GENERIC_SOURCE    -1
#define VE_REG_BMV_MONITOR_MODE_BATTERY_MONITOR    0
#define VE_REG_BMV_MONITOR_MODE_GENERIC_LOAD       1
#define VE_REG_BMV_MONITOR_MODE_ELECTRIC_DRIVE     2
#define VE_REG_BMV_MONITOR_MODE_FRIDGE             3
#define VE_REG_BMV_MONITOR_MODE_WATER_PUMP         4
#define VE_REG_BMV_MONITOR_MODE_BILGE_PUMP         5
#define VE_REG_BMV_MONITOR_MODE_DC_SYSTEM          6
#define VE_REG_BMV_MONITOR_MODE_INVERTER           7
#define VE_REG_BMV_MONITOR_MODE_WATER_HEATER       8


/*
 * VE_REG_BMV_AUX_INPUT - 0xEEF8
 *
 *  un8 input
 */
#define VE_REG_BMV_AUX_INPUT_AUX_VOLTAGE   0
#define VE_REG_BMV_AUX_INPUT_MID_VOLTAGE   1
#define VE_REG_BMV_AUX_INPUT_TEMPERATURE   2
#define VE_REG_BMV_AUX_INPUT_NONE          3

/*
 * VE_REG_CELLULAR_SIM_STATUS - 0xEC76
 *
 *  un8 pin status
 */
#define VE_REG_CELLULAR_SIM_STATUS_ERROR                     0
#define VE_REG_CELLULAR_SIM_STATUS_READY                     1
#define VE_REG_CELLULAR_SIM_STATUS_PIN_REQUIRED              2
#define VE_REG_CELLULAR_SIM_STATUS_PUK_REQUIRED              3
#define VE_REG_CELLULAR_SIM_STATUS_PIN2_REQUIRED             4
#define VE_REG_CELLULAR_SIM_STATUS_PUK2_REQUIRED             5
#define VE_REG_CELLULAR_SIM_STATUS_PIN_NOT_ACCEPTED          6
#define VE_REG_CELLULAR_SIM_STATUS_PUK_NOT_ACCEPTED          7
#define VE_REG_CELLULAR_SIM_STATUS_PIN2_NOT_ACCEPTED         8
#define VE_REG_CELLULAR_SIM_STATUS_PUK2_NOT_ACCEPTED         9
#define VE_REG_CELLULAR_SIM_STATUS_PIN_INSUFFICIENT_RETRIES  10
#define VE_REG_CELLULAR_SIM_STATUS_PUK_INSUFFICIENT_RETRIES  11
#define VE_REG_CELLULAR_SIM_STATUS_PIN2_INSUFFICIENT_RETRIES 12
#define VE_REG_CELLULAR_SIM_STATUS_PUK2_INSUFFICIENT_RETRIES 13


/// @}

#endif
