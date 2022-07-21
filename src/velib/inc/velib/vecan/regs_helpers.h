#ifndef _VELIB_VECAN_REGS_HELPERS_H_
#define _VELIB_VECAN_REGS_HELPERS_H_

/// All errors are above 0x8000.
#define VACK_IS_ERROR(ack)			(ack&0x8000)

/*
 * VE_REG_PRODUCT_ID 0x0100
 *
 *	un8 instance
 *	un16 productId
 *	un8 flags
 *
 * multiple products can be reported by a single node.
 */

#define VE_PROD_ID_FLAGS(f)			( (f) & 0xff)
#define VE_PROD_ID_INSTANCE(i)		( ( (un32)(i) & 0xff) << 24)
#define VE_PROD_ID_PRODUCT_ID(pid) 					\
		( ( ( (un32)(pid)       & 0xff) << 16) | 	\
		( ( ( (un32)(pid) >> 8) & 0xff) <<  8))


// Properties of the device function performing the update e.g. a bootloader.
/// Whether the device can be update.
#define VE_PROD_ID_F_VUP_SUPPORT	0x01
#define VE_PROD_ID_F_RESERVED		0xFE

/*
 * VE_REG_APP_VER 		- 0x0102
 * VE_REG_APP_VER_MIN 	- 0x0103
 *
 *	un8 instance
 *	un24 version
 *
 * multiple versions can be reported by a single node.
 */
#define VREG_APP_VER_INSTANCE(i)	( ( (un32)(i) & 0xff) << 24)
#define VREG_APP_VER_VERSION(v)					\
		( ( ( (un32)(v)        & 0xff) << 16) |	\
		( ( ( (un32)(v) >>  8) & 0xff) <<  8) |	\
		( ( ( (un32)(v) >> 16) & 0xff)      ))


#define VREG_VER_INVALID_VERSION	0xFFFFFF

/*
 * VE_REG_UDF_VERSION	- 0x0110
 *
 *	un24 version
 *	un8 flags
 */

#define VREG_UDF_VER_FLAGS(f)		( (f) & 0xff)
#define VREG_UDF_VER_VERSION(v)					\
		( ( ( (un32)(v)        & 0xff) << 24) |	\
		( ( ( (un32)(v) >>  8) & 0xff) << 16) |	\
		( ( ( (un32)(v) >> 16) & 0xff) <<  8))

#define VREG_UDF_VER_F_RESERVED		0xFE
/// Bootloader active.
#define VREG_UDF_VER_F_ACTIVE		0x01

/** @ingroup VE_REG_ALARM_REASON
 * @defgroup VE_REG_ALARM_REASON_HELPERS
 * @{
 */
#define VE_REG_ALARM_REASON_VOLTAGE				(VE_REG_ALARM_REASON_LOW_VOLTAGE | VE_REG_ALARM_REASON_HIGH_VOLTAGE)
#define VE_REG_ALARM_REASON_VOLTAGE2			(VE_REG_ALARM_REASON_LOW_VOLTAGE2 | VE_REG_ALARM_REASON_HIGH_VOLTAGE2)
#define VE_REG_ALARM_REASON_TEMPERATURE			(VE_REG_ALARM_REASON_LOW_TEMPERATURE | VE_REG_ALARM_REASON_HIGH_TEMPERATURE)
#define VE_REG_ALARM_REASON_V_AC_OUT 			(VE_REG_ALARM_REASON_LOW_V_AC_OUT | VE_REG_ALARM_REASON_HIGH_V_AC_OUT)
/** @} */

#endif

