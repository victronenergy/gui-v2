#ifndef _VELIB_BASE_COMPILER_H_
#define _VELIB_BASE_COMPILER_H_

/**
 * @ingroup VELIB_BASE
 *
 * @def BASE_COMPILER_MARCRO_NARGS
 *	Set to 1 if variadic defines are support on this compiler, 0 otherwise.
 */

/**
 * @ingroup VELIB_BASE
 * @def _DEFINE_CONCAT(a,b)
 *  Concatenates two defines.
 */

/**
 * @ingroup VELIB_BASE
 * @def BASE_COMPILER_MACRO_REMOVE
 * HACK: Removes single line DEFINES by commenting the line itself.
 *
 * On platform without variadic macros it is not possible to remove for example
 * traces by defining the trace call to nothing, since the arguments remain.
 * However the preparser can be tricked to do so, by letting it concated / twice,
 * and hence the line will be commented, e.g.
 *
 * @code
 * #ifdef DEBUG
 * #define dprintf printf
 * #else
 * #define dprintf BASE_COMPILER_MACRO_REMOVE
 * #endif
 * @endcode
 */

/**
 * @ingroup VELIB_BASE
 * @def VE_EXT
 *  Either extern or extern "C" depending on c / cpp compiler.
 */

#include <velib/base/types.h>
#include <velib/velib_config.h>

#define ARRAY_LENGTH(name)	(sizeof(name)/sizeof(name[0]))

#define __DEFINE_CONCAT(a,b)	a ## b
#define _DEFINE_CONCAT(a,b)		__DEFINE_CONCAT(a,b)

#define __DEFINE_STR(a)			#a
#define _DEFINE_STR(a)			__DEFINE_STR(a)

#ifdef __cplusplus
#define VE_EXT		extern "C"
#if __cplusplus >= 201103L
#define CONSTEXPR constexpr
#else
#define CONSTEXPR
#endif
#else
#define VE_EXT		extern
#define CONSTEXPR
#endif

#ifdef __GNUC__
#define VE_ALWAYS_INLINE	inline __attribute__((always_inline))
#elif defined(__MWERKS__)
/* needs #pragma INLINE to achieve this, use #include <velib/base/always_inline.h> */
#define VE_ALWAYS_INLINE
#else
#define VE_ALWAYS_INLINE	inline
#endif

/* Compiler options
*/

#if	defined(_WIN32) || defined(_UNIX_)

// not relevant for systems with OS
# define CODE

#include <stdarg.h>
/* va_copy is c99 which MSVC does not support */
# if defined(_MSC_VER) && !defined(va_copy)
#  define va_copy(a, b)	{(a) = (b);}
# endif

/* msvc has _stricmp; unix has strcasecmp */
#define BASE_COMPILER_CUSTOM_STRICMP	1

// borland doesn't like it either
# ifdef __BORLANDC__
#  define BASE_COMPILER_MARCRO_NARGS	0
# else
# define BASE_COMPILER_MARCRO_NARGS	1
# endif

#elif defined(__KEIL__)
# define CODE 	code
# define BASE_COMPILER_MARCRO_NARGS	0
# define VE_UNUSED(a)		if (a){}

#elif defined(__C30__)
# define CODE 	code
// @todo
# define BASE_COMPILER_MARCRO_NARGS		1
# define BASE_COMPILER_CUSTOM_STRICMP	1

#elif defined(__XC8)

/* Microchip's XC8 compiler also does not like variadic macro's */
/* It also warns on the BASE_COMPILER_MACRO_REMOVE macro */
# define BASE_COMPILER_MARCRO_NARGS		0

# define VE_CT_ASSERT(x)				_VE_CT_ASSERT(x, __LINE__)
# define _VE_CT_ASSERT(x, y) \
		typedef char __VE_CT_ASSERT(assertion_failed##_, y)[2*!!(x)-1];
# define __VE_CT_ASSERT(x, y)			x##y

# define VE_UNUSED(a)					if (a){}

#elif defined(__HIWARE__)				// Freescale

// Doesn't seem to like variadic defines at all.
# define BASE_COMPILER_MARCRO_NARGS	0

#elif defined(__MWERKS__)				// Freescale

# define BASE_COMPILER_MARCRO_NARGS	1

#elif defined(__GNUC__)				// GNU

# define BASE_COMPILER_MARCRO_NARGS	1

#elif defined(__MSP430__)

# define BASE_COMPILER_MARCRO_NARGS	1

#else

// compiler not recognized, must be defined at higher level
# ifndef CODE
#  define CODE const
# endif

# endif

# ifndef BASE_COMPILER_MARCRO_NARGS
#  define BASE_COMPILER_MARCRO_NARGS	0
# endif

# ifndef BASE_COMPILER_CUSTOM_STRICMP
#  define BASE_COMPILER_CUSTOM_STRICMP	0
# endif

// Keil does not allow variadic defines and can't there be defined away
// in a normal manner. For such case (e.g. traces) the complete statement
// is removed. This only works for single liners ofcourse, like the traces.
// use with care!
# define BASE_COMPILER_MACRO_REMOVE /##/

# ifndef VE_UNUSED
#  define VE_UNUSED(a)	(void)(a)
# endif

/* Compile time assert */
#ifndef VE_CT_ASSERT
# define VE_CT_ASSERT(x)			_VE_CT_ASSERT(x, __LINE__)
# define _VE_CT_ASSERT(x, y)		__VE_CT_ASSERT(x, y)
# define __VE_CT_ASSERT(x, y)		extern char __assert ## y[(x) ? 1 : -1]
#endif

#endif
