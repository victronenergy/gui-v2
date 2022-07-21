#ifndef _VELIB_BASE_TYPES_H
#define _VELIB_BASE_TYPES_H

#include <stddef.h>

#include <velib/velib_config.h>

/// A pointer which is NULL, might it that 0 CAN be a valid address on
/// mcu's, especially when using fast addressing modes!
#ifndef NULL
#ifdef __cplusplus
// cplusplus uses 0 as a null pointer and won't errors if (void*) 0 gets
// assinged to a double pointer etc..
#define NULL				0
#else
// (void*) to prevent some compilers from warning assignment makes pointer without a cast.
#define NULL 				 (void*) 0
#endif
#endif

#if defined(__BORLANDC__)
#define _WIN32
#endif

/* Unices
*/
#if defined(__linux__) || defined(__FreeBSD__) || defined(__CYGWIN__) || defined(__APPLE__)
#define _UNIX_

#ifdef __APPLE__
#include <sys/syslimits.h>
#define SHARED_EXT "dylib"
#else
#define SHARED_EXT "so"
#endif

#endif

/*
 * In general these gets upcasted to int or float/double.
 * However not on all compilers used, just undef them
 * and redefine if this fails.
 */
#define F_SN8		"d"
#define F_UN8		"u"
#define F_SN16		"d"
#define F_UN16		"u"
#define F_SN32		"d"
#define F_UN32		"u"
#define F_FLT		"f"
#define F_DBL		"f"
#define F_SZ		"u"

/*
 * GNU always seems to want zu, but mingw might be an exception,
 * since it uses the Windows runtime directly.
 */
#if defined(__GNUC__) && !defined(__MSVCRT__)
# undef F_SZ
# define F_SZ		"zu"
#endif

#if CFG_HAVE_STDINT_H

#include <stdint.h>
typedef uint8_t				veBit;
typedef uint8_t				un8;
typedef int8_t				sn8;
typedef uint16_t			un16;
typedef int16_t				sn16;
typedef uint32_t			un32;
typedef int32_t				sn32;
typedef uint64_t			un64;
typedef int64_t 			sn64;

/*
 * Types can depend on the version of libc. e.g. newlib and glibc differ in
 * long versus int, resulting in numerous warnings about invalid arguments.
 * Therefore use the formatter supplied by the libc.
 */
#include <inttypes.h>
#undef F_SN8
#undef F_UN8
#undef F_SN16
#undef F_UN16
#undef F_SN32
#undef F_UN32
#undef F_SN64
#undef F_UN64

#define F_UN8 PRIu8
#define F_SN8 PRIi8
#define F_UN16 PRIu16
#define F_SN16 PRIi16
#define F_UN32 PRIu32
#define F_SN32 PRIi32
#define F_UN64 PRIu64
#define F_SN64 PRIi64

#elif defined(_WIN32)

#include "windows.h"
#include <math.h> /* might define NAN */

#define VE_LITTLE_ENDIAN	1
typedef unsigned char  		un8;
typedef signed char    		sn8;
typedef unsigned short 		un16;
typedef __int16				sn16;
typedef unsigned int 		un32;
typedef __int32				sn32;
typedef unsigned __int64	un64;
typedef __int64				sn64;

#include <limits.h>
#ifndef INT64_MAX
#define INT64_MAX _I64_MAX
#endif

#elif defined(_UNIX_)

#define VE_LITTLE_ENDIAN	1
#include <stdint.h>
typedef uint8_t  			un8;
typedef signed char		   	sn8;
typedef uint16_t	 		un16;
typedef int16_t				sn16;
typedef uint32_t	 		un32;
typedef int32_t				sn32;
typedef uint64_t	 		un64;
typedef int64_t				sn64;

// 8051 on the Keil compiler
#elif defined(__C51__)

#define VE_LITTLE_ENDIAN	0
typedef bit					veBit;
typedef unsigned char		un8;
typedef signed char			sn8;
typedef unsigned int		un16;
typedef signed int			sn16;
typedef unsigned long		un32;
typedef signed long			sn32;

// 16-bitters, like the C164CI
#elif defined(__C166__)
#define VE_LITTLE_ENDIAN	1
typedef signed char			sn8;
typedef unsigned char		un8;
typedef signed int			sn16;
typedef unsigned int 		un16;
typedef signed long			sn32;
typedef unsigned long		un32;

// XAP core on CSR101x
#elif defined(__XAP)
#define VE_LITTLE_ENDIAN	1
typedef signed char			sn8;
typedef unsigned char		un8;
typedef signed int			sn16;
typedef unsigned int 		un16;
typedef signed long			sn32;
typedef unsigned long		un32;

#elif defined(__C30__) || defined(__XC8)
#define VE_LITTLE_ENDIAN	1
typedef signed char			sn8;
typedef unsigned char		un8;
typedef signed int			sn16;
typedef unsigned int 		un16;
typedef signed long			sn32;
typedef unsigned long		un32;

#elif defined(__HCS08__) || defined(__RS08__)

/// @note Types on a HCS08 are actually compile settings. Do not change those!!!
typedef unsigned char		veBit;
typedef unsigned char		un8;
typedef signed char			sn8;
typedef unsigned int		un16;
typedef signed int			sn16;
typedef unsigned long		un32;
typedef signed long			sn32;

#if defined(__LITTLE_ENDIAN__)
#define VE_LITTLE_ENDIAN	1
#elif defined(__BIG_ENDIAN__)
#define VE_LITTLE_ENDIAN	0
#endif

#elif defined(__MSP430__)
#define VE_LITTLE_ENDIAN	1
typedef signed char			sn8;
typedef unsigned char		un8;
typedef signed int			sn16;
typedef unsigned int 		un16;
typedef signed long			sn32;
typedef unsigned long		un32;

#elif defined(__DOCS__)

/**
 * @ingroup VELIB_BASE
 * @{
 */
/// Defined when values are stored in Little Endian format.
#define VE_LITTLE_ENDIAN	1

typedef something			sn8;			///< signed 8bit value on this platform
typedef something			un8;			///< unsigned 8bit value on this platform
typedef something			sn16;			///< signed 16bit value on this platform
typedef something 			un16;			///< unsigned 16bit value on this platform
typedef something			sn32;			///< signed 32bit value on this platform
typedef something			un32;			///< unsigned 32bit value on this platform

/// @}
#else

#include <velib/velib_inc_types.h>
#ifndef _VELIB_VELIB_INC_TYPES_H_
#error "Platform not recognized, define basic types in velib/velib_inc_types.h and define _VELIB_VELIB_INC_TYPES_H_"
#endif

#endif

#ifndef VE_LITTLE_ENDIAN
#error Endianness not defined
#endif

/// Boolean for c
typedef un8					veBool;
#define veFalse  			0
#define veTrue   			1

#if CFG_WITH_FLOAT
#include <math.h>

#ifndef NAN
#define NAN    ((union { unsigned __l; float __d; })   { __l: 0x7fc00000UL }.__d)
#endif
#endif

#endif
