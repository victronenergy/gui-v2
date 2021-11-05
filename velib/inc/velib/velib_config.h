#ifndef _VELIB_VELIB_CONFIG_H_
#define _VELIB_VELIB_CONFIG_H_

/**
 * Every project which directly links against (parts of) velib must have a
 * velib_config.h. This file should only contain defines, no code..
 *
 * This file set some defaults to ease initial compilation and provide an
 * overview / documentation of available options.
 */

// Number which should be bumped whenever (code) changes are made to the library.
// Add a description of the changes to CHANGELOG.md with the new number.
#define VELIB_TRACKING_NR	11

/// This file must exists as part of the final application of library being build.
#include <velib/velib_config_app.h>

#if !defined(VELIB_EXPECTED_TRACKING_NR) || VELIB_EXPECTED_TRACKING_NR != VELIB_TRACKING_NR
#error it is time to read CHANGELOG.md
#endif

#ifdef __cplusplus

#ifndef VE_API
#define VE_API	extern "C"
#endif

#ifndef VE_DCL
#define VE_DCL	extern "C"
#endif

#else

/// Declaration used for shared calls, e.g. __declspec(dllexport) and friends.
#ifndef VE_API
#define VE_API
#endif

/// Normal declaration of function. Functions can be made visible to e.g. cpp
#ifndef VE_DCL
#define VE_DCL
#endif

#endif

/*
 * Group defines just to ease configurations if there is no need to squeeze
 * out every bytes. The bloated #ifdef is to prevent warnings on codewarrior.
 */
#ifdef CFG_WITH_GROUP_VE_STREAM_NMEA2K
# if CFG_WITH_GROUP_VE_STREAM_NMEA2K == 1
#  define CFG_WITH_VE_STREAM					1
#  define CFG_WITH_VE_STREAM_LE					1
#  define CFG_WITH_VE_STREAM_NMEA2K				1
#  define CFG_WITH_VE_STREAM_NMEA2K_UTILS		1
#  ifdef CFG_WITH_VARIANT
#   if CFG_WITH_VARIANT == 1
#    define CFG_WITH_VE_STREAM_VARIANT_LE		1
#    define CFG_WITH_VE_STREAM_VARIANT_LE		1
#   endif
#  endif
# endif
#endif

/* pc targets */
#if defined(CFG_WITH_TASK)
# if CFG_WITH_TASK == 1
/* don't use 100% cpu on pc's */
#  define CFG_UTILS_TODO_ENABLED		1
/* allow debug output */
#  ifndef CFG_WITH_LOG_PROTO
#   define CFG_WITH_LOG					1
#  endif
/* debug output needs formatting */
#  define CFG_WITH_VE_STR				1
/* and timestamping */
#  define CFG_WITH_VE_STAMP				1

#  if CFG_WITH_CANHW_DRIVER_NMEA2K == 1
#   define CFG_WITH_J1939_DEVICE			1
#   define CFG_WITH_J1939_SF_MEM			1
#   define CFG_WITH_FP					1
#   define CFG_WITH_J1939_STACK			1
#   define CFG_WITH_FP_HEAP				1
#   define CFG_N2K_FP_RX_MSGS			0
#   define CFG_N2K_FP_TX_MSGS			0
#   define CFG_WITH_FP_DEF				1
#  endif
# endif
#endif

/**
 * The character encoding routines require istream and ostream functions.
 */
#if defined(CFG_WITH_STRING)
# if CFG_WITH_STRING == 1
#  define CFG_WITH_VE_STREAM					1
#  define CFG_WITH_VE_STREAM_LE					1
# endif
#endif

/**
 * A posix mainloop might use signal handlers for time progress.
 * In a default setup of QT creator gdb will stop whenever a signal
 * is emmited. As a simple workaround sleep is therefore used instead
 * when  CFG_MAIN_NO_SIGNALS is set to 1, to circumvent this.
 */
#ifndef CFG_MAIN_NO_SIGNALS
#define CFG_MAIN_NO_SIGNALS				0
#endif

/* Fast packet support is disabled by default */
#ifndef CFG_WITH_FP
#define CFG_WITH_FP						0
#endif

/// By default low level CANHw are expected to have the same as J1939Sf
#ifndef CFG_CANHW_J1939_COMPATIBLE
#define CFG_CANHW_J1939_COMPATIBLE		1
#endif

// By default there is only one stack
#ifndef CFG_J1939_STACKS
#define CFG_J1939_STACKS				1
#endif

// With one local device
#ifndef CFG_J1939_DEVICES
#define CFG_J1939_DEVICES				1
#endif

/*
 * If there is exactly 1 device, it will be the j1939Device, there is no need
 * to tell which one; having CFG_J1939DEVICE_IS_DEFAULT_DEVICE enable will provide
 * stubs for that, at least for all backwards compatible ones. In case of multiple
 * it is going to be mandatory to specific which device you meant.
 */
#if CFG_J1939_DEVICES == 1
#define CFG_J1939DEVICE_IS_DEFAULT_DEVICE 1
#endif

// Number of incoming single frame CAN messages which can be queued.
// Can be set to 0 if messages are handled directly.
#ifndef CFG_J1939_SF_RX_MSGS
#define CFG_J1939_SF_RX_MSGS			10
#endif

// Number of single frame CAN messages which can be queued for output.
#ifndef CFG_J1939_SF_TX_MSGS
#define CFG_J1939_SF_TX_MSGS			2
#endif

/// The maximum payload size of a fast packet can be set to reduce RAM usage.
/// Fast packets larger then the buffer are simply dropped.
#ifndef CFG_N2K_FP_MSG_SIZE
#define CFG_N2K_FP_MSG_SIZE				223
#endif

/// Number of fast packets for reception if n2k_fp_queue.c is used.
#ifndef CFG_N2K_FP_RX_MSGS
#define CFG_N2K_FP_RX_MSGS				4
#endif

/// Maximum number of fp which can be queued for output (prevent blocking reception)
#ifndef CFG_N2K_FP_TX_MSGS
#define CFG_N2K_FP_TX_MSGS				2
#endif

/// When defined velib_inc_J1939_app.h will be included.
#ifndef CFG_J1939_INC_APP
#define	CFG_J1939_INC_APP				0
#endif

/// Unless specified assertion are disabled.
#ifndef CFG_ASSERT_ENABLED
#define CFG_ASSERT_ENABLED				0
#endif

/**
 * Unless specified otherwise, it is assumed the CAN interface is defined by the
 * application. This way it errors rather hard / early if not explicatly specified
 * which CAN interface is to be used, and not at all if the CAN isn't used.
 */
#ifndef CFG_CANHW_CUSTOM_IMPLEMENTATION
#define CFG_CANHW_CUSTOM_IMPLEMENTATION 1
#endif

/*
 * Since the functions are now present in velib itself as well, change the name
 * of the define to better reflect what it now means.
 */
#if CFG_CANHW_CUSTOM_IMPLEMENTATION == 0
#define CFG_CANHW_FUNCTIONS_ARE_MACROS	1
#endif

/*
 * This serves two purposes. First of all the n2ksend routine will prepare a second
 * messages and send it to the canhw layer. If there is only a single tx buffer this
 * will always be refused.
 *
 * Secondly it is useful for testing since the application can determine when the
 * next fragment is send and therefore fiddle with timeouts etc.
 */
#ifndef CFG_N2K_FP_TX_SEND_SINGLE
#define CFG_N2K_FP_TX_SEND_SINGLE		0
#endif

/* Default compile with floating point support disabled */
#ifndef CFG_VECAN_WITH_FLOAT
#define CFG_VECAN_WITH_FLOAT			0
#endif

#if CFG_VECAN_WITH_FLOAT==0
#define CFG_VECAN_NO_FLOAT				1
#endif

/* Default when there is one device in a product */
#ifndef CFG_UDF_DEVICE
#define CFG_UDF_DEVICE j1939Device
#endif

/*
 * When set to zero, the application doesn't have to provide a
 * veProdSgnSpanCallback. Instead veProdDataChangeEvent should
 * return N2K_CM_PARAM_OUT_OF_RANGE.
 */
#ifndef CFG_PROD_CM_SPAN_CHECK
#define CFG_PROD_CM_SPAN_CHECK			1
#endif

/*
 * By default the CAN function are function declaration, which can be implemented
 * by an application. velib has implemented for for some drivers as well, but
 * prefixed, so multiple drivers can be compiled in a single executable. If only
 * one drivers is used, this define can disable the declaration so defines can be
 * used to call the driver directly.
 */

#ifndef CFG_CANHW_FUNCTIONS_ARE_MACROS
#define CFG_CANHW_FUNCTIONS_ARE_MACROS	0
#endif

/*
 * Some CAN hardware does not have enough queues to run in a polling mode.
 * This config will enable rx interrupts and call veCanRxEvent. The rx queue
 * can be used (see J1939_rx.c) to store the messages. Guarding the j1939SfRxPop,
 * and j1939SfRxFree in the application is enough to make it interrupt safe.
 * Another usage for the rx interrupt is to get the mcu out of sleep mode.
 */
#ifndef CFG_CANHW_RX_INTERRUPT
#define CFG_CANHW_RX_INTERRUPT			0
#endif

/*
 * In general there is no need to run the transmission on interrupt. It might
 * be usefull to get a device out of sleep and can be used if the mainloop
 * has todo allot of blocking work. The later _needs_ protection / CFG_CAN_LOCK,
 * see below.
 */
#ifndef CFG_CANHW_TX_INTERRUPT
#define CFG_CANHW_TX_INTERRUPT			0
#endif
/*
 * See doc/README_interrupts.md. By default a single context is assumed
 * and no need for locking. If only rx runs on interrupt locking can be done
 * in the application. Only if tx runs on interrupt this is required and will
 * make all queues interrupt safe (besides fast packet reception, since that
 * is currently not a valid case to do).
 */
#ifndef CFG_CAN_LOCK
#define CFG_CAN_LOCK					0
#endif

/*
 * Adds timestamp to the messages using the MSG_EXTRA from below.
 * Since this adds 8 bytes overhead to 8 bytes of data it is off
 * by default.
 */
#ifndef CFG_CANHW_STAMP
#define CFG_CANHW_STAMP					0
#endif

#if CFG_CANHW_STAMP
#define CFG_CAN_MSG_EXTRA				1
#endif

/*
 * When defined a field extra of type VeCanMsgExtra is added to
 * each messages. For application specific info VeCanMsgExtra
 * must be defined in vecan_inc_canhw.h. This is not yet added for
 * the RTS/CTS and BAM.
 */
#ifndef CFG_CAN_MSG_EXTRA
#define CFG_CAN_MSG_EXTRA				0
#endif

/*
 * Tracing can be enabled for a target. Since this is target specific it
 * is disabled by default. When enabled it defaults to using printf.
 */
#ifndef CFG_WITH_LOG
#define CFG_WITH_LOG					0
#endif

#if CFG_WITH_LOG == 1
#define CFG_WITH_LOG_PROTO				1
#endif

/*
 * If custom functions are needed for the trace output, defining the
 * folowing macro will keep the prototypes so it can be implemented in
 * the application itself. (And CFG_WITH_LOG must be removed)
 */
#ifndef CFG_WITH_LOG_PROTO
#define CFG_WITH_LOG_PROTO				0
#endif

/*
 * Todo is a simple mechanism for returning early, while there are still
 * things left to be done. In this case a flag is set that it needs to be
 * called again. Defaulting to disabled, since embedded devices can simply
 * spin in their mainloop. On pc you typically want this or for standby modes.
 */
#ifndef CFG_UTILS_TODO_ENABLED
#define CFG_UTILS_TODO_ENABLED			0
#endif

/*
 * For size / speed reason float support is disable by default.
 * When enable variants can also contain floats e.g.
 */
#ifndef CFG_WITH_FLOAT
#define CFG_WITH_FLOAT					0
#endif

/*
 * Allow allocating variants on the heap. This is not commenly used,
 * but is for e.g. useful when accepting arrays from the dbus.
 * Hence it defaults to disabled.
 */
#ifndef CFG_VARIANT_HEAP
#define CFG_VARIANT_HEAP				0
#endif

/*
 * The ACL procedure is the only code that needs sub 50ms timing. By default
 * a spinning software timer is used, since that works everywhere, but uses 100%
 * cpu. Application specific interrupt driven / kernel timers can be used to prevent
 * that. CFG_J1939_VELIB_TIMER_DISABLED must then be set two one to disable the
 * default timer implementation, see J1939_acl.c for details.
 */
#ifndef CFG_J1939_VELIB_TIMER_DISABLED
#define CFG_J1939_VELIB_TIMER_DISABLED	0
#endif

/* Enables network management */
#ifndef CFG_WITH_J1939_NMT
#define CFG_WITH_J1939_NMT				0
#endif

/*
 * The mk2 code can optionally support writing to any assisant variable.
 * This define sets the amount of assistant the code should be aware of.
 */
#ifndef CFG_MK2_ASSISTANT_VARS_COUNT
#define CFG_MK2_ASSISTANT_VARS_COUNT			0
#endif

/* include support to update the mk2 firmware */
#ifndef CFG_WITH_MK2_UPDATE
#define CFG_WITH_MK2_UPDATE				0
#endif

/*
 * VE.Configure settings files need additional information about the system.
 * This information will be stored when CFG_MK2_VSC_SUPPORT is set. Since
 * this normally just wastes memory, it is not enabled by default.
 */
#ifndef CFG_MK2_VSC_SUPPORT
#define CFG_MK2_VSC_SUPPORT						0
#endif

/*
 * The mk2 has the ability to use a single set of vebus commands/responses
 * even though the device themselves might have different implementations.
 * If this option is disabled in the mk2, the interfacing code itself needs
 * to send / understand to correct version. If CFG_MK2_ALLOW_COMPAT_DISABLED
 * is enabled support for these alternative frame definitions is also included.
 * NOTE: the backwards compatible flag CFG_MK2_ALLOW_COMPAT_DISABLED must be
 * cleared when requesting vebus version to properly detect what kind of
 * messages the device sends.
 */
#ifndef CFG_MK2_ALLOW_COMPAT_DISABLED
#define  CFG_MK2_ALLOW_COMPAT_DISABLED			0
#endif

/*
 * When defined the number of supported settings is extended beyond the
 * number of known settings. Be aware that information like units / names /
 * enum values are invalid for the extended settings! Since scale information
 * is retrieved those are valid though.
 */
#ifdef CFG_VEBUS_SETTINGS_COUNT
#endif

/* Enables a fake serial port which connects over the dbus */
#ifndef CFG_WITH_DBUS_SERIAL
#define CFG_WITH_DBUS_SERIAL				0
#endif

/*
 * When defined the value of VeQItemDbus will be set to invalid (and the text
 * to an emptry string) when the associated D-Bus service disappears. The state
 * of the item will be set to Offline, regardless of this define.
 */
#ifndef CFG_DBUS_INVALIDATE_OFFLINE
#define CFG_DBUS_INVALIDATE_OFFLINE			0
#endif

// Important defines are checked by #if and will warn (by a decent preprocessor)

// Configuration which do not really matter are typically checked by ifdef.

#endif
