#ifndef _VELIB_TYPES_TYPES_H_
#define _VELIB_TYPES_TYPES_H_

#include <velib/base/base.h>
#include <float.h>

/**
 * @ingroup VELIB
 * @defgroup VELIB_TYPES Types
 */

/**
 * @ingroup VELIB_TYPES
 * @defgroup VELIB_TYPES_TYPES Definition of Data Types
 */
/// @{

/// Type mask for types with contain a length as well.
#define VE_TP_MASK				b11100000
/// Mask for the length of the types with contains one.
#define VE_TP_LEN_MASK			(~VE_TP_MASK)
/// Basic type, un8, un16 etc.
#define VE_REGULAR				b00000000
/// Unsigned bit type, lower bits contain it length.
#define VE_BIT					b00100000
/// Signed bit types, lower bits contain it length.
#define VE_SBIT					b01000000
/// Fixed char array, lower bits contain it length.
#define VE_CHARN 				b01100000

/// Maximum supported length of the fixed char array type.
#define VE_CHARN_MAX_LEN		32

/// Used to created CHARn types, not a valid type by itself.
#define VE_CHAR0				(VE_CHAR1-1)
/// Returns the CHARn type.
#define VE_CHARN_SET(n)			(VE_CHAR0+(n))

/// Used to created BITn types, not a valid type by itself.
#define VE_BIT0					(VE_BIT1-1)
/// Maximum supported length of the bits type.
#define	VE_BITN_MAX_LEN			32

/**
 * @brief
 *	Enum to indicate the type of a variable.
 *
 * @details
 *	For now the datatypes are defined from 0-127. The Highest bit is
 *	reserved. The lowest range (0-31) is reserved for basic types, leaving
 *	space for more. (32-63) are the fixed length strings (1-32). Bits are
 *	defined from 64-95 (1-32 bits) and signed bits from 96-127.
 *
 *	The reason to have all the bits type is that CAN-bus message are limited
 *	to 8 bytes and in general developers are forcing their values in there one
 *	way or the other.
 */
typedef enum
{
	VE_UNKNOWN,			///< 0
	VE_UN8,
	VE_SN8,
	VE_UN16,
	VE_SN16,
	VE_UN24,			///< 5
	VE_SN24,
	VE_UN32,
	VE_SN32,
	VE_FLOAT,
	VE_STR,				///< 10
	/*
	 * byte 0: length in bytes (2 + data length in bytes)
	 * byte 1: string type:
	 *   0: UTF-16 (ISO 10646)
	 *   1: latin1 (ISO-8859-1)
	 * non zero ended data follows.
	 */
	VE_STR_N2K,
	/*
	 * See above, but the memory representation is utf8 and zero ended. The bus
	 * representation is either latin1 or utf16 up to length bytes and not zero
	 * ended. Note: Length contains the maximum byte length on the bus!
	 */
	VE_STR_N2K_UTF8,

	VE_TP_RSVD_13,
	VE_TP_RSVD_14,
	VE_TP_RSVD_15,
	VE_TP_RSVD_16,
	VE_TP_RSVD_17,
	VE_TP_RSVD_18,
	VE_TP_RSVD_19,
	VE_TP_RSVD_20,
	VE_TP_RSVD_21,
	VE_TP_RSVD_22,
	VE_TP_RSVD_23,
	VE_TP_RSVD_24,
	VE_TP_RSVD_25,
	VE_TP_RSVD_26,
	VE_TP_RSVD_27,
	VE_TP_RSVD_28,
	VE_TP_RSVD_29,
	VE_TP_RSVD_30,
	VE_BUF,				/* static buffer using a pointer */


	/// 32. Difference between bit and integers (VE_BIT_8 and UN8) is that
	/// the basic types are per definition byte aligned. Bit fields can
	/// cross byte boundaries.
	VE_BIT1,
	VE_BIT2,
	VE_BIT3,
	VE_BIT4,
	VE_BIT5,
	VE_BIT6,
	VE_BIT7,
	VE_BIT8,
	VE_BIT9,
	VE_BIT10,
	VE_BIT11,
	VE_BIT12,
	VE_BIT13,
	VE_BIT14,
	VE_BIT15,
	VE_BIT16,
	VE_BIT17,
	VE_BIT18,
	VE_BIT19,
	VE_BIT20,
	VE_BIT21,
	VE_BIT22,
	VE_BIT23,
	VE_BIT24,
	VE_BIT25,
	VE_BIT26,
	VE_BIT27,
	VE_BIT28,
	VE_BIT29,
	VE_BIT30,
	VE_BIT31,
	VE_BIT32,	///< 63

	/*
	 * These where used by a third party, but not used by Victron itself.
	 * Therefore it is no longer, but reserved in case they are needed
	 * again.
	 */
	VE_SBIT1_UNUSED,	///< 64
	VE_SBIT2_UNUSED,
	VE_SBIT3_UNUSED,
	VE_SBIT4_UNUSED,
	VE_SBIT5_UNUSED,
	VE_SBIT6_UNUSED,
	VE_SBIT7_UNUSED,
	VE_SBIT8_UNUSED,
	VE_SBIT9_UNUSED,
	VE_SBIT10_UNUSED,
	VE_SBIT11_UNUSED,
	VE_SBIT12_UNUSED,
	VE_SBIT13_UNUSED,
	VE_SBIT14_UNUSED,
	VE_SBIT15_UNUSED,
	VE_SBIT16_UNUSED,
	VE_SBIT17_UNUSED,
	VE_SBIT18_UNUSED,
	VE_SBIT19_UNUSED,
	VE_SBIT20_UNUSED,
	VE_SBIT21_UNUSED,
	VE_SBIT22_UNUSED,
	VE_SBIT23_UNUSED,
	VE_SBIT24_UNUSED,
	VE_SBIT25_UNUSED,
	VE_SBIT26_UNUSED,
	VE_SBIT27_UNUSED,
	VE_SBIT28_UNUSED,
	VE_SBIT29_UNUSED,
	VE_SBIT30_UNUSED,
	VE_SBIT31_UNUSED,
	VE_SBIT32_UNUSED,	///< 95

	VE_CHAR1,	///< 96
	VE_CHAR2,
	VE_CHAR3,
	VE_CHAR4,
	VE_CHAR5,
	VE_CHAR6,
	VE_CHAR7,
	VE_CHAR8,
	VE_CHAR9,
	VE_CHAR10,
	VE_CHAR11,
	VE_CHAR12,
	VE_CHAR13,
	VE_CHAR14,
	VE_CHAR15,
	VE_CHAR16,
	VE_CHAR17,
	VE_CHAR18,
	VE_CHAR19,
	VE_CHAR20,
	VE_CHAR21,
	VE_CHAR22,
	VE_CHAR23,
	VE_CHAR24,
	VE_CHAR25,
	VE_CHAR26,
	VE_CHAR27,
	VE_CHAR28,
	VE_CHAR29,
	VE_CHAR30,
	VE_CHAR31,
	VE_CHAR32,	///< 127

	VE_FLOAT_ARRAY,
	VE_HEAP,			/* allocated block */
	VE_HEAP_STR,		/* allocated string */
} VeDataBasicType;

typedef struct
{
	VeDataBasicType		tp;
	un8					len;
} VeDatatype;


/// Structure to hold transforms on signals.
typedef struct
{
	float offset;
	float factor;
} VeScale;

/// Value which can be used to indicate that the un8 doesn't contain valid data.
#define VE_INVALID_UN8		0xFF
/// Value which can be used to indicate that the sn8 doesn't contain valid data.
#define VE_INVALID_SN8		0x7F
/// Value which can be used to indicate that the un16 doesn't contain valid data.
#define VE_INVALID_UN16		0xFFFF
/// Value which can be used to indicate that the sn16 doesn't contain valid data.
#define VE_INVALID_SN16		0x7FFF
/// Value which can be used to indicate that the un24 doesn't contain valid data.
#define VE_INVALID_UN24		0xFFFFFFUL
/// Value which can be used to indicate that the sn24 doesn't contain valid data.
#define VE_INVALID_SN24		0x7FFFFFL
/// Value which can be used to indicate that the un32 doesn't contain valid data.
#define VE_INVALID_UN32		0xFFFFFFFFUL
/// Value which can be used to indicate that the sn32 doesn't contain valid data.
#define VE_INVALID_SN32		0x7FFFFFFFL
/// Value which can be used to indicate that the ptr doesn't contain valid data.
#define VE_INVALID_PTR		NULL

/// Sets a un8 to reserved value to indicate no valid data.
#define invalidateUN8(a)	((a)=VE_INVALID_UN8)
/// Checks if a un8 contains valid data.
#define validUN8(a)			((a)!=VE_INVALID_UN8)

/// Sets a sn8 to reserved value to indicate no valid data.
#define invalidateSN8(a)	((a)=VE_INVALID_SN8)
/// Checks if a sn8 contains valid data.
#define validSN8(a)			((a)!=VE_INVALID_SN8)

/// Sets a un16 to reserved value to indicate no valid data.
#define invalidateUN16(a) 	((a)=VE_INVALID_UN16)
/// Checks if a un16 contains valid data.
#define validUN16(a)		((a)!=VE_INVALID_UN16)

/// Sets a sn16 to reserved value to indicate no valid data.
#define invalidateSN16(a)	((a)=VE_INVALID_SN16)
/// Checks if a sn16 contains valid data.
#define validSN16(a)		((a)!=VE_INVALID_SN16)

/// Sets a un24 to reserved value to indicate no valid data.
#define invalidateUN24(a)	((a)=VE_INVALID_UN24)
/// Checks if a un32 contains valid data.
#define validUN24(a)		((a)!=VE_INVALID_UN24)

/// Sets a sn24 to reserved value to indicate no valid data.
#define invalidateSN24(a)	((a)=VE_INVALID_SN24)
/// Checks if a sn32 contains valid data.
#define validSN24(a)		((a)!=VE_INVALID_SN24)

/// Sets a un32 to reserved value to indicate no valid data.
#define invalidateUN32(a)	((a)=VE_INVALID_UN32)
/// Checks if a un32 contains valid data.
#define validUN32(a)		((a)!=VE_INVALID_UN32)

/// Sets a sn32 to reserved value to indicate no valid data.
#define invalidateSN32(a)	((a)=VE_INVALID_SN32)
/// Checks if a sn32 contains valid data.
#define validSN32(a)		((a)!=VE_INVALID_SN32)

/// Sets a pointer to reserved value to indicate no valid data.
#define invalidatePtr(a)	((a)=VE_INVALID_PTR)
/// Checks if a pointer contains valid data.
#define validPtr(a)			((a)!=VE_INVALID_PTR)

#if CFG_WITH_FLOAT

/// Union to overlay un32 with float to set / test for NAN.
typedef union
{
	un32 vun32;			///< value as un32.
	float vfloat;		///< value as float.
} VeTypesUn32Float;

/// Quiet NAN (might be Endian specific)
#define VE_INVALID_FLOAT 	0x7FC00000L

/// Forces a float to become a QNAN
#define invalidateFloat(a) 	(((VeTypesUn32Float*)&(a))->vun32=VE_INVALID_FLOAT)

/// @def validFloat		test for valid float.
#if defined(_UNIX_)	|| defined(__C51__) || defined(__ARM_EABI__)
#define validFloat(a) 		(!isnan(a))
#elif defined(__C30__) || defined(__C166__) || defined(__MWERKS__) || defined(__MSP430__)
#define validFloat(a) 		(!(((VeTypesUn32Float*)&(a))->vun32==(un32)VE_INVALID_FLOAT))
#elif defined(_WIN32)
#define validFloat(a) 		(!_isnan(a))
#else
#error NoisNAN
#endif

#endif

/// Value which can be used to indicate that the un8 is out of range.
#define VE_OUT_OF_RANGE_UN8		0xFE
/// Value which can be used to indicate that the sn8 is out of range.
#define VE_OUT_OF_RANGE_SN8		0x7E
/// Value which can be used to indicate that the un16 is out of range.
#define VE_OUT_OF_RANGE_UN16	0xFFFE
/// Value which can be used to indicate that the sn16 is out of range.
#define VE_OUT_OF_RANGE_SN16	0x7FFE
/// Ealue which can be used to indicate that the un32 is out of range.
#define VE_OUT_OF_RANGE_UN32	0xFFFFFFFE
/// Value which can be used to indicate that the sn32 is out of range.
#define VE_OUT_OF_RANGE_SN32	0x7FFFFFFE

/// Sets a un8 to reserved value to indicate it is out of range.
#define setOutOfRangeUN8(a)		((a)=VE_OUT_OF_RANGE_UN8)
/// Checks if a un8 is out of range.
#define isOutOfRangeUN8(a)		((a)==VE_OUT_OF_RANGE_UN8)

/// Sets a sn8 to reserved value to indicate it is out of range.
#define setOutOfRangeSN8(a)		((a)=VE_OUT_OF_RANGE_SN8)
/// Checks if a sn8 is out of range.
#define isOutOfRangeSN8(a)		((a)==VE_OUT_OF_RANGE_SN8)

/// Sets a un16 to reserved value to indicate it is out of range.
#define setOutOfRangeUN16(a) 	((a)=VE_OUT_OF_RANGE_UN16)
/// Checks if a un16 is out of range.
#define isOutOfRangeUN16(a)		((a)==VE_OUT_OF_RANGE_UN16)

/// Sets a sn16 to reserved value to indicate it is out of range.
#define setOutOfRangeSN16(a)	((a)=VE_OUT_OF_RANGE_SN16)
/// Checks if a sn16 is is out of range.
#define isOutOfRangeSN16(a)		((a)==VE_OUT_OF_RANGE_SN16)

/// Sets a un32 to reserved value to indicate it is out of range.
#define setOutOfRangeUN32(a)	((a)=VE_OUT_OF_RANGE_UN32)
/// Checks if a un32 is out of range.
#define isOutOfRangeUN32(a)		((a)==VE_OUT_OF_RANGE_UN32)

/// Sets a sn32 to reserved value to indicate it is out of range.
#define setOutOfRangeSN32(a)	((a)=VE_OUT_OF_RANGE_SN32)
/// Checks if a sn32 is out of range.
#define isOutOfRangeSN32(a)		((a)==VE_OUT_OF_RANGE_SN32)

/// @}

#endif
