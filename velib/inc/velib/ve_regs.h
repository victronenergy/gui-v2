#ifndef _VELIB_VE_REGS_H_
#define _VELIB_VE_REGS_H_

#include <velib/types/types.h>
#include <velib/vecan/regs_helpers.h>
#include <velib/vecan/regs_payload.h>

/// @addtogroup VELIB_VECAN_REG
/// @{

/// Register ids are un16
typedef un16 VeRegId;

/*[[[cog import gen_signal_definition ]]]*/
/** only internal! */
#define VE_REG_INVALID 0x0000

/** VREQ {un16 = VReg Requested : un16 = VReg Mask} */
#define VE_REG_REQ 0x0001

/** VACK {un16 = VReg ACKed : un8 = Data : un8 = Code (see xml for meanings)} */
#define VE_REG_ACK 0x0002

/** Ping {stringFixed[4] = payload, returned in the reply} */
#define VE_REG_PING 0x0003

/**
 * Restore user settings
 * This command restores only the user settings to the factory defaults. It does
 * not reset the user history, not reset the factory calibration, and also not
 * reset the service history. For Bluetooth products it does not reset the
 * Bluetooth PIN code, on purpose. And for some products it will not remove a
 * configured custom name, which is OK, though for new products it would (only
 * preferably) remove the custom name. Right now, 2021-04-21, it does *not* reset
 * VE.Smart Networking settings for the Smart Battery Sense, and possible not for
 * other products either, but that is wrong. And will be fixed. Regarding VE.Can,
 * the command does reset all instances, but does *not* reset the network
 * address, since otherwise the sender of the command would never see the
 * acknowledgement.
 * This VREG is used in production, and is used in the field by users, using
 * VictronConnect as well as other UIs.
 */
#define VE_REG_RESTORE_DEFAULT 0x0004

/**
 * Bluetooth Low Energy mode {un8 = mode, 0x00 = BLE disabled, 0x01 = BLE
 * enabled}
 */
#define VE_REG_BLE_MODE 0x0090

/** Bluetooth Low Energy recovery time {un16 = time [1s], 0xFFFF = Not Available} */
#define VE_REG_BLE_OFF_RECOVERY_TIME 0x0091

/**
 * Connectability {un8 = connectable, 0x00 = Connection not allowed, 0x01 =
 * Connection allowed}
 */
#define VE_REG_CONNECTABLE 0x0092

/**
 * Connection keep alive {un16 = Connection keep alive [0.001s]}
 * This is used for example with BLE devices. When this vreg is received by the
 * product for the first time after the start of a connection, a timer is started
 * with the given timeout. If the timer times out, the product drops the
 * connection. So normally the application will keep sending this vreg while it
 * wants to stay connected.
 */
#define VE_REG_CONNECTION_KEEP_ALIVE 0x0093

/**
 * ProductId# {un8 = Identifier : un16 = Product Id (see xml for meanings), Note
 * that the ve.direct mppt chargers report this field incorrectly as an un16 with
 * the product id in big-endian notation : bits[1] = VictronEnergy Update (VUP)
 * support : bits[7] = reserved, 0x7F = reserved}
 */
#define VE_REG_PRODUCT_ID 0x0100

/**
 * Revision# {un8 = Identifier : un16 = Hw revision}
 * Hardware revision Used for identifying hardware changes / incompatibilities.
 * (update related)
 */
#define VE_REG_PRODUCT_REVISION 0x0101

/**
 * Firmware# {un8 = Identifier : un24 = Firmware Version, 0xFFFFFF = no firmware
 * present, Firmware version 0xHHMMLL (HH=high byte, MM=middle byte, LL=low
 * byte). When HH == 0 : 16-bits version number (compatible with old/current
 * designs), LL: minor number, MM: major number, HH: not used (0), string
 * representation: vMM.LL. When HH != 0 : 24-bits version number, LL: revision
 * number (must be 0xFF for a release, this way the release is preferred over
 * test/release candidates when using less/greater than comparisons), MM: minor
 * number, HH: major number (>=1), string representation: vHH.MM (when LL==0xFF),
 * vHH.MM-beta-LL (when LL!=0xFF).}
 */
#define VE_REG_APP_VER 0x0102

/**
 * Minimum Version# {un8 = Identifier : un24 = Firmware Version}
 * Minimum possible firmware version (max downgrade)
 */
#define VE_REG_APP_VER_MIN 0x0103

/**
 * GroupId# {un8 = Group Id (see xml for meanings)}
 * Can be used to group similar devices, eliminating the need for keeping track
 * of various product ids (useful for parallel charging operation).
 */
#define VE_REG_GROUP_ID 0x0104

/**
 * Identify {un8 = Identify, 0 = Off, 1 = On, Write a 1 to this register to
 * enable identify mode. Write a 0 to this register to disable identify mode and
 * return to normal operation.}
 */
#define VE_REG_IDENTIFY 0x010E

/**
 * udf version {un24 = udf version : bits[1] = udf active : bits[7] = reserved,
 * 0x7F = reserved}
 */
#define VE_REG_UDF_VERSION 0x0110

/** Uptime# {un32 = Uptime [1s]} */
#define VE_REG_UPTIME 0x0120

/**
 * Device identification - capabilities1 {bits[1] = Has Load Output, 0 = No, 1 =
 * Yes : bits[1] = Has Rotary Encoder, 0 = No, 1 = Yes : bits[1] = Has History
 * Support, 0 = No, 1 = Yes : bits[1] = Has Batterysafe Mode, 0 = No, 1 = Yes :
 * bits[1] = Has Adaptive Mode, 0 = No, 1 = Yes : bits[1] = Has Manual Equalise,
 * 0 = No, 1 = Yes : bits[1] = Has Auto Equalise, 0 = No, 1 = Yes : bits[1] = Has
 * Storage Mode, 0 = No, 1 = Yes : bits[1] = Has Remote Onoff, 0 = No, 1 = Yes :
 * bits[1] = Has Solar Timer, 0 = No, 1 = Yes : bits[1] = Has Alt Tx Function, 0
 * = No, 1 = Yes : bits[1] = Has User Load Switch, 0 = No, 1 = Yes : bits[1] =
 * Has Load Current, 0 = No, 1 = Yes : bits[1] = Has Panel Current, 0 = No, 1 =
 * Yes : bits[1] = Has Bms Support, 0 = No, 1 = Yes : bits[1] = Has External
 * Control Support, 0 = No, 1 = Yes : bits[1] = Has Remote Sense Support, 0 = No,
 * 1 = Yes : bits[1] = HAS_ALARM_RELAY1, 0 = No, 1 = Yes : bits[1] = Has Alt Rx
 * Function, 0 = No, 1 = Yes : bits[1] = Has Virtual Load Output, 0 = No, 1 = Yes
 * : bits[1] = Has Virtual Relay, 0 = No, 1 = Yes : bits[1] = Has Display, 0 =
 * No, 1 = Yes : bits[1] = Has Low Current Mode, 0 = No, 1 = Yes : bits[1] = Has
 * Night Mode, 0 = No, 1 = Yes : bits[1] = Has Lumeter Support, 0 = No, 1 = Yes :
 * bits[1] = Has Load Aes Mode, 0 = No, 1 = Yes : bits[1] = Has Battery Test, 0 =
 * No, 1 = Yes : bits[1] = Has Paygo Support, 0 = No, 1 = Yes : bits[1] = Has
 * Hibernate Mode, 0 = No, 1 = Yes : bits[1] = Has Ac Out Apparent Power, 0 = No,
 * 1 = Yes : bits[1] = Has Psu Function, 0 = No, 1 = Yes : bits[1] = Needs
 * Battery To Shutdown, 0 = No, 1 = Yes}
 */
#define VE_REG_CAPABILITIES1 0x0140

/**
 * Device identification - capabilities2 {bits[1] = Has No Text, 0 = No, 1 = Yes
 * : bits[1] = Has No Async Hex, 0 = No, 1 = Yes : bits[1] = Has No Hex, 0 = No,
 * 1 = Yes : bits[1] = Has Bus On Off, 0 = No, 1 = Yes : }
 */
#define VE_REG_CAPABILITIES2 0x0141

/**
 * Device identification - capabilities3 {bits[1] = Has Tunnel Support, 0 = No, 1
 * = Yes : }
 */
#define VE_REG_CAPABILITIES3 0x0142

/**
 * Device identification - capabilities4 {bits[1] = Has No Device Off Mode, 0 =
 * No, 1 = Yes : bits[1] = Has Sync Charging Support, 0 = No, 1 = Yes : bits[1] =
 * Has Mppt Boost Converter, 0 = No, 1 = Yes : bits[1] = Has AC Charger, 0 = No,
 * 1 = Yes : bits[1] = Has AC Input Current, 0 = No, 1 = Yes : bits[1] = Has
 * Synchronised Inverter Support, 0 = No, 1 = Yes : }
 */
#define VE_REG_CAPABILITIES4 0x0143

/**
 * Device identification - capabilities5 {bits[1] = Has Prealarm, 0 = No, 1 = Yes
 * : }
 * Capabilities related to BMS functionality
 */
#define VE_REG_CAPABILITIES5 0x0144

/** Device identification - capabilities6 {un32 = , 0 = reserved} */
#define VE_REG_CAPABILITIES6 0x0145

/** Device identification - capabilities7 {un32 = , 0 = reserved} */
#define VE_REG_CAPABILITIES7 0x0146

/** Device identification - capabilities8 {un32 = , 0 = reserved} */
#define VE_REG_CAPABILITIES8 0x0147

/** Device identification - capabilities9 {un32 = , 0 = reserved} */
#define VE_REG_CAPABILITIES9 0x0148

/** Device identification - capabilities10 {un32 = , 0 = reserved} */
#define VE_REG_CAPABILITIES10 0x0149

/** Device identification - capabilities11 {un32 = , 0 = reserved} */
#define VE_REG_CAPABILITIES11 0x014A

/** Device identification - capabilities12 {un32 = , 0 = reserved} */
#define VE_REG_CAPABILITIES12 0x014B

/** Device identification - capabilities13 {un32 = , 0 = reserved} */
#define VE_REG_CAPABILITIES13 0x014C

/** Device identification - capabilities14 {un32 = , 0 = reserved} */
#define VE_REG_CAPABILITIES14 0x014D

/** Device identification - capabilities15 {un32 = , 0 = reserved} */
#define VE_REG_CAPABILITIES15 0x014E

/** Device identification - capabilities16 {un32 = , 0 = reserved} */
#define VE_REG_CAPABILITIES16 0x014F

/**
 * Device identification - capabilities BLE {bits[1] = Has Support For Ve Reg Ble
 * Mode, 0 = No, 1 = Yes : bits[1] = Ble Mode Off Is Permanent, 0 = No, 1 = Yes :
 * bits[1] = Has Support For Ble Off Recovery Time, 0 = No, 1 = Yes : bits[1] =
 * Recovery Time Zero Off Is Permanent, 0 = No, 1 = Yes : bits[1] = Has Support
 * For Ve Reg VE-Reg Service Mode, 0 = No, 1 = Yes : bits[1] = Has Support For
 * Trends, 0 = No, 1 = Yes : }
 * @remark VeReg to be used by VictronConnect to read BLE features supported by a
 * product (single or multi chip). In case of a single chip product this VeReg is
 * published and its value set by the same chip. In case of a 2 chip product (BLE
 * chip and product chip) it shall be the product chip publishing this VeReg;
 * this allows VictronConnect to retrieve this VeReg also via a VE.Direct
 * interface on the product chip. It's value is most likely to be set by the BLE
 * chip.
 */
#define VE_REG_CAPABILITIES_BLE 0x0150

/**
 * Instance 0 Firmware# {un8 = Identifier : un24 = Instance Firmware Version,
 * 0xFFFFFF = no firmware present, Instance Firmware version 0xHHMMLL (HH=high
 * byte, MM=middle byte, LL=low byte).        When HH == 0 : 16-bits version
 * number (compatible with old/current designs),        LL: minor number,
 * MM: major number,        HH: not used (0),        string representation:
 * vMM.LL.        When HH != 0 : 24-bits version number,        LL: revision
 * number (must be 0xFF for a release, this way the release is preferred over
 * test/release candidates when using less/greater than comparisons),        MM:
 * minor number,        HH: major number (>=1),        string representation:
 * vHH.MM (when LL==0xFF), vHH.MM-beta-LL (when LL!=0xFF).}
 */
#define VE_REG_APP_VER_0 0x0160

/**
 * Instance 1 Firmware# {un8 = Identifier : un24 = Instance Firmware Version,
 * 0xFFFFFF = no firmware present, Instance Firmware version 0xHHMMLL (HH=high
 * byte, MM=middle byte, LL=low byte).        When HH == 0 : 16-bits version
 * number (compatible with old/current designs),        LL: minor number,
 * MM: major number,        HH: not used (0),        string representation:
 * vMM.LL.        When HH != 0 : 24-bits version number,        LL: revision
 * number (must be 0xFF for a release, this way the release is preferred over
 * test/release candidates when using less/greater than comparisons),        MM:
 * minor number,        HH: major number (>=1),        string representation:
 * vHH.MM (when LL==0xFF), vHH.MM-beta-LL (when LL!=0xFF).}
 */
#define VE_REG_APP_VER_1 0x0161

/**
 * Instance 2 Firmware# {un8 = Identifier : un24 = Instance Firmware Version,
 * 0xFFFFFF = no firmware present, Instance Firmware version 0xHHMMLL (HH=high
 * byte, MM=middle byte, LL=low byte).        When HH == 0 : 16-bits version
 * number (compatible with old/current designs),        LL: minor number,
 * MM: major number,        HH: not used (0),        string representation:
 * vMM.LL.        When HH != 0 : 24-bits version number,        LL: revision
 * number (must be 0xFF for a release, this way the release is preferred over
 * test/release candidates when using less/greater than comparisons),        MM:
 * minor number,        HH: major number (>=1),        string representation:
 * vHH.MM (when LL==0xFF), vHH.MM-beta-LL (when LL!=0xFF).}
 */
#define VE_REG_APP_VER_2 0x0162

/**
 * Instance 3 Firmware# {un8 = Identifier : un24 = Instance Firmware Version,
 * 0xFFFFFF = no firmware present, Instance Firmware version 0xHHMMLL (HH=high
 * byte, MM=middle byte, LL=low byte).        When HH == 0 : 16-bits version
 * number (compatible with old/current designs),        LL: minor number,
 * MM: major number,        HH: not used (0),        string representation:
 * vMM.LL.        When HH != 0 : 24-bits version number,        LL: revision
 * number (must be 0xFF for a release, this way the release is preferred over
 * test/release candidates when using less/greater than comparisons),        MM:
 * minor number,        HH: major number (>=1),        string representation:
 * vHH.MM (when LL==0xFF), vHH.MM-beta-LL (when LL!=0xFF).}
 */
#define VE_REG_APP_VER_3 0x0163

/**
 * Instance 4 Firmware# {un8 = Identifier : un24 = Instance Firmware Version,
 * 0xFFFFFF = no firmware present, Instance Firmware version 0xHHMMLL (HH=high
 * byte, MM=middle byte, LL=low byte).        When HH == 0 : 16-bits version
 * number (compatible with old/current designs),        LL: minor number,
 * MM: major number,        HH: not used (0),        string representation:
 * vMM.LL.        When HH != 0 : 24-bits version number,        LL: revision
 * number (must be 0xFF for a release, this way the release is preferred over
 * test/release candidates when using less/greater than comparisons),        MM:
 * minor number,        HH: major number (>=1),        string representation:
 * vHH.MM (when LL==0xFF), vHH.MM-beta-LL (when LL!=0xFF).}
 */
#define VE_REG_APP_VER_4 0x0164

/**
 * Instance 5 Firmware# {un8 = Identifier : un24 = Instance Firmware Version,
 * 0xFFFFFF = no firmware present, Instance Firmware version 0xHHMMLL (HH=high
 * byte, MM=middle byte, LL=low byte).        When HH == 0 : 16-bits version
 * number (compatible with old/current designs),        LL: minor number,
 * MM: major number,        HH: not used (0),        string representation:
 * vMM.LL.        When HH != 0 : 24-bits version number,        LL: revision
 * number (must be 0xFF for a release, this way the release is preferred over
 * test/release candidates when using less/greater than comparisons),        MM:
 * minor number,        HH: major number (>=1),        string representation:
 * vHH.MM (when LL==0xFF), vHH.MM-beta-LL (when LL!=0xFF).}
 */
#define VE_REG_APP_VER_5 0x0165

/**
 * Instance 6 Firmware# {un8 = Identifier : un24 = Instance Firmware Version,
 * 0xFFFFFF = no firmware present, Instance Firmware version 0xHHMMLL (HH=high
 * byte, MM=middle byte, LL=low byte).        When HH == 0 : 16-bits version
 * number (compatible with old/current designs),        LL: minor number,
 * MM: major number,        HH: not used (0),        string representation:
 * vMM.LL.        When HH != 0 : 24-bits version number,        LL: revision
 * number (must be 0xFF for a release, this way the release is preferred over
 * test/release candidates when using less/greater than comparisons),        MM:
 * minor number,        HH: major number (>=1),        string representation:
 * vHH.MM (when LL==0xFF), vHH.MM-beta-LL (when LL!=0xFF).}
 */
#define VE_REG_APP_VER_6 0x0166

/**
 * Instance 7 Firmware# {un8 = Identifier : un24 = Instance Firmware Version,
 * 0xFFFFFF = no firmware present, Instance Firmware version 0xHHMMLL (HH=high
 * byte, MM=middle byte, LL=low byte).        When HH == 0 : 16-bits version
 * number (compatible with old/current designs),        LL: minor number,
 * MM: major number,        HH: not used (0),        string representation:
 * vMM.LL.        When HH != 0 : 24-bits version number,        LL: revision
 * number (must be 0xFF for a release, this way the release is preferred over
 * test/release candidates when using less/greater than comparisons),        MM:
 * minor number,        HH: major number (>=1),        string representation:
 * vHH.MM (when LL==0xFF), vHH.MM-beta-LL (when LL!=0xFF).}
 */
#define VE_REG_APP_VER_7 0x0167

/**
 * Instance 8 Firmware# {un8 = Identifier : un24 = Instance Firmware Version,
 * 0xFFFFFF = no firmware present, Instance Firmware version 0xHHMMLL (HH=high
 * byte, MM=middle byte, LL=low byte).        When HH == 0 : 16-bits version
 * number (compatible with old/current designs),        LL: minor number,
 * MM: major number,        HH: not used (0),        string representation:
 * vMM.LL.        When HH != 0 : 24-bits version number,        LL: revision
 * number (must be 0xFF for a release, this way the release is preferred over
 * test/release candidates when using less/greater than comparisons),        MM:
 * minor number,        HH: major number (>=1),        string representation:
 * vHH.MM (when LL==0xFF), vHH.MM-beta-LL (when LL!=0xFF).}
 */
#define VE_REG_APP_VER_8 0x0168

/**
 * Instance 9 Firmware# {un8 = Identifier : un24 = Instance Firmware Version,
 * 0xFFFFFF = no firmware present, Instance Firmware version 0xHHMMLL (HH=high
 * byte, MM=middle byte, LL=low byte).        When HH == 0 : 16-bits version
 * number (compatible with old/current designs),        LL: minor number,
 * MM: major number,        HH: not used (0),        string representation:
 * vMM.LL.        When HH != 0 : 24-bits version number,        LL: revision
 * number (must be 0xFF for a release, this way the release is preferred over
 * test/release candidates when using less/greater than comparisons),        MM:
 * minor number,        HH: major number (>=1),        string representation:
 * vHH.MM (when LL==0xFF), vHH.MM-beta-LL (when LL!=0xFF).}
 */
#define VE_REG_APP_VER_9 0x0169

/**
 * Instance 10 Firmware# {un8 = Identifier : un24 = Instance Firmware Version,
 * 0xFFFFFF = no firmware present, Instance Firmware version 0xHHMMLL (HH=high
 * byte, MM=middle byte, LL=low byte).        When HH == 0 : 16-bits version
 * number (compatible with old/current designs),        LL: minor number,
 * MM: major number,        HH: not used (0),        string representation:
 * vMM.LL.        When HH != 0 : 24-bits version number,        LL: revision
 * number (must be 0xFF for a release, this way the release is preferred over
 * test/release candidates when using less/greater than comparisons),        MM:
 * minor number,        HH: major number (>=1),        string representation:
 * vHH.MM (when LL==0xFF), vHH.MM-beta-LL (when LL!=0xFF).}
 */
#define VE_REG_APP_VER_10 0x016A

/**
 * Instance 11 Firmware# {un8 = Identifier : un24 = Instance Firmware Version,
 * 0xFFFFFF = no firmware present, Instance Firmware version 0xHHMMLL (HH=high
 * byte, MM=middle byte, LL=low byte).        When HH == 0 : 16-bits version
 * number (compatible with old/current designs),        LL: minor number,
 * MM: major number,        HH: not used (0),        string representation:
 * vMM.LL.        When HH != 0 : 24-bits version number,        LL: revision
 * number (must be 0xFF for a release, this way the release is preferred over
 * test/release candidates when using less/greater than comparisons),        MM:
 * minor number,        HH: major number (>=1),        string representation:
 * vHH.MM (when LL==0xFF), vHH.MM-beta-LL (when LL!=0xFF).}
 */
#define VE_REG_APP_VER_11 0x016B

/**
 * Instance 12 Firmware# {un8 = Identifier : un24 = Instance Firmware Version,
 * 0xFFFFFF = no firmware present, Instance Firmware version 0xHHMMLL (HH=high
 * byte, MM=middle byte, LL=low byte).        When HH == 0 : 16-bits version
 * number (compatible with old/current designs),        LL: minor number,
 * MM: major number,        HH: not used (0),        string representation:
 * vMM.LL.        When HH != 0 : 24-bits version number,        LL: revision
 * number (must be 0xFF for a release, this way the release is preferred over
 * test/release candidates when using less/greater than comparisons),        MM:
 * minor number,        HH: major number (>=1),        string representation:
 * vHH.MM (when LL==0xFF), vHH.MM-beta-LL (when LL!=0xFF).}
 */
#define VE_REG_APP_VER_12 0x016C

/**
 * Instance 13 Firmware# {un8 = Identifier : un24 = Instance Firmware Version,
 * 0xFFFFFF = no firmware present, Instance Firmware version 0xHHMMLL (HH=high
 * byte, MM=middle byte, LL=low byte).        When HH == 0 : 16-bits version
 * number (compatible with old/current designs),        LL: minor number,
 * MM: major number,        HH: not used (0),        string representation:
 * vMM.LL.        When HH != 0 : 24-bits version number,        LL: revision
 * number (must be 0xFF for a release, this way the release is preferred over
 * test/release candidates when using less/greater than comparisons),        MM:
 * minor number,        HH: major number (>=1),        string representation:
 * vHH.MM (when LL==0xFF), vHH.MM-beta-LL (when LL!=0xFF).}
 */
#define VE_REG_APP_VER_13 0x016D

/**
 * Instance 14 Firmware# {un8 = Identifier : un24 = Instance Firmware Version,
 * 0xFFFFFF = no firmware present, Instance Firmware version 0xHHMMLL (HH=high
 * byte, MM=middle byte, LL=low byte).        When HH == 0 : 16-bits version
 * number (compatible with old/current designs),        LL: minor number,
 * MM: major number,        HH: not used (0),        string representation:
 * vMM.LL.        When HH != 0 : 24-bits version number,        LL: revision
 * number (must be 0xFF for a release, this way the release is preferred over
 * test/release candidates when using less/greater than comparisons),        MM:
 * minor number,        HH: major number (>=1),        string representation:
 * vHH.MM (when LL==0xFF), vHH.MM-beta-LL (when LL!=0xFF).}
 */
#define VE_REG_APP_VER_14 0x016E

/**
 * Instance 15 Firmware# {un8 = Identifier : un24 = Instance Firmware Version,
 * 0xFFFFFF = no firmware present, Instance Firmware version 0xHHMMLL (HH=high
 * byte, MM=middle byte, LL=low byte).        When HH == 0 : 16-bits version
 * number (compatible with old/current designs),        LL: minor number,
 * MM: major number,        HH: not used (0),        string representation:
 * vMM.LL.        When HH != 0 : 24-bits version number,        LL: revision
 * number (must be 0xFF for a release, this way the release is preferred over
 * test/release candidates when using less/greater than comparisons),        MM:
 * minor number,        HH: major number (>=1),        string representation:
 * vHH.MM (when LL==0xFF), vHH.MM-beta-LL (when LL!=0xFF).}
 */
#define VE_REG_APP_VER_15 0x016F

/**
 * instance 0 udf version {un24 = udf version : bits[1] = udf active : bits[7] =
 * reserved, 0x7F = reserved}
 */
#define VE_REG_UDF_VERSION_0 0x0180

/**
 * instance 1 udf version {un24 = udf version : bits[1] = udf active : bits[7] =
 * reserved, 0x7F = reserved}
 */
#define VE_REG_UDF_VERSION_1 0x0181

/**
 * instance 2 udf version {un24 = udf version : bits[1] = udf active : bits[7] =
 * reserved, 0x7F = reserved}
 */
#define VE_REG_UDF_VERSION_2 0x0182

/**
 * instance 3 udf version {un24 = udf version : bits[1] = udf active : bits[7] =
 * reserved, 0x7F = reserved}
 */
#define VE_REG_UDF_VERSION_3 0x0183

/**
 * instance 4 udf version {un24 = udf version : bits[1] = udf active : bits[7] =
 * reserved, 0x7F = reserved}
 */
#define VE_REG_UDF_VERSION_4 0x0184

/**
 * instance 5 udf version {un24 = udf version : bits[1] = udf active : bits[7] =
 * reserved, 0x7F = reserved}
 */
#define VE_REG_UDF_VERSION_5 0x0185

/**
 * instance 6 udf version {un24 = udf version : bits[1] = udf active : bits[7] =
 * reserved, 0x7F = reserved}
 */
#define VE_REG_UDF_VERSION_6 0x0186

/**
 * instance 7 udf version {un24 = udf version : bits[1] = udf active : bits[7] =
 * reserved, 0x7F = reserved}
 */
#define VE_REG_UDF_VERSION_7 0x0187

/**
 * instance 8 udf version {un24 = udf version : bits[1] = udf active : bits[7] =
 * reserved, 0x7F = reserved}
 */
#define VE_REG_UDF_VERSION_8 0x0188

/**
 * instance 9 udf version {un24 = udf version : bits[1] = udf active : bits[7] =
 * reserved, 0x7F = reserved}
 */
#define VE_REG_UDF_VERSION_9 0x0189

/**
 * instance 10 udf version {un24 = udf version : bits[1] = udf active : bits[7] =
 * reserved, 0x7F = reserved}
 */
#define VE_REG_UDF_VERSION_10 0x018A

/**
 * instance 11 udf version {un24 = udf version : bits[1] = udf active : bits[7] =
 * reserved, 0x7F = reserved}
 */
#define VE_REG_UDF_VERSION_11 0x018B

/**
 * instance 12 udf version {un24 = udf version : bits[1] = udf active : bits[7] =
 * reserved, 0x7F = reserved}
 */
#define VE_REG_UDF_VERSION_12 0x018C

/**
 * instance 13 udf version {un24 = udf version : bits[1] = udf active : bits[7] =
 * reserved, 0x7F = reserved}
 */
#define VE_REG_UDF_VERSION_13 0x018D

/**
 * instance 14 udf version {un24 = udf version : bits[1] = udf active : bits[7] =
 * reserved, 0x7F = reserved}
 */
#define VE_REG_UDF_VERSION_14 0x018E

/**
 * instance 15 udf version {un24 = udf version : bits[1] = udf active : bits[7] =
 * reserved, 0x7F = reserved}
 */
#define VE_REG_UDF_VERSION_15 0x018F

/**
 * Device Mode {un8 = Mode (see xml for meanings)}
 * @remark error code 0x8300: Invalid, value is out of range / not applicable for
 * the device / system error code.
 * @remark error code 0xC001: VE.Bus specific error, the system cannot be
 * controlled since another panel controls the mode.
 */
#define VE_REG_DEVICE_MODE 0x0200

/**
 * Device State {un8 = State (see xml for meanings), Device state , @see
 * N2kConverterState}
 */
#define VE_REG_DEVICE_STATE 0x0201

/**
 * Remote Control Used {bits[1] = ACIN1 current limit, 0 = Internal value, 1 =
 * Remote value : bits[1] = Remote On/Off, 0 = Internal value, 1 = Remote value :
 * bits[1] = ACIN2 current limit, 0 = Internal value, 1 = Remote value : bits[1]
 * = reserved 3, 0 = Internal value, 1 = Remote value : bits[1] = reserved 4, 0 =
 * Internal value, 1 = Remote value : bits[1] = reserved 5, 0 = Internal value, 1
 * = Remote value : bits[1] = reserved 6, 0 = Internal value, 1 = Remote value :
 * bits[1] = reserved 7, 0 = Internal value, 1 = Remote value : bits[1] = Sent
 * panel Leds, 0 = Internal value, 1 = Remote value : bits[1] = reserved 9, 0 =
 * Internal value, 1 = Remote value : bits[1] = reserved 10, 0 = Internal value,
 * 1 = Remote value : bits[1] = reserved 11, 0 = Internal value, 1 = Remote value
 * : bits[1] = reserved 12, 0 = Internal value, 1 = Remote value : bits[1] =
 * reserved 13, 0 = Internal value, 1 = Remote value : bits[1] = reserved 14, 0 =
 * Internal value, 1 = Remote value : bits[1] = reserved 15, 0 = Internal value,
 * 1 = Remote value : bits[1] = Sent cell voltage, 0 = Internal value, 1 = Remote
 * value : bits[1] = reserved 17, 0 = Internal value, 1 = Remote value : bits[1]
 * = reserved 18, 0 = Internal value, 1 = Remote value : bits[1] = reserved 19, 0
 * = Internal value, 1 = Remote value : bits[1] = reserved 20, 0 = Internal
 * value, 1 = Remote value : bits[1] = reserved 21, 0 = Internal value, 1 =
 * Remote value : bits[1] = reserved 22, 0 = Internal value, 1 = Remote value :
 * bits[1] = reserved 23, 0 = Internal value, 1 = Remote value : bits[1] =
 * reserved 24, 0 = Internal value, 1 = Remote value : bits[1] = reserved 25, 0 =
 * Internal value, 1 = Remote value : bits[1] = reserved 26, 0 = Internal value,
 * 1 = Remote value : bits[1] = reserved 27, 0 = Internal value, 1 = Remote value
 * : bits[1] = reserved 28, 0 = Internal value, 1 = Remote value : bits[1] =
 * reserved 29, 0 = Internal value, 1 = Remote value : bits[1] = reserved 30, 0 =
 * Internal value, 1 = Remote value : bits[1] = reserved 31, 0 = Internal value,
 * 1 = Remote value}
 * Some features require activation. E.g. the control of AC input currents should
 * only be used when there is a panel present which displays the actual current
 * limit, so it is always clear why power is limited and not a defect. These
 * flags are OR-ed with current enabled features and for compatibilty also accept
 * flags not known to the device.
 */
#define VE_REG_REMOTE_CONTROL_USED 0x0202

/** AC IN Current Limit {un16 = Limit [0.1A], 0xFFFF = Not Available} */
#define VE_REG_AC_IN_CURRENT_LIMIT 0x0203

/**
 * AC IN Active {un8 = Input, 0 = AC-IN1, 1 = AC-IN2, 240 = Not connected}
 * Active AC input, for example for a quattro.
 */
#define VE_REG_AC_IN_ACTIVE 0x0204

/**
 * Device off reason {bits[1] = No Input Power, 0 = No, 1 = Yes, no/low
 * mains/panel/battery power : bits[1] = Hard Power Switch, 0 = No, 1 = Yes,
 * physical switch : bits[1] = Soft Power Switch, 0 = No, 1 = Yes, remote via
 * device_mode and/or push-button : bits[1] = Remote Input, 0 = No, 1 = Yes,
 * remote input connector : bits[1] = Internal Reason, 0 = No, 1 = Yes, internal
 * condition preventing start-up : bits[1] = Paygo, 0 = No, 1 = Yes, need token
 * for operation : bits[1] = Bms, 0 = No, 1 = Yes, allow-to-charge/allow-to-
 * discharge signals from BMS : bits[1] = Engine Sd Detection, 0 = No, 1 = Yes,
 * engine shutdown detected through low input voltage}
 * @deprecated Use VE_REG_DEVICE_OFF_REASON_2 instead.
 * The first byte of that vreg intentionally has the same meaning.
 * VE_REG_DEVICE_OFF_REASON is used by the SmartBatteryProtect and the
 * PhoenixSmartCharger.
 */
#define VE_REG_DEVICE_OFF_REASON 0x0205

/** Device Function {un8 = Function, 0 = Charger, 1 = Power Supply} */
#define VE_REG_DEVICE_FUNCTION 0x0206

/**
 * Device off reason 2 {bits[1] = VE_REG_DEVICE_OFF_2_NO_INPUT_POWER, 0 = No, 1 =
 * Yes, no/low mains/panel/battery power : bits[1] =
 * VE_REG_DEVICE_OFF_2_HARD_POWER_SWITCH, 0 = No, 1 = Yes, physical switch :
 * bits[1] = VE_REG_DEVICE_OFF_2_SOFT_POWER_SWITCH, 0 = No, 1 = Yes, remote via
 * device_mode and/or push-button : bits[1] = VE_REG_DEVICE_OFF_2_REMOTE_INPUT, 0
 * = No, 1 = Yes, remote input connector : bits[1] =
 * VE_REG_DEVICE_OFF_2_INTERNAL_REASON, 0 = No, 1 = Yes, internal condition
 * preventing start-up : bits[1] = VE_REG_DEVICE_OFF_2_PAYGO, 0 = No, 1 = Yes,
 * need token for operation : bits[1] = VE_REG_DEVICE_OFF_2_BMS, 0 = No, 1 = Yes,
 * allow-to-charge/allow-to-discharge signals from BMS : bits[1] =
 * VE_REG_DEVICE_OFF_2_ENGINE_SD_DETECTION, 0 = No, 1 = Yes, engine shutdown
 * detected through low input voltage : bits[1] =
 * VE_REG_DEVICE_OFF_2_ANALYZING_INPUT_VOLTAGE, 0 = No, 1 = Yes, converter off to
 * check input voltage without cable losses : bits[1] =
 * VE_REG_DEVICE_OFF_2_LOW_BATTERY_TEMPERATURE, 0 = No, 1 = Yes, low temperature
 * cut-off : bits[1] = VE_REG_DEVICE_OFF_2_NO_PV_POWER, 0 = No, 1 = Yes, no pv
 * power : bits[1] = VE_REG_DEVICE_OFF_2_LOW_BATTERY, 0 = No, 1 = Yes, battery
 * voltage too low : bits[1] = VE_REG_DEVICE_OFF_2_LOW_MAINS, 0 = No, 1 = Yes, ac
 * input voltage too low : bits[1] = VE_REG_DEVICE_OFF_2_NO_CANSYNC, 0 = No, 1 =
 * Yes, parallel operation: slave inverter out of sync : bits[1] =
 * VE_REG_DEVICE_OFF_2_NOT_ENOUGH_INVERTERS_SYNC_CAN, 0 = No, 1 = Yes, parallel
 * operation: insufficient inverters : bits[1] =
 * VE_REG_DEVICE_OFF_2_ACTIVE_ALARM, 0 = No, 1 = Yes, an active alarm prevents
 * the unit from starting : bits[16] = reserved, 0x000000 = reserved}
 */
#define VE_REG_DEVICE_OFF_REASON_2 0x0207

/**
 * Charge State {un8 = State (see xml for meanings), Inverter state , @see
 * N2kConverterState , used on combined inverter/charger devices.}
 */
#define VE_REG_INVERTER_STATE 0x0209

/**
 * Charge State {un8 = State (see xml for meanings), Charge state , @see
 * N2kConverterState , used on combined inverter/charger devices.}
 */
#define VE_REG_CHARGE_STATE 0x020A

/**
 * AC IN Limit is adjustable {bits[2] = input 1, 0 = Not available, 1 = Yes, 2 =
 * No : bits[2] = input 2, 0 = Not available, 1 = Yes, 2 = No : bits[2] = input
 * 3, 0 = Not available, 1 = Yes, 2 = No : bits[2] = input 4, 0 = Not available,
 * 1 = Yes, 2 = No}
 * Relates to the 'overuled by remote' setting. Remote panel can determine the ac
 * input current limit or use the internal device limit.
 */
#define VE_REG_AC_IN_LIMIT_IS_ADJUSTABLE 0x020B

/** AC IN1 Current Limit {un16 = Limit [0.1A], 0xFFFF = Not Available} */
#define VE_REG_AC_IN_1_CURRENT_LIMIT 0x0210

/** AC IN1 Current Limit Min {un16 = Limit [0.1A], 0xFFFF = Not Available} */
#define VE_REG_AC_IN_1_CURRENT_LIMIT_MIN 0x0211

/** AC IN1 Current Limit Max {un16 = Limit [0.1A], 0xFFFF = Not Available} */
#define VE_REG_AC_IN_1_CURRENT_LIMIT_MAX 0x0212

/**
 * AC IN1 Current Limit Internal {un16 = Limit [0.1A], 0xFFFF = Not Available}
 * Used after reset if no command is received to use the remote value. This is to
 * ensure a device without panels connected behaves the same as initially shipped
 * after a power cycle.
 */
#define VE_REG_AC_IN_1_CURRENT_LIMIT_INTERNAL 0x0213

/**
 * AC IN1 Current Limit Remote {un16 = Limit [0.1A], 0 = use minimum current,
 * 0xFFFF = not available}
 * The remote limit is not used unless enabled see @ref
 * VE_REG_REMOTE_CONTROL_USED
 */
#define VE_REG_AC_IN_1_CURRENT_LIMIT_REMOTE 0x0214

/**
 * AC IN1 Type {un8 = type, 0 = Not available, 1 = Grid, 2 = Generator, 3 = Shore
 * power}
 */
#define VE_REG_AC_IN_1_TYPE 0x0215

/** AC IN2 Current Limit {un16 = Limit [0.1A], 0xFFFF = Not Available} */
#define VE_REG_AC_IN_2_CURRENT_LIMIT 0x0220

/** AC IN2 Current Limit Min {un16 = Limit [0.1A], 0xFFFF = Not Available} */
#define VE_REG_AC_IN_2_CURRENT_LIMIT_MIN 0x0221

/** AC IN2 Current Limit Max {un16 = Limit [0.1A], 0xFFFF = Not Available} */
#define VE_REG_AC_IN_2_CURRENT_LIMIT_MAX 0x0222

/** AC IN2 Current Limit Internal {un16 = Limit [0.1A], 0xFFFF = Not Available} */
#define VE_REG_AC_IN_2_CURRENT_LIMIT_INTERNAL 0x0223

/**
 * AC IN2 Current Limit Remote {un16 = Limit [0.1A], 0 = use minimum current,
 * 0xFFFF = not available}
 */
#define VE_REG_AC_IN_2_CURRENT_LIMIT_REMOTE 0x0224

/**
 * AC IN2 Type {un8 = type, 0 = Not available, 1 = Grid, 2 = Generator, 3 = Shore
 * power}
 */
#define VE_REG_AC_IN_2_TYPE 0x0225

/** AC Voltage Setpoint {un16 = AC Voltage Setpoint [0.01V]} */
#define VE_REG_AC_OUT_VOLTAGE_SETPOINT 0x0230

/** Min AC OUT Voltage Setpoint {un16 = Min AC OUT Voltage Setpoint [0.01V]} */
#define VE_REG_AC_OUT_VOLTAGE_SETPOINT_MIN 0x0231

/** Max AC OUT Voltage Setpoint {un16 = Max AC OUT Voltage Setpoint [0.01V]} */
#define VE_REG_AC_OUT_VOLTAGE_SETPOINT_MAX 0x0232

/** AC Active Input L1 Voltage {sn16 = Voltage [0.01V], 0x7FFF = Not Available} */
#define VE_REG_AC_ACTIVE_INPUT_L1_VOLTAGE 0x0233

/** AC Active Input L1 Current {sn16 = Current [0.01A], 0x7FFF = Not Available} */
#define VE_REG_AC_ACTIVE_INPUT_L1_CURRENT 0x0234

/**
 * AC Active Input L1 Apparent Power {sn32 = Apparent Power [1VA], 0x7FFFFFFF =
 * Not Available}
 */
#define VE_REG_AC_ACTIVE_INPUT_L1_APPARENT_POWER 0x0235

/** AC Active Input L1 Power {sn32 = Power [1W], 0x7FFFFFFF = Not Available} */
#define VE_REG_AC_ACTIVE_INPUT_L1_POWER 0x0236

/**
 * AC Active Input L1 Frequency {un16 = Frequency [0.01HZ], 0xFFFF = Not
 * Available}
 */
#define VE_REG_AC_ACTIVE_INPUT_L1_FREQUENCY 0x0237

/** AC Active Input L2 Voltage {sn16 = Voltage [0.01V], 0x7FFF = Not Available} */
#define VE_REG_AC_ACTIVE_INPUT_L2_VOLTAGE 0x0238

/** AC Active Input L2 Current {sn16 = Current [0.01A], 0x7FFF = Not Available} */
#define VE_REG_AC_ACTIVE_INPUT_L2_CURRENT 0x0239

/**
 * AC Active Input L2 Apparent Power {sn32 = Apparent Power [1VA], 0x7FFFFFFF =
 * Not Available}
 */
#define VE_REG_AC_ACTIVE_INPUT_L2_APPARENT_POWER 0x023a

/** AC Active Input L2 Power {sn32 = Power [1W], 0x7FFFFFFF = Not Available} */
#define VE_REG_AC_ACTIVE_INPUT_L2_POWER 0x023b

/**
 * AC Active Input L2 Frequency {un16 = Frequency [0.01HZ], 0xFFFF = Not
 * Available}
 */
#define VE_REG_AC_ACTIVE_INPUT_L2_FREQUENCY 0x023c

/** AC Active Input L3 Voltage {sn16 = Voltage [0.01V], 0x7FFF = Not Available} */
#define VE_REG_AC_ACTIVE_INPUT_L3_VOLTAGE 0x023d

/** AC Active Input L3 Current {sn16 = Current [0.01A], 0x7FFF = Not Available} */
#define VE_REG_AC_ACTIVE_INPUT_L3_CURRENT 0x023e

/**
 * AC Active Input L3 Apparent Power {sn32 = Apparent Power [1VA], 0x7FFFFFFF =
 * Not Available}
 */
#define VE_REG_AC_ACTIVE_INPUT_L3_APPARENT_POWER 0x023f

/** AC Active Input L3 Power {sn32 = Power [1W], 0x7FFFFFFF = Not Available} */
#define VE_REG_AC_ACTIVE_INPUT_L3_POWER 0x0240

/**
 * AC Active Input L3 Frequency {un16 = Frequency [0.01HZ], 0xFFFF = Not
 * Available}
 */
#define VE_REG_AC_ACTIVE_INPUT_L3_FREQUENCY 0x0241

/** Number of phases {un8 = Number of phases} */
#define VE_REG_NUMBER_OF_PHASES 0x0242

/** Number of ac inputs {un8 = Number of ac inputs} */
#define VE_REG_NUMBER_OF_AC_INPUTS 0x0243

/** Number of dc inputs {un8 = Number of dc inputs} */
#define VE_REG_NUMBER_OF_DC_INPUTS 0x0244

/** PV Inverter Available {un8 = PV Inverter Available} */
#define VE_REG_PV_INVERTER_AVAILABLE 0x0245

/**
 * Deepest discharge {sn32 = Deepest discharge [0.1Ah]}
 * H1#
 */
#define VE_REG_HIST_DEEPEST_DISCHARGE 0x0300

/**
 * Last discharge {sn32 = Last discharge [0.1Ah]}
 * H2#
 */
#define VE_REG_HIST_LAST_DISCHARGE 0x0301

/**
 * Average discharge {sn32 = Average discharge [0.1Ah]}
 * H3#
 */
#define VE_REG_HIST_AVERAGE_DISCHARGE 0x0302

/**
 * Number of charge cycles {sn32 = Number of charge cycles}
 * H4#
 */
#define VE_REG_HIST_NR_OF_CHARGE_CYCLES 0x0303

/**
 * Number of full discharges {sn32 = Number of full discharges}
 * H5#
 */
#define VE_REG_HIST_NR_OF_FULL_DISCHARGES 0x0304

/**
 * Cumulative Ah {sn32 = Cumulative Ah drawn from the battery [0.1Ah]}
 * H6#
 */
#define VE_REG_HIST_CUMULATIVE_AH 0x0305

/**
 * Minimum battery voltage {sn32 = Minimum battery voltage [0.01V]}
 * H7#
 */
#define VE_REG_HIST_MIN_VOLTAGE 0x0306

/**
 * Maximum battery voltage {sn32 = Maximum battery voltage [0.01V]}
 * H8#
 */
#define VE_REG_HIST_MAX_VOLTAGE 0x0307

/**
 * Time since full charge {sn32 = Number of seconds since last full charge [s]}
 * H9#
 */
#define VE_REG_HIST_SECS_SINCE_LAST_FULL_CHARGE 0x0308

/**
 * Synchronizations {sn32 = Number of automatic synchronizations}
 * H10#
 */
#define VE_REG_HIST_NR_OF_AUTO_SYNCS 0x0309

/**
 * Number of low voltage alarms {sn32 = Number of low voltage alarms}
 * H11#
 */
#define VE_REG_HIST_NR_OF_LOW_VOLTAGE_ALARMS 0x030A

/**
 * Number of high voltage alarms {sn32 = Number of high voltage alarms}
 * H12#
 */
#define VE_REG_HIST_NR_OF_HIGH_VOLTAGE_ALARMS 0x030B

/**
 * Number of low auxilary voltage alarms {sn32 = Number of low auxilary voltage
 * alarms}
 * H12#
 */
#define VE_REG_HIST_NR_OF_LOW_VOLTAGE_2_ALARMS 0x030C

/**
 * Number of high auxilary voltage alarms {sn32 = Number of high auxilary voltage
 * alarms}
 * H13#
 */
#define VE_REG_HIST_NR_OF_HIGH_VOLTAGE_2_ALARMS 0x030D

/**
 * Minimum auxilary voltage {sn32 = Minimum auxilary voltage [0.01V]}
 * H15#
 */
#define VE_REG_HIST_MIN_VOLTAGE_2 0x030E

/**
 * Maximum auxilary voltage {sn32 = Maximum auxilary voltage [0.01V]}
 * H16#
 */
#define VE_REG_HIST_MAX_VOLTAGE_2 0x030F

/**
 * The amount of energy drawn from the source {un32 = The amount of energy drawn
 * from the source [0.01kWh]}
 */
#define VE_REG_HIST_KWH_OUT 0x0310

/**
 * The amount of energy put into the source {un32 = The amount of energy put into
 * the source [0.01kWh]}
 */
#define VE_REG_HIST_KWH_IN 0x0311

/** The maximum temperature {un16 = The maximum temperature [0.01K]} */
#define VE_REG_HIST_MAX_TEMPERATURE 0x0312

/** The minimum temperature {un16 = The minimum temperature [0.01K]} */
#define VE_REG_HIST_MIN_TEMPERATURE 0x0313

/**
 * Warning reason {bits[1] = Low Voltage, 0 = No, 1 = Yes, low battery voltage
 * alarm : bits[1] = High Voltage, 0 = No, 1 = Yes, high battery voltage alarm :
 * bits[1] = Low Soc, 0 = No, 1 = Yes, low State Of Charge alarm : bits[1] =
 * VE_REG_ALARM_REASON_LOW_VOLTAGE2, 0 = No, 1 = Yes, low voltage2 alarm :
 * bits[1] = VE_REG_ALARM_REASON_HIGH_VOLTAGE2, 0 = No, 1 = Yes, high voltage2
 * alarm : bits[1] = Low Temperature, 0 = No, 1 = Yes, low temperature alarm
 * (also not connected transformer NTC) : bits[1] = High Temperature, 0 = No, 1 =
 * Yes, high temperature alarm : bits[1] = Mid Voltage, 0 = No, 1 = Yes, mid
 * voltage alarm : bits[1] = Overload, 0 = No, 1 = Yes, e.g. based on Iinv^2 or
 * Ipeak events count : bits[1] = Dc Ripple, 0 = No, 1 = Yes, e.g. indication for
 * poor battery connection : bits[1] = Low V Ac Out, 0 = No, 1 = Yes, e.g. in
 * case of large load and low battery : bits[1] = High V Ac Out, 0 = No, 1 = Yes,
 * e.g. typ. when connected to other "mains" source, this will prevent the
 * inverter-only to start : bits[1] = Short Circuit, 0 = No, 1 = Yes, short
 * circuit alarm : bits[1] = Bms Lockout, 0 = No, 1 = Yes, BMS Lockout alarm
 * (Used in Smart Battery Protect) : bits[1] = Bms Cable Failure, 0 = No, 1 =
 * Yes, Battery M8 BMS Cable not connected or defect (Used in Smart BMS) :
 * bits[1] = reserved 15, 0 = No, 1 = Yes}
 * ("pre"-alarm, no fault condition), multiple flag can be or-ed together for bit
 * mask
 */
#define VE_REG_WARNING_REASON 0x031C

/**
 * Alarm status {un8 = alarm flags, 0 = active, 1 = inactive}
 * VE.Text equivalent: ALARM (ON/OFF)
 */
#define VE_REG_ALARM_STATUS 0x031D

/**
 * Alarm reason {bits[1] = Low Voltage, 0 = No, 1 = Yes, low battery voltage
 * alarm : bits[1] = High Voltage, 0 = No, 1 = Yes, high battery voltage alarm :
 * bits[1] = Low Soc, 0 = No, 1 = Yes, low State Of Charge alarm : bits[1] =
 * VE_REG_ALARM_REASON_LOW_VOLTAGE2, 0 = No, 1 = Yes, low voltage2 alarm :
 * bits[1] = VE_REG_ALARM_REASON_HIGH_VOLTAGE2, 0 = No, 1 = Yes, high voltage2
 * alarm : bits[1] = Low Temperature, 0 = No, 1 = Yes, low temperature alarm
 * (also not connected transformer NTC) : bits[1] = High Temperature, 0 = No, 1 =
 * Yes, high temperature alarm : bits[1] = Mid Voltage, 0 = No, 1 = Yes, mid
 * voltage alarm : bits[1] = Overload, 0 = No, 1 = Yes, e.g. based on Iinv^2 or
 * Ipeak events count : bits[1] = Dc Ripple, 0 = No, 1 = Yes, e.g. indication for
 * poor battery connection : bits[1] = Low V Ac Out, 0 = No, 1 = Yes, e.g. in
 * case of large load and low battery : bits[1] = High V Ac Out, 0 = No, 1 = Yes,
 * e.g. typ. when connected to other "mains" source, this will prevent the
 * inverter-only to start : bits[1] = Short Circuit, 0 = No, 1 = Yes, short
 * circuit alarm : bits[1] = Bms Lockout, 0 = No, 1 = Yes, BMS Lockout alarm
 * (Used in Smart Battery Protect) : bits[1] = Bms Cable Failure, 0 = No, 1 =
 * Yes, Battery M8 BMS Cable not connected or defect (Used in Smart BMS) :
 * bits[1] = reserved 15, 0 = No, 1 = Yes}
 * multiple flag can be or-ed together for bit mask
 */
#define VE_REG_ALARM_REASON 0x031E

/** Acknowlegde alarm command (no data) */
#define VE_REG_ALARM_ACK 0x031F

/**
 * Low voltage lower threshold
 * @remark BMV-70x and old VE.CAN MPPT chargers are an exception, unit is 0.1V
 * @remark Important for mppt chargers: always set the @ref VE_REG_BAT_VOLTAGE
 * register to the correct system voltage before writing to this register
 */
#define VE_REG_ALARM_LOW_VOLTAGE_SET 0x0320

/**
 * Low voltage upper threshold
 * @remark BMV-70x and old VE.CAN MPPT chargers are an exception, unit is 0.1V
 * @remark Important for mppt chargers: always set the @ref VE_REG_BAT_VOLTAGE
 * register to the correct system voltage before writing to this register
 */
#define VE_REG_ALARM_LOW_VOLTAGE_CLEAR 0x0321

/**
 * High voltage upper threshold
 * @remark BMV-70x and old VE.CAN MPPT chargers are an exception, unit is 0.1V
 * @remark Important for mppt chargers: always set the @ref VE_REG_BAT_VOLTAGE
 * register to the correct system voltage before writing to this register
 */
#define VE_REG_ALARM_HIGH_VOLTAGE_SET 0x0322

/**
 * High voltage lower threshold
 * @remark BMV-70x and old VE.CAN MPPT chargers are an exception, unit is 0.1V
 * @remark Important for mppt chargers: always set the @ref VE_REG_BAT_VOLTAGE
 * register to the correct system voltage before writing to this register
 */
#define VE_REG_ALARM_HIGH_VOLTAGE_CLEAR 0x0323

/**
 * Low auxilary voltage lower threshold
 * @remark BMV-70x is an exception, unit is 0.1V
 */
#define VE_REG_ALARM_LOW_VOLTAGE_2_SET 0x0324

/**
 * Low auxilary voltage upper threshold
 * @remark BMV-70x is an exception, unit is 0.1V
 */
#define VE_REG_ALARM_LOW_VOLTAGE_2_CLEAR 0x0325

/**
 * High auxilary voltage upper threshold
 * @remark BMV-70x is an exception, unit is 0.1V
 */
#define VE_REG_ALARM_HIGH_VOLTAGE_2_SET 0x0326

/**
 * High auxilary voltage lower threshold
 * @remark BMV-70x is an exception, unit is 0.1V
 */
#define VE_REG_ALARM_HIGH_VOLTAGE_2_CLEAR 0x0327

/**
 * Low SOC lower threshold {un16 = Low SOC lower threshold [0.1%], @remark Lynx
 * Shunt VE.Can v1.08 and older: unit is 10%}
 */
#define VE_REG_ALARM_LOW_SOC_SET 0x0328

/**
 * Low SOC upper threshold {un16 = Low SOC upper threshold [0.1%], @remark Lynx
 * Shunt VE.Can v1.08 and older: unit is 10%}
 */
#define VE_REG_ALARM_LOW_SOC_CLEAR 0x0329

/**
 * Low battery temperature lower threshold {un16 = Low battery temperature lower
 * threshold [0.01K]}
 */
#define VE_REG_ALARM_LOW_BAT_TEMP_SET 0x032A

/**
 * Low battery temperature upper threshold {un16 = Low battery temperature upper
 * threshold [0.01K]}
 */
#define VE_REG_ALARM_LOW_BAT_TEMP_CLEAR 0x032B

/**
 * High battery temperature upper threshold {un16 = High battery temperature
 * upper threshold [0.01K]}
 */
#define VE_REG_ALARM_HIGH_BAT_TEMP_SET 0x032C

/**
 * High battery temperature lower threshold {un16 = High battery temperature
 * lower threshold [0.01K]}
 */
#define VE_REG_ALARM_HIGH_BAT_TEMP_CLEAR 0x032D

/**
 * High internal temperature alarm upper threshold {un16 = High internal
 * temperature alarm upper threshold [0.01K]}
 */
#define VE_REG_ALARM_HIGH_INT_TEMP_SET 0x032E

/**
 * High internal temperature alarm lower threshold {un16 = High internal
 * temperature alarm lower threshold [0.01K]}
 */
#define VE_REG_ALARM_HIGH_INT_TEMP_CLEAR 0x032F

/**
 * Fuse blown alarm enable {un8 = Fuse blown alarm enable, 0 = enabled, 1 =
 * disabled}
 */
#define VE_REG_ALARM_FUSE_BLOWN 0x0330

/**
 * Mid voltage alarm set {un16 = Mid voltage alarm set [0.1%]}
 * @remark BMV-70x firmware <= 0x0307 returns rubbish data, because bmv returns
 * only lower byte of uint16.
 */
#define VE_REG_ALARM_MID_VOLTAGE_SET 0x0331

/** Mid voltage alarm clear {un16 = Mid voltage alarm clear [0.1%]} */
#define VE_REG_ALARM_MID_VOLTAGE_CLEAR 0x0332

/**
 * Alarm and Warning configuration {bits[2] = Low Voltage, 0 = Unsupported, 1 =
 * Disabled, 2 = Alarm only, 3 = Alarms and Warnings, low battery voltage alarm :
 * bits[2] = High Voltage, 0 = Unsupported, 1 = Disabled, 2 = Alarm only, 3 =
 * Alarms and Warnings, high battery voltage alarm : bits[2] = Low Soc, 0 =
 * Unsupported, 1 = Disabled, 2 = Alarm only, 3 = Alarms and Warnings, low State
 * Of Charge alarm : bits[2] = VE_REG_ALARM_REASON_LOW_VOLTAGE2, 0 = Unsupported,
 * 1 = Disabled, 2 = Alarm only, 3 = Alarms and Warnings, low voltage2 alarm :
 * bits[2] = VE_REG_ALARM_REASON_HIGH_VOLTAGE2, 0 = Unsupported, 1 = Disabled, 2
 * = Alarm only, 3 = Alarms and Warnings, high voltage2 alarm : bits[2] = Low
 * Temperature, 0 = Unsupported, 1 = Disabled, 2 = Alarm only, 3 = Alarms and
 * Warnings, low temperature alarm (also not connected transformer NTC) : bits[2]
 * = High Temperature, 0 = Unsupported, 1 = Disabled, 2 = Alarm only, 3 = Alarms
 * and Warnings, high temperature alarm : bits[2] = Mid Voltage, 0 = Unsupported,
 * 1 = Disabled, 2 = Alarm only, 3 = Alarms and Warnings, mid voltage alarm :
 * bits[2] = Overload, 0 = Unsupported, 1 = Disabled, 2 = Alarm only, 3 = Alarms
 * and Warnings, e.g. based on Iinv^2 or Ipeak events count : bits[2] = Dc
 * Ripple, 0 = Unsupported, 1 = Disabled, 2 = Alarm only, 3 = Alarms and
 * Warnings, e.g. indication for poor battery connection : bits[2] = Low V Ac
 * Out, 0 = Unsupported, 1 = Disabled, 2 = Alarm only, 3 = Alarms and Warnings,
 * e.g. in case of large load and low battery : bits[2] = High V Ac Out, 0 =
 * Unsupported, 1 = Disabled, 2 = Alarm only, 3 = Alarms and Warnings, e.g. typ.
 * when connected to other "mains" source, this will prevent the inverter-only to
 * start : bits[2] = Short Circuit, 0 = Unsupported, 1 = Disabled, 2 = Alarm
 * only, 3 = Alarms and Warnings, short circuit alarm : bits[2] = Bms Lockout, 0
 * = Unsupported, 1 = Disabled, 2 = Alarm only, 3 = Alarms and Warnings, BMS
 * Lockout alarm (Used in Smart Battery Protect) : bits[2] = Bms Cable Failure, 0
 * = Unsupported, 1 = Disabled, 2 = Alarm only, 3 = Alarms and Warnings, Battery
 * M8 BMS Cable not connected or defect (Used in Smart BMS) : bits[2] = reserved
 * 15, 0 = Unsupported, 1 = Disabled, 2 = Alarm only, 3 = Alarms and Warnings}
 * setting a signal to zero preserves the original value, this allows for
 * modifying only a single signal at a time. see @ref
 * meanings:vregs:bit.unsupported.disabled.alarm.all
 */
#define VE_REG_ALARM_AND_WARNING_CONFIGURATION 0x0333

/** Relay invert. {un8 = relay invert, 0 = not-invert, 1 = invert} */
#define VE_REG_RELAY_INVERT 0x034D

/** Relay control {un8 = Relay control} */
#define VE_REG_RELAY_CONTROL 0x034E

/** Relay Mode {un8 = Relay Mode (see xml for meanings)} */
#define VE_REG_RELAY_MODE 0x034F

/**
 * Relay Low Voltage Set
 * @remark BMV-70x and old VE.CAN MPPT chargers are an exception, unit is 0.1V
 * @remark Important for mppt chargers: always set the @ref VE_REG_BAT_VOLTAGE
 * register to the correct system voltage before writing to this register
 */
#define VE_REG_RELAY_LOW_VOLTAGE_SET 0x0350

/**
 * Relay Low Voltage Clear
 * @remark BMV-70x and old VE.CAN MPPT chargers are an exception, unit is 0.1V
 * @remark Important for mppt chargers: always set the @ref VE_REG_BAT_VOLTAGE
 * register to the correct system voltage before writing to this register
 */
#define VE_REG_RELAY_LOW_VOLTAGE_CLEAR 0x0351

/**
 * Relay High Voltage Set
 * @remark BMV-70x and old VE.CAN MPPT chargers are an exception, unit is 0.1V
 * @remark Important for mppt chargers: always set the @ref VE_REG_BAT_VOLTAGE
 * register to the correct system voltage before writing to this register
 */
#define VE_REG_RELAY_HIGH_VOLTAGE_SET 0x0352

/**
 * Relay High Voltage Clear
 * @remark BMV-70x and old VE.CAN MPPT chargers are an exception, unit is 0.1V
 * @remark Important for mppt chargers: always set the @ref VE_REG_BAT_VOLTAGE
 * register to the correct system voltage before writing to this register
 */
#define VE_REG_RELAY_HIGH_VOLTAGE_CLEAR 0x0353

/**
 * Relay Low Voltage 2 Set
 * @remark BMV-70x is an exception, unit is 0.1V
 */
#define VE_REG_RELAY_LOW_VOLTAGE_2_SET 0x0354

/**
 * Relay Low Voltage 2 Clear
 * @remark BMV-70x is an exception, unit is 0.1V
 */
#define VE_REG_RELAY_LOW_VOLTAGE_2_CLEAR 0x0355

/**
 * Relay High Voltage 2 Set
 * @remark BMV-70x is an exception, unit is 0.1V
 */
#define VE_REG_RELAY_HIGH_VOLTAGE_2_SET 0x0356

/**
 * Relay High Voltage 2 Clear
 * @remark BMV-70x is an exception, unit is 0.1V
 */
#define VE_REG_RELAY_HIGH_VOLTAGE_2_CLEAR 0x0357

/** Low SOC lower threshold {un16 = Low SOC lower threshold [0.1%]} */
#define VE_REG_RELAY_LOW_SOC_SET 0x0358

/** Low SOC upper threshold {un16 = Low SOC upper threshold [0.1%]} */
#define VE_REG_RELAY_LOW_SOC_CLEAR 0x0359

/**
 * Low battery temperature lower threshold {un16 = Low battery temperature lower
 * threshold [0.01K]}
 */
#define VE_REG_RELAY_LOW_BAT_TEMP_SET 0x035A

/**
 * Low battery temperature upper threshold {un16 = Low battery temperature upper
 * threshold [0.01K]}
 */
#define VE_REG_RELAY_LOW_BAT_TEMP_CLEAR 0x035B

/**
 * High battery temperature upper threshold {un16 = High battery temperature
 * upper threshold [0.01K]}
 */
#define VE_REG_RELAY_HIGH_BAT_TEMP_SET 0x035C

/**
 * High battery temperature lower threshold {un16 = High battery temperature
 * lower threshold [0.01K]}
 */
#define VE_REG_RELAY_HIGH_BAT_TEMP_CLEAR 0x035D

/**
 * High internal temperature relay upper threshold {un16 = High internal
 * temperature relay upper threshold [0.01K]}
 */
#define VE_REG_RELAY_HIGH_INT_TEMP_SET 0x035E

/**
 * High internal temperature relay lower threshold {un16 = High internal
 * temperature relay lower threshold [0.01K]}
 */
#define VE_REG_RELAY_HIGH_INT_TEMP_CLEAR 0x035F

/**
 * Enable closing the relay when the fuse is blown {un8 = Enable closing the
 * relay when the fuse is blown, 0 = enabled, 1 = disabled}
 */
#define VE_REG_RELAY_FUSE_BLOWN 0x0360

/** Mid voltage relay set {un16 = Mid voltage relay set [0.1%]} */
#define VE_REG_RELAY_MID_VOLTAGE_SET 0x0361

/** Mid voltage relay clear {un16 = Mid voltage relay clear [0.1%]} */
#define VE_REG_RELAY_MID_VOLTAGE_CLEAR 0x0362

/**
 * Number of batteries and number of cells per battery {un8 = Number of batteries
 * : un8 = Cells per battery : un8 = Number of batteries in parallel : un8 =
 * Number of batteries in series}
 */
#define VE_REG_BATTERY_CONFIGURATION 0x0380

/**
 * Voltages of cell n of battery m . {un8 = m : un8 = n : un16 = Voltages of cell
 * n of battery m . [0.01V]}
 */
#define VE_REG_BATTERY_CELL_VOLTAGE 0x0381

/**
 * The mid-point voltage of a battery bank {un16 = The mid-point voltage of a
 * battery bank [0.01V], 0xFFFF = not available}
 */
#define VE_REG_BATTERY_MID_POINT_VOLTAGE 0x0382

/**
 * The mid-point deviation relative to the expected {sn16 = The mid-point
 * deviation relative to the expected [0.1%], 0x7FFF = not available}
 */
#define VE_REG_BATTERY_MID_POINT_DEVIATION 0x0383

/**
 * Maximum/minimum cell voltage (historic) {un16 = Minimum voltage [0.01V] : un16
 * = Maximum voltage [0.01V]}
 */
#define VE_REG_HIST_BATTERY_CELL_VOLTAGE_MIN_MAX 0x0384

/**
 * Maximum/minimum cell voltage {un16 = Minimum voltage [0.01V] : un16 = Maximum
 * voltage [0.01V]}
 */
#define VE_REG_BATTERY_MIN_MAX_CELL_VOLTAGE 0x0385

/**
 * Maximum/minimum cell temperature {un16 = Minimum temperature [0.01K] : un16 =
 * Maximum temperature [0.01K]}
 */
#define VE_REG_BATTERY_MIN_MAX_CELL_TEMPERATURE 0x0386

/**
 * Battery - Number of parallel strings {un8 = Parallel, 0 = automatically
 * detected}
 */
#define VE_REG_BATTERY_PARALLEL 0x0387

/**
 * Battery - Number of batteries in a series string {un8 = Series, 0 =
 * automatically detected}
 */
#define VE_REG_BATTERY_SERIES 0x0388

/** Battery limit: Charge voltage {un32 = Charge voltage [0.01V]} */
#define VE_REG_BATTERY_LIMIT_CHARGE_VOLTAGE 0x0390

/** Battery limit: Charge current {un32 = Charge current [0.1A]} */
#define VE_REG_BATTERY_LIMIT_CHARGE_CURRENT 0x0391

/** Battery limit: Discharge voltage {un32 = Discharge voltage [0.01V]} */
#define VE_REG_BATTERY_LIMIT_DISCHARGE_VOLTAGE 0x0392

/** Battery limit: Discharge current {un32 = Discharge current [0.1A]} */
#define VE_REG_BATTERY_LIMIT_DISCHARGE_CURRENT 0x0393

/**
 * Allowed-To-Charge minimum battery temperature {un16 = Allowed-To-Charge
 * minimum battery temperature [0.01K]}
 * The Allowed-To-Charge signal will be disabled when the battery temperature
 * gets below this threshold
 */
#define VE_REG_BATTERY_ALLOWED_TO_CHARGE_MIN_TEMP 0x0394

/**
 * Backlight always on {un8 = mode, 0 = stay off, 1 = stay on, 2 = auto}
 * used in mppt chargers with pluggable display, used to store the user setting
 * in nvm
 */
#define VE_REG_BACKLIGHT_ALWAYS_ON 0x0400

/** Backlight intensity {un8 = intensity} */
#define VE_REG_BACKLIGHT_INTENSITY 0x0401

/** Display scroll speed {un8 = scroll speed} */
#define VE_REG_DISPLAY_SCROLL_SPEED 0x0402

/** Lock setup {un8 = Lock setup, 0 = unlocked, 1 = locked} */
#define VE_REG_DISPLAY_SETUP_LOCK 0x0403

/** Temperature unit {un8 = Temperature unit, 0 = Celcius, 1 = Fahrenheit} */
#define VE_REG_DISPLAY_TEMPERATURE_UNIT 0x0404

/**
 * Sound buzzer when alarm active {un8 = Sound buzzer when alarm active, 0 = off,
 * 1 = on}
 */
#define VE_REG_ALARM_BUZZER 0x0405

/** Display contrast {un8 = contrast} */
#define VE_REG_DISPLAY_CONTRAST 0x0406

/**
 * Maximum brightness of the LED(s). {un16 = Maximum brightness of the LED(s).
 * [0.1%]}
 */
#define VE_REG_LED_BRIGHTNESS 0x0407

/**
 * Backlight mode {un8 = mode, 0 = always off, 1 = always on, 2 = automatic}
 * used in models with built-in display, so the setting can modified using
 * VictronConnect
 */
#define VE_REG_BACKLIGHT_MODE 0x0408

/** Consumed Ah {sn32 = Consumed Ah [0.1Ah]} */
#define VE_REG_CONSUMED_AH 0x0FFC

/**
 * Initial battery monitor state {un8 = state, 0 = unsynchronized, 1 =
 * synchronized}
 */
#define VE_REG_START_SYNCHRONIZED 0x0FFD

/** Time to go {un16 = Time to go [1minutes], 0xFFFF = not available} */
#define VE_REG_TTG 0x0FFE

/** State of charge {un16 = SOC [0.01%], 0xFFFF = not available} */
#define VE_REG_SOC 0x0FFF

/**
 * Battery capacity {un16 = Battery capacity [Ah]}
 * @remark Compatible with BMV HEX protocol.
 */
#define VE_REG_BATTERY_CAPACITY 0x1000

/**
 * Charged voltage {un16 = Charged voltage [0.1V]}
 * @remark Compatible with BMV HEX protocol.
 */
#define VE_REG_CHARGED_VOLTAGE 0x1001

/**
 * Charged current {un16 = Charged current [0.1%]}
 * @remark Compatible with BMV HEX protocol.
 */
#define VE_REG_CHARGED_CURRENT 0x1002

/**
 * Charged detection time. {un16 = Charged detection time. [1minutes]}
 * @remark Compatible with BMV HEX protocol.
 */
#define VE_REG_CHARGE_DETECTION_TIME 0x1003

/**
 * Charge efficiency {un16 = Charge efficiency [1%]}
 * @remark Compatible with BMV HEX protocol.
 */
#define VE_REG_CHARGE_EFFICIENCY 0x1004

/**
 * Peukert coefficient {un16 = Peukert coefficient [0.01]}
 * @remark Compatible with BMV HEX protocol.
 */
#define VE_REG_PEUKERT_COEFFICIENT 0x1005

/**
 * Current threshold {un16 = Current threshold [0.01A]}
 * @remark Compatible with BMV HEX protocol.
 */
#define VE_REG_CURRENT_THRESHOLD 0x1006

/**
 * TTG Delta T {un16 = TTG Delta T [1minutes]}
 * @remark Compatible with BMV HEX protocol.
 */
#define VE_REG_TTG_DELTA_T 0x1007

/**
 * Low SOC (Discharge floor) {un16 = Low SOC (Discharge floor) [0.1%]}
 * @remark Compatible with BMV HEX protocol.
 */
#define VE_REG_LOW_SOC 0x1008

/**
 * Low SOC Clear (Relay Low Soc Clear) {un16 = Low SOC Clear (Relay Low Soc
 * Clear) [0.1%]}
 * @remark Compatible with BMV HEX protocol.
 */
#define VE_REG_LOW_SOC_CLEAR 0x1009

/**
 * Relay Min Enabled {un16 = Relay Min Enabled [1minutes], 0xFFFF = Not
 * Available, The minimal number of minutes the relay in enabled}
 * @remark Compatible with BMV HEX protocol.
 */
#define VE_REG_RELAY_MIN_ENABLED 0x100A

/**
 * Relay Disable Delay {un16 = Relay Disable Delay [1minutes], 0xFFFF = Not
 * Available, The number of minutes the relay remains enabled after the relay
 * condition is false.}
 * @remark Compatible with BMV HEX protocol.
 */
#define VE_REG_RELAY_DISABLE_DELAY 0x100B

/** SOC when bulk finisihed {un16 = SOC when bulk finisihed [0.1%]} */
#define VE_REG_SOC_BULK_FINISH 0x100C

/**
 * Zero current command
 * @remark Compatible with BMV HEX protocol.
 */
#define VE_REG_ZERO_CURRENT 0x1029

/**
 * Synchronize monitor command
 * @remark Compatible with BMV HEX protocol.
 */
#define VE_REG_SYNCHRONIZE 0x102C

/**
 * Clear history command
 * @remark Compatible with BMV HEX protocol.
 */
#define VE_REG_CLEAR_HISTORY 0x1030

/**
 * Transmit history data (normally history data is sent on change only, write to
 * this register to request a transmission).
 *       Use vregs @ref VE_REG_HISTORY_TOTAL, @ref VE_REG_HISTORY_DAY00 .. @ref
 * VE_REG_HISTORY_DAY30 instead
 */
#define VE_REG_TRANSMIT_HISTORY 0x1031

/**
 * User current zero in counts {sn16 = User current zero in counts}
 * @remark Compatible with BMV HEX protocol.
 */
#define VE_REG_CURRENT_OFFSET 0x1034

/**
 * Total amount of operating time in seconds. {un32 = Total amount of operating
 * time in seconds.}
 * @remark Time device has been on since factory.
 */
#define VE_REG_HISTORY_TIME 0x1040

/**
 * Total amount of energy in DecaVAh. {un32 = Total amount of energy in DecaVAh.}
 * @remark Energy device has generated since factory.
 */
#define VE_REG_HISTORY_ENERGY 0x1041

/**
 * Multi/Phoenix Inverter measured voltage at (first or main) AC output {sn16 =
 * Multi/Phoenix Inverter measured voltage at (first or main) AC output [0.01V]}
 */
#define VE_REG_AC_OUT_VOLTAGE 0x2200

/**
 * Multi/Phoenix Inverter measured current (through first or main) AC output.
 * {sn16 = Multi/Phoenix Inverter measured current (through first or main) AC
 * output. [0.1A]}
 */
#define VE_REG_AC_OUT_CURRENT 0x2201

/**
 * AC-out voltage (typ. either 230 or 120) {un8 = AC-out voltage (typ. either 230
 * or 120) [1V]}
 */
#define VE_REG_AC_OUT_NOM_VOLTAGE 0x2202

/**
 * Rated output, (typ.VA value printed on the box)  {sn16 = Rated output, (typ.VA
 * value printed on the box)  [1W]}
 */
#define VE_REG_AC_OUT_RATED_POWER 0x2203

/**
 * Multi/Phoenix Inverter measured power at (first or main) AC output {sn32 =
 * Multi/Phoenix Inverter measured power at (first or main) AC output [1W]}
 */
#define VE_REG_AC_OUT_REAL_POWER 0x2204

/**
 * Multi/Phoenix Inverter measured power at (first or main) AC output {sn32 =
 * Multi/Phoenix Inverter measured power at (first or main) AC output [1VA]}
 */
#define VE_REG_AC_OUT_APPARENT_POWER 0x2205

/**
 * Load smaller enables AES/Eco-search mode {un16 = Load smaller enables AES/Eco-
 * search mode [1W]}
 */
#define VE_REG_AC_LOAD_SENSE_POWER_THRESHOLD 0x2206

/**
 * Load larger disables AES/Eco-search mode {un16 = Load larger disables AES/Eco-
 * search mode [1W]}
 */
#define VE_REG_AC_LOAD_SENSE_POWER_CLEAR 0x2207

/**
 * Multi/Phoenix Inverter frequency on AC output {un16 = Multi/Phoenix Inverter
 * frequency on AC output [0.01HZ]}
 */
#define VE_REG_AC_OUTPUT_FREQUENCY 0x2208

/**
 * AC voltage between PE and Neutral {sn16 = AC voltage between PE and Neutral
 * [0.01V]}
 */
#define VE_REG_AC_PE_N_VOLTAGE 0x2209

/** Shutdown On Low Voltage {un16 = Shutdown On Low Voltage [0.01V]} */
#define VE_REG_SHUTDOWN_LOW_VOLTAGE_SET 0x2210

/**
 * Minimum DC voltage (user settings range) {un16 = Minimum DC voltage (user
 * settings range) [0.01V], tester}
 */
#define VE_REG_VOLTAGE_RANGE_MIN 0x2211

/**
 * Maximum DC voltage (user settings range) {un16 = Maximum DC voltage (user
 * settings range) [0.01V], tester}
 */
#define VE_REG_VOLTAGE_RANGE_MAX 0x2212

/**
 * Multi/Phoenix Inverter measured voltage at AC output L1 {sn16 = Multi/Phoenix
 * Inverter measured voltage at AC output L1 [0.01V]}
 */
#define VE_REG_AC_OUTPUT_L1_VOLTAGE 0x2213

/**
 * Multi/Phoenix Inverter measured current AC output.L1 {sn16 = Multi/Phoenix
 * Inverter measured current AC output.L1 [0.01A]}
 */
#define VE_REG_AC_OUTPUT_L1_CURRENT 0x2214

/**
 * Multi/Phoenix Inverter measured power at AC output L1 {sn32 =  Multi/Phoenix
 * Inverter measured power at AC output L1 [1W]}
 */
#define VE_REG_AC_OUTPUT_L1_POWER 0x2215

/**
 * Multi/Phoenix Inverter measured power at AC output L1 {sn32 = Multi/Phoenix
 * Inverter measured power at AC output L1 [1VA]}
 */
#define VE_REG_AC_OUTPUT_L1_APPARENT_POWER 0x2216

/**
 * Multi/Phoenix Inverter frequency at AC output L1 {un16 = Multi/Phoenix
 * Inverter frequency at AC output L1 [0.01HZ]}
 */
#define VE_REG_AC_OUTPUT_L1_FREQUENCY 0x2217

/**
 * Multi/Phoenix Inverter measured voltage at AC output L2 {sn16 = Multi/Phoenix
 * Inverter measured voltage at AC output L2 [0.01V]}
 */
#define VE_REG_AC_OUTPUT_L2_VOLTAGE 0x2218

/**
 * Multi/Phoenix Inverter measured current AC output.L2 {sn16 = Multi/Phoenix
 * Inverter measured current AC output.L2 [0.01A]}
 */
#define VE_REG_AC_OUTPUT_L2_CURRENT 0x2219

/**
 * Multi/Phoenix Inverter measured power at AC output L2 {sn32 =  Multi/Phoenix
 * Inverter measured power at AC output L2 [1W]}
 */
#define VE_REG_AC_OUTPUT_L2_POWER 0x221a

/**
 * Multi/Phoenix Inverter measured power at AC output L2 {sn32 = Multi/Phoenix
 * Inverter measured power at AC output L2 [1VA]}
 */
#define VE_REG_AC_OUTPUT_L2_APPARENT_POWER 0x221b

/** Multi/Phoenix Inverter frequency at AC output L2 {un16 = Frequency [0.01HZ]} */
#define VE_REG_AC_OUTPUT_L2_FREQUENCY 0x221c

/**
 * Multi/Phoenix Inverter measured voltage at AC output L3 {sn16 = Multi/Phoenix
 * Inverter measured voltage at AC output L3 [0.01V]}
 */
#define VE_REG_AC_OUTPUT_L3_VOLTAGE 0x221d

/**
 * Multi/Phoenix Inverter measured current AC output.L3 {sn16 = Multi/Phoenix
 * Inverter measured current AC output.L3 [0.01A]}
 */
#define VE_REG_AC_OUTPUT_L3_CURRENT 0x221e

/**
 * Multi/Phoenix Inverter measured power at AC output L3 {sn32 =  Multi/Phoenix
 * Inverter measured power at AC output L3 [1W]}
 */
#define VE_REG_AC_OUTPUT_L3_POWER 0x221f

/**
 * Multi/Phoenix Inverter measured power at AC output L3 {sn32 = Multi/Phoenix
 * Inverter measured power at AC output L3 [1VA]}
 */
#define VE_REG_AC_OUTPUT_L3_APPARENT_POWER 0x2220

/** Multi/Phoenix Inverter frequency at AC output L3 {un16 = Frequency [0.01HZ]} */
#define VE_REG_AC_OUTPUT_L3_FREQUENCY 0x2221

/**
 * Minimum DC input voltage (user settings range) {un16 = Minimum DC input
 * voltage (user settings range) [0.01V]}
 */
#define VE_REG_INPUT_VOLTAGE_RANGE_MIN 0x2222

/**
 * Maximum DC input voltage (user settings range) {un16 = Maximum DC input
 * voltage (user settings range) [0.01V]}
 */
#define VE_REG_INPUT_VOLTAGE_RANGE_MAX 0x2223

/**
 * Multi measured voltage AC input 1 {sn16 = Multi measured voltage AC input 1
 * [0.01V]}
 */
#define VE_REG_AC_IN_1_VOLTAGE 0x2230

/**
 * Multi measured current AC input 1 {sn16 = Multi measured current AC input 1
 * [0.1A]}
 */
#define VE_REG_AC_IN_1_CURRENT 0x2231

/**
 * Multi measured power on AC input 1 {sn32 =  Multi measured power on AC input 1
 * [1W]}
 */
#define VE_REG_AC_IN_1_REAL_POWER 0x2234

/** Multi measured power AC input 1 {sn32 = Multi measured power AC input 1 [1VA]} */
#define VE_REG_AC_IN_1_APPARENT_POWER 0x2235

/** Multi frequency AC input 1 {un16 = Multi frequency AC input 1 [0.01HZ]} */
#define VE_REG_AC_IN_1_FREQUENCY 0x2238

/**
 * Multi measured voltage AC input 2 {sn16 = Multi measured voltage AC input 2
 * [0.01V]}
 */
#define VE_REG_AC_IN_2_VOLTAGE 0x2240

/**
 * Multi measured current AC input 2 {sn16 = Multi measured current AC input 2
 * [0.1A]}
 */
#define VE_REG_AC_IN_2_CURRENT 0x2241

/**
 * Multi measured power on AC input 2 {sn32 =  Multi measured power on AC input 2
 * [1W]}
 */
#define VE_REG_AC_IN_2_REAL_POWER 0x2244

/** Multi measured power AC input 2 {sn32 = Multi measured power AC input 2 [1VA]} */
#define VE_REG_AC_IN_2_APPARENT_POWER 0x2245

/** Multi frequency AC input 2 {un16 = Multi frequency AC input 2 [0.01HZ]} */
#define VE_REG_AC_IN_2_FREQUENCY 0x2248

/**
 * Multi/Phoenix Inverter measured voltage at AC input 1 L1 {sn16 = Multi/Phoenix
 * Inverter measured voltage at AC input 1 L1 [0.01V]}
 */
#define VE_REG_AC_INPUT_1_L1_VOLTAGE 0x2250

/**
 * Multi/Phoenix Inverter measured current AC input 1 L1 {sn16 = Multi/Phoenix
 * Inverter measured current AC input 1 L1 [0.01A]}
 */
#define VE_REG_AC_INPUT_1_L1_CURRENT 0x2251

/**
 * Multi/Phoenix Inverter measured power at AC input 1 L1 {sn32 =  Multi/Phoenix
 * Inverter measured power at AC input 1 L1 [1W]}
 */
#define VE_REG_AC_INPUT_1_L1_POWER 0x2252

/**
 * Multi/Phoenix Inverter measured power at AC input 1 L1 {sn32 = Multi/Phoenix
 * Inverter measured power at AC input 1 L1 [1VA]}
 */
#define VE_REG_AC_INPUT_1_L1_APPARENT_POWER 0x2253

/**
 * Multi/Phoenix Inverter frequency at AC input 1 L1 {un16 = Multi/Phoenix
 * Inverter frequency at AC input 1 L1 [0.01HZ]}
 */
#define VE_REG_AC_INPUT_1_L1_FREQUENCY 0x2254

/**
 * Multi/Phoenix Inverter measured voltage at AC input 1 L2 {sn16 = Multi/Phoenix
 * Inverter measured voltage at AC input 1 L2 [0.01V]}
 */
#define VE_REG_AC_INPUT_1_L2_VOLTAGE 0x2255

/**
 * Multi/Phoenix Inverter measured current AC input 1 L2 {sn16 = Multi/Phoenix
 * Inverter measured current AC input 1 L2 [0.01A]}
 */
#define VE_REG_AC_INPUT_1_L2_CURRENT 0x2256

/**
 * Multi/Phoenix Inverter measured power at AC input 1 L2 {sn32 =  Multi/Phoenix
 * Inverter measured power at AC input 1 L2 [1W]}
 */
#define VE_REG_AC_INPUT_1_L2_POWER 0x2257

/**
 * Multi/Phoenix Inverter measured power at AC input 1 L2 {sn32 = Multi/Phoenix
 * Inverter measured power at AC input 1 L2 [1VA]}
 */
#define VE_REG_AC_INPUT_1_L2_APPARENT_POWER 0x2258

/** Multi/Phoenix Inverter frequency at AC input 1 L2 {un16 = Frequency [0.01HZ]} */
#define VE_REG_AC_INPUT_1_L2_FREQUENCY 0x2259

/**
 * Multi/Phoenix Inverter measured voltage at AC input 1 L3 {sn16 = Multi/Phoenix
 * Inverter measured voltage at AC input 1 L3 [0.01V]}
 */
#define VE_REG_AC_INPUT_1_L3_VOLTAGE 0x225A

/**
 * Multi/Phoenix Inverter measured current AC input 1.L3 {sn16 = Multi/Phoenix
 * Inverter measured current AC input 1.L3 [0.01A]}
 */
#define VE_REG_AC_INPUT_1_L3_CURRENT 0x225B

/**
 * Multi/Phoenix Inverter measured power at AC input 1 L3 {sn32 =  Multi/Phoenix
 * Inverter measured power at AC input 1 L3 [1W]}
 */
#define VE_REG_AC_INPUT_1_L3_POWER 0x225C

/**
 * Multi/Phoenix Inverter measured power at AC input 1 L3 {sn32 = Multi/Phoenix
 * Inverter measured power at AC input 1 L3 [1VA]}
 */
#define VE_REG_AC_INPUT_1_L3_APPARENT_POWER 0x225D

/** Multi/Phoenix Inverter frequency at AC input 1 L3 {un16 = Frequency [0.01HZ]} */
#define VE_REG_AC_INPUT_1_L3_FREQUENCY 0x225E

/**
 * Multi/Phoenix Inverter measured voltage at AC input 2 L1 {sn16 = Multi/Phoenix
 * Inverter measured voltage at AC input 2 L1 [0.01V]}
 */
#define VE_REG_AC_INPUT_2_L1_VOLTAGE 0x2260

/**
 * Multi/Phoenix Inverter measured current AC input 2 L1 {sn16 = Multi/Phoenix
 * Inverter measured current AC input 2 L1 [0.01A]}
 */
#define VE_REG_AC_INPUT_2_L1_CURRENT 0x2261

/**
 * Multi/Phoenix Inverter measured power at AC input 2 L1 {sn32 =  Multi/Phoenix
 * Inverter measured power at AC input 2 L1 [1W]}
 */
#define VE_REG_AC_INPUT_2_L1_POWER 0x2262

/**
 * Multi/Phoenix Inverter measured power at AC input 2 L1 {sn32 = Multi/Phoenix
 * Inverter measured power at AC input 2 L1 [1VA]}
 */
#define VE_REG_AC_INPUT_2_L1_APPARENT_POWER 0x2263

/**
 * Multi/Phoenix Inverter frequency at AC input 2 L1 {un16 = Multi/Phoenix
 * Inverter frequency at AC input 2 L1 [0.01HZ]}
 */
#define VE_REG_AC_INPUT_2_L1_FREQUENCY 0x2264

/**
 * Multi/Phoenix Inverter measured voltage at AC input 2 L2 {sn16 = Multi/Phoenix
 * Inverter measured voltage at AC input 2 L2 [0.01V]}
 */
#define VE_REG_AC_INPUT_2_L2_VOLTAGE 0x2265

/**
 * Multi/Phoenix Inverter measured current AC input 2 L2 {sn16 = Multi/Phoenix
 * Inverter measured current AC input 2 L2 [0.01A]}
 */
#define VE_REG_AC_INPUT_2_L2_CURRENT 0x2266

/**
 * Multi/Phoenix Inverter measured power at AC input 2 L2 {sn32 =  Multi/Phoenix
 * Inverter measured power at AC input 2 L2 [1W]}
 */
#define VE_REG_AC_INPUT_2_L2_POWER 0x2267

/**
 * Multi/Phoenix Inverter measured power at AC input 2 L2 {sn32 = Multi/Phoenix
 * Inverter measured power at AC input 2 L2 [1VA]}
 */
#define VE_REG_AC_INPUT_2_L2_APPARENT_POWER 0x2268

/** Multi/Phoenix Inverter frequency at AC input 2 L2 {un16 = Frequency [0.01HZ]} */
#define VE_REG_AC_INPUT_2_L2_FREQUENCY 0x2269

/**
 * Multi/Phoenix Inverter measured voltage at AC input 2 L3 {sn16 = Multi/Phoenix
 * Inverter measured voltage at AC input 2 L3 [0.01V]}
 */
#define VE_REG_AC_INPUT_2_L3_VOLTAGE 0x226A

/**
 * Multi/Phoenix Inverter measured current AC input 2.L3 {sn16 = Multi/Phoenix
 * Inverter measured current AC input 2.L3 [0.01A]}
 */
#define VE_REG_AC_INPUT_2_L3_CURRENT 0x226B

/**
 * Multi/Phoenix Inverter measured power at AC input 2 L3 {sn32 =  Multi/Phoenix
 * Inverter measured power at AC input 2 L3 [1W]}
 */
#define VE_REG_AC_INPUT_2_L3_POWER 0x226C

/**
 * Multi/Phoenix Inverter measured power at AC input 2 L3 {sn32 = Multi/Phoenix
 * Inverter measured power at AC input 2 L3 [1VA]}
 */
#define VE_REG_AC_INPUT_2_L3_APPARENT_POWER 0x226D

/** Multi/Phoenix Inverter frequency at AC input 2 L3 {un16 = Frequency [0.01HZ]} */
#define VE_REG_AC_INPUT_2_L3_FREQUENCY 0x226E

/**
 * Remote input connector operation mode {un8 = data, 0 = Remote on/off, 1 = Two
 * signal BMS}
 */
#define VE_REG_REMOTE_MODE 0xD0C0

/** VE.Direct baudrate {un32 = rate, 0 = set to default} */
#define VE_REG_BAUDRATE 0xE800

/**
 * DC Input 1 MPP Mode {un8 = DC Input 1 MPP Mode, 0x00 = Off, 0x01 = Voltage or
 * current limited, 0x02 = MPP Tracker active, 0xFF = Not Available}
 */
#define VE_REG_DC_INPUT1_MPP_MODE 0xECC3

/** DC Input 1 Voltage {un16 = DC Input 1 Voltage [0.01V], 0xFFFF = Not Available} */
#define VE_REG_DC_INPUT1_VOLTAGE 0xECCB

/** DC Input 1 Power {un32 = DC Input 1 Power [0.01W], 0xFFFFFFFF = Not Available} */
#define VE_REG_DC_INPUT1_POWER 0xECCC

/** DC Input 1 Current {un16 = DC Input 1 Current [0.1A], 0xFFFF = Not Available} */
#define VE_REG_DC_INPUT1_CURRENT 0xECCD

/**
 * DC Input 2 MPP Mode {un8 = DC Input 2 MPP Mode, 0x00 = Off, 0x01 = Voltage or
 * current limited, 0x02 = MPP Tracker active, 0xFF = Not Available}
 */
#define VE_REG_DC_INPUT2_MPP_MODE 0xECD3

/** DC Input 2 Voltage {un16 = DC Input 2 Voltage [0.01V], 0xFFFF = Not Available} */
#define VE_REG_DC_INPUT2_VOLTAGE 0xECDB

/** DC Input 2 Power {un32 = DC Input 2 Power [0.01W], 0xFFFFFFFF = Not Available} */
#define VE_REG_DC_INPUT2_POWER 0xECDC

/** DC Input 2 Current {un16 = DC Input 2 Current [0.1A], 0xFFFF = Not Available} */
#define VE_REG_DC_INPUT2_CURRENT 0xECDD

/**
 * DC Input 3 MPP Mode {un8 = DC Input 3 MPP Mode, 0x00 = Off, 0x01 = Voltage or
 * current limited, 0x02 = MPP Tracker active, 0xFF = Not Available}
 */
#define VE_REG_DC_INPUT3_MPP_MODE 0xECE3

/** DC Input 3 Voltage {un16 = DC Input 3 Voltage [0.01V], 0xFFFF = Not Available} */
#define VE_REG_DC_INPUT3_VOLTAGE 0xECEB

/** DC Input 3 Power {un32 = DC Input 3 Power [0.01W], 0xFFFFFFFF = Not Available} */
#define VE_REG_DC_INPUT3_POWER 0xECEC

/** DC Input 3 Current {un16 = DC Input 3 Current [0.1A], 0xFFFF = Not Available} */
#define VE_REG_DC_INPUT3_CURRENT 0xECED

/**
 * DC Input 4 MPP Mode {un8 = DC Input 4 MPP Mode, 0x00 = Off, 0x01 = Voltage or
 * current limited, 0x02 = MPP Tracker active, 0xFF = Not Available}
 */
#define VE_REG_DC_INPUT4_MPP_MODE 0xECF3

/** DC Input 4 Voltage {un16 = DC Input 4 Voltage [0.01V], 0xFFFF = Not Available} */
#define VE_REG_DC_INPUT4_VOLTAGE 0xECFB

/** DC Input 4 Power {un32 = DC Input 4 Power [0.01W], 0xFFFFFFFF = Not Available} */
#define VE_REG_DC_INPUT4_POWER 0xECFC

/** DC Input 4 Current {un16 = DC Input 4 Current [0.1A], 0xFFFF = Not Available} */
#define VE_REG_DC_INPUT4_CURRENT 0xECFD

/**
 * Re-bulk delay {un16 = Re-bulk delay [1s], 0xFFFF = Not Available}
 * Any to bulk changeover on re-bulk voltage
 */
#define VE_REG_BAT_REBULK_DELAY 0xED1F

/**
 * Bulk delay {un16 = Bulk delay [1s], 0xFFFF = Not Available}
 * Bulk to absorption changeover delay
 */
#define VE_REG_BAT_BULK_DELAY 0xED20

/**
 * Absorption delay {un16 = Absorption delay [1s], 0xFFFF = Not Available}
 * Absorption to float changeover when using tail current
 */
#define VE_REG_BAT_ABSORPTION_DELAY 0xED21

/**
 * Equalisation delay {un16 = Equalisation delay [1s], 0xFFFF = Not Available}
 * End of automatic equalisation when voltage reached
 */
#define VE_REG_BAT_EQUALISATION_DELAY 0xED22

/**
 * Link parameter timeout {un16 = Link parameter timeout [1s], 0xFFFF = Not
 * Available}
 * Parallel charging: vset/iset parameter timeout
 */
#define VE_REG_BAT_LINK_PARAMETER_TIMEOUT 0xED23

/**
 * Current limiter timeout {un16 = Current limiter timeout [1s], 0xFFFF = Not
 * Available}
 * Bulk to absorption or Any to bulk changeover on current
 */
#define VE_REG_BAT_CURRENT_LIMITER_TIMEOUT 0xED24

/**
 * Minimum absorption time {un16 = Minimum absorption time [0.01hours], 0xFFFF =
 * Not Available}
 */
#define VE_REG_BAT_MIN_ABSORPTION_TIME 0xED25

/**
 * Manual equalisation duration {un16 = Manual equalisation duration [0.01hours],
 * 0xFFFF = Not Available}
 */
#define VE_REG_BAT_MANUAL_EQUALISATION_DURATION 0xED26

/**
 * Minimum float duration {un16 = Minimum float duration [0.01hours], 0xFFFF =
 * Not Available}
 */
#define VE_REG_BAT_MIN_FLOAT_DURATION 0xED27

/**
 * BMS Charge timeout {un16 = BMS Charge timeout [1s], 0xFFFF = Not Available}
 * When @ref VE_REG_BAT_BMS_PRESENT is set: time the device waits for the BMS to
 * take control.
 */
#define VE_REG_BAT_BMS_CHARGE_TIMEOUT 0xED28

/**
 * BMS Charge duration {un16 = BMS Charge duration [1s], 0xFFFF = Not Available}
 * When @ref VE_REG_BAT_BMS_PRESENT is set: after the charge timeout expires the
 * amount of time the charger will operate so the BMS can power-up.
 */
#define VE_REG_BAT_BMS_CHARGE_DURATION 0xED29

/**
 * Batterysafe DV/DT ramp {un16 = Batterysafe DV/DT ramp [0.01mV/minute], 0xFFFF
 * = Not Available}
 * If the DV/DT ramp is set to 0 the batterysafe mode is skipped.
 * Important for mppt chargers: always set the @ref VE_REG_BAT_VOLTAGE register
 * to the correct system voltage before writing to this register.
 */
#define VE_REG_BAT_BATTERYSAFE_DV_DT_RAMP 0xED2A

/**
 * BatterySafe gas voltage {un16 = BatterySafe gas voltage [0.01V], 0xFFFF = Not
 * Available}
 * Important for mppt chargers: always set the @ref VE_REG_BAT_VOLTAGE register
 * to the correct system voltage before writing to this register.
 */
#define VE_REG_BAT_BATTERYSAFE_GAS_VOLTAGE 0xED2B

/**
 * Battery intelligent start-up trip voltage {un16 = Battery intelligent start-up
 * trip voltage [0.01V], 0xFFFF = Not Available}
 * Currently only used in Skylla chargers: determines if the charger starts-up in
 * Bulk or Storage (empty vs. full battery).
 * Important for mppt chargers: always set the @ref VE_REG_BAT_VOLTAGE register
 * to the correct system voltage before writing to this register.
 */
#define VE_REG_BAT_INTELLIGENT_TRIP_VOLTAGE 0xED2C

/**
 * Battery intelligent open terminal voltage {un16 = Battery intelligent open
 * terminal voltage [0.01V], 0xFFFF = Not Available}
 * Currently only used in Skylla chargers with a FET splittet: determines if
 * there is a battery connected or if a terminal is left open.
 * Important for mppt chargers: always set the @ref VE_REG_BAT_VOLTAGE register
 * to the correct system voltage before writing to this register.
 */
#define VE_REG_BAT_INTELLIGENT_OPEN_VOLTAGE 0xED2D

/**
 * Battery Re-bulk Offset Voltage Level {un16 = Battery Re-bulk Offset Voltage
 * Level [0.01V], 0xFFFF = Not Available}
 * Set VE_REG_BAT_TYPE to 0xFF to use and read the user-defined setting.
 * write: always writes to the user-defined setting in non-volatile memory.
 * Important for mppt chargers: always set the @ref VE_REG_BAT_VOLTAGE register
 * to the correct system voltage before writing to this register.
 */
#define VE_REG_BAT_RE_BULK_OFFSET_V 0xED2E

/**
 * Battery Chemistry {un8 = Battery Chemistry, 0x00 = OPzS/OPzV, 0x01 = Gel/AGM,
 * 0x02 = Lithium Iron Phosphate (LiFePo4), 0xFF = User defined chemistry}
 */
#define VE_REG_BAT_CHEMISTRY 0xED2F

/**
 * Tank Capacity {un32 = Tank Capacity [0.0001m3]}
 * Tank sensor specific parameters - Tank capacity
 * @remark NMEA2000 equivalent: DD227 Tank Capacity as found in PGN 127505
 * (v2.000).
 */
#define VE_REG_TANK_CAPACITY 0xED4D

/**
 * Tank type {un8 = Tank type, type: 0=fuel, 1=fresh water, 2=waste water, 3=live
 * well, 4=oil, 5=black water (sewage) NMEA2000 equivalent: DD208 Fluid Type as
 * found in PGN 127505 (v2.000). Note that field this is 4-bits wide. New types
 * should be added from the top, taking the NMEA 2000 reserved values (6-15) in
 * account.@remark New types should be added from the top, taking the NMEA 2000
 * reserved values (6-15) in account.}
 */
#define VE_REG_TANK_TYPE 0xED4E

/** Tank level {un16 = level [0.1%]} */
#define VE_REG_TANK_LEVEL 0xED4F

/**
 * Charger Algorithm Timeout {un16 = Charger Algorithm Timeout, 0xFFFF = Not
 * Available}
 */
#define VE_REG_CHR_ALGO_TIMEOUT 0xED57

/**
 * actual load status channel 2. @remark status: 0=off, 1=on see @ref
 * VE_REG_DC_OUTPUT_STATUS {un8 = actual load status channel 2. @remark status:
 * 0=off, 1=on see @ref VE_REG_DC_OUTPUT_STATUS}
 */
#define VE_REG_DC_OUTPUT2_STATUS 0xED58

/**
 * actual load voltage channel 2 see @ref VE_REG_DC_OUTPUT_VOLTAGE. {un16 =
 * actual load voltage channel 2 see @ref VE_REG_DC_OUTPUT_VOLTAGE. [0.01V]}
 */
#define VE_REG_DC_OUTPUT2_VOLTAGE 0xED59

/**
 * actual load power channel 2 see @ref VE_REG_DC_OUTPUT_POWER. {un16 = actual
 * load power channel 2 see @ref VE_REG_DC_OUTPUT_POWER. [1W]}
 */
#define VE_REG_DC_OUTPUT2_POWER 0xED5A

/**
 * Load output specific parameters - load control channel 2 see @ref
 * VE_REG_DC_OUTPUT_CONTROL section for possible values see @ref
 * VE_REG_DC_OUTPUT_CONTROL. {un8 = Load output specific parameters - load
 * control channel 2 see @ref VE_REG_DC_OUTPUT_CONTROL section for possible
 * values see @ref VE_REG_DC_OUTPUT_CONTROL.}
 */
#define VE_REG_DC_OUTPUT2_CONTROL 0xED5B

/**
 * Load output offset voltage - load battery life algorithm channel 2 see @ref
 * VE_REG_DC_OUTPUT_OFFSET_VOLTAGE. {un8 = Load output offset voltage - load
 * battery life algorithm channel 2 see @ref VE_REG_DC_OUTPUT_OFFSET_VOLTAGE.
 * [0.01V]}
 */
#define VE_REG_DC_OUTPUT2_OFFSET_VOLTAGE 0xED5C

/**
 * Load output specific parameters - actual load current channel 2 see @ref
 * VE_REG_DC_OUTPUT_CURRENT. {un16 = Load output specific parameters - actual
 * load current channel 2 see @ref VE_REG_DC_OUTPUT_CURRENT. [0.1A]}
 */
#define VE_REG_DC_OUTPUT2_CURRENT 0xED5D

/**
 * Load output specific parameters - load current limit channel 2 see @ref
 * VE_REG_DC_OUTPUT_CURRENT_LIMIT. {un16 = Load output specific parameters - load
 * current limit channel 2 see @ref VE_REG_DC_OUTPUT_CURRENT_LIMIT. [0.1A]}
 */
#define VE_REG_DC_OUTPUT2_CURRENT_LIMIT 0xED5E

/**
 * Load output specific parameters - maximum allowed load current channel 2 see
 * VE_REG_DC_OUTPUT_MAeX_CURRENT. {un16 = Load output specific parameters -
 * maximum allowed load current channel 2 see VE_REG_DC_OUTPUT_MAeX_CURRENT.
 * [0.1A]}
 */
#define VE_REG_DC_OUTPUT2_MAX_CURRENT 0xED5F

/**
 * DC Channel 3 Ripple Voltage {un16 = DC Channel 3 Ripple Voltage [0.001V],
 * 0xFFFF = Not Available}
 */
#define VE_REG_DC_CHANNEL3_RIPPLE_VOLTAGE 0xED6B

/**
 * DC Channel 3 Current {sn32 = DC Channel 3 Current [0.001A], 0x7FFFFFFF = Not
 * Available}
 */
#define VE_REG_DC_CHANNEL3_CURRENT_MA 0xED6C

/**
 * DC Channel 3 Voltage {sn16 = DC Channel 3 Voltage [0.01V], 0x7FFF = Not
 * Available}
 */
#define VE_REG_DC_CHANNEL3_VOLTAGE 0xED6D

/** DC Channel 3 Power {sn16 = DC Channel 3 Power [1W], 0x7FFF = Not Available} */
#define VE_REG_DC_CHANNEL3_POWER 0xED6E

/**
 * DC Channel 3 Current {sn16 = DC Channel 3 Current [0.1A], 0x7FFF = Not
 * Available}
 */
#define VE_REG_DC_CHANNEL3_CURRENT 0xED6F

/**
 * DC Channel 2 Ripple Voltage {un16 = DC Channel 2 Ripple Voltage [0.001V],
 * 0xFFFF = Not Available}
 */
#define VE_REG_DC_CHANNEL2_RIPPLE_VOLTAGE 0xED7B

/**
 * DC Channel 2 Current {sn32 = DC Channel 2 Current [0.001A], 0x7FFFFFFF = Not
 * Available}
 */
#define VE_REG_DC_CHANNEL2_CURRENT_MA 0xED7C

/**
 * DC Channel 2 Voltage {sn16 = DC Channel 2 Voltage [0.01V], 0x7FFF = Not
 * Available}
 */
#define VE_REG_DC_CHANNEL2_VOLTAGE 0xED7D

/** DC Channel 2 Power {sn16 = DC Channel 2 Power [1W], 0x7FFF = Not Available} */
#define VE_REG_DC_CHANNEL2_POWER 0xED7E

/**
 * DC Channel 2 Current {sn16 = DC Channel 2 Current [0.1A], 0x7FFF = Not
 * Available}
 */
#define VE_REG_DC_CHANNEL2_CURRENT 0xED7F

/**
 * DC Channel 1 Ripple Voltage {un16 = DC Channel 1 Ripple Voltage [0.001V],
 * 0xFFFF = Not Available}
 */
#define VE_REG_DC_CHANNEL1_RIPPLE_VOLTAGE 0xED8B

/**
 * DC Channel 1 Current {sn32 = DC Channel 1 Current [0.001A], 0x7FFFFFFF = Not
 * Available}
 */
#define VE_REG_DC_CHANNEL1_CURRENT_MA 0xED8C

/**
 * DC Channel 1 Voltage {sn16 = DC Channel 1 Voltage [0.01V], 0x7FFF = Not
 * Available}
 */
#define VE_REG_DC_CHANNEL1_VOLTAGE 0xED8D

/** DC Channel 1 Power {sn16 = DC Channel 1 Power [1W], 0x7FFF = Not Available} */
#define VE_REG_DC_CHANNEL1_POWER 0xED8E

/**
 * DC Channel 1 Current {sn16 = DC Channel 1 Current [0.1A], 0x7FFF = Not
 * Available}
 */
#define VE_REG_DC_CHANNEL1_CURRENT 0xED8F

/**
 * DC output automatic energy selector timer {un16 = DC output automatic energy
 * selector timer, 0xFFFF = Not Available}
 */
#define VE_REG_DC_OUTPUT_AES_TIMER 0xED90

/**
 * DC output off reason {bits[1] = Battery Low, 0 = No, 1 = Yes : bits[1] = Over
 * Current, 0 = No, 1 = Yes : bits[1] = Timer Program, 0 = No, 1 = Yes : bits[1]
 * = Remote Off, 0 = No, 1 = Yes : bits[1] = Lumeter Off, 0 = No, 1 = Yes :
 * bits[1] = Paygo Off, 0 = No, 1 = Yes : bits[1] = VE_REG_DC_OUTPUT_RESERVED1, 0
 * = No, 1 = Yes : bits[1] = System Startup, 0 = No, 1 = Yes}
 */
#define VE_REG_DC_OUTPUT_OFF_REASON 0xED91

/**
 * DC Output RTC on time (debug) {un16 = DC Output RTC on time (debug), 0xFFFF =
 * Not Available}
 */
#define VE_REG_DC_OUTPUT_RTC_ON_TIME 0xED92

/**
 * DC Output RTC off time (debug) {un16 = DC Output RTC off time (debug), 0xFFFF
 * = Not Available}
 */
#define VE_REG_DC_OUTPUT_RTC_OFF_TIME 0xED93

/**
 * DC Output RTC  expected off time (debug) {un16 = DC Output RTC  expected off
 * time (debug), 0xFFFF = Not Available}
 */
#define VE_REG_DC_OUTPUT_RTC_EXPECTED_OFF_TIME 0xED94

/**
 * DC Output RTC expected on time (debug) {un16 = DC Output RTC expected on time
 * (debug), 0xFFFF = Not Available}
 */
#define VE_REG_DC_OUTPUT_RTC_EXPECTED_ON_TIME 0xED95

/**
 * DC Output sunset delay duration {un16 = DC Output sunset delay duration,
 * 0xFFFF = Not Available}
 */
#define VE_REG_DC_OUTPUT_SUNSET_DELAY 0xED96

/**
 * DC Output sunrise delay duration {un16 = DC Output sunrise delay duration,
 * 0xFFFF = Not Available}
 */
#define VE_REG_DC_OUTPUT_SUNRISE_DELAY 0xED97

/**
 * Ve.direct port rx function {un8 = Ve.direct port rx function, 0x00 = Remote
 * on/off, 0x01 = Load output config, 0x02 = Load output on/off remote control
 * (inverted), 0x03 = Load output on/off remote control (normal)}
 * Special function selection for the RX pin on the ve.direct port.
 */
#define VE_REG_VEDIRECT_PORT_RX_FUNCTION 0xED98

/**
 * DC Output Panel voltage day {un16 = DC Output Panel voltage day [0.01V],
 * 0xFFFF = Not Available, Charger load output specific parameters - panel day
 * voltage detection level}
 */
#define VE_REG_DC_OUTPUT_PANEL_VOLTAGE_DAY 0xED99

/**
 * DC Output Panel voltage night {un16 = DC Output Panel voltage night [0.01V],
 * 0xFFFF = Not Available, Charger load output specific parameters - panel night
 * voltage detection level}
 */
#define VE_REG_DC_OUTPUT_PANEL_VOLTAGE_NIGHT 0xED9A

/**
 * DC Output Lighting dim speed {un8 = DC Output Lighting dim speed, @remark dim:
 * valid range 0 till 100, 0=instantaneous change, x=1% change per x seconds,
 * e.g. 9 takes 15 minutes to dim from 0..100%}
 */
#define VE_REG_DC_OUTPUT_LIGHTING_DIM_SPEED 0xED9B

/**
 * DC Output Switch Low Level {un16 = DC Output Switch Low Level [0.01V], 0xFFFF
 * = Not Available, Charger load output specific parameters - user defined switch
 * low voltage level}
 */
#define VE_REG_DC_OUTPUT_SWITCH_LOW_LEVEL 0xED9C

/**
 * DC Output Switch High Level {un16 = DC Output Switch High Level [0.01V],
 * 0xFFFF = Not Available, Charger load output specific parameters - user defined
 * switch high voltage level}
 */
#define VE_REG_DC_OUTPUT_SWITCH_HIGH_LEVEL 0xED9D

/**
 * Ve.direct port tx function {un8 = Ve.direct port tx function, 0x00 = Ve.direct
 * communication, 0x01 = 0.01kWh pulses, 0x02 = Lighting PWM (normal), 0x03 =
 * Lighting PWM (inverted), Special function selection for the TX pin on the
 * ve.direct port see VE_REG_VEDIRECT_PORT_TX_FUNCTION section for possible
 * values.}
 */
#define VE_REG_VEDIRECT_PORT_TX_FUNCTION 0xED9E

/**
 * DC Output Lighting event 0 {sn16 = Time offset [1minutes] : un8 = Event code,
 * 0x01 = Sunset, 0x02 = Sunrise, 0x03 = Midnight : un8 = Dimlevel, valid range
 * 0..100 (0=load output off)}
 * Charger load output specific parameters - lighting controller event 0 event
 * code
 */
#define VE_REG_DC_OUTPUT_LIGHTING_EVENT0 0xEDA0

/**
 * DC Output Lighting event 1 {sn16 = Time offset [1minutes] : un8 = Event code,
 * 0x01 = Sunset, 0x02 = Sunrise, 0x03 = Midnight : un8 = Dimlevel, valid range
 * 0..100 (0=load output off)}
 */
#define VE_REG_DC_OUTPUT_LIGHTING_EVENT1 0xEDA1

/**
 * DC Output Lighting event 2 {sn16 = Time offset [1minutes] : un8 = Event code,
 * 0x01 = Sunset, 0x02 = Sunrise, 0x03 = Midnight : un8 = Dimlevel, valid range
 * 0..100 (0=load output off)}
 */
#define VE_REG_DC_OUTPUT_LIGHTING_EVENT2 0xEDA2

/**
 * DC Output Lighting event 3 {sn16 = Time offset [1minutes] : un8 = Event code,
 * 0x01 = Sunset, 0x02 = Sunrise, 0x03 = Midnight : un8 = Dimlevel, valid range
 * 0..100 (0=load output off)}
 */
#define VE_REG_DC_OUTPUT_LIGHTING_EVENT3 0xEDA3

/**
 * DC Output Lighting event 4 {sn16 = Time offset [1minutes] : un8 = Event code,
 * 0x01 = Sunset, 0x02 = Sunrise, 0x03 = Midnight : un8 = Dimlevel, valid range
 * 0..100 (0=load output off)}
 */
#define VE_REG_DC_OUTPUT_LIGHTING_EVENT4 0xEDA4

/**
 * DC Output Lighting event 5 {sn16 = Time offset [1minutes] : un8 = Event code,
 * 0x01 = Sunset, 0x02 = Sunrise, 0x03 = Midnight : un8 = Dimlevel, valid range
 * 0..100 (0=load output off)}
 */
#define VE_REG_DC_OUTPUT_LIGHTING_EVENT5 0xEDA5

/**
 * DC Output Lighting dimlevel {un8 = DC Output Lighting dimlevel, Charger load
 * output specific parameters - lighting controller dim setting . dim: valid
 * range 0..100 (0=load output off).@remark this vreg can be used to query the
 * current dimlevel when a timer program is active (e.g. to create an external
 * pwm signal)              }
 */
#define VE_REG_DC_OUTPUT_LIGHTING_DIM 0xEDA6

/** DC Output Midpoint shift {sn16 = DC Output Midpoint shift [1minutes]} */
#define VE_REG_DC_OUTPUT_MIDPOINT_SHIFT 0xEDA7

/**
 * DC Output Status {un8 = status, 0x00 = Output off, 0x01 = Output on, 0x02 =
 * Output scheduled to be activated, 0x03 = Attempting to activate output}
 */
#define VE_REG_DC_OUTPUT_STATUS 0xEDA8

/** DC Output Voltage {un16 = DC Output Voltage [0.01V], 0xFFFF = Not Available} */
#define VE_REG_DC_OUTPUT_VOLTAGE 0xEDA9

/** DC Output Power {un16 = DC Output Power [1W], 0xFFFF = Not Available} */
#define VE_REG_DC_OUTPUT_POWER 0xEDAA

/**
 * DC Output Control Mode {bits[4] = mode (see xml for meanings) : bits[1] =
 * reserved4 : bits[1] = reserved5 : bits[1] = reserved6 : bits[1] = Ve Reg Dc
 * Output Ctrl Light Flag, 0 = solar timer disabled, 1 = solar timer enabled}
 */
#define VE_REG_DC_OUTPUT_CONTROL 0xEDAB

/**
 * Charger load output offset voltage {un8 = Charger load output offset voltage
 * [0.01V]}
 */
#define VE_REG_DC_OUTPUT_OFFSET_VOLTAGE 0xEDAC

/** DC Output Current {un16 = DC Output Current [0.1A], 0xFFFF = Not Available} */
#define VE_REG_DC_OUTPUT_CURRENT 0xEDAD

/**
 * DC Output Current Limit {un16 = DC Output Current Limit [0.1A], 0xFFFF = Not
 * Available}
 */
#define VE_REG_DC_OUTPUT_CURRENT_LIMIT 0xEDAE

/**
 * DC Output Current Maximum {un16 = DC Output Current Maximum [0.1A], 0xFFFF =
 * Not Available, Charger load output specific parameters - maximum allowed load
 * current}
 */
#define VE_REG_DC_OUTPUT_MAX_CURRENT 0xEDAF

/**
 * DC Output Current Percentage {un8 = DC Output Current Percentage [1%], 0xFF =
 * Not Available}
 */
#define VE_REG_DC_OUTPUT_CURRENT_PERCENTAGE 0xEDB0

/**
 * DC Input Isolation Resistance {un32 = Resistance [1Ohm], 0xFFFFFFFF = Not
 * Available}
 */
#define VE_REG_DC_INPUT_RESISTANCE 0xEDB1

/**
 * DC Input Starting Voltage {un16 = DC Input Starting Voltage [0.01V], 0xFFFF =
 * Not Available}
 */
#define VE_REG_DC_INPUT_STARTING_VOLTAGE 0xEDB2

/**
 * DC Input MPP Mode (combined) {un8 = DC Input MPP Mode (combined), 0x00 = Off,
 * 0x01 = Voltage or current limited, 0x02 = MPP Tracker active, 0xFF = Not
 * Available}
 * Result = 0 when all off, 1 when at least one in voltage/current limit, 2 when
 * all in mppt tracking mode
 */
#define VE_REG_DC_INPUT_MPP_MODE 0xEDB3

/**
 * DC Input MPP Power {un32 = DC Input MPP Power [0.01W], 0xFFFFFFFF = Not
 * Available}
 */
#define VE_REG_DC_INPUT_MPP_POWER 0xEDB4

/**
 * DC Input MPP Voltage {un16 = DC Input MPP Voltage [0.01V], 0xFFFF = Not
 * Available}
 */
#define VE_REG_DC_INPUT_MPP_VOLTAGE 0xEDB5

/**
 * DC Input Open Circuit Voltage {un16 = DC Input Open Circuit Voltage [0.01V],
 * 0xFFFF = Not Available}
 */
#define VE_REG_DC_INPUT_OC_VOLTAGE 0xEDB6

/**
 * DC Input Disable Protection {un8 = protection, 0 = enabled, 1 = disabled,
 * Charger input specific parameters - disable automatic panel short circuit
 * mechanism}
 */
#define VE_REG_DC_INPUT_DISABLE_PROTECTION 0xEDB7

/**
 * DC Input Max Voltage {un16 = DC Input Max Voltage [0.01V], 0xFFFF = Not
 * Available}
 */
#define VE_REG_DC_INPUT_MAX_VOLTAGE 0xEDB8

/**
 * DC Input Voltage High Clear {un16 = DC Input Voltage High Clear [0.01V],
 * 0xFFFF = Not Available}
 */
#define VE_REG_DC_INPUT_HIGH_VOLTAGE_CLEAR 0xEDB9

/**
 * DC Input Voltage High Set {un16 = DC Input Voltage High Set [0.01V], 0xFFFF =
 * Not Available}
 */
#define VE_REG_DC_INPUT_HIGH_VOLTAGE_SET 0xEDBA

/** DC Input Voltage {un16 = DC Input Voltage [0.01V], 0xFFFF = Not Available} */
#define VE_REG_DC_INPUT_VOLTAGE 0xEDBB

/**
 * DC Input Power (total) {un32 = DC Input Power (total) [0.01W], 0xFFFFFFFF =
 * Not Available}
 */
#define VE_REG_DC_INPUT_POWER 0xEDBC

/** DC Input Current {un16 = DC Input Current [0.1A], 0xFFFF = Not Available} */
#define VE_REG_DC_INPUT_CURRENT 0xEDBD

/**
 * DC Input Current Limit {un16 = DC Input Current Limit [0.1A], 0xFFFF = Not
 * Available}
 */
#define VE_REG_DC_INPUT_CURRENT_LIMIT 0xEDBE

/**
 * DC Input Current Maximum {un16 = DC Input Current Maximum [0.1A], 0xFFFF = Not
 * Available}
 */
#define VE_REG_DC_INPUT_MAX_CURRENT 0xEDBF

/** Converter Frequency {un16 = Converter Frequency [1Hz], 0xFFFF = Not Available} */
#define VE_REG_CONVERTER_FREQUENCY 0xEDC0

/**
 * Maximum Equalisation Voltage (user settings range) {un16 = Maximum
 * Equalisation Voltage (user settings range) [0.01V]}
 */
#define VE_REG_CHR_MAX_EQUAL_V 0xEDC6

/**
 * Maximum Equalisation Current Percentage (user settings range) {un8 = Maximum
 * Equalisation Current Percentage (user settings range) [1%], 0xFF = Not
 * Available}
 */
#define VE_REG_CHR_MAX_EQUAL_PERCENTAGE 0xEDC7

/**
 * Charger Minimum Current {un16 = Charger Minimum Current [0.1A]}
 * The minimum configurable charge current.
 * @remark When this register is not specified, a value of 0A is assumed.
 */
#define VE_REG_CHR_MIN_CURRENT 0xEDC8

/**
 * Charger specific parameters - max. power {un32 = Charger specific parameters -
 * max. power [0.01W]}
 * The maximum allowed ouput power.
 */
#define VE_REG_CHR_MAX_POWER 0xEDC9

/**
 * Charger specific parameters - max. voltage loss compensation {un16 = Charger
 * specific parameters - max. voltage loss compensation [0.01V]}
 * This voltage setting is used to compensate for losses in the cabling,
 * connections and fuses in the installation.
 * The voltage is added to the voltage set-point in the charger, this voltage
 * scales with the actual charge current and
 * the maximum current the charger can supply (@ref VE_REG_CHR_MAX_CURRENT). Note
 * that this function will be disabled
 * automatically if voltage sense information is available.
 */
#define VE_REG_CHR_MAX_VOLTAGE_LOSS_COMP 0xEDCA

/**
 * Charger specific parameters - charge current during low current mode {un16 =
 * Charger specific parameters - charge current during low current mode [0.1A]}
 */
#define VE_REG_CHR_LOW_CURRENT 0xEDCB

/**
 * Charger Streetlight Version {un8 = Version, Charger specific parameters -
 * streetlight application version}
 */
#define VE_REG_CHR_STREETLIGHT_VERSION 0xEDCC

/** Charger History Version {un8 = Version} */
#define VE_REG_CHR_HISTORY_VERSION 0xEDCD

/**
 * Charger Voltage Settings Range {un8 = Min voltage [1V] (see xml for meanings)
 * : un8 = Max voltage [1V] (see xml for meanings)}
 */
#define VE_REG_CHR_VOLTAGE_SETTINGS_RANGE 0xEDCE

/**
 * Charger Maximum Power Yesterday
 * Charger specific parameters - charger group maximum power yesterday, unit is
 * 1W
 * @remark This used to be a un16 VREG, and was later changed to un32. The
 * VE.Direct MPPTs still have this implemented as a un16. Both the first and
 * second generation VE.Can MPPTs send this as a un32.
 */
#define VE_REG_CHR_YESTERDAY_PMAX 0xEDD0

/**
 * Charger Yield Yesterday
 * Charger specific parameters - charger group yield yesterday, unit is 0.01kWh
 * @remark This used to be a un16 VREG, and was later changed to un32. The
 * VE.Direct MPPTs still have this implemented as a un16. Both the first and
 * second generation VE.Can MPPTs send this as a un32.
 */
#define VE_REG_CHR_YESTERDAY_YIELD 0xEDD1

/**
 * Charger Maximum Power Today
 * Charger specific parameters - charger group maximum power today, unit is 1W
 * @remark This used to be a un16 VREG, and was later changed to un32. The
 * VE.Direct MPPTs still have this implemented as a un16. Both the first and
 * second generation VE.Can MPPTs send this as a un32.
 */
#define VE_REG_CHR_TODAY_PMAX 0xEDD2

/**
 * Charger Yield Today
 * Charger specific parameters - charger group yield today, unit is 0.01kWh
 * @remark This used to be a un16 VREG, and was later changed to un32. The
 * VE.Direct MPPTs still have this implemented as a un16. Both the first and
 * second generation VE.Can MPPTs send this as a un32.
 */
#define VE_REG_CHR_TODAY_YIELD 0xEDD3

/**
 * Charger Additional State Information {bits[1] = Safe Mode, 0 = Off, 1 = On :
 * bits[1] = Tptb Mode, 0 = Off, 1 = On : bits[1] = Repeated Abs, 0 = Off, 1 = On
 * : bits[1] = Low Inp Dim, 0 = Off, 1 = On : bits[1] = Temp Dim, 0 = Off, 1 = On
 * : bits[1] = Sense Dim, 0 = Off, 1 = On : bits[1] = Inp Cur Dim, 0 = Off, 1 =
 * On : bits[1] = Low Power Mode, 0 = Off, 1 = On}
 */
#define VE_REG_CHR_CUSTOM_STATE 0xEDD4

/**
 * Charger Voltage {un16 = Charger Voltage [0.01V], 0xFFFF = Not Available,
 * Charger specific parameters - actual charge voltage                @remark HEX
 * protocol compat. data present in regular NMEA pgn}
 */
#define VE_REG_CHR_VOLTAGE 0xEDD5

/** Charger Power {un16 = Power [1W], 0xFFFF = Not Available} */
#define VE_REG_CHR_POWER 0xEDD6

/**
 * Charger Current {sn16 = Charger Current [0.1A], 0x7FFF = Not Available,
 * Charger specific parameters - actual charge current                @remark HEX
 * protocol compat. data present in regular NMEA pgn}
 */
#define VE_REG_CHR_CURRENT 0xEDD7

/** Charger Relay State {un8 = Relay State, 0x00 = Open, 0x01 = Closed} */
#define VE_REG_CHR_RELAY_CONTROL 0xEDD8

/**
 * Charger Relay Mode {un8 = Relay Mode (see xml for meanings), WARNING:
 * unsupported values are accepted!}
 * @remark use @ref VE_REG_RELAY_MODE for future products.
 */
#define VE_REG_CHR_RELAY_MODE 0xEDD9

/**
 * Charger Error Code {un8 = Error Code (see xml for meanings)}
 * @remark note: this vreg should also be used by non-charger products (e.g.
 * Battery Protect).
 */
#define VE_REG_CHR_ERROR_CODE 0xEDDA

/** Charger Temperature {sn16 = Charger Temperature [0.01°C]} */
#define VE_REG_CHR_TEMPERATURE 0xEDDB

/**
 * Charger User Yield {un32 = Charger User Yield [0.01kWh], 0xFFFFFFFF = Not
 * Available}
 * @remark use @ref VE_REG_CLEAR_HISTORY to clear
 */
#define VE_REG_CHR_USER_YIELD 0xEDDC

/**
 * Charger System Yield {un32 = Charger System Yield [0.01kWh], 0xFFFFFFFF = Not
 * Available}
 */
#define VE_REG_CHR_SYSTEM_YIELD 0xEDDD

/** Charger number of physical outputs {un8 = Outputs} */
#define VE_REG_CHR_OUTPUTS 0xEDDE

/**
 * Charger Maximum Current {un16 = Charger Maximum Current [0.1A], 0xFFFF = Not
 * Available}
 */
#define VE_REG_CHR_MAX_CURRENT 0xEDDF

/**
 * Battery low temperature level {sn16 = Battery low temperature level [0.01°C]}
 * Default value is 5C. Make sure to use hysteresis in the implementation.
 * Relates to @ref VE_REG_BAT_LOW_TEMP_CHARGE_CURRENT for the charge current
 * level.
 */
#define VE_REG_BAT_LOW_TEMP_LEVEL 0xEDE0

/**
 * Battery Re-bulk Current Level {un16 = Battery Re-bulk Current Level [0.1A],
 * 0xFFFF = Not Available}
 * Set VE_REG_BAT_TYPE to 0xFF to use and read the user-defined setting.
 * write: always writes to the user-defined setting in non-volatile memory.
 */
#define VE_REG_BAT_RE_BULK_I 0xEDE1

/**
 * Battery Re-bulk Voltage Level {un16 = Battery Re-bulk Voltage Level [0.01V],
 * 0xFFFF = Not Available}
 * @deprecated Use VE_REG_BAT_RE_BULK_OFFSET_V instead
 */
#define VE_REG_BAT_RE_BULK_V 0xEDE2

/**
 * Battery Equalisation Time Duration {un16 = Battery Equalisation Time Duration
 * [0.01hours]}
 * Set VE_REG_BAT_TYPE to 0xFF to use and read the user-defined setting.
 * write: always writes to the user-defined setting in non-volatile memory.
 */
#define VE_REG_BAT_EQUAL_DURATION 0xEDE3

/**
 * Battery Equalisation Current Percentage {un8 = Battery Equalisation Current
 * Percentage [1%], 0xFF = Not Available}
 * Set VE_REG_BAT_TYPE to 0xFF to use and read the user-defined setting.
 * write: always writes to the user-defined setting in non-volatile memory.
 */
#define VE_REG_BAT_EQUAL_PERCENTAGE 0xEDE4

/**
 * Battery Equalisation Auto Stop {un8 = Battery Equalisation Auto Stop, 0 = No,
 * 1 = Yes}
 * Set VE_REG_BAT_TYPE to 0xFF to use and read the user-defined setting.
 * write: always writes to the user-defined setting in non-volatile memory.
 */
#define VE_REG_BAT_EQUAL_AUTOSTOP 0xEDE5

/**
 * low-temp charge current {un16 = low-temp charge current [0.1A], 0 = stop
 * charging, 0xFFFF = use maximum charger current}
 * Set VE_REG_BAT_TYPE to 0xFF to use and read the user-defined setting.
 * write: always writes to the user-defined setting in non-volatile memory.
 * "0=stop charging" for built-in lithium battery types, "0xFFFF=full charge
 * current"
 * for other types.
 * Relates to @ref VE_REG_BAT_LOW_TEMP_LEVEL for the temperature level.
 * This mechanism is only to be used when the temperature information is accurate
 * (i.e. no estimate based on the charger internal temperature).
 */
#define VE_REG_BAT_LOW_TEMP_CHARGE_CURRENT 0xEDE6

/**
 * Battery Tail Current {un16 = Battery Tail Current [0.1A], 0xFFFF = Not
 * Available}
 */
#define VE_REG_BAT_TAIL_CURRENT 0xEDE7

/**
 * BMS Present {un8 = BMS Present, 0 = No, 1 = Yes}
 * @remark : note: this setting will automatically change to 1 (=present) when a
 * BMS is detected on the bus
 */
#define VE_REG_BAT_BMS_PRESENT 0xEDE8

/**
 * Power Supply Mode Voltage {un16 = Power Supply Mode Voltage [0.01V], 0xFFFF =
 * Not Available, Charger battery parameters - power supply mode voltage setting
 * .read: the parameter as it is currently in use (set VE_REG_BAT_TYPE to 0xFF to
 * use and read the user-defined setting).write: always writes to the user-
 * defined setting in non-volatile memory important for mppt chargers@remark
 * Important for mppt chargers: always set the @ref VE_REG_BAT_VOLTAGE register
 * to the correct system voltage before writing to this register}
 */
#define VE_REG_BAT_PSU_V 0xEDE9

/**
 * Battery Voltage Setting {un8 = Battery Voltage Setting [1V] (see xml for
 * meanings)}
 * @remark note: only present on models that support multiple operating voltages
 * (e.g. mppt chargers)
 */
#define VE_REG_BAT_VOLTAGE_SETTING 0xEDEA

/**
 * Battery Overcharge Voltage Level (upper alarm boundary) {un16 = Battery
 * Overcharge Voltage Level (upper alarm boundary) [0.01V], 0xFFFF = Not
 * Available, high voltage alarm do not implement this vreg in tooling, use
 * VE_REG_RELAY_HIGH_VOLTAGE_SET and VE_REG_RELAY_HIGH_VOLTAGE_CLEAR instead used
 * in all Skylla-i chargers and ve.can mppt <v2.00 important for mppt chargers:
 * always set the VE_REG_BAT_VOLTAGE register to the correct system voltage
 * before writing to this register}
 */
#define VE_REG_BAT_HIGH_V 0xEDEB

/** Battery Temperature {un16 = Battery Temperature [0.01K], 0xFFFF = Unavailable} */
#define VE_REG_BAT_TEMPERATURE 0xEDEC

/**
 * Battery Intelligent Mode {un8 = Intelligent Mode, 0 = Off, 1 = On, (detect
 * state of charge at startup) read: the parameter as it is currently in use (set
 * VE_REG_BAT_TYPE to 0xFF to use and read the user-defined setting).
 * @remark write: always writes to the user-defined setting in non-volatile
 * memory.                }
 */
#define VE_REG_BAT_INTELLIGENT_MODE 0xEDED

/**
 * Battery Storage Mode {un8 = Storage Mode, 0 = Off, 1 = On, read: the parameter
 * as it is currently in use (set VE_REG_BAT_TYPE to 0xFF to use and read the
 * user-defined setting).                @remark write: always writes to the
 * user-defined setting in non-volatile memory}
 */
#define VE_REG_BAT_STORAGE_MODE 0xEDEE

/**
 * Battery Voltage Selection {un8 = Battery Voltage Selection [1V] (see xml for
 * meanings), this vreg reports the actual voltage used (relevant for devices
 * with automatic voltage detection), use VE_REG_BAT_VOLTAGE_SETTING to get the
 * user setting ve.direct mppt <v1.08: read = get user battery voltage setting,
 * write = set user battery voltage setting ve.direct mppt >v1.09: read = get
 * detected battery voltage, write = set user battery voltage setting ve.can
 * mppt <v2.00: read = get user battery voltage setting, write = set user
 * battery voltage setting ve.can mppt >v2.01: read = get detected battery
 * voltage, write = set user battery voltage setting note: for models that do not
 * report the detected voltage: the detected voltage can be derived from the
 * battery                parameters (e.g. VE_REG_BAT_ABSORPTION_V)}
 */
#define VE_REG_BAT_VOLTAGE 0xEDEF

/**
 * Battery Maximum Current {un16 = Battery Maximum Current [0.1A], 0xFFFF = Not
 * Available, read: the parameter as it is currently in use (set VE_REG_BAT_TYPE
 * to 0xFF to use and read the user-defined setting).                @remark
 * write: always writes to the user-defined setting in non-volatile memory.}
 */
#define VE_REG_BAT_MAX_CURRENT 0xEDF0

/**
 * Battery Type {un8 = Battery Type, 0x00 = charger disabled, 0xFF = User
 * Defined}
 */
#define VE_REG_BAT_TYPE 0xEDF1

/**
 * Battery Temperature Compensation Level {sn16 = Temperature Compensation
 * [0.01mV/°C], read: the parameter as it is currently in use (set
 * VE_REG_BAT_TYPE to 0xFF to use and read the user-defined setting) write:
 * always writes to the user-defined setting in non-volatile memory.@remark
 * Important for mppt chargers: always set the @ref VE_REG_BAT_VOLTAGE register
 * to the correct system voltage before writing to this register              }
 */
#define VE_REG_BAT_TEMP_COMP 0xEDF2

/**
 * Battery Discharge Voltage Level (lower alarm boundary) {un16 = Battery
 * Discharge Voltage Level (lower alarm boundary) [0.01V], 0xFFFF = Not
 * Available, low voltage alarm do not implement this vreg in tooling, use @ref
 * VE_REG_RELAY_LOW_VOLTAGE_SET and @REF VE_REG_RELAY_LOW_VOLTAGE_CLEAR instead
 * used in all Skylla-i chargers and ve.can mppt chargers up to and including
 * 2.00 important for mppt chargers: always set the VE_REG_BAT_VOLTAGE register
 * to the correct system voltage before writing to this register}
 */
#define VE_REG_BAT_DISCHARGE_V 0xEDF3

/**
 * Battery Equalisation Voltage Level {un16 = Battery Equalisation Voltage Level
 * [0.01V], 0xFFFF = Not Available}
 * Set VE_REG_BAT_TYPE to 0xFF to use and read the user-defined setting.
 * write: always writes to the user-defined setting in non-volatile memory.
 * Important for mppt chargers: always set the @ref VE_REG_BAT_VOLTAGE register
 * to the correct system voltage before writing to this register.
 */
#define VE_REG_BAT_EQUAL_V 0xEDF4

/**
 * Battery Storage Voltage Level {un16 = Battery Storage Voltage Level [0.01V],
 * 0xFFFF = Not Available}
 * Set VE_REG_BAT_TYPE to 0xFF to use and read the user-defined setting.
 * write: always writes to the user-defined setting in non-volatile memory.
 * Important for mppt chargers: always set the @ref VE_REG_BAT_VOLTAGE register
 * to the correct system voltage before writing to this register.
 */
#define VE_REG_BAT_STORAGE_V 0xEDF5

/**
 * Battery Float Voltage Level {un16 = Battery Float Voltage Level [0.01V],
 * 0xFFFF = Not Available}
 * Set VE_REG_BAT_TYPE to 0xFF to use and read the user-defined setting.
 * write: always writes to the user-defined setting in non-volatile memory.
 * Important for mppt chargers: always set the @ref VE_REG_BAT_VOLTAGE register
 * to the correct system voltage before writing to this register.
 */
#define VE_REG_BAT_FLOAT_V 0xEDF6

/**
 * Battery Absorption Voltage Level {un16 = Battery Absorption Voltage Level
 * [0.01V], 0xFFFF = Not Available}
 * Set VE_REG_BAT_TYPE to 0xFF to use and read the user-defined setting.
 * write: always writes to the user-defined setting in non-volatile memory.
 * Important for mppt chargers: always set the @ref VE_REG_BAT_VOLTAGE register
 * to the correct system voltage before writing to this register.
 */
#define VE_REG_BAT_ABSORPTION_V 0xEDF7

/**
 * Battery Repeated Absorption Time Interval {un16 = Battery Repeated Absorption
 * Time Interval [0.01days]}
 * Set VE_REG_BAT_TYPE to 0xFF to use and read the user-defined setting.
 * write: always writes to the user-defined setting in non-volatile memory.
 */
#define VE_REG_BAT_REPABS_T_INT 0xEDF8

/**
 * Battery Repeated Absorption Time Duration {un16 = Battery Repeated Absorption
 * Time Duration [0.01hours]}
 * Set VE_REG_BAT_TYPE to 0xFF to use and read the user-defined setting.
 * write: always writes to the user-defined setting in non-volatile memory.
 */
#define VE_REG_BAT_REPABS_T_DUR 0xEDF9

/**
 * Battery Float Time Limit {un16 = Battery Float Time Limit [0.01hours], 0x0000
 * = Off}
 * Set VE_REG_BAT_TYPE to 0xFF to use and read the user-defined setting.
 * write: always writes to the user-defined setting in non-volatile memory.
 */
#define VE_REG_BAT_FLOAT_T_LIMIT 0xEDFA

/**
 * Battery Absorption Time Limit {un16 = Battery Absorption Time Limit
 * [0.01hours], 0x0000 = Off}
 * Set VE_REG_BAT_TYPE to 0xFF to use and read the user-defined setting.
 * write: always writes to the user-defined setting in non-volatile memory.
 */
#define VE_REG_BAT_ABS_T_LIMIT 0xEDFB

/**
 * Battery Bulk Time Limit {un16 = Battery Bulk Time Limit [0.01hours], 0x0000 =
 * Off}
 * Set VE_REG_BAT_TYPE to 0xFF to use and read the user-defined setting.
 * write: always writes to the user-defined setting in non-volatile memory.
 */
#define VE_REG_BAT_BULK_T_LIMIT 0xEDFC

/**
 * Battery Automatic Equalisation Mode {un8 = Battery Automatic Equalisation
 * Mode, 0x0000 = Off, MPPT chargers: 1..250=repeat every n days (1=every day,
 * 2=every other day, etc);others: 1=ON (every charge cycle).            }
 * Set VE_REG_BAT_TYPE to 0xFF to use and read the user-defined setting.
 * write: always writes to the user-defined setting in non-volatile memory.
 */
#define VE_REG_BAT_AUTO_EQUALISE_MODE 0xEDFD

/**
 * Battery Adaptive Mode {un8 = Battery Adaptive Mode, 0 = Off, 1 = On}
 * Set VE_REG_BAT_TYPE to 0xFF to use and read the user-defined setting.
 * write: always writes to the user-defined setting in non-volatile memory.
 */
#define VE_REG_BAT_ADAPTIVE_MODE 0xEDFE

/**
 * Battery Safe Mode {un8 = Battery Safe Mode, 0 = Off, 1 = On}
 * Set VE_REG_BAT_TYPE to 0xFF to use and read the user-defined setting.
 * write: always writes to the user-defined setting in non-volatile memory.
 */
#define VE_REG_BAT_SAFE_MODE 0xEDFF

/** Only used to support the BMV, use @ref VE_REG_HIST_DEEPEST_DISCHARGE instead. */
#define VE_REG_BMV_H1 0xEE00

/** Only used to support the BMV, use @ref VE_REG_HIST_LAST_DISCHARGE instead. */
#define VE_REG_BMV_H2 0xEE01

/**
 * Only used to support the BMV, use @ref VE_REG_HIST_NR_OF_CHARGE_CYCLES
 * instead.
 */
#define VE_REG_BMV_H3 0xEE02

/**
 * Only used to support the BMV, use @ref VE_REG_HIST_NR_OF_FULL_DISCHARGES
 * instead.
 */
#define VE_REG_BMV_H4 0xEE03

/** Only used to support the BMV, use @ref VE_REG_HIST_CUMULATIVE_AH instead. */
#define VE_REG_BMV_H5 0xEE04

/** Only used to support the BMV, use @ref VE_REG_HIST_MIN_VOLTAGE instead. */
#define VE_REG_BMV_H6 0xEE05

/** Only used to support the BMV, use @ref VE_REG_HIST_MAX_VOLTAGE instead. */
#define VE_REG_BMV_H7 0xEE06

/**
 * Only used to support the BMV, use @ref VE_REG_HIST_SECS_SINCE_LAST_FULL_CHARGE
 * instead.
 */
#define VE_REG_BMV_H8 0xEE07

/**
 * Only used to support the BMV, use @ref VE_REG_HIST_SECS_SINCE_LAST_FULL_CHARGE
 * instead.
 */
#define VE_REG_BMV_H9 0xEE08

/** Only used to support the BMV, use @ref VE_REG_HIST_NR_OF_AUTO_SYNCS instead. */
#define VE_REG_BMV_H10 0xEE09

/**
 * Only used to support the BMV, use @ref VE_REG_HIST_NR_OF_LOW_VOLTAGE_ALARMS
 * instead.
 */
#define VE_REG_BMV_H11 0xEE0A

/**
 * Only used to support the BMV, use @ref VE_REG_HIST_NR_OF_HIGH_VOLTAGE_ALARMS
 * instead.
 */
#define VE_REG_BMV_H12 0xEE0B

/**
 * Only used to support the BMV, use @ref VE_REG_HIST_NR_OF_LOW_VOLTAGE_2_ALARMS
 * instead.
 */
#define VE_REG_BMV_H13 0xEE0C

/**
 * Only used to support the BMV, use @ref VE_REG_HIST_NR_OF_HIGH_VOLTAGE_2_ALARMS
 * instead.
 */
#define VE_REG_BMV_H14 0xEE0D

/** Only used to support the BMV, use @ref VE_REG_HIST_MIN_VOLTAGE_2 instead. */
#define VE_REG_BMV_H15 0xEE0E

/** Only used to support the BMV, use @ref VE_REG_HIST_MAX_VOLTAGE_2 instead. */
#define VE_REG_BMV_H16 0xEE0F

/**
 * Battery temperature sensor source {un8 = Battery temperature sensor source
 * (see xml for meanings)}
 */
#define VE_REG_BAT_TEMPERATURE_SENSE_SOURCE 0xEE10

/**
 * Battery voltage sensor source {un8 = Battery voltage sensor source (see xml
 * for meanings)}
 */
#define VE_REG_BAT_VOLTAGE_SENSE_SOURCE 0xEE11

/**
 * Battery Temperature (estimated) {un16 = Battery Temperature (estimated)
 * [0.01K], 0xFFFF = Unavailable}
 */
#define VE_REG_BAT_TEMPERATURE_EST 0xEE12

/**
 * Battery Temperature Offset {sn16 = Battery Temperature Offset [0.01K], 0x7FFF
 * = Unavailable}
 * Real battery voltage = Measured battery voltage + offset
 */
#define VE_REG_BAT_TEMPERATURE_OFFSET 0xEE13

/**
 * Power Supply Mode Minimum Voltage {un16 = Power Supply Mode Minimum Voltage
 * [0.01V], 0xFFFF = Not Available}
 * Charger battery parameters - power supply mode minimum voltage setting.
 * @remark When this register is not present, check if @ref
 * VE_REG_VOLTAGE_RANGE_MIN is present and use this.
 */
#define VE_REG_BAT_PSU_V_MIN 0xEE14

/**
 * Power Supply Mode Maximum Voltage {un16 = Power Supply Mode Maximum Voltage
 * [0.01V], 0xFFFF = Not Available}
 * Charger battery parameters - power supply mode maximum voltage setting.
 * @remark When this register is not present, check if @ref
 * VE_REG_VOLTAGE_RANGE_MAX is present and use this.
 */
#define VE_REG_BAT_PSU_V_MAX 0xEE15

/**
 * Battery Used VSense {un16 = Battery Used VSense [0.01V], 0xFFFF = Not
 * Available}
 * The used vsense value
 */
#define VE_REG_BAT_VSENSE_USED 0xEE16

/**
 * Battery Re-bulk Method {un8 = Battery Re-bulk Method, 0 = Voltage, 1 =
 * Constant Current}
 * The used re-bulk method
 */
#define VE_REG_BAT_RE_BULK_METHOD 0xEE17

/**
 * MQTT device IPv4 Address {un32 = address, The ipv4 address of the found mqtt
 * device in network-byte-order/big-endian.}
 * This is used by the VeInterfaces mqtt stack inside VictronConnect to publish
 * the ip address of a found device to the vreg-translator/gui layer.
 */
#define VE_REG_MQTT_IPV4_ADDRESS 0xEC0F

/**
 * BMS flags { : bits[1] = Under Temperature, 0 = No, 1 = Yes : bits[1] = Short
 * Circuit, 0 = No, 1 = Yes : bits[1] = Hardware Failure, 0 = No, 1 = Yes :
 * bits[1] = Allowed to Charge, 0 = No, 1 = Yes : bits[1] = Allowed To Discharge,
 * 0 = No, 1 = Yes : bits[1] = Pre Alarm Active, 0 = No, 1 = Yes : bits[1] = Bad
 * Contacter warning, 0 = No, 1 = Yes : bits[1] = High current alarm, 0 = No, 1 =
 * Yes : }
 * @remark Bit 0-21 maps 1-on-1 on VE_REG_LYNX_ION_FLAGS (0x0370). The Lynx Ion
 * (+ Shunt) has been develop by an external company (MG Electronics). In order
 * to prevent conflicts for bit 22-31 a new register has been defined.
 */
#define VE_REG_BMS_FLAGS 0x2100

/**
 * BMS error {un8 = BMS error (see xml for meanings)}
 * @remark see VE_REG_BMS_ERROR section for possible values
 */
#define VE_REG_BMS_ERROR 0x2101

/** BMS state {un8 = State (see xml for meanings)} */
#define VE_REG_BMS_STATE 0x2102

/**
 * BMS settings {bits[1] = use pre-alarm, 0 = pre-alarm not available, 1 = use
 * pre-alarm : bits[1] = continuous alarm mode, 0 = intermittent, 1 = continues :
 * bits[1] = follow remote, 0 = REMOTE ignored, 1 = BMS disabled when REMOTE is
 * off : bits[1] = Pre alarm DCL, 0 = No, 1 = Yes, Weather a pre alarm causes the
 * discharge current limit to be set to 0 : bits[1] = Enable DVCC, 0 = No, 1 =
 * Yes, Sets if distributed voltage and current control is enabled : }
 * bitmask with BMS settings
 */
#define VE_REG_BMS_SETTINGS 0x2103

/** BMS relay mode {un8 = Relay mode, 0 = alarm, 1 = alternator ATC} */
#define VE_REG_BMS_RELAY_MODE 0x2104

/**
 * Standby timeout {un16 = Standby timeout [1hours]}
 * Standby to Hibernate time in hours
 */
#define VE_REG_STANDBY_TIMEOUT 0x2105

/**
 * BMS warnings and alarms {bits[2] = Low cell voltage, 0 = Unsupported, 1 = OK,
 * 2 = Warning, 3 = Alarm : bits[2] = High Current, 0 = Unsupported, 1 = OK, 2 =
 * Warning, 3 = Alarm : bits[2] = High BMS temperature, 0 = Unsupported, 1 = OK,
 * 2 = Warning, 3 = Alarm : bits[2] = High contactor resistance, 0 = Unsupported,
 * 1 = OK, 2 = Warning, 3 = Alarm : bits[2] = BMS cable fault, 0 = Unsupported, 1
 * = OK, 2 = Warning, 3 = Alarm : bits[2] = Load disconnect, 0 = Unsupported, 1 =
 * OK, 2 = Warning, 3 = Alarm : }
 * BMS warning and alarm flags
 */
#define VE_REG_BMS_WARNINGS_ALARMS 0x2107

/**
 * BMS IO flags {bits[2] = Contactor closed, 0 = Not available, 1 = Yes, 2 = No :
 * bits[2] = Allowed to charge, 0 = Not available, 1 = Yes, 2 = No : bits[2] =
 * Allowed to discharge, 0 = Not available, 1 = Yes, 2 = No : bits[2] = User
 * relay active, 0 = Not available, 1 = Yes, 2 = No : bits[2] = Aux output
 * enabled, 0 = Not available, 1 = Yes, 2 = No : bits[2] = Remote enabled, 0 =
 * Not available, 1 = Yes, 2 = No : bits[2] = Alternator allowed to charge, 0 =
 * Not available, 1 = Yes, 2 = No : }
 * BMS IO flags
 */
#define VE_REG_BMS_IO 0x2108

/**
 * BMS warnings {bits[2] = High cell voltage or low temperature, 0 = Not
 * available, 1 = Yes, 2 = No : bits[2] = Low cell voltage, 0 = Not available, 1
 * = Yes, 2 = No : bits[2] = High charge current, 0 = Not available, 1 = Yes, 2 =
 * No : bits[2] = High discharge current, 0 = Not available, 1 = Yes, 2 = No :
 * bits[2] = High BMS temperature, 0 = Not available, 1 = Yes, 2 = No : bits[2] =
 * High contactor resistance, 0 = Not available, 1 = Yes, 2 = No}
 * BMS warning flags
 */
#define VE_REG_BMS_WARNING 0x2109

/**
 * BMS alarms {bits[2] = High cell voltage or low temperature, 0 = Not available,
 * 1 = Yes, 2 = No : bits[2] = Low cell voltage, 0 = Not available, 1 = Yes, 2 =
 * No : bits[2] = Pre alarm, 0 = Not available, 1 = Yes, 2 = No : bits[2] = High
 * current, 0 = Not available, 1 = Yes, 2 = No : bits[2] = BMS cable
 * disconnected, 0 = Not available, 1 = Yes, 2 = No}
 * BMS alarm flags
 */
#define VE_REG_BMS_ALARM 0x210A

/**
 * Minimum SOC {un16 = Minimum SOC [0.1%]}
 * Lynx discharge floor
 */
#define VE_REG_MIN_SOC 0x210B

/**
 * BMS: Last errors {un8 = Error 1 (see xml for meanings), Last error : un8 =
 * Error 2 (see xml for meanings) : un8 = Error 3 (see xml for meanings) : un8 =
 * Error 4 (see xml for meanings), Oldest error}
 */
#define VE_REG_BMS_LAST_ERRORS 0x2110

/** BMS: UTC time of last error 1 {un32 = BMS: UTC time of last error 1} */
#define VE_REG_BMS_LAST_ERROR1_TIME 0x2111

/** BMS: UTC time of last error 2 {un32 = BMS: UTC time of last error 2} */
#define VE_REG_BMS_LAST_ERROR2_TIME 0x2112

/** BMS: UTC time of last error 3 {un32 = BMS: UTC time of last error 3} */
#define VE_REG_BMS_LAST_ERROR3_TIME 0x2113

/** BMS: UTC time of last error 4 {un32 = BMS: UTC time of last error 4} */
#define VE_REG_BMS_LAST_ERROR4_TIME 0x2114

/**
 * uptime timestamp of last error 1 {un32 = uptime timestamp of last error 1
 * [1s]}
 * Error1 uptime timestamp in seconds
 */
#define VE_REG_LYNX_ERROR1_TIMESTAMP 0x2115

/**
 * uptime timestamp of last error 2 {un32 = uptime timestamp of last error 2
 * [1s]}
 * Error2 uptime timestamp in seconds
 */
#define VE_REG_LYNX_ERROR2_TIMESTAMP 0x2116

/**
 * uptime timestamp of last error 3 {un32 = uptime timestamp of last error 3
 * [1s]}
 * Error3 uptime timestamp in seconds
 */
#define VE_REG_LYNX_ERROR3_TIMESTAMP 0x2117

/**
 * uptime timestamp of last error 4 {un32 = uptime timestamp of last error 4
 * [1s]}
 * Error4 uptime timestamp in seconds
 */
#define VE_REG_LYNX_ERROR4_TIMESTAMP 0x2118

/**
 * {bits[2] = Low battery voltage, 0 = Not available, 1 = Yes, 2 = No : bits[2] =
 * High battery voltage, 0 = Not available, 1 = Yes, 2 = No : bits[2] = Low SOC,
 * 0 = Not available, 1 = Yes, 2 = No : bits[2] = Low fused voltage, 0 = Not
 * available, 1 = Yes, 2 = No : bits[2] = High fused voltage, 0 = Not available,
 * 1 = Yes, 2 = No : bits[2] = Fuse blown, 0 = Not available, 1 = Yes, 2 = No :
 * bits[2] = High battery temperature, 0 = Not available, 1 = Yes, 2 = No :
 * bits[2] = Low battery temperature, 0 = Not available, 1 = Yes, 2 = No :
 * bits[2] = High internal temperature, 0 = Not available, 1 = Yes, 2 = No}
 * Lynx user relay reason
 */
#define VE_REG_LYNX_RELAY 0x2120

/**
 * Lynx alarms {bits[2] = Low battery voltage, 0 = Not available, 1 = Yes, 2 = No
 * : bits[2] = High battery voltage, 0 = Not available, 1 = Yes, 2 = No : bits[2]
 * = Low SOC, 0 = Not available, 1 = Yes, 2 = No : bits[2] = Low fused voltage, 0
 * = Not available, 1 = Yes, 2 = No : bits[2] = High fused voltage, 0 = Not
 * available, 1 = Yes, 2 = No : bits[2] = Fuse blown, 0 = Not available, 1 = Yes,
 * 2 = No : bits[2] = High battery temperature, 0 = Not available, 1 = Yes, 2 =
 * No : bits[2] = Low battery temperature, 0 = Not available, 1 = Yes, 2 = No :
 * bits[2] = High internal temperature, 0 = Not available, 1 = Yes, 2 = No}
 * Lynx alarm flags
 */
#define VE_REG_LYNX_ALARM 0x2121

/**
 * Lynx error {un8 = Lynx error (see xml for meanings)}
 * @remark see VE_REG_LYNX_ERROR section for possible values
 */
#define VE_REG_LYNX_ERROR 0x2122

/**
 * Lynx: Last errors {un8 = Error 1 (see xml for meanings), Last error : un8 =
 * Error 2 (see xml for meanings) : un8 = Error 3 (see xml for meanings) : un8 =
 * Error 4 (see xml for meanings), Oldest error}
 */
#define VE_REG_LYNX_LAST_ERRORS 0x2123

/**
 * Lynx warnings and alarms {bits[2] = Low battery voltage, 0 = Unsupported, 1 =
 * OK, 2 = Warning, 3 = Alarm : bits[2] = High battery voltage, 0 = Unsupported,
 * 1 = OK, 2 = Warning, 3 = Alarm : bits[2] = Low SOC, 0 = Unsupported, 1 = OK, 2
 * = Warning, 3 = Alarm : bits[2] = Fuse blown, 0 = Unsupported, 1 = OK, 2 =
 * Warning, 3 = Alarm : bits[2] = High battery temperature, 0 = Unsupported, 1 =
 * OK, 2 = Warning, 3 = Alarm : bits[2] = Low battery temperature, 0 =
 * Unsupported, 1 = OK, 2 = Warning, 3 = Alarm : bits[2] = High internal
 * temperature, 0 = Unsupported, 1 = OK, 2 = Warning, 3 = Alarm : }
 * Lynx warning and alarm flags
 */
#define VE_REG_LYNX_WARNINGS_ALARMS 0x2124

/**
 * Lynx Distributor status bits {bits[2] = Distributor A status, 0 = Not
 * available, 1 = Connected, 2 = No bus power, 3 = Communication lost : bits[2] =
 * Distributor B status, 0 = Not available, 1 = Connected, 2 = No bus power, 3 =
 * Communication lost : bits[2] = Distributor C status, 0 = Not available, 1 =
 * Connected, 2 = No bus power, 3 = Communication lost : bits[2] = Distributor D
 * status, 0 = Not available, 1 = Connected, 2 = No bus power, 3 = Communication
 * lost : bits[2] = Distributor E status, 0 = Not available, 1 = Connected, 2 =
 * No bus power, 3 = Communication lost : bits[2] = Distributor F status, 0 = Not
 * available, 1 = Connected, 2 = No bus power, 3 = Communication lost : bits[2] =
 * Distributor G status, 0 = Not available, 1 = Connected, 2 = No bus power, 3 =
 * Communication lost : bits[2] = Distributor H status, 0 = Not available, 1 =
 * Connected, 2 = No bus power, 3 = Communication lost}
 */
#define VE_REG_DISTRIBUTOR_STATUS 0x2150

/**
 * Lynx Distributor fuse status bits {bits[1] = Distributor A fuse 1, 0 = OK, 1 =
 * Blown : bits[1] = Distributor A fuse 2, 0 = OK, 1 = Blown : bits[1] =
 * Distributor A fuse 3, 0 = OK, 1 = Blown : bits[1] = Distributor A fuse 4, 0 =
 * OK, 1 = Blown : bits[1] = Distributor B fuse 1, 0 = OK, 1 = Blown : bits[1] =
 * Distributor B fuse 2, 0 = OK, 1 = Blown : bits[1] = Distributor B fuse 3, 0 =
 * OK, 1 = Blown : bits[1] = Distributor B fuse 4, 0 = OK, 1 = Blown : bits[1] =
 * Distributor C fuse 1, 0 = OK, 1 = Blown : bits[1] = Distributor C fuse 2, 0 =
 * OK, 1 = Blown : bits[1] = Distributor C fuse 3, 0 = OK, 1 = Blown : bits[1] =
 * Distributor C fuse 4, 0 = OK, 1 = Blown : bits[1] = Distributor D fuse 1, 0 =
 * OK, 1 = Blown : bits[1] = Distributor D fuse 2, 0 = OK, 1 = Blown : bits[1] =
 * Distributor D fuse 3, 0 = OK, 1 = Blown : bits[1] = Distributor D fuse 4, 0 =
 * OK, 1 = Blown}
 * @deprecated Use VE_REG_DISTRIBUTOR_[A-H]_FUSE_STATUS instead.
 */
#define VE_REG_DISTRIBUTOR_FUSES 0x2151

/**
 * Lynx Distributor A fuse status bits {bits[2] = Distributor A fuse 1, 0 = Not
 * available, 1 = Not in use, 2 = OK, 3 = Blown : bits[2] = Distributor A fuse 2,
 * 0 = Not available, 1 = Not in use, 2 = OK, 3 = Blown : bits[2] = Distributor A
 * fuse 3, 0 = Not available, 1 = Not in use, 2 = OK, 3 = Blown : bits[2] =
 * Distributor A fuse 4, 0 = Not available, 1 = Not in use, 2 = OK, 3 = Blown :
 * bits[2] = Distributor A fuse 5, 0 = Not available, 1 = Not in use, 2 = OK, 3 =
 * Blown : bits[2] = Distributor A fuse 6, 0 = Not available, 1 = Not in use, 2 =
 * OK, 3 = Blown : bits[2] = Distributor A fuse 7, 0 = Not available, 1 = Not in
 * use, 2 = OK, 3 = Blown : bits[2] = Distributor A fuse 8, 0 = Not available, 1
 * = Not in use, 2 = OK, 3 = Blown}
 */
#define VE_REG_DISTRIBUTOR_A_FUSE_STATUS 0x2152

/**
 * Lynx Distributor B fuse status bits {bits[2] = Distributor B fuse 1, 0 = Not
 * available, 1 = Not in use, 2 = OK, 3 = Blown : bits[2] = Distributor B fuse 2,
 * 0 = Not available, 1 = Not in use, 2 = OK, 3 = Blown : bits[2] = Distributor B
 * fuse 3, 0 = Not available, 1 = Not in use, 2 = OK, 3 = Blown : bits[2] =
 * Distributor B fuse 4, 0 = Not available, 1 = Not in use, 2 = OK, 3 = Blown :
 * bits[2] = Distributor B fuse 5, 0 = Not available, 1 = Not in use, 2 = OK, 3 =
 * Blown : bits[2] = Distributor B fuse 6, 0 = Not available, 1 = Not in use, 2 =
 * OK, 3 = Blown : bits[2] = Distributor B fuse 7, 0 = Not available, 1 = Not in
 * use, 2 = OK, 3 = Blown : bits[2] = Distributor B fuse 8, 0 = Not available, 1
 * = Not in use, 2 = OK, 3 = Blown}
 */
#define VE_REG_DISTRIBUTOR_B_FUSE_STATUS 0x2153

/**
 * Lynx Distributor C fuse status bits {bits[2] = Distributor C fuse 1, 0 = Not
 * available, 1 = Not in use, 2 = OK, 3 = Blown : bits[2] = Distributor C fuse 2,
 * 0 = Not available, 1 = Not in use, 2 = OK, 3 = Blown : bits[2] = Distributor C
 * fuse 3, 0 = Not available, 1 = Not in use, 2 = OK, 3 = Blown : bits[2] =
 * Distributor C fuse 4, 0 = Not available, 1 = Not in use, 2 = OK, 3 = Blown :
 * bits[2] = Distributor C fuse 5, 0 = Not available, 1 = Not in use, 2 = OK, 3 =
 * Blown : bits[2] = Distributor C fuse 6, 0 = Not available, 1 = Not in use, 2 =
 * OK, 3 = Blown : bits[2] = Distributor C fuse 7, 0 = Not available, 1 = Not in
 * use, 2 = OK, 3 = Blown : bits[2] = Distributor C fuse 8, 0 = Not available, 1
 * = Not in use, 2 = OK, 3 = Blown}
 */
#define VE_REG_DISTRIBUTOR_C_FUSE_STATUS 0x2154

/**
 * Lynx Distributor D fuse status bits {bits[2] = Distributor D fuse 1, 0 = Not
 * available, 1 = Not in use, 2 = OK, 3 = Blown : bits[2] = Distributor D fuse 2,
 * 0 = Not available, 1 = Not in use, 2 = OK, 3 = Blown : bits[2] = Distributor D
 * fuse 3, 0 = Not available, 1 = Not in use, 2 = OK, 3 = Blown : bits[2] =
 * Distributor D fuse 4, 0 = Not available, 1 = Not in use, 2 = OK, 3 = Blown :
 * bits[2] = Distributor D fuse 5, 0 = Not available, 1 = Not in use, 2 = OK, 3 =
 * Blown : bits[2] = Distributor D fuse 6, 0 = Not available, 1 = Not in use, 2 =
 * OK, 3 = Blown : bits[2] = Distributor D fuse 7, 0 = Not available, 1 = Not in
 * use, 2 = OK, 3 = Blown : bits[2] = Distributor D fuse 8, 0 = Not available, 1
 * = Not in use, 2 = OK, 3 = Blown}
 */
#define VE_REG_DISTRIBUTOR_D_FUSE_STATUS 0x2155

/**
 * Lynx Distributor E fuse status bits {bits[2] = Distributor E fuse 1, 0 = Not
 * available, 1 = Not in use, 2 = OK, 3 = Blown : bits[2] = Distributor E fuse 2,
 * 0 = Not available, 1 = Not in use, 2 = OK, 3 = Blown : bits[2] = Distributor E
 * fuse 3, 0 = Not available, 1 = Not in use, 2 = OK, 3 = Blown : bits[2] =
 * Distributor E fuse 4, 0 = Not available, 1 = Not in use, 2 = OK, 3 = Blown :
 * bits[2] = Distributor E fuse 5, 0 = Not available, 1 = Not in use, 2 = OK, 3 =
 * Blown : bits[2] = Distributor E fuse 6, 0 = Not available, 1 = Not in use, 2 =
 * OK, 3 = Blown : bits[2] = Distributor E fuse 7, 0 = Not available, 1 = Not in
 * use, 2 = OK, 3 = Blown : bits[2] = Distributor E fuse 8, 0 = Not available, 1
 * = Not in use, 2 = OK, 3 = Blown}
 */
#define VE_REG_DISTRIBUTOR_E_FUSE_STATUS 0x2156

/**
 * Lynx Distributor F fuse status bits {bits[2] = Distributor F fuse 1, 0 = Not
 * available, 1 = Not in use, 2 = OK, 3 = Blown : bits[2] = Distributor F fuse 2,
 * 0 = Not available, 1 = Not in use, 2 = OK, 3 = Blown : bits[2] = Distributor F
 * fuse 3, 0 = Not available, 1 = Not in use, 2 = OK, 3 = Blown : bits[2] =
 * Distributor F fuse 4, 0 = Not available, 1 = Not in use, 2 = OK, 3 = Blown :
 * bits[2] = Distributor F fuse 5, 0 = Not available, 1 = Not in use, 2 = OK, 3 =
 * Blown : bits[2] = Distributor F fuse 6, 0 = Not available, 1 = Not in use, 2 =
 * OK, 3 = Blown : bits[2] = Distributor F fuse 7, 0 = Not available, 1 = Not in
 * use, 2 = OK, 3 = Blown : bits[2] = Distributor F fuse 8, 0 = Not available, 1
 * = Not in use, 2 = OK, 3 = Blown}
 */
#define VE_REG_DISTRIBUTOR_F_FUSE_STATUS 0x2157

/**
 * Lynx Distributor G fuse status bits {bits[2] = Distributor G fuse 1, 0 = Not
 * available, 1 = Not in use, 2 = OK, 3 = Blown : bits[2] = Distributor G fuse 2,
 * 0 = Not available, 1 = Not in use, 2 = OK, 3 = Blown : bits[2] = Distributor G
 * fuse 3, 0 = Not available, 1 = Not in use, 2 = OK, 3 = Blown : bits[2] =
 * Distributor G fuse 4, 0 = Not available, 1 = Not in use, 2 = OK, 3 = Blown :
 * bits[2] = Distributor G fuse 5, 0 = Not available, 1 = Not in use, 2 = OK, 3 =
 * Blown : bits[2] = Distributor G fuse 6, 0 = Not available, 1 = Not in use, 2 =
 * OK, 3 = Blown : bits[2] = Distributor G fuse 7, 0 = Not available, 1 = Not in
 * use, 2 = OK, 3 = Blown : bits[2] = Distributor G fuse 8, 0 = Not available, 1
 * = Not in use, 2 = OK, 3 = Blown}
 */
#define VE_REG_DISTRIBUTOR_G_FUSE_STATUS 0x2158

/**
 * Lynx Distributor H fuse status bits {bits[2] = Distributor H fuse 1, 0 = Not
 * available, 1 = Not in use, 2 = OK, 3 = Blown : bits[2] = Distributor H fuse 2,
 * 0 = Not available, 1 = Not in use, 2 = OK, 3 = Blown : bits[2] = Distributor H
 * fuse 3, 0 = Not available, 1 = Not in use, 2 = OK, 3 = Blown : bits[2] =
 * Distributor H fuse 4, 0 = Not available, 1 = Not in use, 2 = OK, 3 = Blown :
 * bits[2] = Distributor H fuse 5, 0 = Not available, 1 = Not in use, 2 = OK, 3 =
 * Blown : bits[2] = Distributor H fuse 6, 0 = Not available, 1 = Not in use, 2 =
 * OK, 3 = Blown : bits[2] = Distributor H fuse 7, 0 = Not available, 1 = Not in
 * use, 2 = OK, 3 = Blown : bits[2] = Distributor H fuse 8, 0 = Not available, 1
 * = Not in use, 2 = OK, 3 = Blown}
 */
#define VE_REG_DISTRIBUTOR_H_FUSE_STATUS 0x2159

/** Discharged amp sec {sn32 = charge [As]} */
#define VE_REG_DISCHARGEDAS 0x2180

/** Peukert discharge {sn32 = charge [As]} */
#define VE_REG_PEUKERTDISCHARGEAS 0x2181

/** Peukert avg current {sn32 = current [0.001A]} */
#define VE_REG_PEUKERTCURRENTAVG 0x2182

/** Depth current discharge cycle {sn32 = charge [0.1Ah]} */
#define VE_REG_DEPTHCURRENTDISCHARGECYCLE 0x2183

/** Peukert compensated battery capacity {sn32 = charge [As]} */
#define VE_REG_PEUKERTDISCHARGEMAXAS 0x2184

/** Peukert compensated battery empty {sn32 = charge [As]} */
#define VE_REG_PEUKERTDISCHARGEEMPTYAS 0x2185

/** VDATA: BMV total current(NMT group) {sn32 = current [0.001A]} */
#define VE_REG_BMV_TOTAL_CURRENT 0x2186

/**
 * SmartLithium error flags {un32 = SmartLithium error flags}
 * @remark see VE_REG_SMART_LITHIUM_ERROR_FLAGS section for possible values
 */
#define VE_REG_SMART_LITHIUM_ERROR_FLAGS 0xEC80

/**
 * SmartLithium balancer update status {un8 = Balancer : un8 = Progress}
 * @remark A progress of 0xFF means it is not updating
 */
#define VE_REG_SMART_LITHIUM_BALANCER_UPDATE_PROGRESS 0xEC81

/**
 * SmartLithium balancer update errors {un32 = SmartLithium balancer update
 * errors}
 * @remark When a bit is set, it means there was an error updating the
 * corresponding balancer.
 * bit 0 -> balancer instance 0,
 * bit 1 -> balancer instance 1,
 * ...
 */
#define VE_REG_SMART_LITHIUM_BALANCER_UPDATE_ERRORS 0xEC82

/**
 * SmartLithium overlapped voltage errors {un32 = SmartLithium overlapped voltage
 * errors}
 * @remark When a bit is set, it means that a voltage measurement
 * by two different balancers of the same cell differs too much.
 * bit 0 -> balancer instance 0 and instance 1 (cell 1),
 * bit 1 -> balancer instance 1 and instance 2 (cell 2),
 * ...
 */
#define VE_REG_SMART_LITHIUM_OVERLAPPED_VOLTAGE_ERRORS 0xEC83

/**
 * SmartLithium Allowed-To-Discharge disable voltage {un16 = Voltage [0.01V],
 * 0xFFFF = Not Available}
 * The Allowed-To-Discharge signal will be disabled when a cell is below this
 * voltage.
 */
#define VE_REG_SMART_LITHIUM_NOT_ALLOWED_TO_DISCHARGE_CELL_VOLTAGE 0xEC84

/**
 * SmartLithium cell under voltage pre-alarm threshold {un16 = Voltage [0.01V],
 * 0xFFFF = Not Available}
 * The pre-alarm signal precedes any under-voltage alarm
 */
#define VE_REG_SMART_LITHIUM_CELL_UNDER_VOLTAGE_PREALARM_THRESHOLD 0xEC85

/** History Cycle Count {un8 = History Cycle Count} */
#define VE_REG_HISTORY_CYCLE_COUNT 0x106F

/**
 * History Cycle Count {un32 = History Cycle Count}
 * Sequence number for the cycle history, which will change in case of a new
 * cycle. This can be used as a trigger to fetch the entire cycle history.
 */
#define VE_REG_HISTORY_CYCLE_SEQUENCE_NUMBER 0x1099

/**
 * BLE networking network id {stringFixed[2] = id}
 * The network id of the BLE network the node is configured to participate in.
 */
#define VE_REG_BLE_NETWORK_ID 0xEC12

/**
 * NumerOfBroadcastedVeRegs {un8 = NumerOfBroadcastedVeRegs}
 * The number of VE_REG's this node is broadcasting in the BLE network it is
 * configured to participate in.
 */
#define VE_REG_BLE_NETWORK_NUMBER_TRANSMITTED_VE_REGS 0xEC15

/**
 * NumberOfReceivedVeRegs {un8 = NumberOfReceivedVeRegs}
 * The number of unique VE_REG's this node has received since it was activated
 * (up and running).
 */
#define VE_REG_BLE_NETWORK_NUMBER_RECEIVED_VE_REGS 0xEC16

/**
 * NumberOfInRangeDevices {un8 = NumberOfInRangeDevices}
 * The number of devices from which the local node has received one or more
 * broadcasted VE_REG's. The local node will also be included in this number
 * (hence the value will always be at least 1). Nodes from which nothing was
 * received during an implementation dependent period may be excluded from this
 * number.
 */
#define VE_REG_BLE_NETWORK_NUMBER_IN_RANGE_DEVICES 0xEC30

/**
 * ParallelChargeSupport {un8 = ParallelChargeSupport}
 * @remark Flag to indicate support for parallel charge operation. Only value
 * 0x01 is defined! Other values are to be discarded.
 */
#define VE_REG_BLE_NETWORK_PARALLEL_CHARGE_SUPPORT 0xEC3E

/**
 * Default Pincode Status {un8 = PincodeStatus, 0x00 = Default pincode is used,
 * 0x01 = Non-default pincode is used (pincode has been changed)}
 * @remark Status to indicate whether the default pincode is being used or the
 * pincode has been changed.
 */
#define VE_REG_PINCODE_STATUS 0xEC3F

/**
 * Settings Lock Status {un8 = SettingsLock, 0x00 = Unlocked, 0x01 = Locked}
 * @remark Flag to indicate that the settings of the device are considered to be
 * locked. This flag does not enforce the lock in the device, it is an indication
 * to the entity accessing the settings (ie. VictronConnect), that the settings
 * are considered to be locked. Hence it is the responsibility of the entity
 * accessing the settings to implement the actual lock.
 */
#define VE_REG_SETTINGS_LOCK 0xEC40

/**
 * SettingsChanged {un32 = Timestamp}
 * @remark Date/time of last change of the settings, in unix-timestamp format.
 * Stored in an UNsigned 4-byte word to allow usage after 19-Jan-38. To prevent
 * flash wear it is allowed for the storing device to scale down the accuracy of
 * the stored timestamp. A stored accuracy of a “minute” is advised (e.g.
 * (timestamp/60)*60). At the same time it advised to leave out seconds when
 * showing the timestamp (e.g. 10-Sep-18 11:25). When not set, the default value
 * will be 0xFFFFFFFF. In case the time is not known by the instance setting this
 * VeReg, the value 0 (zero) shall be used(e.g. when settings are changed via the
 * local UI on a BMV).
 */
#define VE_REG_SETTINGS_CHANGED 0xEC41

/** BLE networking RSSI {un8 = RSSI} */
#define VE_REG_BLE_NETWORK_RSSI 0xEC42

/** Internal CPU temperature {un16 = Internal CPU temperature [0.01K]} */
#define VE_REG_CPU_TEMPERATURE 0xEC43

/**
 * Discharge off reason {un16 = reason (see xml for meanings)}
 * Reason why product is not discharging. Multiple flag can be or-ed together for
 * bit mask
 */
#define VE_REG_DISCHARGE_OFF_REASON 0xEC44

/**
 * Charge off reason {un16 = reason (see xml for meanings)}
 * Reason why product is not charging. multiple flag can be or-ed together for
 * bit mask
 */
#define VE_REG_CHARGE_OFF_REASON 0xEC45

/**
 * Auxiliary charge off reason {un16 = reason (see xml for meanings)}
 * Reason why product auxiliary path is not charging. multiple flag can be or-ed
 * together for bit mask
 * @remark used by Smart BMS 12/200
 */
#define VE_REG_CHARGE_2_OFF_REASON 0xEC49

/**
 * Allow Discharge off reason {un16 = reason (see xml for meanings)}
 * Reason why product does not allow discharging. Multiple flag can be or-ed
 * together for bit mask
 */
#define VE_REG_ALLOW_DISCHARGE_OFF_REASON 0xEC46

/**
 * Allow Charge off reason {un16 = reason (see xml for meanings)}
 * Reason why product does not allow charging. Multiple flag can be or-ed
 * together for bit mask
 */
#define VE_REG_ALLOW_CHARGE_OFF_REASON 0xEC47

/** Fuse type {un8 = type (see xml for meanings)} */
#define VE_REG_FUSE_TYPE 0xEC48

/**
 * Last time reference for all trends {un32 = Time reference for latest sample in
 * all trends., 0xFFFFFFFF = Not Available}
 * Returns the time reference for all supported trends (0-7). As all trends use
 * the same synchronized time reference, the returned time reference is
 * applicable for each trend.
 */
#define VE_REG_TREND_LAST_TIME_REFERENCE 0xEC5A

/**
 * Clear trend data in device {un8 = Trend index [0-7], 0xFF = Not Available}
 * Clears all (volatile and non-volatile) trend data in the device for selected
 * trend (trend index found via VE_REG_TREND_SUPP_VREGS). Also resets the time
 * references. Using trend index 0xFE will clear ALL trends.
 */
#define VE_REG_TREND_CLEAR 0xEC5C

/**
 * BLE Advertisement mode {un8 = type, 0 = Service UUIDs enabled, extra
 * manufacturer data disabled, 1 = Service UUIDs disabled, extra manufacturer
 * data enabled}
 * Determines what data is included in the BLE advertisement. Extra manufacturer
 * that allows the receiver (VictronConnect) to show data while it is scanning.
 * Older VictronConnect versions will however not be able to find the product.
 * When the Service UUIDs are enabled, older VictronConnect will be able to find
 * the product.
 */
#define VE_REG_BLE_ADVERTISEMENT_MODE 0xEC7D

/**
 * VE-Reg service mode {un8 = type, 0 = VE-Reg service disabled, 1 = VE-Reg
 * service enabled}
 * By use of the BLE VE-Reg Service, vregs can be made available through GATT
 * characteristics. Thus making it easy for 3rd party BLE implementations, to
 * retreive product properties, such as voltage, current and power.
 */
#define VE_REG_BLE_GATT_VEREG_SERVICE_MODE 0xEC7E

/**
 * RSSI of a device as seen by the BLE stack on the central (e.g. the phone)
 * {sn16 = RSSI}
 */
#define VE_REG_BLE_RSSI 0xEC7F

/**
 * Auxiliary trend {un16 = Auxiliary trend}
 * The auxiliary trend either represents starter voltage, midpoint voltage or
 * temperature. VE_REG_BMV_AUX_INPUT must be used to determine what the Auxiliary
 * trend is representing. When the auxiliary input is changed the trend must be
 * cleared seperately via VE_REG_TREND_CLEAR to prevent interpreting the old
 * trend data with the new auxiliary input setting.
 */
#define VE_REG_AUX_TREND 0xEC86

/**
 * SOC for trends {un8 = SOC for trends}
 * SOC percentage in range 0-100 (resolution: 1%). Invalid value 0xFF.
 */
#define VE_REG_SOC_TREND 0xEC87

/**
 * Battery temperature for trends {sn8 = Battery temperature for trends}
 * Battery temperature (Celcius) in range -40C to +100C (resolution: 1C). Invalid
 * value 0x7F
 */
#define VE_REG_BAT_TEMPERATURE_TREND 0xEC88

/**
 * DC output current for trends {un8 = DC output current for trends}
 * DC output current in range 0A to 20A (resolution 0.1A). Invalid value 0xFF.
 */
#define VE_REG_DC_OUTPUT_CURRENT_TREND 0xEC89

/**
 * DC input power for trends {un16 = DC input power for trends}
 * DC input power (resolution 1W). Invalid value 0xFFFF. Max value is 65534W
 * (0xFFFE). In case VE_REG_DC_INPUT_POWER exceeds 65534W then
 * VE_REG_DC_INPUT_POWER_TREND will remain at its max value of 65534W.
 */
#define VE_REG_DC_INPUT_POWER_TREND 0xEC8A

/**
 * Lowest cell voltage for trends {un8 = Lowest cell voltage for trends}
 * Lowest cell voltage over the trend interval (resolution 0.01V). Invalid value
 * 0xFF. Actual cell voltage is 1.7V + value * 0.01V. Max value is 4.24V (0xFE).
 * When the actual value is higher than 4.24V or lower than 1.7v, the value will
 * be clamped to the rnage 1.7 .. 4.24V.
 */
#define VE_REG_MIN_CELL_VOLTAGE_TREND 0xEC8B

/**
 * Consumed Ah {sn32 = Consumed Ah [0.1Ah]}
 * @deprecated Use VE_REG_CONSUMED_AH instead. (Equal to VE_REG_BMV_CE)
 */
#define VE_REG_CAH 0xEEFF

/** UDF.Start (internal) {un8 = vup instance} */
#define VE_REG_UPDATE_ENABLE 0x0010

/** UDF.End (internal) */
#define VE_REG_UPDATE_END 0x0011

/**
 * UDF.Begin (internal) {un8 = instance}
 * This vreg is not used on VE.CAN. There, a special (non-vreg) VE.CAN message is
 * sent that contains the 6 byte CAN unique id.
 */
#define VE_REG_UPDATE_BEGIN 0x0013

/** Test Mode (internal) {stringFixed[4] = Password} */
#define VE_REG_TEST_MODE 0x0020

/**
 * Microcontroller reset detection (internal) {un8 = reset flag, 0 = reset value,
 * 1 = written by tester}
 * @remark Tester writes 1 at start of test sequence, at end of test sequence
 * check if flag is still 1.
 */
#define VE_REG_RESET_DETECTION 0x0021

/**
 * Product released (internal) {un8 = release, 0 = product failed, 1 = product
 * passed testing and calibration}
 * @remark Product will not start automatically when set to 0. Do not set this
 * bit just for testing, to be set at the end of the test sequence only.
 */
#define VE_REG_TEST_PRODUCT_RELEASE 0x0022

/** Settings dump (internal) {un16 = offset : un16 = size} */
#define VE_REG_DUMP_PAGE 0x0023

/**
 * Clear service history command (internal)
 * @remark To be used by the tester to erase the history section that normally
 * not accessible by the user (e.g. burning hours, system yield).
 */
#define VE_REG_CLEAR_SERVICE_HISTORY 0x0024

/**
 * Tunnel (internal)
 * Used for serial like communication, e.g. with a on board chip or to emulate a
 * console. See io/ve_tunnel.c for the common payload. There might be protocol
 * specific payload in the data. The CAN bus identifies instance of busses with a
 * byte, while the dbus uses a path to identify them. The carried payload should
 * be of identical format for all busses though.
 */
#define VE_REG_TUNNEL 0x0030

/**
 * Unique id 0 (internal) {un16 = Controller id (see xml for meanings) : un16 =
 * Site id, 0x02A8 = Arrow Europe, 0xE7D2 = Victron Energy}
 */
#define VE_REG_UNIQUE_ID_0 0x0040

/** Unique id 1 (internal) {un32 = Id} */
#define VE_REG_UNIQUE_ID_1 0x0041

/** Unique id 2 (internal) {un32 = Id} */
#define VE_REG_UNIQUE_ID_2 0x0042

/** Unique id 3 (internal) {un32 = Id} */
#define VE_REG_UNIQUE_ID_3 0x0043

/** Unique id 4 (internal) {un32 = Id} */
#define VE_REG_UNIQUE_ID_4 0x0044

/**
 * Random number field 0 (internal) {un32 = Random}
 * Reading field 0 updates the random value, make sure to read the fields in the
 * proper sequence.
 */
#define VE_REG_RANDOM_0 0x0050

/** Random number field 1 (internal) {un32 = Random} */
#define VE_REG_RANDOM_1 0x0051

/** Random number field 2 (internal) {un32 = Random} */
#define VE_REG_RANDOM_2 0x0052

/** Random number field 3 (internal) {un32 = Random} */
#define VE_REG_RANDOM_3 0x0053

/** Random number field 4 (internal) {un32 = Random} */
#define VE_REG_RANDOM_4 0x0054

/** Random number field 5 (internal) {un32 = Random} */
#define VE_REG_RANDOM_5 0x0055

/** Random number field 6 (internal) {un32 = Random} */
#define VE_REG_RANDOM_6 0x0056

/** Random number field 7 (internal) {un32 = Random} */
#define VE_REG_RANDOM_7 0x0057

/** Random number field 8 (internal) {un32 = Random} */
#define VE_REG_RANDOM_8 0x0058

/** Random number field 9 (internal) {un32 = Random} */
#define VE_REG_RANDOM_9 0x0059

/**
 * BUS ON (internal) {un8 = device instance, 255=broadcast (can be used in the
 * factory or by test tooling) }
 * This register is intended for VE.Direct multi-node communication.
 * Acknowledge vreg set when instance matches (including broadcast)
 * Go to bus off mode when instance does not match.
 * Note: The sender cannot rely on this behaviour because it might not be
 * received properly by all devices that are still in bus on mode.
 */
#define VE_REG_BUS_ON 0x0070

/**
 * BUS OFF (internal) {un8 = device instance, 255=broadcast (can be used in the
 * factory or by test tooling)}
 * This register is intended for VE.Direct multi-node communication.
 * Acknowledge vreg set when instance matches (including broadcast)
 * Bus off mode suppresses all hex commands and text protocol information, in bus
 * off mode only handle VE_REG_BUS_ON and VE_REG_BUS_OFF set commands
 */
#define VE_REG_BUS_OFF 0x0071

/**
 * Heartbeat (internal) {bits[32] = hash}
 * Heartbeat (pay-as-you-go functionality)
 */
#define VE_REG_HEARTBEAT 0x0082

/**
 * MCU Id# (internal) {un8 = Identifier : un24 = MCU Id, 0xFFFFFF = MCU Id not
 * available,  Product specific MCU identifier. The MCU identifier is defined by
 * the product itself. It can be a unique identifier stored by the manufacturer
 * in the MCU but also some  number defined by the product. Its purpose is to
 * distinguish for situations in which the product Id does not suffice (e.g.
 * product Id is the same while using different types of MCU). }
 * Product specific MCU Identifier. Used for identifying the Micro Controller
 * Unit
 */
#define VE_REG_MCU_ID 0x0108

/**
 * Reset reason (internal) {un32 = Reset reason, The contents of this register is
 * product dependant.}
 */
#define VE_REG_RESET_REASON 0x0121

/** UDF.State (internal) */
#define VE_REG_UDF_STATE 0x0128

/** UDF Data (internal) {un8 = reserved} */
#define VE_REG_UDF_DATA 0x012E

/** Stats RX HW overflow count (internal) {un32 = Counts} */
#define VE_REG_RX_HW_OVERFLOW_COUNT 0x0130

/** Stats RX SW overflow count (internal) {un32 = Counts} */
#define VE_REG_RX_SW_OVERFLOW_COUNT 0x0131

/** Stats Error Passive count (internal) {un32 = Counts} */
#define VE_REG_ERROR_PASSIVE_COUNT 0x0132

/** Stats Bus Off count (internal) {un32 = Counts} */
#define VE_REG_BUSOFF_COUNT 0x0133

/** Stats Payload Overrun count (internal) {un32 = Counts} */
#define VE_REG_PAYLOAD_OVERRUN_COUNT 0x0134

/** Stats Tx Error count (internal) {un32 = Counts} */
#define VE_REG_TX_ERROR_COUNT 0x0135

/**
 * Physical selection (internal) {un8 = Physical selection, 0 = Off, 1 = On}
 * Charger physical selection, useful for unit identification in a network
 * @remark mode: 0=normal operation (default), 1=blink/beep. Use register @ref
 * VE_REG_INDENTIFY instead.
 */
#define VE_REG_CAN_SELECT 0xED9F

/**
 * Balancer cell voltage low set (internal) {un16 = Balancer cell voltage low set
 * [0.001V]}
 * Control allow-to-discharge signal: do not allow discharge when cell voltage
 * below this setting
 */
#define VE_REG_BALANCER_CELL_VOLTAGE_LOW_SET 0xEA00

/**
 * Balancer cell voltage low clear (internal) {un16 = Balancer cell voltage low
 * clear [0.001V]}
 * Control allow-to-discharge signal: allow discharge when cell voltage above
 * this setting
 */
#define VE_REG_BALANCER_CELL_VOLTAGE_LOW_CLEAR 0xEA01

/**
 * Balancer cell voltage high set (internal) {un16 = Balancer cell voltage high
 * set [0.001V]}
 * Control allow-to-charge signal: do not allow charging when cell voltage above
 * this setting
 */
#define VE_REG_BALANCER_CELL_VOLTAGE_HIGH_SET 0xEA02

/**
 * Balancer cell voltage high clear (internal) {un16 = Balancer cell voltage high
 * clear [0.001V]}
 * Control allow-to-charge signal: allow charging when cell voltage below this
 * setting
 */
#define VE_REG_BALANCER_CELL_VOLTAGE_HIGH_CLEAR 0xEA03

/**
 * Balancer cell voltage valid detect low (internal) {un16 = Balancer cell
 * voltage valid detect low [0.001V]}
 * allow balancing when cell voltage above this limit (handles partial connection
 * during assembly)
 */
#define VE_REG_BALANCER_VOLTAGE_VALID_DETECT_LOW 0xEA04

/**
 * Balancer cell voltage valid detect high (internal) {un16 = Balancer cell
 * voltage valid detect high [0.001V]}
 * allow balancing when cell voltage below this limit (handles partial connection
 * during assembly)
 */
#define VE_REG_BALANCER_VOLTAGE_VALID_DETECT_HIGH 0xEA05

/**
 * Balancer cell voltage keep balancing (internal) {un16 = Balancer cell voltage
 * keep balancing [0.001V]}
 * keep the balancer active when the cell voltage is above this limit (typically
 * when a charger is active)
 */
#define VE_REG_BALANCER_CELL_VOLTAGE_KEEP_BALANCING 0xEA06

/**
 * Balancer maximum balance current (internal) {un16 = Balancer maximum balance
 * current [0.001A]}
 * maximum balancer current
 */
#define VE_REG_BALANCER_MAXIMUM_BALANCE_CURRENT 0xEA07

/**
 * Balancer cell voltage switch off threshold (internal) {un16 = Balancer cell
 * voltage switch off threshold [0.001V]}
 * stop balancing when the cell voltage difference is below this setting
 */
#define VE_REG_BALANCER_CELL_VOLTAGE_SWITCH_OFF_THRESHOLD 0xEA08

/**
 * Balancer cell voltage switch on threshold (internal) {un16 = Balancer cell
 * voltage switch on threshold [0.001V]}
 * start balancing when the cell voltage difference is above this setting
 */
#define VE_REG_BALANCER_CELL_VOLTAGE_SWITCH_ON_THRESHOLD 0xEA09

/**
 * Balancer keep balancing current (internal) {un16 = Balancer keep balancing
 * current [0.001A]}
 * keep the balancer active when the balancing current is above this limit
 */
#define VE_REG_BALANCER_KEEP_BALANCING_CURRENT 0xEA0A

/**
 * Balancer temperature low level (internal) {sn16 = Balancer temperature low
 * level [0.01°C]}
 * low temperature action: stop balancing below this level, do not allow to
 * charge below this level
 */
#define VE_REG_BALANCER_TEMPERATURE_LOW_LEVEL 0xEA0B

/**
 * Balancer temperature high level (internal) {sn16 = Balancer temperature high
 * level [0.01°C]}
 * high temperature actions: stop balancing above this level, degraded balancer
 * performance starts 20C below this level, do not allow discharge above this
 * level
 */
#define VE_REG_BALANCER_TEMPERATURE_HIGH_LEVEL 0xEA0C

/**
 * Balancer cell voltage activate internal load low (internal) {un16 = Balancer
 * cell voltage activate internal load low [0.001V]}
 * partially activate additional resistive load when the cell voltage is above
 * this level (helps to balance multiple batteries when charging them in series)
 */
#define VE_REG_BALANCER_CELL_VOLTAGE_ACTIVATE_INTERNAL_LOAD_LOW 0xEA0D

/**
 * Balancer cell voltage activate internal load high (internal) {un16 = Balancer
 * cell voltage activate internal load high [0.001V]}
 * fully activate additional resistive load when the cell voltage is above this
 * level (helps to balance multiple batteries when charging them in series)
 */
#define VE_REG_BALANCER_CELL_VOLTAGE_ACTIVATE_INTERNAL_LOAD_HIGH 0xEA0E

/**
 * Balancer internal load low duty cycle (internal) {un8 = Balancer internal load
 * low duty cycle [1%]}
 * internal load low duty cycle
 */
#define VE_REG_BALANCER_INTERNAL_LOAD_LOW_DUTY 0xEA0F

/**
 * Balancer internal load high duty cycle (internal) {un8 = Balancer internal
 * load high duty cycle [1%]}
 * internal load high duty cycle
 */
#define VE_REG_BALANCER_INTERNAL_LOAD_HIGH_DUTY 0xEA10

/**
 * Balancer cell voltage threshold high (internal) {un16 = Balancer cell voltage
 * threshold high [0.001V]}
 * below this level the switch on level is gradually increased
 */
#define VE_REG_BALANCER_CELL_VOLTAGE_THRESHOLD_HIGH 0xEA11

/**
 * Balancer cell voltage threshold low (internal) {un16 = Balancer cell voltage
 * threshold low [0.001V]}
 * below this level the switch on level is increased to its maximum
 */
#define VE_REG_BALANCER_CELL_VOLTAGE_THRESHOLD_LOW 0xEA12

/**
 * Balancer cell voltage threshold offset high (internal) {un16 = Balancer cell
 * voltage threshold offset high [0.001V]}
 * switch on level threshold high increase (used @ low cell voltage)
 */
#define VE_REG_BALANCER_CELL_THRESHOLD_OFFSET_HIGH 0xEA13

/**
 * Balancer cell voltage threshold offset low (internal) {un16 = Balancer cell
 * voltage threshold offset low [0.001V]}
 * switch on level threshold low increase (used @ high cell voltage)
 */
#define VE_REG_BALANCER_CELL_THRESHOLD_OFFSET_LOW 0xEA14

/**
 * Balancer status (internal) {un8 = Status, 0 = Unknown, 1 = Balanced, 2 =
 * Balancing, 3 = Cell imbalance}
 */
#define VE_REG_BALANCER_STATUS 0xEA15

/** Tester product id (internal) {un16 = Tester product id} */
#define VE_REG_TST_PRODUCT_ID 0xEE7C

/** Tester Command (internal) {un16 = Tester Command} */
#define VE_REG_TST_TST_EXEC_CMD 0xEE7D

/** Tester measured value (datatype depends on device implementation) (internal) */
#define VE_REG_TST_MEAS_GET 0xEE80

/**
 * Tester ADC calibration offset (datatype depends on device implementation)
 * (internal) {Float = Tester ADC calibration offset (datatype depends on device
 * implementation)}
 */
#define VE_REG_TST_ADC_CAL_OFFSET 0xEEA0

/**
 * Tester ADC calibration gain (datatype depends on device implementation)
 * (internal)
 */
#define VE_REG_TST_ADC_CAL_GAIN 0xEEC0

/** UDF.Data */
#define VE_REG_UPDATE_DATA 0x0012

/**
 * Token {un32 = cmd : un32 = payload : un32 = hash}
 * Token (pay-as-you-go functionality)
 */
#define VE_REG_TOKEN 0x0080

/**
 * Nonce {un8 = nonce}
 * Nonce 8 bytes (pay-as-you-go functionality)
 */
#define VE_REG_NONCE 0x0081

/**
 * Pre-shared key {un8 = token key}
 * Pre-shared key 20 bytes (pay-as-you-go functionality)
 */
#define VE_REG_PRE_SHARED_KEY 0x0083

/**
 * BROKEN: Statistics page Peak Power Pack {un8 = version : un32 = sequence nr :
 * un8 = deep discharge events : un8 = under-voltage events : un16 = over-voltage
 * events : un8 = over-temperature events : un8 = short-circuit events : un16 =
 * mover output activations : un32 = mover time : un32 = sub-zero time : un16 =
 * charge cycles : un16 = charge cycles at high temperature : un16 = discharges
 * at high temperature : stringFixed[7] = reserved, =0xFF}
 * v2 statistics: Version 0: 34 bytes (same length as @ref VE_REG_HISTORY_DAY00)
 */
#define VE_REG_STATS_PEAK_POWER_PACK 0x0500

/**
 * Non-resetable cumulative data {un8 = Version : un32 = Operation time [1s],
 * 0xFFFFFFFF = Not Available : un32 = Charged Ah [0.1Ah], 0xFFFFFFFF = Not
 * Available : un32 = Charge cycles started, 0xFFFFFFFF = Not Available : un32 =
 * Charge cycles completed, 0xFFFFFFFF = Not Available : un32 = Number of power-
 * ups, 0xFFFFFFFF = Not Available : un32 = Number of deep discharges, 0xFFFFFFFF
 * = Not Available}
 * @remark Cumulative data generated since factory.
 */
#define VE_REG_HISTORY_CUMULATIVE_SERVICE 0x1042

/**
 * User-resetable cumulative data {un8 = Version : un32 = Operation time [1s],
 * 0xFFFFFFFF = Not Available : un32 = Charged Ah [0.1Ah], 0xFFFFFFFF = Not
 * Available : un32 = Charge cycles started, 0xFFFFFFFF = Not Available : un32 =
 * Charge cycles completed, 0xFFFFFFFF = Not Available : un32 = Number of power-
 * ups, 0xFFFFFFFF = Not Available : un32 = Number of deep discharges, 0xFFFFFFFF
 * = Not Available}
 */
#define VE_REG_HISTORY_CUMULATIVE_USER 0x1043

/**
 * History Total {un8 = Version, 0 = , 1 =  : un8 = Error database id, 0 =
 * ERROR_DB_CHARGERS, 1 = ERROR_DB_DEVICES, 0xFF = Not available : un8 = Error 0
 * (see xml for meanings) : un8 = Error 1 (see xml for meanings) : un8 = Error 2
 * (see xml for meanings) : un8 = Error 3 (see xml for meanings) : un32 = Total
 * yield user [0.01kWh], 0xFFFFFFFF = Not Available : un32 = Total yield system
 * [0.01kWh], 0xFFFFFFFF = Not Available : un16 = Panel voc max [0.01V], 0xFFFF =
 * Not Available : un16 = Battery voltage max [0.01V], 0xFFFF = Not Available :
 * un8 = Number of available days : , 1 = }
 */
#define VE_REG_HISTORY_TOTAL 0x104F

/**
 * History Day 0 (today) {un8 = Version : un32 = Yield [0.01kWh], 0xFFFFFFFF =
 * Not Available : un32 = Consumed [0.01kWh], 0xFFFFFFFF = Not Available : un16 =
 * Battery voltage max [0.01V], 0xFFFF = Not Available : un16 = Battery voltage
 * min [0.01V], 0xFFFF = Not Available : un8 = Error database id, 0 =
 * ERROR_DB_CHARGERS, 1 = ERROR_DB_DEVICES, 0xFF = Not available : un8 = Error 0
 * (see xml for meanings) : un8 = Error 1 (see xml for meanings) : un8 = Error 2
 * (see xml for meanings) : un8 = Error 3 (see xml for meanings) : un16 = Time
 * Bulk [1minutes], 0xFFFF = Not Available : un16 = Time Absorption [1minutes],
 * 0xFFFF = Not Available : un16 = Time Float [1minutes], 0xFFFF = Not Available
 * : un32 = Max power [1W], 0xFFFFFFFF = Not Available : un16 = Battery current
 * max [0.1A], 0xFFFF = Not Available : un16 = Panel voc max [0.01V], 0xFFFF =
 * Not Available : un16 = Day sequence number}
 * @remark requesting a day that is not (yet) available results in an error
 * response (ve.can nack or ve.direct flags!=0)
 */
#define VE_REG_HISTORY_DAY00 0x1050

/**
 * History Day -1 (yesterday) {un8 = Version : un32 = Yield [0.01kWh], 0xFFFFFFFF
 * = Not Available : un32 = Consumed [0.01kWh], 0xFFFFFFFF = Not Available : un16
 * = Battery voltage max [0.01V], 0xFFFF = Not Available : un16 = Battery voltage
 * min [0.01V], 0xFFFF = Not Available : un8 = Error database id, 0 =
 * ERROR_DB_CHARGERS, 1 = ERROR_DB_DEVICES, 0xFF = Not available : un8 = Error 0
 * (see xml for meanings) : un8 = Error 1 (see xml for meanings) : un8 = Error 2
 * (see xml for meanings) : un8 = Error 3 (see xml for meanings) : un16 = Time
 * Bulk [1minutes], 0xFFFF = Not Available : un16 = Time Absorption [1minutes],
 * 0xFFFF = Not Available : un16 = Time Float [1minutes], 0xFFFF = Not Available
 * : un32 = Max power [1W], 0xFFFFFFFF = Not Available : un16 = Battery current
 * max [0.1A], 0xFFFF = Not Available : un16 = Panel voc max [0.01V], 0xFFFF =
 * Not Available : un16 = Day sequence number}
 */
#define VE_REG_HISTORY_DAY01 0x1051

/**
 * History Day -2 {un8 = Version : un32 = Yield [0.01kWh], 0xFFFFFFFF = Not
 * Available : un32 = Consumed [0.01kWh], 0xFFFFFFFF = Not Available : un16 =
 * Battery voltage max [0.01V], 0xFFFF = Not Available : un16 = Battery voltage
 * min [0.01V], 0xFFFF = Not Available : un8 = Error database id, 0 =
 * ERROR_DB_CHARGERS, 1 = ERROR_DB_DEVICES, 0xFF = Not available : un8 = Error 0
 * (see xml for meanings) : un8 = Error 1 (see xml for meanings) : un8 = Error 2
 * (see xml for meanings) : un8 = Error 3 (see xml for meanings) : un16 = Time
 * Bulk [1minutes], 0xFFFF = Not Available : un16 = Time Absorption [1minutes],
 * 0xFFFF = Not Available : un16 = Time Float [1minutes], 0xFFFF = Not Available
 * : un32 = Max power [1W], 0xFFFFFFFF = Not Available : un16 = Battery current
 * max [0.1A], 0xFFFF = Not Available : un16 = Panel voc max [0.01V], 0xFFFF =
 * Not Available : un16 = Day sequence number}
 */
#define VE_REG_HISTORY_DAY02 0x1052

/**
 * History Day -2 {un8 = Version : un32 = Yield [0.01kWh], 0xFFFFFFFF = Not
 * Available : un32 = Consumed [0.01kWh], 0xFFFFFFFF = Not Available : un16 =
 * Battery voltage max [0.01V], 0xFFFF = Not Available : un16 = Battery voltage
 * min [0.01V], 0xFFFF = Not Available : un8 = Error database id, 0 =
 * ERROR_DB_CHARGERS, 1 = ERROR_DB_DEVICES, 0xFF = Not available : un8 = Error 0
 * (see xml for meanings) : un8 = Error 1 (see xml for meanings) : un8 = Error 2
 * (see xml for meanings) : un8 = Error 3 (see xml for meanings) : un16 = Time
 * Bulk [1minutes], 0xFFFF = Not Available : un16 = Time Absorption [1minutes],
 * 0xFFFF = Not Available : un16 = Time Float [1minutes], 0xFFFF = Not Available
 * : un32 = Max power [1W], 0xFFFFFFFF = Not Available : un16 = Battery current
 * max [0.1A], 0xFFFF = Not Available : un16 = Panel voc max [0.01V], 0xFFFF =
 * Not Available : un16 = Day sequence number}
 */
#define VE_REG_HISTORY_DAY03 0x1053

/**
 * History Day -4 {un8 = Version : un32 = Yield [0.01kWh], 0xFFFFFFFF = Not
 * Available : un32 = Consumed [0.01kWh], 0xFFFFFFFF = Not Available : un16 =
 * Battery voltage max [0.01V], 0xFFFF = Not Available : un16 = Battery voltage
 * min [0.01V], 0xFFFF = Not Available : un8 = Error database id, 0 =
 * ERROR_DB_CHARGERS, 1 = ERROR_DB_DEVICES, 0xFF = Not available : un8 = Error 0
 * (see xml for meanings) : un8 = Error 1 (see xml for meanings) : un8 = Error 2
 * (see xml for meanings) : un8 = Error 3 (see xml for meanings) : un16 = Time
 * Bulk [1minutes], 0xFFFF = Not Available : un16 = Time Absorption [1minutes],
 * 0xFFFF = Not Available : un16 = Time Float [1minutes], 0xFFFF = Not Available
 * : un32 = Max power [1W], 0xFFFFFFFF = Not Available : un16 = Battery current
 * max [0.1A], 0xFFFF = Not Available : un16 = Panel voc max [0.01V], 0xFFFF =
 * Not Available : un16 = Day sequence number}
 */
#define VE_REG_HISTORY_DAY04 0x1054

/**
 * History Day -5 {un8 = Version : un32 = Yield [0.01kWh], 0xFFFFFFFF = Not
 * Available : un32 = Consumed [0.01kWh], 0xFFFFFFFF = Not Available : un16 =
 * Battery voltage max [0.01V], 0xFFFF = Not Available : un16 = Battery voltage
 * min [0.01V], 0xFFFF = Not Available : un8 = Error database id, 0 =
 * ERROR_DB_CHARGERS, 1 = ERROR_DB_DEVICES, 0xFF = Not available : un8 = Error 0
 * (see xml for meanings) : un8 = Error 1 (see xml for meanings) : un8 = Error 2
 * (see xml for meanings) : un8 = Error 3 (see xml for meanings) : un16 = Time
 * Bulk [1minutes], 0xFFFF = Not Available : un16 = Time Absorption [1minutes],
 * 0xFFFF = Not Available : un16 = Time Float [1minutes], 0xFFFF = Not Available
 * : un32 = Max power [1W], 0xFFFFFFFF = Not Available : un16 = Battery current
 * max [0.1A], 0xFFFF = Not Available : un16 = Panel voc max [0.01V], 0xFFFF =
 * Not Available : un16 = Day sequence number}
 */
#define VE_REG_HISTORY_DAY05 0x1055

/**
 * History Day -6 {un8 = Version : un32 = Yield [0.01kWh], 0xFFFFFFFF = Not
 * Available : un32 = Consumed [0.01kWh], 0xFFFFFFFF = Not Available : un16 =
 * Battery voltage max [0.01V], 0xFFFF = Not Available : un16 = Battery voltage
 * min [0.01V], 0xFFFF = Not Available : un8 = Error database id, 0 =
 * ERROR_DB_CHARGERS, 1 = ERROR_DB_DEVICES, 0xFF = Not available : un8 = Error 0
 * (see xml for meanings) : un8 = Error 1 (see xml for meanings) : un8 = Error 2
 * (see xml for meanings) : un8 = Error 3 (see xml for meanings) : un16 = Time
 * Bulk [1minutes], 0xFFFF = Not Available : un16 = Time Absorption [1minutes],
 * 0xFFFF = Not Available : un16 = Time Float [1minutes], 0xFFFF = Not Available
 * : un32 = Max power [1W], 0xFFFFFFFF = Not Available : un16 = Battery current
 * max [0.1A], 0xFFFF = Not Available : un16 = Panel voc max [0.01V], 0xFFFF =
 * Not Available : un16 = Day sequence number}
 */
#define VE_REG_HISTORY_DAY06 0x1056

/**
 * History Day -7 {un8 = Version : un32 = Yield [0.01kWh], 0xFFFFFFFF = Not
 * Available : un32 = Consumed [0.01kWh], 0xFFFFFFFF = Not Available : un16 =
 * Battery voltage max [0.01V], 0xFFFF = Not Available : un16 = Battery voltage
 * min [0.01V], 0xFFFF = Not Available : un8 = Error database id, 0 =
 * ERROR_DB_CHARGERS, 1 = ERROR_DB_DEVICES, 0xFF = Not available : un8 = Error 0
 * (see xml for meanings) : un8 = Error 1 (see xml for meanings) : un8 = Error 2
 * (see xml for meanings) : un8 = Error 3 (see xml for meanings) : un16 = Time
 * Bulk [1minutes], 0xFFFF = Not Available : un16 = Time Absorption [1minutes],
 * 0xFFFF = Not Available : un16 = Time Float [1minutes], 0xFFFF = Not Available
 * : un32 = Max power [1W], 0xFFFFFFFF = Not Available : un16 = Battery current
 * max [0.1A], 0xFFFF = Not Available : un16 = Panel voc max [0.01V], 0xFFFF =
 * Not Available : un16 = Day sequence number}
 */
#define VE_REG_HISTORY_DAY07 0x1057

/**
 * History Day -8 {un8 = Version : un32 = Yield [0.01kWh], 0xFFFFFFFF = Not
 * Available : un32 = Consumed [0.01kWh], 0xFFFFFFFF = Not Available : un16 =
 * Battery voltage max [0.01V], 0xFFFF = Not Available : un16 = Battery voltage
 * min [0.01V], 0xFFFF = Not Available : un8 = Error database id, 0 =
 * ERROR_DB_CHARGERS, 1 = ERROR_DB_DEVICES, 0xFF = Not available : un8 = Error 0
 * (see xml for meanings) : un8 = Error 1 (see xml for meanings) : un8 = Error 2
 * (see xml for meanings) : un8 = Error 3 (see xml for meanings) : un16 = Time
 * Bulk [1minutes], 0xFFFF = Not Available : un16 = Time Absorption [1minutes],
 * 0xFFFF = Not Available : un16 = Time Float [1minutes], 0xFFFF = Not Available
 * : un32 = Max power [1W], 0xFFFFFFFF = Not Available : un16 = Battery current
 * max [0.1A], 0xFFFF = Not Available : un16 = Panel voc max [0.01V], 0xFFFF =
 * Not Available : un16 = Day sequence number}
 */
#define VE_REG_HISTORY_DAY08 0x1058

/**
 * History Day -9 {un8 = Version : un32 = Yield [0.01kWh], 0xFFFFFFFF = Not
 * Available : un32 = Consumed [0.01kWh], 0xFFFFFFFF = Not Available : un16 =
 * Battery voltage max [0.01V], 0xFFFF = Not Available : un16 = Battery voltage
 * min [0.01V], 0xFFFF = Not Available : un8 = Error database id, 0 =
 * ERROR_DB_CHARGERS, 1 = ERROR_DB_DEVICES, 0xFF = Not available : un8 = Error 0
 * (see xml for meanings) : un8 = Error 1 (see xml for meanings) : un8 = Error 2
 * (see xml for meanings) : un8 = Error 3 (see xml for meanings) : un16 = Time
 * Bulk [1minutes], 0xFFFF = Not Available : un16 = Time Absorption [1minutes],
 * 0xFFFF = Not Available : un16 = Time Float [1minutes], 0xFFFF = Not Available
 * : un32 = Max power [1W], 0xFFFFFFFF = Not Available : un16 = Battery current
 * max [0.1A], 0xFFFF = Not Available : un16 = Panel voc max [0.01V], 0xFFFF =
 * Not Available : un16 = Day sequence number}
 */
#define VE_REG_HISTORY_DAY09 0x1059

/**
 * History Day -10 {un8 = Version : un32 = Yield [0.01kWh], 0xFFFFFFFF = Not
 * Available : un32 = Consumed [0.01kWh], 0xFFFFFFFF = Not Available : un16 =
 * Battery voltage max [0.01V], 0xFFFF = Not Available : un16 = Battery voltage
 * min [0.01V], 0xFFFF = Not Available : un8 = Error database id, 0 =
 * ERROR_DB_CHARGERS, 1 = ERROR_DB_DEVICES, 0xFF = Not available : un8 = Error 0
 * (see xml for meanings) : un8 = Error 1 (see xml for meanings) : un8 = Error 2
 * (see xml for meanings) : un8 = Error 3 (see xml for meanings) : un16 = Time
 * Bulk [1minutes], 0xFFFF = Not Available : un16 = Time Absorption [1minutes],
 * 0xFFFF = Not Available : un16 = Time Float [1minutes], 0xFFFF = Not Available
 * : un32 = Max power [1W], 0xFFFFFFFF = Not Available : un16 = Battery current
 * max [0.1A], 0xFFFF = Not Available : un16 = Panel voc max [0.01V], 0xFFFF =
 * Not Available : un16 = Day sequence number}
 */
#define VE_REG_HISTORY_DAY10 0x105A

/**
 * History Day -11 {un8 = Version : un32 = Yield [0.01kWh], 0xFFFFFFFF = Not
 * Available : un32 = Consumed [0.01kWh], 0xFFFFFFFF = Not Available : un16 =
 * Battery voltage max [0.01V], 0xFFFF = Not Available : un16 = Battery voltage
 * min [0.01V], 0xFFFF = Not Available : un8 = Error database id, 0 =
 * ERROR_DB_CHARGERS, 1 = ERROR_DB_DEVICES, 0xFF = Not available : un8 = Error 0
 * (see xml for meanings) : un8 = Error 1 (see xml for meanings) : un8 = Error 2
 * (see xml for meanings) : un8 = Error 3 (see xml for meanings) : un16 = Time
 * Bulk [1minutes], 0xFFFF = Not Available : un16 = Time Absorption [1minutes],
 * 0xFFFF = Not Available : un16 = Time Float [1minutes], 0xFFFF = Not Available
 * : un32 = Max power [1W], 0xFFFFFFFF = Not Available : un16 = Battery current
 * max [0.1A], 0xFFFF = Not Available : un16 = Panel voc max [0.01V], 0xFFFF =
 * Not Available : un16 = Day sequence number}
 */
#define VE_REG_HISTORY_DAY11 0x105B

/**
 * History Day -12 {un8 = Version : un32 = Yield [0.01kWh], 0xFFFFFFFF = Not
 * Available : un32 = Consumed [0.01kWh], 0xFFFFFFFF = Not Available : un16 =
 * Battery voltage max [0.01V], 0xFFFF = Not Available : un16 = Battery voltage
 * min [0.01V], 0xFFFF = Not Available : un8 = Error database id, 0 =
 * ERROR_DB_CHARGERS, 1 = ERROR_DB_DEVICES, 0xFF = Not available : un8 = Error 0
 * (see xml for meanings) : un8 = Error 1 (see xml for meanings) : un8 = Error 2
 * (see xml for meanings) : un8 = Error 3 (see xml for meanings) : un16 = Time
 * Bulk [1minutes], 0xFFFF = Not Available : un16 = Time Absorption [1minutes],
 * 0xFFFF = Not Available : un16 = Time Float [1minutes], 0xFFFF = Not Available
 * : un32 = Max power [1W], 0xFFFFFFFF = Not Available : un16 = Battery current
 * max [0.1A], 0xFFFF = Not Available : un16 = Panel voc max [0.01V], 0xFFFF =
 * Not Available : un16 = Day sequence number}
 */
#define VE_REG_HISTORY_DAY12 0x105C

/**
 * History Day -13 {un8 = Version : un32 = Yield [0.01kWh], 0xFFFFFFFF = Not
 * Available : un32 = Consumed [0.01kWh], 0xFFFFFFFF = Not Available : un16 =
 * Battery voltage max [0.01V], 0xFFFF = Not Available : un16 = Battery voltage
 * min [0.01V], 0xFFFF = Not Available : un8 = Error database id, 0 =
 * ERROR_DB_CHARGERS, 1 = ERROR_DB_DEVICES, 0xFF = Not available : un8 = Error 0
 * (see xml for meanings) : un8 = Error 1 (see xml for meanings) : un8 = Error 2
 * (see xml for meanings) : un8 = Error 3 (see xml for meanings) : un16 = Time
 * Bulk [1minutes], 0xFFFF = Not Available : un16 = Time Absorption [1minutes],
 * 0xFFFF = Not Available : un16 = Time Float [1minutes], 0xFFFF = Not Available
 * : un32 = Max power [1W], 0xFFFFFFFF = Not Available : un16 = Battery current
 * max [0.1A], 0xFFFF = Not Available : un16 = Panel voc max [0.01V], 0xFFFF =
 * Not Available : un16 = Day sequence number}
 */
#define VE_REG_HISTORY_DAY13 0x105D

/**
 * History Day -14 {un8 = Version : un32 = Yield [0.01kWh], 0xFFFFFFFF = Not
 * Available : un32 = Consumed [0.01kWh], 0xFFFFFFFF = Not Available : un16 =
 * Battery voltage max [0.01V], 0xFFFF = Not Available : un16 = Battery voltage
 * min [0.01V], 0xFFFF = Not Available : un8 = Error database id, 0 =
 * ERROR_DB_CHARGERS, 1 = ERROR_DB_DEVICES, 0xFF = Not available : un8 = Error 0
 * (see xml for meanings) : un8 = Error 1 (see xml for meanings) : un8 = Error 2
 * (see xml for meanings) : un8 = Error 3 (see xml for meanings) : un16 = Time
 * Bulk [1minutes], 0xFFFF = Not Available : un16 = Time Absorption [1minutes],
 * 0xFFFF = Not Available : un16 = Time Float [1minutes], 0xFFFF = Not Available
 * : un32 = Max power [1W], 0xFFFFFFFF = Not Available : un16 = Battery current
 * max [0.1A], 0xFFFF = Not Available : un16 = Panel voc max [0.01V], 0xFFFF =
 * Not Available : un16 = Day sequence number}
 */
#define VE_REG_HISTORY_DAY14 0x105E

/**
 * History Day -15 {un8 = Version : un32 = Yield [0.01kWh], 0xFFFFFFFF = Not
 * Available : un32 = Consumed [0.01kWh], 0xFFFFFFFF = Not Available : un16 =
 * Battery voltage max [0.01V], 0xFFFF = Not Available : un16 = Battery voltage
 * min [0.01V], 0xFFFF = Not Available : un8 = Error database id, 0 =
 * ERROR_DB_CHARGERS, 1 = ERROR_DB_DEVICES, 0xFF = Not available : un8 = Error 0
 * (see xml for meanings) : un8 = Error 1 (see xml for meanings) : un8 = Error 2
 * (see xml for meanings) : un8 = Error 3 (see xml for meanings) : un16 = Time
 * Bulk [1minutes], 0xFFFF = Not Available : un16 = Time Absorption [1minutes],
 * 0xFFFF = Not Available : un16 = Time Float [1minutes], 0xFFFF = Not Available
 * : un32 = Max power [1W], 0xFFFFFFFF = Not Available : un16 = Battery current
 * max [0.1A], 0xFFFF = Not Available : un16 = Panel voc max [0.01V], 0xFFFF =
 * Not Available : un16 = Day sequence number}
 */
#define VE_REG_HISTORY_DAY15 0x105F

/**
 * History Day -16 {un8 = Version : un32 = Yield [0.01kWh], 0xFFFFFFFF = Not
 * Available : un32 = Consumed [0.01kWh], 0xFFFFFFFF = Not Available : un16 =
 * Battery voltage max [0.01V], 0xFFFF = Not Available : un16 = Battery voltage
 * min [0.01V], 0xFFFF = Not Available : un8 = Error database id, 0 =
 * ERROR_DB_CHARGERS, 1 = ERROR_DB_DEVICES, 0xFF = Not available : un8 = Error 0
 * (see xml for meanings) : un8 = Error 1 (see xml for meanings) : un8 = Error 2
 * (see xml for meanings) : un8 = Error 3 (see xml for meanings) : un16 = Time
 * Bulk [1minutes], 0xFFFF = Not Available : un16 = Time Absorption [1minutes],
 * 0xFFFF = Not Available : un16 = Time Float [1minutes], 0xFFFF = Not Available
 * : un32 = Max power [1W], 0xFFFFFFFF = Not Available : un16 = Battery current
 * max [0.1A], 0xFFFF = Not Available : un16 = Panel voc max [0.01V], 0xFFFF =
 * Not Available : un16 = Day sequence number}
 */
#define VE_REG_HISTORY_DAY16 0x1060

/**
 * History Day -17 {un8 = Version : un32 = Yield [0.01kWh], 0xFFFFFFFF = Not
 * Available : un32 = Consumed [0.01kWh], 0xFFFFFFFF = Not Available : un16 =
 * Battery voltage max [0.01V], 0xFFFF = Not Available : un16 = Battery voltage
 * min [0.01V], 0xFFFF = Not Available : un8 = Error database id, 0 =
 * ERROR_DB_CHARGERS, 1 = ERROR_DB_DEVICES, 0xFF = Not available : un8 = Error 0
 * (see xml for meanings) : un8 = Error 1 (see xml for meanings) : un8 = Error 2
 * (see xml for meanings) : un8 = Error 3 (see xml for meanings) : un16 = Time
 * Bulk [1minutes], 0xFFFF = Not Available : un16 = Time Absorption [1minutes],
 * 0xFFFF = Not Available : un16 = Time Float [1minutes], 0xFFFF = Not Available
 * : un32 = Max power [1W], 0xFFFFFFFF = Not Available : un16 = Battery current
 * max [0.1A], 0xFFFF = Not Available : un16 = Panel voc max [0.01V], 0xFFFF =
 * Not Available : un16 = Day sequence number}
 */
#define VE_REG_HISTORY_DAY17 0x1061

/**
 * History Day -18 {un8 = Version : un32 = Yield [0.01kWh], 0xFFFFFFFF = Not
 * Available : un32 = Consumed [0.01kWh], 0xFFFFFFFF = Not Available : un16 =
 * Battery voltage max [0.01V], 0xFFFF = Not Available : un16 = Battery voltage
 * min [0.01V], 0xFFFF = Not Available : un8 = Error database id, 0 =
 * ERROR_DB_CHARGERS, 1 = ERROR_DB_DEVICES, 0xFF = Not available : un8 = Error 0
 * (see xml for meanings) : un8 = Error 1 (see xml for meanings) : un8 = Error 2
 * (see xml for meanings) : un8 = Error 3 (see xml for meanings) : un16 = Time
 * Bulk [1minutes], 0xFFFF = Not Available : un16 = Time Absorption [1minutes],
 * 0xFFFF = Not Available : un16 = Time Float [1minutes], 0xFFFF = Not Available
 * : un32 = Max power [1W], 0xFFFFFFFF = Not Available : un16 = Battery current
 * max [0.1A], 0xFFFF = Not Available : un16 = Panel voc max [0.01V], 0xFFFF =
 * Not Available : un16 = Day sequence number}
 */
#define VE_REG_HISTORY_DAY18 0x1062

/**
 * History Day -19 {un8 = Version : un32 = Yield [0.01kWh], 0xFFFFFFFF = Not
 * Available : un32 = Consumed [0.01kWh], 0xFFFFFFFF = Not Available : un16 =
 * Battery voltage max [0.01V], 0xFFFF = Not Available : un16 = Battery voltage
 * min [0.01V], 0xFFFF = Not Available : un8 = Error database id, 0 =
 * ERROR_DB_CHARGERS, 1 = ERROR_DB_DEVICES, 0xFF = Not available : un8 = Error 0
 * (see xml for meanings) : un8 = Error 1 (see xml for meanings) : un8 = Error 2
 * (see xml for meanings) : un8 = Error 3 (see xml for meanings) : un16 = Time
 * Bulk [1minutes], 0xFFFF = Not Available : un16 = Time Absorption [1minutes],
 * 0xFFFF = Not Available : un16 = Time Float [1minutes], 0xFFFF = Not Available
 * : un32 = Max power [1W], 0xFFFFFFFF = Not Available : un16 = Battery current
 * max [0.1A], 0xFFFF = Not Available : un16 = Panel voc max [0.01V], 0xFFFF =
 * Not Available : un16 = Day sequence number}
 */
#define VE_REG_HISTORY_DAY19 0x1063

/**
 * History Day -20 {un8 = Version : un32 = Yield [0.01kWh], 0xFFFFFFFF = Not
 * Available : un32 = Consumed [0.01kWh], 0xFFFFFFFF = Not Available : un16 =
 * Battery voltage max [0.01V], 0xFFFF = Not Available : un16 = Battery voltage
 * min [0.01V], 0xFFFF = Not Available : un8 = Error database id, 0 =
 * ERROR_DB_CHARGERS, 1 = ERROR_DB_DEVICES, 0xFF = Not available : un8 = Error 0
 * (see xml for meanings) : un8 = Error 1 (see xml for meanings) : un8 = Error 2
 * (see xml for meanings) : un8 = Error 3 (see xml for meanings) : un16 = Time
 * Bulk [1minutes], 0xFFFF = Not Available : un16 = Time Absorption [1minutes],
 * 0xFFFF = Not Available : un16 = Time Float [1minutes], 0xFFFF = Not Available
 * : un32 = Max power [1W], 0xFFFFFFFF = Not Available : un16 = Battery current
 * max [0.1A], 0xFFFF = Not Available : un16 = Panel voc max [0.01V], 0xFFFF =
 * Not Available : un16 = Day sequence number}
 */
#define VE_REG_HISTORY_DAY20 0x1064

/**
 * History Day -21 {un8 = Version : un32 = Yield [0.01kWh], 0xFFFFFFFF = Not
 * Available : un32 = Consumed [0.01kWh], 0xFFFFFFFF = Not Available : un16 =
 * Battery voltage max [0.01V], 0xFFFF = Not Available : un16 = Battery voltage
 * min [0.01V], 0xFFFF = Not Available : un8 = Error database id, 0 =
 * ERROR_DB_CHARGERS, 1 = ERROR_DB_DEVICES, 0xFF = Not available : un8 = Error 0
 * (see xml for meanings) : un8 = Error 1 (see xml for meanings) : un8 = Error 2
 * (see xml for meanings) : un8 = Error 3 (see xml for meanings) : un16 = Time
 * Bulk [1minutes], 0xFFFF = Not Available : un16 = Time Absorption [1minutes],
 * 0xFFFF = Not Available : un16 = Time Float [1minutes], 0xFFFF = Not Available
 * : un32 = Max power [1W], 0xFFFFFFFF = Not Available : un16 = Battery current
 * max [0.1A], 0xFFFF = Not Available : un16 = Panel voc max [0.01V], 0xFFFF =
 * Not Available : un16 = Day sequence number}
 */
#define VE_REG_HISTORY_DAY21 0x1065

/**
 * History Day -22 {un8 = Version : un32 = Yield [0.01kWh], 0xFFFFFFFF = Not
 * Available : un32 = Consumed [0.01kWh], 0xFFFFFFFF = Not Available : un16 =
 * Battery voltage max [0.01V], 0xFFFF = Not Available : un16 = Battery voltage
 * min [0.01V], 0xFFFF = Not Available : un8 = Error database id, 0 =
 * ERROR_DB_CHARGERS, 1 = ERROR_DB_DEVICES, 0xFF = Not available : un8 = Error 0
 * (see xml for meanings) : un8 = Error 1 (see xml for meanings) : un8 = Error 2
 * (see xml for meanings) : un8 = Error 3 (see xml for meanings) : un16 = Time
 * Bulk [1minutes], 0xFFFF = Not Available : un16 = Time Absorption [1minutes],
 * 0xFFFF = Not Available : un16 = Time Float [1minutes], 0xFFFF = Not Available
 * : un32 = Max power [1W], 0xFFFFFFFF = Not Available : un16 = Battery current
 * max [0.1A], 0xFFFF = Not Available : un16 = Panel voc max [0.01V], 0xFFFF =
 * Not Available : un16 = Day sequence number}
 */
#define VE_REG_HISTORY_DAY22 0x1066

/**
 * History Day -22 {un8 = Version : un32 = Yield [0.01kWh], 0xFFFFFFFF = Not
 * Available : un32 = Consumed [0.01kWh], 0xFFFFFFFF = Not Available : un16 =
 * Battery voltage max [0.01V], 0xFFFF = Not Available : un16 = Battery voltage
 * min [0.01V], 0xFFFF = Not Available : un8 = Error database id, 0 =
 * ERROR_DB_CHARGERS, 1 = ERROR_DB_DEVICES, 0xFF = Not available : un8 = Error 0
 * (see xml for meanings) : un8 = Error 1 (see xml for meanings) : un8 = Error 2
 * (see xml for meanings) : un8 = Error 3 (see xml for meanings) : un16 = Time
 * Bulk [1minutes], 0xFFFF = Not Available : un16 = Time Absorption [1minutes],
 * 0xFFFF = Not Available : un16 = Time Float [1minutes], 0xFFFF = Not Available
 * : un32 = Max power [1W], 0xFFFFFFFF = Not Available : un16 = Battery current
 * max [0.1A], 0xFFFF = Not Available : un16 = Panel voc max [0.01V], 0xFFFF =
 * Not Available : un16 = Day sequence number}
 */
#define VE_REG_HISTORY_DAY23 0x1067

/**
 * History Day -24 {un8 = Version : un32 = Yield [0.01kWh], 0xFFFFFFFF = Not
 * Available : un32 = Consumed [0.01kWh], 0xFFFFFFFF = Not Available : un16 =
 * Battery voltage max [0.01V], 0xFFFF = Not Available : un16 = Battery voltage
 * min [0.01V], 0xFFFF = Not Available : un8 = Error database id, 0 =
 * ERROR_DB_CHARGERS, 1 = ERROR_DB_DEVICES, 0xFF = Not available : un8 = Error 0
 * (see xml for meanings) : un8 = Error 1 (see xml for meanings) : un8 = Error 2
 * (see xml for meanings) : un8 = Error 3 (see xml for meanings) : un16 = Time
 * Bulk [1minutes], 0xFFFF = Not Available : un16 = Time Absorption [1minutes],
 * 0xFFFF = Not Available : un16 = Time Float [1minutes], 0xFFFF = Not Available
 * : un32 = Max power [1W], 0xFFFFFFFF = Not Available : un16 = Battery current
 * max [0.1A], 0xFFFF = Not Available : un16 = Panel voc max [0.01V], 0xFFFF =
 * Not Available : un16 = Day sequence number}
 */
#define VE_REG_HISTORY_DAY24 0x1068

/**
 * History Day -25 {un8 = Version : un32 = Yield [0.01kWh], 0xFFFFFFFF = Not
 * Available : un32 = Consumed [0.01kWh], 0xFFFFFFFF = Not Available : un16 =
 * Battery voltage max [0.01V], 0xFFFF = Not Available : un16 = Battery voltage
 * min [0.01V], 0xFFFF = Not Available : un8 = Error database id, 0 =
 * ERROR_DB_CHARGERS, 1 = ERROR_DB_DEVICES, 0xFF = Not available : un8 = Error 0
 * (see xml for meanings) : un8 = Error 1 (see xml for meanings) : un8 = Error 2
 * (see xml for meanings) : un8 = Error 3 (see xml for meanings) : un16 = Time
 * Bulk [1minutes], 0xFFFF = Not Available : un16 = Time Absorption [1minutes],
 * 0xFFFF = Not Available : un16 = Time Float [1minutes], 0xFFFF = Not Available
 * : un32 = Max power [1W], 0xFFFFFFFF = Not Available : un16 = Battery current
 * max [0.1A], 0xFFFF = Not Available : un16 = Panel voc max [0.01V], 0xFFFF =
 * Not Available : un16 = Day sequence number}
 */
#define VE_REG_HISTORY_DAY25 0x1069

/**
 * History Day -26 {un8 = Version : un32 = Yield [0.01kWh], 0xFFFFFFFF = Not
 * Available : un32 = Consumed [0.01kWh], 0xFFFFFFFF = Not Available : un16 =
 * Battery voltage max [0.01V], 0xFFFF = Not Available : un16 = Battery voltage
 * min [0.01V], 0xFFFF = Not Available : un8 = Error database id, 0 =
 * ERROR_DB_CHARGERS, 1 = ERROR_DB_DEVICES, 0xFF = Not available : un8 = Error 0
 * (see xml for meanings) : un8 = Error 1 (see xml for meanings) : un8 = Error 2
 * (see xml for meanings) : un8 = Error 3 (see xml for meanings) : un16 = Time
 * Bulk [1minutes], 0xFFFF = Not Available : un16 = Time Absorption [1minutes],
 * 0xFFFF = Not Available : un16 = Time Float [1minutes], 0xFFFF = Not Available
 * : un32 = Max power [1W], 0xFFFFFFFF = Not Available : un16 = Battery current
 * max [0.1A], 0xFFFF = Not Available : un16 = Panel voc max [0.01V], 0xFFFF =
 * Not Available : un16 = Day sequence number}
 */
#define VE_REG_HISTORY_DAY26 0x106A

/**
 * History Day -27 {un8 = Version : un32 = Yield [0.01kWh], 0xFFFFFFFF = Not
 * Available : un32 = Consumed [0.01kWh], 0xFFFFFFFF = Not Available : un16 =
 * Battery voltage max [0.01V], 0xFFFF = Not Available : un16 = Battery voltage
 * min [0.01V], 0xFFFF = Not Available : un8 = Error database id, 0 =
 * ERROR_DB_CHARGERS, 1 = ERROR_DB_DEVICES, 0xFF = Not available : un8 = Error 0
 * (see xml for meanings) : un8 = Error 1 (see xml for meanings) : un8 = Error 2
 * (see xml for meanings) : un8 = Error 3 (see xml for meanings) : un16 = Time
 * Bulk [1minutes], 0xFFFF = Not Available : un16 = Time Absorption [1minutes],
 * 0xFFFF = Not Available : un16 = Time Float [1minutes], 0xFFFF = Not Available
 * : un32 = Max power [1W], 0xFFFFFFFF = Not Available : un16 = Battery current
 * max [0.1A], 0xFFFF = Not Available : un16 = Panel voc max [0.01V], 0xFFFF =
 * Not Available : un16 = Day sequence number}
 */
#define VE_REG_HISTORY_DAY27 0x106B

/**
 * History Day -28 {un8 = Version : un32 = Yield [0.01kWh], 0xFFFFFFFF = Not
 * Available : un32 = Consumed [0.01kWh], 0xFFFFFFFF = Not Available : un16 =
 * Battery voltage max [0.01V], 0xFFFF = Not Available : un16 = Battery voltage
 * min [0.01V], 0xFFFF = Not Available : un8 = Error database id, 0 =
 * ERROR_DB_CHARGERS, 1 = ERROR_DB_DEVICES, 0xFF = Not available : un8 = Error 0
 * (see xml for meanings) : un8 = Error 1 (see xml for meanings) : un8 = Error 2
 * (see xml for meanings) : un8 = Error 3 (see xml for meanings) : un16 = Time
 * Bulk [1minutes], 0xFFFF = Not Available : un16 = Time Absorption [1minutes],
 * 0xFFFF = Not Available : un16 = Time Float [1minutes], 0xFFFF = Not Available
 * : un32 = Max power [1W], 0xFFFFFFFF = Not Available : un16 = Battery current
 * max [0.1A], 0xFFFF = Not Available : un16 = Panel voc max [0.01V], 0xFFFF =
 * Not Available : un16 = Day sequence number}
 */
#define VE_REG_HISTORY_DAY28 0x106C

/**
 * History Day -29 {un8 = Version : un32 = Yield [0.01kWh], 0xFFFFFFFF = Not
 * Available : un32 = Consumed [0.01kWh], 0xFFFFFFFF = Not Available : un16 =
 * Battery voltage max [0.01V], 0xFFFF = Not Available : un16 = Battery voltage
 * min [0.01V], 0xFFFF = Not Available : un8 = Error database id, 0 =
 * ERROR_DB_CHARGERS, 1 = ERROR_DB_DEVICES, 0xFF = Not available : un8 = Error 0
 * (see xml for meanings) : un8 = Error 1 (see xml for meanings) : un8 = Error 2
 * (see xml for meanings) : un8 = Error 3 (see xml for meanings) : un16 = Time
 * Bulk [1minutes], 0xFFFF = Not Available : un16 = Time Absorption [1minutes],
 * 0xFFFF = Not Available : un16 = Time Float [1minutes], 0xFFFF = Not Available
 * : un32 = Max power [1W], 0xFFFFFFFF = Not Available : un16 = Battery current
 * max [0.1A], 0xFFFF = Not Available : un16 = Panel voc max [0.01V], 0xFFFF =
 * Not Available : un16 = Day sequence number}
 */
#define VE_REG_HISTORY_DAY29 0x106D

/**
 * History Day -30 {un8 = Version : un32 = Yield [0.01kWh], 0xFFFFFFFF = Not
 * Available : un32 = Consumed [0.01kWh], 0xFFFFFFFF = Not Available : un16 =
 * Battery voltage max [0.01V], 0xFFFF = Not Available : un16 = Battery voltage
 * min [0.01V], 0xFFFF = Not Available : un8 = Error database id, 0 =
 * ERROR_DB_CHARGERS, 1 = ERROR_DB_DEVICES, 0xFF = Not available : un8 = Error 0
 * (see xml for meanings) : un8 = Error 1 (see xml for meanings) : un8 = Error 2
 * (see xml for meanings) : un8 = Error 3 (see xml for meanings) : un16 = Time
 * Bulk [1minutes], 0xFFFF = Not Available : un16 = Time Absorption [1minutes],
 * 0xFFFF = Not Available : un16 = Time Float [1minutes], 0xFFFF = Not Available
 * : un32 = Max power [1W], 0xFFFFFFFF = Not Available : un16 = Battery current
 * max [0.1A], 0xFFFF = Not Available : un16 = Panel voc max [0.01V], 0xFFFF =
 * Not Available : un16 = Day sequence number}
 */
#define VE_REG_HISTORY_DAY30 0x106E

/**
 * History Cycle 0 (active) {un8 = Version : un32 = Start time [1s], 0xFFFFFFFF =
 * Not Available : un32 = Time Bulk [1s], 0xFFFFFFFF = Not Available : un32 =
 * Time Absorption [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Recondition/Equalization [1s], 0xFFFFFFFF = Not Available : un32 = Time Float
 * [1s], 0xFFFFFFFF = Not Available : un32 = Time Storage [1s], 0xFFFFFFFF = Not
 * Available : un32 = Ah Bulk [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Absorption [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Recondition/Equalization [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Float
 * [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Storage [0.1Ah], 0xFFFFFFFF =
 * Not Available : un16 = Voltage start [0.01V], 0xFFFF = Not Available : un16 =
 * Voltage end [0.01V], 0xFFFF = Not Available : un8 = Battery type : bits[4] =
 * Reserved : bits[4] = Termination reason (see xml for meanings) : un8 = Error
 * (see xml for meanings)}
 */
#define VE_REG_HISTORY_CYCLE00 0x1070

/**
 * History Cycle 1 (previous) {un8 = Version : un32 = Start time [1s], 0xFFFFFFFF
 * = Not Available : un32 = Time Bulk [1s], 0xFFFFFFFF = Not Available : un32 =
 * Time Absorption [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Recondition/Equalization [1s], 0xFFFFFFFF = Not Available : un32 = Time Float
 * [1s], 0xFFFFFFFF = Not Available : un32 = Time Storage [1s], 0xFFFFFFFF = Not
 * Available : un32 = Ah Bulk [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Absorption [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Recondition/Equalization [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Float
 * [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Storage [0.1Ah], 0xFFFFFFFF =
 * Not Available : un16 = Voltage start [0.01V], 0xFFFF = Not Available : un16 =
 * Voltage end [0.01V], 0xFFFF = Not Available : un8 = Battery type : bits[4] =
 * Reserved : bits[4] = Termination reason (see xml for meanings) : un8 = Error
 * (see xml for meanings)}
 */
#define VE_REG_HISTORY_CYCLE01 0x1071

/**
 * History Cycle 2 {un8 = Version : un32 = Start time [1s], 0xFFFFFFFF = Not
 * Available : un32 = Time Bulk [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Absorption [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Recondition/Equalization [1s], 0xFFFFFFFF = Not Available : un32 = Time Float
 * [1s], 0xFFFFFFFF = Not Available : un32 = Time Storage [1s], 0xFFFFFFFF = Not
 * Available : un32 = Ah Bulk [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Absorption [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Recondition/Equalization [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Float
 * [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Storage [0.1Ah], 0xFFFFFFFF =
 * Not Available : un16 = Voltage start [0.01V], 0xFFFF = Not Available : un16 =
 * Voltage end [0.01V], 0xFFFF = Not Available : un8 = Battery type : bits[4] =
 * Reserved : bits[4] = Termination reason (see xml for meanings) : un8 = Error
 * (see xml for meanings)}
 */
#define VE_REG_HISTORY_CYCLE02 0x1072

/**
 * History Cycle 3 {un8 = Version : un32 = Start time [1s], 0xFFFFFFFF = Not
 * Available : un32 = Time Bulk [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Absorption [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Recondition/Equalization [1s], 0xFFFFFFFF = Not Available : un32 = Time Float
 * [1s], 0xFFFFFFFF = Not Available : un32 = Time Storage [1s], 0xFFFFFFFF = Not
 * Available : un32 = Ah Bulk [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Absorption [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Recondition/Equalization [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Float
 * [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Storage [0.1Ah], 0xFFFFFFFF =
 * Not Available : un16 = Voltage start [0.01V], 0xFFFF = Not Available : un16 =
 * Voltage end [0.01V], 0xFFFF = Not Available : un8 = Battery type : bits[4] =
 * Reserved : bits[4] = Termination reason (see xml for meanings) : un8 = Error
 * (see xml for meanings)}
 */
#define VE_REG_HISTORY_CYCLE03 0x1073

/**
 * History Cycle 4 {un8 = Version : un32 = Start time [1s], 0xFFFFFFFF = Not
 * Available : un32 = Time Bulk [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Absorption [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Recondition/Equalization [1s], 0xFFFFFFFF = Not Available : un32 = Time Float
 * [1s], 0xFFFFFFFF = Not Available : un32 = Time Storage [1s], 0xFFFFFFFF = Not
 * Available : un32 = Ah Bulk [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Absorption [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Recondition/Equalization [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Float
 * [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Storage [0.1Ah], 0xFFFFFFFF =
 * Not Available : un16 = Voltage start [0.01V], 0xFFFF = Not Available : un16 =
 * Voltage end [0.01V], 0xFFFF = Not Available : un8 = Battery type : bits[4] =
 * Reserved : bits[4] = Termination reason (see xml for meanings) : un8 = Error
 * (see xml for meanings)}
 */
#define VE_REG_HISTORY_CYCLE04 0x1074

/**
 * History Cycle 5 {un8 = Version : un32 = Start time [1s], 0xFFFFFFFF = Not
 * Available : un32 = Time Bulk [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Absorption [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Recondition/Equalization [1s], 0xFFFFFFFF = Not Available : un32 = Time Float
 * [1s], 0xFFFFFFFF = Not Available : un32 = Time Storage [1s], 0xFFFFFFFF = Not
 * Available : un32 = Ah Bulk [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Absorption [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Recondition/Equalization [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Float
 * [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Storage [0.1Ah], 0xFFFFFFFF =
 * Not Available : un16 = Voltage start [0.01V], 0xFFFF = Not Available : un16 =
 * Voltage end [0.01V], 0xFFFF = Not Available : un8 = Battery type : bits[4] =
 * Reserved : bits[4] = Termination reason (see xml for meanings) : un8 = Error
 * (see xml for meanings)}
 */
#define VE_REG_HISTORY_CYCLE05 0x1075

/**
 * History Cycle 6 {un8 = Version : un32 = Start time [1s], 0xFFFFFFFF = Not
 * Available : un32 = Time Bulk [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Absorption [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Recondition/Equalization [1s], 0xFFFFFFFF = Not Available : un32 = Time Float
 * [1s], 0xFFFFFFFF = Not Available : un32 = Time Storage [1s], 0xFFFFFFFF = Not
 * Available : un32 = Ah Bulk [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Absorption [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Recondition/Equalization [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Float
 * [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Storage [0.1Ah], 0xFFFFFFFF =
 * Not Available : un16 = Voltage start [0.01V], 0xFFFF = Not Available : un16 =
 * Voltage end [0.01V], 0xFFFF = Not Available : un8 = Battery type : bits[4] =
 * Reserved : bits[4] = Termination reason (see xml for meanings) : un8 = Error
 * (see xml for meanings)}
 */
#define VE_REG_HISTORY_CYCLE06 0x1076

/**
 * History Cycle 7 {un8 = Version : un32 = Start time [1s], 0xFFFFFFFF = Not
 * Available : un32 = Time Bulk [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Absorption [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Recondition/Equalization [1s], 0xFFFFFFFF = Not Available : un32 = Time Float
 * [1s], 0xFFFFFFFF = Not Available : un32 = Time Storage [1s], 0xFFFFFFFF = Not
 * Available : un32 = Ah Bulk [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Absorption [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Recondition/Equalization [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Float
 * [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Storage [0.1Ah], 0xFFFFFFFF =
 * Not Available : un16 = Voltage start [0.01V], 0xFFFF = Not Available : un16 =
 * Voltage end [0.01V], 0xFFFF = Not Available : un8 = Battery type : bits[4] =
 * Reserved : bits[4] = Termination reason (see xml for meanings) : un8 = Error
 * (see xml for meanings)}
 */
#define VE_REG_HISTORY_CYCLE07 0x1077

/**
 * History Cycle 8 {un8 = Version : un32 = Start time [1s], 0xFFFFFFFF = Not
 * Available : un32 = Time Bulk [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Absorption [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Recondition/Equalization [1s], 0xFFFFFFFF = Not Available : un32 = Time Float
 * [1s], 0xFFFFFFFF = Not Available : un32 = Time Storage [1s], 0xFFFFFFFF = Not
 * Available : un32 = Ah Bulk [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Absorption [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Recondition/Equalization [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Float
 * [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Storage [0.1Ah], 0xFFFFFFFF =
 * Not Available : un16 = Voltage start [0.01V], 0xFFFF = Not Available : un16 =
 * Voltage end [0.01V], 0xFFFF = Not Available : un8 = Battery type : bits[4] =
 * Reserved : bits[4] = Termination reason (see xml for meanings) : un8 = Error
 * (see xml for meanings)}
 */
#define VE_REG_HISTORY_CYCLE08 0x1078

/**
 * History Cycle 9 {un8 = Version : un32 = Start time [1s], 0xFFFFFFFF = Not
 * Available : un32 = Time Bulk [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Absorption [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Recondition/Equalization [1s], 0xFFFFFFFF = Not Available : un32 = Time Float
 * [1s], 0xFFFFFFFF = Not Available : un32 = Time Storage [1s], 0xFFFFFFFF = Not
 * Available : un32 = Ah Bulk [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Absorption [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Recondition/Equalization [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Float
 * [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Storage [0.1Ah], 0xFFFFFFFF =
 * Not Available : un16 = Voltage start [0.01V], 0xFFFF = Not Available : un16 =
 * Voltage end [0.01V], 0xFFFF = Not Available : un8 = Battery type : bits[4] =
 * Reserved : bits[4] = Termination reason (see xml for meanings) : un8 = Error
 * (see xml for meanings)}
 */
#define VE_REG_HISTORY_CYCLE09 0x1079

/**
 * History Cycle 10 {un8 = Version : un32 = Start time [1s], 0xFFFFFFFF = Not
 * Available : un32 = Time Bulk [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Absorption [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Recondition/Equalization [1s], 0xFFFFFFFF = Not Available : un32 = Time Float
 * [1s], 0xFFFFFFFF = Not Available : un32 = Time Storage [1s], 0xFFFFFFFF = Not
 * Available : un32 = Ah Bulk [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Absorption [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Recondition/Equalization [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Float
 * [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Storage [0.1Ah], 0xFFFFFFFF =
 * Not Available : un16 = Voltage start [0.01V], 0xFFFF = Not Available : un16 =
 * Voltage end [0.01V], 0xFFFF = Not Available : un8 = Battery type : bits[4] =
 * Reserved : bits[4] = Termination reason (see xml for meanings) : un8 = Error
 * (see xml for meanings)}
 */
#define VE_REG_HISTORY_CYCLE10 0x107A

/**
 * History Cycle 11 {un8 = Version : un32 = Start time [1s], 0xFFFFFFFF = Not
 * Available : un32 = Time Bulk [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Absorption [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Recondition/Equalization [1s], 0xFFFFFFFF = Not Available : un32 = Time Float
 * [1s], 0xFFFFFFFF = Not Available : un32 = Time Storage [1s], 0xFFFFFFFF = Not
 * Available : un32 = Ah Bulk [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Absorption [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Recondition/Equalization [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Float
 * [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Storage [0.1Ah], 0xFFFFFFFF =
 * Not Available : un16 = Voltage start [0.01V], 0xFFFF = Not Available : un16 =
 * Voltage end [0.01V], 0xFFFF = Not Available : un8 = Battery type : bits[4] =
 * Reserved : bits[4] = Termination reason (see xml for meanings) : un8 = Error
 * (see xml for meanings)}
 */
#define VE_REG_HISTORY_CYCLE11 0x107B

/**
 * History Cycle 12 {un8 = Version : un32 = Start time [1s], 0xFFFFFFFF = Not
 * Available : un32 = Time Bulk [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Absorption [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Recondition/Equalization [1s], 0xFFFFFFFF = Not Available : un32 = Time Float
 * [1s], 0xFFFFFFFF = Not Available : un32 = Time Storage [1s], 0xFFFFFFFF = Not
 * Available : un32 = Ah Bulk [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Absorption [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Recondition/Equalization [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Float
 * [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Storage [0.1Ah], 0xFFFFFFFF =
 * Not Available : un16 = Voltage start [0.01V], 0xFFFF = Not Available : un16 =
 * Voltage end [0.01V], 0xFFFF = Not Available : un8 = Battery type : bits[4] =
 * Reserved : bits[4] = Termination reason (see xml for meanings) : un8 = Error
 * (see xml for meanings)}
 */
#define VE_REG_HISTORY_CYCLE12 0x107C

/**
 * History Cycle 13 {un8 = Version : un32 = Start time [1s], 0xFFFFFFFF = Not
 * Available : un32 = Time Bulk [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Absorption [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Recondition/Equalization [1s], 0xFFFFFFFF = Not Available : un32 = Time Float
 * [1s], 0xFFFFFFFF = Not Available : un32 = Time Storage [1s], 0xFFFFFFFF = Not
 * Available : un32 = Ah Bulk [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Absorption [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Recondition/Equalization [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Float
 * [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Storage [0.1Ah], 0xFFFFFFFF =
 * Not Available : un16 = Voltage start [0.01V], 0xFFFF = Not Available : un16 =
 * Voltage end [0.01V], 0xFFFF = Not Available : un8 = Battery type : bits[4] =
 * Reserved : bits[4] = Termination reason (see xml for meanings) : un8 = Error
 * (see xml for meanings)}
 */
#define VE_REG_HISTORY_CYCLE13 0x107D

/**
 * History Cycle 14 {un8 = Version : un32 = Start time [1s], 0xFFFFFFFF = Not
 * Available : un32 = Time Bulk [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Absorption [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Recondition/Equalization [1s], 0xFFFFFFFF = Not Available : un32 = Time Float
 * [1s], 0xFFFFFFFF = Not Available : un32 = Time Storage [1s], 0xFFFFFFFF = Not
 * Available : un32 = Ah Bulk [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Absorption [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Recondition/Equalization [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Float
 * [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Storage [0.1Ah], 0xFFFFFFFF =
 * Not Available : un16 = Voltage start [0.01V], 0xFFFF = Not Available : un16 =
 * Voltage end [0.01V], 0xFFFF = Not Available : un8 = Battery type : bits[4] =
 * Reserved : bits[4] = Termination reason (see xml for meanings) : un8 = Error
 * (see xml for meanings)}
 */
#define VE_REG_HISTORY_CYCLE14 0x107E

/**
 * History Cycle 15 {un8 = Version : un32 = Start time [1s], 0xFFFFFFFF = Not
 * Available : un32 = Time Bulk [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Absorption [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Recondition/Equalization [1s], 0xFFFFFFFF = Not Available : un32 = Time Float
 * [1s], 0xFFFFFFFF = Not Available : un32 = Time Storage [1s], 0xFFFFFFFF = Not
 * Available : un32 = Ah Bulk [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Absorption [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Recondition/Equalization [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Float
 * [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Storage [0.1Ah], 0xFFFFFFFF =
 * Not Available : un16 = Voltage start [0.01V], 0xFFFF = Not Available : un16 =
 * Voltage end [0.01V], 0xFFFF = Not Available : un8 = Battery type : bits[4] =
 * Reserved : bits[4] = Termination reason (see xml for meanings) : un8 = Error
 * (see xml for meanings)}
 */
#define VE_REG_HISTORY_CYCLE15 0x107F

/**
 * History Cycle 16 {un8 = Version : un32 = Start time [1s], 0xFFFFFFFF = Not
 * Available : un32 = Time Bulk [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Absorption [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Recondition/Equalization [1s], 0xFFFFFFFF = Not Available : un32 = Time Float
 * [1s], 0xFFFFFFFF = Not Available : un32 = Time Storage [1s], 0xFFFFFFFF = Not
 * Available : un32 = Ah Bulk [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Absorption [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Recondition/Equalization [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Float
 * [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Storage [0.1Ah], 0xFFFFFFFF =
 * Not Available : un16 = Voltage start [0.01V], 0xFFFF = Not Available : un16 =
 * Voltage end [0.01V], 0xFFFF = Not Available : un8 = Battery type : bits[4] =
 * Reserved : bits[4] = Termination reason (see xml for meanings) : un8 = Error
 * (see xml for meanings)}
 */
#define VE_REG_HISTORY_CYCLE16 0x1080

/**
 * History Cycle 17 {un8 = Version : un32 = Start time [1s], 0xFFFFFFFF = Not
 * Available : un32 = Time Bulk [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Absorption [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Recondition/Equalization [1s], 0xFFFFFFFF = Not Available : un32 = Time Float
 * [1s], 0xFFFFFFFF = Not Available : un32 = Time Storage [1s], 0xFFFFFFFF = Not
 * Available : un32 = Ah Bulk [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Absorption [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Recondition/Equalization [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Float
 * [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Storage [0.1Ah], 0xFFFFFFFF =
 * Not Available : un16 = Voltage start [0.01V], 0xFFFF = Not Available : un16 =
 * Voltage end [0.01V], 0xFFFF = Not Available : un8 = Battery type : bits[4] =
 * Reserved : bits[4] = Termination reason (see xml for meanings) : un8 = Error
 * (see xml for meanings)}
 */
#define VE_REG_HISTORY_CYCLE17 0x1081

/**
 * History Cycle 18 {un8 = Version : un32 = Start time [1s], 0xFFFFFFFF = Not
 * Available : un32 = Time Bulk [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Absorption [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Recondition/Equalization [1s], 0xFFFFFFFF = Not Available : un32 = Time Float
 * [1s], 0xFFFFFFFF = Not Available : un32 = Time Storage [1s], 0xFFFFFFFF = Not
 * Available : un32 = Ah Bulk [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Absorption [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Recondition/Equalization [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Float
 * [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Storage [0.1Ah], 0xFFFFFFFF =
 * Not Available : un16 = Voltage start [0.01V], 0xFFFF = Not Available : un16 =
 * Voltage end [0.01V], 0xFFFF = Not Available : un8 = Battery type : bits[4] =
 * Reserved : bits[4] = Termination reason (see xml for meanings) : un8 = Error
 * (see xml for meanings)}
 */
#define VE_REG_HISTORY_CYCLE18 0x1082

/**
 * History Cycle 19 {un8 = Version : un32 = Start time [1s], 0xFFFFFFFF = Not
 * Available : un32 = Time Bulk [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Absorption [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Recondition/Equalization [1s], 0xFFFFFFFF = Not Available : un32 = Time Float
 * [1s], 0xFFFFFFFF = Not Available : un32 = Time Storage [1s], 0xFFFFFFFF = Not
 * Available : un32 = Ah Bulk [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Absorption [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Recondition/Equalization [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Float
 * [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Storage [0.1Ah], 0xFFFFFFFF =
 * Not Available : un16 = Voltage start [0.01V], 0xFFFF = Not Available : un16 =
 * Voltage end [0.01V], 0xFFFF = Not Available : un8 = Battery type : bits[4] =
 * Reserved : bits[4] = Termination reason (see xml for meanings) : un8 = Error
 * (see xml for meanings)}
 */
#define VE_REG_HISTORY_CYCLE19 0x1083

/**
 * History Cycle 20 {un8 = Version : un32 = Start time [1s], 0xFFFFFFFF = Not
 * Available : un32 = Time Bulk [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Absorption [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Recondition/Equalization [1s], 0xFFFFFFFF = Not Available : un32 = Time Float
 * [1s], 0xFFFFFFFF = Not Available : un32 = Time Storage [1s], 0xFFFFFFFF = Not
 * Available : un32 = Ah Bulk [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Absorption [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Recondition/Equalization [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Float
 * [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Storage [0.1Ah], 0xFFFFFFFF =
 * Not Available : un16 = Voltage start [0.01V], 0xFFFF = Not Available : un16 =
 * Voltage end [0.01V], 0xFFFF = Not Available : un8 = Battery type : bits[4] =
 * Reserved : bits[4] = Termination reason (see xml for meanings) : un8 = Error
 * (see xml for meanings)}
 */
#define VE_REG_HISTORY_CYCLE20 0x1084

/**
 * History Cycle 21 {un8 = Version : un32 = Start time [1s], 0xFFFFFFFF = Not
 * Available : un32 = Time Bulk [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Absorption [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Recondition/Equalization [1s], 0xFFFFFFFF = Not Available : un32 = Time Float
 * [1s], 0xFFFFFFFF = Not Available : un32 = Time Storage [1s], 0xFFFFFFFF = Not
 * Available : un32 = Ah Bulk [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Absorption [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Recondition/Equalization [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Float
 * [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Storage [0.1Ah], 0xFFFFFFFF =
 * Not Available : un16 = Voltage start [0.01V], 0xFFFF = Not Available : un16 =
 * Voltage end [0.01V], 0xFFFF = Not Available : un8 = Battery type : bits[4] =
 * Reserved : bits[4] = Termination reason (see xml for meanings) : un8 = Error
 * (see xml for meanings)}
 */
#define VE_REG_HISTORY_CYCLE21 0x1085

/**
 * History Cycle 22 {un8 = Version : un32 = Start time [1s], 0xFFFFFFFF = Not
 * Available : un32 = Time Bulk [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Absorption [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Recondition/Equalization [1s], 0xFFFFFFFF = Not Available : un32 = Time Float
 * [1s], 0xFFFFFFFF = Not Available : un32 = Time Storage [1s], 0xFFFFFFFF = Not
 * Available : un32 = Ah Bulk [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Absorption [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Recondition/Equalization [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Float
 * [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Storage [0.1Ah], 0xFFFFFFFF =
 * Not Available : un16 = Voltage start [0.01V], 0xFFFF = Not Available : un16 =
 * Voltage end [0.01V], 0xFFFF = Not Available : un8 = Battery type : bits[4] =
 * Reserved : bits[4] = Termination reason (see xml for meanings) : un8 = Error
 * (see xml for meanings)}
 */
#define VE_REG_HISTORY_CYCLE22 0x1086

/**
 * History Cycle 23 {un8 = Version : un32 = Start time [1s], 0xFFFFFFFF = Not
 * Available : un32 = Time Bulk [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Absorption [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Recondition/Equalization [1s], 0xFFFFFFFF = Not Available : un32 = Time Float
 * [1s], 0xFFFFFFFF = Not Available : un32 = Time Storage [1s], 0xFFFFFFFF = Not
 * Available : un32 = Ah Bulk [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Absorption [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Recondition/Equalization [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Float
 * [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Storage [0.1Ah], 0xFFFFFFFF =
 * Not Available : un16 = Voltage start [0.01V], 0xFFFF = Not Available : un16 =
 * Voltage end [0.01V], 0xFFFF = Not Available : un8 = Battery type : bits[4] =
 * Reserved : bits[4] = Termination reason (see xml for meanings) : un8 = Error
 * (see xml for meanings)}
 */
#define VE_REG_HISTORY_CYCLE23 0x1087

/**
 * History Cycle 24 {un8 = Version : un32 = Start time [1s], 0xFFFFFFFF = Not
 * Available : un32 = Time Bulk [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Absorption [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Recondition/Equalization [1s], 0xFFFFFFFF = Not Available : un32 = Time Float
 * [1s], 0xFFFFFFFF = Not Available : un32 = Time Storage [1s], 0xFFFFFFFF = Not
 * Available : un32 = Ah Bulk [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Absorption [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Recondition/Equalization [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Float
 * [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Storage [0.1Ah], 0xFFFFFFFF =
 * Not Available : un16 = Voltage start [0.01V], 0xFFFF = Not Available : un16 =
 * Voltage end [0.01V], 0xFFFF = Not Available : un8 = Battery type : bits[4] =
 * Reserved : bits[4] = Termination reason (see xml for meanings) : un8 = Error
 * (see xml for meanings)}
 */
#define VE_REG_HISTORY_CYCLE24 0x1088

/**
 * History Cycle 25 {un8 = Version : un32 = Start time [1s], 0xFFFFFFFF = Not
 * Available : un32 = Time Bulk [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Absorption [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Recondition/Equalization [1s], 0xFFFFFFFF = Not Available : un32 = Time Float
 * [1s], 0xFFFFFFFF = Not Available : un32 = Time Storage [1s], 0xFFFFFFFF = Not
 * Available : un32 = Ah Bulk [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Absorption [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Recondition/Equalization [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Float
 * [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Storage [0.1Ah], 0xFFFFFFFF =
 * Not Available : un16 = Voltage start [0.01V], 0xFFFF = Not Available : un16 =
 * Voltage end [0.01V], 0xFFFF = Not Available : un8 = Battery type : bits[4] =
 * Reserved : bits[4] = Termination reason (see xml for meanings) : un8 = Error
 * (see xml for meanings)}
 */
#define VE_REG_HISTORY_CYCLE25 0x1089

/**
 * History Cycle 26 {un8 = Version : un32 = Start time [1s], 0xFFFFFFFF = Not
 * Available : un32 = Time Bulk [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Absorption [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Recondition/Equalization [1s], 0xFFFFFFFF = Not Available : un32 = Time Float
 * [1s], 0xFFFFFFFF = Not Available : un32 = Time Storage [1s], 0xFFFFFFFF = Not
 * Available : un32 = Ah Bulk [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Absorption [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Recondition/Equalization [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Float
 * [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Storage [0.1Ah], 0xFFFFFFFF =
 * Not Available : un16 = Voltage start [0.01V], 0xFFFF = Not Available : un16 =
 * Voltage end [0.01V], 0xFFFF = Not Available : un8 = Battery type : bits[4] =
 * Reserved : bits[4] = Termination reason (see xml for meanings) : un8 = Error
 * (see xml for meanings)}
 */
#define VE_REG_HISTORY_CYCLE26 0x108A

/**
 * History Cycle 27 {un8 = Version : un32 = Start time [1s], 0xFFFFFFFF = Not
 * Available : un32 = Time Bulk [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Absorption [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Recondition/Equalization [1s], 0xFFFFFFFF = Not Available : un32 = Time Float
 * [1s], 0xFFFFFFFF = Not Available : un32 = Time Storage [1s], 0xFFFFFFFF = Not
 * Available : un32 = Ah Bulk [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Absorption [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Recondition/Equalization [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Float
 * [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Storage [0.1Ah], 0xFFFFFFFF =
 * Not Available : un16 = Voltage start [0.01V], 0xFFFF = Not Available : un16 =
 * Voltage end [0.01V], 0xFFFF = Not Available : un8 = Battery type : bits[4] =
 * Reserved : bits[4] = Termination reason (see xml for meanings) : un8 = Error
 * (see xml for meanings)}
 */
#define VE_REG_HISTORY_CYCLE27 0x108B

/**
 * History Cycle 28 {un8 = Version : un32 = Start time [1s], 0xFFFFFFFF = Not
 * Available : un32 = Time Bulk [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Absorption [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Recondition/Equalization [1s], 0xFFFFFFFF = Not Available : un32 = Time Float
 * [1s], 0xFFFFFFFF = Not Available : un32 = Time Storage [1s], 0xFFFFFFFF = Not
 * Available : un32 = Ah Bulk [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Absorption [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Recondition/Equalization [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Float
 * [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Storage [0.1Ah], 0xFFFFFFFF =
 * Not Available : un16 = Voltage start [0.01V], 0xFFFF = Not Available : un16 =
 * Voltage end [0.01V], 0xFFFF = Not Available : un8 = Battery type : bits[4] =
 * Reserved : bits[4] = Termination reason (see xml for meanings) : un8 = Error
 * (see xml for meanings)}
 */
#define VE_REG_HISTORY_CYCLE28 0x108C

/**
 * History Cycle 29 {un8 = Version : un32 = Start time [1s], 0xFFFFFFFF = Not
 * Available : un32 = Time Bulk [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Absorption [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Recondition/Equalization [1s], 0xFFFFFFFF = Not Available : un32 = Time Float
 * [1s], 0xFFFFFFFF = Not Available : un32 = Time Storage [1s], 0xFFFFFFFF = Not
 * Available : un32 = Ah Bulk [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Absorption [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Recondition/Equalization [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Float
 * [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Storage [0.1Ah], 0xFFFFFFFF =
 * Not Available : un16 = Voltage start [0.01V], 0xFFFF = Not Available : un16 =
 * Voltage end [0.01V], 0xFFFF = Not Available : un8 = Battery type : bits[4] =
 * Reserved : bits[4] = Termination reason (see xml for meanings) : un8 = Error
 * (see xml for meanings)}
 */
#define VE_REG_HISTORY_CYCLE29 0x108D

/**
 * History Cycle 30 {un8 = Version : un32 = Start time [1s], 0xFFFFFFFF = Not
 * Available : un32 = Time Bulk [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Absorption [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Recondition/Equalization [1s], 0xFFFFFFFF = Not Available : un32 = Time Float
 * [1s], 0xFFFFFFFF = Not Available : un32 = Time Storage [1s], 0xFFFFFFFF = Not
 * Available : un32 = Ah Bulk [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Absorption [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Recondition/Equalization [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Float
 * [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Storage [0.1Ah], 0xFFFFFFFF =
 * Not Available : un16 = Voltage start [0.01V], 0xFFFF = Not Available : un16 =
 * Voltage end [0.01V], 0xFFFF = Not Available : un8 = Battery type : bits[4] =
 * Reserved : bits[4] = Termination reason (see xml for meanings) : un8 = Error
 * (see xml for meanings)}
 */
#define VE_REG_HISTORY_CYCLE30 0x108E

/**
 * History Cycle 31 {un8 = Version : un32 = Start time [1s], 0xFFFFFFFF = Not
 * Available : un32 = Time Bulk [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Absorption [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Recondition/Equalization [1s], 0xFFFFFFFF = Not Available : un32 = Time Float
 * [1s], 0xFFFFFFFF = Not Available : un32 = Time Storage [1s], 0xFFFFFFFF = Not
 * Available : un32 = Ah Bulk [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Absorption [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Recondition/Equalization [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Float
 * [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Storage [0.1Ah], 0xFFFFFFFF =
 * Not Available : un16 = Voltage start [0.01V], 0xFFFF = Not Available : un16 =
 * Voltage end [0.01V], 0xFFFF = Not Available : un8 = Battery type : bits[4] =
 * Reserved : bits[4] = Termination reason (see xml for meanings) : un8 = Error
 * (see xml for meanings)}
 */
#define VE_REG_HISTORY_CYCLE31 0x108F

/**
 * History Cycle 32 {un8 = Version : un32 = Start time [1s], 0xFFFFFFFF = Not
 * Available : un32 = Time Bulk [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Absorption [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Recondition/Equalization [1s], 0xFFFFFFFF = Not Available : un32 = Time Float
 * [1s], 0xFFFFFFFF = Not Available : un32 = Time Storage [1s], 0xFFFFFFFF = Not
 * Available : un32 = Ah Bulk [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Absorption [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Recondition/Equalization [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Float
 * [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Storage [0.1Ah], 0xFFFFFFFF =
 * Not Available : un16 = Voltage start [0.01V], 0xFFFF = Not Available : un16 =
 * Voltage end [0.01V], 0xFFFF = Not Available : un8 = Battery type : bits[4] =
 * Reserved : bits[4] = Termination reason (see xml for meanings) : un8 = Error
 * (see xml for meanings)}
 */
#define VE_REG_HISTORY_CYCLE32 0x1090

/**
 * History Cycle 33 {un8 = Version : un32 = Start time [1s], 0xFFFFFFFF = Not
 * Available : un32 = Time Bulk [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Absorption [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Recondition/Equalization [1s], 0xFFFFFFFF = Not Available : un32 = Time Float
 * [1s], 0xFFFFFFFF = Not Available : un32 = Time Storage [1s], 0xFFFFFFFF = Not
 * Available : un32 = Ah Bulk [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Absorption [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Recondition/Equalization [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Float
 * [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Storage [0.1Ah], 0xFFFFFFFF =
 * Not Available : un16 = Voltage start [0.01V], 0xFFFF = Not Available : un16 =
 * Voltage end [0.01V], 0xFFFF = Not Available : un8 = Battery type : bits[4] =
 * Reserved : bits[4] = Termination reason (see xml for meanings) : un8 = Error
 * (see xml for meanings)}
 */
#define VE_REG_HISTORY_CYCLE33 0x1091

/**
 * History Cycle 34 {un8 = Version : un32 = Start time [1s], 0xFFFFFFFF = Not
 * Available : un32 = Time Bulk [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Absorption [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Recondition/Equalization [1s], 0xFFFFFFFF = Not Available : un32 = Time Float
 * [1s], 0xFFFFFFFF = Not Available : un32 = Time Storage [1s], 0xFFFFFFFF = Not
 * Available : un32 = Ah Bulk [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Absorption [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Recondition/Equalization [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Float
 * [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Storage [0.1Ah], 0xFFFFFFFF =
 * Not Available : un16 = Voltage start [0.01V], 0xFFFF = Not Available : un16 =
 * Voltage end [0.01V], 0xFFFF = Not Available : un8 = Battery type : bits[4] =
 * Reserved : bits[4] = Termination reason (see xml for meanings) : un8 = Error
 * (see xml for meanings)}
 */
#define VE_REG_HISTORY_CYCLE34 0x1092

/**
 * History Cycle 35 {un8 = Version : un32 = Start time [1s], 0xFFFFFFFF = Not
 * Available : un32 = Time Bulk [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Absorption [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Recondition/Equalization [1s], 0xFFFFFFFF = Not Available : un32 = Time Float
 * [1s], 0xFFFFFFFF = Not Available : un32 = Time Storage [1s], 0xFFFFFFFF = Not
 * Available : un32 = Ah Bulk [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Absorption [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Recondition/Equalization [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Float
 * [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Storage [0.1Ah], 0xFFFFFFFF =
 * Not Available : un16 = Voltage start [0.01V], 0xFFFF = Not Available : un16 =
 * Voltage end [0.01V], 0xFFFF = Not Available : un8 = Battery type : bits[4] =
 * Reserved : bits[4] = Termination reason (see xml for meanings) : un8 = Error
 * (see xml for meanings)}
 */
#define VE_REG_HISTORY_CYCLE35 0x1093

/**
 * History Cycle 36 {un8 = Version : un32 = Start time [1s], 0xFFFFFFFF = Not
 * Available : un32 = Time Bulk [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Absorption [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Recondition/Equalization [1s], 0xFFFFFFFF = Not Available : un32 = Time Float
 * [1s], 0xFFFFFFFF = Not Available : un32 = Time Storage [1s], 0xFFFFFFFF = Not
 * Available : un32 = Ah Bulk [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Absorption [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Recondition/Equalization [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Float
 * [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Storage [0.1Ah], 0xFFFFFFFF =
 * Not Available : un16 = Voltage start [0.01V], 0xFFFF = Not Available : un16 =
 * Voltage end [0.01V], 0xFFFF = Not Available : un8 = Battery type : bits[4] =
 * Reserved : bits[4] = Termination reason (see xml for meanings) : un8 = Error
 * (see xml for meanings)}
 */
#define VE_REG_HISTORY_CYCLE36 0x1094

/**
 * History Cycle 37 {un8 = Version : un32 = Start time [1s], 0xFFFFFFFF = Not
 * Available : un32 = Time Bulk [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Absorption [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Recondition/Equalization [1s], 0xFFFFFFFF = Not Available : un32 = Time Float
 * [1s], 0xFFFFFFFF = Not Available : un32 = Time Storage [1s], 0xFFFFFFFF = Not
 * Available : un32 = Ah Bulk [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Absorption [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Recondition/Equalization [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Float
 * [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Storage [0.1Ah], 0xFFFFFFFF =
 * Not Available : un16 = Voltage start [0.01V], 0xFFFF = Not Available : un16 =
 * Voltage end [0.01V], 0xFFFF = Not Available : un8 = Battery type : bits[4] =
 * Reserved : bits[4] = Termination reason (see xml for meanings) : un8 = Error
 * (see xml for meanings)}
 */
#define VE_REG_HISTORY_CYCLE37 0x1095

/**
 * History Cycle 38 {un8 = Version : un32 = Start time [1s], 0xFFFFFFFF = Not
 * Available : un32 = Time Bulk [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Absorption [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Recondition/Equalization [1s], 0xFFFFFFFF = Not Available : un32 = Time Float
 * [1s], 0xFFFFFFFF = Not Available : un32 = Time Storage [1s], 0xFFFFFFFF = Not
 * Available : un32 = Ah Bulk [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Absorption [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Recondition/Equalization [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Float
 * [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Storage [0.1Ah], 0xFFFFFFFF =
 * Not Available : un16 = Voltage start [0.01V], 0xFFFF = Not Available : un16 =
 * Voltage end [0.01V], 0xFFFF = Not Available : un8 = Battery type : bits[4] =
 * Reserved : bits[4] = Termination reason (see xml for meanings) : un8 = Error
 * (see xml for meanings)}
 */
#define VE_REG_HISTORY_CYCLE38 0x1096

/**
 * History Cycle 39 {un8 = Version : un32 = Start time [1s], 0xFFFFFFFF = Not
 * Available : un32 = Time Bulk [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Absorption [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Recondition/Equalization [1s], 0xFFFFFFFF = Not Available : un32 = Time Float
 * [1s], 0xFFFFFFFF = Not Available : un32 = Time Storage [1s], 0xFFFFFFFF = Not
 * Available : un32 = Ah Bulk [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Absorption [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Recondition/Equalization [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Float
 * [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Storage [0.1Ah], 0xFFFFFFFF =
 * Not Available : un16 = Voltage start [0.01V], 0xFFFF = Not Available : un16 =
 * Voltage end [0.01V], 0xFFFF = Not Available : un8 = Battery type : bits[4] =
 * Reserved : bits[4] = Termination reason (see xml for meanings) : un8 = Error
 * (see xml for meanings)}
 */
#define VE_REG_HISTORY_CYCLE39 0x1097

/**
 * History Cycle 40 {un8 = Version : un32 = Start time [1s], 0xFFFFFFFF = Not
 * Available : un32 = Time Bulk [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Absorption [1s], 0xFFFFFFFF = Not Available : un32 = Time
 * Recondition/Equalization [1s], 0xFFFFFFFF = Not Available : un32 = Time Float
 * [1s], 0xFFFFFFFF = Not Available : un32 = Time Storage [1s], 0xFFFFFFFF = Not
 * Available : un32 = Ah Bulk [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Absorption [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah
 * Recondition/Equalization [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Float
 * [0.1Ah], 0xFFFFFFFF = Not Available : un32 = Ah Storage [0.1Ah], 0xFFFFFFFF =
 * Not Available : un16 = Voltage start [0.01V], 0xFFFF = Not Available : un16 =
 * Voltage end [0.01V], 0xFFFF = Not Available : un8 = Battery type : bits[4] =
 * Reserved : bits[4] = Termination reason (see xml for meanings) : un8 = Error
 * (see xml for meanings)}
 */
#define VE_REG_HISTORY_CYCLE40 0x1098

/**
 * History Mppt Day 0 (today) {un8 = Version : un16 = Day sequence number : un16
 * = Energy tracker 1 [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 2
 * [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 3 [0.01kWh], 0xFFFF
 * = Not Available : un16 = Energy tracker 4 [0.01kWh], 0xFFFF = Not Available :
 * un16 = Peak power tracker 1 [1W], 0xFFFF = Not Available : un16 = Peak power
 * tracker 2 [1W], 0xFFFF = Not Available : un16 = Peak power tracker 3 [1W],
 * 0xFFFF = Not Available : un16 = Peak power tracker 4 [1W], 0xFFFF = Not
 * Available : un16 = Voc max tracker 1 [0.01V], 0xFFFF = Not Available : un16 =
 * Voc max tracker 2 [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 3
 * [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 4 [0.01V], 0xFFFF =
 * Not Available :  [0.01V]}
 * @remark requesting a day that is not (yet) available results in an error
 * response (ve.can nack or ve.direct flags!=0)
 */
#define VE_REG_HISTORY_MPPT_DAY00 0x10A0

/**
 * History MPPT Day -1 (yesterday) {un8 = Version : un16 = Day sequence number :
 * un16 = Energy tracker 1 [0.01kWh], 0xFFFF = Not Available : un16 = Energy
 * tracker 2 [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 3
 * [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 4 [0.01kWh], 0xFFFF
 * = Not Available : un16 = Peak power tracker 1 [1W], 0xFFFF = Not Available :
 * un16 = Peak power tracker 2 [1W], 0xFFFF = Not Available : un16 = Peak power
 * tracker 3 [1W], 0xFFFF = Not Available : un16 = Peak power tracker 4 [1W],
 * 0xFFFF = Not Available : un16 = Voc max tracker 1 [0.01V], 0xFFFF = Not
 * Available : un16 = Voc max tracker 2 [0.01V], 0xFFFF = Not Available : un16 =
 * Voc max tracker 3 [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 4
 * [0.01V], 0xFFFF = Not Available :  [0.01V]}
 */
#define VE_REG_HISTORY_MPPT_DAY01 0x10A1

/**
 * History MPPT Day -2 {un8 = Version : un16 = Day sequence number : un16 =
 * Energy tracker 1 [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 2
 * [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 3 [0.01kWh], 0xFFFF
 * = Not Available : un16 = Energy tracker 4 [0.01kWh], 0xFFFF = Not Available :
 * un16 = Peak power tracker 1 [1W], 0xFFFF = Not Available : un16 = Peak power
 * tracker 2 [1W], 0xFFFF = Not Available : un16 = Peak power tracker 3 [1W],
 * 0xFFFF = Not Available : un16 = Peak power tracker 4 [1W], 0xFFFF = Not
 * Available : un16 = Voc max tracker 1 [0.01V], 0xFFFF = Not Available : un16 =
 * Voc max tracker 2 [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 3
 * [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 4 [0.01V], 0xFFFF =
 * Not Available :  [0.01V]}
 */
#define VE_REG_HISTORY_MPPT_DAY02 0x10A2

/**
 * History MPPT Day -3 {un8 = Version : un16 = Day sequence number : un16 =
 * Energy tracker 1 [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 2
 * [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 3 [0.01kWh], 0xFFFF
 * = Not Available : un16 = Energy tracker 4 [0.01kWh], 0xFFFF = Not Available :
 * un16 = Peak power tracker 1 [1W], 0xFFFF = Not Available : un16 = Peak power
 * tracker 2 [1W], 0xFFFF = Not Available : un16 = Peak power tracker 3 [1W],
 * 0xFFFF = Not Available : un16 = Peak power tracker 4 [1W], 0xFFFF = Not
 * Available : un16 = Voc max tracker 1 [0.01V], 0xFFFF = Not Available : un16 =
 * Voc max tracker 2 [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 3
 * [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 4 [0.01V], 0xFFFF =
 * Not Available :  [0.01V]}
 */
#define VE_REG_HISTORY_MPPT_DAY03 0x10A3

/**
 * History MPPT Day -4 {un8 = Version : un16 = Day sequence number : un16 =
 * Energy tracker 1 [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 2
 * [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 3 [0.01kWh], 0xFFFF
 * = Not Available : un16 = Energy tracker 4 [0.01kWh], 0xFFFF = Not Available :
 * un16 = Peak power tracker 1 [1W], 0xFFFF = Not Available : un16 = Peak power
 * tracker 2 [1W], 0xFFFF = Not Available : un16 = Peak power tracker 3 [1W],
 * 0xFFFF = Not Available : un16 = Peak power tracker 4 [1W], 0xFFFF = Not
 * Available : un16 = Voc max tracker 1 [0.01V], 0xFFFF = Not Available : un16 =
 * Voc max tracker 2 [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 3
 * [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 4 [0.01V], 0xFFFF =
 * Not Available :  [0.01V]}
 */
#define VE_REG_HISTORY_MPPT_DAY04 0x10A4

/**
 * History MPPT Day -5 {un8 = Version : un16 = Day sequence number : un16 =
 * Energy tracker 1 [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 2
 * [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 3 [0.01kWh], 0xFFFF
 * = Not Available : un16 = Energy tracker 4 [0.01kWh], 0xFFFF = Not Available :
 * un16 = Peak power tracker 1 [1W], 0xFFFF = Not Available : un16 = Peak power
 * tracker 2 [1W], 0xFFFF = Not Available : un16 = Peak power tracker 3 [1W],
 * 0xFFFF = Not Available : un16 = Peak power tracker 4 [1W], 0xFFFF = Not
 * Available : un16 = Voc max tracker 1 [0.01V], 0xFFFF = Not Available : un16 =
 * Voc max tracker 2 [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 3
 * [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 4 [0.01V], 0xFFFF =
 * Not Available :  [0.01V]}
 */
#define VE_REG_HISTORY_MPPT_DAY05 0x10A5

/**
 * History MPPT Day -6 {un8 = Version : un16 = Day sequence number : un16 =
 * Energy tracker 1 [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 2
 * [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 3 [0.01kWh], 0xFFFF
 * = Not Available : un16 = Energy tracker 4 [0.01kWh], 0xFFFF = Not Available :
 * un16 = Peak power tracker 1 [1W], 0xFFFF = Not Available : un16 = Peak power
 * tracker 2 [1W], 0xFFFF = Not Available : un16 = Peak power tracker 3 [1W],
 * 0xFFFF = Not Available : un16 = Peak power tracker 4 [1W], 0xFFFF = Not
 * Available : un16 = Voc max tracker 1 [0.01V], 0xFFFF = Not Available : un16 =
 * Voc max tracker 2 [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 3
 * [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 4 [0.01V], 0xFFFF =
 * Not Available :  [0.01V]}
 */
#define VE_REG_HISTORY_MPPT_DAY06 0x10A6

/**
 * History MPPT Day -7 {un8 = Version : un16 = Day sequence number : un16 =
 * Energy tracker 1 [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 2
 * [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 3 [0.01kWh], 0xFFFF
 * = Not Available : un16 = Energy tracker 4 [0.01kWh], 0xFFFF = Not Available :
 * un16 = Peak power tracker 1 [1W], 0xFFFF = Not Available : un16 = Peak power
 * tracker 2 [1W], 0xFFFF = Not Available : un16 = Peak power tracker 3 [1W],
 * 0xFFFF = Not Available : un16 = Peak power tracker 4 [1W], 0xFFFF = Not
 * Available : un16 = Voc max tracker 1 [0.01V], 0xFFFF = Not Available : un16 =
 * Voc max tracker 2 [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 3
 * [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 4 [0.01V], 0xFFFF =
 * Not Available :  [0.01V]}
 */
#define VE_REG_HISTORY_MPPT_DAY07 0x10A7

/**
 * History MPPT Day -8 {un8 = Version : un16 = Day sequence number : un16 =
 * Energy tracker 1 [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 2
 * [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 3 [0.01kWh], 0xFFFF
 * = Not Available : un16 = Energy tracker 4 [0.01kWh], 0xFFFF = Not Available :
 * un16 = Peak power tracker 1 [1W], 0xFFFF = Not Available : un16 = Peak power
 * tracker 2 [1W], 0xFFFF = Not Available : un16 = Peak power tracker 3 [1W],
 * 0xFFFF = Not Available : un16 = Peak power tracker 4 [1W], 0xFFFF = Not
 * Available : un16 = Voc max tracker 1 [0.01V], 0xFFFF = Not Available : un16 =
 * Voc max tracker 2 [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 3
 * [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 4 [0.01V], 0xFFFF =
 * Not Available :  [0.01V]}
 */
#define VE_REG_HISTORY_MPPT_DAY08 0x10A8

/**
 * History MPPT Day -9 {un8 = Version : un16 = Day sequence number : un16 =
 * Energy tracker 1 [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 2
 * [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 3 [0.01kWh], 0xFFFF
 * = Not Available : un16 = Energy tracker 4 [0.01kWh], 0xFFFF = Not Available :
 * un16 = Peak power tracker 1 [1W], 0xFFFF = Not Available : un16 = Peak power
 * tracker 2 [1W], 0xFFFF = Not Available : un16 = Peak power tracker 3 [1W],
 * 0xFFFF = Not Available : un16 = Peak power tracker 4 [1W], 0xFFFF = Not
 * Available : un16 = Voc max tracker 1 [0.01V], 0xFFFF = Not Available : un16 =
 * Voc max tracker 2 [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 3
 * [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 4 [0.01V], 0xFFFF =
 * Not Available :  [0.01V]}
 */
#define VE_REG_HISTORY_MPPT_DAY09 0x10A9

/**
 * History MPPT Day -10 {un8 = Version : un16 = Day sequence number : un16 =
 * Energy tracker 1 [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 2
 * [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 3 [0.01kWh], 0xFFFF
 * = Not Available : un16 = Energy tracker 4 [0.01kWh], 0xFFFF = Not Available :
 * un16 = Peak power tracker 1 [1W], 0xFFFF = Not Available : un16 = Peak power
 * tracker 2 [1W], 0xFFFF = Not Available : un16 = Peak power tracker 3 [1W],
 * 0xFFFF = Not Available : un16 = Peak power tracker 4 [1W], 0xFFFF = Not
 * Available : un16 = Voc max tracker 1 [0.01V], 0xFFFF = Not Available : un16 =
 * Voc max tracker 2 [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 3
 * [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 4 [0.01V], 0xFFFF =
 * Not Available :  [0.01V]}
 */
#define VE_REG_HISTORY_MPPT_DAY10 0x10AA

/**
 * History MPPT Day -11 {un8 = Version : un16 = Day sequence number : un16 =
 * Energy tracker 1 [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 2
 * [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 3 [0.01kWh], 0xFFFF
 * = Not Available : un16 = Energy tracker 4 [0.01kWh], 0xFFFF = Not Available :
 * un16 = Peak power tracker 1 [1W], 0xFFFF = Not Available : un16 = Peak power
 * tracker 2 [1W], 0xFFFF = Not Available : un16 = Peak power tracker 3 [1W],
 * 0xFFFF = Not Available : un16 = Peak power tracker 4 [1W], 0xFFFF = Not
 * Available : un16 = Voc max tracker 1 [0.01V], 0xFFFF = Not Available : un16 =
 * Voc max tracker 2 [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 3
 * [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 4 [0.01V], 0xFFFF =
 * Not Available :  [0.01V]}
 */
#define VE_REG_HISTORY_MPPT_DAY11 0x10AB

/**
 * History MPPT Day -12 {un8 = Version : un16 = Day sequence number : un16 =
 * Energy tracker 1 [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 2
 * [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 3 [0.01kWh], 0xFFFF
 * = Not Available : un16 = Energy tracker 4 [0.01kWh], 0xFFFF = Not Available :
 * un16 = Peak power tracker 1 [1W], 0xFFFF = Not Available : un16 = Peak power
 * tracker 2 [1W], 0xFFFF = Not Available : un16 = Peak power tracker 3 [1W],
 * 0xFFFF = Not Available : un16 = Peak power tracker 4 [1W], 0xFFFF = Not
 * Available : un16 = Voc max tracker 1 [0.01V], 0xFFFF = Not Available : un16 =
 * Voc max tracker 2 [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 3
 * [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 4 [0.01V], 0xFFFF =
 * Not Available :  [0.01V]}
 */
#define VE_REG_HISTORY_MPPT_DAY12 0x10AC

/**
 * History MPPT Day -13 {un8 = Version : un16 = Day sequence number : un16 =
 * Energy tracker 1 [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 2
 * [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 3 [0.01kWh], 0xFFFF
 * = Not Available : un16 = Energy tracker 4 [0.01kWh], 0xFFFF = Not Available :
 * un16 = Peak power tracker 1 [1W], 0xFFFF = Not Available : un16 = Peak power
 * tracker 2 [1W], 0xFFFF = Not Available : un16 = Peak power tracker 3 [1W],
 * 0xFFFF = Not Available : un16 = Peak power tracker 4 [1W], 0xFFFF = Not
 * Available : un16 = Voc max tracker 1 [0.01V], 0xFFFF = Not Available : un16 =
 * Voc max tracker 2 [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 3
 * [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 4 [0.01V], 0xFFFF =
 * Not Available :  [0.01V]}
 */
#define VE_REG_HISTORY_MPPT_DAY13 0x10AD

/**
 * History MPPT Day -14 {un8 = Version : un16 = Day sequence number : un16 =
 * Energy tracker 1 [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 2
 * [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 3 [0.01kWh], 0xFFFF
 * = Not Available : un16 = Energy tracker 4 [0.01kWh], 0xFFFF = Not Available :
 * un16 = Peak power tracker 1 [1W], 0xFFFF = Not Available : un16 = Peak power
 * tracker 2 [1W], 0xFFFF = Not Available : un16 = Peak power tracker 3 [1W],
 * 0xFFFF = Not Available : un16 = Peak power tracker 4 [1W], 0xFFFF = Not
 * Available : un16 = Voc max tracker 1 [0.01V], 0xFFFF = Not Available : un16 =
 * Voc max tracker 2 [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 3
 * [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 4 [0.01V], 0xFFFF =
 * Not Available :  [0.01V]}
 */
#define VE_REG_HISTORY_MPPT_DAY14 0x10AE

/**
 * History MPPT Day -15 {un8 = Version : un16 = Day sequence number : un16 =
 * Energy tracker 1 [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 2
 * [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 3 [0.01kWh], 0xFFFF
 * = Not Available : un16 = Energy tracker 4 [0.01kWh], 0xFFFF = Not Available :
 * un16 = Peak power tracker 1 [1W], 0xFFFF = Not Available : un16 = Peak power
 * tracker 2 [1W], 0xFFFF = Not Available : un16 = Peak power tracker 3 [1W],
 * 0xFFFF = Not Available : un16 = Peak power tracker 4 [1W], 0xFFFF = Not
 * Available : un16 = Voc max tracker 1 [0.01V], 0xFFFF = Not Available : un16 =
 * Voc max tracker 2 [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 3
 * [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 4 [0.01V], 0xFFFF =
 * Not Available :  [0.01V]}
 */
#define VE_REG_HISTORY_MPPT_DAY15 0x10AF

/**
 * History MPPT Day -16 {un8 = Version : un16 = Day sequence number : un16 =
 * Energy tracker 1 [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 2
 * [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 3 [0.01kWh], 0xFFFF
 * = Not Available : un16 = Energy tracker 4 [0.01kWh], 0xFFFF = Not Available :
 * un16 = Peak power tracker 1 [1W], 0xFFFF = Not Available : un16 = Peak power
 * tracker 2 [1W], 0xFFFF = Not Available : un16 = Peak power tracker 3 [1W],
 * 0xFFFF = Not Available : un16 = Peak power tracker 4 [1W], 0xFFFF = Not
 * Available : un16 = Voc max tracker 1 [0.01V], 0xFFFF = Not Available : un16 =
 * Voc max tracker 2 [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 3
 * [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 4 [0.01V], 0xFFFF =
 * Not Available :  [0.01V]}
 */
#define VE_REG_HISTORY_MPPT_DAY16 0x10B0

/**
 * History MPPT Day -17 {un8 = Version : un16 = Day sequence number : un16 =
 * Energy tracker 1 [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 2
 * [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 3 [0.01kWh], 0xFFFF
 * = Not Available : un16 = Energy tracker 4 [0.01kWh], 0xFFFF = Not Available :
 * un16 = Peak power tracker 1 [1W], 0xFFFF = Not Available : un16 = Peak power
 * tracker 2 [1W], 0xFFFF = Not Available : un16 = Peak power tracker 3 [1W],
 * 0xFFFF = Not Available : un16 = Peak power tracker 4 [1W], 0xFFFF = Not
 * Available : un16 = Voc max tracker 1 [0.01V], 0xFFFF = Not Available : un16 =
 * Voc max tracker 2 [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 3
 * [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 4 [0.01V], 0xFFFF =
 * Not Available :  [0.01V]}
 */
#define VE_REG_HISTORY_MPPT_DAY17 0x10B1

/**
 * History MPPT Day -18 {un8 = Version : un16 = Day sequence number : un16 =
 * Energy tracker 1 [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 2
 * [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 3 [0.01kWh], 0xFFFF
 * = Not Available : un16 = Energy tracker 4 [0.01kWh], 0xFFFF = Not Available :
 * un16 = Peak power tracker 1 [1W], 0xFFFF = Not Available : un16 = Peak power
 * tracker 2 [1W], 0xFFFF = Not Available : un16 = Peak power tracker 3 [1W],
 * 0xFFFF = Not Available : un16 = Peak power tracker 4 [1W], 0xFFFF = Not
 * Available : un16 = Voc max tracker 1 [0.01V], 0xFFFF = Not Available : un16 =
 * Voc max tracker 2 [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 3
 * [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 4 [0.01V], 0xFFFF =
 * Not Available :  [0.01V]}
 */
#define VE_REG_HISTORY_MPPT_DAY18 0x10B2

/**
 * History MPPT Day -19 {un8 = Version : un16 = Day sequence number : un16 =
 * Energy tracker 1 [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 2
 * [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 3 [0.01kWh], 0xFFFF
 * = Not Available : un16 = Energy tracker 4 [0.01kWh], 0xFFFF = Not Available :
 * un16 = Peak power tracker 1 [1W], 0xFFFF = Not Available : un16 = Peak power
 * tracker 2 [1W], 0xFFFF = Not Available : un16 = Peak power tracker 3 [1W],
 * 0xFFFF = Not Available : un16 = Peak power tracker 4 [1W], 0xFFFF = Not
 * Available : un16 = Voc max tracker 1 [0.01V], 0xFFFF = Not Available : un16 =
 * Voc max tracker 2 [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 3
 * [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 4 [0.01V], 0xFFFF =
 * Not Available :  [0.01V]}
 */
#define VE_REG_HISTORY_MPPT_DAY19 0x10B3

/**
 * History MPPT Day -20 {un8 = Version : un16 = Day sequence number : un16 =
 * Energy tracker 1 [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 2
 * [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 3 [0.01kWh], 0xFFFF
 * = Not Available : un16 = Energy tracker 4 [0.01kWh], 0xFFFF = Not Available :
 * un16 = Peak power tracker 1 [1W], 0xFFFF = Not Available : un16 = Peak power
 * tracker 2 [1W], 0xFFFF = Not Available : un16 = Peak power tracker 3 [1W],
 * 0xFFFF = Not Available : un16 = Peak power tracker 4 [1W], 0xFFFF = Not
 * Available : un16 = Voc max tracker 1 [0.01V], 0xFFFF = Not Available : un16 =
 * Voc max tracker 2 [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 3
 * [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 4 [0.01V], 0xFFFF =
 * Not Available :  [0.01V]}
 */
#define VE_REG_HISTORY_MPPT_DAY20 0x10B4

/**
 * History MPPT Day -21 {un8 = Version : un16 = Day sequence number : un16 =
 * Energy tracker 1 [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 2
 * [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 3 [0.01kWh], 0xFFFF
 * = Not Available : un16 = Energy tracker 4 [0.01kWh], 0xFFFF = Not Available :
 * un16 = Peak power tracker 1 [1W], 0xFFFF = Not Available : un16 = Peak power
 * tracker 2 [1W], 0xFFFF = Not Available : un16 = Peak power tracker 3 [1W],
 * 0xFFFF = Not Available : un16 = Peak power tracker 4 [1W], 0xFFFF = Not
 * Available : un16 = Voc max tracker 1 [0.01V], 0xFFFF = Not Available : un16 =
 * Voc max tracker 2 [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 3
 * [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 4 [0.01V], 0xFFFF =
 * Not Available :  [0.01V]}
 */
#define VE_REG_HISTORY_MPPT_DAY21 0x10B5

/**
 * History MPPT Day -22 {un8 = Version : un16 = Day sequence number : un16 =
 * Energy tracker 1 [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 2
 * [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 3 [0.01kWh], 0xFFFF
 * = Not Available : un16 = Energy tracker 4 [0.01kWh], 0xFFFF = Not Available :
 * un16 = Peak power tracker 1 [1W], 0xFFFF = Not Available : un16 = Peak power
 * tracker 2 [1W], 0xFFFF = Not Available : un16 = Peak power tracker 3 [1W],
 * 0xFFFF = Not Available : un16 = Peak power tracker 4 [1W], 0xFFFF = Not
 * Available : un16 = Voc max tracker 1 [0.01V], 0xFFFF = Not Available : un16 =
 * Voc max tracker 2 [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 3
 * [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 4 [0.01V], 0xFFFF =
 * Not Available :  [0.01V]}
 */
#define VE_REG_HISTORY_MPPT_DAY22 0x10B6

/**
 * History MPPT Day -23 {un8 = Version : un16 = Day sequence number : un16 =
 * Energy tracker 1 [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 2
 * [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 3 [0.01kWh], 0xFFFF
 * = Not Available : un16 = Energy tracker 4 [0.01kWh], 0xFFFF = Not Available :
 * un16 = Peak power tracker 1 [1W], 0xFFFF = Not Available : un16 = Peak power
 * tracker 2 [1W], 0xFFFF = Not Available : un16 = Peak power tracker 3 [1W],
 * 0xFFFF = Not Available : un16 = Peak power tracker 4 [1W], 0xFFFF = Not
 * Available : un16 = Voc max tracker 1 [0.01V], 0xFFFF = Not Available : un16 =
 * Voc max tracker 2 [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 3
 * [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 4 [0.01V], 0xFFFF =
 * Not Available :  [0.01V]}
 */
#define VE_REG_HISTORY_MPPT_DAY23 0x10B7

/**
 * History MPPT Day -24 {un8 = Version : un16 = Day sequence number : un16 =
 * Energy tracker 1 [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 2
 * [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 3 [0.01kWh], 0xFFFF
 * = Not Available : un16 = Energy tracker 4 [0.01kWh], 0xFFFF = Not Available :
 * un16 = Peak power tracker 1 [1W], 0xFFFF = Not Available : un16 = Peak power
 * tracker 2 [1W], 0xFFFF = Not Available : un16 = Peak power tracker 3 [1W],
 * 0xFFFF = Not Available : un16 = Peak power tracker 4 [1W], 0xFFFF = Not
 * Available : un16 = Voc max tracker 1 [0.01V], 0xFFFF = Not Available : un16 =
 * Voc max tracker 2 [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 3
 * [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 4 [0.01V], 0xFFFF =
 * Not Available :  [0.01V]}
 */
#define VE_REG_HISTORY_MPPT_DAY24 0x10B8

/**
 * History MPPT Day -25 {un8 = Version : un16 = Day sequence number : un16 =
 * Energy tracker 1 [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 2
 * [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 3 [0.01kWh], 0xFFFF
 * = Not Available : un16 = Energy tracker 4 [0.01kWh], 0xFFFF = Not Available :
 * un16 = Peak power tracker 1 [1W], 0xFFFF = Not Available : un16 = Peak power
 * tracker 2 [1W], 0xFFFF = Not Available : un16 = Peak power tracker 3 [1W],
 * 0xFFFF = Not Available : un16 = Peak power tracker 4 [1W], 0xFFFF = Not
 * Available : un16 = Voc max tracker 1 [0.01V], 0xFFFF = Not Available : un16 =
 * Voc max tracker 2 [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 3
 * [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 4 [0.01V], 0xFFFF =
 * Not Available :  [0.01V]}
 */
#define VE_REG_HISTORY_MPPT_DAY25 0x10B9

/**
 * History MPPT Day -26 {un8 = Version : un16 = Day sequence number : un16 =
 * Energy tracker 1 [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 2
 * [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 3 [0.01kWh], 0xFFFF
 * = Not Available : un16 = Energy tracker 4 [0.01kWh], 0xFFFF = Not Available :
 * un16 = Peak power tracker 1 [1W], 0xFFFF = Not Available : un16 = Peak power
 * tracker 2 [1W], 0xFFFF = Not Available : un16 = Peak power tracker 3 [1W],
 * 0xFFFF = Not Available : un16 = Peak power tracker 4 [1W], 0xFFFF = Not
 * Available : un16 = Voc max tracker 1 [0.01V], 0xFFFF = Not Available : un16 =
 * Voc max tracker 2 [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 3
 * [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 4 [0.01V], 0xFFFF =
 * Not Available :  [0.01V]}
 */
#define VE_REG_HISTORY_MPPT_DAY26 0x10BA

/**
 * History MPPT Day -27 {un8 = Version : un16 = Day sequence number : un16 =
 * Energy tracker 1 [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 2
 * [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 3 [0.01kWh], 0xFFFF
 * = Not Available : un16 = Energy tracker 4 [0.01kWh], 0xFFFF = Not Available :
 * un16 = Peak power tracker 1 [1W], 0xFFFF = Not Available : un16 = Peak power
 * tracker 2 [1W], 0xFFFF = Not Available : un16 = Peak power tracker 3 [1W],
 * 0xFFFF = Not Available : un16 = Peak power tracker 4 [1W], 0xFFFF = Not
 * Available : un16 = Voc max tracker 1 [0.01V], 0xFFFF = Not Available : un16 =
 * Voc max tracker 2 [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 3
 * [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 4 [0.01V], 0xFFFF =
 * Not Available :  [0.01V]}
 */
#define VE_REG_HISTORY_MPPT_DAY27 0x10BB

/**
 * History MPPT Day -28 {un8 = Version : un16 = Day sequence number : un16 =
 * Energy tracker 1 [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 2
 * [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 3 [0.01kWh], 0xFFFF
 * = Not Available : un16 = Energy tracker 4 [0.01kWh], 0xFFFF = Not Available :
 * un16 = Peak power tracker 1 [1W], 0xFFFF = Not Available : un16 = Peak power
 * tracker 2 [1W], 0xFFFF = Not Available : un16 = Peak power tracker 3 [1W],
 * 0xFFFF = Not Available : un16 = Peak power tracker 4 [1W], 0xFFFF = Not
 * Available : un16 = Voc max tracker 1 [0.01V], 0xFFFF = Not Available : un16 =
 * Voc max tracker 2 [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 3
 * [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 4 [0.01V], 0xFFFF =
 * Not Available :  [0.01V]}
 */
#define VE_REG_HISTORY_MPPT_DAY28 0x10BC

/**
 * History MPPT Day -29 {un8 = Version : un16 = Day sequence number : un16 =
 * Energy tracker 1 [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 2
 * [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 3 [0.01kWh], 0xFFFF
 * = Not Available : un16 = Energy tracker 4 [0.01kWh], 0xFFFF = Not Available :
 * un16 = Peak power tracker 1 [1W], 0xFFFF = Not Available : un16 = Peak power
 * tracker 2 [1W], 0xFFFF = Not Available : un16 = Peak power tracker 3 [1W],
 * 0xFFFF = Not Available : un16 = Peak power tracker 4 [1W], 0xFFFF = Not
 * Available : un16 = Voc max tracker 1 [0.01V], 0xFFFF = Not Available : un16 =
 * Voc max tracker 2 [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 3
 * [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 4 [0.01V], 0xFFFF =
 * Not Available :  [0.01V]}
 */
#define VE_REG_HISTORY_MPPT_DAY29 0x10BD

/**
 * History MPPT Day -1 {un8 = Version : un16 = Day sequence number : un16 =
 * Energy tracker 1 [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 2
 * [0.01kWh], 0xFFFF = Not Available : un16 = Energy tracker 3 [0.01kWh], 0xFFFF
 * = Not Available : un16 = Energy tracker 4 [0.01kWh], 0xFFFF = Not Available :
 * un16 = Peak power tracker 1 [1W], 0xFFFF = Not Available : un16 = Peak power
 * tracker 2 [1W], 0xFFFF = Not Available : un16 = Peak power tracker 3 [1W],
 * 0xFFFF = Not Available : un16 = Peak power tracker 4 [1W], 0xFFFF = Not
 * Available : un16 = Voc max tracker 1 [0.01V], 0xFFFF = Not Available : un16 =
 * Voc max tracker 2 [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 3
 * [0.01V], 0xFFFF = Not Available : un16 = Voc max tracker 4 [0.01V], 0xFFFF =
 * Not Available :  [0.01V]}
 */
#define VE_REG_HISTORY_MPPT_DAY30 0x10BE

/** Distributor E fuse 1 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_E_FUSE1_NAME 0x2130

/** Distributor E fuse 2 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_E_FUSE2_NAME 0x2131

/** Distributor E fuse 3 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_E_FUSE3_NAME 0x2132

/** Distributor E fuse 4 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_E_FUSE4_NAME 0x2133

/** Distributor F fuse 1 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_F_FUSE1_NAME 0x2134

/** Distributor F fuse 2 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_F_FUSE2_NAME 0x2135

/** Distributor F fuse 3 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_F_FUSE3_NAME 0x2136

/** Distributor F fuse 4 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_F_FUSE4_NAME 0x2137

/** Distributor G fuse 1 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_G_FUSE1_NAME 0x2138

/** Distributor G fuse 2 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_G_FUSE2_NAME 0x2139

/** Distributor G fuse 3 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_G_FUSE3_NAME 0x213A

/** Distributor G fuse 4 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_G_FUSE4_NAME 0x213B

/** Distributor H fuse 1 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_H_FUSE1_NAME 0x213C

/** Distributor H fuse 2 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_H_FUSE2_NAME 0x213D

/** Distributor H fuse 3 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_H_FUSE3_NAME 0x213E

/** Distributor H fuse 4 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_H_FUSE4_NAME 0x213F

/** Distributor E fuse 5 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_E_FUSE5_NAME 0x2140

/** Distributor E fuse 6 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_E_FUSE6_NAME 0x2141

/** Distributor E fuse 7 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_E_FUSE7_NAME 0x2142

/** Distributor E fuse 8 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_E_FUSE8_NAME 0x2143

/** Distributor F fuse 5 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_F_FUSE5_NAME 0x2144

/** Distributor F fuse 6 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_F_FUSE6_NAME 0x2145

/** Distributor F fuse 7 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_F_FUSE7_NAME 0x2146

/** Distributor F fuse 8 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_F_FUSE8_NAME 0x2147

/** Distributor G fuse 5 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_G_FUSE5_NAME 0x2148

/** Distributor G fuse 6 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_G_FUSE6_NAME 0x2149

/** Distributor G fuse 7 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_G_FUSE7_NAME 0x214A

/** Distributor G fuse 8 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_G_FUSE8_NAME 0x214B

/** Distributor H fuse 5 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_H_FUSE5_NAME 0x214C

/** Distributor H fuse 6 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_H_FUSE6_NAME 0x214D

/** Distributor H fuse 7 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_H_FUSE7_NAME 0x214E

/** Distributor H fuse 8 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_H_FUSE8_NAME 0x214F

/** Distributor A fuse 1 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_A_FUSE1_NAME 0x2160

/** Distributor A fuse 2 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_A_FUSE2_NAME 0x2161

/** Distributor A fuse 3 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_A_FUSE3_NAME 0x2162

/** Distributor A fuse 4 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_A_FUSE4_NAME 0x2163

/** Distributor B fuse 1 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_B_FUSE1_NAME 0x2164

/** Distributor B fuse 2 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_B_FUSE2_NAME 0x2165

/** Distributor B fuse 3 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_B_FUSE3_NAME 0x2166

/** Distributor B fuse 4 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_B_FUSE4_NAME 0x2167

/** Distributor C fuse 1 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_C_FUSE1_NAME 0x2168

/** Distributor C fuse 2 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_C_FUSE2_NAME 0x2169

/** Distributor C fuse 3 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_C_FUSE3_NAME 0x216A

/** Distributor C fuse 4 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_C_FUSE4_NAME 0x216B

/** Distributor D fuse 1 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_D_FUSE1_NAME 0x216C

/** Distributor D fuse 2 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_D_FUSE2_NAME 0x216D

/** Distributor D fuse 3 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_D_FUSE3_NAME 0x216E

/** Distributor D fuse 4 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_D_FUSE4_NAME 0x216F

/** Distributor A fuse 5 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_A_FUSE5_NAME 0x2170

/** Distributor A fuse 6 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_A_FUSE6_NAME 0x2171

/** Distributor A fuse 7 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_A_FUSE7_NAME 0x2172

/** Distributor A fuse 8 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_A_FUSE8_NAME 0x2173

/** Distributor B fuse 5 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_B_FUSE5_NAME 0x2174

/** Distributor B fuse 6 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_B_FUSE6_NAME 0x2175

/** Distributor B fuse 7 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_B_FUSE7_NAME 0x2176

/** Distributor B fuse 8 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_B_FUSE8_NAME 0x2177

/** Distributor C fuse 5 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_C_FUSE5_NAME 0x2178

/** Distributor C fuse 6 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_C_FUSE6_NAME 0x2179

/** Distributor C fuse 7 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_C_FUSE7_NAME 0x217A

/** Distributor C fuse 8 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_C_FUSE8_NAME 0x217B

/** Distributor D fuse 5 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_D_FUSE5_NAME 0x217C

/** Distributor D fuse 6 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_D_FUSE6_NAME 0x217D

/** Distributor D fuse 7 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_D_FUSE7_NAME 0x217E

/** Distributor D fuse 8 name {stringZeroEnded[16] = fuse name} */
#define VE_REG_DISTRIBUTOR_D_FUSE8_NAME 0x217F

/**
 * MQTT device VRM ID {stringFixed[12] = id}
 * This is used by the VeInterfaces mqtt stack inside VictronConnect to publish
 * the VRM identifier of a found device to the vreg-translator/gui layer.
 */
#define VE_REG_MQTT_VRM_ID 0xEC0E

/**
 * Pin code for BLE devices Codes are decimal characters. {stringFixed[6] = old
 * code : stringFixed[6] = new code}
 */
#define VE_REG_PINCODE 0xEC10

/**
 * PUK code for BLE devices {stringZeroEnded[32] = puk code}
 * @remark Codes are decimal characters.
 */
#define VE_REG_PUKCODE 0xEC11

/**
 * BLE networking key {stringFixed[16] = key}
 * The network encryption key of the BLE network the node is configured to
 * participate in.
 */
#define VE_REG_BLE_NETWORK_KEY 0xEC13

/**
 * BLE networking name {stringZeroEnded[32] = name}
 * The descriptive name of the BLE network the node is configured to participate
 * in. The name is not used by the nodes, but stored as reference to the user.
 */
#define VE_REG_BLE_NETWORK_NAME 0xEC14

/**
 * BLE networking transmitting list {un16 = Transmitted VE_REG_1, 0xFFFF = Not
 * Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest Prio, 0xFF =
 * Not Available : un16 = Transmitted VE_REG_2, 0xFFFF = Not Available : un8 =
 * Priority, 0x00 = Lowest Prio, 0x0F = Highest Prio, 0xFF = Not Available : un16
 * = Transmitted VE_REG_3, 0xFFFF = Not Available : un8 = Priority, 0x00 = Lowest
 * Prio, 0x0F = Highest Prio, 0xFF = Not Available : un16 = Transmitted VE_REG_4,
 * 0xFFFF = Not Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest
 * Prio, 0xFF = Not Available : un16 = Transmitted VE_REG_5, 0xFFFF = Not
 * Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest Prio, 0xFF =
 * Not Available : un16 = Transmitted VE_REG_6, 0xFFFF = Not Available : un8 =
 * Priority, 0x00 = Lowest Prio, 0x0F = Highest Prio, 0xFF = Not Available : un16
 * = Transmitted VE_REG_7, 0xFFFF = Not Available : un8 = Priority, 0x00 = Lowest
 * Prio, 0x0F = Highest Prio, 0xFF = Not Available : un16 = Transmitted VE_REG_8,
 * 0xFFFF = Not Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest
 * Prio, 0xFF = Not Available : un16 = Transmitted VE_REG_9, 0xFFFF = Not
 * Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest Prio, 0xFF =
 * Not Available : un16 = Transmitted VE_REG_10, 0xFFFF = Not Available : un8 =
 * Priority, 0x00 = Lowest Prio, 0x0F = Highest Prio, 0xFF = Not Available}
 * @remark The list of VE_REG's this node is broadcasting in the BLE network it
 * is configured to participate in.
 * When the VE_REG value is set to 0xFFFF it marks the end of the list (no more
 * to follow).
 */
#define VE_REG_BLE_NETWORK_TRANSMIT_LIST_1 0xEC17

/**
 * BLE networking transmitting list {un16 = Transmitted VE_REG_1, 0xFFFF = Not
 * Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest Prio, 0xFF =
 * Not Available : un16 = Transmitted VE_REG_2, 0xFFFF = Not Available : un8 =
 * Priority, 0x00 = Lowest Prio, 0x0F = Highest Prio, 0xFF = Not Available : un16
 * = Transmitted VE_REG_3, 0xFFFF = Not Available : un8 = Priority, 0x00 = Lowest
 * Prio, 0x0F = Highest Prio, 0xFF = Not Available : un16 = Transmitted VE_REG_4,
 * 0xFFFF = Not Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest
 * Prio, 0xFF = Not Available : un16 = Transmitted VE_REG_5, 0xFFFF = Not
 * Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest Prio, 0xFF =
 * Not Available : un16 = Transmitted VE_REG_6, 0xFFFF = Not Available : un8 =
 * Priority, 0x00 = Lowest Prio, 0x0F = Highest Prio, 0xFF = Not Available : un16
 * = Transmitted VE_REG_7, 0xFFFF = Not Available : un8 = Priority, 0x00 = Lowest
 * Prio, 0x0F = Highest Prio, 0xFF = Not Available : un16 = Transmitted VE_REG_8,
 * 0xFFFF = Not Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest
 * Prio, 0xFF = Not Available : un16 = Transmitted VE_REG_9, 0xFFFF = Not
 * Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest Prio, 0xFF =
 * Not Available : un16 = Transmitted VE_REG_10, 0xFFFF = Not Available : un8 =
 * Priority, 0x00 = Lowest Prio, 0x0F = Highest Prio, 0xFF = Not Available}
 * @remark Continuation of the list of VE_REG's this node is broadcasting in the
 * BLE network it is configured to participate in.
 * When the VE_REG value is set to 0xFFFF it marks the end of the list (no more
 * to follow).
 */
#define VE_REG_BLE_NETWORK_TRANSMIT_LIST_2 0xEC18

/**
 * BLE networking transmitting list {un16 = Transmitted VE_REG_1, 0xFFFF = Not
 * Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest Prio, 0xFF =
 * Not Available : un16 = Transmitted VE_REG_2, 0xFFFF = Not Available : un8 =
 * Priority, 0x00 = Lowest Prio, 0x0F = Highest Prio, 0xFF = Not Available : un16
 * = Transmitted VE_REG_3, 0xFFFF = Not Available : un8 = Priority, 0x00 = Lowest
 * Prio, 0x0F = Highest Prio, 0xFF = Not Available : un16 = Transmitted VE_REG_4,
 * 0xFFFF = Not Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest
 * Prio, 0xFF = Not Available : un16 = Transmitted VE_REG_5, 0xFFFF = Not
 * Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest Prio, 0xFF =
 * Not Available : un16 = Transmitted VE_REG_6, 0xFFFF = Not Available : un8 =
 * Priority, 0x00 = Lowest Prio, 0x0F = Highest Prio, 0xFF = Not Available : un16
 * = Transmitted VE_REG_7, 0xFFFF = Not Available : un8 = Priority, 0x00 = Lowest
 * Prio, 0x0F = Highest Prio, 0xFF = Not Available : un16 = Transmitted VE_REG_8,
 * 0xFFFF = Not Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest
 * Prio, 0xFF = Not Available : un16 = Transmitted VE_REG_9, 0xFFFF = Not
 * Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest Prio, 0xFF =
 * Not Available : un16 = Transmitted VE_REG_10, 0xFFFF = Not Available : un8 =
 * Priority, 0x00 = Lowest Prio, 0x0F = Highest Prio, 0xFF = Not Available}
 * @remark Continuation of the list of VE_REG's this node is broadcasting in the
 * BLE network it is configured to participate in.
 * When the VE_REG value is set to 0xFFFF it marks the end of the list (no more
 * to follow).
 */
#define VE_REG_BLE_NETWORK_TRANSMIT_LIST_3 0xEC19

/**
 * BLE networking reception list {un16 = Received VE_REG_1, 0xFFFF = Not
 * Available : un8 = Time [1s], 0xFE = More than 253 sec, 0xFF = Not Available :
 * un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest Prio, 0xFF = Not Available
 * : un32 = Sender, 0xFFFFFFFF = Not Available : un16 = Received VE_REG_2, 0xFFFF
 * = Not Available : un8 = Time [1s], 0xFE = More than 253 sec, 0xFF = Not
 * Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest Prio, 0xFF =
 * Not Available : un32 = Sender, 0xFFFFFFFF = Not Available : un16 = Received
 * VE_REG_3, 0xFFFF = Not Available : un8 = Time [1s], 0xFE = More than 253 sec,
 * 0xFF = Not Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest
 * Prio, 0xFF = Not Available : un32 = Sender, 0xFFFFFFFF = Not Available : un16
 * = Received VE_REG_4, 0xFFFF = Not Available : un8 = Time [1s], 0xFE = More
 * than 253 sec, 0xFF = Not Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F
 * = Highest Prio, 0xFF = Not Available : un32 = Sender, 0xFFFFFFFF = Not
 * Available}
 * @remark The list of unique VE_REG's this node is capable of receiving and has
 * received. Only to the node known VE_REG's will be returned. In case a VE_REG
 * has not been received yet, the Sender, Time and Priority will be set to "Not
 * Available". In case a VE_REG has not been received anymore for an
 * implementation dependent period, the local node may decide to set Sender, Time
 * and Priority to "Not Avavilable". When a VE_REG has been received, only the
 * last sender for that specific VE_REG will be returned.
 * When the VE_REG value is set to 0xFFFF it marks the end of the list at this
 * moment (no more to follow).
 */
#define VE_REG_BLE_NETWORK_RECEIVE_LIST_1 0xEC20

/**
 * BLE networking reception list {un16 = Received VE_REG_1, 0xFFFF = Not
 * Available : un8 = Time [1s], 0xFE = More than 253 sec, 0xFF = Not Available :
 * un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest Prio, 0xFF = Not Available
 * : un32 = Sender, 0xFFFFFFFF = Not Available : un16 = Received VE_REG_2, 0xFFFF
 * = Not Available : un8 = Time [1s], 0xFE = More than 253 sec, 0xFF = Not
 * Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest Prio, 0xFF =
 * Not Available : un32 = Sender, 0xFFFFFFFF = Not Available : un16 = Received
 * VE_REG_3, 0xFFFF = Not Available : un8 = Time [1s], 0xFE = More than 253 sec,
 * 0xFF = Not Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest
 * Prio, 0xFF = Not Available : un32 = Sender, 0xFFFFFFFF = Not Available : un16
 * = Received VE_REG_4, 0xFFFF = Not Available : un8 = Time [1s], 0xFE = More
 * than 253 sec, 0xFF = Not Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F
 * = Highest Prio, 0xFF = Not Available : un32 = Sender, 0xFFFFFFFF = Not
 * Available}
 * @remark Continuation of list of unique VE_REG's this node is capable of
 * receiving and has received. Only to the node known VE_REG's will be returned.
 * In case a VE_REG has not been received yet, the Sender, Time and Priority will
 * be set to "Not Available". In case a VE_REG has not been received anymore for
 * an implementation dependent period, the local node may decide to set Sender,
 * Time and Priority to "Not Avavilable". When a VE_REG has been received, only
 * the last sender for that specific VE_REG will be returned.
 * When the VE_REG value is set to 0xFFFF it marks the end of the list at this
 * moment (no more to follow).
 */
#define VE_REG_BLE_NETWORK_RECEIVE_LIST_2 0xEC21

/**
 * BLE networking reception list {un16 = Received VE_REG_1, 0xFFFF = Not
 * Available : un8 = Time [1s], 0xFE = More than 253 sec, 0xFF = Not Available :
 * un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest Prio, 0xFF = Not Available
 * : un32 = Sender, 0xFFFFFFFF = Not Available : un16 = Received VE_REG_2, 0xFFFF
 * = Not Available : un8 = Time [1s], 0xFE = More than 253 sec, 0xFF = Not
 * Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest Prio, 0xFF =
 * Not Available : un32 = Sender, 0xFFFFFFFF = Not Available : un16 = Received
 * VE_REG_3, 0xFFFF = Not Available : un8 = Time [1s], 0xFE = More than 253 sec,
 * 0xFF = Not Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest
 * Prio, 0xFF = Not Available : un32 = Sender, 0xFFFFFFFF = Not Available : un16
 * = Received VE_REG_4, 0xFFFF = Not Available : un8 = Time [1s], 0xFE = More
 * than 253 sec, 0xFF = Not Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F
 * = Highest Prio, 0xFF = Not Available : un32 = Sender, 0xFFFFFFFF = Not
 * Available}
 * @remark Continuation of list of unique VE_REG's this node is capable of
 * receiving and has received. Only to the node known VE_REG's will be returned.
 * In case a VE_REG has not been received yet, the Sender, Time and Priority will
 * be set to "Not Available". In case a VE_REG has not been received anymore for
 * an implementation dependent period, the local node may decide to set Sender,
 * Time and Priority to "Not Avavilable". When a VE_REG has been received, only
 * the last sender for that specific VE_REG will be returned.
 * When the VE_REG value is set to 0xFFFF it marks the end of the list at this
 * moment (no more to follow).
 */
#define VE_REG_BLE_NETWORK_RECEIVE_LIST_3 0xEC22

/**
 * BLE networking reception list {un16 = Received VE_REG_1, 0xFFFF = Not
 * Available : un8 = Time [1s], 0xFE = More than 253 sec, 0xFF = Not Available :
 * un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest Prio, 0xFF = Not Available
 * : un32 = Sender, 0xFFFFFFFF = Not Available : un16 = Received VE_REG_2, 0xFFFF
 * = Not Available : un8 = Time [1s], 0xFE = More than 253 sec, 0xFF = Not
 * Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest Prio, 0xFF =
 * Not Available : un32 = Sender, 0xFFFFFFFF = Not Available : un16 = Received
 * VE_REG_3, 0xFFFF = Not Available : un8 = Time [1s], 0xFE = More than 253 sec,
 * 0xFF = Not Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest
 * Prio, 0xFF = Not Available : un32 = Sender, 0xFFFFFFFF = Not Available : un16
 * = Received VE_REG_4, 0xFFFF = Not Available : un8 = Time [1s], 0xFE = More
 * than 253 sec, 0xFF = Not Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F
 * = Highest Prio, 0xFF = Not Available : un32 = Sender, 0xFFFFFFFF = Not
 * Available}
 * @remark Continuation of list of unique VE_REG's this node is capable of
 * receiving and has received. Only to the node known VE_REG's will be returned.
 * In case a VE_REG has not been received yet, the Sender, Time and Priority will
 * be set to "Not Available". In case a VE_REG has not been received anymore for
 * an implementation dependent period, the local node may decide to set Sender,
 * Time and Priority to "Not Avavilable". When a VE_REG has been received, only
 * the last sender for that specific VE_REG will be returned.
 * When the VE_REG value is set to 0xFFFF it marks the end of the list at this
 * moment (no more to follow).
 */
#define VE_REG_BLE_NETWORK_RECEIVE_LIST_4 0xEC23

/**
 * BLE networking reception list {un16 = Received VE_REG_1, 0xFFFF = Not
 * Available : un8 = Time [1s], 0xFE = More than 253 sec, 0xFF = Not Available :
 * un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest Prio, 0xFF = Not Available
 * : un32 = Sender, 0xFFFFFFFF = Not Available : un16 = Received VE_REG_2, 0xFFFF
 * = Not Available : un8 = Time [1s], 0xFE = More than 253 sec, 0xFF = Not
 * Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest Prio, 0xFF =
 * Not Available : un32 = Sender, 0xFFFFFFFF = Not Available : un16 = Received
 * VE_REG_3, 0xFFFF = Not Available : un8 = Time [1s], 0xFE = More than 253 sec,
 * 0xFF = Not Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest
 * Prio, 0xFF = Not Available : un32 = Sender, 0xFFFFFFFF = Not Available : un16
 * = Received VE_REG_4, 0xFFFF = Not Available : un8 = Time [1s], 0xFE = More
 * than 253 sec, 0xFF = Not Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F
 * = Highest Prio, 0xFF = Not Available : un32 = Sender, 0xFFFFFFFF = Not
 * Available}
 * @remark Continuation of list of unique VE_REG's this node is capable of
 * receiving and has received. Only to the node known VE_REG's will be returned.
 * In case a VE_REG has not been received yet, the Sender, Time and Priority will
 * be set to "Not Available". In case a VE_REG has not been received anymore for
 * an implementation dependent period, the local node may decide to set Sender,
 * Time and Priority to "Not Avavilable". When a VE_REG has been received, only
 * the last sender for that specific VE_REG will be returned.
 * When the VE_REG value is set to 0xFFFF it marks the end of the list at this
 * moment (no more to follow).
 */
#define VE_REG_BLE_NETWORK_RECEIVE_LIST_5 0xEC24

/**
 * BLE networking reception list {un16 = Received VE_REG_1, 0xFFFF = Not
 * Available : un8 = Time [1s], 0xFE = More than 253 sec, 0xFF = Not Available :
 * un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest Prio, 0xFF = Not Available
 * : un32 = Sender, 0xFFFFFFFF = Not Available : un16 = Received VE_REG_2, 0xFFFF
 * = Not Available : un8 = Time [1s], 0xFE = More than 253 sec, 0xFF = Not
 * Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest Prio, 0xFF =
 * Not Available : un32 = Sender, 0xFFFFFFFF = Not Available : un16 = Received
 * VE_REG_3, 0xFFFF = Not Available : un8 = Time [1s], 0xFE = More than 253 sec,
 * 0xFF = Not Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest
 * Prio, 0xFF = Not Available : un32 = Sender, 0xFFFFFFFF = Not Available : un16
 * = Received VE_REG_4, 0xFFFF = Not Available : un8 = Time [1s], 0xFE = More
 * than 253 sec, 0xFF = Not Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F
 * = Highest Prio, 0xFF = Not Available : un32 = Sender, 0xFFFFFFFF = Not
 * Available}
 * @remark Continuation of list of unique VE_REG's this node is capable of
 * receiving and has received. Only to the node known VE_REG's will be returned.
 * In case a VE_REG has not been received yet, the Sender, Time and Priority will
 * be set to "Not Available". In case a VE_REG has not been received anymore for
 * an implementation dependent period, the local node may decide to set Sender,
 * Time and Priority to "Not Avavilable". When a VE_REG has been received, only
 * the last sender for that specific VE_REG will be returned.
 * When the VE_REG value is set to 0xFFFF it marks the end of the list at this
 * moment (no more to follow).
 */
#define VE_REG_BLE_NETWORK_RECEIVE_LIST_6 0xEC25

/**
 * BLE networking reception list {un16 = Received VE_REG_1, 0xFFFF = Not
 * Available : un8 = Time [1s], 0xFE = More than 253 sec, 0xFF = Not Available :
 * un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest Prio, 0xFF = Not Available
 * : un32 = Sender, 0xFFFFFFFF = Not Available : un16 = Received VE_REG_2, 0xFFFF
 * = Not Available : un8 = Time [1s], 0xFE = More than 253 sec, 0xFF = Not
 * Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest Prio, 0xFF =
 * Not Available : un32 = Sender, 0xFFFFFFFF = Not Available : un16 = Received
 * VE_REG_3, 0xFFFF = Not Available : un8 = Time [1s], 0xFE = More than 253 sec,
 * 0xFF = Not Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest
 * Prio, 0xFF = Not Available : un32 = Sender, 0xFFFFFFFF = Not Available : un16
 * = Received VE_REG_4, 0xFFFF = Not Available : un8 = Time [1s], 0xFE = More
 * than 253 sec, 0xFF = Not Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F
 * = Highest Prio, 0xFF = Not Available : un32 = Sender, 0xFFFFFFFF = Not
 * Available}
 * @remark Continuation of list of unique VE_REG's this node is capable of
 * receiving and has received. Only to the node known VE_REG's will be returned.
 * In case a VE_REG has not been received yet, the Sender, Time and Priority will
 * be set to "Not Available". In case a VE_REG has not been received anymore for
 * an implementation dependent period, the local node may decide to set Sender,
 * Time and Priority to "Not Avavilable". When a VE_REG has been received, only
 * the last sender for that specific VE_REG will be returned.
 * When the VE_REG value is set to 0xFFFF it marks the end of the list at this
 * moment (no more to follow).
 */
#define VE_REG_BLE_NETWORK_RECEIVE_LIST_7 0xEC26

/**
 * BLE networking reception list {un16 = Received VE_REG_1, 0xFFFF = Not
 * Available : un8 = Time [1s], 0xFE = More than 253 sec, 0xFF = Not Available :
 * un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest Prio, 0xFF = Not Available
 * : un32 = Sender, 0xFFFFFFFF = Not Available : un16 = Received VE_REG_2, 0xFFFF
 * = Not Available : un8 = Time [1s], 0xFE = More than 253 sec, 0xFF = Not
 * Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest Prio, 0xFF =
 * Not Available : un32 = Sender, 0xFFFFFFFF = Not Available : un16 = Received
 * VE_REG_3, 0xFFFF = Not Available : un8 = Time [1s], 0xFE = More than 253 sec,
 * 0xFF = Not Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest
 * Prio, 0xFF = Not Available : un32 = Sender, 0xFFFFFFFF = Not Available : un16
 * = Received VE_REG_4, 0xFFFF = Not Available : un8 = Time [1s], 0xFE = More
 * than 253 sec, 0xFF = Not Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F
 * = Highest Prio, 0xFF = Not Available : un32 = Sender, 0xFFFFFFFF = Not
 * Available}
 * @remark Continuation of list of unique VE_REG's this node is capable of
 * receiving and has received. Only to the node known VE_REG's will be returned.
 * In case a VE_REG has not been received yet, the Sender, Time and Priority will
 * be set to "Not Available". In case a VE_REG has not been received anymore for
 * an implementation dependent period, the local node may decide to set Sender,
 * Time and Priority to "Not Avavilable". When a VE_REG has been received, only
 * the last sender for that specific VE_REG will be returned.
 * When the VE_REG value is set to 0xFFFF it marks the end of the list at this
 * moment (no more to follow).
 */
#define VE_REG_BLE_NETWORK_RECEIVE_LIST_8 0xEC27

/**
 * BLE networking reception list {un16 = Received VE_REG_1, 0xFFFF = Not
 * Available : un8 = Time [1s], 0xFE = More than 253 sec, 0xFF = Not Available :
 * un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest Prio, 0xFF = Not Available
 * : un32 = Sender, 0xFFFFFFFF = Not Available : un16 = Received VE_REG_2, 0xFFFF
 * = Not Available : un8 = Time [1s], 0xFE = More than 253 sec, 0xFF = Not
 * Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest Prio, 0xFF =
 * Not Available : un32 = Sender, 0xFFFFFFFF = Not Available : un16 = Received
 * VE_REG_3, 0xFFFF = Not Available : un8 = Time [1s], 0xFE = More than 253 sec,
 * 0xFF = Not Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest
 * Prio, 0xFF = Not Available : un32 = Sender, 0xFFFFFFFF = Not Available : un16
 * = Received VE_REG_4, 0xFFFF = Not Available : un8 = Time [1s], 0xFE = More
 * than 253 sec, 0xFF = Not Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F
 * = Highest Prio, 0xFF = Not Available : un32 = Sender, 0xFFFFFFFF = Not
 * Available}
 * @remark Continuation of list of unique VE_REG's this node is capable of
 * receiving and has received. Only to the node known VE_REG's will be returned.
 * In case a VE_REG has not been received yet, the Sender, Time and Priority will
 * be set to "Not Available". In case a VE_REG has not been received anymore for
 * an implementation dependent period, the local node may decide to set Sender,
 * Time and Priority to "Not Avavilable". When a VE_REG has been received, only
 * the last sender for that specific VE_REG will be returned.
 * When the VE_REG value is set to 0xFFFF it marks the end of the list at this
 * moment (no more to follow).
 */
#define VE_REG_BLE_NETWORK_RECEIVE_LIST_9 0xEC28

/**
 * BLE networking reception list {un16 = Received VE_REG_1, 0xFFFF = Not
 * Available : un8 = Time [1s], 0xFE = More than 253 sec, 0xFF = Not Available :
 * un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest Prio, 0xFF = Not Available
 * : un32 = Sender, 0xFFFFFFFF = Not Available : un16 = Received VE_REG_2, 0xFFFF
 * = Not Available : un8 = Time [1s], 0xFE = More than 253 sec, 0xFF = Not
 * Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest Prio, 0xFF =
 * Not Available : un32 = Sender, 0xFFFFFFFF = Not Available : un16 = Received
 * VE_REG_3, 0xFFFF = Not Available : un8 = Time [1s], 0xFE = More than 253 sec,
 * 0xFF = Not Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest
 * Prio, 0xFF = Not Available : un32 = Sender, 0xFFFFFFFF = Not Available : un16
 * = Received VE_REG_4, 0xFFFF = Not Available : un8 = Time [1s], 0xFE = More
 * than 253 sec, 0xFF = Not Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F
 * = Highest Prio, 0xFF = Not Available : un32 = Sender, 0xFFFFFFFF = Not
 * Available}
 * @remark Continuation of list of unique VE_REG's this node is capable of
 * receiving and has received. Only to the node known VE_REG's will be returned.
 * In case a VE_REG has not been received yet, the Sender, Time and Priority will
 * be set to "Not Available". In case a VE_REG has not been received anymore for
 * an implementation dependent period, the local node may decide to set Sender,
 * Time and Priority to "Not Avavilable". When a VE_REG has been received, only
 * the last sender for that specific VE_REG will be returned.
 * When the VE_REG value is set to 0xFFFF it marks the end of the list at this
 * moment (no more to follow).
 */
#define VE_REG_BLE_NETWORK_RECEIVE_LIST_10 0xEC29

/**
 * BLE networking reception list {un16 = Received VE_REG_1, 0xFFFF = Not
 * Available : un8 = Time [1s], 0xFE = More than 253 sec, 0xFF = Not Available :
 * un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest Prio, 0xFF = Not Available
 * : un32 = Sender, 0xFFFFFFFF = Not Available : un16 = Received VE_REG_2, 0xFFFF
 * = Not Available : un8 = Time [1s], 0xFE = More than 253 sec, 0xFF = Not
 * Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest Prio, 0xFF =
 * Not Available : un32 = Sender, 0xFFFFFFFF = Not Available : un16 = Received
 * VE_REG_3, 0xFFFF = Not Available : un8 = Time [1s], 0xFE = More than 253 sec,
 * 0xFF = Not Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest
 * Prio, 0xFF = Not Available : un32 = Sender, 0xFFFFFFFF = Not Available : un16
 * = Received VE_REG_4, 0xFFFF = Not Available : un8 = Time [1s], 0xFE = More
 * than 253 sec, 0xFF = Not Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F
 * = Highest Prio, 0xFF = Not Available : un32 = Sender, 0xFFFFFFFF = Not
 * Available}
 * @remark Continuation of list of unique VE_REG's this node is capable of
 * receiving and has received. Only to the node known VE_REG's will be returned.
 * In case a VE_REG has not been received yet, the Sender, Time and Priority will
 * be set to "Not Available". In case a VE_REG has not been received anymore for
 * an implementation dependent period, the local node may decide to set Sender,
 * Time and Priority to "Not Avavilable". When a VE_REG has been received, only
 * the last sender for that specific VE_REG will be returned.
 * When the VE_REG value is set to 0xFFFF it marks the end of the list at this
 * moment (no more to follow).
 */
#define VE_REG_BLE_NETWORK_RECEIVE_LIST_11 0xEC2A

/**
 * BLE networking reception list {un16 = Received VE_REG_1, 0xFFFF = Not
 * Available : un8 = Time [1s], 0xFE = More than 253 sec, 0xFF = Not Available :
 * un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest Prio, 0xFF = Not Available
 * : un32 = Sender, 0xFFFFFFFF = Not Available : un16 = Received VE_REG_2, 0xFFFF
 * = Not Available : un8 = Time [1s], 0xFE = More than 253 sec, 0xFF = Not
 * Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest Prio, 0xFF =
 * Not Available : un32 = Sender, 0xFFFFFFFF = Not Available : un16 = Received
 * VE_REG_3, 0xFFFF = Not Available : un8 = Time [1s], 0xFE = More than 253 sec,
 * 0xFF = Not Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest
 * Prio, 0xFF = Not Available : un32 = Sender, 0xFFFFFFFF = Not Available : un16
 * = Received VE_REG_4, 0xFFFF = Not Available : un8 = Time [1s], 0xFE = More
 * than 253 sec, 0xFF = Not Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F
 * = Highest Prio, 0xFF = Not Available : un32 = Sender, 0xFFFFFFFF = Not
 * Available}
 * @remark Continuation of list of unique VE_REG's this node is capable of
 * receiving and has received. Only to the node known VE_REG's will be returned.
 * In case a VE_REG has not been received yet, the Sender, Time and Priority will
 * be set to "Not Available". In case a VE_REG has not been received anymore for
 * an implementation dependent period, the local node may decide to set Sender,
 * Time and Priority to "Not Avavilable". When a VE_REG has been received, only
 * the last sender for that specific VE_REG will be returned.
 * When the VE_REG value is set to 0xFFFF it marks the end of the list at this
 * moment (no more to follow).
 */
#define VE_REG_BLE_NETWORK_RECEIVE_LIST_12 0xEC2B

/**
 * BLE networking reception list {un16 = Received VE_REG_1, 0xFFFF = Not
 * Available : un8 = Time [1s], 0xFE = More than 253 sec, 0xFF = Not Available :
 * un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest Prio, 0xFF = Not Available
 * : un32 = Sender, 0xFFFFFFFF = Not Available : un16 = Received VE_REG_2, 0xFFFF
 * = Not Available : un8 = Time [1s], 0xFE = More than 253 sec, 0xFF = Not
 * Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest Prio, 0xFF =
 * Not Available : un32 = Sender, 0xFFFFFFFF = Not Available : un16 = Received
 * VE_REG_3, 0xFFFF = Not Available : un8 = Time [1s], 0xFE = More than 253 sec,
 * 0xFF = Not Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest
 * Prio, 0xFF = Not Available : un32 = Sender, 0xFFFFFFFF = Not Available : un16
 * = Received VE_REG_4, 0xFFFF = Not Available : un8 = Time [1s], 0xFE = More
 * than 253 sec, 0xFF = Not Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F
 * = Highest Prio, 0xFF = Not Available : un32 = Sender, 0xFFFFFFFF = Not
 * Available}
 * @remark Continuation of list of unique VE_REG's this node is capable of
 * receiving and has received. Only to the node known VE_REG's will be returned.
 * In case a VE_REG has not been received yet, the Sender, Time and Priority will
 * be set to "Not Available". In case a VE_REG has not been received anymore for
 * an implementation dependent period, the local node may decide to set Sender,
 * Time and Priority to "Not Avavilable". When a VE_REG has been received, only
 * the last sender for that specific VE_REG will be returned.
 * When the VE_REG value is set to 0xFFFF it marks the end of the list at this
 * moment (no more to follow).
 */
#define VE_REG_BLE_NETWORK_RECEIVE_LIST_13 0xEC2C

/**
 * BLE networking reception list {un16 = Received VE_REG_1, 0xFFFF = Not
 * Available : un8 = Time [1s], 0xFE = More than 253 sec, 0xFF = Not Available :
 * un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest Prio, 0xFF = Not Available
 * : un32 = Sender, 0xFFFFFFFF = Not Available : un16 = Received VE_REG_2, 0xFFFF
 * = Not Available : un8 = Time [1s], 0xFE = More than 253 sec, 0xFF = Not
 * Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest Prio, 0xFF =
 * Not Available : un32 = Sender, 0xFFFFFFFF = Not Available : un16 = Received
 * VE_REG_3, 0xFFFF = Not Available : un8 = Time [1s], 0xFE = More than 253 sec,
 * 0xFF = Not Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest
 * Prio, 0xFF = Not Available : un32 = Sender, 0xFFFFFFFF = Not Available : un16
 * = Received VE_REG_4, 0xFFFF = Not Available : un8 = Time [1s], 0xFE = More
 * than 253 sec, 0xFF = Not Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F
 * = Highest Prio, 0xFF = Not Available : un32 = Sender, 0xFFFFFFFF = Not
 * Available}
 * @remark Continuation of list of unique VE_REG's this node is capable of
 * receiving and has received. Only to the node known VE_REG's will be returned.
 * In case a VE_REG has not been received yet, the Sender, Time and Priority will
 * be set to "Not Available". In case a VE_REG has not been received anymore for
 * an implementation dependent period, the local node may decide to set Sender,
 * Time and Priority to "Not Avavilable". When a VE_REG has been received, only
 * the last sender for that specific VE_REG will be returned.
 * When the VE_REG value is set to 0xFFFF it marks the end of the list at this
 * moment (no more to follow).
 */
#define VE_REG_BLE_NETWORK_RECEIVE_LIST_14 0xEC2D

/**
 * BLE networking reception list {un16 = Received VE_REG_1, 0xFFFF = Not
 * Available : un8 = Time [1s], 0xFE = More than 253 sec, 0xFF = Not Available :
 * un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest Prio, 0xFF = Not Available
 * : un32 = Sender, 0xFFFFFFFF = Not Available : un16 = Received VE_REG_2, 0xFFFF
 * = Not Available : un8 = Time [1s], 0xFE = More than 253 sec, 0xFF = Not
 * Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest Prio, 0xFF =
 * Not Available : un32 = Sender, 0xFFFFFFFF = Not Available : un16 = Received
 * VE_REG_3, 0xFFFF = Not Available : un8 = Time [1s], 0xFE = More than 253 sec,
 * 0xFF = Not Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest
 * Prio, 0xFF = Not Available : un32 = Sender, 0xFFFFFFFF = Not Available : un16
 * = Received VE_REG_4, 0xFFFF = Not Available : un8 = Time [1s], 0xFE = More
 * than 253 sec, 0xFF = Not Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F
 * = Highest Prio, 0xFF = Not Available : un32 = Sender, 0xFFFFFFFF = Not
 * Available}
 * @remark Continuation of list of unique VE_REG's this node is capable of
 * receiving and has received. Only to the node known VE_REG's will be returned.
 * In case a VE_REG has not been received yet, the Sender, Time and Priority will
 * be set to "Not Available". In case a VE_REG has not been received anymore for
 * an implementation dependent period, the local node may decide to set Sender,
 * Time and Priority to "Not Avavilable". When a VE_REG has been received, only
 * the last sender for that specific VE_REG will be returned.
 * When the VE_REG value is set to 0xFFFF it marks the end of the list at this
 * moment (no more to follow).
 */
#define VE_REG_BLE_NETWORK_RECEIVE_LIST_15 0xEC2E

/**
 * BLE networking reception list {un16 = Received VE_REG_1, 0xFFFF = Not
 * Available : un8 = Time [1s], 0xFE = More than 253 sec, 0xFF = Not Available :
 * un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest Prio, 0xFF = Not Available
 * : un32 = Sender, 0xFFFFFFFF = Not Available : un16 = Received VE_REG_2, 0xFFFF
 * = Not Available : un8 = Time [1s], 0xFE = More than 253 sec, 0xFF = Not
 * Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest Prio, 0xFF =
 * Not Available : un32 = Sender, 0xFFFFFFFF = Not Available : un16 = Received
 * VE_REG_3, 0xFFFF = Not Available : un8 = Time [1s], 0xFE = More than 253 sec,
 * 0xFF = Not Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F = Highest
 * Prio, 0xFF = Not Available : un32 = Sender, 0xFFFFFFFF = Not Available : un16
 * = Received VE_REG_4, 0xFFFF = Not Available : un8 = Time [1s], 0xFE = More
 * than 253 sec, 0xFF = Not Available : un8 = Priority, 0x00 = Lowest Prio, 0x0F
 * = Highest Prio, 0xFF = Not Available : un32 = Sender, 0xFFFFFFFF = Not
 * Available}
 * @remark Continuation of list of unique VE_REG's this node is capable of
 * receiving and has received. Only to the node known VE_REG's will be returned.
 * In case a VE_REG has not been received yet, the Sender, Time and Priority will
 * be set to "Not Available". In case a VE_REG has not been received anymore for
 * an implementation dependent period, the local node may decide to set Sender,
 * Time and Priority to "Not Avavilable". When a VE_REG has been received, only
 * the last sender for that specific VE_REG will be returned.
 * When the VE_REG value is set to 0xFFFF it marks the end of the list at this
 * moment (no more to follow).
 */
#define VE_REG_BLE_NETWORK_RECEIVE_LIST_16 0xEC2F

/**
 * BLE networking devices in range list {un8 = VREG version, 0x01 = Version1
 * (only allowed value) : un32 = Address In Range Device_1, 0xFFFFFFFF = Not
 * Available : un16 = Product ID Device_1, 0xFFFF = Not Available : un8 = Time
 * Device_1 [1s], 0xFE = More than 253 sec, 0xFF = Not Available : un32 =
 * Application Version Device_1, 0xFFFFFFFF = Not Available : sn8 = Rssi
 * Device_1, 0x7F = Not Available : un32 = Reserved Device_1, 0xFFFFFFFF =
 * Reserved Value : un32 = Address In Range Device_2, 0xFFFFFFFF = Not Available
 * : un16 = Product ID Device_2, 0xFFFF = Not Available : un8 = Time Device_2
 * [1s], 0xFE = More than 253 sec, 0xFF = Not Available : un32 = Application
 * Version Device_2, 0xFFFFFFFF = Not Available : sn8 = Rssi Device_2, 0x7F = Not
 * Available : un32 = Reserved Device_2, 0xFFFFFFFF = Reserved Value}
 * @remark Start of the list of devices from which broadcasted VE_REG's are
 * received. The first node in this list shall always be the local node. Nodes
 * for which no VE_REG's are received anymore, may be removed from the list after
 * an implementation dependent period.
 * When the Address value is set to 0xFFFFFFFF it marks the end of the list at
 * this moment (no more to follow).
 */
#define VE_REG_BLE_NETWORK_IN_RANGE_DEVICES_LIST_1 0xEC31

/**
 * BLE networking devices in range list {un8 = VREG version, 0x01 = Version1
 * (only allowed value) : un32 = Address In Range Device_1, 0xFFFFFFFF = Not
 * Available : un16 = Product ID Device_1, 0xFFFF = Not Available : un8 = Time
 * Device_1 [1s], 0xFE = More than 253 sec, 0xFF = Not Available : un32 =
 * Application Version Device_1, 0xFFFFFFFF = Not Available : sn8 = Rssi
 * Device_1, 0x7F = Not Available : un32 = Reserved Device_1, 0xFFFFFFFF =
 * Reserved Value : un32 = Address In Range Device_2, 0xFFFFFFFF = Not Available
 * : un16 = Product ID Device_2, 0xFFFF = Not Available : un8 = Time Device_2
 * [1s], 0xFE = More than 253 sec, 0xFF = Not Available : un32 = Application
 * Version Device_2, 0xFFFFFFFF = Not Available : sn8 = Rssi Device_2, 0x7F = Not
 * Available : un32 = Reserved Device_2, 0xFFFFFFFF = Reserved Value}
 * @remark Continuation of the list of devices from which broadcasted VE_REG's
 * are received. Nodes for which no VE_REG's are received anymore, may be removed
 * from the list after an implementation dependent period.
 * When the Address value is set to 0xFFFFFFFF it marks the end of the list at
 * this moment (no more to follow).
 */
#define VE_REG_BLE_NETWORK_IN_RANGE_DEVICES_LIST_2 0xEC32

/**
 * BLE networking devices in range list {un8 = VREG version, 0x01 = Version1
 * (only allowed value) : un32 = Address In Range Device_1, 0xFFFFFFFF = Not
 * Available : un16 = Product ID Device_1, 0xFFFF = Not Available : un8 = Time
 * Device_1 [1s], 0xFE = More than 253 sec, 0xFF = Not Available : un32 =
 * Application Version Device_1, 0xFFFFFFFF = Not Available : sn8 = Rssi
 * Device_1, 0x7F = Not Available : un32 = Reserved Device_1, 0xFFFFFFFF =
 * Reserved Value : un32 = Address In Range Device_2, 0xFFFFFFFF = Not Available
 * : un16 = Product ID Device_2, 0xFFFF = Not Available : un8 = Time Device_2
 * [1s], 0xFE = More than 253 sec, 0xFF = Not Available : un32 = Application
 * Version Device_2, 0xFFFFFFFF = Not Available : sn8 = Rssi Device_2, 0x7F = Not
 * Available : un32 = Reserved Device_2, 0xFFFFFFFF = Reserved Value}
 * @remark Continuation of the list of devices from which broadcasted VE_REG's
 * are received. Nodes for which no VE_REG's are received anymore, may be removed
 * from the list after an implementation dependent period.
 * When the Address value is set to 0xFFFFFFFF it marks the end of the list at
 * this moment (no more to follow).
 */
#define VE_REG_BLE_NETWORK_IN_RANGE_DEVICES_LIST_3 0xEC33

/**
 * BLE networking devices in range list {un8 = VREG version, 0x01 = Version1
 * (only allowed value) : un32 = Address In Range Device_1, 0xFFFFFFFF = Not
 * Available : un16 = Product ID Device_1, 0xFFFF = Not Available : un8 = Time
 * Device_1 [1s], 0xFE = More than 253 sec, 0xFF = Not Available : un32 =
 * Application Version Device_1, 0xFFFFFFFF = Not Available : sn8 = Rssi
 * Device_1, 0x7F = Not Available : un32 = Reserved Device_1, 0xFFFFFFFF =
 * Reserved Value : un32 = Address In Range Device_2, 0xFFFFFFFF = Not Available
 * : un16 = Product ID Device_2, 0xFFFF = Not Available : un8 = Time Device_2
 * [1s], 0xFE = More than 253 sec, 0xFF = Not Available : un32 = Application
 * Version Device_2, 0xFFFFFFFF = Not Available : sn8 = Rssi Device_2, 0x7F = Not
 * Available : un32 = Reserved Device_2, 0xFFFFFFFF = Reserved Value}
 * @remark Continuation of the list of devices from which broadcasted VE_REG's
 * are received. Nodes for which no VE_REG's are received anymore, may be removed
 * from the list after an implementation dependent period.
 * When the Address value is set to 0xFFFFFFFF it marks the end of the list at
 * this moment (no more to follow).
 */
#define VE_REG_BLE_NETWORK_IN_RANGE_DEVICES_LIST_4 0xEC34

/**
 * BLE networking devices in range list {un8 = VREG version, 0x01 = Version1
 * (only allowed value) : un32 = Address In Range Device_1, 0xFFFFFFFF = Not
 * Available : un16 = Product ID Device_1, 0xFFFF = Not Available : un8 = Time
 * Device_1 [1s], 0xFE = More than 253 sec, 0xFF = Not Available : un32 =
 * Application Version Device_1, 0xFFFFFFFF = Not Available : sn8 = Rssi
 * Device_1, 0x7F = Not Available : un32 = Reserved Device_1, 0xFFFFFFFF =
 * Reserved Value : un32 = Address In Range Device_2, 0xFFFFFFFF = Not Available
 * : un16 = Product ID Device_2, 0xFFFF = Not Available : un8 = Time Device_2
 * [1s], 0xFE = More than 253 sec, 0xFF = Not Available : un32 = Application
 * Version Device_2, 0xFFFFFFFF = Not Available : sn8 = Rssi Device_2, 0x7F = Not
 * Available : un32 = Reserved Device_2, 0xFFFFFFFF = Reserved Value}
 * @remark Continuation of the list of devices from which broadcasted VE_REG's
 * are received. Nodes for which no VE_REG's are received anymore, may be removed
 * from the list after an implementation dependent period.
 * When the Address value is set to 0xFFFFFFFF it marks the end of the list at
 * this moment (no more to follow).
 */
#define VE_REG_BLE_NETWORK_IN_RANGE_DEVICES_LIST_5 0xEC35

/**
 * BLE networking devices in range list {un8 = VREG version, 0x01 = Version1
 * (only allowed value) : un32 = Address In Range Device_1, 0xFFFFFFFF = Not
 * Available : un16 = Product ID Device_1, 0xFFFF = Not Available : un8 = Time
 * Device_1 [1s], 0xFE = More than 253 sec, 0xFF = Not Available : un32 =
 * Application Version Device_1, 0xFFFFFFFF = Not Available : sn8 = Rssi
 * Device_1, 0x7F = Not Available : un32 = Reserved Device_1, 0xFFFFFFFF =
 * Reserved Value : un32 = Address In Range Device_2, 0xFFFFFFFF = Not Available
 * : un16 = Product ID Device_2, 0xFFFF = Not Available : un8 = Time Device_2
 * [1s], 0xFE = More than 253 sec, 0xFF = Not Available : un32 = Application
 * Version Device_2, 0xFFFFFFFF = Not Available : sn8 = Rssi Device_2, 0x7F = Not
 * Available : un32 = Reserved Device_2, 0xFFFFFFFF = Reserved Value}
 * @remark Continuation of the list of devices from which broadcasted VE_REG's
 * are received. Nodes for which no VE_REG's are received anymore, may be removed
 * from the list after an implementation dependent period.
 * When the Address value is set to 0xFFFFFFFF it marks the end of the list at
 * this moment (no more to follow).
 */
#define VE_REG_BLE_NETWORK_IN_RANGE_DEVICES_LIST_6 0xEC36

/**
 * BLE networking devices in range list {un8 = VREG version, 0x01 = Version1
 * (only allowed value) : un32 = Address In Range Device_1, 0xFFFFFFFF = Not
 * Available : un16 = Product ID Device_1, 0xFFFF = Not Available : un8 = Time
 * Device_1 [1s], 0xFE = More than 253 sec, 0xFF = Not Available : un32 =
 * Application Version Device_1, 0xFFFFFFFF = Not Available : sn8 = Rssi
 * Device_1, 0x7F = Not Available : un32 = Reserved Device_1, 0xFFFFFFFF =
 * Reserved Value : un32 = Address In Range Device_2, 0xFFFFFFFF = Not Available
 * : un16 = Product ID Device_2, 0xFFFF = Not Available : un8 = Time Device_2
 * [1s], 0xFE = More than 253 sec, 0xFF = Not Available : un32 = Application
 * Version Device_2, 0xFFFFFFFF = Not Available : sn8 = Rssi Device_2, 0x7F = Not
 * Available : un32 = Reserved Device_2, 0xFFFFFFFF = Reserved Value}
 * @remark Continuation of the list of devices from which broadcasted VE_REG's
 * are received. Nodes for which no VE_REG's are received anymore, may be removed
 * from the list after an implementation dependent period.
 * When the Address value is set to 0xFFFFFFFF it marks the end of the list at
 * this moment (no more to follow).
 */
#define VE_REG_BLE_NETWORK_IN_RANGE_DEVICES_LIST_7 0xEC37

/**
 * BLE networking devices in range list {un8 = VREG version, 0x01 = Version1
 * (only allowed value) : un32 = Address In Range Device_1, 0xFFFFFFFF = Not
 * Available : un16 = Product ID Device_1, 0xFFFF = Not Available : un8 = Time
 * Device_1 [1s], 0xFE = More than 253 sec, 0xFF = Not Available : un32 =
 * Application Version Device_1, 0xFFFFFFFF = Not Available : sn8 = Rssi
 * Device_1, 0x7F = Not Available : un32 = Reserved Device_1, 0xFFFFFFFF =
 * Reserved Value : un32 = Address In Range Device_2, 0xFFFFFFFF = Not Available
 * : un16 = Product ID Device_2, 0xFFFF = Not Available : un8 = Time Device_2
 * [1s], 0xFE = More than 253 sec, 0xFF = Not Available : un32 = Application
 * Version Device_2, 0xFFFFFFFF = Not Available : sn8 = Rssi Device_2, 0x7F = Not
 * Available : un32 = Reserved Device_2, 0xFFFFFFFF = Reserved Value}
 * @remark Continuation of the list of devices from which broadcasted VE_REG's
 * are received. Nodes for which no VE_REG's are received anymore, may be removed
 * from the list after an implementation dependent period.
 * When the Address value is set to 0xFFFFFFFF it marks the end of the list at
 * this moment (no more to follow).
 */
#define VE_REG_BLE_NETWORK_IN_RANGE_DEVICES_LIST_8 0xEC38

/**
 * BLE networking devices in range list {un8 = VREG version, 0x01 = Version1
 * (only allowed value) : un32 = Address In Range Device_1, 0xFFFFFFFF = Not
 * Available : un16 = Product ID Device_1, 0xFFFF = Not Available : un8 = Time
 * Device_1 [1s], 0xFE = More than 253 sec, 0xFF = Not Available : un32 =
 * Application Version Device_1, 0xFFFFFFFF = Not Available : sn8 = Rssi
 * Device_1, 0x7F = Not Available : un32 = Reserved Device_1, 0xFFFFFFFF =
 * Reserved Value : un32 = Address In Range Device_2, 0xFFFFFFFF = Not Available
 * : un16 = Product ID Device_2, 0xFFFF = Not Available : un8 = Time Device_2
 * [1s], 0xFE = More than 253 sec, 0xFF = Not Available : un32 = Application
 * Version Device_2, 0xFFFFFFFF = Not Available : sn8 = Rssi Device_2, 0x7F = Not
 * Available : un32 = Reserved Device_2, 0xFFFFFFFF = Reserved Value}
 * @remark Continuation of the list of devices from which broadcasted VE_REG's
 * are received. Nodes for which no VE_REG's are received anymore, may be removed
 * from the list after an implementation dependent period.
 * When the Address value is set to 0xFFFFFFFF it marks the end of the list at
 * this moment (no more to follow).
 */
#define VE_REG_BLE_NETWORK_IN_RANGE_DEVICES_LIST_9 0xEC39

/**
 * BLE networking devices in range list {un8 = VREG version, 0x01 = Version1
 * (only allowed value) : un32 = Address In Range Device_1, 0xFFFFFFFF = Not
 * Available : un16 = Product ID Device_1, 0xFFFF = Not Available : un8 = Time
 * Device_1 [1s], 0xFE = More than 253 sec, 0xFF = Not Available : un32 =
 * Application Version Device_1, 0xFFFFFFFF = Not Available : sn8 = Rssi
 * Device_1, 0x7F = Not Available : un32 = Reserved Device_1, 0xFFFFFFFF =
 * Reserved Value : un32 = Address In Range Device_2, 0xFFFFFFFF = Not Available
 * : un16 = Product ID Device_2, 0xFFFF = Not Available : un8 = Time Device_2
 * [1s], 0xFE = More than 253 sec, 0xFF = Not Available : un32 = Application
 * Version Device_2, 0xFFFFFFFF = Not Available : sn8 = Rssi Device_2, 0x7F = Not
 * Available : un32 = Reserved Device_2, 0xFFFFFFFF = Reserved Value}
 * @remark Continuation of the list of devices from which broadcasted VE_REG's
 * are received. Nodes for which no VE_REG's are received anymore, may be removed
 * from the list after an implementation dependent period.
 * When the Address value is set to 0xFFFFFFFF it marks the end of the list at
 * this moment (no more to follow).
 */
#define VE_REG_BLE_NETWORK_IN_RANGE_DEVICES_LIST_10 0xEC3A

/**
 * BLE networking devices in range list {un8 = VREG version, 0x01 = Version1
 * (only allowed value) : un32 = Address In Range Device_1, 0xFFFFFFFF = Not
 * Available : un16 = Product ID Device_1, 0xFFFF = Not Available : un8 = Time
 * Device_1 [1s], 0xFE = More than 253 sec, 0xFF = Not Available : un32 =
 * Application Version Device_1, 0xFFFFFFFF = Not Available : sn8 = Rssi
 * Device_1, 0x7F = Not Available : un32 = Reserved Device_1, 0xFFFFFFFF =
 * Reserved Value : un32 = Address In Range Device_2, 0xFFFFFFFF = Not Available
 * : un16 = Product ID Device_2, 0xFFFF = Not Available : un8 = Time Device_2
 * [1s], 0xFE = More than 253 sec, 0xFF = Not Available : un32 = Application
 * Version Device_2, 0xFFFFFFFF = Not Available : sn8 = Rssi Device_2, 0x7F = Not
 * Available : un32 = Reserved Device_2, 0xFFFFFFFF = Reserved Value}
 * @remark Continuation of the list of devices from which broadcasted VE_REG's
 * are received. Nodes for which no VE_REG's are received anymore, may be removed
 * from the list after an implementation dependent period.
 * When the Address value is set to 0xFFFFFFFF it marks the end of the list at
 * this moment (no more to follow).
 */
#define VE_REG_BLE_NETWORK_IN_RANGE_DEVICES_LIST_11 0xEC3B

/**
 * BLE networking devices in range list {un8 = VREG version, 0x01 = Version1
 * (only allowed value) : un32 = Address In Range Device_1, 0xFFFFFFFF = Not
 * Available : un16 = Product ID Device_1, 0xFFFF = Not Available : un8 = Time
 * Device_1 [1s], 0xFE = More than 253 sec, 0xFF = Not Available : un32 =
 * Application Version Device_1, 0xFFFFFFFF = Not Available : sn8 = Rssi
 * Device_1, 0x7F = Not Available : un32 = Reserved Device_1, 0xFFFFFFFF =
 * Reserved Value : un32 = Address In Range Device_2, 0xFFFFFFFF = Not Available
 * : un16 = Product ID Device_2, 0xFFFF = Not Available : un8 = Time Device_2
 * [1s], 0xFE = More than 253 sec, 0xFF = Not Available : un32 = Application
 * Version Device_2, 0xFFFFFFFF = Not Available : sn8 = Rssi Device_2, 0x7F = Not
 * Available : un32 = Reserved Device_2, 0xFFFFFFFF = Reserved Value}
 * @remark Continuation of the list of devices from which broadcasted VE_REG's
 * are received. Nodes for which no VE_REG's are received anymore, may be removed
 * from the list after an implementation dependent period.
 * When the Address value is set to 0xFFFFFFFF it marks the end of the list at
 * this moment (no more to follow).
 */
#define VE_REG_BLE_NETWORK_IN_RANGE_DEVICES_LIST_12 0xEC3C

/**
 * BLE networking devices in range list {un8 = VREG version, 0x01 = Version1
 * (only allowed value) : un32 = Address In Range Device_1, 0xFFFFFFFF = Not
 * Available : un16 = Product ID Device_1, 0xFFFF = Not Available : un8 = Time
 * Device_1 [1s], 0xFE = More than 253 sec, 0xFF = Not Available : un32 =
 * Application Version Device_1, 0xFFFFFFFF = Not Available : sn8 = Rssi
 * Device_1, 0x7F = Not Available : un32 = Reserved Device_1, 0xFFFFFFFF =
 * Reserved Value : un32 = Address In Range Device_2, 0xFFFFFFFF = Not Available
 * : un16 = Product ID Device_2, 0xFFFF = Not Available : un8 = Time Device_2
 * [1s], 0xFE = More than 253 sec, 0xFF = Not Available : un32 = Application
 * Version Device_2, 0xFFFFFFFF = Not Available : sn8 = Rssi Device_2, 0x7F = Not
 * Available : un32 = Reserved Device_2, 0xFFFFFFFF = Reserved Value}
 * @remark Continuation of the list of devices from which broadcasted VE_REG's
 * are received. Nodes for which no VE_REG's are received anymore, may be removed
 * from the list after an implementation dependent period.
 * When the Address value is set to 0xFFFFFFFF it marks the end of the list at
 * this moment (no more to follow).
 */
#define VE_REG_BLE_NETWORK_IN_RANGE_DEVICES_LIST_13 0xEC3D

/**
 * Configuration of trend 0 {un8 = Number of subtrends each trend has. Maximum of
 * 8 subtrends., 0xFF = Not Available : un8 = Maximum number of samples in one
 * PUSH_DATA vreg for this trend, 0xFF = Not Available : un16 = Number of samples
 * in SUBTREND_0, 0xFFFF = Not Available : un16 = Time between 2 samples
 * (seconds) for SUBTREND_0, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_1, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_1, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_2, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_2, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_3, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_3, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_4, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_4, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_5, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_5, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_6, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_6, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_7, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_7, 0xFFFF = Not Available}
 * Configuration of trend 0 (definition of trend 0 via VE_REG_TREND_SUPP_VREGS).
 */
#define VE_REG_TREND_CONFIG_TREND_0 0xEC4A

/**
 * Configuration of trend 1 {un8 = Number of subtrends each trend has. Maximum of
 * 8 subtrends., 0xFF = Not Available : un8 = Maximum number of samples in one
 * PUSH_DATA vreg for this trend, 0xFF = Not Available : un16 = Number of samples
 * in SUBTREND_0, 0xFFFF = Not Available : un16 = Time between 2 samples
 * (seconds) for SUBTREND_0, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_1, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_1, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_2, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_2, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_3, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_3, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_4, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_4, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_5, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_5, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_6, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_6, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_7, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_7, 0xFFFF = Not Available}
 * Configuration of trend 1 (definition of trend 1 via VE_REG_TREND_SUPP_VREGS).
 */
#define VE_REG_TREND_CONFIG_TREND_1 0xEC4B

/**
 * Configuration of trend 2 {un8 = Number of subtrends each trend has. Maximum of
 * 8 subtrends., 0xFF = Not Available : un8 = Maximum number of samples in one
 * PUSH_DATA vreg for this trend, 0xFF = Not Available : un16 = Number of samples
 * in SUBTREND_0, 0xFFFF = Not Available : un16 = Time between 2 samples
 * (seconds) for SUBTREND_0, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_1, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_1, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_2, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_2, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_3, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_3, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_4, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_4, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_5, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_5, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_6, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_6, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_7, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_7, 0xFFFF = Not Available}
 * Configuration of trend 2 (definition of trend 2 via VE_REG_TREND_SUPP_VREGS).
 */
#define VE_REG_TREND_CONFIG_TREND_2 0xEC4C

/**
 * Configuration of trend 3 {un8 = Number of subtrends each trend has. Maximum of
 * 8 subtrends., 0xFF = Not Available : un8 = Maximum number of samples in one
 * PUSH_DATA vreg for this trend, 0xFF = Not Available : un16 = Number of samples
 * in SUBTREND_0, 0xFFFF = Not Available : un16 = Time between 2 samples
 * (seconds) for SUBTREND_0, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_1, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_1, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_2, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_2, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_3, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_3, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_4, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_4, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_5, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_5, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_6, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_6, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_7, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_7, 0xFFFF = Not Available}
 * Configuration of trend 3 (definition of trend 3 via VE_REG_TREND_SUPP_VREGS).
 */
#define VE_REG_TREND_CONFIG_TREND_3 0xEC4D

/**
 * Configuration of trend 4 {un8 = Number of subtrends each trend has. Maximum of
 * 8 subtrends., 0xFF = Not Available : un8 = Maximum number of samples in one
 * PUSH_DATA vreg for this trend, 0xFF = Not Available : un16 = Number of samples
 * in SUBTREND_0, 0xFFFF = Not Available : un16 = Time between 2 samples
 * (seconds) for SUBTREND_0, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_1, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_1, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_2, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_2, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_3, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_3, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_4, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_4, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_5, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_5, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_6, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_6, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_7, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_7, 0xFFFF = Not Available}
 * Configuration of trend 4 (definition of trend 4 via VE_REG_TREND_SUPP_VREGS).
 */
#define VE_REG_TREND_CONFIG_TREND_4 0xEC4E

/**
 * Configuration of trend 5 {un8 = Number of subtrends each trend has. Maximum of
 * 8 subtrends., 0xFF = Not Available : un8 = Maximum number of samples in one
 * PUSH_DATA vreg for this trend, 0xFF = Not Available : un16 = Number of samples
 * in SUBTREND_0, 0xFFFF = Not Available : un16 = Time between 2 samples
 * (seconds) for SUBTREND_0, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_1, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_1, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_2, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_2, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_3, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_3, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_4, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_4, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_5, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_5, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_6, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_6, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_7, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_7, 0xFFFF = Not Available}
 * Configuration of trend 5 (definition of trend 5 via VE_REG_TREND_SUPP_VREGS).
 */
#define VE_REG_TREND_CONFIG_TREND_5 0xEC4F

/**
 * Configuration of trend 6 {un8 = Number of subtrends each trend has. Maximum of
 * 8 subtrends., 0xFF = Not Available : un8 = Maximum number of samples in one
 * PUSH_DATA vreg for this trend, 0xFF = Not Available : un16 = Number of samples
 * in SUBTREND_0, 0xFFFF = Not Available : un16 = Time between 2 samples
 * (seconds) for SUBTREND_0, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_1, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_1, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_2, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_2, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_3, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_3, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_4, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_4, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_5, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_5, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_6, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_6, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_7, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_7, 0xFFFF = Not Available}
 * Configuration of trend 6 (definition of trend 6 via VE_REG_TREND_SUPP_VREGS).
 */
#define VE_REG_TREND_CONFIG_TREND_6 0xEC50

/**
 * Configuration of trend 7 {un8 = Number of subtrends each trend has. Maximum of
 * 8 subtrends., 0xFF = Not Available : un8 = Maximum number of samples in one
 * PUSH_DATA vreg for this trend, 0xFF = Not Available : un16 = Number of samples
 * in SUBTREND_0, 0xFFFF = Not Available : un16 = Time between 2 samples
 * (seconds) for SUBTREND_0, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_1, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_1, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_2, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_2, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_3, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_3, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_4, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_4, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_5, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_5, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_6, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_6, 0xFFFF = Not Available : un16 = Number of samples in
 * SUBTREND_7, 0xFFFF = Not Available : un16 = Time between 2 samples (seconds)
 * for SUBTREND_7, 0xFFFF = Not Available}
 * Configuration of trend 7 (definition of trend 7 via VE_REG_TREND_SUPP_VREGS).
 */
#define VE_REG_TREND_CONFIG_TREND_7 0xEC51

/**
 * Time references trend 0 {un32 = Time reference for latest sample in
 * SUBTREND_0, 0xFFFFFFFF = Not Available : un32 = Time reference for latest
 * sample in SUBTREND_1, 0xFFFFFFFF = Not Available : un32 = Time reference for
 * latest sample in SUBTREND_2, 0xFFFFFFFF = Not Available : un32 = Time
 * reference for latest sample in SUBTREND_3, 0xFFFFFFFF = Not Available : un32 =
 * Time reference for latest sample in SUBTREND_4, 0xFFFFFFFF = Not Available :
 * un32 = Time reference for latest sample in SUBTREND_5, 0xFFFFFFFF = Not
 * Available : un32 = Time reference for latest sample in SUBTREND_6, 0xFFFFFFFF
 * = Not Available : un32 = Time reference for latest sample in SUBTREND_7,
 * 0xFFFFFFFF = Not Available}
 * Returns the time references for all supported subtrends for trend 0.
 */
#define VE_REG_TREND_TIME_REFS_TREND_0 0xEC52

/**
 * Time references trend 1 {un32 = Time reference for latest sample in
 * SUBTREND_0, 0xFFFFFFFF = Not Available : un32 = Time reference for latest
 * sample in SUBTREND_1, 0xFFFFFFFF = Not Available : un32 = Time reference for
 * latest sample in SUBTREND_2, 0xFFFFFFFF = Not Available : un32 = Time
 * reference for latest sample in SUBTREND_3, 0xFFFFFFFF = Not Available : un32 =
 * Time reference for latest sample in SUBTREND_4, 0xFFFFFFFF = Not Available :
 * un32 = Time reference for latest sample in SUBTREND_5, 0xFFFFFFFF = Not
 * Available : un32 = Time reference for latest sample in SUBTREND_6, 0xFFFFFFFF
 * = Not Available : un32 = Time reference for latest sample in SUBTREND_7,
 * 0xFFFFFFFF = Not Available}
 * Returns the time references for all supported subtrends for trend 1.
 */
#define VE_REG_TREND_TIME_REFS_TREND_1 0xEC53

/**
 * Time references trend 2 {un32 = Time reference for latest sample in
 * SUBTREND_0, 0xFFFFFFFF = Not Available : un32 = Time reference for latest
 * sample in SUBTREND_1, 0xFFFFFFFF = Not Available : un32 = Time reference for
 * latest sample in SUBTREND_2, 0xFFFFFFFF = Not Available : un32 = Time
 * reference for latest sample in SUBTREND_3, 0xFFFFFFFF = Not Available : un32 =
 * Time reference for latest sample in SUBTREND_4, 0xFFFFFFFF = Not Available :
 * un32 = Time reference for latest sample in SUBTREND_5, 0xFFFFFFFF = Not
 * Available : un32 = Time reference for latest sample in SUBTREND_6, 0xFFFFFFFF
 * = Not Available : un32 = Time reference for latest sample in SUBTREND_7,
 * 0xFFFFFFFF = Not Available}
 * Returns the time references for all supported subtrends for trend 2.
 */
#define VE_REG_TREND_TIME_REFS_TREND_2 0xEC54

/**
 * Time references trend 3 {un32 = Time reference for latest sample in
 * SUBTREND_0, 0xFFFFFFFF = Not Available : un32 = Time reference for latest
 * sample in SUBTREND_1, 0xFFFFFFFF = Not Available : un32 = Time reference for
 * latest sample in SUBTREND_2, 0xFFFFFFFF = Not Available : un32 = Time
 * reference for latest sample in SUBTREND_3, 0xFFFFFFFF = Not Available : un32 =
 * Time reference for latest sample in SUBTREND_4, 0xFFFFFFFF = Not Available :
 * un32 = Time reference for latest sample in SUBTREND_5, 0xFFFFFFFF = Not
 * Available : un32 = Time reference for latest sample in SUBTREND_6, 0xFFFFFFFF
 * = Not Available : un32 = Time reference for latest sample in SUBTREND_7,
 * 0xFFFFFFFF = Not Available}
 * Returns the time references for all supported subtrends for trend 3.
 */
#define VE_REG_TREND_TIME_REFS_TREND_3 0xEC55

/**
 * Time references trend 4 {un32 = Time reference for latest sample in
 * SUBTREND_0, 0xFFFFFFFF = Not Available : un32 = Time reference for latest
 * sample in SUBTREND_1, 0xFFFFFFFF = Not Available : un32 = Time reference for
 * latest sample in SUBTREND_2, 0xFFFFFFFF = Not Available : un32 = Time
 * reference for latest sample in SUBTREND_3, 0xFFFFFFFF = Not Available : un32 =
 * Time reference for latest sample in SUBTREND_4, 0xFFFFFFFF = Not Available :
 * un32 = Time reference for latest sample in SUBTREND_5, 0xFFFFFFFF = Not
 * Available : un32 = Time reference for latest sample in SUBTREND_6, 0xFFFFFFFF
 * = Not Available : un32 = Time reference for latest sample in SUBTREND_7,
 * 0xFFFFFFFF = Not Available}
 * Returns the time references for all supported subtrends for trend 4.
 */
#define VE_REG_TREND_TIME_REFS_TREND_4 0xEC56

/**
 * Time references trend 5 {un32 = Time reference for latest sample in
 * SUBTREND_0, 0xFFFFFFFF = Not Available : un32 = Time reference for latest
 * sample in SUBTREND_1, 0xFFFFFFFF = Not Available : un32 = Time reference for
 * latest sample in SUBTREND_2, 0xFFFFFFFF = Not Available : un32 = Time
 * reference for latest sample in SUBTREND_3, 0xFFFFFFFF = Not Available : un32 =
 * Time reference for latest sample in SUBTREND_4, 0xFFFFFFFF = Not Available :
 * un32 = Time reference for latest sample in SUBTREND_5, 0xFFFFFFFF = Not
 * Available : un32 = Time reference for latest sample in SUBTREND_6, 0xFFFFFFFF
 * = Not Available : un32 = Time reference for latest sample in SUBTREND_7,
 * 0xFFFFFFFF = Not Available}
 * Returns the time references for all supported subtrends for trend 5.
 */
#define VE_REG_TREND_TIME_REFS_TREND_5 0xEC57

/**
 * Time references trend 6 {un32 = Time reference for latest sample in
 * SUBTREND_0, 0xFFFFFFFF = Not Available : un32 = Time reference for latest
 * sample in SUBTREND_1, 0xFFFFFFFF = Not Available : un32 = Time reference for
 * latest sample in SUBTREND_2, 0xFFFFFFFF = Not Available : un32 = Time
 * reference for latest sample in SUBTREND_3, 0xFFFFFFFF = Not Available : un32 =
 * Time reference for latest sample in SUBTREND_4, 0xFFFFFFFF = Not Available :
 * un32 = Time reference for latest sample in SUBTREND_5, 0xFFFFFFFF = Not
 * Available : un32 = Time reference for latest sample in SUBTREND_6, 0xFFFFFFFF
 * = Not Available : un32 = Time reference for latest sample in SUBTREND_7,
 * 0xFFFFFFFF = Not Available}
 * Returns the time references for all supported subtrends for trend 6.
 */
#define VE_REG_TREND_TIME_REFS_TREND_6 0xEC58

/**
 * Time references trend 7 {un32 = Time reference for latest sample in
 * SUBTREND_0, 0xFFFFFFFF = Not Available : un32 = Time reference for latest
 * sample in SUBTREND_1, 0xFFFFFFFF = Not Available : un32 = Time reference for
 * latest sample in SUBTREND_2, 0xFFFFFFFF = Not Available : un32 = Time
 * reference for latest sample in SUBTREND_3, 0xFFFFFFFF = Not Available : un32 =
 * Time reference for latest sample in SUBTREND_4, 0xFFFFFFFF = Not Available :
 * un32 = Time reference for latest sample in SUBTREND_5, 0xFFFFFFFF = Not
 * Available : un32 = Time reference for latest sample in SUBTREND_6, 0xFFFFFFFF
 * = Not Available : un32 = Time reference for latest sample in SUBTREND_7,
 * 0xFFFFFFFF = Not Available}
 * Returns the time references for all supported subtrends for trend 7.
 */
#define VE_REG_TREND_TIME_REFS_TREND_7 0xEC59

/**
 * Push trend data {un8 = Trend index [0-7], 0xFF = Not Available : un32 = Time
 * reference of newest to push, 0xFFFFFFFF = Not Available : un8 = Number of
 * samples to push (start with time reference), 0xFF = Not Available : un16 =
 * Interval time of the pushed samples, 0xFFFF = Not Available : block = Sample
 * data. Maximum of 56 bytes., 0xFF = Not Available}
 * Vreg can only be SET. The reply send by the device will contain the sample
 * data.
 */
#define VE_REG_TREND_PUSH_DATA 0xEC5B

/**
 * Trend Supported VREGs {un16 = Supported vreg referenced as TREND_0, 0xFFFF =
 * Not Available : un16 = Supported vreg referenced as TREND_1, 0xFFFF = Not
 * Available : un16 = Supported vreg referenced as TREND_2, 0xFFFF = Not
 * Available : un16 = Supported vreg referenced as TREND_3, 0xFFFF = Not
 * Available : un16 = Supported vreg referenced as TREND_4, 0xFFFF = Not
 * Available : un16 = Supported vreg referenced as TREND_5, 0xFFFF = Not
 * Available : un16 = Supported vreg referenced as TREND_6, 0xFFFF = Not
 * Available : un16 = Supported vreg referenced as TREND_7, 0xFFFF = Not
 * Available}
 * Vregs the device storing trend values for. The position in the list is
 * considered to be an index.
 */
#define VE_REG_TREND_SUPP_VREGS 0xEC5D

/**
 * Push trend data v2 (prototyping)
 *             Push trend data for multiple SubTrends.
 *             SET+REPLY payload: un8 = trend index, un32 = time reference for
 * requested most recent sample (following samples will be older).
 *             REPLY payload: un8 = trend index, un32 = time reference, un16 =
 * interval time samples, un8 = nr of samples (=X), X samples, un16 = interval
 * time samples, un8 = nr of samples (=Y), Y samples, un16 = interval time
 * samples, un8 = nr of samples (=Z), Z samples, .. , .. )
 */
#define VE_REG_TREND_PUSH_DATA_V2 0xEC5E

/**
 * Trend active time tuple {un32 = Active TimeTuple TimeRef, 0xFFFFFFFF = Not
 * Available : un32 = Active TimeTuple TimeStamp, 0xFFFFFFFF = Not Available,
 * Date/time in unix-timestamp format. Stored in an UNsigned 4-byte word to allow
 * usage after 19-Jan-38. }
 * Returns or stores the current active time tuple. The active time tuple can
 * only be set once after rebooting and will stay active for as long as the
 * device is powered up. When set the time tuple is stored and can also be
 * retrieved via the VE_REG_TREND_PUSH_TIME_TUPLES_LIST.
 */
#define VE_REG_TREND_ACTIVE_TIME_TUPLE 0xEC5F

/**
 * Push trend time tuple list {un32 = (Set only) Time reference of newest time
 * tuple to push, 0xFFFFFFFF = Not Available : un32 = (Reply only) TimeTuple_1
 * TimeRef, 0xFFFFFFFF = Not Available : un32 = (Reply only) TimeTuple_1
 * TimeStamp, 0xFFFFFFFF = Not Available, Date/time in unix-timestamp format.
 * Stored in an UNsigned 4-byte word to allow usage after 19-Jan-38.  : un32 =
 * (Reply only) TimeTuple_2 TimeRef, 0xFFFFFFFF = Not Available : un32 = (Reply
 * only) TimeTuple_2 TimeStamp, 0xFFFFFFFF = Not Available : un32 = (Reply only)
 * TimeTuple_3 TimeRef, 0xFFFFFFFF = Not Available : un32 = (Reply only)
 * TimeTuple_3 TimeStamp, 0xFFFFFFFF = Not Available : un32 = (Reply only)
 * TimeTuple_4 TimeRef, 0xFFFFFFFF = Not Available : un32 = (Reply only)
 * TimeTuple_4 TimeStamp, 0xFFFFFFFF = Not Available : un32 = (Reply only)
 * TimeTuple_5 TimeRef, 0xFFFFFFFF = Not Available : un32 = (Reply only)
 * TimeTuple_5 TimeStamp, 0xFFFFFFFF = Not Available : un32 = (Reply only)
 * TimeTuple_6 TimeRef, 0xFFFFFFFF = Not Available : un32 = (Reply only)
 * TimeTuple_6 TimeStamp, 0xFFFFFFFF = Not Available : un32 = (Reply only)
 * TimeTuple_7 TimeRef, 0xFFFFFFFF = Not Available : un32 = (Reply only)
 * TimeTuple_7 TimeStamp, 0xFFFFFFFF = Not Available : un32 = (Reply only)
 * TimeTuple_8 TimeRef, 0xFFFFFFFF = Not Available : un32 = (Reply only)
 * TimeTuple_8 TimeStamp, 0xFFFFFFFF = Not Available}
 * Vreg can only be SET. The reply send by the device will contain the time
 * tuples only. Reply will always contain 8 time tuples, though each one can have
 * the invalid value. Once a time tuple has the invalid value, all remaining time
 * tuples will also have the invalid value.
 */
#define VE_REG_TREND_PUSH_TIME_TUPLE_LIST 0xEC63

/**
 * Push trend reboot list {un32 = (Set only) Time reference of newest reboot time
 * reference to push, 0xFFFFFFFF = Not Available : un32 = (Reply only) Reboot
 * TimeRef 1, 0xFFFFFFFF = Not Available : un32 = (Reply only) Reboot TimeRef 2,
 * 0xFFFFFFFF = Not Available : un32 = (Reply only) Reboot TimeRef 3, 0xFFFFFFFF
 * = Not Available : un32 = (Reply only) Reboot TimeRef 4, 0xFFFFFFFF = Not
 * Available : un32 = (Reply only) Reboot TimeRef 5, 0xFFFFFFFF = Not Available :
 * un32 = (Reply only) Reboot TimeRef 6, 0xFFFFFFFF = Not Available : un32 =
 * (Reply only) Reboot TimeRef 7, 0xFFFFFFFF = Not Available : un32 = (Reply
 * only) Reboot TimeRef 8, 0xFFFFFFFF = Not Available : un32 = (Reply only)
 * Reboot TimeRef 9, 0xFFFFFFFF = Not Available : un32 = (Reply only) Reboot
 * TimeRef 10, 0xFFFFFFFF = Not Available : un32 = (Reply only) Reboot TimeRef
 * 11, 0xFFFFFFFF = Not Available : un32 = (Reply only) Reboot TimeRef 12,
 * 0xFFFFFFFF = Not Available : un32 = (Reply only) Reboot TimeRef 13, 0xFFFFFFFF
 * = Not Available : un32 = (Reply only) Reboot TimeRef 14, 0xFFFFFFFF = Not
 * Available : un32 = (Reply only) Reboot TimeRef 15, 0xFFFFFFFF = Not Available
 * : un32 = (Reply only) Reboot TimeRef 16, 0xFFFFFFFF = Not Available}
 * Vreg can only be SET. The reply send by the device will contain the reboot
 * time references only (stored by device for each reboot). Reply will always
 * contain 16 time references, though each one can have the invalid value. Once a
 * time reference has the invalid value, all remaining time refences will also
 * have the invalid value.
 */
#define VE_REG_TREND_PUSH_REBOOT_LIST 0xEC64

/**
 * BLE advertisement key {stringFixed[16] = key}
 * The encryption key that is used to encrypt the "extra" advertisement data.
 * This is regenerated when the pincode is changed.
 * This way, people that were bonded but removed from the bond list will also not
 * be able to properly decode the advertisement data.
 */
#define VE_REG_BLE_ADVERTISEMENT_KEY 0xEC65

/** BLE MAC address {stringFixed[6] = address} */
#define VE_REG_BLE_MAC_ADDRESS 0xEC66

/** BLE+ Button/Switch State {un16 = buttons} */
#define VE_REG_BLEP_BUTTONS 0x2300

/** BLE+ Blinking Pattern for LED 0 {un16 = pattern} */
#define VE_REG_BLEP_LED_PATTERN_0 0x2310

/** BLE+ Blinking Pattern for LED 1 {un16 = pattern} */
#define VE_REG_BLEP_LED_PATTERN_1 0x2311

/** BLE+ Blinking Pattern for LED 2 {un16 = pattern} */
#define VE_REG_BLEP_LED_PATTERN_2 0x2312

/** BLE+ Blinking Pattern for LED 3 {un16 = pattern} */
#define VE_REG_BLEP_LED_PATTERN_3 0x2313

/** BLE+ Blinking Pattern for LED 4 {un16 = pattern} */
#define VE_REG_BLEP_LED_PATTERN_4 0x2314

/** BLE+ Blinking Pattern for LED 5 {un16 = pattern} */
#define VE_REG_BLEP_LED_PATTERN_5 0x2315

/** BLE+ Blinking Pattern for LED 6 {un16 = pattern} */
#define VE_REG_BLEP_LED_PATTERN_6 0x2316

/** BLE+ Blinking Pattern for LED 7 {un16 = pattern} */
#define VE_REG_BLEP_LED_PATTERN_7 0x2317

/** BLE+ Blinking Pattern for LED 8 {un16 = pattern} */
#define VE_REG_BLEP_LED_PATTERN_8 0x2318

/** BLE+ Blinking Pattern for LED 9 {un16 = pattern} */
#define VE_REG_BLEP_LED_PATTERN_9 0x2319

/** BLE+ ADC Measurement Result 0 {un16 = measurement} */
#define VE_REG_BLEP_ADC_MEAS_0 0x2320

/** BLE+ ADC Measurement Result 1 {un16 = measurement} */
#define VE_REG_BLEP_ADC_MEAS_1 0x2321

/** BLE+ ADC Measurement Result 2 {un16 = measurement} */
#define VE_REG_BLEP_ADC_MEAS_2 0x2322

/** BLE+ ADC Measurement Result 3 {un16 = measurement} */
#define VE_REG_BLEP_ADC_MEAS_3 0x2323

/** BLE+ ADC Measurement Result 4 {un16 = measurement} */
#define VE_REG_BLEP_ADC_MEAS_4 0x2324

/** BLE+ ADC Measurement Result 5 {un16 = measurement} */
#define VE_REG_BLEP_ADC_MEAS_5 0x2325

/** BLE+ ADC Measurement Result 6 {un16 = measurement} */
#define VE_REG_BLEP_ADC_MEAS_6 0x2326

/** BLE+ ADC Measurement Result 7 {un16 = measurement} */
#define VE_REG_BLEP_ADC_MEAS_7 0x2327

/** BLE+ ADC Reference Measurement {un16 = measurement} */
#define VE_REG_BLEP_ADC_REF 0x232F

/** BLE+ ADC Measurement Gain 0 {un16 = gain} */
#define VE_REG_BLEP_ADC_GAIN_0 0x2330

/** BLE+ ADC Measurement Gain 1 {un16 = gain} */
#define VE_REG_BLEP_ADC_GAIN_1 0x2331

/** BLE+ ADC Measurement Gain 2 {un16 = gain} */
#define VE_REG_BLEP_ADC_GAIN_2 0x2332

/** BLE+ ADC Measurement Gain 3 {un16 = gain} */
#define VE_REG_BLEP_ADC_GAIN_3 0x2333

/** BLE+ ADC Measurement Gain 4 {un16 = gain} */
#define VE_REG_BLEP_ADC_GAIN_4 0x2334

/** BLE+ ADC Measurement Gain 5 {un16 = gain} */
#define VE_REG_BLEP_ADC_GAIN_5 0x2335

/** BLE+ ADC Measurement Gain 6 {un16 = gain} */
#define VE_REG_BLEP_ADC_GAIN_6 0x2336

/** BLE+ ADC Measurement Gain 7 {un16 = gain} */
#define VE_REG_BLEP_ADC_GAIN_7 0x2337

/** BLE+ ADC Reference Calibration value {un16 = measurement} */
#define VE_REG_BLEP_ADC_CALIB_REF 0x233F

/** BLE+ Wake-up Threshold {un16 = threshold [0.01V], 0xFFFF = Not Available} */
#define VE_REG_BLEP_WAKEUP_THRESHOLD 0x2340

/** BLE+ Hibernate Threshold {un16 = threshold [0.01V], 0xFFFF = Not Available} */
#define VE_REG_BLEP_HIBERNATE_THRESHOLD 0x2341

/**
 * BLE+ Power Mode {un16 = mode, 0x0000 = On, 0x0001 = Standby, 0x0002 = Update,
 * 0x0010 = Hibernate}
 */
#define VE_REG_BLEP_POWER_MODE 0x2342

/** BLE+ Remember Mode {un16 = mode} */
#define VE_REG_BLEP_REMEMBER_MODE 0x2343

/** BLE+ Remember Alarm {un16 = alarm} */
#define VE_REG_BLEP_REMEMBER_ALARM 0x2344

/** BLE+ Internal Communication Timeout {un16 = timeout} */
#define VE_REG_BLEP_INTERNALCOM_TIMEOUT 0x2345

/** BLE+ Enable VE.Direct Supply {un16 = supply} */
#define VE_REG_BLEP_ENABLE_VEDSUPPLY 0x2346

/** BLE+ Battery Voltage Gain {un16 = gain} */
#define VE_REG_BLEP_VBAT_GAIN 0x2347

/** BLE+ Battery Voltage STM {sn32 = voltage [0.001V]} */
#define VE_REG_BLEP_VBAT_STM 0x2348

/**
 * BLE+ Errors {bits[1] = Calibration Tfs corrupt : bits[1] = Settings Tfs
 * corrupt : bits[14] = reserved, 0x0 = reserved}
 */
#define VE_REG_BLEP_ERRORS 0x2349

/** BLE+ Display Mode {un8 = mode} */
#define VE_REG_BLEP_DISPLAY_MODE 0x2350

/** BLE+ Display Backlight {un8 = backlight} */
#define VE_REG_BLEP_DISPLAY_BACKLIGHT 0x2351

/** BLE+ Display Contrast {un8 = contrast} */
#define VE_REG_BLEP_DISPLAY_CONTRAST 0x2352

/** BLE+ Display Cursor {un8 = cursor} */
#define VE_REG_BLEP_DISPLAY_CURSOR 0x2353

/** BLE+ Buzzer {un16 = buzzer} */
#define VE_REG_BLEP_BUZZER 0x2360

/** BLE+ ErrorCode {un16 = errorcode} */
#define VE_REG_BLEP_ERRORCODE 0x2361

/** BLE+ Display Line 1 {stringFixed[20] = line} */
#define VE_REG_BLEP_DISPLAY_LINE1 0x2354

/** BLE+ Display Line 2 {stringFixed[20] = line} */
#define VE_REG_BLEP_DISPLAY_LINE2 0x2355

/** BLE+ Display Line 3 {stringFixed[20] = line} */
#define VE_REG_BLEP_DISPLAY_LINE3 0x2356

/** BLE+ Display Line 4 {stringFixed[20] = line} */
#define VE_REG_BLEP_DISPLAY_LINE4 0x2357

/** BLE+ Display Line 5 {stringFixed[20] = line} */
#define VE_REG_BLEP_DISPLAY_LINE5 0x2362

/** BLE+ Display Line 6 {stringFixed[20] = line} */
#define VE_REG_BLEP_DISPLAY_LINE6 0x2363

/** BLE+ Display Line 7 {stringFixed[20] = line} */
#define VE_REG_BLEP_DISPLAY_LINE7 0x2364

/** BLE+ Display Line 8 {stringFixed[20] = line} */
#define VE_REG_BLEP_DISPLAY_LINE8 0x2365

/** BLE+ Display Bitmap 0 {stringFixed[8] = bitmap} */
#define VE_REG_BLEP_DISPLAY_BITMAP0 0x2358

/** BLE+ Display Bitmap 1 {stringFixed[8] = bitmap} */
#define VE_REG_BLEP_DISPLAY_BITMAP1 0x2359

/** BLE+ Display Bitmap 2 {stringFixed[8] = bitmap} */
#define VE_REG_BLEP_DISPLAY_BITMAP2 0x235A

/** BLE+ Display Bitmap 3 {stringFixed[8] = bitmap} */
#define VE_REG_BLEP_DISPLAY_BITMAP3 0x235B

/** BLE+ Display Bitmap 4 {stringFixed[8] = bitmap} */
#define VE_REG_BLEP_DISPLAY_BITMAP4 0x235C

/** BLE+ Display Bitmap 5 {stringFixed[8] = bitmap} */
#define VE_REG_BLEP_DISPLAY_BITMAP5 0x235D

/** BLE+ Display Bitmap 6 {stringFixed[8] = bitmap} */
#define VE_REG_BLEP_DISPLAY_BITMAP6 0x235E

/** BLE+ Display Bitmap 7 {stringFixed[8] = bitmap} */
#define VE_REG_BLEP_DISPLAY_BITMAP7 0x235F

/**
 * Link Algorithm (internal) {un8 = Link Algorithm (see xml for meanings)}
 * @remark only models that support parallel charging have this information
 */
#define VE_REG_LINK_ALGORITHM 0x2000

/**
 * Link VSet (internal) {un16 = Link VSet [0.01V], 0xFFFF = Not Available,
 * Charger link, voltage set-point }
 * @remark only the charge master broadcasts voltage set-point, share this from
 * the master to the slaves, slaves have 60s timeout
 */
#define VE_REG_LINK_VSET 0x2001

/**
 * Link VSense (internal) {un16 = Voltage [0.01V], 0xFFFF = Not Available,
 * Charger link, battery sense voltage }
 * @remark any member broadcasts battery sense voltage when available
 */
#define VE_REG_LINK_VSENSE 0x2002

/**
 * Link TSense (internal) {sn16 = Temperature [0.01°C], 0x7FFF = Not Available,
 * Charger link, battery temperature}
 * @remark any member broadcasts battery temperature sense when available
 */
#define VE_REG_LINK_TSENSE 0x2003

/**
 * Link Command (internal) {un8 = Commmand, 0x01 = VE_REG_COMMAND_START_EQUALISE,
 * 0x02 = VE_REG_COMMAND_STOP_EQUALISE, 0x03 = VE_REG_COMMAND_GUI_SYNC, 0x04 =
 * VE_REG_COMMAND_DAY_SYNC, Charger link, command channel from slaves to master}
 */
#define VE_REG_LINK_COMMAND 0x2004

/**
 * Link Switch Bank Status (internal) {bits[1] = Switch 1, 0 = Off, 1 = On :
 * bits[1] = Switch 2, 0 = Off, 1 = On : bits[1] = Switch 3, 0 = Off, 1 = On :
 * bits[1] = Switch 4, 0 = Off, 1 = On : bits[1] = Switch 5, 0 = Off, 1 = On :
 * bits[1] = Switch 6, 0 = Off, 1 = On : bits[1] = Switch 7, 0 = Off, 1 = On :
 * bits[1] = Switch 8, 0 = Off, 1 = On : bits[1] = Switch 9, 0 = Off, 1 = On :
 * bits[1] = Switch 10, 0 = Off, 1 = On : bits[1] = Switch 11, 0 = Off, 1 = On :
 * bits[1] = Switch 12, 0 = Off, 1 = On : bits[1] = Switch 13, 0 = Off, 1 = On :
 * bits[1] = Switch 14, 0 = Off, 1 = On : bits[1] = Switch 15, 0 = Off, 1 = On :
 * bits[1] = Switch 16, 0 = Off, 1 = On : bits[1] = Switch 17, 0 = Off, 1 = On :
 * bits[1] = Switch 18, 0 = Off, 1 = On : bits[1] = Switch 19, 0 = Off, 1 = On :
 * bits[1] = Switch 20, 0 = Off, 1 = On : bits[1] = Switch 21, 0 = Off, 1 = On :
 * bits[1] = Switch 22, 0 = Off, 1 = On : bits[1] = Switch 23, 0 = Off, 1 = On :
 * bits[1] = Switch 24, 0 = Off, 1 = On : bits[1] = Switch 25, 0 = Off, 1 = On :
 * bits[1] = Switch 26, 0 = Off, 1 = On : bits[1] = Switch 27, 0 = Off, 1 = On :
 * bits[1] = Switch 28, 0 = Off, 1 = On : bits[4] = reserved, 0 = reserved}
 */
#define VE_REG_LINK_BINARY_SWITCH_BANK_STATUS 0x2005

/**
 * Link Switch Bank Mask (internal) {bits[1] = Switch 1, 0 = Unused, 1 = Used :
 * bits[1] = Switch 2, 0 = Unused, 1 = Used : bits[1] = Switch 3, 0 = Unused, 1 =
 * Used : bits[1] = Switch 4, 0 = Unused, 1 = Used : bits[1] = Switch 5, 0 =
 * Unused, 1 = Used : bits[1] = Switch 6, 0 = Unused, 1 = Used : bits[1] = Switch
 * 7, 0 = Unused, 1 = Used : bits[1] = Switch 8, 0 = Unused, 1 = Used : bits[1] =
 * Switch 9, 0 = Unused, 1 = Used : bits[1] = Switch 10, 0 = Unused, 1 = Used :
 * bits[1] = Switch 11, 0 = Unused, 1 = Used : bits[1] = Switch 12, 0 = Unused, 1
 * = Used : bits[1] = Switch 13, 0 = Unused, 1 = Used : bits[1] = Switch 14, 0 =
 * Unused, 1 = Used : bits[1] = Switch 15, 0 = Unused, 1 = Used : bits[1] =
 * Switch 16, 0 = Unused, 1 = Used : bits[1] = Switch 17, 0 = Unused, 1 = Used :
 * bits[1] = Switch 18, 0 = Unused, 1 = Used : bits[1] = Switch 19, 0 = Unused, 1
 * = Used : bits[1] = Switch 20, 0 = Unused, 1 = Used : bits[1] = Switch 21, 0 =
 * Unused, 1 = Used : bits[1] = Switch 22, 0 = Unused, 1 = Used : bits[1] =
 * Switch 23, 0 = Unused, 1 = Used : bits[1] = Switch 24, 0 = Unused, 1 = Used :
 * bits[1] = Switch 25, 0 = Unused, 1 = Used : bits[1] = Switch 26, 0 = Unused, 1
 * = Used : bits[1] = Switch 27, 0 = Unused, 1 = Used : bits[1] = Switch 28, 0 =
 * Unused, 1 = Used : bits[4] = reserved, 0 = reserved}
 */
#define VE_REG_LINK_BINARY_SWITCH_BANK_MASK 0x2006

/**
 * Link Elapsed Time (internal) {un32 = Time [0.001s], 0xFFFFFFFF = Not
 * Available}
 * @remark only the charge master broadcasts timestamp, share this from the
 * master to the slaves, slaves have 60s timeout
 */
#define VE_REG_LINK_ELAPSED_TIME 0x2007

/**
 * Link Absorption Time (internal) {un16 = Time [0.01hours], 0xFFFF = Not
 * Available}
 * @remark only the charge master broadcasts timestamp, share this from the
 * master to the slaves, slaves have 60s timeout
 */
#define VE_REG_LINK_ABSORPTION_TIME 0x2008

/**
 * Link Error Code (internal) {un8 = Error Code (see xml for meanings)}
 * @remark an external network master can use this to inject an error code (this
 * will be shown on the unit), 60s timeout
 */
#define VE_REG_LINK_ERROR_CODE 0x2009

/**
 * Link Battery Current (internal) {sn32 = Current [0.001A], 0x7FFFFFFF = Not
 * Available}
 * @remark the charge master needs the actual battery current (source bmv or
 * battery), 60s timeout.
 * if this information is not available ve.direct uses @ref
 * VE_REG_LINK_TOTAL_CHARGE_CURRENT instead
 * and on ve.can the unit collects all @ref VE_REG_DC_CHANNEL1_CURRENT data and
 * adds
 * @ref VE_REG_LINK_EXTRA_BATTERY_CURRENT to this for the dc currents that are
 * not directly visible
 * (vedirect/vebus).
 */
#define VE_REG_LINK_BATTERY_CURRENT 0x200A

/**
 * Link Battery Idle Voltage (internal) {un16 = Link Battery Idle Voltage
 * [0.01V], 0xFFFF = Not Available, Charger link, battery idle voltage}
 * @remark share this from the charge master to the slaves. Background: only the
 * first unit that starts the charge process can measure the battery idle
 * voltage.
 */
#define VE_REG_LINK_BATTERY_IDLE_VOLTAGE 0x200B

/**
 * Link device state (internal) {un8 = State (see xml for meanings), Charger
 * link, device state, @see N2kConverterState}
 * @remark share the device state @VE_REG_DEVICE_STATE from the master to the
 * slaves, slaves have 60s timeout.
 */
#define VE_REG_LINK_DEVICE_STATE 0x200C

/**
 * Link Network Info (internal) {bits[1] = BMS, 0 = No, 1 = Yes : bits[1] =
 * External voltage control, 0 = No, 1 = Yes, remote voltage control : bits[1] =
 * Charge Slave, 0 = No, 1 = Yes : bits[1] = Charge Master, 0 = No, 1 = Yes :
 * bits[1] = I Charge, 0 = No, 1 = Yes : bits[1] = I Sense, 0 = No, 1 = Yes :
 * bits[1] = T Sense, 0 = No, 1 = Yes : bits[1] = V Sense, 0 = No, 1 = Yes :
 * bits[1] = Standby, 0 = No, 1 = Yes : bits[1] = I Control, 0 = No, 1 = Yes,
 * remote current control : }
 * this reports the overall network activity
 */
#define VE_REG_LINK_NETWORK_INFO 0x200D

/**
 * Link Network Mode (internal) {bits[1] = Networked, 0 = No, 1 = Yes : bits[1] =
 * Remote Charge, 0 = No, 1 = Yes, remote algoritm : bits[1] = External Control,
 * 0 = No, 1 = Yes : bits[1] = Remote BMS, 0 = No, 1 = Yes, remote bms puts a
 * ve.direct device in remote controlled mode. : bits[1] = Group Master, 0 = No,
 * 1 = Yes : bits[1] = Instance Master, 0 = No, 1 = Yes : bits[1] = Standby, 0 =
 * No, 1 = Yes : bits[1] = reserved, 0 = No, 1 = Yes}
 * @remark the network master has to set this on all units, 60s timeout
 */
#define VE_REG_LINK_NETWORK_MODE 0x200E

/**
 * Link Device Network Status (internal) {bits[1] = Group Master, 0 = No, 1 = Yes
 * : bits[1] = Instance Master, 0 = No, 1 = Yes : bits[1] = Stand Alone, 0 = No,
 * 1 = Yes : bits[1] = reserved 3, 0 = No, 1 = Yes : bits[1] = Using I Charge, 0
 * = No, 1 = Yes : bits[1] = Using I Sense, 0 = No, 1 = Yes : bits[1] = Using T
 * Sense, 0 = No, 1 = Yes : bits[1] = Using V Sense, 0 = No, 1 = Yes}
 * @remark for informational purpose only, this reports the network status (per
 * interface)
 */
#define VE_REG_LINK_NETWORK_STATUS 0x200F

/**
 * Link AC Input Current Maximum (internal) {un16 = Link AC Input Current Maximum
 * [0.1A], 0xFFFF = Not Available}
 */
#define VE_REG_LINK_AC_INPUT_MAX_CURRENT 0x2010

/**
 * Link AC Input Current Limit (internal) {un16 = Link AC Input Current Limit
 * [0.1A], 0xFFFF = Not Available}
 */
#define VE_REG_LINK_AC_INPUT_CURRENT_LIMIT 0x2011

/**
 * Link AC Input Current (internal) {un16 = Link AC Input Current [0.1A], 0xFFFF
 * = Not Available}
 */
#define VE_REG_LINK_AC_INPUT_CURRENT 0x2012

/**
 * Link Total Charge Current (internal) {sn32 = Current [0.001A], 0x7FFFFFFF =
 * Not Available}
 * @remark the charge master needs the actual battery current (source adding all
 * dc currents: estimate), 60s timeout.
 * if @ref VE_REG_LINK_BATTERY_CURRENT is present in the system this information
 * will be used instead.
 */
#define VE_REG_LINK_TOTAL_CHARGE_CURRENT 0x2013

/**
 * Link Charge Current Percentage (internal) {un8 = Percentage [1%], 0xFF = Not
 * Available, valid range 0 till 100}
 */
#define VE_REG_LINK_CHARGE_CURRENT_PERCENTAGE 0x2014

/**
 * Link Charge Current Limit (internal) {un16 = Link Charge Current Limit [0.1A],
 * 0xFFFF = Not Available}
 */
#define VE_REG_LINK_CHARGE_CURRENT_LIMIT 0x2015

/**
 * Link Charge Voltage Setpoint (internal) {un16 = Link Charge Voltage Setpoint
 * [0.01V], 0xFFFF = Not Available}
 * @remark Use register @ref VE_REG_LINK_VSET instead
 */
#define VE_REG_LINK_CHARGE_VOLTAGE_SETPOINT 0x2016

/**
 * Link Discharge Current Limit (internal) {un16 = Link Discharge Current Limit
 * [0.1A], 0xFFFF = Not Available}
 */
#define VE_REG_LINK_DISCHARGE_CURRENT_LIMIT 0x2017

/**
 * Link Equalisation Pending (internal) {un8 = Link Equalisation Pending, 0 = No,
 * 1 = Yes, 2 = Error, 3 = Unknown}
 */
#define VE_REG_LINK_EQUALISATION_PENDING 0x2018

/**
 * Link Equalisation Time Remaining (internal) {un16 = Link Equalisation Time
 * Remaining [1min], 0xFFFF = Not Available}
 */
#define VE_REG_LINK_EQUALISATION_TIME_REMAINING 0x2019

/**
 * Link Device Disable Network Data (internal) {bits[1] = Sync Chgr, 0 = No, 1 =
 * Yes : bits[1] = I Sense, 0 = No, 1 = Yes : bits[1] = T Sense, 0 = No, 1 = Yes
 * : bits[1] = V Sense, 0 = No, 1 = Yes : bits[1] = reserved 4, 0 = No, 1 = Yes :
 * bits[1] = reserved 5, 0 = No, 1 = Yes : bits[1] = reserved 6, 0 = No, 1 = Yes
 * : bits[1] = reserved 7, 0 = No, 1 = Yes}
 * @remark this reports the disable network data (per interface)
 */
#define VE_REG_LINK_DISABLE_NETWORK_DATA 0x201A

/**
 * Link Discharge Voltage Limit (internal) {un16 = Link Discharge Voltage Limit
 * [0.01V], 0xFFFF = Not Available}
 */
#define VE_REG_LINK_DISCHARGE_VOLTAGE_LIMIT 0x201B

/**
 * Link Extra Battery Current (internal) {sn32 = Current [0.001A], 0x7FFFFFFF =
 * Not Available}
 * @remark the charge master needs the actual battery current (source adding all
 * dc currents: estimate), 60s timeout.
 * if @ref VE_REG_LINK_BATTERY_CURRENT is present in the system this information
 * will be used instead. if this
 * information is not available ve.can the units collect all @ref
 * VE_REG_DC_CHANNEL1_CURRENT data and add
 * @ref VE_REG_LINK_EXTRA_BATTERY_CURRENT to this for the dc currents that are
 * not directly visible (vedirect/vebus).
 */
#define VE_REG_LINK_EXTRA_BATTERY_CURRENT 0x201C

/**
 * Link System Yield (internal) {un32 = Link System Yield [0.01kWh], 0xFFFFFFFF =
 * Not Available}
 */
#define VE_REG_LINK_SYSTEM_YIELD 0x2020

/**
 * Link User Yield (internal) {un32 = Link User Yield [0.01kWh], 0xFFFFFFFF = Not
 * Available}
 */
#define VE_REG_LINK_USER_YIELD 0x2021

/**
 * Link Yield Today (internal) {un32 = Link Yield Today [0.01kWh], 0xFFFFFFFF =
 * Not Available}
 */
#define VE_REG_LINK_TODAY_YIELD 0x2022

/**
 * Link Maximum Power Today (internal) {un16 = Link Maximum Power Today [1W],
 * 0xFFFF = Not Available}
 */
#define VE_REG_LINK_TODAY_PMAX 0x2023

/**
 * Link Yield Yesterday (internal) {un32 = Link Yield Yesterday [0.01kWh],
 * 0xFFFFFFFF = Not Available}
 */
#define VE_REG_LINK_YESTERDAY_YIELD 0x2024

/**
 * Link Maximum Power Yesterday (internal) {un16 = Link Maximum Power Yesterday
 * [1W], 0xFFFF = Not Available}
 */
#define VE_REG_LINK_YESTERDAY_PMAX 0x2025

/**
 * Link Actual Power (internal) {un32 = Link Actual Power [0.01W], 0xFFFFFFFF =
 * Not Available}
 */
#define VE_REG_LINK_ACTUAL_POWER 0x2026

/**
 * Link Total DC Input Power (internal) {un32 = Link Total DC Input Power
 * [0.01W], 0xFFFFFFFF = Not Available}
 */
#define VE_REG_LINK_TOTAL_DC_INPUT_POWER 0x2027

/**
 * Link RTC Solar (internal) {un8 = Link RTC Solar, 0x00 = Night, 0x01 = Day,
 * 0xFF = Not Available}
 */
#define VE_REG_LINK_RTC_SOLAR 0x2030

/**
 * Link RTC Time (internal) {un16 = Link RTC Time [1minutes], 0xFFFF = Not
 * Available, valid range 0..1440 (starting at midnight)}
 */
#define VE_REG_LINK_RTC_TIME 0x2031

/**
 * Link SYNC Timebase (debug) (internal) {un32 = T}
 * @remark only models that support sync over CAN use this information
 */
#define VE_REG_LINK_SYNC_TIMEBASE 0x2032

/** Link SYNC Period (debug) (internal) {un32 = T} */
#define VE_REG_LINK_SYNC_PERIOD 0x2033

/** Link SYNC Phase (debug) (internal) {un32 = T} */
#define VE_REG_LINK_SYNC_PHASE 0x2034

/** Link CHECK Timebase (debug) (internal) {un32 = T} */
#define VE_REG_LINK_CHECK_TIMEBASE 0x2035

/** Link CHECK Period (debug) (internal) {un32 = T} */
#define VE_REG_LINK_CHECK_PERIOD 0x2036

/** Link CHECK Phase (debug) (internal) {un32 = T} */
#define VE_REG_LINK_CHECK_PHASE 0x2037

/** Link SLAVE sync on off (internal) {un32 = T} */
#define VE_REG_LINK_SLAVE_SYNC_ONOFF 0x2038

/** Link SYNC_TIMESTAMP (internal) {un32 = T} */
#define VE_REG_LINK_SYNC_TIMESTAMP 0x2039

/** Link SYNC TIMESTART (internal) {un32 = T} */
#define VE_REG_LINK_SYNC_TIMESTART 0x203A

/** Link FREE PERIOD (internal) {un16 = T} */
#define VE_REG_LINK_FREE_PERIOD 0x203B

/**
 * Link Sync Flags (internal) {un32 = flags}
 * @remark only models that support sync over can have this information
 */
#define VE_REG_LINK_SYNC_FLAGS 0x203F

/**
 * Link Sync Priority (internal) {un8 = priority, 20 =
 * VE_SYNC_PRIORITY_INVERTER_WITHOUT_ACIN, 40 =
 * VE_SYNC_PRIORITY_INVERTER_WITH_ACIN, 60 = VE_SYNC_PRIORITY_TRANSFER_SWITCH,
 * 0xFE = VE_SYNC_PRIORITY_RESERVED, 0xFF = VE_SYNC_PRIORITY_NOT_SET}
 * @remark only models that support sync over can have this information
 */
#define VE_REG_LINK_SYNC_PRIORITY 0x2040

/**
 * Link Sync Status (internal) {un32 = status}
 * @remark only models that support sync over can have this information
 */
#define VE_REG_LINK_SYNC_STATUS 0x2041

/**
 * Link Absorption End Time (internal) {un16 = Time [0.01hours], 0xFFFF = Not
 * Available}
 * @remark This is the absorption end time based on either 20*Tbulk (adaptive),
 * battery idle voltage (MPPT) or VE_REG_BAT_ABS_T_LIMIT (fixed) and limited by
 * VE_REG_BAT_ABS_T_LIMIT.
 * Only the charge master broadcasts this, share this from the master to the
 * slaves, slaves have 60s timeout
 */
#define VE_REG_LINK_ABSORPTION_END_TIME 0x2042

/**
 * Device instance {un8 = Instance}
 * @remark HEX protocol only (data present in regular NMEA pgn)
 */
#define VE_REG_DEVICE_INSTANCE 0x0105

/**
 * Device class {un8 = Class (see xml for meanings) : un8 = Function}
 * @remark HEX protocol only (data present in regular NMEA pgn)
 */
#define VE_REG_DEVICE_CLASS 0x0106

/**
 * UCN {un32 = UCN}
 * UCN - Universal Control Number
 */
#define VE_REG_UCN 0x0107

/**
 * System instance {un8 = Instance}
 * @remark HEX protocol only (data present in regular NMEA pgn)
 */
#define VE_REG_SYSTEM_INSTANCE 0x0109

/**
 * Serial number {stringZeroEnded[32] = Serial : un8 = padding, 0 = 0x00 padding,
 * 0xFF = 0xFF padding}
 */
#define VE_REG_SERIAL_NUMBER 0x010A

/** Model name {stringZeroEnded[64] = Model : un8 = padding, 0 = zeropadding} */
#define VE_REG_MODEL_NAME 0x010B

/** Description 1 {stringZeroEnded[64] = Serial : un8 = padding, 0 = zeropadding} */
#define VE_REG_DESCRIPTION1 0x010C

/** Description 2 {stringZeroEnded[64] = Serial : un8 = padding, 0 = zeropadding} */
#define VE_REG_DESCRIPTION2 0x010D

/** Build timestamp {stringZeroEnded[32] = build : un8 = padding, 0 = zeropadding} */
#define VE_REG_BUILD_TIMESTAMP 0x010F

/**
 * Signals that there is an update available {un16 = Flags, bit 0 isAvailable
 * Whether an update is available bit 1 isMandatory Whether the update is
 * mandatory before the product can be used bit 2 . . 15 Reserved : un32 =
 * FromVersion The app version the product now has : un32 = ToVersion, The app
 * version of the new firmware}
 */
#define VE_REG_UPDATE_AVAILABLE 0x0018

/** Update progress {un8 = progress percentage [1%]} */
#define VE_REG_UPDATE_PROGRESS 0x0019

/** Start available update */
#define VE_REG_UPDATE_START_AVAILABLE 0x001A

/**
 * Connect {un8 = child device : un8 = request, 0 = Disconnect, 1 = Connect}
 * Connect to child device, mainly used for SW interface
 */
#define VE_REG_CONNECT 0x0060

/** (internal) */
#define VE_REG_LAST_MESSAGE 0xEC00

/** (internal) */
#define VE_REG_HSDS 0xEC01

/** (internal) */
#define VE_REG_VER 0xEC02

/** (internal) */
#define VE_REG_PROD 0xEC03

/** (internal) */
#define VE_REG_BMV 0xEC04

/** Synchronized {un8 = Synchronized, 0 = not synced, 1 = synced} */
#define VE_REG_BMV_SYNCHRONIZED 0xEEB6

/**
 * Monitoring mode. {sn16 = Monitoring mode. (see xml for meanings)}
 * Mode used to determine support for battery related measurements (charged
 * energy, time-to-go, charge cycles etc)
 */
#define VE_REG_BMV_MONITOR_MODE 0xEEB8

/**
 * Consumed Ah {sn32 = Consumed Ah [0.1Ah]}
 * @deprecated Use VE_REG_CONSUMED_AH instead
 */
#define VE_REG_BMV_CE 0xEEFF

/**
 * @remark The next block is only used for the tester LCD memory (internal)
 * {stringFixed[14] = @remark The next block is only used for the tester LCD
 * memory}
 */
#define VE_REG_BMV_TST_LCD_MEM 0xEE90

/**
 * Button state 0x0004=BUTTON_SETUP, 0x0008=BUTTON_SELECT, 0x0010=BUTTON_MINUS,
 * 0x0020=BUTTON_PLUS. (internal) {un16 = Button state 0x0004=BUTTON_SETUP,
 * 0x0008=BUTTON_SELECT, 0x0010=BUTTON_MINUS, 0x0020=BUTTON_PLUS.}
 */
#define VE_REG_BMV_TST_BTN_STATE 0xEE91

/** Store calibration to flash. (internal) */
#define VE_REG_BMV_TST_STORE_CAL 0xEE92

/** Test relay (internal) {un8 = Test relay, 0 = close, 1 = open} */
#define VE_REG_BMV_TST_RELAY 0xEE93

/** Test backlight : 0-9. (internal) {un8 = Test backlight : 0-9.} */
#define VE_REG_BMV_TST_BACKLIGHT 0xEE94

/** (internal) {un8 = , 0 = off, 1 = on} */
#define VE_REG_BMV_TST_BUZZER 0xEE95

/** Test clock : counts. (internal) {un16 = Test clock : counts.} */
#define VE_REG_BMV_TST_CLOCK 0xEE96

/**
 * Tester get input . 0:off; 1:on (internal) {un16 = Tester get input . 0:off;
 * 1:on}
 */
#define VE_REG_BMV_TST_INPUT 0xEE97

/**
 * Tester get output . 0:off; 1:on (internal) {un16 = Tester get output . 0:off;
 * 1:on}
 */
#define VE_REG_BMV_TST_OUTPUT 0xEE98

/**
 * @remark The next block is only used for the tester ADC voltage counts
 * (internal) {Float = @remark The next block is only used for the tester ADC
 * voltage counts}
 */
#define VE_REG_BMV_ADC_VOLTAGE_COUNTS 0xEEA0

/** ADC auxiliary voltage counts (internal) {Float = ADC auxiliary voltage counts} */
#define VE_REG_BMV_ADC_AUX_VOLTAGE_COUNTS 0xEEA1

/** ADC current counts (internal) {Float = ADC current counts} */
#define VE_REG_BMV_ADC_CURRENT_COUNTS 0xEEA2

/**
 * @remark The next block is only used for the tester Voltage (internal) {Float =
 * @remark The next block is only used for the tester Voltage [V]}
 */
#define VE_REG_BMV_VOLTAGE 0xEEB0

/** Auxiliary voltage (internal) {Float = Auxiliary voltage [V]} */
#define VE_REG_BMV_AUX_VOLTAGE 0xEEB1

/** Current (internal) {Float = Current [A]} */
#define VE_REG_BMV_CURRENT 0xEEB2

/** Consumed AH (internal) {Float = Consumed AH [Ah]} */
#define VE_REG_BMV_CAH 0xEEB3

/** SOC (internal) {Float = SOC [%]} */
#define VE_REG_BMV_SOC 0xEEB4

/**
 * TTG (internal) {Float = TTG}
 * The max float value indicates an infite ttg
 */
#define VE_REG_BMV_TTG 0xEEB5

/** Temperature in Fahrenheit. (internal) {Float = Temperature in Fahrenheit.} */
#define VE_REG_BMV_TEMPERATURE 0xEEB7

/**
 * @remark The next block is only used for the tester Voltage offset (internal)
 * {Float = @remark The next block is only used for the tester Voltage offset}
 */
#define VE_REG_BMV_CAL2_VOLTAGE_OFFSET 0xEEC0

/** Voltage gain (internal) {Float = Voltage gain} */
#define VE_REG_BMV_CAL2_VOLTAGE_GAIN 0xEEC1

/** Voltage2 offset (internal) {Float = Voltage2 offset} */
#define VE_REG_BMV_CAL2_VOLTAGE_2_OFFSET 0xEEC2

/** Voltage2 gain (internal) {Float = Voltage2 gain} */
#define VE_REG_BMV_CAL2_VOLTAGE_2_GAIN 0xEEC3

/** Current offset (internal) {Float = Current offset} */
#define VE_REG_BMV_CAL2_CURRENT_OFFSET 0xEEC4

/** Current gain (internal) {Float = Current gain} */
#define VE_REG_BMV_CAL2_CURRENT_GAIN 0xEEC5

/**
 * Calibrated fields : calibrated if LSB is 0. (internal) {un16 = Calibrated
 * fields : calibrated if LSB is 0.}
 */
#define VE_REG_BMV_CAL2_CALIBRATED 0xEEC6

/** Serial number (internal) {stringFixed[32] = Serial number} */
#define VE_REG_BMV_CAL2_SERIAL 0xEEC7

/**
 * @remark The next block is only used for the tester Voltage offset (internal)
 * {Float = @remark The next block is only used for the tester Voltage offset}
 */
#define VE_REG_BMV_CAL_VOLTAGE_OFFSET 0xEED0

/** Voltage gain (internal) {Float = Voltage gain} */
#define VE_REG_BMV_CAL_VOLTAGE_GAIN 0xEED1

/** Voltage2 offset (internal) {Float = Voltage2 offset} */
#define VE_REG_BMV_CAL_VOLTAGE_2_OFFSET 0xEED2

/** Voltage2 gain (internal) {Float = Voltage2 gain} */
#define VE_REG_BMV_CAL_VOLTAGE_2_GAIN 0xEED3

/** Current offset (internal) {Float = Current offset} */
#define VE_REG_BMV_CAL_CURRENT_OFFSET 0xEED4

/** Current gain (internal) {Float = Current gain} */
#define VE_REG_BMV_CAL_CURRENT_GAIN 0xEED5

/**
 * Calibrated fields : calibrated if LSB is 0. (internal) {un16 = Calibrated
 * fields : calibrated if LSB is 0.}
 */
#define VE_REG_BMV_CAL_CALIBRATED 0xEED6

/**
 * Show voltage in status menu (internal) {un8 = Show voltage in status menu, 0 =
 * no, 1 = yes}
 */
#define VE_REG_BMV_SHOW_VOLTAGE 0xEEE0

/**
 * Show auxiliairy voltage in status menu (internal) {un8 = Show auxiliairy
 * voltage in status menu, 0 = no, 1 = yes}
 */
#define VE_REG_BMV_SHOW_AUX_VOLTAGE 0xEEE1

/**
 * Show mid voltage in status menu (internal) {un8 = Show mid voltage in status
 * menu, 0 = no, 1 = yes}
 */
#define VE_REG_BMV_SHOW_MID_VOLTAGE 0xEEE2

/**
 * Show current in status menu (internal) {un8 = Show current in status menu, 0 =
 * no, 1 = yes}
 */
#define VE_REG_BMV_SHOW_CURRENT 0xEEE3

/**
 * Show AH in status menu (internal) {un8 = Show AH in status menu, 0 = no, 1 =
 * yes}
 */
#define VE_REG_BMV_SHOW_AH 0xEEE4

/**
 * Show SOC in status menu. (internal) {un8 = Show SOC in status menu., 0 = no, 1
 * = yes}
 */
#define VE_REG_BMV_SHOW_SOC 0xEEE5

/**
 * Show TTG in status menu (internal) {un8 = Show TTG in status menu, 0 = no, 1 =
 * yes}
 */
#define VE_REG_BMV_SHOW_TTG 0xEEE6

/**
 * Show temperature in status menu (internal) {un8 = Show temperature in status
 * menu, 0 = no, 1 = yes}
 */
#define VE_REG_BMV_SHOW_TEMPERATURE 0xEEE7

/**
 * Show power in status menu (internal) {un8 = Show power in status menu, 0 = no,
 * 1 = yes}
 */
#define VE_REG_BMV_SHOW_POWER 0xEEE8

/**
 * Temperature coefficient (internal) {un16 = Temperature coefficient}
 * Temperature compensation for battery capacity in 0.1CAP.
 */
#define VE_REG_BMV_TEMPERATURE_COEFFICIENT 0xEEF4

/** Scroll speed (internal) {un8 = Scroll speed (see xml for meanings)} */
#define VE_REG_BMV_SCROLL_SPEED 0xEEF5

/** Lock setup (internal) {un8 = Lock setup, 0 = unlocked, 1 = locked} */
#define VE_REG_BMV_SETUP_LOCK 0xEEF6

/**
 * Temperature unit (internal) {un8 = Temperature unit, 0 = Celcius, 1 =
 * Fahrenheit}
 */
#define VE_REG_BMV_TEMPERATURE_UNIT 0xEEF7

/**
 * Auxiliairy input mode (internal) {un8 = Auxiliairy input mode, 0 = aux, 1 =
 * mid, 2 = temperature, 3 = none}
 */
#define VE_REG_BMV_AUX_INPUT 0xEEF8

/** Software version (internal) {un16 = Software version} */
#define VE_REG_BMV_SW_VERSION 0xEEF9

/** Shunt max voltage (internal) {un16 = Shunt max voltage [0.001V]} */
#define VE_REG_BMV_SHUNT_VOLTS 0xEEFA

/** Shunt max current (internal) {un16 = Shunt max current [1A]} */
#define VE_REG_BMV_SHUNT_AMPS 0xEEFB

/**
 * Sound buzzer when alarm active (internal) {un8 = Sound buzzer when alarm
 * active, 0 = off, 1 = on}
 */
#define VE_REG_BMV_ALARM_BUZZER_ON 0xEEFC

/** Backlight intensity : 0-9 (internal) {un8 = Backlight intensity : 0-9} */
#define VE_REG_BMV_BACKLIGHT 0xEEFE

/**
 * First-use settings-setup status flags (internal) {bits[1] = Setup Is Active, 0
 * = No, 1 = Yes : bits[15] = Setup progress flags, 0 = No, 1 = Yes, Each bit
 * indicates whether the setup of an individual setting is active, 0 = No, 1 =
 * Yes. Which setting it represents is device/application specific. Using the
 * setup progress field is optional. Unused bits should be set to 0.}
 */
#define VE_REG_FIRST_USE_SETUP 0xEF00

/** Tester raw ADC value {un16 = raw adc value} */
#define VE_REG_TST_ADC_GET_RAW 0xEEE0

/** {un8 = freq, 0x00 = 60HZ, 0x01 = 50HZ, 0xFF = Not Available} */
#define VE_REG_INV_WAVE_SET50HZ_NOT60HZ 0xEB03

/** typeNvmCommand {un8 = typeNvmCommand (see xml for meanings)} */
#define VE_REG_INV_NVM_COMMAND 0xEB99

/**
 * Inverter Dynamic-cutoff Factor 5 (mV) {un16 = Voltage [0.001V], 0xFFFF = Not
 * Available}
 */
#define VE_REG_INV_PROT_UBAT_DYN_CUTOFF_FACTOR5 0xEBB2

/**
 * Inverter Dynamic-cutoff Factor 250 (mV) {un16 = Voltage [0.001V], 0xFFFF = Not
 * Available}
 */
#define VE_REG_INV_PROT_UBAT_DYN_CUTOFF_FACTOR250 0xEBB3

/** un16 mV {un16 = Voltage [0.001V], 0xFFFF = Not Available} */
#define VE_REG_INV_PROT_UBAT_DYN_CUTOFF_FACTOR700 0xEBB4

/**
 * Inverter Dynamic-cutoff Factor (mV) {un16 = Voltage [0.001V], 0xFFFF = Not
 * Available}
 */
#define VE_REG_INV_PROT_UBAT_DYN_CUTOFF_FACTOR2000 0xEBB5

/**
 * Inv prot ubat dyn cutoff enable {un8 = Inv prot ubat dyn cutoff enable, 0 =
 * Off, 1 = On}
 */
#define VE_REG_INV_PROT_UBAT_DYN_CUTOFF_ENABLE 0xEBBA

/**
 * typeOperatingMode tester (internal) {un8 = typeOperatingMode tester (see xml
 * for meanings)}
 * The Mode is controlled by user-control via HW(GPIO)switch and remote switch or
 * register VE_REG_DEVICE_MODE. The Tester can overrule all the user inputs
 * (ModeMaskSW)
 */
#define VE_REG_INV_OPER_OPERATING_MODE 0xEB00

/**
 * typeOperState readonly (internal) {un8 = typeOperState readonly}
 * Current operation mode state. The FSM is controlled by user Mode, the Load
 * (Eco) and Protection status
 */
#define VE_REG_INV_OPER_GET_STATE 0xEB01

/** (internal) {un16 = data} */
#define VE_REG_INV_MOD_GET_WAVE_AMPLITUDE 0xEB02

/** (internal) {un16 = data} */
#define VE_REG_INV_OPER_ECO_MODE_IINV_MIN 0xEB04

/** (internal) {un8 = data} */
#define VE_REG_INV_OPER_ECO_MODE_IS_IINV_COUNT 0xEB05

/** (internal) {un8 = data [0.25s]} */
#define VE_REG_INV_OPER_ECO_MODE_RETRY_TIME 0xEB06

/** (internal) {un16 = data, tester} */
#define VE_REG_INV_MOD_FAST_IPEAK 0xEB07

/** typeProtState readonly (internal) {un16 = data} */
#define VE_REG_INV_PROT_GET_STATE 0xEB08

/** (internal) {un16 = data, tester} */
#define VE_REG_INV_MOD_FAST_UPEAK 0xEB09

/** (internal) {un16 = data [1s]} */
#define VE_REG_INV_OPER_ECO_MODE_RETRY_TIME_SEC 0xEB0A

/**
 * (internal) {un8 = }
 * Duration of a load detect pulse in number of AC-out periods
 */
#define VE_REG_INV_OPER_ECO_LOAD_DETECT_PERIODS 0xEB10

/**
 * (internal) {sn16 = data}
 * actual number of events during last sine period
 */
#define VE_REG_INV_PROT_GET_IPEAK_LOWLEVEL_COUNT 0xEB11

/**
 * (internal) {sn16 = data}
 * 0.01 deg
 */
#define VE_REG_INV_ADC_REFERENCE_PHASE_60HZ_OFFSET 0xEB12

/**
 * (internal) {sn16 = data}
 * 0.01 deg
 */
#define VE_REG_INV_LOOP_LOAD_PHASE_OFFSET_60HZ_OFFSET 0xEB13

/** (internal) {un16 = data} */
#define VE_REG_INV_LOOP_COMPENSATE_ROUT_GIN_60HZ_GAIN 0xEB14

/**
 * (internal) {sn16 = data}
 * 0.01 deg
 */
#define VE_REG_INV_LOOP_COMPENSATE_ROUT_GIN_PHASE_60HZ_OFFSET 0xEB15

/**
 * (internal) {sn16 = data}
 * 0.01 deg
 */
#define VE_REG_INV_LOOP_VOLTAGE_DROP_RLV_PHASE 0xEB16

/**
 * (internal) {sn16 = data}
 * 0x4000 is nom.
 */
#define VE_REG_INV_LOOP_GET_LOAD_VOLTAGE 0xEB17

/**
 * (internal) {sn16 = data}
 * 0.01 deg
 */
#define VE_REG_INV_LOOP_GET_LOAD_VOLTAGE_PHASE 0xEB18

/**
 * (internal) {un16 =  [0.001A]}
 * mA
 */
#define VE_REG_INV_LOOP_IINV_MAX_THRESHOLD 0xEB19

/**
 * (internal) {un16 =  [0.001A]}
 * mA
 */
#define VE_REG_INV_LOOP_IINV_MAX_ROUT 0xEB1A

/** (internal) {un16 = data} */
#define VE_REG_INV_ADC_UINV_RAW 0xEB20

/** (internal) {un16 = data} */
#define VE_REG_INV_ADC_IINV_RAW 0xEB21

/** (internal) {un16 = data} */
#define VE_REG_INV_ADC_UBAT_RAW 0xEB22

/** (internal) {un16 = data} */
#define VE_REG_INV_ADC_UTRANSF_RAW 0xEB23

/** (internal) {un16 = data} */
#define VE_REG_INV_ADC_UTEMP_FET_RAW 0xEB24

/** (internal) {un16 = data} */
#define VE_REG_INV_ADC_UTEMP_MICRO_RAW 0xEB25

/** (internal) {un16 = data} */
#define VE_REG_INV_ADC_UPOTMETER_RAW 0xEB26

/** (internal) {un16 = data} */
#define VE_REG_INV_ADC_XRAW 0xEB27

/** (internal) {un16 = data} */
#define VE_REG_INV_ADC_UINV 0xEB28

/** (internal) {un16 = data} */
#define VE_REG_INV_ADC_IINV 0xEB29

/** (internal) {un16 = data} */
#define VE_REG_INV_ADC_UBAT 0xEB2A

/** (internal) {un16 = data} */
#define VE_REG_INV_ADC_UTEMP_TRANSF 0xEB2B

/** (internal) {un16 = data} */
#define VE_REG_INV_ADC_UTEMP_FET 0xEB2C

/** (internal) {un16 = data} */
#define VE_REG_INV_ADC_UTEMP_MICRO 0xEB2D

/** (internal) {un16 = data} */
#define VE_REG_INV_ADC_UPOTMETER 0xEB2E

/** (internal) {un16 = data} */
#define VE_REG_INV_ADC_UINV_MEAN 0xEB30

/** (internal) {un16 = data} */
#define VE_REG_INV_ADC_IINV_MEAN 0xEB31

/** (internal) {un16 = data} */
#define VE_REG_INV_ADC_UBAT_MEAN 0xEB32

/** (internal) {sn32 = data} */
#define VE_REG_INV_ADC_PINV_MEAN 0xEB33

/** (internal) {un16 = data} */
#define VE_REG_INV_ADC_UREF_ADC 0xEB39

/** un32 readonly (internal) {un32 = data} */
#define VE_REG_INV_ADC_UINV_RMS 0xEB3A

/** un32 readonly (internal) {un32 = data} */
#define VE_REG_INV_ADC_IINV_RMS 0xEB3B

/** un32 readonly (internal) {un32 = data} */
#define VE_REG_INV_ADC_UBAT_RMS 0xEB3C

/** (internal) {sn16 = Temperature [0.1°C], 0x7FFF = Not Available} */
#define VE_REG_INV_ADC_TEMP_TRANSF_D_C 0xEB3D

/** (internal) {sn16 = Temperature [0.1°C], 0x7FFF = Not Available} */
#define VE_REG_INV_ADC_TEMP_FET_D_C 0xEB3E

/** (internal) {sn16 = Temperature [0.1°C], 0x7FFF = Not Available} */
#define VE_REG_INV_ADC_TEMP_MICRO_D_C 0xEB3F

/** typeLoop tester (internal) {un16 = typeLoop tester (see xml for meanings)} */
#define VE_REG_INV_LOOP_OPTIONS 0xEB40

/** tester (internal) {un16 = data} */
#define VE_REG_INV_LOOP_NULL_AMPLITUDE 0xEB41

/** tester (internal) {un16 = data} */
#define VE_REG_INV_MOD_PHASEBEAT_PERIOD 0xEB42

/** tester (internal) {un16 = data} */
#define VE_REG_INV_LOOP_ERROR_GAIN 0xEB43

/** tester (internal) {un16 = data} */
#define VE_REG_INV_LOOP60HZ_COMPENSATION_RATIO 0xEB44

/** tester (internal) {un16 = data} */
#define VE_REG_INV_LOOP_UINV_REFERENCE 0xEB45

/** (internal) {sn32 = data [0.001V]} */
#define VE_REG_INV_LOOP_GET_UOUT 0xEB46

/** (internal) {un16 = data} */
#define VE_REG_INV_LOOP_TEMP_COMPENSATION 0xEB47

/** (internal) {un8 = data} */
#define VE_REG_INV_PROT_GET_IPEAK_LOWLEVEL_EVENT 0xEB48

/** (internal) {un8 = data} */
#define VE_REG_INV_PROT_GET_IPEAK_HIGHLEVEL_EVENT 0xEB49

/** (internal) {un8 = data} */
#define VE_REG_INV_PROT_GET_UPEAK_EVENT 0xEB4A

/** tester (internal) {un16 = data} */
#define VE_REG_INV_LOOP_UBAT_REFERENCE 0xEB4B

/** (internal) {sn16 = data} */
#define VE_REG_INV_LOOP_GET_ERROR 0xEB4C

/** (internal) {un16 = data} */
#define VE_REG_INV_LOOP_GET_ERROR_INTEGRATED 0xEB4D

/** (internal) {sn16 = data} */
#define VE_REG_INV_LOOP_GET_IINV 0xEB4E

/** tester (internal) {un16 = data} */
#define VE_REG_INV_LOOP_COMPENSATE_ROUT_GIN 0xEB4F

/** tester (internal) {un16 = data} */
#define VE_REG_INV_LOOP_AMPLITUDE_CLAMP 0xEB50

/** tester (internal) {un16 = data} */
#define VE_REG_INV_LOOP_COMPUTE_IINV_GIN 0xEB51

/**
 * typeProtections tester (internal) {un16 = typeProtections tester (see xml for
 * meanings)}
 * undefined bits are set by default hence new protections will be enabled
 */
#define VE_REG_INV_PROT_ENABLE_MASK 0xEB52

/** (internal) {sn8 = data} */
#define VE_REG_INV_PROT_GET_ACTIVE_LEVEL 0xEB53

/** (internal) {sn8 = data} */
#define VE_REG_INV_PROT_GET_HICKUP_COUNT 0xEB54

/**
 * typeProtWhat readonly (internal) {sn8 = typeProtWhat readonly (see xml for
 * meanings)}
 */
#define VE_REG_INV_PROT_GET_ACTIVE_ALARM 0xEB55

/** sn8 readonly (internal) {sn8 = data} */
#define VE_REG_INV_PROT_GET_UINV_STATUS 0xEB56

/** sn8 readonly (internal) {sn8 = data} */
#define VE_REG_INV_PROT_GET_IINV_STATUS 0xEB57

/** sn8 readonly (internal) {sn8 = data} */
#define VE_REG_INV_PROT_GET_UBAT_STATUS 0xEB58

/** sn8 readonly (internal) {sn8 = data} */
#define VE_REG_INV_PROT_GET_TEMP_STATUS 0xEB59

/** sn8 readonly (internal) {sn8 = data} */
#define VE_REG_INV_PROT_GET_IPEAK_COUNT_STATUS 0xEB5A

/** sn8 readonly (internal) {sn8 = data} */
#define VE_REG_INV_PROT_GET_UBAT_RIPPLE_STATUS 0xEB5B

/** typeProtections tester (internal) {un16 = typeProtections tester} */
#define VE_REG_INV_PROT_ENABLE_HICKUP 0xEB5C

/** typeProtections (internal) {un16 = typeProtections} */
#define VE_REG_INV_PROT_ENABLE_WAIT4EVER 0xEB5D

/** tester (internal) {un8 = data} */
#define VE_REG_INV_PROT_HICKUP_ATTEMPT_COUNT 0xEB5E

/** tester (internal) {un16 = data} */
#define VE_REG_INV_PROT_HICKUP_RESTART_DELAY 0xEB5F

/** tester (internal) {un16 = data} */
#define VE_REG_INV_PROT_HICKUP_TIME_OUT 0xEB60

/**
 * typeGpioAlarmLed readonly (internal) {un8 = typeGpioAlarmLed readonly}
 *  An enum, also for each state a blinking pattern is defined
 */
#define VE_REG_INV_GPIO_ALARM_LED_STATE 0xEB61

/** tester (internal) {un16 = data} */
#define VE_REG_INV_PROT_UINV_LEVEL_LOW 0xEB62

/** tester (internal) {un16 = data} */
#define VE_REG_INV_PROT_UINV_IS_LOW_COUNT 0xEB63

/** tester (internal) {un16 = data} */
#define VE_REG_INV_PROT_IINV_LEVEL_WARNING_HIGH 0xEB64

/** tester (internal) {un16 = data} */
#define VE_REG_INV_PROT_IINV_IS_WARNING_HIGH_COUNT 0xEB65

/** tester (internal) {un16 = data} */
#define VE_REG_INV_PROT_IINV_LEVEL_HIGH 0xEB66

/** tester (internal) {un16 = data} */
#define VE_REG_INV_PROT_IINV_IS_HIGH_TIMEOUT 0xEB67

/** tester (internal) {un16 = data} */
#define VE_REG_INV_PROT_UBAT_LEVEL_HIGH 0xEB68

/** tester (internal) {un16 = data} */
#define VE_REG_INV_PROT_UBAT_IS_HIGH_COUNT 0xEB69

/** (internal) {un16 = data} */
#define VE_REG_INV_PROT_UBAT_LEVEL_WARNING_LOW 0xEB6A

/** tester (internal) {un16 = data} */
#define VE_REG_INV_PROT_UBAT_IS_WARNING_LOW_COUNT 0xEB6B

/** (internal) {un16 = data} */
#define VE_REG_INV_PROT_UBAT_LEVEL_LOW 0xEB6C

/** tester (internal) {un16 = data} */
#define VE_REG_INV_PROT_UBAT_IS_LOW_COUNT 0xEB6D

/** tester (internal) {un16 = data} */
#define VE_REG_INV_PROT_UBAT_LEVEL2LOW 0xEB6E

/** tester (internal) {un8 = data} */
#define VE_REG_INV_PROT_TEMP_FET_WARNING_HIGH_C 0xEB6F

/** tester (internal) {un8 = data} */
#define VE_REG_INV_PROT_TEMP_FET2HIGH_C 0xEB70

/** tester (internal) {un8 = data} */
#define VE_REG_INV_PROT_IPEAK_LOW_LEVEL_INCREMENT 0xEB72

/** tester (internal) {un16 = data} */
#define VE_REG_INV_PROT_IPEAK_HIGH_LEVEL_INCREMENT 0xEB73

/** tester (internal) {un8 = data} */
#define VE_REG_INV_PROT_IPEAK_DECREMENT 0xEB74

/** tester (internal) {un16 = data} */
#define VE_REG_INV_PROT_IPEAK_COUNT 0xEB75

/** tester (internal) {un16 = data} */
#define VE_REG_INV_PROT_UBAT_RIPPLE_LEVEL_HIGH 0xEB76

/** tester (internal) {un16 = data} */
#define VE_REG_INV_PROT_UBAT_RIPPLE_IS_HIGH_COUNT 0xEB77

/** tester (internal) {un16 = data} */
#define VE_REG_INV_PROT_UBAT_RIPPLE_LEVEL2HIGH 0xEB78

/** tester (internal) {un16 = data} */
#define VE_REG_INV_PROT_UBAT_RIPPLE_IS2HIGH_COUNT 0xEB79

/** tester (internal) {un8 = data} */
#define VE_REG_INV_PROT_TEMP_TRANS_WARNING_HIGH_C 0xEB7A

/** tester (internal) {un8 = data} */
#define VE_REG_INV_PROT_TEMP_TRANS2HIGH_C 0xEB7B

/** (internal) {un16 = data} */
#define VE_REG_INV_PROT_UBAT_LEVEL_WARNING_LOW_CLEAR 0xEB7C

/** tester (internal) {un16 = data} */
#define VE_REG_INV_PROT_FAULT_RESTART_TIMEOUT 0xEB7D

/** tester (internal) {un16 = data} */
#define VE_REG_INV_LOOP_NULL_AMPLITUDE_V117 0xEB7E

/** tester (internal) {un16 = data} */
#define VE_REG_INV_ADC_UINV_GAIN 0xEB80

/** tester (internal) {un16 = data} */
#define VE_REG_INV_ADC_IINV_GAIN 0xEB81

/** tester (internal) {un16 = data} */
#define VE_REG_INV_ADC_UBAT_GAIN 0xEB82

/** tester (internal) {un16 = data} */
#define VE_REG_INV_ADC_UTEMP_TRANSF_GAIN 0xEB83

/** tester (internal) {un16 = data} */
#define VE_REG_INV_ADC_UTEMP_FET_GAIN 0xEB84

/** tester (internal) {sn16 = data} */
#define VE_REG_INV_ADC_UINV_OFFSET 0xEB88

/** tester (internal) {sn16 = data} */
#define VE_REG_INV_ADC_IINV_OFFSET 0xEB89

/** tester (internal) {sn16 = data} */
#define VE_REG_INV_ADC_UBAT_OFFSET 0xEB8A

/** tester (internal) {sn16 = data} */
#define VE_REG_INV_ADC_UTEMP_TRANS_OFFSET 0xEB8B

/** tester (internal) {sn16 = data} */
#define VE_REG_INV_ADC_UTEMP_FET_OFFSET 0xEB8C

/** tester (internal) {un16 = data} */
#define VE_REG_INV_PWM_DEBUG2 0xEB91

/** tester (internal) {un8 = data} */
#define VE_REG_INV_SER_TEXT_FRAME_PERIOD 0xEB92

/** tester (internal) {un16 = data} */
#define VE_REG_INV_PROT_UINV_LEVEL_HIGH_AT_START_UP 0xEB93

/** TFSSpaceDebug (internal) {un16 = data} */
#define VE_REG_INV_TFS_SPACE_LEFT 0xEB94

/** NvmPaygoDummy (internal) {un8 = data} */
#define VE_REG_INV_NVM_PAYGO_DUMMY 0xEB95

/** NVMHistoryDummy (internal) {un8 = data} */
#define VE_REG_INV_NVM_HISTORY_DUMMY 0xEB96

/**
 * minimal compatible fw version number for current nvm settings page (internal)
 * {un16 = data}
 */
#define VE_REG_INV_NVM_MIN_VERSION 0xEB97

/** serial number of active settings map, +1 each save (internal) {un16 = data} */
#define VE_REG_INV_NVM_SERIAL 0xEB98

/** Read all settings (internal) {un32 = data} */
#define VE_REG_INV_NVM_READ_PAGE 0xEB9A

/**
 * typeFanMode tester (internal) {un8 = typeFanMode tester, 0 = Set: Fan in Auto
 * mode(bit 1=0) Get: fan is OFF, 1 = Set: Fan in Auto mode(bit 1=0) Get: fan is
 * ON, 2 = Set Fan is enforced OFF, 3 = Set Fan is enforced ON at max speed}
 */
#define VE_REG_INV_FAN_MODE 0xEBA0

/** tester (internal) {un16 = data} */
#define VE_REG_INV_FAN_SPEED_MIN 0xEBA1

/** tester (internal) {un16 = data} */
#define VE_REG_INV_FAN_SPEED_MAX 0xEBA2

/** tester (internal) {un16 = data} */
#define VE_REG_INV_FAN_SPEED_PITCH 0xEBA3

/** tester (internal) {un16 = data} */
#define VE_REG_INV_FAN_TIME_PITCH 0xEBA4

/** tester (internal) {un16 = data} */
#define VE_REG_INV_FAN_SPEED_UP 0xEBA5

/** tester (internal) {un16 = data} */
#define VE_REG_INV_FAN_SPEED_DOWN 0xEBA6

/** tester (internal) {un8 = data} */
#define VE_REG_INV_FAN_TEMP_FET_LOW 0xEBA7

/** tester (internal) {un8 = data} */
#define VE_REG_INV_FAN_TEMP_FET_HIGH 0xEBA8

/** tester (internal) {un16 = data} */
#define VE_REG_INV_FAN_IINV_LOW 0xEBA9

/** tester (internal) {un16 = data} */
#define VE_REG_INV_FAN_IINV_HIGH 0xEBAA

/** tester (internal) {un8 = data} */
#define VE_REG_INV_FAN_TEMP_AMBIENT_LOW 0xEBAB

/** tester (internal) {un8 = data} */
#define VE_REG_INV_FAN_TEMP_AMBIENT_HIGH 0xEBAC

/** tester (internal) {un16 = data} */
#define VE_REG_INV_FAN_IINV_ON_COUNT 0xEBAD

/** tester (internal) {un16 = data} */
#define VE_REG_INV_FAN_TIME_KEEP_ON 0xEBAE

/** tester (internal) {un8 = data} */
#define VE_REG_INV_FAN_TEMP_TRANSF_LOW 0xEBAF

/** tester (internal) {un8 = data} */
#define VE_REG_INV_FAN_TEMP_TRANSF_HIGH 0xEBB0

/**
 * Inverter Dynamic-cutoff Voltage (mV) (internal) {un16 = Voltage [0.001V],
 * 0xFFFF = Not Available}
 */
#define VE_REG_INV_PROT_UBAT_DYN_CUTOFF_VOLTAGE 0xEBB1

/** Inverter Dynamic-cutoff Factor (mA/C) (internal) {un16 = Factor [0.001A/C]} */
#define VE_REG_INV_PROT_UBAT_DYN_CUTOFF_FACTOR 0xEBB7

/** un8 bits (internal) {un8 = un8 bits} */
#define VE_REG_INV_PROT_UBAT_DYN_CUTOFF_FILTER_ASC 0xEBB8

/** un8 bits (internal) {un8 = un8 bits} */
#define VE_REG_INV_PROT_UBAT_DYN_CUTOFF_FILTER_DESC 0xEBB9

/**
 * Inverter Dynamic-cutoff Warning Offset (mV) (internal) {un16 = Voltage
 * [0.001V], 0xFFFF = Not Available}
 */
#define VE_REG_INV_PROT_UBAT_DYN_CUTOFF_WARNING_OFFSET 0xEBBB

/** (internal) {un16 = data} */
#define VE_REG_INV_ADC_UAUX_RAW 0xEBBC

/** tester (internal) {un16 = data} */
#define VE_REG_INV_ADC_UAUX_GAIN 0xEBBD

/** data (internal) {un16 = data} */
#define VE_REG_INV_ADC_UAUX 0xEBBE

/** data (internal) {sn16 = data} */
#define VE_REG_INV_ADC_PINV_GAIN 0xEBBF

/** (internal) {un8 =  (see xml for meanings)} */
#define VE_REG_INV_POWER_SLEEP_STATE 0xEBC0

/** (internal) {un16 = data [0.001V]} */
#define VE_REG_INV_PROT_UAUX_LEVEL2LOW 0xEBC1

/** (internal) {un16 = data} */
#define VE_REG_INV_RELAYS_STATUS 0xEBC2

/** (internal) {sn32 = data [0.001V]} */
#define VE_REG_INV_LOOP_GET_UBAT 0xEBC3

/** (internal) {un16 = data} */
#define VE_REG_INV_REMOTE_LOW_LEVEL 0xEBC4

/** (internal) {un16 = data} */
#define VE_REG_INV_REMOTE_HIGH_LEVEL 0xEBC5

/** (internal) {un16 = data} */
#define VE_REG_INV_REMOTE_LOW_HIGH_HYSTERESIS 0xEBC6

/**
 * (internal) {un8 = , 1 = bit 0 enable hibernation, 2 = bit 1 prevent
 * hibernation when fan on , 4 = bit 2 periodic wake-up for external UART supply}
 */
#define VE_REG_INV_POWER_SLEEP_OPTIONS 0xEBC7

/** (internal) {un16 = data} */
#define VE_REG_INV_LOOP_ERROR_GAIN_PROP 0xEBC8

/** (internal) {un16 = data} */
#define VE_REG_INV_LOOP_AMPLITUDE_NORM_MAX 0xEBC9

/** (internal) {un16 = data} */
#define VE_REG_INV_LOOP_AMPLITUDE_NORM_MIN 0xEBCA

/** tester (internal) {un16 = data} */
#define VE_REG_INV_LOOP60HZ_COMPENSATION_RATIO_IINV 0xEBCB

/**
 * Ac out voltage (internal) {sn32 = Voltage [0.001V], 0x7FFFFFFF = Not
 * Available}
 * DC-AC measured ac-out voltage, internaly HF-multi
 */
#define VE_REG_INV_SI_AC_OUT_VOLTAGE 0xEBCC

/**
 * Inverter alarm reason (internal) {bits[1] = Low Voltage, 0 = No, 1 = Yes, low
 * battery voltage alarm : bits[1] = High Voltage, 0 = No, 1 = Yes, high battery
 * voltage alarm : bits[1] = Low Soc, 0 = No, 1 = Yes, low State Of Charge alarm
 * : bits[1] = VE_REG_ALARM_REASON_LOW_VOLTAGE2, 0 = No, 1 = Yes, low voltage2
 * alarm : bits[1] = VE_REG_ALARM_REASON_HIGH_VOLTAGE2, 0 = No, 1 = Yes, high
 * voltage2 alarm : bits[1] = Low Temperature, 0 = No, 1 = Yes, low temperature
 * alarm (also not connected transformer NTC) : bits[1] = High Temperature, 0 =
 * No, 1 = Yes, high temperature alarm : bits[1] = Mid Voltage, 0 = No, 1 = Yes,
 * mid voltage alarm : bits[1] = Overload, 0 = No, 1 = Yes, e.g. based on Iinv^2
 * or Ipeak events count : bits[1] = Dc Ripple, 0 = No, 1 = Yes, e.g. indication
 * for poor battery connection : bits[1] = Low V Ac Out, 0 = No, 1 = Yes, e.g. in
 * case of large load and low battery : bits[1] = High V Ac Out, 0 = No, 1 = Yes,
 * e.g. typ. when connected to other "mains" source, this will prevent the
 * inverter-only to start : bits[1] = Short Circuit, 0 = No, 1 = Yes, short
 * circuit alarm : bits[1] = Bms Lockout, 0 = No, 1 = Yes, BMS Lockout alarm
 * (Used in Smart Battery Protect) : bits[1] = Bms Cable Failure, 0 = No, 1 =
 * Yes, Battery M8 BMS Cable not connected or defect (Used in Smart BMS) :
 * bits[1] = reserved 15, 0 = No, 1 = Yes}
 * DC-AC alarm reason (active protection), internaly HF-multi
 */
#define VE_REG_INV_INTERNAL_ALARM_REASON 0xEBCD

/**
 * Inverter warning reason (internal) {bits[1] = Low Voltage, 0 = No, 1 = Yes,
 * low battery voltage alarm : bits[1] = High Voltage, 0 = No, 1 = Yes, high
 * battery voltage alarm : bits[1] = Low Soc, 0 = No, 1 = Yes, low State Of
 * Charge alarm : bits[1] = VE_REG_ALARM_REASON_LOW_VOLTAGE2, 0 = No, 1 = Yes,
 * low voltage2 alarm : bits[1] = VE_REG_ALARM_REASON_HIGH_VOLTAGE2, 0 = No, 1 =
 * Yes, high voltage2 alarm : bits[1] = Low Temperature, 0 = No, 1 = Yes, low
 * temperature alarm (also not connected transformer NTC) : bits[1] = High
 * Temperature, 0 = No, 1 = Yes, high temperature alarm : bits[1] = Mid Voltage,
 * 0 = No, 1 = Yes, mid voltage alarm : bits[1] = Overload, 0 = No, 1 = Yes, e.g.
 * based on Iinv^2 or Ipeak events count : bits[1] = Dc Ripple, 0 = No, 1 = Yes,
 * e.g. indication for poor battery connection : bits[1] = Low V Ac Out, 0 = No,
 * 1 = Yes, e.g. in case of large load and low battery : bits[1] = High V Ac Out,
 * 0 = No, 1 = Yes, e.g. typ. when connected to other "mains" source, this will
 * prevent the inverter-only to start : bits[1] = Short Circuit, 0 = No, 1 = Yes,
 * short circuit alarm : bits[1] = Bms Lockout, 0 = No, 1 = Yes, BMS Lockout
 * alarm (Used in Smart Battery Protect) : bits[1] = Bms Cable Failure, 0 = No, 1
 * = Yes, Battery M8 BMS Cable not connected or defect (Used in Smart BMS) :
 * bits[1] = reserved 15, 0 = No, 1 = Yes}
 * DC-AC warning reasons(pre-alarms), internaly HF-multi
 */
#define VE_REG_INV_INTERNAL_WARNING_REASON 0xEBCE

/**
 * Inverter device state (internal) {un8 = State (see xml for meanings), Device
 * state , @see N2kConverterState}
 * DC-AC device state, internaly HF-multi
 */
#define VE_REG_INV_INTERNAL_DEVICE_STATE 0xEBCF

/**
 * Ac inverter real power (internal) {sn32 = Power [0.001W], 0x7FFFFFFF = Not
 * Available}
 * DC-AC measured real-ac inverter power, internaly HF-multi
 */
#define VE_REG_INV_SI_AC_INV_POWER 0xEBD0

/**
 * Ac inverter current (internal) {sn32 = Current [0.001A], 0x7FFFFFFF = Not
 * Available}
 * DC-AC measured ac inverter current, internaly HF-multi
 */
#define VE_REG_INV_SI_AC_INV_CURRENT 0xEBD1

/**
 * Ac inverter apparent power (internal) {sn32 = Apparent Power [0.001VA],
 * 0x7FFFFFFF = Not Available}
 * DC-AC measured apparent power, internaly HF-multi
 */
#define VE_REG_INV_SI_AC_INV_APPARENT_POWER 0xEBD2

/**
 * Inverter DC bus voltage (internal) {sn32 = DC voltage [0.001V], 0x7FFFFFFF =
 * Not Available}
 * DC-AC measured DC(Bus) voltage, internaly HF-multi
 */
#define VE_REG_INV_SI_DC_VOLTAGE 0xEBD3

/** (internal) {un16 = Time [1e-06s], 0xFFFF = Not Available} */
#define VE_REG_INV_PLL_FREE_PERIOD 0xEBD4

/**
 * Ac inverter voltage (internal) {sn32 = DC voltage [0.001V], 0x7FFFFFFF = Not
 * Available}
 * DC-AC measured DC(Bus) voltage, internaly HF-multi
 */
#define VE_REG_INV_POWER_SLEEP_DELAY 0xEBD5

/** (internal) {sn16 = data} */
#define VE_REG_INV_MOD_BALANCE_BRIDGE 0xEBD6

/**
 * (internal) {un16 = data}
 * get up/down levels of all buttons
 */
#define VE_REG_INV_BUTTON_GET_LEVELS 0xEBD7

/**
 * (internal) {sn32 = data}
 * raw product, not filtered or clamped
 */
#define VE_REG_INV_LOOP_GET_VA_PRODUCT 0xEBD8

/**
 * (internal) {sn16 = data}
 * (user-)offset for internal current calculation [1mA]
 */
#define VE_REG_INV_LOOP_IINV_OFFSET 0xEBD9

/**
 * (internal) {sn8 = data}
 * 0 = OK, 3 = PTC too hot
 */
#define VE_REG_INV_PROT_GET_DC_TERMINAL_STATUS 0xEBDA

/** (internal) {un16 = data} */
#define VE_REG_INV_ADC_UREMOTE_LOW_RAW 0xEBDB

/** (internal) {un16 = data} */
#define VE_REG_INV_ADC_UREMOTE_HIGH_RAW 0xEBDC

/**
 * (internal) {un16 = data}
 * FW version current nvmpage is saved by
 */
#define VE_REG_INV_NVM_SETTINGS_PAGE_VERSION 0xEBDD

/** (internal) {un16 = data} */
#define VE_REG_INV_LOOP60HZ_COMPENSATION_IINV_GIN 0xEBDE

/** (internal) {sn16 = data} */
#define VE_REG_INV_LOOP_VOLTAGE_DROP_RLV 0xEBDF

/**
 * (internal) {sn16 = data}
 * 0.01 deg
 */
#define VE_REG_INV_ADC_IINV_PHASE1 0xEBE0

/**
 * (internal) {sn16 = data}
 * 0.01 deg
 */
#define VE_REG_INV_ADC_UINV_PHASE1 0xEBE1

/**
 * (internal) {un16 =  [0.001A]}
 * mA
 */
#define VE_REG_INV_ADC_IINV_HARM1 0xEBE2

/**
 * (internal) {un16 = data}
 * 0x4000 is nom.
 */
#define VE_REG_INV_ADC_UINV_HARM1 0xEBE3

/**
 * (internal) {sn16 = data}
 * 0.01 deg
 */
#define VE_REG_INV_ADC_REFERENCE_PHASE1 0xEBE4

/** (internal) {un16 = data} */
#define VE_REG_INV_LOOP_COMPENSATE_HARM357 0xEBE5

/**
 * (internal) {sn16 = data}
 * 0.01 deg
 */
#define VE_REG_INV_ADC_UINV_PHASE1_OFFSET_60HZ_OFFSET 0xEBE6

/**
 * (internal) {sn16 = data}
 * 0.01 deg
 */
#define VE_REG_INV_LOOP_GET_LOAD_PHASE 0xEBE7

/**
 * (internal) {sn16 = data}
 * 0.01 deg
 */
#define VE_REG_INV_LOOP_LOAD_PHASE_OFFSET 0xEBE8

/**
 * (internal) {sn16 = data}
 * 0x4000 is nom
 */
#define VE_REG_INV_LOOP_VOLTAGE_DROP_RLV_HARM357 0xEBE9

/**
 * (internal) {un16 = data}
 * 0x4000 is nom
 */
#define VE_REG_INV_LOOP_LOAD_PHASE_THRESHOLD 0xEBEA

/**
 * (internal) {sn16 = data}
 * 0.01 deg
 */
#define VE_REG_INV_ADC_UINV_PHASE1_DIF 0xEBEB

/**
 * (internal) {sn16 = data}
 * 0.01 deg
 */
#define VE_REG_INV_ADC_UINV_PHASE1_OFFSET 0xEBEC

/**
 * (internal) {un8 = data}
 * TFSCorrupt
 */
#define VE_REG_VE_REG_INV_TFS_CORRUPT 0xEBEE

/** (internal) {sn16 = data} */
#define VE_REG_INV_LOOP_TEMP_COMPENSATION_ROUT_GIN 0xEBEF

/**
 * (internal) {sn16 = data}
 * 0.01 deg
 */
#define VE_REG_INV_LOOP_COMPENSATE_ROUT_GIN_PHASE 0xEBF7

/**
 * (internal) {sn32 = data}
 * generic debug register
 */
#define VE_REG_INV_DEBUG_HARM1 0xEBF8

/**
 * (internal) {un16 = data}
 * max number of events at nominal battery voltage
 */
#define VE_REG_INV_PROT_IPEAK_LOW_LEVEL_THRESHOLD 0xEBF9

/**
 * (internal) {un16 = data}
 * max number of events at low battery voltage (9V * N)
 */
#define VE_REG_INV_PROT_IPEAK_LOW_LEVEL_THRESHOLD_LOW_BAT 0xEBFA

/** (internal) {un16 = data} */
#define VE_REG_INV_WATCH_TEST 0xEBFE

/** sn16 readonly (internal) {sn16 = data} */
#define VE_REG_INV_WAVE_GET_MIN_MARGIN_WAVE_PHASE 0xEBFF

/**
 * Blue Power Charger LED State {un32 = Blue Power Charger LED State}
 * @deprecated VictronConnect is not showing the LEDs anymore. Was used to mimic
 * LED behaviour. 3 bits reserved per LED; from lsb to msb: test, bulk, abs,
 * float, storage, normal, high, recon, li-ion. See section VELIB_VECAN_REG_BPC
 * for definition: 0:off, 1:on, 2:blink, 3:blink inverted, 3-6: reserved,
 * 7:invalid.
 */
#define VE_REG_BPC_LED_STATE 0xE000

/** Low current mode {un8 = Low current mode, 0 = off, 1 = on, 2 = night mode} */
#define VE_REG_BPC_LOW_CURRENT_MODE 0xE001

/** Low current mode: time left {un32 = Low current mode: time left [1s]} */
#define VE_REG_BPC_LOW_CURRENT_MODE_TIME_LEFT 0xE002

/** Statistics: number of converter starts {un32 = Starts} */
#define VE_REG_BPC_STATS_CONVERTER_STARTS 0xE003

/** Statistics: number of converter restarts {un32 = Restarts} */
#define VE_REG_BPC_STATS_CONVERTER_RESTARTS 0xE004

/** Output setpoint {un16 = Output setpoint [0.01V]} */
#define VE_REG_BPC_TST_OUTPUT_SETPOINT 0xEE40

/** Output offset {un16 = Output offset [0.01V]} */
#define VE_REG_BPC_TST_OUTPUT_OFFSET 0xEE50

/** Output gain {un16 = Output gain} */
#define VE_REG_BPC_TST_OUTPUT_GAIN 0xEE60

/** Raw pwm output value {un16 = Raw pwm output value, 0-1000} */
#define VE_REG_BPC_TST_OUTPUT_RAW 0xEE70

/** Tester mains lost detection (latched) {un8 = Mains, 0 = present, 1 = lost} */
#define VE_REG_BPC_TST_MAINS_LOST 0xEE7A

/**
 * Tester mains detection. 0:absent; 1:present {un8 = Tester mains detection.
 * 0:absent; 1:present}
 */
#define VE_REG_BPC_TST_GET_MAINS_DETECT 0xEE7B

/**
 * Tester get current limiter active {un8 = Tester get current limiter active,
 * 0=no, 1=yes, 255= unknown/invalid;}
 */
#define VE_REG_BPC_TST_CURR_LIMITER_ACTIVE 0xEE7C

/** Tester is calibrated {un8 = Tester is calibrated, 0=no, 1=yes;} */
#define VE_REG_BPC_TST_IS_CALIBRATED 0xEE7E

/**
 * Tester get button . 0:released; 1:pressed {un8 = Tester get button .
 * 0:released; 1:pressed}
 */
#define VE_REG_BPC_TST_BUTTON 0xEE7F

/**
 * The connection currently used to connect to Coupling Server {un8 = The
 * connection currently used to connect to Coupling Server, 0 = no connection, 1
 * = cellular, 2 = wifi, 3 = lorawan, 255 = unknown}
 */
#define VE_REG_GL_CONNECTION 0xE3C0

/**
 * Time ago last successfully read data from VE.Direct port 1 {un32 = Time ago
 * last successfully read data from VE.Direct port 1 [1s], 0xFFFFFFFF = Never
 * seen}
 */
#define VE_REG_GL_VEDIRECT_1_LAST_SEEN 0xE3C1

/**
 * Time ago last successfully read data from VE.Direct port 2 {un32 = Time ago
 * last successfully read data from VE.Direct port 2 [1s], 0xFFFFFFFF = Never
 * seen}
 */
#define VE_REG_GL_VEDIRECT_2_LAST_SEEN 0xE3C2

/**
 * Custom name for the device connected to VE.Direct port 1 {stringZeroEnded[80]
 * = Custom name for the device connected to VE.Direct port 1}
 */
#define VE_REG_GL_VEDIRECT_1_CUSTOM_NAME 0xE3C3

/**
 * Custom name for the device connected to VE.Direct port 2 {stringZeroEnded[80]
 * = Custom name for the device connected to VE.Direct port 2}
 */
#define VE_REG_GL_VEDIRECT_2_CUSTOM_NAME 0xE3C4

/**
 * Current state of Digital Input 1 {un8 = Current state of Digital Input 1, 0 =
 * low, 1 = high}
 */
#define VE_REG_GL_DIGITAL_INPUT_1_STATE 0xE3C5

/**
 * Current state of Digital Input 2 {un8 = Current state of Digital Input 2, 0 =
 * low, 1 = high}
 */
#define VE_REG_GL_DIGITAL_INPUT_2_STATE 0xE3C6

/**
 * Custom name for Digital Input 1 {stringZeroEnded[80] = Custom name for Digital
 * Input 1}
 */
#define VE_REG_GL_DIGITAL_INPUT_1_CUSTOM_NAME 0xE3C7

/**
 * Custom name for Digital Input 2 {stringZeroEnded[80] = Custom name for Digital
 * Input 2}
 */
#define VE_REG_GL_DIGITAL_INPUT_2_CUSTOM_NAME 0xE3C8

/**
 * Whether automatic updates are enabled or not {un8 = Whether automatic updates
 * are enabled or not, 0 = disabled, 1 = enabled}
 */
#define VE_REG_AUTOUPDATE_ENABLED 0xEC60

/**
 * Feed used for automatic updates {un8 = Feed used for automatic updates, 0 =
 * release, 1 = candidate, 2 = testing, 3 = develop}
 */
#define VE_REG_AUTOUPDATE_FEED 0xEC61

/**
 * Whether an update is currently in progress {un8 = Whether an update is
 * currently in progress, 0 = idle, 1 = updating}
 */
#define VE_REG_AUTOUPDATE_STATUS 0xEC62

/**
 * Connectivity state of the cellular connection {un8 = Connectivity state of the
 * cellular connection, 0 = disconnected, 1 = attaching, 2 = connecting, 3 =
 * connected}
 */
#define VE_REG_CELLULAR_STATUS 0xEC70

/**
 * The antenna type used for the cellular connection {un8 = The antenna type used
 * for the cellular connection, 0 = internal, 1 = external}
 */
#define VE_REG_CELLULAR_ANTENNA 0xEC71

/** Signal strength (RSSI) {sn16 = Signal strength (RSSI), 0x7FFF = Unavailable} */
#define VE_REG_CELLULAR_RSSI 0xEC72

/**
 * Name and/or PLMN of current cellular operator {stringZeroEnded[80] = Name
 * and/or PLMN of current cellular operator}
 */
#define VE_REG_CELLULAR_OPERATOR 0xEC73

/**
 * Access Point Name for connecting cellular to the Internet {stringZeroEnded[80]
 * = Access Point Name for connecting cellular to the Internet}
 */
#define VE_REG_CELLULAR_APN 0xEC74

/**
 * Identifier number of of the SIM card {stringZeroEnded[22] = Identifier number
 * of of the SIM card}
 */
#define VE_REG_CELLULAR_ICCID 0xEC75

/**
 * PIN status of the SIM card {un8 = PIN status of the SIM card (see xml for
 * meanings)}
 */
#define VE_REG_CELLULAR_SIM_STATUS 0xEC76

/**
 * PIN code for unlocking the SIM card {stringZeroEnded[16] = PIN code for
 * unlocking the SIM card}
 */
#define VE_REG_CELLULAR_SIM_PIN 0xEC77

/**
 * Result of AT command +CEREG?: EPS Network Registration Status
 * {stringZeroEnded[120] = Result of AT command +CEREG?: EPS Network Registration
 * Status}
 */
#define VE_REG_CELLULAR_AT_CEREG 0xEC78

/**
 * Enabled/disable state of external device {block = Enabled/disable state of
 * external device, CBOR-encoded map. Key is an arbitrary unique device
 * identifier, value is a boolean whether the device is enabled. NULL = not
 * enabled.}
 */
#define VE_REG_EXTERNALDEVICE_ENABLED 0xEC90

/**
 * Type of external device {block = Type of external device, CBOR-encoded map.
 * Key is an arbitrary unique device identifier, value is an integer product ID.
 * NULL = 0xFFFF (VE_PROD_ID_NOT_SET)}
 */
#define VE_REG_EXTERNALDEVICE_TYPE 0xEC91

/**
 * Name of external device {block = Name of external device, CBOR-encoded map.
 * Key is an arbitrary unique device identifier, value is a string device name.
 * NULL = unknown, fall back to default.}
 */
#define VE_REG_EXTERNALDEVICE_NAME 0xEC92

/**
 * Time ago last successfully read data from external device {block = Time ago
 * last successfully read data from external device, CBOR-encoded map. Key is an
 * arbitrary unique device identifier, value is the integer time ago in seconds.
 * NULL = never seen.}
 */
#define VE_REG_EXTERNALDEVICE_LAST_SEEN 0xEC93

/**
 * Signal strength for external device {block = Signal strength for external
 * device, CBOR-encoded map. Key is an arbitrary unique device identifier, value
 * is the integer RSSI in decibel. NULL = unknown.}
 */
#define VE_REG_EXTERNALDEVICE_RSSI 0xEC94

/**
 * Error message for external device {block = Error message for external device,
 * CBOR-encoded map. Key is an arbitrary unique device identifier, value is a
 * string with an error message. NULL = no error.}
 */
#define VE_REG_EXTERNALDEVICE_ERROR 0xEC95

/**
 * BLE MAC address for external device {block = BLE MAC address for external
 * device, CBOR-encoded map. Key is an arbitrary unique device identifier, value
 * is the bytestring BLE MAC address (48 bits / 6 bytes). NULL = unknown.}
 */
#define VE_REG_EXTERNALDEVICE_BLE_MAC_ADDRESS 0xEC96

/**
 * BLE advertisement key for external device {block = BLE advertisement key for
 * external device, CBOR-encoded map. Key is an arbitrary unique device
 * identifier, value is the bytestring BLE advertisement key (16 bytes). NULL =
 * unknown.}
 */
#define VE_REG_EXTERNALDEVICE_BLE_ADVERTISEMENT_KEY 0xEC97

/**
 * Features supported by external device {block = Features supported by external
 * device, CBOR-encoded map. Key is an arbitrary unique device identifier, value
 * is an unsigned integer containing bitwise flags indicating feature support.
 * NULL = unknown. Bit 1 = BLE advertisement key.}
 */
#define VE_REG_EXTERNALDEVICE_FEATURE_FLAGS 0xEC98

/** Voltage on the power supply {sn32 = Voltage on the power supply [0.001V]} */
#define VE_REG_DC_SUPPLY_VOLTAGE 0xECA0

/**
 * Internal temperature of the device {sn16 = Internal temperature of the device
 * [0.01°C]}
 */
#define VE_REG_INTERNAL_TEMPERATURE 0xECA1

/**
 * Time ago last transmitted data to VRM {un32 = Time ago last transmitted data
 * to VRM [1s], 0xFFFFFFFF = Never transmitted}
 */
#define VE_REG_VRM_LAST_TRANSMISSION 0xECA2

/**
 * Error message if last attempt to transmit to VRM failed. Empty string = no
 * error. {stringZeroEnded[120] = Error message if last attempt to transmit to
 * VRM failed. Empty string = no error.}
 */
#define VE_REG_VRM_LAST_ERROR_MESSAGE 0xECA3

/**
 * Version information of the vesmart-server {block = Version information of the
 * vesmart-server}
 * Cbor encoded dictionary of strings, for example {"version": "0.3.6"}
 */
#define VE_REG_VENUS_NETWORK_VERSION 0xE3D0

/**
 * Trigger network scan on Venus
 * Empty message to trigger the scan.
 */
#define VE_REG_VENUS_NETWORK_TRIGGER_SCAN 0xE3D1

/**
 * Scanning state of the Venus device {block = Scanning state of the Venus
 * device}
 * Array of 1 or 2 strings. First string is the state ("nowifi", "idle",
 * "scanning") and second is a potential error string.
 */
#define VE_REG_VENUS_NETWORK_WIFI_SCAN_STATE 0xE3D2

/**
 * List of wifi services on the Venus device {block = List of wifi services on
 * the Venus device}
 * Cbor array of wifi services with each wifi service being an array containing
 * id, state, signal strength and configured. Configured is equal to the connman
 * property Favorite
 */
#define VE_REG_VENUS_NETWORK_WIFI_SERVICES 0xE3D3

/**
 * Connect to a wifi service {stringZeroEnded[80] = Connect to a wifi service}
 * Character string containing the wifi service ID
 */
#define VE_REG_VENUS_NETWORK_CONNECT 0xE3D4

/**
 * Forget a wifi service {stringZeroEnded[80] = Forget a wifi service}
 * Character string containing the wifi service ID. Will also disconnect.
 */
#define VE_REG_VENUS_NETWORK_FORGET 0xE3D5

/**
 * Disconnect from a wifi service {stringZeroEnded[80] = Disconnect from a wifi
 * service}
 * Character string containing the wifi service ID.
 */
#define VE_REG_VENUS_NETWORK_DISCONNECT 0xE3D6

/**
 * The selected service {stringZeroEnded[80] = The selected service, Character
 * string containing the service ID.}
 */
#define VE_REG_VENUS_NETWORK_SELECTED_SERVICE 0xE3D7

/**
 * Properties of the selected service {block = Properties of the selected
 * service, CBOR array containing: 1. id of the service this data corresponds to,
 * 2. CBOR map of the properties}
 */
#define VE_REG_VENUS_NETWORK_SERVICE_PROPERTIES 0xE3D8

/**
 * Set properties of a service {block = Set properties of a service, CBOR array
 * containing 1. the id string of the service, 2. the property name to change and
 * 3. a CBOR encoded value}
 */
#define VE_REG_VENUS_NETWORK_SET_SERVICE_PROPERTIES 0xE3D9

/**
 * Wifi connection agent input request {block = Wifi connection agent input
 * request}
 * Cbor encoded dictionary of strings.
 */
#define VE_REG_VENUS_NETWORK_AGENT_INPUT_REQUEST 0xE3DA

/**
 * Wifi connection agent input request {block = Wifi connection agent input
 * request}
 * Cbor encoded dictionary of strings, having a response to the request in
 * VE_REG_VENUS_NETWORK_AGENT_RESPONSE
 */
#define VE_REG_VENUS_NETWORK_AGENT_RESPONSE 0xE3DB

/**
 * Access point available {un8 = Access point available, 0 = access point not
 * available, 1 = access point available}
 */
#define VE_REG_VENUS_NETWORK_AP_AVAILABLE 0xE3DC

/**
 * Access point state {un8 = Access point state, 0 = access point disabled, 1 =
 * access point enabled}
 */
#define VE_REG_VENUS_NETWORK_AP_STATE 0xE3DD

/**
 * Access point state {stringZeroEnded[64] = Access point state}
 * Character string containing the Access Point passphrase.
 */
#define VE_REG_VENUS_NETWORK_AP_PASSPHRASE 0xE3DE

/**
 * Access point state {stringZeroEnded[32] = Access point state}
 * Character string containing the Access Point SSID.
 */
#define VE_REG_VENUS_NETWORK_AP_SSID 0xE3DF

/**
 * Ethernet service name and state {block = Ethernet service name and state, CBOR
 * array containing 1. the id string of the ethernet service, 2. a CBOR string
 * containing the state}
 */
#define VE_REG_VENUS_NETWORK_ETHERNET_SERVICE 0xE3E0

/** The link local address {stringZeroEnded[80] = The link local address} */
#define VE_REG_VENUS_NETWORK_LINK_LOCAL_ADDRESS 0xE3E1

/**
 * VE.Bus interface operating mode {un8 = VE.Bus interface operating mode, 0x00 =
 * Initializing, 0x01 = PrimaryMode, 0x02 = SecondaryMode}
 */
#define VE_REG_VEBUS_INTERFACE_OPERATING_MODE 0xE400

/**
 * Power measurement type {un8 = Power measurement type, 0x00 = Apparent power
 * from master, 0x01 = Real power summed masters, 0x02 = Real power summed, 0x03
 * = Real power snapshot masters, 0x04 = Real power snapshot}
 */
#define VE_REG_VEBUS_AC_POWER_MEASUREMENT_TYPE 0xE401

/** Vebus system workarounds {un16 = Vebus system workarounds} */
#define VE_REG_VEBUS_SYSTEM_QUIRKS 0xE402

/**
 * Mains led status {un8 = Mains led status, Bit 1 set = on, bit 2 set =
 * blinking}
 */
#define VE_REG_VEBUS_LED_MAINS 0xE403

/**
 * Absorption led status {un8 = Absorption led status, Bit 1 set = on, bit 2 set
 * = blinking}
 */
#define VE_REG_VEBUS_LED_ABSORPTION 0xE404

/** Bulk led status {un8 = Bulk led status, Bit 1 set = on, bit 2 set = blinking} */
#define VE_REG_VEBUS_LED_BULK 0xE405

/**
 * Float led status {un8 = Float led status, Bit 1 set = on, bit 2 set =
 * blinking}
 */
#define VE_REG_VEBUS_LED_FLOAT 0xE406

/**
 * Inverter led status {un8 = Inverter led status, Bit 1 set = on, bit 2 set =
 * blinking}
 */
#define VE_REG_VEBUS_LED_INVERTER 0xE407

/**
 * Overload led status {un8 = Overload led status, Bit 1 set = on, bit 2 set =
 * blinking}
 */
#define VE_REG_VEBUS_LED_OVERLOAD 0xE408

/**
 * Low Battery led status {un8 = Low Battery led status, Bit 1 set = on, bit 2
 * set = blinking}
 */
#define VE_REG_VEBUS_LED_LOW_BATTERY 0xE409

/**
 * Temperature led status {un8 = Temperature led status, Bit 1 set = on, bit 2
 * set = blinking}
 */
#define VE_REG_VEBUS_LED_TEMPERATURE 0xE40A

/** VeBus error {un8 = VeBus error} */
#define VE_REG_VEBUS_VEBUS_ERROR 0xE40B

/** Vebus Short id flags {un32 = Vebus Short id flags} */
#define VE_REG_VEBUS_SHORT_IDS 0xE40C

/**
 * VeBus temperature sensor alarm {un8 = VeBus temperature sensor alarm, 0 = ok,
 * 1 = warning, 2 = active}
 */
#define VE_REG_VEBUS_ALARM_TEMP_SENSOR 0xE40D

/**
 * VeBus voltage sensor alarm {un8 = VeBus voltage sensor alarm, 0 = ok, 1 =
 * warning, 2 = active}
 */
#define VE_REG_VEBUS_ALARM_VOLTAGE_SENSOR 0xE40E

/**
 * VeBus L1 low battery alarm {un8 = VeBus L1 low battery alarm, 0 = ok, 1 =
 * warning, 2 = active}
 */
#define VE_REG_VEBUS_ALARM_L1_LOW_BATTERY 0xE40F

/**
 * VeBus L1 temperature alarm {un8 = VeBus L1 temperature alarm, 0 = ok, 1 =
 * warning, 2 = active}
 */
#define VE_REG_VEBUS_ALARM_L1_TEMPERATURE 0xE410

/**
 * VeBus L1 overload alarm {un8 = VeBus L1 overload alarm, 0 = ok, 1 = warning, 2
 * = active}
 */
#define VE_REG_VEBUS_ALARM_L1_OVERLOAD 0xE411

/**
 * VeBus L1 battery voltage ripple alarm {un8 = VeBus L1 battery voltage ripple
 * alarm, 0 = ok, 1 = warning, 2 = active}
 */
#define VE_REG_VEBUS_ALARM_L1_U_BAT_RIPPLE 0xE412

/**
 * VeBus L2 low battery alarm {un8 = VeBus L2 low battery alarm, 0 = ok, 1 =
 * warning, 2 = active}
 */
#define VE_REG_VEBUS_ALARM_L2_LOW_BATTERY 0xE413

/**
 * VeBus L2 temperature alarm {un8 = VeBus L2 temperature alarm, 0 = ok, 1 =
 * warning, 2 = active}
 */
#define VE_REG_VEBUS_ALARM_L2_TEMPERATURE 0xE414

/**
 * VeBus L2 overload alarm {un8 = VeBus L2 overload alarm, 0 = ok, 1 = warning, 2
 * = active}
 */
#define VE_REG_VEBUS_ALARM_L2_OVERLOAD 0xE415

/**
 * VeBus L2 battery voltage ripple alarm {un8 = VeBus L2 battery voltage ripple
 * alarm, 0 = ok, 1 = warning, 2 = active}
 */
#define VE_REG_VEBUS_ALARM_L2_U_BAT_RIPPLE 0xE416

/**
 * VeBus L3 low battery alarm {un8 = VeBus L3 low battery alarm, 0 = ok, 1 =
 * warning, 2 = active}
 */
#define VE_REG_VEBUS_ALARM_L3_LOW_BATTERY 0xE417

/**
 * VeBus L3 temperature alarm {un8 = VeBus L3 temperature alarm, 0 = ok, 1 =
 * warning, 2 = active}
 */
#define VE_REG_VEBUS_ALARM_L3_TEMPERATURE 0xE418

/**
 * VeBus L3 overload alarm {un8 = VeBus L3 overload alarm, 0 = ok, 1 = warning, 2
 * = active}
 */
#define VE_REG_VEBUS_ALARM_L3_OVERLOAD 0xE419

/**
 * VeBus L3 battery voltage ripple alarm {un8 = VeBus L3 battery voltage ripple
 * alarm, 0 = ok, 1 = warning, 2 = active}
 */
#define VE_REG_VEBUS_ALARM_L3_U_BAT_RIPPLE 0xE41A

/** Absorption voltage {sn16 = Absorption voltage [0.01V]} */
#define VE_REG_VEBUS_SET_U_BAT_ABSORPTION 0xE41B

/** Float voltage {sn16 = Float voltage [0.01V]} */
#define VE_REG_VEBUS_SET_U_BAT_FLOAT 0xE41C

/** Maximum charge current {sn16 = Maximum charge current [0.01A]} */
#define VE_REG_VEBUS_SET_I_BAT_BULK 0xE41D

/** Inverter output voltage {sn16 = Inverter output voltage [0.01V]} */
#define VE_REG_VEBUS_SET_U_INV_SETPOINT 0xE41E

/** AC1 current limit {sn16 = AC1 current limit [0.01A]} */
#define VE_REG_VEBUS_SET_I_MAINS_LIMIT_AC1 0xE41F

/** Repeated absorption time {un16 = Repeated absorption time [1min]} */
#define VE_REG_VEBUS_SET_REPEATED_ABSORPTION_TIME 0xE420

/** Repeated absorption interval {un16 = Repeated absorption interval [1min]} */
#define VE_REG_VEBUS_SET_REPEATED_ABSORPTION_INTERVAL 0xE421

/** Maximum absorption time {un16 = Maximum absorption time [1min]} */
#define VE_REG_VEBUS_SET_MAXIMUM_ABSORPTION_DURATION 0xE422

/** Charge charasteristic {un8 = Charge charasteristic} */
#define VE_REG_VEBUS_SET_CHARGE_CHARACTERISTIC 0xE423

/** Inverter DC shutdown voltage {sn16 = Inverter DC shutdown voltage [0.01V]} */
#define VE_REG_VEBUS_SET_U_BAT_LOW_LIMIT_FOR_INVERTER 0xE424

/** Inverter DC restart voltage {sn16 = Inverter DC restart voltage [0.01V]} */
#define VE_REG_VEBUS_SET_UBAT_LOW_RESTART_LEVEL_FOR_INVERTER 0xE425

/** Number of slaves connected {un8 = Number of slaves connected} */
#define VE_REG_VEBUS_SET_NUMBER_OF_SLAVES_CONNECTED 0xE426

/** Special three phase setting {un8 = Special three phase setting} */
#define VE_REG_VEBUS_SET_SPECIAL_THREE_PHASE_SETTING 0xE427

/** Virtual switch usage {un8 = Virtual switch usage} */
#define VE_REG_VEBUS_SET_VS_USAGE 0xE428

/** VS on load higher than {un16 = VS on load higher than [1W]} */
#define VE_REG_VEBUS_SET_VS_ON_P_INV_HIGH 0xE429

/** VS on when U DC lower than {sn16 = VS on when U DC lower than [0.01V]} */
#define VE_REG_VEBUS_SET_VS_ON_U_BAT_HIGH 0xE42A

/** VS on when U DC higher than {sn16 = VS on when U DC higher than [0.01V]} */
#define VE_REG_VEBUS_SET_VS_ON_U_BAT_LOW 0xE42B

/** VS time on load high  {un16 = VS time on load high  [1s]} */
#define VE_REG_VEBUS_SET_VS_TON_P_INV_HIGH 0xE42C

/** VS time on DC voltage high {un16 = VS time on DC voltage high [1s]} */
#define VE_REG_VEBUS_SET_VS_TON_U_BAT_HIGH 0xE42D

/** VS time on DC voltage low {un16 = VS time on DC voltage low [1s]} */
#define VE_REG_VEBUS_SET_VS_TON_U_BAT_LOW 0xE42E

/** VS time on when not charging {un16 = VS time on when not charging [1s]} */
#define VE_REG_VEBUS_SET_VS_TON_NOT_CHARGING 0xE42F

/** VS time on fan enabled {un16 = VS time on fan enabled [1s]} */
#define VE_REG_VEBUS_SET_VS_TON_FAN_ON 0xE430

/** VS time on temperature alarm {un16 = VS time on temperature alarm [1s]} */
#define VE_REG_VEBUS_SET_VS_TON_TEMPERATURE_ALARM 0xE431

/** VS time on low battery alarm {un16 = VS time on low battery alarm [1s]} */
#define VE_REG_VEBUS_SET_VS_TON_LOW_BATTERY_ALARM 0xE432

/** VS time on overload alarm {un16 = VS time on overload alarm [1s]} */
#define VE_REG_VEBUS_SET_VS_TON_OVERLOAD_ALARM 0xE433

/** VS time on ripple alarm {un16 = VS time on ripple alarm [1s]} */
#define VE_REG_VEBUS_SET_VS_TON_U_BATT_RIPPLE_ALARM 0xE434

/** VS off load lower than {un16 = VS off load lower than [1W]} */
#define VE_REG_VEBUS_SET_VS_OFF_P_INV_LOW 0xE435

/** VS off when udc lower than {sn16 = VS off when udc lower than [0.01V]} */
#define VE_REG_VEBUS_SET_VS_OFF_U_BAT_HIGH 0xE436

/** VS off when udc higher than {sn16 = VS off when udc higher than [0.01V]} */
#define VE_REG_VEBUS_SET_VS_OFF_U_BAT_LOW 0xE437

/** VS time off load low {un16 = VS time off load low [1s]} */
#define VE_REG_VEBUS_SET_VS_TOFF_P_INV_LOW 0xE438

/** VS time off DC voltage high {un16 = VS time off DC voltage high [1s]} */
#define VE_REG_VEBUS_SET_VS_TOFF_U_BATT_HIGH 0xE439

/** VS time off DC voltage low {un16 = VS time off DC voltage low [1s]} */
#define VE_REG_VEBUS_SET_VS_TOFF_U_BATT_LOW 0xE43A

/** VS off when charging for {un16 = VS off when charging for [1s]} */
#define VE_REG_VEBUS_SET_VS_TOFF_CHARGING 0xE43B

/** VS time off fan disabled {un16 = VS time off fan disabled [1s]} */
#define VE_REG_VEBUS_SET_VS_TOFF_FAN_OFF 0xE43C

/** VS off bulk finished for {un16 = VS off bulk finished for [1min]} */
#define VE_REG_VEBUS_SET_VS_TOFF_CHARGE_BULK_FINISHED 0xE43D

/** VS off no ON condition for {un16 = VS off no ON condition for [1min]} */
#define VE_REG_VEBUS_SET_VS_TOFF_NO_VSON_CONDITION 0xE43E

/** VS off when no AC Input for {un16 = VS off when no AC Input for [1s]} */
#define VE_REG_VEBUS_SET_VS_TOFF_NO_AC_INPUT 0xE43F

/** VS off no temperature alarm {un16 = VS off no temperature alarm [1s]} */
#define VE_REG_VEBUS_SET_VS_TOFF_TEMPERATURE_ALARM 0xE440

/** VS off no battery alarm {un16 = VS off no battery alarm [1s]} */
#define VE_REG_VEBUS_SET_VS_TOFF_LOW_BATTERY_ALARM 0xE441

/** VS off no overload alarm {un16 = VS off no overload alarm [1s]} */
#define VE_REG_VEBUS_SET_VS_TOFF_OVERLOAD_ALARM 0xE442

/** VS off no ripple alarm {un16 = VS off no ripple alarm [1s]} */
#define VE_REG_VEBUS_SET_VS_TOFF_U_BATT_RIPPLE_ALARM 0xE443

/** minimum on time {un16 = minimum on time [1min]} */
#define VE_REG_VEBUS_SET_VS_MINIMUM_ON_TIME 0xE444

/** AC low switch input off {sn16 = AC low switch input off [0.01V]} */
#define VE_REG_VEBUS_SET_U_MAINS_LOW_DISCONNECT 0xE445

/** AC low switch input on {sn16 = AC low switch input on [0.01V]} */
#define VE_REG_VEBUS_SET_U_MAINS_LOW_CONNECT 0xE446

/** AC high switch input on {sn16 = AC high switch input on [0.01V]} */
#define VE_REG_VEBUS_SET_U_MAINS_HIGH_DISCONNECT 0xE447

/** AC high switch input off {sn16 = AC high switch input off [0.01V]} */
#define VE_REG_VEBUS_SET_U_MAINS_HIGH_CONNECT 0xE448

/** Assist current boost factor {un8 = Assist current boost factor} */
#define VE_REG_VEBUS_SET_ASSIST_CURRENT_BOOST_FACTOR 0xE449

/** AC2 current limit {sn16 = AC2 current limit [0.01A]} */
#define VE_REG_VEBUS_SET_I_MAINS_LIMIT_AC2 0xE44A

/** Power for switching to AES {un16 = Power for switching to AES [1W]} */
#define VE_REG_VEBUS_SET_POWER_FOR_SWITCHING_TO_AES 0xE44B

/**
 * Power offset for ending AES mode {un16 = Power offset for ending AES mode
 * [1W]}
 */
#define VE_REG_VEBUS_SET_HYST_FOR_AES_POWER 0xE44C

/** VS2 on load higher than {un16 = VS2 on load higher than [1W]} */
#define VE_REG_VEBUS_SET_VS_2_ON_P_LOAD_HIGH_LEVEL 0xE44D

/** VS2 time on load high {un16 = VS2 time on load high [1s]} */
#define VE_REG_VEBUS_SET_VS_2_ON_I_LOAD_HIGH_TIME 0xE44E

/** VS2 on lower DC voltage than {sn16 = VS2 on lower DC voltage than [0.01V]} */
#define VE_REG_VEBUS_SET_VS_2_ON_U_BAT_LOW_LEVEL 0xE44F

/** VS2 on low DC voltage for {un16 = VS2 on low DC voltage for [1s]} */
#define VE_REG_VEBUS_SET_VS_2_ON_U_BAT_LOW_TIME 0xE450

/** VS2 off load lower then {un16 = VS2 off load lower then [1W]} */
#define VE_REG_VEBUS_SET_VS_2_OFF_LOAD_LOW_LEVEL 0xE451

/** VS2 off load lower for {un16 = VS2 off load lower for [1min]} */
#define VE_REG_VEBUS_SET_VS_2_OFF_LOAD_LOW_TIME 0xE452

/** VS2 off DC voltage high {sn16 = VS2 off DC voltage high [0.01V]} */
#define VE_REG_VEBUS_SET_VS_2_OFF_U_BAT_HIGH_LEVEL 0xE453

/** VS2 off DC voltage for {un16 = VS2 off DC voltage for [1min]} */
#define VE_REG_VEBUS_SET_VS_2_OFF_U_BAT_HIGH_TIME 0xE454

/** VS Inverter period time {un16 = VS Inverter period time [0.001s]} */
#define VE_REG_VEBUS_SET_VS_INVERTER_PERIOD_TIME 0xE455

/** Low DC alarm level {sn16 = Low DC alarm level [0.01V]} */
#define VE_REG_VEBUS_SET_U_BAT_LOW_PRE_ALARM_LEVEL 0xE456

/** Battery capacity {un16 = Battery capacity [Ah]} */
#define VE_REG_VEBUS_SET_BATTERY_CAPACITY 0xE457

/** SOC when bulk finisihed {un8 = SOC when bulk finisihed [1%]} */
#define VE_REG_VEBUS_SET_BATTERY_CHARGE_PERCENTAGE 0xE458

/** Frequency shift U bat start {sn16 = Frequency shift U bat start [0.01V]} */
#define VE_REG_VEBUS_SET_SHIFT_UBAT_START 0xE459

/**
 * Frequency shift U bat start delay {un16 = Frequency shift U bat start delay
 * [1s]}
 */
#define VE_REG_VEBUS_SET_SHIFT_UBAT_START_DELAY 0xE45A

/** Frequency shift U bat stop {sn16 = Frequency shift U bat stop [0.01V]} */
#define VE_REG_VEBUS_SET_SHIFT_UBAT_STOP 0xE45B

/**
 * Frequency shift U bat stop delay {un16 = Frequency shift U bat stop delay
 * [1s]}
 */
#define VE_REG_VEBUS_SET_SHIFT_UBAT_STOP_DELAY 0xE45C

/** VS2 on SOC level {un8 = VS2 on SOC level [1%]} */
#define VE_REG_VEBUS_SET_VS2_ON_SOC 0xE45D

/**
 * Assistant temperature compensation {sn16 = Assistant temperature compensation
 * [0.01°C]}
 */
#define VE_REG_VEBUS_SET_VLL_TEMP_COMPENSATION 0xE45E

/** Charge efficiency {un16 = Charge efficiency [0.01]} */
#define VE_REG_VEBUS_SET_CHARGE_EFFICIENCY 0xE45F

/** Multi phase system {un8 = Multi phase system, 0 = Off, 1 = On} */
#define VE_REG_VEBUS_FLAG_MULTI_PHASE_SYSTEM 0xE460

/** Multi phase leader {un8 = Multi phase leader, 0 = Off, 1 = On} */
#define VE_REG_VEBUS_FLAG_MULTI_PHASE_LEADER 0xE461

/** 60Hz {un8 = 60Hz, 0 = Off, 1 = On} */
#define VE_REG_VEBUS_FLAG_60HZ 0xE462

/** Disable wave check {un8 = Disable wave check, 0 = Off, 1 = On} */
#define VE_REG_VEBUS_FLAG_DISABLE_WAVE_CHECK 0xE463

/** Don't stop after 10h bulk {un8 = Don't stop after 10h bulk, 0 = Off, 1 = On} */
#define VE_REG_VEBUS_FLAG_DONT_STOP_AFTER_10H_BULK 0xE464

/** Power assist enabled {un8 = Power assist enabled, 0 = Off, 1 = On} */
#define VE_REG_VEBUS_FLAG_ASSIST_ENABLED 0xE465

/** Disable charger {un8 = Disable charger, 0 = Off, 1 = On} */
#define VE_REG_VEBUS_FLAG_DISABLE_CHARGE 0xE466

/**
 * Disable back feed lock on large currents {un8 = Disable back feed lock on
 * large currents, 0 = Off, 1 = On}
 */
#define VE_REG_VEBUS_FLAG_DISABLE_BF_LOCK_ON_LARGE_CURRENTS 0xE467

/** Disable AES {un8 = Disable AES, 0 = Off, 1 = On} */
#define VE_REG_VEBUS_FLAG_DISABLE_AES 0xE468

/** Enable reduced float {un8 = Enable reduced float, 0 = Off, 1 = On} */
#define VE_REG_VEBUS_FLAG_ENABLE_REDUCED_FLOAT 0xE469

/** Disable ground relay {un8 = Disable ground relay, 0 = Off, 1 = On} */
#define VE_REG_VEBUS_FLAG_DISABLE_GROUND_RELAY 0xE46A

/** Weak AC input {un8 = Weak AC input, 0 = Off, 1 = On} */
#define VE_REG_VEBUS_FLAG_WEAK_AC_INPUT 0xE46B

/** Remote overrules AC2 {un8 = Remote overrules AC2, 0 = Off, 1 = On} */
#define VE_REG_VEBUS_FLAG_REMOTE_OVERRULES_AC2 0xE46C

/** VS on bulk protection {un8 = VS on bulk protection, 0 = Off, 1 = On} */
#define VE_REG_VEBUS_FLAG_VS_ON_BULK_PROTECTION 0xE46D

/**
 * VS on temperature pre alarm {un8 = VS on temperature pre alarm, 0 = Off, 1 =
 * On}
 */
#define VE_REG_VEBUS_FLAG_VS_ON_TEMP_PRE_ALARM 0xE46E

/**
 * VS on low battery pre alarm {un8 = VS on low battery pre alarm, 0 = Off, 1 =
 * On}
 */
#define VE_REG_VEBUS_FLAG_VS_ON_LOW_BAT_PRE_ALARM 0xE46F

/** VS on overload pre alarm {un8 = VS on overload pre alarm, 0 = Off, 1 = On} */
#define VE_REG_VEBUS_FLAG_VS_ON_OVERLOAD_PRE_ALARM 0xE470

/** VS on ripple pre alarm {un8 = VS on ripple pre alarm, 0 = Off, 1 = On} */
#define VE_REG_VEBUS_FLAG_VS_ON_RIPPLE_PRE_ALARM 0xE471

/**
 * VS off temperature pre alarm {un8 = VS off temperature pre alarm, 0 = Off, 1 =
 * On}
 */
#define VE_REG_VEBUS_FLAG_VS_OFF_TEMP_PRE_ALARM 0xE472

/**
 * VS off low battery pre alarm {un8 = VS off low battery pre alarm, 0 = Off, 1 =
 * On}
 */
#define VE_REG_VEBUS_FLAG_VS_OFF_LOW_BAT_PRE_ALARM 0xE473

/** VS off overload pre alarm {un8 = VS off overload pre alarm, 0 = Off, 1 = On} */
#define VE_REG_VEBUS_FLAG_VS_OFF_OVERLOAD_PRE_ALARM 0xE474

/** VS off ripple pre alarm {un8 = VS off ripple pre alarm, 0 = Off, 1 = On} */
#define VE_REG_VEBUS_FLAG_VS_OFF_RIPPLE_PRE_ALARM 0xE475

/** VS on when failure {un8 = VS on when failure, 0 = Off, 1 = On} */
#define VE_REG_VEBUS_FLAG_VS_ON_WHEN_FAILURE 0xE476

/** Invert VS behaviour {un8 = Invert VS behaviour, 0 = Off, 1 = On} */
#define VE_REG_VEBUS_FLAG_VS_INVERT 0xE477

/**
 * Accept wide input frequency {un8 = Accept wide input frequency, 0 = Off, 1 =
 * On}
 */
#define VE_REG_VEBUS_FLAG_WIDE_INPUT_FREQ 0xE478

/** Dynamic current limit {un8 = Dynamic current limit, 0 = Off, 1 = On} */
#define VE_REG_VEBUS_FLAG_DYNAMIC_CURRENT_LIMIT 0xE479

/**
 * Tubular plate traction curve {un8 = Tubular plate traction curve, 0 = Off, 1 =
 * On}
 */
#define VE_REG_VEBUS_FLAG_USE_TUBULAR_PLATE_CURVE 0xE47A

/** Remote overrules AC1 {un8 = Remote overrules AC1, 0 = Off, 1 = On} */
#define VE_REG_VEBUS_FLAG_REMOTE_OVERRULES_AC1 0xE47B

/** Low power shutdown in AES {un8 = Low power shutdown in AES, 0 = Off, 1 = On} */
#define VE_REG_VEBUS_FLAG_LOW_POWER_SHUTDOWN_IN_AES 0xE47C

/** VS2 off when AC1 available {un8 = VS2 off when AC1 available, 0 = Off, 1 = On} */
#define VE_REG_VEBUS_FLAG_VS2_OFF_WHEN_AC1_PRESENT 0xE47D

/** Invert VS2 behaviour {un8 = Invert VS2 behaviour, 0 = Off, 1 = On} */
#define VE_REG_VEBUS_FLAG_VS2_INVERT 0xE47E

/** Frequency changes by VS {un8 = Frequency changes by VS, 0 = Off, 1 = On} */
#define VE_REG_VEBUS_FLAG_INVERTER_PERIOD_BY_VS 0xE47F

/**
 * Frequency changes by U battery {un8 = Frequency changes by U battery, 0 = Off,
 * 1 = On}
 */
#define VE_REG_VEBUS_FLAG_INVERTER_PERIOD_BY_UBAT 0xE480

/** Lithium battery {un8 = Lithium battery, 0 = Off, 1 = On} */
#define VE_REG_VEBUS_FLAG_LITHIUM_BATTERY 0xE481

/** Allow enable feed in {un8 = Allow enable feed in, 0 = Off, 1 = On} */
#define VE_REG_VEBUS_FLAG_ALLOW_ENABLE_FEED_IN 0xE482

/**
 * {un32 = Energy from AcIn1 to Inverter [0.01kWh], 0xFFFFFFFF = Not Available,
 * This is the amount of energy before the charger (so without loses). The
 * internal resolution of these counters is roughly 0.0182kWh}
 */
#define VE_REG_VEBUS_ENERGY_FROM_ACIN1_TO_INVERTER 0xE483

/**
 * {un32 = Energy from AcIn2 to Inverter [0.01kWh], 0xFFFFFFFF = Not Available,
 * This is the amount of energy before the charger (so without loses)}
 */
#define VE_REG_VEBUS_ENERGY_FROM_ACIN2_TO_INVERTER 0xE484

/** {un32 = Energy from AcIn1 to AC-Out [0.01kWh], 0xFFFFFFFF = Not Available} */
#define VE_REG_VEBUS_ENERGY_FROM_ACIN1_TO_ACOUT 0xE485

/** {un32 = Energy from AcIn2 to AC-Out [0.01kWh], 0xFFFFFFFF = Not Available} */
#define VE_REG_VEBUS_ENERGY_FROM_ACIN2_TO_ACOUT 0xE486

/** {un32 = Energy from Inverter to AC-In1 [0.01kWh], 0xFFFFFFFF = Not Available} */
#define VE_REG_VEBUS_ENERGY_FROM_INVERTER_TO_ACIN1 0xE487

/** {un32 = Energy from Inverter to AC-In2 [0.01kWh], 0xFFFFFFFF = Not Available} */
#define VE_REG_VEBUS_ENERGY_FROM_INVERTER_TO_ACIN2 0xE488

/** {un32 = Energy from AC-out to AC-In1 [0.01kWh], 0xFFFFFFFF = Not Available} */
#define VE_REG_VEBUS_ENERGY_FROM_ACOUT_TO_ACIN1 0xE489

/** {un32 = Energy from AC-out to AC-In2 [0.01kWh], 0xFFFFFFFF = Not Available} */
#define VE_REG_VEBUS_ENERGY_FROM_ACOUT_TO_ACIN2 0xE48A

/** {un32 = Energy from Inverter to AC-Out [0.01kWh], 0xFFFFFFFF = Not Available} */
#define VE_REG_VEBUS_ENERGY_FROM_INVERTER_TO_ACOUT 0xE48B

/** {un32 = Energy from AC-Out to Inverter [0.01kWh], 0xFFFFFFFF = Not Available} */
#define VE_REG_VEBUS_ENERGY_FROM_ACOUT_TO_INVERTER 0xE48C

/** {un32 = } */
#define VE_REG_VEBUS_UNIQUE_NUMBER 0xE48D

/** {un8 = } */
#define VE_REG_VEBUS_SHORT_ADDRESS 0xE48F

/** Flags 0 settings {un16 = Flags 0 settings} */
#define VE_REG_VEBUS_SET_FLAGS_0 0xE490

/** Flags 1 settings {un16 = Flags 1 settings} */
#define VE_REG_VEBUS_SET_FLAGS_1 0xE491

/** Flags 2 settings {un16 = Flags 2 settings} */
#define VE_REG_VEBUS_SET_FLAGS_2 0xE492

/** Flags 3 settings {un16 = Flags 3 settings} */
#define VE_REG_VEBUS_SET_FLAGS_3 0xE493

/** {un8 = , 0 = Off, 1 = On} */
#define VE_REG_VEBUS_FLAG_NOT_PROMOTED_1 0xE494

/** {un8 = , 0 = Off, 1 = On} */
#define VE_REG_VEBUS_FLAG_NOT_PROMOTED_2 0xE495

/** {un8 = , 0 = Off, 1 = On} */
#define VE_REG_VEBUS_FLAG_NOT_PROMOTED_3 0xE496

/** Absorption voltage (min) {sn16 = Absorption voltage (min) [0.01V]} */
#define VE_REG_VEBUS_SET_U_BAT_ABSORPTION_MIN 0xE497

/** Absorption voltage (max) {sn16 = Absorption voltage (max) [0.01V]} */
#define VE_REG_VEBUS_SET_U_BAT_ABSORPTION_MAX 0xE498

/** Absorption voltage default {sn16 = Absorption voltage default [0.01V]} */
#define VE_REG_VEBUS_SET_U_BAT_ABSORPTION_DEFAULT 0xE499

/** Float voltage (min) {sn16 = Float voltage (min) [0.01V]} */
#define VE_REG_VEBUS_SET_U_BAT_FLOAT_MIN 0xE49A

/** Float voltage (max) {sn16 = Float voltage (max) [0.01V]} */
#define VE_REG_VEBUS_SET_U_BAT_FLOAT_MAX 0xE49B

/** Float voltage default {sn16 = Float voltage default [0.01V]} */
#define VE_REG_VEBUS_SET_U_BAT_FLOAT_DEFAULT 0xE49C

/** Maximum charge current (min) {sn16 = Maximum charge current (min) [0.01A]} */
#define VE_REG_VEBUS_SET_I_BAT_BULK_MIN 0xE49D

/** Maximum charge current (max) {sn16 = Maximum charge current (max) [0.01A]} */
#define VE_REG_VEBUS_SET_I_BAT_BULK_MAX 0xE49E

/** Maximum charge current default {sn16 = Maximum charge current default [0.01A]} */
#define VE_REG_VEBUS_SET_I_BAT_BULK_DEFAULT 0xE49F

/** Inverter output voltage (min) {sn16 = Inverter output voltage (min) [0.01V]} */
#define VE_REG_VEBUS_SET_U_INV_SETPOINT_MIN 0xE4A0

/** Inverter output voltage (max) {sn16 = Inverter output voltage (max) [0.01V]} */
#define VE_REG_VEBUS_SET_U_INV_SETPOINT_MAX 0xE4A1

/**
 * Inverter output voltage default {sn16 = Inverter output voltage default
 * [0.01V]}
 */
#define VE_REG_VEBUS_SET_U_INV_SETPOINT_DEFAULT 0xE4A2

/** AC1 current limit (min) {sn16 = AC1 current limit (min) [0.01A]} */
#define VE_REG_VEBUS_SET_I_MAINS_LIMIT_AC1_MIN 0xE4A3

/** AC1 current limit (max) {sn16 = AC1 current limit (max) [0.01A]} */
#define VE_REG_VEBUS_SET_I_MAINS_LIMIT_AC1_MAX 0xE4A4

/** AC1 current limit default {sn16 = AC1 current limit default [0.01A]} */
#define VE_REG_VEBUS_SET_I_MAINS_LIMIT_AC1_DEFAULT 0xE4A5

/** Repeated absorption time (min) {un16 = Repeated absorption time (min) [1min]} */
#define VE_REG_VEBUS_SET_REPEATED_ABSORPTION_TIME_MIN 0xE4A6

/** Repeated absorption time (max) {un16 = Repeated absorption time (max) [1min]} */
#define VE_REG_VEBUS_SET_REPEATED_ABSORPTION_TIME_MAX 0xE4A7

/**
 * Repeated absorption time default {un16 = Repeated absorption time default
 * [1min]}
 */
#define VE_REG_VEBUS_SET_REPEATED_ABSORPTION_TIME_DEFAULT 0xE4A8

/**
 * Repeated absorption interval (min) {un16 = Repeated absorption interval (min)
 * [1min]}
 */
#define VE_REG_VEBUS_SET_REPEATED_ABSORPTION_INTERVAL_MIN 0xE4A9

/**
 * Repeated absorption interval (max) {un16 = Repeated absorption interval (max)
 * [1min]}
 */
#define VE_REG_VEBUS_SET_REPEATED_ABSORPTION_INTERVAL_MAX 0xE4AA

/**
 * Repeated absorption interval default {un16 = Repeated absorption interval
 * default [1min]}
 */
#define VE_REG_VEBUS_SET_REPEATED_ABSORPTION_INTERVAL_DEFAULT 0xE4AB

/** Maximum absorption time (min) {un16 = Maximum absorption time (min) [1min]} */
#define VE_REG_VEBUS_SET_MAXIMUM_ABSORPTION_DURATION_MIN 0xE4AC

/** Maximum absorption time (max) {un16 = Maximum absorption time (max) [1min]} */
#define VE_REG_VEBUS_SET_MAXIMUM_ABSORPTION_DURATION_MAX 0xE4AD

/**
 * Maximum absorption time default {un16 = Maximum absorption time default
 * [1min]}
 */
#define VE_REG_VEBUS_SET_MAXIMUM_ABSORPTION_DURATION_DEFAULT 0xE4AE

/** Charge charasteristic (min) {un8 = Charge charasteristic (min)} */
#define VE_REG_VEBUS_SET_CHARGE_CHARACTERISTIC_MIN 0xE4AF

/** Charge charasteristic (max) {un8 = Charge charasteristic (max)} */
#define VE_REG_VEBUS_SET_CHARGE_CHARACTERISTIC_MAX 0xE4B0

/** Charge charasteristic default {un8 = Charge charasteristic default} */
#define VE_REG_VEBUS_SET_CHARGE_CHARACTERISTIC_DEFAULT 0xE4B1

/**
 * Inverter DC shutdown voltage (min) {sn16 = Inverter DC shutdown voltage (min)
 * [0.01V]}
 */
#define VE_REG_VEBUS_SET_U_BAT_LOW_LIMIT_FOR_INVERTER_MIN 0xE4B2

/**
 * Inverter DC shutdown voltage (max) {sn16 = Inverter DC shutdown voltage (max)
 * [0.01V]}
 */
#define VE_REG_VEBUS_SET_U_BAT_LOW_LIMIT_FOR_INVERTER_MAX 0xE4B3

/**
 * Inverter DC shutdown voltage default {sn16 = Inverter DC shutdown voltage
 * default [0.01V]}
 */
#define VE_REG_VEBUS_SET_U_BAT_LOW_LIMIT_FOR_INVERTER_DEFAULT 0xE4B4

/**
 * Inverter DC restart voltage (min) {sn16 = Inverter DC restart voltage (min)
 * [0.01V]}
 */
#define VE_REG_VEBUS_SET_UBAT_LOW_RESTART_LEVEL_FOR_INVERTER_MIN 0xE4B5

/**
 * Inverter DC restart voltage (max) {sn16 = Inverter DC restart voltage (max)
 * [0.01V]}
 */
#define VE_REG_VEBUS_SET_UBAT_LOW_RESTART_LEVEL_FOR_INVERTER_MAX 0xE4B6

/**
 * Inverter DC restart voltage default {sn16 = Inverter DC restart voltage
 * default [0.01V]}
 */
#define VE_REG_VEBUS_SET_UBAT_LOW_RESTART_LEVEL_FOR_INVERTER_DEFAULT 0xE4B7

/** Number of slaves connected (min) {un8 = Number of slaves connected (min)} */
#define VE_REG_VEBUS_SET_NUMBER_OF_SLAVES_CONNECTED_MIN 0xE4B8

/** Number of slaves connected (max) {un8 = Number of slaves connected (max)} */
#define VE_REG_VEBUS_SET_NUMBER_OF_SLAVES_CONNECTED_MAX 0xE4B9

/** Number of slaves connected default {un8 = Number of slaves connected default} */
#define VE_REG_VEBUS_SET_NUMBER_OF_SLAVES_CONNECTED_DEFAULT 0xE4BA

/** Special three phase setting (min) {un8 = Special three phase setting (min)} */
#define VE_REG_VEBUS_SET_SPECIAL_THREE_PHASE_SETTING_MIN 0xE4BB

/** Special three phase setting (max) {un8 = Special three phase setting (max)} */
#define VE_REG_VEBUS_SET_SPECIAL_THREE_PHASE_SETTING_MAX 0xE4BC

/**
 * Special three phase setting default {un8 = Special three phase setting
 * default}
 */
#define VE_REG_VEBUS_SET_SPECIAL_THREE_PHASE_SETTING_DEFAULT 0xE4BD

/** Virtual switch usage (min) {un8 = Virtual switch usage (min)} */
#define VE_REG_VEBUS_SET_VS_USAGE_MIN 0xE4BE

/** Virtual switch usage (max) {un8 = Virtual switch usage (max)} */
#define VE_REG_VEBUS_SET_VS_USAGE_MAX 0xE4BF

/** Virtual switch usage default {un8 = Virtual switch usage default} */
#define VE_REG_VEBUS_SET_VS_USAGE_DEFAULT 0xE4C0

/** VS on load higher than (min) {un16 = VS on load higher than (min) [1W]} */
#define VE_REG_VEBUS_SET_VS_ON_P_INV_HIGH_MIN 0xE4C1

/** VS on load higher than (max) {un16 = VS on load higher than (max) [1W]} */
#define VE_REG_VEBUS_SET_VS_ON_P_INV_HIGH_MAX 0xE4C2

/**
 * VS on load higher than (default) {un16 = VS on load higher than (default)
 * [1W]}
 */
#define VE_REG_VEBUS_SET_VS_ON_P_INV_HIGH_DEFAULT 0xE4C3

/**
 * VS on when U DC lower than (min) {sn16 = VS on when U DC lower than (min)
 * [0.01V]}
 */
#define VE_REG_VEBUS_SET_VS_ON_U_BAT_HIGH_MIN 0xE4C4

/**
 * VS on when U DC lower than (max) {sn16 = VS on when U DC lower than (max)
 * [0.01V]}
 */
#define VE_REG_VEBUS_SET_VS_ON_U_BAT_HIGH_MAX 0xE4C5

/**
 * VS on when U DC lower than (default) {sn16 = VS on when U DC lower than
 * (default) [0.01V]}
 */
#define VE_REG_VEBUS_SET_VS_ON_U_BAT_HIGH_DEFAULT 0xE4C6

/**
 * VS on when U DC higher than (min) {sn16 = VS on when U DC higher than (min)
 * [0.01V]}
 */
#define VE_REG_VEBUS_SET_VS_ON_U_BAT_LOW_MIN 0xE4C7

/**
 * VS on when U DC higher than (max) {sn16 = VS on when U DC higher than (max)
 * [0.01V]}
 */
#define VE_REG_VEBUS_SET_VS_ON_U_BAT_LOW_MAX 0xE4C8

/**
 * VS on when U DC higher than (default) {sn16 = VS on when U DC higher than
 * (default) [0.01V]}
 */
#define VE_REG_VEBUS_SET_VS_ON_U_BAT_LOW_DEFAULT 0xE4C9

/** VS time on load high (min) {un16 = VS time on load high (min) [1s]} */
#define VE_REG_VEBUS_SET_VS_TON_P_INV_HIGH_MIN 0xE4CA

/** VS time on load high (max) {un16 = VS time on load high (max) [1s]} */
#define VE_REG_VEBUS_SET_VS_TON_P_INV_HIGH_MAX 0xE4CB

/** VS time on load high (default) {un16 = VS time on load high (default) [1s]} */
#define VE_REG_VEBUS_SET_VS_TON_P_INV_HIGH_DEFAULT 0xE4CC

/**
 * VS time on DC voltage high (min) {un16 = VS time on DC voltage high (min)
 * [1s]}
 */
#define VE_REG_VEBUS_SET_VS_TON_U_BAT_HIGH_MIN 0xE4CD

/**
 * VS time on DC voltage high (max) {un16 = VS time on DC voltage high (max)
 * [1s]}
 */
#define VE_REG_VEBUS_SET_VS_TON_U_BAT_HIGH_MAX 0xE4CE

/**
 * VS time on DC voltage high (default) {un16 = VS time on DC voltage high
 * (default) [1s]}
 */
#define VE_REG_VEBUS_SET_VS_TON_U_BAT_HIGH_DEFAULT 0xE4CF

/** VS time on DC voltage low (min) {un16 = VS time on DC voltage low (min) [1s]} */
#define VE_REG_VEBUS_SET_VS_TON_U_BAT_LOW_MIN 0xE4D0

/** VS time on DC voltage low (max) {un16 = VS time on DC voltage low (max) [1s]} */
#define VE_REG_VEBUS_SET_VS_TON_U_BAT_LOW_MAX 0xE4D1

/**
 * VS time on DC voltage low (default) {un16 = VS time on DC voltage low
 * (default) [1s]}
 */
#define VE_REG_VEBUS_SET_VS_TON_U_BAT_LOW_DEFAULT 0xE4D2

/**
 * VS time on when not charging (min) {un16 = VS time on when not charging (min)
 * [1s]}
 */
#define VE_REG_VEBUS_SET_VS_TON_NOT_CHARGING_MIN 0xE4D3

/**
 * VS time on when not charging (max) {un16 = VS time on when not charging (max)
 * [1s]}
 */
#define VE_REG_VEBUS_SET_VS_TON_NOT_CHARGING_MAX 0xE4D4

/**
 * VS time on when not charging (default) {un16 = VS time on when not charging
 * (default) [1s]}
 */
#define VE_REG_VEBUS_SET_VS_TON_NOT_CHARGING_DEFAULT 0xE4D5

/** VS time on fan enabled (min) {un16 = VS time on fan enabled (min) [1s]} */
#define VE_REG_VEBUS_SET_VS_TON_FAN_ON_MIN 0xE4D6

/** VS time on fan enabled (max) {un16 = VS time on fan enabled (max) [1s]} */
#define VE_REG_VEBUS_SET_VS_TON_FAN_ON_MAX 0xE4D7

/**
 * VS time on fan enabled (default) {un16 = VS time on fan enabled (default)
 * [1s]}
 */
#define VE_REG_VEBUS_SET_VS_TON_FAN_ON_DEFAULT 0xE4D8

/**
 * VS time on temperature alarm (min) {un16 = VS time on temperature alarm (min)
 * [1s]}
 */
#define VE_REG_VEBUS_SET_VS_TON_TEMPERATURE_ALARM_MIN 0xE4D9

/**
 * VS time on temperature alarm (max) {un16 = VS time on temperature alarm (max)
 * [1s]}
 */
#define VE_REG_VEBUS_SET_VS_TON_TEMPERATURE_ALARM_MAX 0xE4DA

/**
 * VS time on temperature alarm (default) {un16 = VS time on temperature alarm
 * (default) [1s]}
 */
#define VE_REG_VEBUS_SET_VS_TON_TEMPERATURE_ALARM_DEFAULT 0xE4DB

/**
 * VS time on low battery alarm (min) {un16 = VS time on low battery alarm (min)
 * [1s]}
 */
#define VE_REG_VEBUS_SET_VS_TON_LOW_BATTERY_ALARM_MIN 0xE4DC

/**
 * VS time on low battery alarm (max) {un16 = VS time on low battery alarm (max)
 * [1s]}
 */
#define VE_REG_VEBUS_SET_VS_TON_LOW_BATTERY_ALARM_MAX 0xE4DD

/**
 * VS time on low battery alarm (default) {un16 = VS time on low battery alarm
 * (default) [1s]}
 */
#define VE_REG_VEBUS_SET_VS_TON_LOW_BATTERY_ALARM_DEFAULT 0xE4DE

/** VS time on overload alarm (min) {un16 = VS time on overload alarm (min) [1s]} */
#define VE_REG_VEBUS_SET_VS_TON_OVERLOAD_ALARM_MIN 0xE4DF

/** VS time on overload alarm (max) {un16 = VS time on overload alarm (max) [1s]} */
#define VE_REG_VEBUS_SET_VS_TON_OVERLOAD_ALARM_MAX 0xE4E0

/**
 * VS time on overload alarm (default) {un16 = VS time on overload alarm
 * (default) [1s]}
 */
#define VE_REG_VEBUS_SET_VS_TON_OVERLOAD_ALARM_DEFAULT 0xE4E1

/** VS time on ripple alarm (min) {un16 = VS time on ripple alarm (min) [1s]} */
#define VE_REG_VEBUS_SET_VS_TON_U_BATT_RIPPLE_ALARM_MIN 0xE4E2

/** VS time on ripple alarm (max) {un16 = VS time on ripple alarm (max) [1s]} */
#define VE_REG_VEBUS_SET_VS_TON_U_BATT_RIPPLE_ALARM_MAX 0xE4E3

/**
 * VS time on ripple alarm (default) {un16 = VS time on ripple alarm (default)
 * [1s]}
 */
#define VE_REG_VEBUS_SET_VS_TON_U_BATT_RIPPLE_ALARM_DEFAULT 0xE4E4

/** VS off load lower than (min) {un16 = VS off load lower than (min) [1W]} */
#define VE_REG_VEBUS_SET_VS_OFF_P_INV_LOW_MIN 0xE4E5

/** VS off load lower than (max) {un16 = VS off load lower than (max) [1W]} */
#define VE_REG_VEBUS_SET_VS_OFF_P_INV_LOW_MAX 0xE4E6

/**
 * VS off load lower than (default) {un16 = VS off load lower than (default)
 * [1W]}
 */
#define VE_REG_VEBUS_SET_VS_OFF_P_INV_LOW_DEFAULT 0xE4E7

/**
 * VS off when udc lower than (min) {sn16 = VS off when udc lower than (min)
 * [0.01V]}
 */
#define VE_REG_VEBUS_SET_VS_OFF_U_BAT_HIGH_MIN 0xE4E8

/**
 * VS off when udc lower than (max) {sn16 = VS off when udc lower than (max)
 * [0.01V]}
 */
#define VE_REG_VEBUS_SET_VS_OFF_U_BAT_HIGH_MAX 0xE4E9

/**
 * VS off when udc lower than (default) {sn16 = VS off when udc lower than
 * (default) [0.01V]}
 */
#define VE_REG_VEBUS_SET_VS_OFF_U_BAT_HIGH_DEFAULT 0xE4EA

/**
 * VS off when udc higher than (min) {sn16 = VS off when udc higher than (min)
 * [0.01V]}
 */
#define VE_REG_VEBUS_SET_VS_OFF_U_BAT_LOW_MIN 0xE4EB

/**
 * VS off when udc higher than (max) {sn16 = VS off when udc higher than (max)
 * [0.01V]}
 */
#define VE_REG_VEBUS_SET_VS_OFF_U_BAT_LOW_MAX 0xE4EC

/**
 * VS off when udc higher than (default) {sn16 = VS off when udc higher than
 * (default) [0.01V]}
 */
#define VE_REG_VEBUS_SET_VS_OFF_U_BAT_LOW_DEFAULT 0xE4ED

/** VS time off load low (min) {un16 = VS time off load low (min) [1s]} */
#define VE_REG_VEBUS_SET_VS_TOFF_P_INV_LOW_MIN 0xE4EE

/** VS time off load low (max) {un16 = VS time off load low (max) [1s]} */
#define VE_REG_VEBUS_SET_VS_TOFF_P_INV_LOW_MAX 0xE4EF

/** VS time off load low (default) {un16 = VS time off load low (default) [1s]} */
#define VE_REG_VEBUS_SET_VS_TOFF_P_INV_LOW_DEFAULT 0xE4F0

/**
 * VS time off DC voltage high (min) {un16 = VS time off DC voltage high (min)
 * [1s]}
 */
#define VE_REG_VEBUS_SET_VS_TOFF_U_BATT_HIGH_MIN 0xE4F1

/**
 * VS time off DC voltage high (max) {un16 = VS time off DC voltage high (max)
 * [1s]}
 */
#define VE_REG_VEBUS_SET_VS_TOFF_U_BATT_HIGH_MAX 0xE4F2

/**
 * VS time off DC voltage high (default) {un16 = VS time off DC voltage high
 * (default) [1s]}
 */
#define VE_REG_VEBUS_SET_VS_TOFF_U_BATT_HIGH_DEFAULT 0xE4F3

/**
 * VS time off DC voltage low (min) {un16 = VS time off DC voltage low (min)
 * [1s]}
 */
#define VE_REG_VEBUS_SET_VS_TOFF_U_BATT_LOW_MIN 0xE4F4

/**
 * VS time off DC voltage low (max) {un16 = VS time off DC voltage low (max)
 * [1s]}
 */
#define VE_REG_VEBUS_SET_VS_TOFF_U_BATT_LOW_MAX 0xE4F5

/**
 * VS time off DC voltage low (default) {un16 = VS time off DC voltage low
 * (default) [1s]}
 */
#define VE_REG_VEBUS_SET_VS_TOFF_U_BATT_LOW_DEFAULT 0xE4F6

/** VS off when charging for (min) {un16 = VS off when charging for (min) [1s]} */
#define VE_REG_VEBUS_SET_VS_TOFF_CHARGING_MIN 0xE4F7

/** VS off when charging for (max) {un16 = VS off when charging for (max) [1s]} */
#define VE_REG_VEBUS_SET_VS_TOFF_CHARGING_MAX 0xE4F8

/**
 * VS off when charging for (default) {un16 = VS off when charging for (default)
 * [1s]}
 */
#define VE_REG_VEBUS_SET_VS_TOFF_CHARGING_DEFAULT 0xE4F9

/** VS time off fan disabled (min) {un16 = VS time off fan disabled (min) [1s]} */
#define VE_REG_VEBUS_SET_VS_TOFF_FAN_OFF_MIN 0xE4FA

/** VS time off fan disabled (max) {un16 = VS time off fan disabled (max) [1s]} */
#define VE_REG_VEBUS_SET_VS_TOFF_FAN_OFF_MAX 0xE4FB

/**
 * VS time off fan disabled (default) {un16 = VS time off fan disabled (default)
 * [1s]}
 */
#define VE_REG_VEBUS_SET_VS_TOFF_FAN_OFF_DEFAULT 0xE4FC

/** VS off bulk finished for (min) {un16 = VS off bulk finished for (min) [1min]} */
#define VE_REG_VEBUS_SET_VS_TOFF_CHARGE_BULK_FINISHED_MIN 0xE4FD

/** VS off bulk finished for (max) {un16 = VS off bulk finished for (max) [1min]} */
#define VE_REG_VEBUS_SET_VS_TOFF_CHARGE_BULK_FINISHED_MAX 0xE4FE

/**
 * VS off bulk finished for (default) {un16 = VS off bulk finished for (default)
 * [1min]}
 */
#define VE_REG_VEBUS_SET_VS_TOFF_CHARGE_BULK_FINISHED_DEFAULT 0xE4FF

/**
 * VS off no ON condition for (min) {un16 = VS off no ON condition for (min)
 * [1min]}
 */
#define VE_REG_VEBUS_SET_VS_TOFF_NO_VSON_CONDITION_MIN 0xE500

/**
 * VS off no ON condition for (max) {un16 = VS off no ON condition for (max)
 * [1min]}
 */
#define VE_REG_VEBUS_SET_VS_TOFF_NO_VSON_CONDITION_MAX 0xE501

/**
 * VS off no ON condition for (default) {un16 = VS off no ON condition for
 * (default) [1min]}
 */
#define VE_REG_VEBUS_SET_VS_TOFF_NO_VSON_CONDITION_DEFAULT 0xE502

/**
 * VS off when no AC Input for (min) {un16 = VS off when no AC Input for (min)
 * [1s]}
 */
#define VE_REG_VEBUS_SET_VS_TOFF_NO_AC_INPUT_MIN 0xE503

/**
 * VS off when no AC Input for (max) {un16 = VS off when no AC Input for (max)
 * [1s]}
 */
#define VE_REG_VEBUS_SET_VS_TOFF_NO_AC_INPUT_MAX 0xE504

/**
 * VS off when no AC Input for (default) {un16 = VS off when no AC Input for
 * (default) [1s]}
 */
#define VE_REG_VEBUS_SET_VS_TOFF_NO_AC_INPUT_DEFAULT 0xE505

/**
 * VS off no temperature alarm (min) {un16 = VS off no temperature alarm (min)
 * [1s]}
 */
#define VE_REG_VEBUS_SET_VS_TOFF_TEMPERATURE_ALARM_MIN 0xE506

/**
 * VS off no temperature alarm (max) {un16 = VS off no temperature alarm (max)
 * [1s]}
 */
#define VE_REG_VEBUS_SET_VS_TOFF_TEMPERATURE_ALARM_MAX 0xE507

/**
 * VS off no temperature alarm (default) {un16 = VS off no temperature alarm
 * (default) [1s]}
 */
#define VE_REG_VEBUS_SET_VS_TOFF_TEMPERATURE_ALARM_DEFAULT 0xE508

/** VS off no battery alarm (min) {un16 = VS off no battery alarm (min) [1s]} */
#define VE_REG_VEBUS_SET_VS_TOFF_LOW_BATTERY_ALARM_MIN 0xE509

/** VS off no battery alarm (max) {un16 = VS off no battery alarm (max) [1s]} */
#define VE_REG_VEBUS_SET_VS_TOFF_LOW_BATTERY_ALARM_MAX 0xE50A

/**
 * VS off no battery alarm (default) {un16 = VS off no battery alarm (default)
 * [1s]}
 */
#define VE_REG_VEBUS_SET_VS_TOFF_LOW_BATTERY_ALARM_DEFAULT 0xE50B

/** VS off no overload alarm (min) {un16 = VS off no overload alarm (min) [1s]} */
#define VE_REG_VEBUS_SET_VS_TOFF_OVERLOAD_ALARM_MIN 0xE50C

/** VS off no overload alarm (max) {un16 = VS off no overload alarm (max) [1s]} */
#define VE_REG_VEBUS_SET_VS_TOFF_OVERLOAD_ALARM_MAX 0xE50D

/**
 * VS off no overload alarm (default) {un16 = VS off no overload alarm (default)
 * [1s]}
 */
#define VE_REG_VEBUS_SET_VS_TOFF_OVERLOAD_ALARM_DEFAULT 0xE50E

/** VS off no ripple alarm (min) {un16 = VS off no ripple alarm (min) [1s]} */
#define VE_REG_VEBUS_SET_VS_TOFF_U_BATT_RIPPLE_ALARM_MIN 0xE50F

/** VS off no ripple alarm (min) {un16 = VS off no ripple alarm (min) [1s]} */
#define VE_REG_VEBUS_SET_VS_TOFF_U_BATT_RIPPLE_ALARM_MAX 0xE510

/** VS off no ripple alarm (min) {un16 = VS off no ripple alarm (min) [1s]} */
#define VE_REG_VEBUS_SET_VS_TOFF_U_BATT_RIPPLE_ALARM_DEFAULT 0xE511

/** minimum on time (min) {un16 = minimum on time (min) [1min]} */
#define VE_REG_VEBUS_SET_VS_MINIMUM_ON_TIME_MIN 0xE512

/** minimum on time (max) {un16 = minimum on time (max) [1min]} */
#define VE_REG_VEBUS_SET_VS_MINIMUM_ON_TIME_MAX 0xE513

/** minimum on time (default) {un16 = minimum on time (default) [1min]} */
#define VE_REG_VEBUS_SET_VS_MINIMUM_ON_TIME_DEFAULT 0xE514

/** AC low switch input off (min) {sn16 = AC low switch input off (min) [0.01V]} */
#define VE_REG_VEBUS_SET_U_MAINS_LOW_DISCONNECT_MIN 0xE515

/** AC low switch input off (max) {sn16 = AC low switch input off (max) [0.01V]} */
#define VE_REG_VEBUS_SET_U_MAINS_LOW_DISCONNECT_MAX 0xE516

/**
 * AC low switch input off (default) {sn16 = AC low switch input off (default)
 * [0.01V]}
 */
#define VE_REG_VEBUS_SET_U_MAINS_LOW_DISCONNECT_DEFAULT 0xE517

/** AC low switch input on (min) {sn16 = AC low switch input on (min) [0.01V]} */
#define VE_REG_VEBUS_SET_U_MAINS_LOW_CONNECT_MIN 0xE518

/** AC low switch input on (max) {sn16 = AC low switch input on (max) [0.01V]} */
#define VE_REG_VEBUS_SET_U_MAINS_LOW_CONNECT_MAX 0xE519

/**
 * AC low switch input on (default) {sn16 = AC low switch input on (default)
 * [0.01V]}
 */
#define VE_REG_VEBUS_SET_U_MAINS_LOW_CONNECT_DEFAULT 0xE51A

/** AC high switch input on (min) {sn16 = AC high switch input on (min) [0.01V]} */
#define VE_REG_VEBUS_SET_U_MAINS_HIGH_DISCONNECT_MIN 0xE51B

/** AC high switch input on (max) {sn16 = AC high switch input on (max) [0.01V]} */
#define VE_REG_VEBUS_SET_U_MAINS_HIGH_DISCONNECT_MAX 0xE51C

/**
 * AC high switch input on (default) {sn16 = AC high switch input on (default)
 * [0.01V]}
 */
#define VE_REG_VEBUS_SET_U_MAINS_HIGH_DISCONNECT_DEFAULT 0xE51D

/** AC high switch input off (min) {sn16 = AC high switch input off (min) [0.01V]} */
#define VE_REG_VEBUS_SET_U_MAINS_HIGH_CONNECT_MIN 0xE51E

/** AC high switch input off (max) {sn16 = AC high switch input off (max) [0.01V]} */
#define VE_REG_VEBUS_SET_U_MAINS_HIGH_CONNECT_MAX 0xE51F

/**
 * AC high switch input off (default) {sn16 = AC high switch input off (default)
 * [0.01V]}
 */
#define VE_REG_VEBUS_SET_U_MAINS_HIGH_CONNECT_DEFAULT 0xE520

/** Assist current boost factor (min) {un8 = Assist current boost factor (min)} */
#define VE_REG_VEBUS_SET_ASSIST_CURRENT_BOOST_FACTOR_MIN 0xE521

/** Assist current boost factor (max) {un8 = Assist current boost factor (max)} */
#define VE_REG_VEBUS_SET_ASSIST_CURRENT_BOOST_FACTOR_MAX 0xE522

/**
 * Assist current boost factor (default) {un8 = Assist current boost factor
 * (default)}
 */
#define VE_REG_VEBUS_SET_ASSIST_CURRENT_BOOST_FACTOR_DEFAULT 0xE523

/** AC2 current limit (min) {sn16 = AC2 current limit (min) [0.01A]} */
#define VE_REG_VEBUS_SET_I_MAINS_LIMIT_AC2_MIN 0xE524

/** AC2 current limit (max) {sn16 = AC2 current limit (max) [0.01A]} */
#define VE_REG_VEBUS_SET_I_MAINS_LIMIT_AC2_MAX 0xE525

/** AC2 current limit (default) {sn16 = AC2 current limit (default) [0.01A]} */
#define VE_REG_VEBUS_SET_I_MAINS_LIMIT_AC2_DEFAULT 0xE526

/**
 * Power for switching to AES (min) {un16 = Power for switching to AES (min)
 * [1W]}
 */
#define VE_REG_VEBUS_SET_POWER_FOR_SWITCHING_TO_AES_MIN 0xE527

/**
 * Power for switching to AES (max) {un16 = Power for switching to AES (max)
 * [1W]}
 */
#define VE_REG_VEBUS_SET_POWER_FOR_SWITCHING_TO_AES_MAX 0xE528

/**
 * Power for switching to AES (default) {un16 = Power for switching to AES
 * (default) [1W]}
 */
#define VE_REG_VEBUS_SET_POWER_FOR_SWITCHING_TO_AES_DEFAULT 0xE529

/**
 * Power offset for ending AES mode (min) {un16 = Power offset for ending AES
 * mode (min) [1W]}
 */
#define VE_REG_VEBUS_SET_HYST_FOR_AES_POWER_MIN 0xE52A

/**
 * Power offset for ending AES mode (max) {un16 = Power offset for ending AES
 * mode (max) [1W]}
 */
#define VE_REG_VEBUS_SET_HYST_FOR_AES_POWER_MAX 0xE52B

/**
 * Power offset for ending AES mode (default) {un16 = Power offset for ending AES
 * mode (default) [1W]}
 */
#define VE_REG_VEBUS_SET_HYST_FOR_AES_POWER_DEFAULT 0xE52C

/** VS2 on load higher than (min) {un16 = VS2 on load higher than (min) [1W]} */
#define VE_REG_VEBUS_SET_VS_2_ON_P_LOAD_HIGH_LEVEL_MIN 0xE52D

/** VS2 on load higher than (max) {un16 = VS2 on load higher than (max) [1W]} */
#define VE_REG_VEBUS_SET_VS_2_ON_P_LOAD_HIGH_LEVEL_MAX 0xE52E

/**
 * VS2 on load higher than (default) {un16 = VS2 on load higher than (default)
 * [1W]}
 */
#define VE_REG_VEBUS_SET_VS_2_ON_P_LOAD_HIGH_LEVEL_DEFAULT 0xE52F

/** VS2 time on load high (min) {un16 = VS2 time on load high (min) [1s]} */
#define VE_REG_VEBUS_SET_VS_2_ON_I_LOAD_HIGH_TIME_MIN 0xE530

/** VS2 time on load high (max) {un16 = VS2 time on load high (max) [1s]} */
#define VE_REG_VEBUS_SET_VS_2_ON_I_LOAD_HIGH_TIME_MAX 0xE531

/** VS2 time on load high (default) {un16 = VS2 time on load high (default) [1s]} */
#define VE_REG_VEBUS_SET_VS_2_ON_I_LOAD_HIGH_TIME_DEFAULT 0xE532

/**
 * VS2 on lower DC voltage than (min) {sn16 = VS2 on lower DC voltage than (min)
 * [0.01V]}
 */
#define VE_REG_VEBUS_SET_VS_2_ON_U_BAT_LOW_LEVEL_MIN 0xE533

/**
 * VS2 on lower DC voltage than (max) {sn16 = VS2 on lower DC voltage than (max)
 * [0.01V]}
 */
#define VE_REG_VEBUS_SET_VS_2_ON_U_BAT_LOW_LEVEL_MAX 0xE534

/**
 * VS2 on lower DC voltage than (default) {sn16 = VS2 on lower DC voltage than
 * (default) [0.01V]}
 */
#define VE_REG_VEBUS_SET_VS_2_ON_U_BAT_LOW_LEVEL_DEFAULT 0xE535

/** VS2 on low DC voltage for (min) {un16 = VS2 on low DC voltage for (min) [1s]} */
#define VE_REG_VEBUS_SET_VS_2_ON_U_BAT_LOW_TIME_MIN 0xE536

/** VS2 on low DC voltage for (max) {un16 = VS2 on low DC voltage for (max) [1s]} */
#define VE_REG_VEBUS_SET_VS_2_ON_U_BAT_LOW_TIME_MAX 0xE537

/**
 * VS2 on low DC voltage for (deault) {un16 = VS2 on low DC voltage for (deault)
 * [1s]}
 */
#define VE_REG_VEBUS_SET_VS_2_ON_U_BAT_LOW_TIME_DEFAULT 0xE538

/** VS2 off load lower then (min) {un16 = VS2 off load lower then (min) [1W]} */
#define VE_REG_VEBUS_SET_VS_2_OFF_LOAD_LOW_LEVEL_MIN 0xE539

/** VS2 off load lower then (max) {un16 = VS2 off load lower then (max) [1W]} */
#define VE_REG_VEBUS_SET_VS_2_OFF_LOAD_LOW_LEVEL_MAX 0xE53A

/**
 * VS2 off load lower then (default) {un16 = VS2 off load lower then (default)
 * [1W]}
 */
#define VE_REG_VEBUS_SET_VS_2_OFF_LOAD_LOW_LEVEL_DEFAULT 0xE53B

/** VS2 off load lower for (min) {un16 = VS2 off load lower for (min) [1min]} */
#define VE_REG_VEBUS_SET_VS_2_OFF_LOAD_LOW_TIME_MIN 0xE53C

/** VS2 off load lower for (max) {un16 = VS2 off load lower for (max) [1min]} */
#define VE_REG_VEBUS_SET_VS_2_OFF_LOAD_LOW_TIME_MAX 0xE53D

/**
 * VS2 off load lower for (default) {un16 = VS2 off load lower for (default)
 * [1min]}
 */
#define VE_REG_VEBUS_SET_VS_2_OFF_LOAD_LOW_TIME_DEFAULT 0xE53E

/** VS2 off DC voltage high (min) {sn16 = VS2 off DC voltage high (min) [0.01V]} */
#define VE_REG_VEBUS_SET_VS_2_OFF_U_BAT_HIGH_LEVEL_MIN 0xE53F

/** VS2 off DC voltage high (max) {sn16 = VS2 off DC voltage high (max) [0.01V]} */
#define VE_REG_VEBUS_SET_VS_2_OFF_U_BAT_HIGH_LEVEL_MAX 0xE540

/**
 * VS2 off DC voltage high (default) {sn16 = VS2 off DC voltage high (default)
 * [0.01V]}
 */
#define VE_REG_VEBUS_SET_VS_2_OFF_U_BAT_HIGH_LEVEL_DEFAULT 0xE541

/** VS2 off DC voltage for (min) {un16 = VS2 off DC voltage for (min) [1min]} */
#define VE_REG_VEBUS_SET_VS_2_OFF_U_BAT_HIGH_TIME_MIN 0xE542

/** VS2 off DC voltage for (max) {un16 = VS2 off DC voltage for (max) [1min]} */
#define VE_REG_VEBUS_SET_VS_2_OFF_U_BAT_HIGH_TIME_MAX 0xE543

/**
 * VS2 off DC voltage for (default) {un16 = VS2 off DC voltage for (default)
 * [1min]}
 */
#define VE_REG_VEBUS_SET_VS_2_OFF_U_BAT_HIGH_TIME_DEFAULT 0xE544

/** VS Inverter period time (min) {un16 = VS Inverter period time (min) [0.001s]} */
#define VE_REG_VEBUS_SET_VS_INVERTER_PERIOD_TIME_MIN 0xE545

/** VS Inverter period time (max) {un16 = VS Inverter period time (max) [0.001s]} */
#define VE_REG_VEBUS_SET_VS_INVERTER_PERIOD_TIME_MAX 0xE546

/**
 * VS Inverter period time (default) {un16 = VS Inverter period time (default)
 * [0.001s]}
 */
#define VE_REG_VEBUS_SET_VS_INVERTER_PERIOD_TIME_DEFAULT 0xE547

/** Low DC alarm level (min) {sn16 = Low DC alarm level (min) [0.01V]} */
#define VE_REG_VEBUS_SET_U_BAT_LOW_PRE_ALARM_LEVEL_MIN 0xE548

/** Low DC alarm level (max) {sn16 = Low DC alarm level (max) [0.01V]} */
#define VE_REG_VEBUS_SET_U_BAT_LOW_PRE_ALARM_LEVEL_MAX 0xE549

/** Low DC alarm level (default) {sn16 = Low DC alarm level (default) [0.01V]} */
#define VE_REG_VEBUS_SET_U_BAT_LOW_PRE_ALARM_LEVEL_DEFAULT 0xE54A

/** Battery capacity (min) {un16 = Battery capacity (min) [Ah]} */
#define VE_REG_VEBUS_SET_BATTERY_CAPACITY_MIN 0xE54B

/** Battery capacity (max) {un16 = Battery capacity (max) [Ah]} */
#define VE_REG_VEBUS_SET_BATTERY_CAPACITY_MAX 0xE54C

/** Battery capacity (default) {un16 = Battery capacity (default) [Ah]} */
#define VE_REG_VEBUS_SET_BATTERY_CAPACITY_DEFAULT 0xE54D

/** SOC when bulk finisihed (min) {un8 = SOC when bulk finisihed (min) [1%]} */
#define VE_REG_VEBUS_SET_BATTERY_CHARGE_PERCENTAGE_MIN 0xE54E

/** SOC when bulk finisihed (max) {un8 = SOC when bulk finisihed (max) [1%]} */
#define VE_REG_VEBUS_SET_BATTERY_CHARGE_PERCENTAGE_MAX 0xE54F

/**
 * SOC when bulk finisihed (default) {un8 = SOC when bulk finisihed (default)
 * [1%]}
 */
#define VE_REG_VEBUS_SET_BATTERY_CHARGE_PERCENTAGE_DEFAULT 0xE550

/**
 * Frequency shift U bat start (min) {sn16 = Frequency shift U bat start (min)
 * [0.01V]}
 */
#define VE_REG_VEBUS_SET_SHIFT_UBAT_START_MIN 0xE551

/**
 * Frequency shift U bat start (max) {sn16 = Frequency shift U bat start (max)
 * [0.01V]}
 */
#define VE_REG_VEBUS_SET_SHIFT_UBAT_START_MAX 0xE552

/**
 * Frequency shift U bat start (default) {sn16 = Frequency shift U bat start
 * (default) [0.01V]}
 */
#define VE_REG_VEBUS_SET_SHIFT_UBAT_START_DEFAULT 0xE553

/**
 * Frequency shift U bat start delay (min) {un16 = Frequency shift U bat start
 * delay (min) [1s]}
 */
#define VE_REG_VEBUS_SET_SHIFT_UBAT_START_DELAY_MIN 0xE554

/**
 * Frequency shift U bat start delay (max) {un16 = Frequency shift U bat start
 * delay (max) [1s]}
 */
#define VE_REG_VEBUS_SET_SHIFT_UBAT_START_DELAY_MAX 0xE555

/**
 * Frequency shift U bat start delay (default) {un16 = Frequency shift U bat
 * start delay (default) [1s]}
 */
#define VE_REG_VEBUS_SET_SHIFT_UBAT_START_DELAY_DEFAULT 0xE556

/**
 * Frequency shift U bat stop (min) {sn16 = Frequency shift U bat stop (min)
 * [0.01V]}
 */
#define VE_REG_VEBUS_SET_SHIFT_UBAT_STOP_MIN 0xE557

/**
 * Frequency shift U bat stop (max) {sn16 = Frequency shift U bat stop (max)
 * [0.01V]}
 */
#define VE_REG_VEBUS_SET_SHIFT_UBAT_STOP_MAX 0xE558

/**
 * Frequency shift U bat stop (default) {sn16 = Frequency shift U bat stop
 * (default) [0.01V]}
 */
#define VE_REG_VEBUS_SET_SHIFT_UBAT_STOP_DEFAULT 0xE559

/**
 * Frequency shift U bat stop delay (min) {un16 = Frequency shift U bat stop
 * delay (min) [1s]}
 */
#define VE_REG_VEBUS_SET_SHIFT_UBAT_STOP_DELAY_MIN 0xE55A

/**
 * Frequency shift U bat stop delay (max) {un16 = Frequency shift U bat stop
 * delay (max) [1s]}
 */
#define VE_REG_VEBUS_SET_SHIFT_UBAT_STOP_DELAY_MAX 0xE55B

/**
 * Frequency shift U bat stop delay (default) {un16 = Frequency shift U bat stop
 * delay (default) [1s]}
 */
#define VE_REG_VEBUS_SET_SHIFT_UBAT_STOP_DELAY_DEFAULT 0xE55C

/** VS2 on SOC level (min) {un8 = VS2 on SOC level (min) [1%]} */
#define VE_REG_VEBUS_SET_VS2_ON_SOC_MIN 0xE55D

/** VS2 on SOC level (max) {un8 = VS2 on SOC level (max) [1%]} */
#define VE_REG_VEBUS_SET_VS2_ON_SOC_MAX 0xE55E

/** VS2 on SOC level (default) {un8 = VS2 on SOC level (default) [1%]} */
#define VE_REG_VEBUS_SET_VS2_ON_SOC_DEFAULT 0xE55F

/**
 * Assistant temperature compensation (min) {sn16 = Assistant temperature
 * compensation (min) [0.01°C]}
 */
#define VE_REG_VEBUS_SET_VLL_TEMP_COMPENSATION_MIN 0xE560

/**
 * Assistant temperature compensation (max) {sn16 = Assistant temperature
 * compensation (max) [0.01°C]}
 */
#define VE_REG_VEBUS_SET_VLL_TEMP_COMPENSATION_MAX 0xE561

/**
 * Assistant temperature compensation (default) {sn16 = Assistant temperature
 * compensation (default) [0.01°C]}
 */
#define VE_REG_VEBUS_SET_VLL_TEMP_COMPENSATION_DEFAULT 0xE562

/** Charge efficiency (min) {un16 = Charge efficiency (min) [0.01]} */
#define VE_REG_VEBUS_SET_CHARGE_EFFICIENCY_MIN 0xE563

/** Charge efficiency (max) {un16 = Charge efficiency (max) [0.01]} */
#define VE_REG_VEBUS_SET_CHARGE_EFFICIENCY_MAX 0xE564

/** Charge efficiency (default) {un16 = Charge efficiency (default) [0.01]} */
#define VE_REG_VEBUS_SET_CHARGE_EFFICIENCY_DEFAULT 0xE565

/** Flags 0 settings (min) {un16 = Flags 0 settings (min)} */
#define VE_REG_VEBUS_SET_FLAGS_0_MIN 0xE566

/** Flags 0 settings (max) {un16 = Flags 0 settings (max)} */
#define VE_REG_VEBUS_SET_FLAGS_0_MAX 0xE567

/** Flags 0 settings (default) {un16 = Flags 0 settings (default)} */
#define VE_REG_VEBUS_SET_FLAGS_0_DEFAULT 0xE568

/** Flags 1 settings (min) {un16 = Flags 1 settings (min)} */
#define VE_REG_VEBUS_SET_FLAGS_1_MIN 0xE569

/** Flags 1 settings (max) {un16 = Flags 1 settings (max)} */
#define VE_REG_VEBUS_SET_FLAGS_1_MAX 0xE56A

/** Flags 1 settings (default) {un16 = Flags 1 settings (default)} */
#define VE_REG_VEBUS_SET_FLAGS_1_DEFAULT 0xE56B

/** Flags 2 settings (min) {un16 = Flags 2 settings (min)} */
#define VE_REG_VEBUS_SET_FLAGS_2_MIN 0xE56C

/** Flags 2 settings (max) {un16 = Flags 2 settings (max)} */
#define VE_REG_VEBUS_SET_FLAGS_2_MAX 0xE56D

/** Flags 2 settings (default) {un16 = Flags 2 settings (default)} */
#define VE_REG_VEBUS_SET_FLAGS_2_DEFAULT 0xE56E

/** Flags 3 settings (min) {un16 = Flags 3 settings (min)} */
#define VE_REG_VEBUS_SET_FLAGS_3_MIN 0xE56F

/** Flags 3 settings (max) {un16 = Flags 3 settings (max)} */
#define VE_REG_VEBUS_SET_FLAGS_3_MAX 0xE570

/** Flags 3 settings (default) {un16 = Flags 3 settings (default)} */
#define VE_REG_VEBUS_SET_FLAGS_3_DEFAULT 0xE571

/**
 * Ve.Bus device reset required {un8 = Ve.Bus device reset required, 0 = Off, 1 =
 * On}
 * 1 if vebus device indicates that a reset is required after changing a setting
 */
#define VE_REG_VEBUS_INFO_RESET_REQUIRED 0xE572

/**
 * Ve.Bus device access level required {un8 = Ve.Bus device access level
 * required}
 * Returns the required access level after a (failed) attempt to write a password
 * protected setting
 */
#define VE_REG_VEBUS_INFO_ACCESS_LEVEL_REQUIRED 0xE573

/**
 * Ve.Bus reset all vebus devices {un8 = Ve.Bus reset all vebus devices, 0 = Off,
 * 1 = On}
 */
#define VE_REG_VEBUS_SYSTEM_RESET 0xE574

/**
 * Send a blocking command to other MK2 based devices {un8 = Send a blocking
 * command to other MK2 based devices, 0 = Off, 1 = On}
 */
#define VE_REG_VEBUS_BLOCK_OTHER_MK2_BASED_DEVICES 0xE575

/**
 * Switch over info connecting phase L1 {un8 = Switch over info connecting phase
 * L1, 0 = Off, 1 = On}
 * True if grid is accepted and delay is counting down
 */
#define VE_REG_VEBUS_SWITCH_OVER_INFO_L1_CONNECTING 0xE576

/**
 * Delay in seconds before L1 backfeed relay will close {un16 = Delay in seconds
 * before L1 backfeed relay will close [s]}
 */
#define VE_REG_VEBUS_SWITCH_OVER_INFO_L1_DELAY 0xE577

/**
 * Max delay in seconds before L1 backfeed relay will close {un16 = Max delay in
 * seconds before L1 backfeed relay will close [s]}
 */
#define VE_REG_VEBUS_SWITCH_OVER_INFO_L1_DELAY_MAX 0xE578

/**
 * The reason why the grid is rejected for phase L1 {un8 = The reason why the
 * grid is rejected for phase L1 (see xml for meanings)}
 */
#define VE_REG_VEBUS_SWITCH_OVER_INFO_L1_ERROR_FLAGS 0xE579

/**
 * Switch over info connecting phase L2 {un8 = Switch over info connecting phase
 * L2, 0 = Off, 1 = On}
 * True if grid is accepted and delay is counting down
 */
#define VE_REG_VEBUS_SWITCH_OVER_INFO_L2_CONNECTING 0xE57A

/**
 * Delay in seconds before L2 backfeed relay will close {un16 = Delay in seconds
 * before L2 backfeed relay will close [s]}
 */
#define VE_REG_VEBUS_SWITCH_OVER_INFO_L2_DELAY 0xE57B

/**
 * Max delay in seconds before L2 backfeed relay will close {un16 = Max delay in
 * seconds before L2 backfeed relay will close [s]}
 */
#define VE_REG_VEBUS_SWITCH_OVER_INFO_L2_DELAY_MAX 0xE57C

/**
 * The reason why the grid is rejected for phase L2 {un8 = The reason why the
 * grid is rejected for phase L2 (see xml for meanings)}
 */
#define VE_REG_VEBUS_SWITCH_OVER_INFO_L2_ERROR_FLAGS 0xE57D

/**
 * Switch over info connecting phase L3 {un8 = Switch over info connecting phase
 * L3, 0 = Off, 1 = On}
 * True if grid is accepted and delay is counting down
 */
#define VE_REG_VEBUS_SWITCH_OVER_INFO_L3_CONNECTING 0xE57E

/**
 * Delay in seconds before L3 backfeed relay will close {un16 = Delay in seconds
 * before L3 backfeed relay will close [s]}
 */
#define VE_REG_VEBUS_SWITCH_OVER_INFO_L3_DELAY 0xE57F

/**
 * Max delay in seconds before L3 backfeed relay will close {un16 = Max delay in
 * seconds before L3 backfeed relay will close [s]}
 */
#define VE_REG_VEBUS_SWITCH_OVER_INFO_L3_DELAY_MAX 0xE580

/**
 * The reason why the grid is rejected for phase L3 {un8 = The reason why the
 * grid is rejected for phase L3 (see xml for meanings)}
 */
#define VE_REG_VEBUS_SWITCH_OVER_INFO_L3_ERROR_FLAGS 0xE581

/**
 * VeBus phase rotation alarm {un8 = VeBus phase rotation alarm, 0 = ok, 1 =
 * warning}
 */
#define VE_REG_VEBUS_ALARM_PHASE_ROTATION 0xE582

/**
 * VeBus status ignore AC input {un8 = VeBus status ignore AC input, 0 = AC input
 * not ignored, 1 = AC input ignored}
 */
#define VE_REG_VEBUS_STATUS_IGNORE_AC_INPUT 0xE583

/**
 * VeBus status ignore AC input 1 {un8 = VeBus status ignore AC input 1, 0 = AC
 * input not ignored, 1 = AC input ignored}
 */
#define VE_REG_VEBUS_STATUS_IGNORE_AC_INPUT_1 0xE584

/**
 * VeBus status ignore AC input 2 {un8 = VeBus status ignore AC input 2, 0 = AC
 * input not ignored, 1 = AC input ignored}
 */
#define VE_REG_VEBUS_STATUS_IGNORE_AC_INPUT_2 0xE585

/**
 * VeBus status split phase L2 passthru  {un8 = VeBus status split phase L2
 * passthru , 0 = L2 not passed through, 1 = L2 passed through}
 */
#define VE_REG_VEBUS_STATUS_SPLIT_PHASE_L2_PASSTHRU 0xE586

/** Tester potmeter/encoder value {un8 = Tester potmeter/encoder value} */
#define VE_REG_MPPT_TST_GET_DIO 0xEE7E

/** Tester keypad analog scan value {un8 = Tester keypad analog scan value} */
#define VE_REG_MPPT_TST_GET_KEYBRD 0xEE7F

/** Tester get factory settings checksum, should be 0xAA55 if calibrated. */
#define VE_REG_PPP_TST_CHECKSUM 0xEE7E

#define VE_REG_PPP_TST_BUTTON 0xEE7F

/** Returns the stack usage {un32 = Stack usage} */
#define VE_REG_SMART_LITHIUM_TST_STACK_USAGE 0xEE7E

/**
 * Sets/Returns the GPIO state {un32 = GPIO values, bit 0: allowedToCharge, bit
 * 1: allowedToDischarge, 0, bit2: noPreAlarm: off, 1:on}
 */
#define VE_REG_SMART_LITHIUM_TST_GPIO_STATE 0xEE7F

/** Returns the stack usage {un32 = Stack usage} */
#define VE_REG_SBS_TST_STACK_USAGE 0xEE7E

/** Returns the stack usage {un32 = Stack usage} */
#define VE_REG_VEDIRECT_BLE_TST_STACK_USAGE 0xEE7F

/**
 * Lynx Ion last errors . {un8 = err0 (see xml for meanings) : un8 = err1 (see
 * xml for meanings) : un8 = err2 (see xml for meanings) : un8 = err3 (see xml
 * for meanings)}
 * @deprecated Use VE_REG_BMS_LAST_ERRORS instead
 */
#define VE_REG_LYNX_ION_LAST_ERROR 0xEEFE

/**
 * Lynx Ion consumed AH (same as VE_REG_BMV_CE)
 * @deprecated Use VE_REG_CONSUMED_AH instead
 */
#define VE_REG_LYNX_ION_CE 0xEEFF

/**
 * Lynx Ion battery flags {bits[1] = Charged, 0 = No, 1 = Yes : bits[1] = Almost
 * Charged, 0 = No, 1 = Yes : bits[1] = Discharged, 0 = No, 1 = Yes : bits[1] =
 * Almost Discharged, 0 = No, 1 = Yes : bits[1] = Charging, 0 = No, 1 = Yes :
 * bits[1] = Discharging, 0 = No, 1 = Yes : bits[1] = Balancing, 0 = No, 1 = Yes
 * : bits[1] = Relay Discharged, 0 = No, 1 = Yes : bits[1] = Relay Charged, 0 =
 * No, 1 = Yes : bits[1] = Alarm Over Voltage, 0 = No, 1 = Yes : bits[1] =
 * Warning Over Voltage, 0 = No, 1 = Yes : bits[1] = Alarm Under Voltage, 0 = No,
 * 1 = Yes : bits[1] = Warning Under Voltage, 0 = No, 1 = Yes : bits[1] = Warning
 * Charge Current, 0 = No, 1 = Yes : bits[1] = Warning Discharge Current, 0 = No,
 * 1 = Yes : bits[1] = Alarm Over Temperature, 0 = No, 1 = Yes : bits[1] =
 * Warning Over Temperature, 0 = No, 1 = Yes : bits[1] = Warning Under
 * Temperature (Charge), 0 = No, 1 = Yes : bits[1] = Alarm Under Temperature
 * (Charge), 0 = No, 1 = Yes : bits[1] = Warning Under Temperature (Discharge), 0
 * = No, 1 = Yes : bits[1] = Alarm Under Temperature (Discharge), 0 = No, 1 = Yes
 * : bits[1] = Low SOC, 0 = No, 1 = Yes}
 * @deprecated Use VE_REG_BMS_FLAGS instead
 */
#define VE_REG_LYNX_ION_FLAGS 0x0370

/** Lynx Ion BMS state {un8 = State (see xml for meanings)} */
#define VE_REG_LYNX_ION_BMS_STATE 0x0371

/**
 * {un32 = Lynx Ion BMS error (see xml for meanings)}
 * Note that this is a value, not a bit mask. @deprecated Use VE_REG_BMS_ERROR
 * instead
 */
#define VE_REG_LYNX_ION_BMS_ERROR_FLAGS 0x0372

/**
 * Lynx Ion BMS synchronize group (internal) {un8 = Group, The group to
 * synchronize}
 * Used to synchronize multiple Lynx Ion BMS-es in parallel
 */
#define VE_REG_LYNX_ION_BMS_SYNCHRONIZE 0x0373

/**
 * Lynx Ion BMS startup on charge detect setting (internal) {un8 = Startup on
 * charge detect, 0 = Off, 1 = On}
 * When this settings is enabled (default), the Lynx Ion BMS will automatically
 * startup when user voltage rises above ~18V
 */
#define VE_REG_LYNX_ION_BMS_STARTUP_ON_CHARGE_DETECT 0x0375

/** Lynx Ion BMS synchronize group number setting (internal) {un8 = Group} */
#define VE_REG_LYNX_ION_BMS_SYNCHRONIZE_GROUP_NUMBER 0x0374

/**
 * Lynx Ion BMS battery strategy setting (internal) {un8 = Strategy, 0 = default,
 * 1 = performance}
 */
#define VE_REG_LYNX_ION_BMS_BATTERY_STRATEGY 0x0376

/**
 * Lynx Ion BMS combined mode setting (internal) {un8 = Combined, 0 = Off, 1 =
 * On}
 * When this setting is enabled, the Lynx Ion BMS will not automatically close
 * the contactor, only on command from the user
 */
#define VE_REG_LYNX_ION_BMS_COMBINED 0x0377

/**
 * Lynx Ion BMS combined state (internal) {un8 = State, 1 = pre-charging, 2 =
 * running}
 * This message is only broadcasted by the Lynx Ion BMS that is pre-charging or
 * in running state, this is to let other devices know to not start on request
 * anymore
 */
#define VE_REG_LYNX_ION_BMS_COMBINED_STATE 0x0378

/** Lynx Ion BMS restart request (internal) */
#define VE_REG_LYNX_ION_BMS_RESTART_REQUEST 0x0379

/**
 * Lynx Ion BMS combined control output voltage (internal) {un32 = Voltage
 * [0.01V], 0xFFFFFFFF = Output not active}
 */
#define VE_REG_LYNX_ION_BMS_VOLTAGE 0x037A

/**
 * Lynx Ion number of shutdowns caused by error (internal) {un16 = Lynx Ion
 * number of shutdowns caused by error}
 */
#define VE_REG_LYNX_ION_SHUTDOWNS_DUE_ERROR 0xEEFC

/**
 * Lynx Ion battery extended flags (internal) {un32 = Lynx Ion battery extended
 * flags}
 * @deprecated Has never been used
 */
#define VE_REG_LYNX_ION_FLAGS_EXT 0xEEFD

/** Internal temperature. {un16 = Internal temperature. [0.01K]} */
#define VE_REG_LYNX_SHUNT_INTERNAL_TEMPERATURE 0xEE60

/** Use to send NACK on CAN bus to indicate invalid calibration values (no data) */
#define VE_REG_LYNX_SHUNT_CALIBRATION 0xEE61

/**
 * {un32 = Energy from AcIn1 to Inverter [0.01kWh], 0xFFFFFFFF = Not Available,
 * This is the amount of energy before the charger (so without loses). The
 * internal resolution of these counters is roughly 0.0182kWh}
 */
#define VE_REG_ENERGY_FROM_ACIN1_TO_INVERTER 0xEEC0

/**
 * {un32 = Energy from AcIn2 to Inverter [0.01kWh], 0xFFFFFFFF = Not Available,
 * This is the amount of energy before the charger (so without loses)}
 */
#define VE_REG_ENERGY_FROM_ACIN2_TO_INVERTER 0xEEC1

/** {un32 = Energy from AcIn1 to AC-Out [0.01kWh], 0xFFFFFFFF = Not Available} */
#define VE_REG_ENERGY_FROM_ACIN1_TO_ACOUT 0xEEC2

/** {un32 = Energy from AcIn2 to AC-Out [0.01kWh], 0xFFFFFFFF = Not Available} */
#define VE_REG_ENERGY_FROM_ACIN2_TO_ACOUT 0xEEC3

/** {un32 = Energy from Inverter to AC-In1 [0.01kWh], 0xFFFFFFFF = Not Available} */
#define VE_REG_ENERGY_FROM_INVERTER_TO_ACIN1 0xEEC4

/** {un32 = Energy from Inverter to AC-In2 [0.01kWh], 0xFFFFFFFF = Not Available} */
#define VE_REG_ENERGY_FROM_INVERTER_TO_ACIN2 0xEEC5

/** {un32 = Energy from AC-out to AC-In1 [0.01kWh], 0xFFFFFFFF = Not Available} */
#define VE_REG_ENERGY_FROM_ACOUT_TO_ACIN1 0xEEC6

/** {un32 = Energy from AC-out to AC-In2 [0.01kWh], 0xFFFFFFFF = Not Available} */
#define VE_REG_ENERGY_FROM_ACOUT_TO_ACIN2 0xEEC7

/** {un32 = Energy from Inverter to AC-Out [0.01kWh], 0xFFFFFFFF = Not Available} */
#define VE_REG_ENERGY_FROM_INVERTER_TO_ACOUT 0xEEC8

/** {un32 = Energy from AC-Out to Inverter [0.01kWh], 0xFFFFFFFF = Not Available} */
#define VE_REG_ENERGY_FROM_ACOUT_TO_INVERTER 0xEEC9

/**
 * Read / write. Reports / sets the maximum charge current in 0.1A. the unit is
 * to be compatible with the charger settings in 0xED. Vebus actually uses 1A.
 * {un16 = Read / write. Reports / sets the maximum charge current in 0.1A. the
 * unit is to be compatible with the charger settings in 0xED. Vebus actually
 * uses 1A.}
 */
#define VE_REG_MK2CAN_MAX_CHARGE_CURRENT 0xEEFE

/** Vebus error {un8 = Vebus error} */
#define VE_REG_MK2CAN_VEBUS_ERROR 0xEEFF

/**
 * Tester dio pin value
 *               @remark value: B1=control, B0=mains
 *              {un8 = value}
 */
#define VE_REG_SCB_TST_GET_DIO 0xEE7C

/**
 * Tester dip-switch value
 *               @remark value: bit mask B5..B0=dip switches 1..6
 *              {un8 = value}
 */
#define VE_REG_SCB_TST_GET_DIPSW 0xEE7E

/**
 * Tester rotary switch value value: bit mask
 * B7=update,B6=equalise,B5=remote,B4=power,B3..B0=rotary encoder {un8 = value}
 */
#define VE_REG_SCB_TST_GET_ROTARY 0xEE7F

/** Tester ambient light value {un16 = value} */
#define VE_REG_SRP_TST_GET_LDR 0xEE7C

/** Tester potmeter/encoder value {un16 = value} */
#define VE_REG_SRP_TST_GET_POT 0xEE7E

/** value: B2=setup (rear),B1=power,B0=encoder" */
#define VE_REG_SRP_TST_GET_SWITCH 0xEE7F

/** Smart BatteryProtect - Operational mode {un8 = mode, 0 = Normal, 1 = Li-ion} */
#define VE_REG_BPR_MODE 0xE900

/**
 * Smart BatteryProtect - Under voltage profile {un8 = profile (see xml for
 * meanings)}
 */
#define VE_REG_BPR_PROFILE 0xE901

/**
 * Smart BatteryProtect - Internal temperature {un16 = Smart BatteryProtect -
 * Internal temperature [0.01K]}
 */
#define VE_REG_BPR_TEMPERATURE 0xE902

/**
 * Smart BatteryProtect - Tester is calibrated {un8 = calibrated, 0 = no, 1 =
 * yes}
 */
#define VE_REG_BPR_TST_IS_CALIBRATED 0xEE7E

/**
 * Smart BatteryProtect - Tester get button {bits[1] = Prog, 0 = Off, 1 = On :
 * bits[1] = Remote, 0 = Off, 1 = On}
 */
#define VE_REG_BPR_TST_BUTTON 0xEE7F

/** Smart BMS - Tester is calibrated {un8 = calibrated, 0 = no, 1 = yes} */
#define VE_REG_SMART_BMS_TST_IS_CALIBRATED 0xEE7E

/**
 * Smart BMS - Tester get input {bits[1] = Over Temperature, 0 = Off, 1 = On :
 * bits[1] = Allow to Charge BMS, 0 = Off, 1 = On : bits[1] = Allow to Discharge
 * BMS, 0 = Off, 1 = On : bits[1] = Pre-alarm BMS, 0 = Off, 1 = On}
 */
#define VE_REG_SMART_BMS_TST_INPUT 0xEE70

/**
 * Smart BMS - Tester get output {bits[1] = Shutdown, 0 = Off, 1 = On : bits[1] =
 * Allow to Discharge, 0 = Off, 1 = On : bits[1] = Allow to Charge, 0 = Off, 1 =
 * On : bits[1] = Enable Charge, 0 = Off, 1 = On : bits[1] = Enable Pre-alarm, 0
 * = Off, 1 = On}
 */
#define VE_REG_SMART_BMS_TST_OUTPUT 0xEE71

/**
 * Smart BMS - Tester get charge current {un16 = Smart BMS - Tester get charge
 * current [0.1A]}
 */
#define VE_REG_SMART_BMS_TST_ICHARGE 0xEE72

/** Smart BMS - Tester Fuse type {un8 = type (see xml for meanings)} */
#define VE_REG_SMART_BMS_TST_FUSE_TYPE 0xEE73

/** Smart BMS - Tester get button {bits[1] = Remote, 0 = Off, 1 = On} */
#define VE_REG_SMART_BMS_TST_BUTTON 0xEE7F

/**
 * Orion Smart LED State {un32 = Orion Smart LED State}
 * e.g. for VictronConnect to mimic LED behaviour . 3 bits reserved per LED; from
 * lsb to msb: init, ble. States: 0:blinkSlowInverted, 1:off, 2:on, 3:blink,
 * 4:blinkSlow, 5:blinkFast, 6:blinkFastInverted, 7:blinkInverted.
 */
#define VE_REG_ORION_LED_STATE 0xE000

/** Output setpoint {un16 = Output setpoint [0.01V]} */
#define VE_REG_ORION_TST_OUTPUT_SETPOINT 0xEE40

/** Output offset {un16 = Output offset [0.01V]} */
#define VE_REG_ORION_TST_OUTPUT_OFFSET 0xEE50

/** Output gain {un16 = Output gain} */
#define VE_REG_ORION_TST_OUTPUT_GAIN 0xEE60

/** Raw pwm output value {un16 = Raw pwm output value, 0-1000} */
#define VE_REG_ORION_TST_OUTPUT_RAW 0xEE70

/** Tester is calibrated {un8 = Tester is calibrated, 0=no, 1=yes;} */
#define VE_REG_ORION_TST_IS_CALIBRATED 0xEE30

/**
 * Tester get current limiter active {un8 = Tester get current limiter active,
 * 0=no, 1=yes, 255= unknown/invalid;}
 */
#define VE_REG_ORION_TST_CURR_LIMITER_ACTIVE 0xEE31

/**
 * Tester get allow to charge status . 0:not allowed; 1:allowed {un8 = Tester get
 * allow to charge status . 0:not allowed; 1:allowed}
 */
#define VE_REG_ORION_TST_ALLOW_TO_CHARGE 0xEE32

/**
 * Tester get PTC status . 0:no high temperature; 1:high temperature {un8 =
 * Tester get PTC status . 0:no high temperature; 1:high temperature}
 */
#define VE_REG_ORION_TST_PTC 0xEE33

/**
 * Tester get shutdown detection status . 0:no shutdown detected; 1:shutdown
 * detected {un8 = Tester get shutdown detection status . 0:no shutdown detected;
 * 1:shutdown detected}
 */
#define VE_REG_ORION_TST_SHUTDOWN_DETECTION 0xEE34

/**
 * Tester get remote on/off status . 0:off; 1:on {un8 = Tester get remote on/off
 * status . 0:off; 1:on}
 */
#define VE_REG_ORION_TST_REMOTE_ON_OFF 0xEE35

/**
 * Engine shutdown detection set threshold {un16 = Engine shutdown detection set
 * threshold [0.01V], 0xFFFF = Not Available}
 */
#define VE_REG_ENGINE_SHUTDOWN_DETECT_SET 0xEE36

/**
 * Engine shutdown detection clear threshold {un16 = Engine shutdown detection
 * clear threshold [0.01V], 0xFFFF = Not Available}
 */
#define VE_REG_ENGINE_SHUTDOWN_DETECT_CLEAR 0xEE37

/**
 * Engine shutdown detection clear delayed threshold {un16 = Engine shutdown
 * detection clear delayed threshold [0.01V], 0xFFFF = Not Available}
 */
#define VE_REG_ENGINE_SHUTDOWN_DELAYED_DETECT_CLEAR 0xEE38

/**
 * Engine shutdown detection clear delay {un32 = Engine shutdown detection clear
 * delay [1s], 0xFFFFFFFF = Not Available}
 */
#define VE_REG_ENGINE_SHUTDOWN_DETECT_CLEAR_DELAY 0xEE39

/** {un8 = Tester get the relay state (0 = closed, 1 = open)} */
#define VE_REG_VEBUS_SMART_TST_GET_MAINS_DETECT 0xEE7B

/** {un8 = Tester get the relay state (0 = closed, 1 = open)} */
#define VE_REG_VEBUS_SMART_TST_GET_RELAY 0xEE7C

/** Returns the stack usage {un32 = Stack usage} */
#define VE_REG_VEBUS_SMART_TST_STACK_USAGE 0xEE7E

/** {un8 = MK3 production test state} */
#define VE_REG_VEBUS_SMART_TST_MK3_TEST_STATE 0xEE7F

/**
 * Tester VBat channel measured voltage {sn16 = Tester VBat channel measured
 * voltage [0.01V]}
 */
#define VE_REG_VEBUS_SMART_TST_MEAS_GET_VBAT 0xEE80

/**
 * Tester VBat low pass filtered measured voltage {sn16 = Tester VBat low pass
 * filtered measured voltage [0.01V]}
 */
#define VE_REG_VEBUS_SMART_TST_MEAS_GET_VBAT_LP 0xEE81

/**
 * Tester temperature reference measured voltage {sn16 = Tester temperature
 * reference measured voltage [0.01V]}
 */
#define VE_REG_VEBUS_SMART_TST_MEAS_GET_TEMP_REF 0xEE82

/**
 * Tester temperature channel measured voltage {sn16 = Tester temperature channel
 * measured voltage [0.01V]}
 */
#define VE_REG_VEBUS_SMART_TST_MEAS_GET_TEMP 0xEE83

/** Tester VBat channel ADC calibration offset {sn16 = value} */
#define VE_REG_VEBUS_SMART_TST_ADC_CAL_OFFSET_VBAT 0xEEA0

/** Tester VBat low pass filtered channel ADC calibration offset {sn16 = value} */
#define VE_REG_VEBUS_SMART_TST_ADC_CAL_OFFSET_VBAT_LP 0xEEA1

/** Tester temperature reference channel ADC calibration offset {sn16 = value} */
#define VE_REG_VEBUS_SMART_TST_ADC_CAL_OFFSET_TEMP_REF 0xEEA2

/** Tester temperature channel ADC calibration offset {sn16 = value} */
#define VE_REG_VEBUS_SMART_TST_ADC_CAL_OFFSET_TEMP 0xEEA3

/** Tester VBat channel ADC calibration gain {sn16 = value} */
#define VE_REG_VEBUS_SMART_TST_ADC_CAL_GAIN_VBAT 0xEEC0

/** Tester VBat low pass filtered channel ADC calibration gain {sn16 = value} */
#define VE_REG_VEBUS_SMART_TST_ADC_CAL_GAIN_VBAT_LP 0xEEC1

/** Tester temperature reference channel ADC calibration gain {sn16 = value} */
#define VE_REG_VEBUS_SMART_TST_ADC_CAL_GAIN_TEMP_REF 0xEEC2

/** Tester temperature channel ADC calibration gain {sn16 = value} */
#define VE_REG_VEBUS_SMART_TST_ADC_CAL_GAIN_TEMP 0xEEC3

/** Tester VBat channel raw ADC value {un16 = raw adc value} */
#define VE_REG_VEBUS_SMART_TST_ADC_GET_RAW_VBAT 0xEEE0

/** Tester VBat low pass filtered channel raw ADC value {un16 = raw adc value} */
#define VE_REG_VEBUS_SMART_TST_ADC_GET_RAW_VBAT_LP 0xEEE1

/** Tester temperature reference channel raw ADC value {un16 = raw adc value} */
#define VE_REG_VEBUS_SMART_TST_ADC_GET_RAW_TEMP_REF 0xEEE2

/** Tester temperature channel raw ADC value {un16 = raw adc value} */
#define VE_REG_VEBUS_SMART_TST_ADC_GET_RAW_TEMP 0xEEE3

/** Tester ADC voltage reference channel raw ADC value {un16 = raw adc value} */
#define VE_REG_VEBUS_SMART_TST_ADC_GET_RAW_REFERENCE 0xEEE4

/**
 * Orion Smart - Vcc voltage (debug) {un16 = Orion Smart - Vcc voltage (debug)
 * [0.01V]}
 */
#define VE_REG_ORION_SMART_VCC_VOLTAGE 0xEE20

/**
 * Orion Smart - Signal frequency of the output voltage measurement (debug) {un16
 * = Orion Smart - Signal frequency of the output voltage measurement (debug)
 * [1Hz]}
 */
#define VE_REG_ORION_SMART_OUTPUT_VOLTAGE_SIG_FREQ 0xEE21

/**
 * Orion Smart - Output voltage setpoint (debug) {un16 = Orion Smart - Output
 * voltage setpoint (debug) [0.01V]}
 */
#define VE_REG_ORION_SMART_OUTPUT_VOLTAGE_SETPOINT 0xEE22

/**
 * Orion Smart - Time being on the current charger state (debug) {un32 = Orion
 * Smart - Time being on the current charger state (debug) [1s]}
 */
#define VE_REG_ORION_SMART_CURRENT_STATE_TIME 0xEE23

/**
 * Orion Smart - Time being on the condition to stop the charger algorithm
 * (debug) {un32 = Orion Smart - Time being on the condition to stop the charger
 * algorithm (debug) [1s]}
 */
#define VE_REG_ORION_SMART_CHARGER_TIMEOUT_TIME 0xEE24

/** IMPULSE-II L Smart - Chopper duty cycle (filtered) {sn32 = Duty cycle} */
#define VE_REG_IMPULSE_II_L_CHOPPER_DUTY_CYCLE 0xD000

/** IMPULSE-II L Smart - Chopper frequency {sn32 = Frequency} */
#define VE_REG_IMPULSE_II_L_CHOPPER_FREQUENCY 0xD001

/** IMPULSE-II L Smart - Chopper duty cycle (estimated) {sn32 = Duty cycle} */
#define VE_REG_IMPULSE_II_L_CHOPPER_DUTY_CYCLE_EST 0xD002

/** IMPULSE-II L Smart - Chopper duty cycle (raw) {sn32 = Duty cycle} */
#define VE_REG_IMPULSE_II_L_CHOPPER_DUTY_CYCLE_RAW 0xD003

/** IMPULSE-II L Smart - Nr. of chopper edges in buffer {un32 = Edges} */
#define VE_REG_IMPULSE_II_L_CHOPPER_EDGES 0xD004

/** IMPULSE-II L Smart - Nr. of full chopper periods in buffer {un32 = Periods} */
#define VE_REG_IMPULSE_II_L_CHOPPER_PERIODS 0xD005

/** IMPULSE-II L Smart - Nr. of skipped chopper periods in buffer {un32 = Periods} */
#define VE_REG_IMPULSE_II_L_CHOPPER_PERIODS_SKIPPED 0xD006

/**
 * IMPULSE-II L Smart - Accumulated nr. of skipped chopper periods {un32 =
 * Periods}
 */
#define VE_REG_IMPULSE_II_L_CHOPPER_PERIODS_SKIPPED_ACCUMULATED 0xD007

/**
 * MultiC 2-wire BMS input {bits[1] = 2-Wire input Enabled, 0 = Off, 1 = On :
 * bits[1] = Allow to Discharge, 0 = Off, 1 = On : bits[1] = Allow to Charge, 0 =
 * Off, 1 = On : bits[1] = reserved 3, 0 = No, 1 = Yes : bits[1] = reserved 4, 0
 * = No, 1 = Yes : bits[1] = reserved 5, 0 = No, 1 = Yes : bits[1] = reserved 6,
 * 0 = No, 1 = Yes : bits[1] = reserved 7, 0 = No, 1 = Yes}
 */
#define VE_REG_MULTIC_2WIRE_BMS 0xD01F

/** MultiC Actual SOC limit {un16 = soc [0.01%], 0xFFFF = not available} */
#define VE_REG_MULTIC_ACTUAL_SOC_LIMIT 0xD03A

/** MultiC ESS actual constant discharge {un16 = power [1W]} */
#define VE_REG_MULTIC_ACTUAL_CONSTANT_DISCHARGE 0xD03B

/**
 * MultiC ACIN grid code {un8 = code, 0x00 = GRID_CODE_NONE, 0x01 =
 * GRID_CODE_OTHER, 0x02 = GRID_CODE_OTHER_NBYP}
 */
#define VE_REG_MULTIC_ACIN_GRID_CODE 0xD040

/**
 * MultiC ACIN1 LOM detection) {un8 = lom, 0x00 = LOM_DISABLED, 0x01 =
 * LOM_TYPE_A, 0x02 = LOM_TYPE_B}
 */
#define VE_REG_MULTIC_ACIN1_LOM_DETECTION 0xD041

/**
 * MultiC ACIN2 LOM detection {un8 = lom, 0x00 = LOM_DISABLED, 0x01 = LOM_TYPE_A,
 * 0x02 = LOM_TYPE_B}
 */
#define VE_REG_MULTIC_ACIN2_LOM_DETECTION 0xD042

/**
 * MultiC ACIN high voltage disconnect {un16 = MultiC ACIN high voltage
 * disconnect [0.01V]}
 */
#define VE_REG_MULTIC_ACIN_HIGH_VOLTAGE_DISCONNECT 0xD043

/**
 * MultiC ACIN high voltage connect {un16 = MultiC ACIN high voltage connect
 * [0.01V]}
 */
#define VE_REG_MULTIC_ACIN_HIGH_VOLTAGE_CONNECT 0xD044

/**
 * MultiC ACIN low voltage connect {un16 = MultiC ACIN low voltage connect
 * [0.01V]}
 */
#define VE_REG_MULTIC_ACIN_LOW_VOLTAGE_CONNECT 0xD045

/**
 * MultiC ACIN low voltage disconnect {un16 = MultiC ACIN low voltage disconnect
 * [0.01V]}
 */
#define VE_REG_MULTIC_ACIN_LOW_VOLTAGE_DISCONNECT 0xD046

/**
 * MultiC ACIN behaviour {bits[1] = AcceptWideInputFrequencyRange, 0 = No, 1 =
 * Yes : bits[1] = UPSfunction, 0 = No, 1 = Yes : bits[1] = AutoConnect, 0 = No,
 * 1 = Yes : bits[1] = reserved 3, 0 = No, 1 = Yes : bits[1] = reserved 4, 0 =
 * No, 1 = Yes : bits[1] = reserved 5, 0 = No, 1 = Yes : bits[1] = reserved 6, 0
 * = No, 1 = Yes : bits[1] = reserved 7, 0 = No, 1 = Yes}
 */
#define VE_REG_MULTIC_ACIN_BEHAVIOUR 0xD047

/** MultiC network configuration {un8 = freq} */
#define VE_REG_MULTIC_NETWORK_CONFIGURATION 0xD048

/** MultiC phase assignment (0=L1,1=L2,2=L3) {un8 = phase} */
#define VE_REG_MULTIC_AC_PHASE 0xD049

/**
 * MultiC ACIN connection count-down {un32 = MultiC ACIN connection count-down
 * [0.001s], 0xFFFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_ACIN_CONNECT_COUNTDOWN 0xD04E

/**
 * MultiC ESS mode {un8 = mode, 0x00 = OPTIMIZED_WITH_BATTERYLIFE, 0x01 =
 * OPTIMIZED_WITHOUT_BATTERYLIFE, 0x02 = KEEP_BATTERIES_CHARGED, 0x03 =
 * EXTERNAL_CONTROL}
 */
#define VE_REG_MULTIC_ESS_MODE 0xD050

/** MultiC ESS constant discharge {un16 = power [1W]} */
#define VE_REG_MULTIC_ESS_CONSTANT_DISCHARGE 0xD051

/** MultiC ESS voltage ofsset {un16 = voltage [0.001V]} */
#define VE_REG_MULTIC_ESS_VOLTAGE_OFFSET 0xD052

/** MultiC ESS discharge soc {un16 = soc [0.1%]} */
#define VE_REG_MULTIC_ESS_DISCHARGE_SOC 0xD053

/** MultiC ESS AC power setpoint {sn16 = power [1W]} */
#define VE_REG_MULTIC_ESS_AC_POWER_SETPOINT 0xD054

/** MultiC ESS options {un16 = options} */
#define VE_REG_MULTIC_ESS_OPTIONS 0xD055

/** MultiC ESS flags {un16 = flags} */
#define VE_REG_MULTIC_ESS_FLAGS 0xD056

/**
 * MultiC inverter shutdown on battery state-of-charge {un8 = mode, 0 = Disabled,
 * 1 = Enabled}
 */
#define VE_REG_MULTIC_INVERTER_SHUTDOWN_ON_SOC 0xD057

/** MultiC Inverter SOC low shutdown {un16 = soc [0.1%]} */
#define VE_REG_MULTIC_INVERTER_SOC_LOW_SHUTDOWN 0xD058

/** MultiC Inverter SOC low restart {un16 = soc [0.1%]} */
#define VE_REG_MULTIC_INVERTER_SOC_LOW_RESTART 0xD059

/** MultiC minimum number of inverters {un16 = inverters} */
#define VE_REG_MULTIC_CAN_MIN_INVERTERS 0xD05C

/** MultiC aux in1 function {un8 = function (see xml for meanings)} */
#define VE_REG_MULTIC_AUX_IN1_FUNCTION 0xD061

/** MultiC aux in2 function {un8 = function (see xml for meanings)} */
#define VE_REG_MULTIC_AUX_IN2_FUNCTION 0xD062

/**
 * MultiC ac input 1 current limit overruled by remote {un8 = overruled, 0 = No,
 * 1 = Yes}
 */
#define VE_REG_MULTIC_ACIN1_CURRENT_LIMIT_OVERRULED_BY_REMOTE 0xD063

/**
 * MultiC ac input 2 current limit overruled by remote {un8 = overruled, 0 = No,
 * 1 = Yes}
 */
#define VE_REG_MULTIC_ACIN2_CURRENT_LIMIT_OVERRULED_BY_REMOTE 0xD064

/** MultiC ESS ACIN High Voltage Limit {un16 = voltage [0.01V]} */
#define VE_REG_MULTIC_ESS_ACIN_HIGH_VOLTAGE_LIMIT 0xD066

/**
 * Generator relay polarity {un8 = polarity, 0 = close relay to start generator,
 * 1 = open relay to start generator}
 */
#define VE_REG_GENERATOR_RELAY_POLARITY 0xD06D

/**
 * Generator options {bits[1] = start on load conditions, 0 = No, 1 = Yes :
 * bits[1] = start on low battery voltage, 0 = No, 1 = Yes : bits[1] = start on
 * low state of charge, 0 = No, 1 = Yes : bits[1] = use a minimum run-time for
 * the generator, 0 = No, 1 = Yes : bits[1] = reserved 4, 0 = No, 1 = Yes :
 * bits[1] = reserved 5, 0 = No, 1 = Yes : bits[1] = reserved 6, 0 = No, 1 = Yes
 * : bits[1] = reserved 7, 0 = No, 1 = Yes}
 */
#define VE_REG_GENERATOR_OPTIONS 0xD06E

/** Generator start - load above power {un16 = power [1W], 0xFFFF = Not Available} */
#define VE_REG_GENERATOR_START_LOAD_ABOVE_POWER 0xD06F

/**
 * Generator start - load above power time {un16 = time [1s], 0xFFFF = Not
 * Available}
 */
#define VE_REG_GENERATOR_START_LOAD_ABOVE_POWER_TIME 0xD070

/** Generator stop - load below power {un16 = power [1W], 0xFFFF = Not Available} */
#define VE_REG_GENERATOR_STOP_LOAD_BELOW_POWER 0xD071

/**
 * Generator stop - load below power time {un16 = time [1s], 0xFFFF = Not
 * Available}
 */
#define VE_REG_GENERATOR_STOP_LOAD_BELOW_POWER_TIME 0xD072

/**
 * Generator start - battery voltage source {un8 = source, 0x00 = temperature
 * compensated battery sense, 0x01 = uncompensated battery sense, 0x02 = DC
 * input}
 */
#define VE_REG_GENERATOR_BATTERY_VOLTAGE_START_SOURCE 0xD073

/**
 * Generator start - battery below voltage {un16 = Voltage [0.01V], 0xFFFF = Not
 * Available}
 */
#define VE_REG_GENERATOR_START_BATTERY_BELOW_VOLTAGE 0xD074

/**
 * Generator start - battery below voltage time {un16 = time [1s], 0xFFFF = Not
 * Available}
 */
#define VE_REG_GENERATOR_START_BATTERY_BELOW_VOLTAGE_TIME 0xD075

/**
 * Generator start - below state of charge {un16 = soc [0.1%], 0xFFFF = Not
 * Available}
 */
#define VE_REG_GENERATOR_START_BELOW_STATE_OF_CHARGE 0xD076

/**
 * Generator stop condition {un8 = condition, 0 = battery voltage higher than a
 * certain level, 1 = state of charge higher than a certain level, 2 = bulk
 * charge state finished for a certain time, 3 = absorption charge state finished
 * for a certain time}
 */
#define VE_REG_GENERATOR_BATTERY_STOP_CONDITION 0xD077

/**
 * Generator stop - battery voltage source {un8 = source, 0x00 = temperature
 * compensated battery sense, 0x01 = uncompensated battery sense, 0x02 = DC
 * input}
 */
#define VE_REG_GENERATOR_BATTERY_VOLTAGE_STOP_SOURCE 0xD078

/**
 * Generator stop - battery above voltage {un16 = Voltage [0.01V], 0xFFFF = Not
 * Available}
 */
#define VE_REG_GENERATOR_STOP_BATTERY_ABOVE_VOLTAGE 0xD079

/**
 * Generator stop - battery above voltage time {un16 = time [1s], 0xFFFF = Not
 * Available}
 */
#define VE_REG_GENERATOR_STOP_BATTERY_ABOVE_VOLTAGE_TIME 0xD07A

/**
 * Generator stop - above state of charge {un16 = soc [0.1%], 0xFFFF = Not
 * Available}
 */
#define VE_REG_GENERATOR_STOP_ABOVE_STATE_OF_CHARGE 0xD07B

/**
 * Generator stop - after bulk charge state finished {un16 = time [1s], 0xFFFF =
 * Not Available}
 */
#define VE_REG_GENERATOR_STOP_AFTER_BULK_FINISHED 0xD07C

/**
 * Generator stop - after aborption charge state finished {un16 = time [1s],
 * 0xFFFF = Not Available}
 */
#define VE_REG_GENERATOR_STOP_AFTER_ABSORPTION_FINISHED 0xD07D

/** Generator minimum on time {un16 = time [1s], 0xFFFF = Not Available} */
#define VE_REG_GENERATOR_MINIMUM_ON_TIME 0xD07E

/**
 * Generator stop when AC available {un8 = condition, 0 = the generator is not
 * stopped by AC input, 1 = the generator is stopped when AC1 is available, 2 =
 * the generator is stopped when AC2 is available}
 */
#define VE_REG_GENERATOR_STOP_WHEN_AC_AVAILABLE 0xD07F

/**
 * MultiC AES mode {un8 = data, 0x00 = AES_DISABLED, 0x01 =
 * AES_MODIFIED_SINE_WAVE, 0x02 = AES_SEARCH_MODE}
 */
#define VE_REG_MULTIC_AES_MODE 0xD091

/**
 * MultiC AES start below {un16 = MultiC AES start below [1W], 0xFFFF = Not
 * Available}
 */
#define VE_REG_MULTIC_AES_START_BELOW 0xD092

/**
 * MultiC AES stop offset {un16 = MultiC AES stop offset [1W], 0xFFFF = Not
 * Available}
 */
#define VE_REG_MULTIC_AES_STOP_OFFSET 0xD093

/**
 * MultiC Display operation mode {un8 = mode, 0 = End user, 1 = Development, 2 =
 * Demo}
 */
#define VE_REG_MULTIC_DISPLAY_MODE 0xD0C1

/**
 * MultiC buzzer configuration {un8 = mode, 0 = Buzzer disabled, 1 = Buzzer
 * enabled}
 */
#define VE_REG_MULTIC_BUZZER_CONFIG 0xD0C2

/**
 * MultiC protections configuration {bits[1] = PVRISO protection, 0 = No, 1 = Yes
 * : bits[1] = GFCI protection, 0 = No, 1 = Yes : bits[1] = Over-charge
 * protection, 0 = No, 1 = Yes : bits[1] = Ground relay protection, 0 = No, 1 =
 * Yes : bits[1] = ACIN relay protection, 0 = No, 1 = Yes : bits[1] = reserved 5,
 * 0 = No, 1 = Yes : bits[1] = reserved 6, 0 = No, 1 = Yes : bits[1] = reserved
 * 7, 0 = No, 1 = Yes}
 */
#define VE_REG_MULTIC_PROTECTIONS 0xD0C3

/** MultiC ground relay {un8 = mode, 0 = Off, 1 = Auto} */
#define VE_REG_MULTIC_GROUND_RELAY 0xD0C4

/** MultiC monitor PE Neutral voltage {un8 = mode, 0 = Disabled, 1 = Enabled} */
#define VE_REG_MULTIC_MONITOR_PE_NEUTRAL_VOLTAGE 0xD0C7

/** MultiC protection restart delay {un16 = Time [0.05s], 0xFFFF = Not Available} */
#define VE_REG_MULTIC_PROTECTION_RESTART_DELAY 0xD130

/** MultiC protection clear delay {un16 = Time [0.05s], 0xFFFF = Not Available} */
#define VE_REG_MULTIC_PROTECTION_CLEAR_DELAY 0xD131

/**
 * MultiC protection restart delay long {un16 = Time [0.05s], 0xFFFF = Not
 * Available}
 */
#define VE_REG_MULTIC_PROTECTION_RESTART_DELAY_LONG 0xD132

/**
 * MultiC protection Vbat low warn delay {un16 = Time [0.05s], 0xFFFF = Not
 * Available}
 */
#define VE_REG_MULTIC_PROTECTION_VBAT_LOW_WARN_DELAY 0xD133

/**
 * MultiC protection Vbat low error delay {un16 = Time [0.05s], 0xFFFF = Not
 * Available}
 */
#define VE_REG_MULTIC_PROTECTION_VBAT_LOW_ERROR_DELAY 0xD134

/**
 * MultiC protection Vbat low restart time {un16 = Time [0.05s], 0xFFFF = Not
 * Available}
 */
#define VE_REG_MULTIC_PROTECTION_VBAT_LOW_RESTART_TIME 0xD135

/** MultiC protection Vbat low restart attempts {un16 = Attempts} */
#define VE_REG_MULTIC_PROTECTION_VBAT_LOW_RESTART_ATTEMPTS 0xD136

/** MultiC MPPT Partial shading {un8 = data, 0 = none, 1 = smart} */
#define VE_REG_MULTIC_MPPT_PARTIAL_SHADING 0xD4D7

/**
 * {un32 = Energy from AcIn1 to Inverter [0.01kWh], 0xFFFFFFFF = Not Available,
 * This is the amount of energy before the charger (so without loses). The
 * internal resolution of these counters is roughly 0.0182kWh}
 */
#define VE_REG_MULTIC_ENERGY_FROM_ACIN1_TO_INVERTER 0xD5C0

/**
 * {un32 = Energy from AcIn2 to Inverter [0.01kWh], 0xFFFFFFFF = Not Available,
 * This is the amount of energy before the charger (so without loses)}
 */
#define VE_REG_MULTIC_ENERGY_FROM_ACIN2_TO_INVERTER 0xD5C1

/** {un32 = Energy from AcIn1 to AC-Out [0.01kWh], 0xFFFFFFFF = Not Available} */
#define VE_REG_MULTIC_ENERGY_FROM_ACIN1_TO_ACOUT 0xD5C2

/** {un32 = Energy from AcIn2 to AC-Out [0.01kWh], 0xFFFFFFFF = Not Available} */
#define VE_REG_MULTIC_ENERGY_FROM_ACIN2_TO_ACOUT 0xD5C3

/** {un32 = Energy from Inverter to AC-In1 [0.01kWh], 0xFFFFFFFF = Not Available} */
#define VE_REG_MULTIC_ENERGY_FROM_INVERTER_TO_ACIN1 0xD5C4

/** {un32 = Energy from Inverter to AC-In2 [0.01kWh], 0xFFFFFFFF = Not Available} */
#define VE_REG_MULTIC_ENERGY_FROM_INVERTER_TO_ACIN2 0xD5C5

/** {un32 = Energy from AC-out to AC-In1 [0.01kWh], 0xFFFFFFFF = Not Available} */
#define VE_REG_MULTIC_ENERGY_FROM_ACOUT_TO_ACIN1 0xD5C6

/** {un32 = Energy from AC-out to AC-In2 [0.01kWh], 0xFFFFFFFF = Not Available} */
#define VE_REG_MULTIC_ENERGY_FROM_ACOUT_TO_ACIN2 0xD5C7

/** {un32 = Energy from AC-Out to Inverter [0.01kWh], 0xFFFFFFFF = Not Available} */
#define VE_REG_MULTIC_ENERGY_FROM_ACOUT_TO_INVERTER 0xD5C9

/** {un32 = Energy from Solar to Battery [0.01kWh], 0xFFFFFFFF = Not Available} */
#define VE_REG_MULTIC_ENERGY_FROM_SOLAR_TO_BATTERY 0xD5CA

/** {un32 = Energy from Solar to AC-Out [0.01kWh], 0xFFFFFFFF = Not Available} */
#define VE_REG_MULTIC_ENERGY_FROM_SOLAR_TO_ACOUT 0xD5CB

/** {un32 = Energy from Solar to AC-In1 [0.01kWh], 0xFFFFFFFF = Not Available} */
#define VE_REG_MULTIC_ENERGY_FROM_SOLAR_TO_ACIN1 0xD5CC

/** {un32 = Energy from Solar to AC-In2 [0.01kWh], 0xFFFFFFFF = Not Available} */
#define VE_REG_MULTIC_ENERGY_FROM_SOLAR_TO_ACIN2 0xD5CD

/** MultiC Device State (internal) {un8 = data (see xml for meanings)} */
#define VE_REG_MULTIC_DEVICE_STATE 0xD010

/** MultiC Board revision instace 1 (internal) {un32 = revision} */
#define VE_REG_MULTIC_BOARD_REV_1 0xD011

/** MultiC Board revision instace 2 (internal) {un32 = revision} */
#define VE_REG_MULTIC_BOARD_REV_2 0xD012

/** MultiC Board revision instace 3 (internal) {un32 = revision} */
#define VE_REG_MULTIC_BOARD_REV_3 0xD013

/** MultiC Board revision instace 4 (internal) {un32 = revision} */
#define VE_REG_MULTIC_BOARD_REV_4 0xD014

/**
 * MultiC options (bitmask) (internal) {bits[1] = Connect To Acin1, 0 = No, 1 =
 * Yes : bits[1] = Connect To Acin2, 0 = No, 1 = Yes : bits[1] = Enable Acout2, 0
 * = No, 1 = Yes : bits[1] = reserved 3, 0 = No, 1 = Yes : bits[1] = reserved 4,
 * 0 = No, 1 = Yes : bits[1] = reserved 5, 0 = No, 1 = Yes : bits[1] = Allow To
 * Discharge, 0 = No, 1 = Yes : bits[1] = Allow To Charge, 0 = No, 1 = Yes :
 * bits[1] = reserved 8, 0 = No, 1 = Yes : bits[1] = reserved 9, 0 = No, 1 = Yes
 * : bits[1] = reserved 10, 0 = No, 1 = Yes : bits[1] = reserved 11, 0 = No, 1 =
 * Yes : bits[1] = reserved 12, 0 = No, 1 = Yes : bits[1] = reserved 13, 0 = No,
 * 1 = Yes : bits[1] = reserved 14, 0 = No, 1 = Yes : bits[1] = reserved 15, 0 =
 * No, 1 = Yes}
 */
#define VE_REG_MULTIC_MULTI_OPT 0xD018

/**
 * MultiC flags (bitmask) (internal) {bits[1] = Acin1Valid, 0 = No, 1 = Yes :
 * bits[1] = Acin2Valid, 0 = No, 1 = Yes : bits[1] = Acin1Relay Test Error, 0 =
 * No, 1 = Yes : bits[1] = Acin2Relay Test Error, 0 = No, 1 = Yes : bits[1] =
 * Acin1Relay Closed, 0 = No, 1 = Yes : bits[1] = Acin2Relay Closed, 0 = No, 1 =
 * Yes : bits[1] = Enable Charger, 0 = No, 1 = Yes : bits[1] = Enable Inverter, 0
 * = No, 1 = Yes : bits[1] = reserved 8, 0 = No, 1 = Yes : bits[1] = reserved 9,
 * 0 = No, 1 = Yes : bits[1] = reserved 10, 0 = No, 1 = Yes : bits[1] = reserved
 * 11, 0 = No, 1 = Yes : bits[1] = reserved 12, 0 = No, 1 = Yes : bits[1] =
 * reserved 13, 0 = No, 1 = Yes : bits[1] = reserved 14, 0 = No, 1 = Yes :
 * bits[1] = reserved 15, 0 = No, 1 = Yes}
 */
#define VE_REG_MULTIC_MULTI_FLAGS 0xD019

/** MultiC errata (bitmask) (internal) {un32 = MultiC errata (bitmask)} */
#define VE_REG_MULTIC_ERRATA 0xD01A

/**
 * MultiC MPPT control command (internal) {un8 = data, 0x00 = Off, 0x01 = On,
 * 0xFF = Not available}
 */
#define VE_REG_MULTIC_MPPT_CONTROL 0xD020

/**
 * MultiC MPPT DC Bus voltage set-point (internal) {un32 = Voltage [0.001V],
 * 0xFFFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_VBUS_SET 0xD021

/**
 * MultiC power set-point (internal) {un32 = Power [0.001W], 0xFFFFFFFF = Not
 * Available}
 */
#define VE_REG_MULTIC_POWER_SET 0xD022

/**
 * MultiC Relay control command (internal) {bits[1] = Ground Relay, 0 = No, 1 =
 * Yes : bits[1] = Acin1Relays, 0 = No, 1 = Yes : bits[1] = Acin2Relays, 0 = No,
 * 1 = Yes : bits[1] = reserved 3, 0 = No, 1 = Yes : bits[1] = reserved 4, 0 =
 * No, 1 = Yes : bits[1] = reserved 5, 0 = No, 1 = Yes : bits[1] = reserved 6, 0
 * = No, 1 = Yes : bits[1] = reserved 7, 0 = No, 1 = Yes}
 */
#define VE_REG_MULTIC_RELAY_CONTROL 0xD023

/**
 * MultiC GFCI control command (internal) {un8 = data, 0x00 = Off, 0x01 = Test,
 * 0x02 = Active, 0x03 = Disable, 0xFF = Not available}
 */
#define VE_REG_MULTIC_GFCI_CONTROL 0xD024

/** MultiC GFCI test result (internal) {un8 = data (see xml for meanings)} */
#define VE_REG_MULTIC_GFCI_TEST_RESULT 0xD025

/**
 * MultiC GFCI AC current (internal) {sn32 = Current [1e-06A], 0x7FFFFFFF = Not
 * Available}
 */
#define VE_REG_MULTIC_GFCI_AC_CURRENT 0xD026

/**
 * MultiC GFCI DC current  (internal) {sn32 = Current [1e-06A], 0x7FFFFFFF = Not
 * Available}
 */
#define VE_REG_MULTIC_GFCI_DC_CURRENT 0xD027

/**
 * MultiC PVRISO control command (internal) {un8 = data, 0x00 = Off, 0x01 = Test,
 * 0x02 = Active, 0x03 = Disable, 0xFF = Not available}
 */
#define VE_REG_MULTIC_PVRISO_CONTROL 0xD028

/** MultiC PVRISO test result (internal) {un8 = data (see xml for meanings)} */
#define VE_REG_MULTIC_PVRISO_TEST_RESULT 0xD029

/**
 * MultiC PVRISO voltage (internal) {sn32 = Voltage [0.001V], 0x7FFFFFFF = Not
 * Available}
 */
#define VE_REG_MULTIC_PVRISO_VOLTAGE 0xD02A

/** MultiC FAN1 duty-cycle (due to load) (internal) {un16 = data} */
#define VE_REG_MULTIC_FAN1_DUTY_FF 0xD02B

/** MultiC FAN1 duty-cycle (due to temperature) (internal) {un16 = data} */
#define VE_REG_MULTIC_FAN1_DUTY_FB 0xD02C

/** MultiC FAN2 duty-cycle (due to load) (internal) {un16 = data} */
#define VE_REG_MULTIC_FAN2_DUTY_FF 0xD02D

/** MultiC FAN2 duty-cycle (due to temperature) (internal) {un16 = data} */
#define VE_REG_MULTIC_FAN2_DUTY_FB 0xD02E

/**
 * MultiC DC Bus power (inverter) (internal) {sn32 = Power [0.001W], 0x7FFFFFFF =
 * Not Available}
 */
#define VE_REG_MULTIC_DCAC_DC_BUS_POWER 0xD030

/**
 * MultiC Package validation result (internal) {bits[2] = Instance 0, 0 = Not
 * present, 1 = Validated ok, 2 = Validation failed, 3 = Unknown : bits[2] =
 * Instance 1, 0 = Not present, 1 = Validated ok, 2 = Validation failed, 3 =
 * Unknown : bits[2] = Instance 2, 0 = Not present, 1 = Validated ok, 2 =
 * Validation failed, 3 = Unknown : bits[2] = Instance 3, 0 = Not present, 1 =
 * Validated ok, 2 = Validation failed, 3 = Unknown : bits[2] = Instance 4, 0 =
 * Not present, 1 = Validated ok, 2 = Validation failed, 3 = Unknown : bits[2] =
 * Instance 5, 0 = Not present, 1 = Validated ok, 2 = Validation failed, 3 =
 * Unknown : bits[2] = Instance 6, 0 = Not present, 1 = Validated ok, 2 =
 * Validation failed, 3 = Unknown : bits[2] = Instance 7, 0 = Not present, 1 =
 * Validated ok, 2 = Validation failed, 3 = Unknown : bits[2] = Instance 8, 0 =
 * Not present, 1 = Validated ok, 2 = Validation failed, 3 = Unknown : bits[2] =
 * Instance 9, 0 = Not present, 1 = Validated ok, 2 = Validation failed, 3 =
 * Unknown : bits[2] = Instance 10, 0 = Not present, 1 = Validated ok, 2 =
 * Validation failed, 3 = Unknown : bits[2] = Instance 11, 0 = Not present, 1 =
 * Validated ok, 2 = Validation failed, 3 = Unknown : bits[2] = Instance 12, 0 =
 * Not present, 1 = Validated ok, 2 = Validation failed, 3 = Unknown : bits[2] =
 * Instance 13, 0 = Not present, 1 = Validated ok, 2 = Validation failed, 3 =
 * Unknown : bits[2] = Instance 14, 0 = Not present, 1 = Validated ok, 2 =
 * Validation failed, 3 = Unknown : bits[2] = Instance 15, 0 = Not present, 1 =
 * Validated ok, 2 = Validation failed, 3 = Unknown}
 */
#define VE_REG_MULTIC_PACKAGE_VALIDATION 0xD031

/**
 * MultiC Anti-tamper key status (internal) {bits[1] = Instance 1 Method 1, 0 =
 * No, 1 = Yes : bits[1] = Instance 1 Method 2, 0 = No, 1 = Yes : bits[1] =
 * Instance 1 Method 3, 0 = No, 1 = Yes : bits[1] = Instance 2 Method 1, 0 = No,
 * 1 = Yes : bits[1] = Instance 2 Method 2, 0 = No, 1 = Yes : bits[1] = Instance
 * 2 Method 3, 0 = No, 1 = Yes : bits[1] = Instance 3 Method 1, 0 = No, 1 = Yes :
 * bits[1] = Instance 3 Method 2, 0 = No, 1 = Yes : bits[1] = Instance 3 Method
 * 3, 0 = No, 1 = Yes : bits[1] = Instance 4 Method 1, 0 = No, 1 = Yes : bits[1]
 * = Instance 4 Method 2, 0 = No, 1 = Yes : bits[1] = Instance 4 Method 3, 0 =
 * No, 1 = Yes : }
 */
#define VE_REG_ATK_STATUS 0xD032

/**
 * MultiC relay test control command (internal) {un8 = control, 0x00 = Off, 0x01
 * = Test, 0x02 = Active, 0x03 = Disable, 0xFF = Not available}
 */
#define VE_REG_MULTIC_RELAY_TEST_CONTROL 0xD033

/** MultiC relay test result (internal) {un8 = result (see xml for meanings)} */
#define VE_REG_MULTIC_RELAY_TEST_RESULT 0xD034

/**
 * MultiC relay test control command (internal) {un8 = mode (see xml for
 * meanings)}
 */
#define VE_REG_MULTIC_CONNECTION_MODE 0xD035

/** MultiC rotary switch position (internal) {un16 = position} */
#define VE_REG_MULTIC_ROTARY_POSITION 0xD036

/**
 * MultiC relay test pattern (internal) {bits[1] = dcacRelayTest1Pass, 0 = No, 1
 * = Yes : bits[1] = mpptRelayTest1Pass, 0 = No, 1 = Yes : bits[1] =
 * dcacRelayTest2Pass, 0 = No, 1 = Yes : bits[1] = mpptRelayTest2Pass, 0 = No, 1
 * = Yes : bits[1] = dcacRelayTest3Pass, 0 = No, 1 = Yes : bits[1] =
 * mpptRelayTest3Pass, 0 = No, 1 = Yes : bits[1] = dcacRelayTest4Pass, 0 = No, 1
 * = Yes : bits[1] = mpptRelayTest4Pass, 0 = No, 1 = Yes}
 */
#define VE_REG_MULTIC_RELAY_TEST_PATTERN 0xD037

/** MultiC sysclock (debug) (internal) {un32 = freq} */
#define VE_REG_MULTIC_SYSCLOCK 0xD038

/** MultiC BatteryLife State (internal) {un8 = state (see xml for meanings)} */
#define VE_REG_MULTIC_BATTERYLIFE_STATE 0xD039

/**
 * MultiC GFCI DC voltage (internal) {sn32 = Voltage [0.001V], 0x7FFFFFFF = Not
 * Available}
 */
#define VE_REG_MULTIC_GFCI_DC_VOLTAGE 0xD03C

/** MultiC acin1 disconnect reason (internal) {un8 = reason} */
#define VE_REG_MULTIC_ACIN1_DISCONNECT_REASON 0xD03D

/** MultiC DCDC grid disconnect reason (internal) {un32 = reason} */
#define VE_REG_MULTIC_DCDC_GRID_DISCONNECT_REASON 0xD03E

/**
 * Min AC IN Voltage Setpoint (internal) {un16 = Min AC IN Voltage Setpoint
 * [0.01V]}
 */
#define VE_REG_ACIN_VOLTAGE_SETPOINT_MIN 0xD04A

/**
 * Max AC IN Voltage Setpoint (internal) {un16 = Max AC IN Voltage Setpoint
 * [0.01V]}
 */
#define VE_REG_ACIN_VOLTAGE_SETPOINT_MAX 0xD04B

/**
 * MultiC ACIN vector ufb max offset high voltage connect (internal) {sn16 =
 * MultiC ACIN vector ufb max offset high voltage connect [0.01V]}
 */
#define VE_REG_MULTIC_ACIN_UFB_MAX_OFFSET_HIGH_VOLTAGE_CONNECT 0xD04C

/**
 * MultiC ACIN vector ufb min offset low voltage connect (internal) {sn16 =
 * MultiC ACIN vector ufb min offset low voltage connect [0.01V]}
 */
#define VE_REG_MULTIC_ACIN_UFB_MIN_OFFSET_LOW_VOLTAGE_CONNECT 0xD04D

/**
 * MultiC CAN master timer (internal) {un8 = timer, 0 = CAN_FREE_RUN, 1 =
 * CAN_SYNC_IN, 255 = UNKNOWN}
 */
#define VE_REG_MULTIC_CAN_MASTER_TIMER 0xD05A

/** MultiC CAN command timestamp (internal) {un32 = timestamp} */
#define VE_REG_MULTIC_CAN_COMMAND_TIMESTAMP 0xD05B

/**
 * MultiC AC Coupled PV Inverter Detection Level (internal) {sn32 = power
 * [0.001W]}
 */
#define VE_REG_MULTIC_AC_COUPLED_PV_INVERTER_DETECTION_LEVEL 0xD060

/** Generator state (internal) {un8 = state, 0 = active, 1 = inactive} */
#define VE_REG_GENERATOR_STATE 0xD06B

/**
 * Generator run time (internal) {un32 = Time [0.001s], 0xFFFFFFFF = Not
 * Available}
 */
#define VE_REG_GENERATOR_RUN_TIME 0xD06C

/** instance 1 protection level (internal) {un8 = level} */
#define VE_REG_PROTECTION_LEVEL_1 0xD081

/** instance 2 protection level (internal) {un8 = level} */
#define VE_REG_PROTECTION_LEVEL_2 0xD082

/** instance 3 protection level (internal) {un8 = level} */
#define VE_REG_PROTECTION_LEVEL_3 0xD083

/** instance 4 protection level (internal) {un8 = level} */
#define VE_REG_PROTECTION_LEVEL_4 0xD084

/** MultiC no restart after short (internal) {un8 = data, 0x00 = NO, 0x01 = YES} */
#define VE_REG_MULTIC_NO_RESTART_AFTER_SHORT 0xD090

/** Stack usage Metrics: instance 1 bytes used (internal) {un32 = bytes used} */
#define VE_REG_STACK_USAGE_1 0xD0A1

/** Stack usage Metrics: instance 2 bytes used (internal) {un32 = bytes used} */
#define VE_REG_STACK_USAGE_2 0xD0A2

/** Stack usage Metrics: instance 3 bytes used (internal) {un32 = bytes used} */
#define VE_REG_STACK_USAGE_3 0xD0A3

/** Stack usage Metrics: instance 4 bytes used (internal) {un32 = bytes used} */
#define VE_REG_STACK_USAGE_4 0xD0A4

/**
 * MultiC Using test board (forces settings to 12V) (internal) {un8 = data, 0 =
 * No, 1 = Yes}
 */
#define VE_REG_MULTIC_LV_TEST_BOARD 0xD0C5

/** MultiC rotary switch configuration (internal) {un8 = config} */
#define VE_REG_MULTIC_ROTARY_CONFIG 0xD0C6

/**
 * Warning reason test (internal) {bits[1] = Low Voltage, 0 = No, 1 = Yes, low
 * battery voltage alarm : bits[1] = High Voltage, 0 = No, 1 = Yes, high battery
 * voltage alarm : bits[1] = Low Soc, 0 = No, 1 = Yes, low State Of Charge alarm
 * : bits[1] = VE_REG_ALARM_REASON_LOW_VOLTAGE2, 0 = No, 1 = Yes, low voltage2
 * alarm : bits[1] = VE_REG_ALARM_REASON_HIGH_VOLTAGE2, 0 = No, 1 = Yes, high
 * voltage2 alarm : bits[1] = Low Temperature, 0 = No, 1 = Yes, low temperature
 * alarm (also not connected transformer NTC) : bits[1] = High Temperature, 0 =
 * No, 1 = Yes, high temperature alarm : bits[1] = Mid Voltage, 0 = No, 1 = Yes,
 * mid voltage alarm : bits[1] = Overload, 0 = No, 1 = Yes, e.g. based on Iinv^2
 * or Ipeak events count : bits[1] = Dc Ripple, 0 = No, 1 = Yes, e.g. indication
 * for poor battery connection : bits[1] = Low V Ac Out, 0 = No, 1 = Yes, e.g. in
 * case of large load and low battery : bits[1] = High V Ac Out, 0 = No, 1 = Yes,
 * e.g. typ. when connected to other "mains" source, this will prevent the
 * inverter-only to start : bits[1] = Short Circuit, 0 = No, 1 = Yes, short
 * circuit alarm : bits[1] = Bms Lockout, 0 = No, 1 = Yes, BMS Lockout alarm
 * (Used in Smart Battery Protect) : bits[1] = Bms Cable Failure, 0 = No, 1 =
 * Yes, Battery M8 BMS Cable not connected or defect (Used in Smart BMS) :
 * bits[1] = reserved 15, 0 = No, 1 = Yes}
 * multiple flag can be or-ed together for bit mask
 */
#define VE_REG_MULTIC_WARNING_TEST 0xD0CE

/**
 * Alarm reason test (internal) {bits[1] = Low Voltage, 0 = No, 1 = Yes, low
 * battery voltage alarm : bits[1] = High Voltage, 0 = No, 1 = Yes, high battery
 * voltage alarm : bits[1] = Low Soc, 0 = No, 1 = Yes, low State Of Charge alarm
 * : bits[1] = VE_REG_ALARM_REASON_LOW_VOLTAGE2, 0 = No, 1 = Yes, low voltage2
 * alarm : bits[1] = VE_REG_ALARM_REASON_HIGH_VOLTAGE2, 0 = No, 1 = Yes, high
 * voltage2 alarm : bits[1] = Low Temperature, 0 = No, 1 = Yes, low temperature
 * alarm (also not connected transformer NTC) : bits[1] = High Temperature, 0 =
 * No, 1 = Yes, high temperature alarm : bits[1] = Mid Voltage, 0 = No, 1 = Yes,
 * mid voltage alarm : bits[1] = Overload, 0 = No, 1 = Yes, e.g. based on Iinv^2
 * or Ipeak events count : bits[1] = Dc Ripple, 0 = No, 1 = Yes, e.g. indication
 * for poor battery connection : bits[1] = Low V Ac Out, 0 = No, 1 = Yes, e.g. in
 * case of large load and low battery : bits[1] = High V Ac Out, 0 = No, 1 = Yes,
 * e.g. typ. when connected to other "mains" source, this will prevent the
 * inverter-only to start : bits[1] = Short Circuit, 0 = No, 1 = Yes, short
 * circuit alarm : bits[1] = Bms Lockout, 0 = No, 1 = Yes, BMS Lockout alarm
 * (Used in Smart Battery Protect) : bits[1] = Bms Cable Failure, 0 = No, 1 =
 * Yes, Battery M8 BMS Cable not connected or defect (Used in Smart BMS) :
 * bits[1] = reserved 15, 0 = No, 1 = Yes}
 * multiple flag can be or-ed together for bit mask
 */
#define VE_REG_MULTIC_ALARM_TEST 0xD0CF

/**
 * MultiC FAN1 current limit - turn off (internal) {sn32 = Current [0.001A],
 * 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_FAN1_I_OFF 0xD0D0

/**
 * MultiC FAN1 current limit - lowest duty cycle  (internal) {sn32 = Current
 * [0.001A], 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_FAN1_I_LOW 0xD0D1

/**
 * MultiC FAN1 current limit - higest duty cycle (internal) {sn32 = Current
 * [0.001A], 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_FAN1_I_HIGH 0xD0D2

/**
 * MultiC FAN1 temperature limit - turn off (internal) {sn32 = Temperature
 * [0.001°C], 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_FAN1_T_OFF 0xD0D3

/**
 * MultiC FAN1 temperature limit - lowest duty cycle (internal) {sn32 =
 * Temperature [0.001°C], 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_FAN1_T_LOW 0xD0D4

/**
 * MultiC FAN1 temperature limit - highest duty cycle (internal) {sn32 =
 * Temperature [0.001°C], 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_FAN1_T_HIGH 0xD0D5

/**
 * MultiC FAN2 power limit - turn off (internal) {sn32 = Power [0.001W],
 * 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_FAN2_P_OFF 0xD0D6

/**
 * MultiC FAN2 power limit - lowest duty cycle (internal) {sn32 = Power [0.001W],
 * 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_FAN2_P_LOW 0xD0D7

/**
 * MultiC FAN2 power limit - highest duty cycle (internal) {sn32 = Power
 * [0.001W], 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_FAN2_P_HIGH 0xD0D8

/**
 * MultiC FAN2 temperature limit - turn off (internal) {sn32 = Temperature
 * [0.001°C], 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_FAN2_T_OFF 0xD0D9

/**
 * MultiC FAN2 temperature limit - lowest duty cycle (internal) {sn32 =
 * Temperature [0.001°C], 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_FAN2_T_LOW 0xD0DA

/**
 * MultiC FAN2 temperature limit - highest duty cycle (internal) {sn32 =
 * Temperature [0.001°C], 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_FAN2_T_HIGH 0xD0DB

/**
 * MultiC DCDC converter options (bitmask) (internal) {bits[1] = Enable Dcdc, 0 =
 * No, 1 = Yes : bits[1] = Sweep Started, 0 = No, 1 = Yes : bits[1] = Enable
 * Other Bridge, 0 = No, 1 = Yes : bits[1] = Starting Bridge, 0 = No, 1 = Yes :
 * bits[1] = reserved 4, 0 = No, 1 = Yes : bits[1] = reserved 5, 0 = No, 1 = Yes
 * : bits[1] = Allow To Discharge, 0 = No, 1 = Yes : bits[1] = Allow To Charge, 0
 * = No, 1 = Yes : bits[1] = reserved 8, 0 = No, 1 = Yes : bits[1] = reserved 9,
 * 0 = No, 1 = Yes : bits[1] = reserved 10, 0 = No, 1 = Yes : bits[1] = reserved
 * 11, 0 = No, 1 = Yes : bits[1] = reserved 12, 0 = No, 1 = Yes : bits[1] =
 * reserved 13, 0 = No, 1 = Yes : bits[1] = reserved 14, 0 = No, 1 = Yes :
 * bits[1] = reserved 15, 0 = No, 1 = Yes}
 */
#define VE_REG_MULTIC_DCDC_OPT 0xD100

/**
 * MultiC DCDC converter flags (bitmask) (internal) {bits[1] = Dcdc Active, 0 =
 * No, 1 = Yes : bits[1] = Sweep Finished, 0 = No, 1 = Yes : bits[1] = Other
 * Bridge Enabled, 0 = No, 1 = Yes : bits[1] = Break Event, 0 = No, 1 = Yes :
 * bits[1] = Ovp Event, 0 = No, 1 = Yes : bits[1] = reserved 5, 0 = No, 1 = Yes :
 * bits[1] = Supply Ok Low Voltage Side, 0 = No, 1 = Yes : bits[1] = Supply Ok
 * High Voltage Side, 0 = No, 1 = Yes : bits[1] = reserved 8, 0 = No, 1 = Yes :
 * bits[1] = reserved 9, 0 = No, 1 = Yes : bits[1] = reserved 10, 0 = No, 1 = Yes
 * : bits[1] = reserved 11, 0 = No, 1 = Yes : bits[1] = reserved 12, 0 = No, 1 =
 * Yes : bits[1] = reserved 13, 0 = No, 1 = Yes : bits[1] = reserved 14, 0 = No,
 * 1 = Yes : bits[1] = reserved 15, 0 = No, 1 = Yes}
 */
#define VE_REG_MULTIC_DCDC_FLAGS 0xD101

/**
 * MultiC DCDC converter operating frequency (internal) {un32 = Frequency [1Hz],
 * 0xFFFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_DCDC_FREQ 0xD102

/** MultiC DCDC converter break event counter (internal) {un32 = Events} */
#define VE_REG_MULTIC_DCDC_BREAKS 0xD103

/** MultiC DCDC converter over-voltage event counter (internal) {sn32 = Events} */
#define VE_REG_MULTIC_DCDC_OVP 0xD104

/**
 * MultiC DCDC incoming SYNC signal period time (internal) {un16 = Time [1e-06s],
 * 0xFFFF = Not Available}
 */
#define VE_REG_MULTIC_DCDC_SYNC_IN 0xD105

/**
 * MultiC DCDC converter heatsink temperature (internal) {sn32 = Temperature
 * [0.001°C], 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_DCDC_TEMPERATURE 0xD106

/**
 * MultiC DCDC converter voltage over the transformer (internal) {sn32 = Voltage
 * [0.001V], 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_DCDC_OFFSET_VOLTAGE 0xD107

/**
 * MultiC allow-2-charge input voltage (internal) {sn32 = Voltage [0.001V],
 * 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_VALLOW2CHARGE 0xD108

/**
 * MultiC tsense input temperature (internal) {sn32 = Temperature [0.001°C],
 * 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_TSENSE 0xD109

/**
 * MultiC vsense plus input voltage (internal) {sn32 = Voltage [0.001V],
 * 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_VSENSE_P 0xD10A

/**
 * MultiC vsense minus input voltage (internal) {sn32 = Voltage [0.001V],
 * 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_VSENSE_M 0xD10B

/**
 * MultiC aux1 input voltage (internal) {sn32 = Voltage [0.001V], 0x7FFFFFFF =
 * Not Available}
 */
#define VE_REG_MULTIC_AUX1 0xD10C

/**
 * MultiC aux2 input voltage (internal) {sn32 = Voltage [0.001V], 0x7FFFFFFF =
 * Not Available}
 */
#define VE_REG_MULTIC_AUX2 0xD10D

/**
 * MultiC DCDC CPU temperature (instance 1) (internal) {sn32 = Temperature
 * [0.001°C], 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_DCDC_CPU_TEMPERATURE 0xD10E

/**
 * MultiC DCDC CPU voltage (instance 1) (internal) {sn32 = Voltage [0.001V],
 * 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_DCDC_3V3 0xD10F

/**
 * MultiC vsense input voltage (differential) (internal) {un32 = Voltage
 * [0.001V], 0xFFFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_VBAT_SENSE 0xD110

/**
 * MultiC battery voltage (terminals) (internal) {un32 = Voltage [0.001V],
 * 0xFFFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_VBAT_MEAS 0xD111

/**
 * MultiC battery voltage (internal) {un32 = Voltage [0.001V], 0xFFFFFFFF = Not
 * Available}
 */
#define VE_REG_MULTIC_VBAT 0xD112

/**
 * MultiC battery voltage ripple (rms) (internal) {un32 = Voltage [0.001V],
 * 0xFFFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_VBAT_RIPPLE 0xD113

/**
 * MultiC battery low voltage timer (internal) {un16 = Time [0.05s], 0xFFFF = Not
 * Available}
 */
#define VE_REG_MULTIC_VBAT_LOW_TIMER 0xD114

/** MultiC battery low voltage event counter (internal) {un8 = Events} */
#define VE_REG_MULTIC_VBAT_LOW_COUNT 0xD115

/**
 * MultiC battery current limit (due to temperature) (internal) {sn32 = Current
 * [0.001A], 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_IBAT_LIMIT 0xD116

/**
 * MultiC battery current estimate (source MPPT) (internal) {sn32 = Current
 * [0.001A], 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_IBAT_MPPT_EST 0xD117

/**
 * MultiC battery current estimate (source Inverter)  (internal) {sn32 = Current
 * [0.001A], 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_IBAT_DCAC_EST 0xD118

/**
 * MultiC battery current estimate (combined) (internal) {sn32 = Current
 * [0.001A], 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_IBAT_EST 0xD119

/**
 * MultiC battery current measurement (shunt) (internal) {sn32 = Current
 * [0.001A], 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_IBAT_MEAS 0xD11A

/**
 * MultiC battery current (internal) {sn32 = Current [0.001A], 0x7FFFFFFF = Not
 * Available}
 */
#define VE_REG_MULTIC_IBAT 0xD11B

/**
 * MultiC internal aux5v voltage (internal) {sn32 = Voltage [0.001V], 0x7FFFFFFF
 * = Not Available}
 * measured on the dcdc board on the battery side
 */
#define VE_REG_MULTIC_AUX5V 0xD11C

/**
 * MultiC internal aux12v voltage (internal) {sn32 = Voltage [0.001V], 0x7FFFFFFF
 * = Not Available}
 * measured on the dcdc board on the battery side
 */
#define VE_REG_MULTIC_AUX12V 0xD11D

/**
 * MultiC internal aux15v voltage (internal) {sn32 = Voltage [0.001V], 0x7FFFFFFF
 * = Not Available}
 * measured on the dcdc board on the battery side
 */
#define VE_REG_MULTIC_AUX15V 0xD11E

/**
 * MultiC vsense minus input filtered raw adc value (for tester) (internal) {un16
 * = offset}
 */
#define VE_REG_MULTIC_VSENSE_M_OFFSET 0xD11F

/**
 * MultiC reasons preventing hibernate (internal) {bits[1] = poweroff, 0 = No, 1
 * = Yes : bits[1] = inverter, 0 = No, 1 = Yes : bits[1] = mppt, 0 = No, 1 = Yes
 * : bits[1] = adcReady, 0 = No, 1 = Yes : bits[1] = aux15V, 0 = No, 1 = Yes :
 * bits[1] = displayState, 0 = No, 1 = Yes : bits[1] = tester, 0 = No, 1 = Yes :
 * bits[1] = vregsBLE, 0 = No, 1 = Yes : bits[1] = reserved 8, 0 = No, 1 = Yes :
 * bits[1] = reserved 9, 0 = No, 1 = Yes : bits[1] = reserved 10, 0 = No, 1 = Yes
 * : bits[1] = reserved 11, 0 = No, 1 = Yes : bits[1] = reserved 12, 0 = No, 1 =
 * Yes : bits[1] = reserved 13, 0 = No, 1 = Yes : bits[1] = reserved 14, 0 = No,
 * 1 = Yes : bits[1] = reserved 15, 0 = No, 1 = Yes}
 */
#define VE_REG_MULTIC_HIBERNATE 0xD120

/**
 * MultiC internal losses compensation (internal) {sn32 = Power [0.001W],
 * 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_LOSSES_COMP 0xD121

/**
 * MultiC battery voltage limit (internal) {un32 = Voltage [0.001V], 0xFFFFFFFF =
 * Not Available}
 */
#define VE_REG_MULTIC_VBAT_LIMIT 0xD123

/** MultiC DCDC PLL phase (internal) {sn32 = data} */
#define VE_REG_MULTIC_PLL_PHASE 0xD124

/** MultiC DCDC PLL amplitude (internal) {sn32 = data} */
#define VE_REG_MULTIC_PLL_AMPLITUDE 0xD125

/**
 * MultiC DCDC VBAT signal period time (internal) {un16 = Time [1e-06s], 0xFFFF =
 * Not Available}
 */
#define VE_REG_MULTIC_DCDC_SYNC_ADC 0xD126

/**
 * MultiC DCDC battery current ripple (internal) {sn32 = Current [0.001A],
 * 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_DCDC_IBAT_RIPPLE 0xD127

/**
 * MultiC DCDC outgoing SYNC signal period time (internal) {un16 = Time [1e-06s],
 * 0xFFFF = Not Available}
 */
#define VE_REG_MULTIC_DCDC_SYNC_OUT 0xD128

/** MultiC DCDC off reason (internal) {un16 = data} */
#define VE_REG_MULTIC_DCDC_OFF_REASON 0xD129

/** MultiC DCAC off reason (internal) {un16 = data} */
#define VE_REG_MULTIC_DCAC_OFF_REASON 0xD12A

/**
 * MultiC DCDC offset value (calculated) (internal) {sn32 = Voltage [0.001V],
 * 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_DCDC_OFFSET_VALUE 0xD12B

/** MultiC DCDC sync source (internal) {un8 = source (see xml for meanings)} */
#define VE_REG_MULTIC_DCDC_SYNC_SOURCE 0xD12C

/**
 * MultiC DCDC Power Margin (internal) {un32 = Power [0.001W], 0xFFFFFFFF = Not
 * Available}
 */
#define VE_REG_MULTIC_DCDC_POWER_MARGIN 0xD12D

/**
 * Charger algorithm - bulk protection counter (internal) {un32 = Time [0.001s],
 * 0xFFFFFFFF = Not Available}
 */
#define VE_REG_CHARGER_BULK_PROTECTION_COUNTER 0xD17A

/**
 * Charger algorithm - disable vset peak detector (internal) {bits[1] =
 * disableInternally, 0 = No, 1 = Yes : bits[1] = disableExternally, 0 = No, 1 =
 * Yes : bits[1] = disableForTesting, 0 = No, 1 = Yes : }
 */
#define VE_REG_CHARGER_DISABLE_VSET_PEAK_DETECTOR 0xD17B

/**
 * Charger algorithm - equalisation time spent (internal) {un32 = Time [0.001s],
 * 0xFFFFFFFF = Not Available}
 */
#define VE_REG_CHARGER_EQUALISATION_COUNTER 0xD17C

/**
 * Charger algorithm - battery estimated temperature (internal) {sn32 =
 * Temperature [0.001°C], 0x7FFFFFFF = Not Available}
 */
#define VE_REG_CHARGER_BATTERY_ESTIMATED_TEMPERATURE 0xD17D

/**
 * Charger algorithm - time cc to bulk (internal) {un32 = Time [0.001s],
 * 0xFFFFFFFF = Not Available}
 */
#define VE_REG_CHARGER_TIMER_CC_TO_BULK 0xD17E

/** Charger algorithm - grid present (internal) {un8 = data} */
#define VE_REG_CHARGER_GRID_PRESENT 0xD17F

/**
 * Charger algorithm - time in current charger state (internal) {un32 = Time
 * [0.001s], 0xFFFFFFFF = Not Available}
 * reset to 0 when the charger state changes
 */
#define VE_REG_CHARGER_ELAPSED_TIME 0xD180

/** Charger algorithm - cumulative amp hours (internal) {un32 = data} */
#define VE_REG_CHARGER_AMPHOURS 0xD181

/**
 * Charger algorithm - measured bulk time (internal) {un32 = Time [0.001s],
 * 0xFFFFFFFF = Not Available}
 * updated when leaving the bulk state
 */
#define VE_REG_CHARGER_BULK_DURATION 0xD182

/**
 * Charger algorithm - absorption time spent (internal) {un32 = Time [0.001s],
 * 0xFFFFFFFF = Not Available}
 */
#define VE_REG_CHARGER_ABSORPTION_COUNTER 0xD183

/**
 * Charger algorithm - absorption time available (internal) {un32 = Time
 * [0.001s], 0xFFFFFFFF = Not Available}
 * depending on the algorithm, either 20xTbulk or based on the battery idle
 * voltage
 */
#define VE_REG_CHARGER_ABSORPTION_END_TIME 0xD184

/**
 * Charger algorithm - float time available (internal) {un32 = Time [0.001s],
 * 0xFFFFFFFF = Not Available}
 */
#define VE_REG_CHARGER_FLOAT_TIME 0xD185

/**
 * Charger algorithm - equalisation time available (internal) {un32 = Time
 * [0.001s], 0xFFFFFFFF = Not Available}
 */
#define VE_REG_CHARGER_MAX_EQUALISATION_TIME 0xD186

/**
 * Charger algorithm - bulk end detection timer (internal) {un32 = Time [0.001s],
 * 0xFFFFFFFF = Not Available}
 */
#define VE_REG_CHARGER_TIMER_CURRENT_LIMIT 0xD187

/**
 * Charger algorithm - internal batterysafe ramp integral (dv*dt) (internal)
 * {un32 = data}
 */
#define VE_REG_CHARGER_BATTERYSAFE_RAMP 0xD188

/**
 * Charger algorithm - switch back to bulk timer (internal) {un32 = Time
 * [0.001s], 0xFFFFFFFF = Not Available}
 */
#define VE_REG_CHARGER_TIMER_SWITCH_TO_BULK 0xD189

/**
 * Charger algorithm - switch to float timer (internal) {un32 = Time [0.001s],
 * 0xFFFFFFFF = Not Available}
 */
#define VE_REG_CHARGER_TIMER_SWITCH_TO_FLOAT 0xD18A

/**
 * Charger algorithm - delay to restart charger algorithm when (temporarily) not
 * charging (internal) {un32 = Time [0.001s], 0xFFFFFFFF = Not Available}
 */
#define VE_REG_CHARGER_BATTERY_IDLE 0xD18B

/**
 * Charger algorithm - allowed charge current at low temperature (internal) {sn32
 * = Current [0.001A], 0x7FFFFFFF = Not Available}
 */
#define VE_REG_CHARGER_LOW_TEMP_MAX_CURRENT 0xD18C

/**
 * Charger algorithm - actual battery voltage (measured) (internal) {sn32 =
 * Voltage [0.001V], 0x7FFFFFFF = Not Available}
 */
#define VE_REG_CHARGER_BATTERY_VOLTAGE 0xD18D

/**
 * Charger algorithm - idle battery voltage (internal) {un32 = Voltage [0.001V],
 * 0xFFFFFFFF = Not Available}
 * typically measured in the morning before the charge cycle starts
 */
#define VE_REG_CHARGER_IDLE_BATTERY_VOLTAGE 0xD18E

/**
 * Charger algorithm - actual battery charge current (internal) {sn32 = Current
 * [0.001A], 0x7FFFFFFF = Not Available}
 * preferably measured by a battery monitor on the battery terminals
 */
#define VE_REG_CHARGER_CHARGE_CURRENT 0xD18F

/**
 * Charger algorithm - charger output current (internal) {sn32 = Current
 * [0.001A], 0x7FFFFFFF = Not Available}
 */
#define VE_REG_CHARGER_CHARGER_CURRENT 0xD190

/**
 * Charger algorithm - re-bulk voltage (without temperature compensation)
 * (internal) {un32 = Voltage [0.001V], 0xFFFFFFFF = Not Available}
 */
#define VE_REG_CHARGER_REBULK_VOLTAGE_NO_COMP 0xD191

/**
 * Charger algorithm - charger voltage set-point (without temperature
 * compensation) (internal) {un32 = Voltage [0.001V], 0xFFFFFFFF = Not Available}
 */
#define VE_REG_CHARGER_TARGET_VOLTAGE 0xD192

/**
 * Charger algorithm - charger voltage set-point (temperature compensated)
 * (internal) {un32 = Voltage [0.001V], 0xFFFFFFFF = Not Available}
 */
#define VE_REG_CHARGER_VOLTAGE_SETPOINT 0xD193

/**
 * Charger algorithm - charger current set-point (internal) {sn32 = Current
 * [0.001A], 0x7FFFFFFF = Not Available}
 */
#define VE_REG_CHARGER_CURRENT_SETPOINT 0xD194

/**
 * Charger algorithm - external voltage set-point (internal) {un32 = Voltage
 * [0.001V], 0xFFFFFFFF = Not Available}
 * used in setups where the charger is remotely controller (e.g. ESS or
 * synchronised charging)
 */
#define VE_REG_CHARGER_EXTERNAL_VOLTAGE_SETPOINT 0xD195

/**
 * Charger algorithm - temperature compensation (internal) {sn32 = Voltage
 * [0.001V], 0x7FFFFFFF = Not Available}
 */
#define VE_REG_CHARGER_TEMPCOMP 0xD196

/**
 * Charger algorithm - temperature compensation (for re-bulk voltage) (internal)
 * {sn32 = Voltage [0.001V], 0x7FFFFFFF = Not Available}
 */
#define VE_REG_CHARGER_TEMPCOMP_REBULK 0xD197

/**
 * Charger algorithm - battery temperature (internal) {sn32 = Temperature
 * [0.001°C], 0x7FFFFFFF = Not Available}
 */
#define VE_REG_CHARGER_BATTERY_TEMPERATURE 0xD198

/** Charger algorithm - manual equalise start/stop request (internal) {un8 = data} */
#define VE_REG_CHARGER_MANUAL_EQUALISE_PENDING 0xD199

/**
 * Charger algorithm - automatic equalise start/stop request (internal) {un8 =
 * data}
 */
#define VE_REG_CHARGER_AUTO_EQUALISE_PENDING 0xD19A

/** Charger algorithm - BMS state (internal) {un8 = data} */
#define VE_REG_CHARGER_BMS_STATE 0xD19B

/**
 * Charger algorithm - external request to recalculate the absorption time
 * (internal) {un8 = data}
 */
#define VE_REG_CHARGER_RECALC_ABSORPTION_TIME 0xD19C

/** Charger algorithm - current limiter active (internal) {un8 = data} */
#define VE_REG_CHARGER_CURRENT_LIMITED 0xD19D

/** Charger algorithm - charger enanbled (internal) {un8 = data} */
#define VE_REG_CHARGER_CHARGER_ENABLE 0xD19E

/** Charger algorithm - equalise is active (internal) {un8 = data} */
#define VE_REG_CHARGER_EQUALISATION_ACTIVE 0xD19F

/**
 * Charger algorithm - charger output limited due to low battery temperature
 * (internal) {un8 = data}
 */
#define VE_REG_CHARGER_LOW_TEMP_LIMITED 0xD1A0

/**
 * Charger algorithm - charger output reduced due to pv inverter (internal) {un8
 * = data}
 * used when the battery is nearly full, a pv inverter lacks the control finesse
 * to fully charge the battery
 */
#define VE_REG_CHARGER_CHARGER_REDUCED 0xD1A1

/**
 * Charger algorithm - charger error code (internal) {un8 = Error Code (see xml
 * for meanings)}
 */
#define VE_REG_CHARGER_ERROR_CODE 0xD1A2

/** Charger algorithm - charger state (internal) {un8 = data} */
#define VE_REG_CHARGER_CHARGER_STATE 0xD1A3

/** Charger algorithm - MPP tracker active (internal) {un8 = data} */
#define VE_REG_CHARGER_CHARGER_MPPT_ACTIVE 0xD1A4

/** Charger algorithm - charger operates as slave (internal) {un8 = data} */
#define VE_REG_CHARGER_CHARGER_AS_SLAVE 0xD1A5

/**
 * Charger algorithm - charger state received from a remote master (internal)
 * {un8 = data}
 */
#define VE_REG_CHARGER_EXTERNAL_CHARGER_STATE 0xD1A6

/**
 * Over-charge protection (voltage): over-voltage level (internal) {sn32 =
 * Voltage [0.001V], 0x7FFFFFFF = Not Available}
 */
#define VE_REG_CHARGER_PROT_V_TRIP_LEVEL 0xD1A7

/**
 * Over-charge protection (voltage): over-voltage detected (internal) {un8 =
 * data, 0 = Inactive, 1 = Active}
 */
#define VE_REG_CHARGER_PROT_V_TRIP_ACTIVE 0xD1A8

/**
 * Over-charge protection (current): over-voltage level (internal) {sn32 =
 * Voltage [0.001V], 0x7FFFFFFF = Not Available}
 */
#define VE_REG_CHARGER_PROT_I_TRIP_LEVEL 0xD1A9

/**
 * Over-charge protection (current): over-voltage detected (internal) {un8 =
 * data, 0 = Inactive, 1 = Active}
 */
#define VE_REG_CHARGER_PROT_I_TRIP_VOLTAGE 0xD1AA

/** Over-charge protection (current): event counter (internal) {un16 = data} */
#define VE_REG_CHARGER_PROT_I_TRIP_COUNT 0xD1AB

/**
 * Over-charge protection (current): current detected (internal) {un8 = data, 0 =
 * Inactive, 1 = Active}
 */
#define VE_REG_CHARGER_PROT_I_TRIP_ACTIVE 0xD1AC

/** Charger algorithm - standby (internal) {un8 = data, 0 = Inactive, 1 = Active} */
#define VE_REG_CHARGER_STANDBY 0xD1AD

/**
 * Charger algorithm - startup delay (internal) {un32 = Time [0.001s], 0xFFFFFFFF
 * = Not Available}
 */
#define VE_REG_CHARGER_STARTUP_DELAY 0xD1AE

/**
 * Charger algorithm - reduced voltage (ac coupled pv inverter) (internal) {sn32
 * = Voltage [0.001V], 0x7FFFFFFF = Not Available}
 */
#define VE_REG_CHARGER_REDUCED_VOLTAGE 0xD1AF

/** MultiC NMT Debug (internal) {sn32 = data} */
#define VE_REG_MULTIC_NMT_DEBUG0 0xD1B0

/** MultiC NMT Debug (internal) {sn32 = data} */
#define VE_REG_MULTIC_NMT_DEBUG1 0xD1B1

/** MultiC NMT Debug (internal) {sn32 = data} */
#define VE_REG_MULTIC_NMT_DEBUG2 0xD1B2

/** MultiC NMT Debug (internal) {sn32 = data} */
#define VE_REG_MULTIC_NMT_DEBUG3 0xD1B3

/** MultiC NMT Debug (internal) {sn32 = data} */
#define VE_REG_MULTIC_NMT_DEBUG4 0xD1B4

/** MultiC NMT Debug (internal) {sn32 = data} */
#define VE_REG_MULTIC_NMT_DEBUG5 0xD1B5

/** MultiC NMT Debug (internal) {sn32 = data} */
#define VE_REG_MULTIC_NMT_DEBUG6 0xD1B6

/** MultiC NMT Debug (internal) {sn32 = data} */
#define VE_REG_MULTIC_NMT_COUNT_INLOCK 0xD1B7

/** MultiC NMT Debug (internal) {sn32 = data} */
#define VE_REG_MULTIC_NMT_COUNT_READY2START 0xD1B8

/** MultiC NMT Debug (internal) {sn32 = data} */
#define VE_REG_MULTIC_NMT_COUNT_READY2CONNECT 0xD1B9

/** MultiC NMT Debug (internal) {sn32 = data} */
#define VE_REG_MULTIC_NMT_COUNT_INVERTING 0xD1BA

/** MultiC NMT Debug (internal) {sn32 = data} */
#define VE_REG_MULTIC_NMT_COUNT_PRESENT 0xD1BB

/**
 * MultiC DCDC converter start sweep frequency (internal) {un32 = Frequency
 * [1Hz], 0xFFFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_DCDC_F1 0xD1C0

/**
 * MultiC DCDC converter end sweep and highest control frequency (internal) {un32
 * = Frequency [1Hz], 0xFFFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_DCDC_F2 0xD1C1

/**
 * MultiC DCDC converter lowest control frequency (internal) {un32 = Frequency
 * [1Hz], 0xFFFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_DCDC_F3 0xD1C2

/** MultiC DCDC converter sweep rate (internal) {un16 = data} */
#define VE_REG_MULTIC_DCDC_SWEEP 0xD1C3

/** MultiC DCDC converter control update rate (internal) {un16 = data} */
#define VE_REG_MULTIC_DCDC_CRATE 0xD1C4

/**
 * MultiC DCDC converter dead-time (internal) {un16 = Time [1e-06s], 0xFFFF = Not
 * Available}
 */
#define VE_REG_MULTIC_DCDC_DT 0xD1C5

/**
 * MultiC DCDC converter temperature limit - resume operation (internal) {sn32 =
 * Temperature [0.001°C], 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_DCDC_T_ON 0xD1C6

/**
 * MultiC DCDC converter temperature limit - reduce charge current/warn
 * (internal) {sn32 = Temperature [0.001°C], 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_DCDC_T_DIM 0xD1C7

/**
 * MultiC DCDC converter temperature limit - turn off (internal) {sn32 =
 * Temperature [0.001°C], 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_DCDC_T_OFF 0xD1C8

/**
 * MultiC DCDC converter current limit - at low temperature (internal) {un32 =
 * Current [0.001A], 0xFFFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_DCDC_CURRENT_AT_LOW_TEMP 0xD1C9

/**
 * MultiC DCDC converter temperature limit - for low current set-point (internal)
 * {sn32 = Temperature [0.001°C], 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_DCDC_CURRENT_LOW_TEMP_LEVEL 0xD1CA

/**
 * MultiC DCDC converter current limit - at high temperature (internal) {un32 =
 * Current [0.001A], 0xFFFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_DCDC_CURRENT_AT_HIGH_TEMP 0xD1CB

/**
 * MultiC DCDC converter temperature limit - for high current set-point
 * (internal) {sn32 = Temperature [0.001°C], 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_DCDC_CURRENT_HIGH_TEMP_LEVEL 0xD1CC

/**
 * MultiC DCDC max charge current below voltage (internal) {un32 = Voltage
 * [0.001V], 0xFFFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_DCDC_MAX_CHARGE_CURRENT_BELOW_VOLTAGE 0xD1CD

/**
 * MultiC DCDC min charge current above voltage (internal) {un32 = Voltage
 * [0.001V], 0xFFFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_DCDC_MIN_CHARGE_CURRENT_ABOVE_VOLTAGE 0xD1CE

/**
 * MultiC DCDC min charge current level (internal) {sn32 = Current [0.001A],
 * 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_DCDC_MIN_CHARGE_CURRENT_LEVEL 0xD1CF

/**
 * MultiC DCDC converter low DC bus voltage limit - stop operation (internal)
 * {sn32 = Voltage [0.001V], 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_VBUS_LOW_STOP 0xD1D0

/**
 * MultiC DCDC converter low DC bus voltage limit - start operation (internal)
 * {sn32 = Voltage [0.001V], 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_VBUS_LOW_START 0xD1D1

/**
 * MultiC DCDC converter high DC bus voltage limit - start operation (internal)
 * {sn32 = Voltage [0.001V], 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_VBUS_MAX 0xD1D2

/**
 * MultiC DCDC converter high DC bus voltage limit - stop operation (internal)
 * {sn32 = Voltage [0.001V], 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_VBUS_OVP 0xD1D3

/** MultiC DCDC PLL P (internal) {sn32 = data} */
#define VE_REG_MULTIC_PLL_P 0xD1D4

/** MultiC DCDC PLL I (internal) {sn32 = data} */
#define VE_REG_MULTIC_PLL_I 0xD1D5

/** MultiC DCDC PLL D (internal) {sn32 = data} */
#define VE_REG_MULTIC_PLL_D 0xD1D6

/** MultiC DCAC PI vbat control Kp parameter (internal) {un16 = data} */
#define VE_REG_MULTIC_PINV0_KP 0xD1D7

/** MultiC DCAC PI vbat control Ki parameter (internal) {un16 = data} */
#define VE_REG_MULTIC_PINV0_KI 0xD1D8

/** MultiC DCDC PLL amplitude (internal) {sn32 = data} */
#define VE_REG_MULTIC_PLL_AMPLITUDE 0xD125

/** MultiC charger supports pv inverters (internal) {un8 = data, 0 = No, 1 = Yes} */
#define VE_REG_MULTIC_PV_INVERTER_SUPPORT 0xD1E0

/**
 * MultiC ac coupled pv inverter presense detection power level (internal) {sn32
 * = Power [0.001W], 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_PV_INVERTER_POWER_THRESHOLD 0xD1E1

/**
 * MultiC ac coupled pv inverter start-up time (before frequency control is
 * allowed) (internal) {un32 = Time [1s], 0xFFFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_PV_INVERTER_STARTUP_TIME 0xD1E2

/**
 * MultiC ac coupled pv inverter presense detection time (internal) {un32 = Time
 * [1s], 0xFFFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_PV_INVERTER_DETECT_TIME 0xD1E3

/**
 * MultiC ac coupled pv inverter re-bulk time (internal) {un32 = Time [1s],
 * 0xFFFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_PV_INVERTER_REBULK_TIME 0xD1E4

/**
 * MultiC ac coupled pv inverter tail current (internal) {un16 = Current [0.1A],
 * 0xFFFF = Not Available}
 */
#define VE_REG_MULTIC_PV_INVERTER_TAIL_CURRENT 0xD1E5

/**
 * MultiC ac coupled pv inverter re-bulk voltage (internal) {un16 = Voltage
 * [0.01V], 0xFFFF = Not Available}
 */
#define VE_REG_MULTIC_PV_INVERTER_RE_BULK_VOLTAGE 0xD1E6

/**
 * MultiC ac coupled pv inverter ac frequency (free-running) for 50Hz systems
 * (internal) {un16 = Frequency [0.01HZ], 0xFFFF = Not Available}
 */
#define VE_REG_MULTIC_PV_INVERTER_FREQ_FREE_50HZ 0xD1E7

/**
 * MultiC ac coupled pv inverter ac frequency (maximum power) for 50Hz systems
 * (internal) {un16 = Frequency [0.01HZ], 0xFFFF = Not Available}
 */
#define VE_REG_MULTIC_PV_INVERTER_FREQ_PMAX_50HZ 0xD1E8

/**
 * MultiC ac coupled pv inverter ac frequency (minimum power) for 50Hz systems
 * (internal) {un16 = Frequency [0.01HZ], 0xFFFF = Not Available}
 */
#define VE_REG_MULTIC_PV_INVERTER_FREQ_PMIN_50HZ 0xD1E9

/**
 * MultiC ac coupled pv inverter ac frequency (shutdown) for 50Hz systems
 * (internal) {un16 = Frequency [0.01HZ], 0xFFFF = Not Available}
 */
#define VE_REG_MULTIC_PV_INVERTER_FREQ_STOP_50HZ 0xD1EA

/**
 * MultiC ac coupled pv inverter ac frequency control Kp parameter (internal)
 * {un16 = data}
 */
#define VE_REG_MULTIC_PV_INVERTER_FREQ_KP 0xD1EB

/**
 * MultiC ac coupled pv inverter ac frequency control Ki parameter (internal)
 * {un16 = data}
 */
#define VE_REG_MULTIC_PV_INVERTER_FREQ_KI 0xD1EC

/**
 * MultiC ac coupled pv inverter ac frequency control gain for battery current
 * (internal) {un16 = data}
 */
#define VE_REG_MULTIC_PV_INVERTER_IBAT_GAIN 0xD1ED

/**
 * MultiC ac coupled pv inverter ac frequency control voltage error limit
 * (internal) {un16 = Voltage [0.01V], 0xFFFF = Not Available}
 */
#define VE_REG_MULTIC_PV_INVERTER_VOLT_ERROR_LIMIT 0xD1EF

/**
 * MultiC ac coupled pv inverter ac frequency (free-running) for 60Hz systems
 * (internal) {un16 = Frequency [0.01HZ], 0xFFFF = Not Available}
 */
#define VE_REG_MULTIC_PV_INVERTER_FREQ_FREE_60HZ 0xD1F0

/**
 * MultiC ac coupled pv inverter ac frequency (maximum power) for 60Hz systems
 * (internal) {un16 = Frequency [0.01HZ], 0xFFFF = Not Available}
 */
#define VE_REG_MULTIC_PV_INVERTER_FREQ_PMAX_60HZ 0xD1F1

/**
 * MultiC ac coupled pv inverter ac frequency (minimum power) for 60Hz systems
 * (internal) {un16 = Frequency [0.01HZ], 0xFFFF = Not Available}
 */
#define VE_REG_MULTIC_PV_INVERTER_FREQ_PMIN_60HZ 0xD1F2

/**
 * MultiC ac coupled pv inverter ac frequency (shutdown) for 60Hz systems
 * (internal) {un16 = Frequency [0.01HZ], 0xFFFF = Not Available}
 */
#define VE_REG_MULTIC_PV_INVERTER_FREQ_STOP_60HZ 0xD1F3

/**
 * MultiC ac coupled pv inverter re-bulk voltage offset (internal) {sn16 =
 * Voltage [0.01V], 0x7FFF = Not Available}
 */
#define VE_REG_MULTIC_PV_INVERTER_RE_BULK_VOLTAGE_OFFSET 0xD1F4

/** MultiC inverter ADC_IAC_IN (internal) {un16 = data} */
#define VE_REG_INV_ADC_IAC_IN 0xD300

/** MultiC inverter ADC_IAC_IN_GAIN (internal) {un16 = data} */
#define VE_REG_INV_ADC_IAC_IN_GAIN 0xD301

/** MultiC inverter ADC_IAC_IN_IM (internal) {sn32 = data} */
#define VE_REG_INV_ADC_IAC_IN_IM 0xD302

/** MultiC inverter ADC_IAC_IN_MEAN (internal) {un16 = data} */
#define VE_REG_INV_ADC_IAC_IN_MEAN 0xD303

/** MultiC inverter ADC_IAC_IN_RAW (internal) {un16 = data} */
#define VE_REG_INV_ADC_IAC_IN_RAW 0xD304

/** MultiC inverter ADC_IAC_IN_RE (internal) {sn32 = data} */
#define VE_REG_INV_ADC_IAC_IN_RE 0xD305

/** MultiC inverter ADC_IGFCI (internal) {sn16 = data} */
#define VE_REG_INV_ADC_IGFCI 0xD306

/** MultiC inverter ADC_IGFCI_GAIN (internal) {un16 = data} */
#define VE_REG_INV_ADC_IGFCI_GAIN 0xD307

/** MultiC inverter ADC_IGFCI_MEAN (internal) {un16 = data} */
#define VE_REG_INV_ADC_IGFCI_MEAN 0xD308

/** MultiC inverter ADC_IGFCI_OFFSET (internal) {sn16 = data} */
#define VE_REG_INV_ADC_IGFCI_OFFSET 0xD309

/** MultiC inverter ADC_IGFCI_RAW (internal) {un16 = data} */
#define VE_REG_INV_ADC_IGFCI_RAW 0xD30A

/** MultiC inverter ADC_UAC_IN (internal) {un16 = data} */
#define VE_REG_INV_ADC_UAC_IN 0xD30B

/** MultiC inverter ADC_UAC_IN_GAIN (internal) {un16 = data} */
#define VE_REG_INV_ADC_UAC_IN_GAIN 0xD30C

/** MultiC inverter ADC_UAC_IN_IM (internal) {sn32 = data} */
#define VE_REG_INV_ADC_UAC_IN_IM 0xD30D

/** MultiC inverter ADC_UAC_IN_MEAN (internal) {un16 = data} */
#define VE_REG_INV_ADC_UAC_IN_MEAN 0xD30E

/** MultiC inverter ADC_UAC_IN_RAW (internal) {un16 = data} */
#define VE_REG_INV_ADC_UAC_IN_RAW 0xD30F

/** MultiC inverter ADC_UAC_IN_RE (internal) {sn32 = data} */
#define VE_REG_INV_ADC_UAC_IN_RE 0xD310

/** MultiC inverter ADC_UGND_RELAY (internal) {un16 = data} */
#define VE_REG_INV_ADC_UGND_RELAY 0xD311

/** MultiC inverter ADC_UGND_RELAY_GAIN (internal) {un16 = data} */
#define VE_REG_INV_ADC_UGND_RELAY_GAIN 0xD312

/** MultiC inverter ADC_UGND_RELAY_MEAN (internal) {un16 = data} */
#define VE_REG_INV_ADC_UGND_RELAY_MEAN 0xD313

/** MultiC inverter ADC_UGND_RELAY_RAW (internal) {un16 = data} */
#define VE_REG_INV_ADC_UGND_RELAY_RAW 0xD314

/** MultiC inverter BRIDGE_DEAD_TIME (internal) {un8 = data} */
#define VE_REG_INV_BRIDGE_DEAD_TIME 0xD315

/** MultiC inverter BRIDGE_MAX_PWM_PERIOD_MARGIN (internal) {un8 = data} */
#define VE_REG_INV_BRIDGE_MAX_PWM_PERIOD_MARGIN 0xD316

/** MultiC inverter BRIDGE_MIN_PWM_PULSE (internal) {un8 = data} */
#define VE_REG_INV_BRIDGE_MIN_PWM_PULSE 0xD317

/** MultiC inverter BRIDGE_PERIOD (internal) {un16 = data} */
#define VE_REG_INV_BRIDGE_PERIOD 0xD318

/** MultiC inverter LOOP_UBAT_COMP_MIN (internal) {un16 = data} */
#define VE_REG_INV_LOOP_UBAT_COMP_MIN 0xD319

/** MultiC inverter MOD_SLOPE_TRIGGER (internal) {un16 = data} */
#define VE_REG_INV_MOD_SLOPE_TRIGGER 0xD31A

/** MultiC inverter PLL_CONTROL_P (internal) {un16 = data} */
#define VE_REG_INV_PLL_CONTROL_P 0xD31B

/** MultiC inverter PLL_CONTROL_I (internal) {un16 = data} */
#define VE_REG_INV_PLL_CONTROL_I 0xD31C

/** MultiC inverter PLL_CONTROL_D (internal) {un16 = data} */
#define VE_REG_INV_PLL_CONTROL_D 0xD31D

/**
 * MultiC inverter PLL_GET_CAPTURE (internal) {un16 = Time [1e-06s], 0xFFFF = Not
 * Available}
 */
#define VE_REG_INV_PLL_GET_CAPTURE 0xD31E

/**
 * MultiC inverter PLL_GET_CAPTURE_PERIOD (internal) {un16 = Time [1e-06s],
 * 0xFFFF = Not Available}
 */
#define VE_REG_INV_PLL_GET_CAPTURE_PERIOD 0xD31F

/**
 * MultiC inverter PLL_GET_PERIOD_OUT (internal) {un16 = Time [1e-06s], 0xFFFF =
 * Not Available}
 */
#define VE_REG_INV_PLL_GET_PERIOD_OUT 0xD320

/**
 * MultiC inverter PLL_GET_PERIOD_UAC_IN (internal) {un16 = Time [1e-06s], 0xFFFF
 * = Not Available}
 */
#define VE_REG_INV_PLL_GET_PERIOD_UAC_IN 0xD321

/** MultiC inverter PLL_GET_PHASE_IAC_IN (internal) {sn16 = data} */
#define VE_REG_INV_PLL_GET_PHASE_IAC_IN 0xD322

/** MultiC inverter PLL_GET_PHASE_UAC_IN (internal) {sn16 = data} */
#define VE_REG_INV_PLL_GET_PHASE_UAC_IN 0xD323

/** MultiC inverter PLL_GET_STATUS (internal) {un16 = data} */
#define VE_REG_INV_PLL_GET_STATUS 0xD324

/** MultiC inverter PLL_MODE (internal) {un16 = data} */
#define VE_REG_INV_PLL_MODE 0xD327

/** MultiC inverter PLL_PHASE_SETPOINT (internal) {sn16 = data} */
#define VE_REG_INV_PLL_PHASE_SETPOINT 0xD328

/** MultiC inverter PLL_SLEW_RATE (internal) {un16 = data} */
#define VE_REG_INV_PLL_SLEW_RATE 0xD329

/** MultiC inverter PROT_GET_UAC_IN_STATUS (internal) {sn8 = data} */
#define VE_REG_INV_PROT_GET_UAC_IN_STATUS 0xD32A

/** MultiC inverter PROT_GET_UBUS_STATUS (internal) {sn8 = data} */
#define VE_REG_INV_PROT_GET_UBUS_STATUS 0xD32B

/** MultiC inverter PROT_UAC_IN_LEVEL2HIGH (internal) {un16 = data} */
#define VE_REG_INV_PROT_UAC_IN_LEVEL2HIGH 0xD32C

/** MultiC inverter PROT_UAC_IN_LEVEL2LOW (internal) {un16 = data} */
#define VE_REG_INV_PROT_UAC_IN_LEVEL2LOW 0xD32D

/** MultiC inverter PROT_UAC_IN_LEVEL_WARNING_HIGH (internal) {un16 = data} */
#define VE_REG_INV_PROT_UAC_IN_LEVEL_WARNING_HIGH 0xD32E

/** MultiC inverter PROT_UAC_IN_LEVEL_WARNING_LOW (internal) {un16 = data} */
#define VE_REG_INV_PROT_UAC_IN_LEVEL_WARNING_LOW 0xD32F

/** MultiC inverter PROT_UBUS_LEVEL2LOW (internal) {un16 = data} */
#define VE_REG_INV_PROT_UBUS_LEVEL2LOW 0xD330

/** MultiC inverter PROT_UBUS_LEVEL_WARNING_LOW (internal) {un16 = data} */
#define VE_REG_INV_PROT_UBUS_LEVEL_WARNING_LOW 0xD331

/** MultiC inverter RELAY_GET_STATE (internal) {un8 = data} */
#define VE_REG_INV_RELAY_GET_STATE 0xD332

/** MultiC inverter PLL_LOCK_PHASE_MARGIN (internal) {sn16 = data} */
#define VE_REG_INV_PLL_LOCK_PHASE_MARGIN 0xD333

/** MultiC inverter LOOP_UAC_IN_UINV_DIF (internal) {sn16 = data} */
#define VE_REG_INV_LOOP_UAC_IN_UINV_DIF 0xD334

/** MultiC inverter RELAY_ENABLE_MASK (internal) {un8 = data} */
#define VE_REG_INV_RELAY_ENABLE_MASK 0xD335

/** MultiC inverter PLL_LOCK1TH_HARM_MIN (internal) {un32 = data} */
#define VE_REG_INV_PLL_LOCK1TH_HARM_MIN 0xD336

/** MultiC inverter RELAY_LEVEL_PITCH (internal) {un16 = data} */
#define VE_REG_INV_RELAY_LEVEL_PITCH 0xD337

/** MultiC inverter RELAY_LEVEL_ON (internal) {un16 = data} */
#define VE_REG_INV_RELAY_LEVEL_ON 0xD338

/** MultiC inverter RELAY_TIME_PITCH (internal) {un16 = data} */
#define VE_REG_INV_RELAY_TIME_PITCH 0xD339

/** MultiC inverter RELAY_UAC_IN_UINV_DIF_MAX (internal) {un16 = data} */
#define VE_REG_INV_RELAY_UAC_IN_UINV_DIF_MAX 0xD33A

/** MultiC inverter LOOP_ROUT (internal) {un16 = data} */
#define VE_REG_INV_LOOP_ROUT 0xD33B

/** MultiC inverter LOOP_GET_AMPLITUDE_GAIN (internal) {un16 = data} */
#define VE_REG_INV_LOOP_GET_AMPLITUDE_GAIN 0xD33C

/** MultiC inverter RELAY_AC_IN_MIN_OFF_COUNT (internal) {un16 = data} */
#define VE_REG_INV_RELAY_AC_IN_MIN_OFF_COUNT 0xD33D

/** MultiC inverter PROT_UBUS_LEVEL2HIGH (internal) {un16 = data} */
#define VE_REG_INV_PROT_UBUS_LEVEL2HIGH 0xD33E

/** MultiC inverter ADC_UAC_OUT (internal) {un16 = data} */
#define VE_REG_INV_ADC_UAC_OUT 0xD33F

/** MultiC inverter ADC_UAC_OUT_GAIN (internal) {un16 = data} */
#define VE_REG_INV_ADC_UAC_OUT_GAIN 0xD340

/** MultiC inverter ADC_UAC_OUT_MEAN (internal) {un16 = data} */
#define VE_REG_INV_ADC_UAC_OUT_MEAN 0xD341

/** MultiC inverter ADC_UAC_OUT_RAW (internal) {un16 = data} */
#define VE_REG_INV_ADC_UAC_OUT_RAW 0xD342

/** MultiC inverter LOOP_GET_AMPLITUDE_NORM (internal) {un16 = data} */
#define VE_REG_INV_LOOP_GET_AMPLITUDE_NORM 0xD345

/** MultiC inverter PLL_GET_PHASE_IINV (internal) {sn16 = data} */
#define VE_REG_INV_PLL_GET_PHASE_IINV 0xD346

/** MultiC inverter PLL_GET_PHASE_UINV (internal) {sn16 = data} */
#define VE_REG_INV_PLL_GET_PHASE_UINV 0xD347

/** MultiC inverter PROT_GET_TURN_ON_TEST_STATUS (internal) {un8 = data} */
#define VE_REG_INV_PROT_GET_TURN_ON_TEST_STATUS 0xD34B

/** MultiC inverter PROT_UAC_OUT_LEVEL2LOW (internal) {un16 = data} */
#define VE_REG_INV_PROT_UAC_OUT_LEVEL2LOW 0xD34C

/** MultiC inverter PROT_UAC_OUT_LEVEL_LOW (internal) {un16 = data} */
#define VE_REG_INV_PROT_UAC_OUT_LEVEL_LOW 0xD34D

/** MultiC inverter PROT_UAC_OUT_LEVEL_HIGH (internal) {un16 = data} */
#define VE_REG_INV_PROT_UAC_OUT_LEVEL_HIGH 0xD34E

/** MultiC inverter PROT_UAC_OUT_LEVEL2HIGH (internal) {un16 = data} */
#define VE_REG_INV_PROT_UAC_OUT_LEVEL2HIGH 0xD34F

/** MultiC inverter PROT_UAC_OUT_IS_LOW_COUNT (internal) {un16 = data} */
#define VE_REG_INV_PROT_UAC_OUT_IS_LOW_COUNT 0xD350

/** MultiC inverter PROT_UAC_OUT_IS_HIGH_COUNT (internal) {un16 = data} */
#define VE_REG_INV_PROT_UAC_OUT_IS_HIGH_COUNT 0xD351

/** MultiC inverter PROT_GET_UAC_OUT_STATUS (internal) {sn8 = data} */
#define VE_REG_INV_PROT_GET_UAC_OUT_STATUS 0xD352

/** MultiC inverter PROT_IINV_LEVEL_HIGH_COLD (internal) {un16 = data} */
#define VE_REG_INV_PROT_IINV_LEVEL_HIGH_COLD 0xD353

/** MultiC inverter PROT_IINV_LEVEL_HIGH_HOT (internal) {un16 = data} */
#define VE_REG_INV_PROT_IINV_LEVEL_HIGH_HOT 0xD354

/** MultiC inverter PROT_UINV_DC_MARGIN_COUNT (internal) {un16 = data} */
#define VE_REG_INV_PROT_UINV_DC_MARGIN_COUNT 0xD356

/** MultiC inverter MOD_FAST_UPEAK_COUNT (internal) {un16 = data} */
#define VE_REG_INV_MOD_FAST_UPEAK_COUNT 0xD358

/** MultiC inverter PROT_UINV_DC_MARGIN_SUPPRESS_COUNT (internal) {un16 = data} */
#define VE_REG_INV_PROT_UINV_DC_MARGIN_SUPPRESS_COUNT 0xD359

/** MultiC inverter PROT_UPEAK_SET_PERIODS (internal) {un16 = data} */
#define VE_REG_INV_PROT_UPEAK_SET_PERIODS 0xD35A

/** MultiC inverter PROT_UPEAK_CLEAR_PERIODS (internal) {un16 = data} */
#define VE_REG_INV_PROT_UPEAK_CLEAR_PERIODS 0xD35B

/** MultiC inverter PLL_LOCK_RANGE_MAX (internal) {sn16 = data} */
#define VE_REG_INV_PLL_LOCK_RANGE_MAX 0xD35C

/** MultiC inverter PLL_LOCK_RANGE_MIN (internal) {sn16 = data} */
#define VE_REG_INV_PLL_LOCK_RANGE_MIN 0xD35D

/** MultiC inverter ADC_UAC_OUT_AVERAGE (internal) {sn16 = data} */
#define VE_REG_INV_ADC_UAC_OUT_AVERAGE 0xD35E

/** MultiC inverter ADC_UINV_AVERAGE (internal) {sn16 = data} */
#define VE_REG_INV_ADC_UINV_AVERAGE 0xD35F

/** MultiC inverter ADC_UAC_OUT_OFFSET (internal) {sn16 = data} */
#define VE_REG_INV_ADC_UAC_OUT_OFFSET 0xD360

/** MultiC inverter ADC_UINV_AVERAGE_FAST (internal) {sn16 = data} */
#define VE_REG_INV_ADC_UINV_AVERAGE_FAST 0xD361

/** MultiC inverter RELAY_TEST_MASK (internal) {un8 = data} */
#define VE_REG_INV_RELAY_TEST_MASK 0xD364

/** MultiC inverter PROT_UINV_AC_MARGIN_AT_START (internal) {un16 = data} */
#define VE_REG_INV_PROT_UINV_AC_MARGIN_AT_START 0xD365

/** MultiC inverter PROT_UAC_OUT_HIGH_AT_START (internal) {un16 = data} */
#define VE_REG_INV_PROT_UAC_OUT_HIGH_AT_START 0xD366

/** MultiC inverter PROT_UINV_DC_MARGIN (internal) {un16 = data} */
#define VE_REG_INV_PROT_UINV_DC_MARGIN 0xD367

/** MultiC inverter ADC_IINV_IM (internal) {sn32 = data} */
#define VE_REG_INV_ADC_IINV_IM 0xD368

/** MultiC inverter ADC_IINV_RE (internal) {sn32 = data} */
#define VE_REG_INV_ADC_IINV_RE 0xD369

/** MultiC inverter PLL_TEST_COMMAND (internal) {un16 = data} */
#define VE_REG_INV_PLL_TEST_COMMAND 0xD36A

/** MultiC inverter PLL_TEST_INSERT_PERIOD_STEP (internal) {sn16 = data} */
#define VE_REG_INV_PLL_TEST_INSERT_PERIOD_STEP 0xD36B

/** MultiC inverter ADC_IINV_RE_OFFSET (internal) {sn16 = data} */
#define VE_REG_INV_ADC_IINV_RE_OFFSET 0xD36C

/** MultiC inverter ADC_IINV_IM_OFFSET (internal) {sn16 = data} */
#define VE_REG_INV_ADC_IINV_IM_OFFSET 0xD36D

/** MultiC inverter ADC_IINV_RE_OFFSET_DIF_LOW_UBUS (internal) {sn16 = data} */
#define VE_REG_INV_ADC_IINV_RE_OFFSET_DIF_LOW_UBUS 0xD36E

/** MultiC inverter ADC_IINV_RE_OFFSET_DIF_HIGH_UBUS (internal) {sn16 = data} */
#define VE_REG_INV_ADC_IINV_RE_OFFSET_DIF_HIGH_UBUS 0xD36F

/** MultiC inverter ADC_IINV_CALC_PHASE (internal) {sn16 = data} */
#define VE_REG_INV_ADC_IINV_CALC_PHASE 0xD370

/**
 * MultiC inverter INTERNAL_GET50HZ_NOT60HZ (internal) {un8 = freq, 0x00 = 60HZ,
 * 0x01 = 50HZ, 0xFF = Not Available}
 */
#define VE_REG_INV_INTERNAL_GET50HZ_NOT60HZ 0xD371

/** MultiC inverter INTERNAL_OPERATING_MODE (internal) {un8 = data} */
#define VE_REG_INV_INTERNAL_OPERATING_MODE 0xD372

/**
 * MultiC DCAC DC bus power (internal) {sn32 = Power [0.001W], 0x7FFFFFFF = Not
 * Available}
 */
#define VE_REG_INV_SI_DC_INV_POWER 0xD374

/** MultiC inverter PLL_IAC_IN_SPEED (internal) {un16 = data} */
#define VE_REG_INV_PLL_IAC_IN_SPEED 0xD375

/**
 * MultiC inverter PLL_IAC_IN_THRESHOLD (internal) {un16 = MultiC inverter
 * PLL_IAC_IN_THRESHOLD [0.001A]}
 */
#define VE_REG_INV_PLL_IAC_IN_THRESHOLD 0xD376

/**
 * MultiC inverter SI_AC_IN1_VOLTAGE (internal) {sn32 = Voltage [0.001V],
 * 0x7FFFFFFF = Not Available}
 */
#define VE_REG_INV_SI_AC_IN1_VOLTAGE 0xD377

/** MultiC inverter CONTROL_ACIN (internal) {un32 = data} */
#define VE_REG_INV_CONTROL_ACIN 0xD378

/**
 * MultiC inverter SI_AC_IN1_POWER (internal) {sn32 = Power [0.001W], 0x7FFFFFFF
 * = Not Available}
 */
#define VE_REG_INV_SI_AC_IN1_POWER 0xD37A

/**
 * MultiC inverter SI_AC_OUT_POWER (internal) {sn32 = Power [0.001W], 0x7FFFFFFF
 * = Not Available}
 */
#define VE_REG_INV_SI_AC_OUT_POWER 0xD37B

/**
 * MultiC inverter SI_GROUND_RELAY_VOLTAGE (internal) {sn32 = Voltage [0.001V],
 * 0x7FFFFFFF = Not Available}
 */
#define VE_REG_INV_SI_GROUND_RELAY_VOLTAGE 0xD37C

/**
 * MultiC inverter CONTROL_SETPOINT_IINV (internal) {sn32 = Current [0.001A],
 * 0x7FFFFFFF = Not Available}
 */
#define VE_REG_INV_CONTROL_SETPOINT_IINV 0xD37D

/**
 * MultiC inverter SI_AC_OUT_CURRENT (internal) {sn32 = Current [0.001A],
 * 0x7FFFFFFF = Not Available}
 */
#define VE_REG_INV_SI_AC_OUT_CURRENT 0xD37E

/**
 * MultiC inverter SI_AC_OUT_CURRENT_LOW1 (internal) {sn32 = Current [0.001A],
 * 0x7FFFFFFF = Not Available}
 */
#define VE_REG_INV_SI_AC_OUT_CURRENT_LOW1 0xD37F

/**
 * MultiC inverter SI_AC_OUT_CURRENT_LOW0 (internal) {sn32 = Current [0.001A],
 * 0x7FFFFFFF = Not Available}
 */
#define VE_REG_INV_SI_AC_OUT_CURRENT_LOW0 0xD380

/**
 * MultiC inverter SI_AC_OUT_CURRENT_HIGH0 (internal) {sn32 = Current [0.001A],
 * 0x7FFFFFFF = Not Available}
 */
#define VE_REG_INV_SI_AC_OUT_CURRENT_HIGH0 0xD381

/**
 * MultiC inverter SI_AC_OUT_CURRENT_HIGH1 (internal) {sn32 = Current [0.001A],
 * 0x7FFFFFFF = Not Available}
 */
#define VE_REG_INV_SI_AC_OUT_CURRENT_HIGH1 0xD382

/**
 * MultiC inverter SI_AC_IN1_CURRENT (internal) {sn32 = Current [0.001A],
 * 0x7FFFFFFF = Not Available}
 */
#define VE_REG_INV_SI_AC_IN1_CURRENT 0xD383

/**
 * MultiC inverter SI_AC_INV_VOLTAGE (internal) {sn32 = Voltage [0.001V],
 * 0x7FFFFFFF = Not Available}
 */
#define VE_REG_INV_SI_AC_INV_VOLTAGE 0xD384

/** MultiC inverter CONTROL_FEEDBACK_SOURCE (internal) {sn16 = data} */
#define VE_REG_INV_CONTROL_FEEDBACK_SOURCE 0xD385

/** MultiC inverter CONTROL_MODE (internal) {un16 = data} */
#define VE_REG_INV_CONTROL_MODE 0xD386

/** MultiC inverter CONTROL_RINV (internal) {sn32 = data} */
#define VE_REG_INV_CONTROL_RINV 0xD387

/** MultiC inverter CONTROL_FB_IERROR_P (internal) {un16 = data} */
#define VE_REG_INV_CONTROL_FB_IERROR_P 0xD388

/** MultiC inverter CONTROL_FB_IERROR_I (internal) {un16 = data} */
#define VE_REG_INV_CONTROL_FB_IERROR_I 0xD389

/** MultiC inverter PLL_GRID_DETECTION_DRIFT (internal) {sn16 = data} */
#define VE_REG_INV_PLL_GRID_DETECTION_DRIFT 0xD38A

/** MultiC inverter WAVE_UACIN_FEEDFORWARD (internal) {un16 = data} */
#define VE_REG_INV_WAVE_UACIN_FEEDFORWARD 0xD38B

/** MultiC inverter WAVE_UACIN_FEEDFORWARD_MIX (internal) {un16 = data} */
#define VE_REG_INV_WAVE_UACIN_FEEDFORWARD_MIX 0xD38C

/** MultiC inverter WAVE_UACIN_FEEDFORWARD_COS (internal) {sn16 = data} */
#define VE_REG_INV_WAVE_UACIN_FEEDFORWARD_COS 0xD38D

/** MultiC inverter CONTROL_DCAC_STATE (internal) {un8 = data} */
#define VE_REG_INV_CONTROL_DCAC_STATE 0xD38E

/**
 * MultiC inverter SI_AC_IN1_APPARENT_POWER (internal) {sn32 = Apparent Power
 * [0.001VA], 0x7FFFFFFF = Not Available}
 */
#define VE_REG_INV_SI_AC_IN1_APPARENT_POWER 0xD394

/**
 * MultiC inverter SI_AC_OUT_APPARENT_POWER (internal) {sn32 = Apparent Power
 * [0.001VA], 0x7FFFFFFF = Not Available}
 */
#define VE_REG_INV_SI_AC_OUT_APPARENT_POWER 0xD39C

/**
 * MultiC inverter SI_AC_OUT_CURRENT_RE (internal) {sn32 = Current [0.001A],
 * 0x7FFFFFFF = Not Available}
 */
#define VE_REG_INV_SI_AC_OUT_CURRENT_RE 0xD39F

/**
 * MultiC inverter SI_AC_INV_CURRENT_RE (internal) {sn32 = Current [0.001A],
 * 0x7FFFFFFF = Not Available}
 */
#define VE_REG_INV_SI_AC_INV_CURRENT_RE 0xD3A1

/**
 * MultiC inverter SI_AC_INV_CURRENT_BALANCE (internal) {sn32 = Current [0.001A],
 * 0x7FFFFFFF = Not Available}
 */
#define VE_REG_INV_SI_AC_INV_CURRENT_BALANCE 0xD3A3

/** MultiC inverter INTERNAL_DISCONNECT_REASON (internal) {un32 = reason} */
#define VE_REG_INV_INTERNAL_DISCONNECT_REASON 0xD3A6

/** MultiC inverter WAVE_DISTORTION_TEST_LEVEL (internal) {un16 = data} */
#define VE_REG_INV_WAVE_DISTORTION_TEST_LEVEL 0xD3FE

/** MultiC inverter ADC_UBUS_SAMPLE (internal) {un16 = data} */
#define VE_REG_INV_ADC_UBUS_SAMPLE 0xD3FF

/** MultiC MPPT number of trackers (internal) {un8 = Count} */
#define VE_REG_MULTIC_MPPT_TRACKERS 0xD400

/**
 * MultiC MPPT options (bitmask) (internal) {bits[1] = Enable MPPT, 0 = No, 1 =
 * Yes : bits[1] = Enable Power Limit, 0 = No, 1 = Yes : bits[1] = Enable
 * PVShort, 0 = No, 1 = Yes : bits[1] = Enable Ipv Limit, 0 = No, 1 = Yes :
 * bits[1] = Enable Temperature Check, 0 = No, 1 = Yes : bits[1] = Enable Partial
 * Shading, 0 = No, 1 = Yes : bits[1] = Enhanced Tod, 0 = No, 1 = Yes : bits[1] =
 * reserved 7, 0 = No, 1 = Yes : bits[1] = reserved 8, 0 = No, 1 = Yes : bits[1]
 * = reserved 9, 0 = No, 1 = Yes : bits[1] = reserved 10, 0 = No, 1 = Yes :
 * bits[1] = reserved 11, 0 = No, 1 = Yes : bits[1] = reserved 12, 0 = No, 1 =
 * Yes : bits[1] = reserved 13, 0 = No, 1 = Yes : bits[1] = reserved 14, 0 = No,
 * 1 = Yes : bits[1] = reserved 15, 0 = No, 1 = Yes}
 */
#define VE_REG_MULTIC_MPPT_OPT 0xD401

/**
 * MultiC MPPT flags (bitmask) (internal) {bits[1] = MPPTActive, 0 = No, 1 = Yes
 * : bits[1] = Supply Ok, 0 = No, 1 = Yes : bits[1] = Have Power, 0 = No, 1 = Yes
 * : bits[1] = Day Detection, 0 = No, 1 = Yes : bits[1] = High Panel Voltage, 0 =
 * No, 1 = Yes : bits[1] = Updater Busy, 0 = No, 1 = Yes : bits[1] = Settings Ok,
 * 0 = No, 1 = Yes : bits[1] = PIControl, 0 = No, 1 = Yes : bits[1] = Atk
 * Failure, 0 = No, 1 = Yes : bits[1] = b3V3Ok, 0 = No, 1 = Yes : bits[1] =
 * b15VOk, 0 = No, 1 = Yes : bits[1] = Ac In1Valid, 0 = No, 1 = Yes : bits[1] =
 * reserved 12, 0 = No, 1 = Yes : bits[1] = reserved 13, 0 = No, 1 = Yes :
 * bits[1] = reserved 14, 0 = No, 1 = Yes : bits[1] = reserved 15, 0 = No, 1 =
 * Yes}
 */
#define VE_REG_MULTIC_MPPT_FLAGS 0xD402

/**
 * MultiC MPPT errors (bitmask) (internal) {bits[1] = Bus Ovp, 0 = No, 1 = Yes :
 * bits[1] = Gnd Relay Failure, 0 = No, 1 = Yes : bits[1] = Vpv Limit Detected, 0
 * = No, 1 = Yes : bits[1] = Atk Failure, 0 = No, 1 = Yes : bits[1] = Temperature
 * Limit Detected, 0 = No, 1 = Yes : bits[1] = Temperature Sensor Conn Lost, 0 =
 * No, 1 = Yes : bits[1] = Temperature Sensor Short, 0 = No, 1 = Yes : bits[1] =
 * TFSFailure, 0 = No, 1 = Yes : bits[1] = Gnd Voltage Failure, 0 = No, 1 = Yes :
 * bits[1] = reserved 9, 0 = No, 1 = Yes : bits[1] = reserved 10, 0 = No, 1 = Yes
 * : bits[1] = reserved 11, 0 = No, 1 = Yes : bits[1] = reserved 12, 0 = No, 1 =
 * Yes : bits[1] = reserved 13, 0 = No, 1 = Yes : bits[1] = reserved 14, 0 = No,
 * 1 = Yes : bits[1] = reserved 15, 0 = No, 1 = Yes}
 */
#define VE_REG_MULTIC_MPPT_ERR 0xD403

/**
 * MultiC MPPT temperature (internal) {sn32 = Temperature [0.001°C], 0x7FFFFFFF =
 * Not Available}
 */
#define VE_REG_MULTIC_MPPT_TEMPERATURE 0xD404

/** MultiC MPPT over-voltage event counter (internal) {un32 = Events} */
#define VE_REG_MULTIC_MPPT_OVPS 0xD405

/**
 * MultiC MPPT input power (internal) {sn32 = Power [0.001W], 0x7FFFFFFF = Not
 * Available}
 */
#define VE_REG_MULTIC_MPPT_POWER 0xD406

/**
 * MultiC MPPT DC bus power (internal) {sn32 = Power [0.001W], 0x7FFFFFFF = Not
 * Available}
 */
#define VE_REG_MULTIC_MPPT_DC_BUS_POWER 0xD407

/**
 * MultiC MPPT energy harvest (internal) {un32 = Energy [0.001kWh], 0xFFFFFFFF =
 * Not Available}
 */
#define VE_REG_MULTIC_MPPT_YIELD 0xD408

/**
 * MultiC MPPT DC bus voltage (internal) {sn32 = Voltage [0.001V], 0x7FFFFFFF =
 * Not Available}
 */
#define VE_REG_MULTIC_MPPT_DC_BUS_VOLTAGE 0xD409

/**
 * MultiC MPPT CPU temperature (instance 4) (internal) {sn32 = Temperature
 * [0.001°C], 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT_CPU_TEMPERATURE 0xD40A

/**
 * MultiC MPPT CPU voltage (instance 4) (internal) {sn32 = Voltage [0.001V],
 * 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT_3V3 0xD40B

/**
 * MultiC MPPT ground relay voltage (internal) {sn32 = Voltage [0.001V],
 * 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT_GROUND_RELAY_VOLTAGE 0xD40C

/**
 * MultiC MPPT mains current (internal) {sn32 = Current [0.001A], 0x7FFFFFFF =
 * Not Available}
 */
#define VE_REG_MULTIC_MPPT_MAINS_CURRENT 0xD40D

/**
 * MultiC MPPT AC output voltage (internal) {sn32 = Voltage [0.001V], 0x7FFFFFFF
 * = Not Available}
 */
#define VE_REG_MULTIC_MPPT_AC_OUT_VOLTAGE 0xD40E

/**
 * MultiC MPPT AC input voltage (internal) {sn32 = Voltage [0.001V], 0x7FFFFFFF =
 * Not Available}
 */
#define VE_REG_MULTIC_MPPT_AC_IN_VOLTAGE 0xD40F

/**
 * MultiC MPPT input peak power (internal) {sn32 = Power [0.001W], 0x7FFFFFFF =
 * Not Available}
 */
#define VE_REG_MULTIC_MPPT_PEAKPOWER 0xD410

/**
 * MultiC MPPT incoming SYNC signal period time (internal) {un16 = Time [1e-06s],
 * 0xFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT_SYNC_IN 0xD411

/**
 * MultiC MPPT PVRISO1 voltage (internal) {sn32 = Voltage [0.001V], 0x7FFFFFFF =
 * Not Available}
 */
#define VE_REG_MULTIC_MPPT_PVRISO1_VOLTAGE 0xD412

/**
 * MultiC MPPT PVRISO2 voltage (internal) {sn32 = Voltage [0.001V], 0x7FFFFFFF =
 * Not Available}
 */
#define VE_REG_MULTIC_MPPT_PVRISO2_VOLTAGE 0xD413

/**
 * MultiC RELAY feedback (internal) {bits[1] = Mppt Ground Relay, 0 = No, 1 = Yes
 * : bits[1] = Mppt Acin1L1Relay, 0 = No, 1 = Yes : bits[1] = Mppt Acin1N1Relay,
 * 0 = No, 1 = Yes : bits[1] = Mppt Acin1N2Relay, 0 = No, 1 = Yes : bits[1] =
 * Dcac Acin1Relay Enable, 0 = No, 1 = Yes : bits[1] = reserved 5, 0 = No, 1 =
 * Yes : bits[1] = reserved 6, 0 = No, 1 = Yes : bits[1] = reserved 7, 0 = No, 1
 * = Yes}
 */
#define VE_REG_MULTIC_MPPT_RELAY_FEEDBACK 0xD414

/**
 * MultiC MPPT AC IN1 signal period time (internal) {un16 = Time [1e-06s], 0xFFFF
 * = Not Available}
 */
#define VE_REG_MULTIC_MPPT_AC_IN1_PERIOD 0xD415

/** MultiC HSI trim (internal) {un32 = trim} */
#define VE_REG_MULTIC_MPPT_HSITRIM 0xD416

/**
 * MultiC MPPT PV input isolation resistance (internal) {un32 = Resistance
 * [1Ohm], 0xFFFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT_PVRISO_RESISTANCE 0xD417

/**
 * MultiC MPPT temperature limit (internal) {sn32 = Temperature [0.001°C],
 * 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT_TEMPERATURE_LIMIT 0xD418

/** MultiC MPPT grid disconnect reason (internal) {un32 = reason} */
#define VE_REG_MULTIC_MPPT_GRID_DISCONNECT_REASON 0xD419

/** MultiC MPPT state (tracker 1) (internal) {un16 = state (see xml for meanings)} */
#define VE_REG_MULTIC_MPPT1_STATE 0xD440

/**
 * MultiC MPPT options (bitmask, tracker 1) (internal) {bits[1] = Enable MPPT, 0
 * = No, 1 = Yes : bits[1] = Allow Start, 0 = No, 1 = Yes : bits[1] = reserved 2,
 * 0 = No, 1 = Yes : bits[1] = reserved 3, 0 = No, 1 = Yes : bits[1] = reserved
 * 4, 0 = No, 1 = Yes : bits[1] = reserved 5, 0 = No, 1 = Yes : bits[1] =
 * reserved 6, 0 = No, 1 = Yes : bits[1] = reserved 7, 0 = No, 1 = Yes : bits[1]
 * = reserved 8, 0 = No, 1 = Yes : bits[1] = reserved 9, 0 = No, 1 = Yes :
 * bits[1] = reserved 10, 0 = No, 1 = Yes : bits[1] = reserved 11, 0 = No, 1 =
 * Yes : bits[1] = reserved 12, 0 = No, 1 = Yes : bits[1] = reserved 13, 0 = No,
 * 1 = Yes : bits[1] = reserved 14, 0 = No, 1 = Yes : bits[1] = reserved 15, 0 =
 * No, 1 = Yes}
 */
#define VE_REG_MULTIC_MPPT1_OPT 0xD441

/**
 * MultiC MPPT flags (bitmask, tracker 1) (internal) {bits[1] = MPPTActive, 0 =
 * No, 1 = Yes : bits[1] = MPPTDirection, 0 = No, 1 = Yes : bits[1] = PVShort
 * Active, 0 = No, 1 = Yes : bits[1] = Day Detection, 0 = No, 1 = Yes : bits[1] =
 * PIControl, 0 = No, 1 = Yes : bits[1] = MPPTControl, 0 = No, 1 = Yes : bits[1]
 * = High Panel Voltage, 0 = No, 1 = Yes : bits[1] = Converter Mode, 0 = No, 1 =
 * Yes : bits[1] = Atk Failure, 0 = No, 1 = Yes : bits[1] = reserved 9, 0 = No, 1
 * = Yes : bits[1] = reserved 10, 0 = No, 1 = Yes : bits[1] = reserved 11, 0 =
 * No, 1 = Yes : bits[1] = reserved 12, 0 = No, 1 = Yes : bits[1] = reserved 13,
 * 0 = No, 1 = Yes : bits[1] = reserved 14, 0 = No, 1 = Yes : bits[1] = reserved
 * 15, 0 = No, 1 = Yes}
 */
#define VE_REG_MULTIC_MPPT1_FLAGS 0xD442

/**
 * MultiC MPPT errors (bitmask, tracker 1) (internal) {bits[1] = Tracking Lost, 0
 * = No, 1 = Yes : bits[1] = Power Max Detected, 0 = No, 1 = Yes : bits[1] = Vpv
 * Limit Detected, 0 = No, 1 = Yes : bits[1] = Ipv Limit Detected, 0 = No, 1 =
 * Yes : bits[1] = Shading Detected, 0 = No, 1 = Yes : bits[1] = VBus Limit
 * Detected, 0 = No, 1 = Yes : bits[1] = Ipv Fast Limit, 0 = No, 1 = Yes :
 * bits[1] = reserved 7, 0 = No, 1 = Yes : bits[1] = reserved 8, 0 = No, 1 = Yes
 * : bits[1] = reserved 9, 0 = No, 1 = Yes : bits[1] = reserved 10, 0 = No, 1 =
 * Yes : bits[1] = reserved 11, 0 = No, 1 = Yes : bits[1] = reserved 12, 0 = No,
 * 1 = Yes : bits[1] = reserved 13, 0 = No, 1 = Yes : bits[1] = reserved 14, 0 =
 * No, 1 = Yes : bits[1] = reserved 15, 0 = No, 1 = Yes}
 */
#define VE_REG_MULTIC_MPPT1_ERR 0xD443

/** MultiC MPPT duty cycle (tracker 1) (internal) {un16 = data} */
#define VE_REG_MULTIC_MPPT1_DUTY 0xD444

/**
 * MultiC MPPT input power (tracker 1) (internal) {un32 = Power [0.001W],
 * 0xFFFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT1_POWER 0xD445

/**
 * MultiC MPPT DC bus power (tracker 1) (internal) {sn32 = Power [0.001W],
 * 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT1_DC_BUS_POWER 0xD446

/** MultiC MPPT panel-current zero bias level (tracker 1) (internal) {un16 = data} */
#define VE_REG_MULTIC_MPPT1_IPV_ZERO 0xD447

/** MultiC MPPT tracker step size (tracker 1) (internal) {un16 = data} */
#define VE_REG_MULTIC_MPPT1_STEPS 0xD448

/** MultiC MPPT minimum duty cycle (tracker 1) (internal) {un16 = data} */
#define VE_REG_MULTIC_MPPT1_DUTY_MIN 0xD449

/** MultiC MPPT minimum duty cycle (tracker 1) (internal) {un16 = data} */
#define VE_REG_MULTIC_MPPT1_MPP_DUTY 0xD44A

/**
 * MultiC MPPT peak input power (tracker 1) (internal) {un32 = Power [0.001W],
 * 0xFFFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT1_MPP_POWER 0xD44B

/**
 * MultiC MPPT peak panel voltage (tracker 1) (internal) {un32 = Voltage
 * [0.001V], 0xFFFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT1_MPP_VOLTAGE 0xD44C

/**
 * MultiC MPPT open-circuit panel voltage (tracker 1) (internal) {un32 = Voltage
 * [0.001V], 0xFFFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT1_OC_VOLTAGE 0xD44D

/** MultiC MPPT tracker maximum step size (tracker 1) (internal) {un16 = data} */
#define VE_REG_MULTIC_MPPT1_MAX_STEPSIZE 0xD44E

/** MultiC MPPT tracker minimum step size (tracker 1) (internal) {un16 = data} */
#define VE_REG_MULTIC_MPPT1_MIN_STEPSIZE 0xD44F

/**
 * MultiC MPPT panel voltage (tracker 1) (internal) {sn32 = Voltage [0.001V],
 * 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT1_VPV 0xD450

/**
 * MultiC MPPT panel current (tracker 1) (internal) {sn32 = Current [0.001A],
 * 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT1_IPV 0xD451

/**
 * MultiC MPPT energy harvest (tracker 1) (internal) {un32 = Energy [0.001kWh],
 * 0xFFFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT1_YIELD 0xD452

/**
 * MultiC MPPT input power limit (tracker 1) (internal) {un32 = Power [0.001W],
 * 0xFFFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT1_POWER_LIMIT 0xD453

/** MultiC MPPT state (tracker 2) (internal) {un16 = state (see xml for meanings)} */
#define VE_REG_MULTIC_MPPT2_STATE 0xD460

/**
 * MultiC MPPT options (bitmask, tracker 2) (internal) {bits[1] = Enable MPPT, 0
 * = No, 1 = Yes : bits[1] = Allow Start, 0 = No, 1 = Yes : bits[1] = reserved 2,
 * 0 = No, 1 = Yes : bits[1] = reserved 3, 0 = No, 1 = Yes : bits[1] = reserved
 * 4, 0 = No, 1 = Yes : bits[1] = reserved 5, 0 = No, 1 = Yes : bits[1] =
 * reserved 6, 0 = No, 1 = Yes : bits[1] = reserved 7, 0 = No, 1 = Yes : bits[1]
 * = reserved 8, 0 = No, 1 = Yes : bits[1] = reserved 9, 0 = No, 1 = Yes :
 * bits[1] = reserved 10, 0 = No, 1 = Yes : bits[1] = reserved 11, 0 = No, 1 =
 * Yes : bits[1] = reserved 12, 0 = No, 1 = Yes : bits[1] = reserved 13, 0 = No,
 * 1 = Yes : bits[1] = reserved 14, 0 = No, 1 = Yes : bits[1] = reserved 15, 0 =
 * No, 1 = Yes}
 */
#define VE_REG_MULTIC_MPPT2_OPT 0xD461

/**
 * MultiC MPPT flags (bitmask, tracker 2) (internal) {bits[1] = MPPTActive, 0 =
 * No, 1 = Yes : bits[1] = MPPTDirection, 0 = No, 1 = Yes : bits[1] = PVShort
 * Active, 0 = No, 1 = Yes : bits[1] = Day Detection, 0 = No, 1 = Yes : bits[1] =
 * PIControl, 0 = No, 1 = Yes : bits[1] = MPPTControl, 0 = No, 1 = Yes : bits[1]
 * = High Panel Voltage, 0 = No, 1 = Yes : bits[1] = Converter Mode, 0 = No, 1 =
 * Yes : bits[1] = Atk Failure, 0 = No, 1 = Yes : bits[1] = reserved 9, 0 = No, 1
 * = Yes : bits[1] = reserved 10, 0 = No, 1 = Yes : bits[1] = reserved 11, 0 =
 * No, 1 = Yes : bits[1] = reserved 12, 0 = No, 1 = Yes : bits[1] = reserved 13,
 * 0 = No, 1 = Yes : bits[1] = reserved 14, 0 = No, 1 = Yes : bits[1] = reserved
 * 15, 0 = No, 1 = Yes}
 */
#define VE_REG_MULTIC_MPPT2_FLAGS 0xD462

/**
 * MultiC MPPT errors (bitmask, tracker 2) (internal) {bits[1] = Tracking Lost, 0
 * = No, 1 = Yes : bits[1] = Power Max Detected, 0 = No, 1 = Yes : bits[1] = Vpv
 * Limit Detected, 0 = No, 1 = Yes : bits[1] = Ipv Limit Detected, 0 = No, 1 =
 * Yes : bits[1] = Shading Detected, 0 = No, 1 = Yes : bits[1] = VBus Limit
 * Detected, 0 = No, 1 = Yes : bits[1] = Ipv Fast Limit, 0 = No, 1 = Yes :
 * bits[1] = reserved 7, 0 = No, 1 = Yes : bits[1] = reserved 8, 0 = No, 1 = Yes
 * : bits[1] = reserved 9, 0 = No, 1 = Yes : bits[1] = reserved 10, 0 = No, 1 =
 * Yes : bits[1] = reserved 11, 0 = No, 1 = Yes : bits[1] = reserved 12, 0 = No,
 * 1 = Yes : bits[1] = reserved 13, 0 = No, 1 = Yes : bits[1] = reserved 14, 0 =
 * No, 1 = Yes : bits[1] = reserved 15, 0 = No, 1 = Yes}
 */
#define VE_REG_MULTIC_MPPT2_ERR 0xD463

/** MultiC MPPT duty cycle (tracker 2) (internal) {un16 = data} */
#define VE_REG_MULTIC_MPPT2_DUTY 0xD464

/**
 * MultiC MPPT input power (tracker 2) (internal) {un32 = Power [0.001W],
 * 0xFFFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT2_POWER 0xD465

/**
 * MultiC MPPT DC bus power (tracker 2) (internal) {sn32 = Power [0.001W],
 * 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT2_DC_BUS_POWER 0xD466

/** MultiC MPPT panel-current zero bias level (tracker 2) (internal) {un16 = data} */
#define VE_REG_MULTIC_MPPT2_IPV_ZERO 0xD467

/** MultiC MPPT tracker step size (tracker 2) (internal) {un16 = data} */
#define VE_REG_MULTIC_MPPT2_STEPS 0xD468

/** MultiC MPPT minimum duty cycle (tracker 2) (internal) {un16 = data} */
#define VE_REG_MULTIC_MPPT2_DUTY_MIN 0xD469

/** MultiC MPPT maximum duty cycle (tracker 2) (internal) {un16 = data} */
#define VE_REG_MULTIC_MPPT2_MPP_DUTY 0xD46A

/**
 * MultiC MPPT peak input power (tracker 2) (internal) {un32 = Power [0.001W],
 * 0xFFFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT2_MPP_POWER 0xD46B

/**
 * MultiC MPPT peak panel voltage (tracker 2) (internal) {un32 = Voltage
 * [0.001V], 0xFFFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT2_MPP_VOLTAGE 0xD46C

/**
 * MultiC MPPT open-circuit panel voltage (tracker 2) (internal) {un32 = Voltage
 * [0.001V], 0xFFFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT2_OC_VOLTAGE 0xD46D

/** MultiC MPPT tracker maximum step size (tracker 2) (internal) {un16 = data} */
#define VE_REG_MULTIC_MPPT2_MAX_STEPSIZE 0xD46E

/** MultiC MPPT tracker minimum step size (tracker 2) (internal) {un16 = data} */
#define VE_REG_MULTIC_MPPT2_MIN_STEPSIZE 0xD46F

/**
 * MultiC MPPT panel voltage (tracker 2) (internal) {sn32 = Voltage [0.001V],
 * 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT2_VPV 0xD470

/**
 * MultiC MPPT panel current (tracker 2) (internal) {sn32 = Current [0.001A],
 * 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT2_IPV 0xD471

/**
 * MultiC energy harvest (tracker 2) (internal) {un32 = Energy [0.001kWh],
 * 0xFFFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT2_YIELD 0xD472

/**
 * MultiC MPPT input power limit (tracker 2) (internal) {un32 = Power [0.001W],
 * 0xFFFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT2_POWER_LIMIT 0xD473

/** MultiC MPPT state (tracker 3) (internal) {un16 = state (see xml for meanings)} */
#define VE_REG_MULTIC_MPPT3_STATE 0xD480

/**
 * MultiC MPPT options (bitmask, tracker 3) (internal) {bits[1] = Enable MPPT, 0
 * = No, 1 = Yes : bits[1] = Allow Start, 0 = No, 1 = Yes : bits[1] = reserved 2,
 * 0 = No, 1 = Yes : bits[1] = reserved 3, 0 = No, 1 = Yes : bits[1] = reserved
 * 4, 0 = No, 1 = Yes : bits[1] = reserved 5, 0 = No, 1 = Yes : bits[1] =
 * reserved 6, 0 = No, 1 = Yes : bits[1] = reserved 7, 0 = No, 1 = Yes : bits[1]
 * = reserved 8, 0 = No, 1 = Yes : bits[1] = reserved 9, 0 = No, 1 = Yes :
 * bits[1] = reserved 10, 0 = No, 1 = Yes : bits[1] = reserved 11, 0 = No, 1 =
 * Yes : bits[1] = reserved 12, 0 = No, 1 = Yes : bits[1] = reserved 13, 0 = No,
 * 1 = Yes : bits[1] = reserved 14, 0 = No, 1 = Yes : bits[1] = reserved 15, 0 =
 * No, 1 = Yes}
 */
#define VE_REG_MULTIC_MPPT3_OPT 0xD481

/**
 * MultiC MPPT flags (bitmask, tracker 3) (internal) {bits[1] = MPPTActive, 0 =
 * No, 1 = Yes : bits[1] = MPPTDirection, 0 = No, 1 = Yes : bits[1] = PVShort
 * Active, 0 = No, 1 = Yes : bits[1] = Day Detection, 0 = No, 1 = Yes : bits[1] =
 * PIControl, 0 = No, 1 = Yes : bits[1] = MPPTControl, 0 = No, 1 = Yes : bits[1]
 * = High Panel Voltage, 0 = No, 1 = Yes : bits[1] = Converter Mode, 0 = No, 1 =
 * Yes : bits[1] = Atk Failure, 0 = No, 1 = Yes : bits[1] = reserved 9, 0 = No, 1
 * = Yes : bits[1] = reserved 10, 0 = No, 1 = Yes : bits[1] = reserved 11, 0 =
 * No, 1 = Yes : bits[1] = reserved 12, 0 = No, 1 = Yes : bits[1] = reserved 13,
 * 0 = No, 1 = Yes : bits[1] = reserved 14, 0 = No, 1 = Yes : bits[1] = reserved
 * 15, 0 = No, 1 = Yes}
 */
#define VE_REG_MULTIC_MPPT3_FLAGS 0xD482

/**
 * MultiC MPPT errors (bitmask, tracker 3) (internal) {bits[1] = Tracking Lost, 0
 * = No, 1 = Yes : bits[1] = Power Max Detected, 0 = No, 1 = Yes : bits[1] = Vpv
 * Limit Detected, 0 = No, 1 = Yes : bits[1] = Ipv Limit Detected, 0 = No, 1 =
 * Yes : bits[1] = Shading Detected, 0 = No, 1 = Yes : bits[1] = VBus Limit
 * Detected, 0 = No, 1 = Yes : bits[1] = Ipv Fast Limit, 0 = No, 1 = Yes :
 * bits[1] = reserved 7, 0 = No, 1 = Yes : bits[1] = reserved 8, 0 = No, 1 = Yes
 * : bits[1] = reserved 9, 0 = No, 1 = Yes : bits[1] = reserved 10, 0 = No, 1 =
 * Yes : bits[1] = reserved 11, 0 = No, 1 = Yes : bits[1] = reserved 12, 0 = No,
 * 1 = Yes : bits[1] = reserved 13, 0 = No, 1 = Yes : bits[1] = reserved 14, 0 =
 * No, 1 = Yes : bits[1] = reserved 15, 0 = No, 1 = Yes}
 */
#define VE_REG_MULTIC_MPPT3_ERR 0xD483

/** MultiC MPPT duty cycle (tracker 3) (internal) {un16 = data} */
#define VE_REG_MULTIC_MPPT3_DUTY 0xD484

/**
 * MultiC MPPT input power (tracker 3) (internal) {un32 = Power [0.001W],
 * 0xFFFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT3_POWER 0xD485

/**
 * MultiC MPPT DC bus power (tracker 3) (internal) {sn32 = Power [0.001W],
 * 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT3_DC_BUS_POWER 0xD486

/** MultiC MPPT panel-current zero bias level (tracker 3) (internal) {un16 = data} */
#define VE_REG_MULTIC_MPPT3_IPV_ZERO 0xD487

/** MultiC MPPT tracker step size (tracker 3) (internal) {un16 = data} */
#define VE_REG_MULTIC_MPPT3_STEPS 0xD488

/** MultiC MPPT minimum duty cycle (tracker 3) (internal) {un16 = data} */
#define VE_REG_MULTIC_MPPT3_DUTY_MIN 0xD489

/** MultiC MPPT maximum duty cycle (tracker 3) (internal) {un16 = data} */
#define VE_REG_MULTIC_MPPT3_MPP_DUTY 0xD48A

/**
 * MultiC MPPT peak input power (tracker 3) (internal) {un32 = Power [0.001W],
 * 0xFFFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT3_MPP_POWER 0xD48B

/**
 * MultiC MPPT peak panel voltage (tracker 3) (internal) {un32 = Voltage
 * [0.001V], 0xFFFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT3_MPP_VOLTAGE 0xD48C

/**
 * MultiC MPPT open-circuit panel voltage (tracker 3) (internal) {un32 = Voltage
 * [0.001V], 0xFFFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT3_OC_VOLTAGE 0xD48D

/** MultiC MPPT tracker maximum step size (tracker 3) (internal) {un16 = data} */
#define VE_REG_MULTIC_MPPT3_MAX_STEPSIZE 0xD48E

/** MultiC MPPT tracker minimum step size (tracker 3) (internal) {un16 = data} */
#define VE_REG_MULTIC_MPPT3_MIN_STEPSIZE 0xD48F

/**
 * MultiC MPPT panel voltage (tracker 3) (internal) {sn32 = Voltage [0.001V],
 * 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT3_VPV 0xD490

/**
 * MultiC MPPT panel current (tracker 3) (internal) {sn32 = Current [0.001A],
 * 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT3_IPV 0xD491

/**
 * MultiC energy harvest (tracker 3) (internal) {un32 = Energy [0.001kWh],
 * 0xFFFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT3_YIELD 0xD492

/**
 * MultiC MPPT input power limit (tracker 3) (internal) {un32 = Power [0.001W],
 * 0xFFFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT3_POWER_LIMIT 0xD493

/** MultiC MPPT state (tracker 4) (internal) {un16 = state (see xml for meanings)} */
#define VE_REG_MULTIC_MPPT4_STATE 0xD4A0

/**
 * MultiC MPPT options (bitmask, tracker 4) (internal) {bits[1] = Enable MPPT, 0
 * = No, 1 = Yes : bits[1] = Allow Start, 0 = No, 1 = Yes : bits[1] = reserved 2,
 * 0 = No, 1 = Yes : bits[1] = reserved 3, 0 = No, 1 = Yes : bits[1] = reserved
 * 4, 0 = No, 1 = Yes : bits[1] = reserved 5, 0 = No, 1 = Yes : bits[1] =
 * reserved 6, 0 = No, 1 = Yes : bits[1] = reserved 7, 0 = No, 1 = Yes : bits[1]
 * = reserved 8, 0 = No, 1 = Yes : bits[1] = reserved 9, 0 = No, 1 = Yes :
 * bits[1] = reserved 10, 0 = No, 1 = Yes : bits[1] = reserved 11, 0 = No, 1 =
 * Yes : bits[1] = reserved 12, 0 = No, 1 = Yes : bits[1] = reserved 13, 0 = No,
 * 1 = Yes : bits[1] = reserved 14, 0 = No, 1 = Yes : bits[1] = reserved 15, 0 =
 * No, 1 = Yes}
 */
#define VE_REG_MULTIC_MPPT4_OPT 0xD4A1

/**
 * MultiC MPPT flags (bitmask, tracker 4) (internal) {bits[1] = MPPTActive, 0 =
 * No, 1 = Yes : bits[1] = MPPTDirection, 0 = No, 1 = Yes : bits[1] = PVShort
 * Active, 0 = No, 1 = Yes : bits[1] = Day Detection, 0 = No, 1 = Yes : bits[1] =
 * PIControl, 0 = No, 1 = Yes : bits[1] = MPPTControl, 0 = No, 1 = Yes : bits[1]
 * = High Panel Voltage, 0 = No, 1 = Yes : bits[1] = Converter Mode, 0 = No, 1 =
 * Yes : bits[1] = Atk Failure, 0 = No, 1 = Yes : bits[1] = reserved 9, 0 = No, 1
 * = Yes : bits[1] = reserved 10, 0 = No, 1 = Yes : bits[1] = reserved 11, 0 =
 * No, 1 = Yes : bits[1] = reserved 12, 0 = No, 1 = Yes : bits[1] = reserved 13,
 * 0 = No, 1 = Yes : bits[1] = reserved 14, 0 = No, 1 = Yes : bits[1] = reserved
 * 15, 0 = No, 1 = Yes}
 */
#define VE_REG_MULTIC_MPPT4_FLAGS 0xD4A2

/**
 * MultiC MPPT errors (bitmask, tracker 4) (internal) {bits[1] = Tracking Lost, 0
 * = No, 1 = Yes : bits[1] = Power Max Detected, 0 = No, 1 = Yes : bits[1] = Vpv
 * Limit Detected, 0 = No, 1 = Yes : bits[1] = Ipv Limit Detected, 0 = No, 1 =
 * Yes : bits[1] = Shading Detected, 0 = No, 1 = Yes : bits[1] = VBus Limit
 * Detected, 0 = No, 1 = Yes : bits[1] = Ipv Fast Limit, 0 = No, 1 = Yes :
 * bits[1] = reserved 7, 0 = No, 1 = Yes : bits[1] = reserved 8, 0 = No, 1 = Yes
 * : bits[1] = reserved 9, 0 = No, 1 = Yes : bits[1] = reserved 10, 0 = No, 1 =
 * Yes : bits[1] = reserved 11, 0 = No, 1 = Yes : bits[1] = reserved 12, 0 = No,
 * 1 = Yes : bits[1] = reserved 13, 0 = No, 1 = Yes : bits[1] = reserved 14, 0 =
 * No, 1 = Yes : bits[1] = reserved 15, 0 = No, 1 = Yes}
 */
#define VE_REG_MULTIC_MPPT4_ERR 0xD4A3

/** MultiC MPPT duty cycle (tracker 4) (internal) {un16 = data} */
#define VE_REG_MULTIC_MPPT4_DUTY 0xD4A4

/**
 * MultiC MPPT input power (tracker 4) (internal) {un32 = Power [0.001W],
 * 0xFFFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT4_POWER 0xD4A5

/**
 * MultiC MPPT DC bus power (tracker 4) (internal) {sn32 = Power [0.001W],
 * 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT4_DC_BUS_POWER 0xD4A6

/** MultiC MPPT panel-current zero bias level (tracker 4) (internal) {un16 = data} */
#define VE_REG_MULTIC_MPPT4_IPV_ZERO 0xD4A7

/** MultiC MPPT tracker step size (tracker 4) (internal) {un16 = data} */
#define VE_REG_MULTIC_MPPT4_STEPS 0xD4A8

/** MultiC MPPT minimum duty cycle (tracker 4) (internal) {un16 = data} */
#define VE_REG_MULTIC_MPPT4_DUTY_MIN 0xD4A9

/** MultiC MPPT maximum duty cycle (tracker 4) (internal) {un16 = data} */
#define VE_REG_MULTIC_MPPT4_MPP_DUTY 0xD4AA

/**
 * MultiC MPPT peak input power (tracker 4) (internal) {un32 = Power [0.001W],
 * 0xFFFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT4_MPP_POWER 0xD4AB

/**
 * MultiC MPPT peak panel voltage (tracker 4) (internal) {un32 = Voltage
 * [0.001V], 0xFFFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT4_MPP_VOLTAGE 0xD4AC

/**
 * MultiC MPPT open-circuit panel voltage (tracker 4) (internal) {un32 = Voltage
 * [0.001V], 0xFFFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT4_OC_VOLTAGE 0xD4AD

/** MultiC MPPT tracker maximum step size (tracker 4) (internal) {un16 = data} */
#define VE_REG_MULTIC_MPPT4_MAX_STEPSIZE 0xD4AE

/** MultiC MPPT tracker minimum step size (tracker 4) (internal) {un16 = data} */
#define VE_REG_MULTIC_MPPT4_MIN_STEPSIZE 0xD4AF

/**
 * MultiC MPPT panel voltage (tracker 4) (internal) {sn32 = Voltage [0.001V],
 * 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT4_VPV 0xD4B0

/**
 * MultiC MPPT panel current (tracker 4) (internal) {sn32 = Current [0.001A],
 * 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT4_IPV 0xD4B1

/**
 * MultiC energy harvest (tracker 4) (internal) {un32 = Energy [0.001kWh],
 * 0xFFFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT4_YIELD 0xD4B2

/**
 * MultiC MPPT input power limit (tracker 4) (internal) {un32 = Power [0.001W],
 * 0xFFFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT4_POWER_LIMIT 0xD4B3

/**
 * MultiC MPPT auto-adjust parameters (internal) {un8 = data, 0x00 = Manual, 0x01
 * = Auto}
 */
#define VE_REG_MULTIC_MPPT_AUTO 0xD4C0

/**
 * MultiC MPPT low panel voltage - start level (internal) {un32 = Voltage
 * [0.001V], 0xFFFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT_VPV_LOW_START 0xD4C1

/**
 * MultiC MPPT low panel voltage - stop level (internal) {un32 = Voltage
 * [0.001V], 0xFFFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT_VPV_LOW_STOP 0xD4C2

/**
 * MultiC MPPT panel voltage - tracking lost (internal) {un32 = Voltage [0.001V],
 * 0xFFFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT_VPV_TRACK_LOST 0xD4C3

/** MultiC MPPT minimum step size (internal) {un16 = data} */
#define VE_REG_MULTIC_MPPT_STEP_MIN 0xD4C4

/** MultiC MPPT maximum step size (internal) {un16 = data} */
#define VE_REG_MULTIC_MPPT_STEP_MAX 0xD4C5

/**
 * MultiC MPPT tracker power window (internal) {un32 = Power [0.001W], 0xFFFFFFFF
 * = Not Available}
 */
#define VE_REG_MULTIC_MPPT_TRACKER_POWER_WINDOW 0xD4C6

/** MultiC MPPT tracker update rate (internal) {un16 = data} */
#define VE_REG_MULTIC_MPPT_RATE 0xD4C7

/**
 * MultiC MPPT maximum panel current (internal) {un32 = Current [0.001A],
 * 0xFFFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT_IPV_MAX 0xD4C8

/**
 * MultiC MPPT panel current fast shutdown (internal) {un32 = Current [0.001A],
 * 0xFFFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT_IPV_LIMIT 0xD4C9

/**
 * MultiC MPPT power limit - high temperature dim level (internal) {un32 = Power
 * [0.001W], 0xFFFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT_POWER_MIN 0xD4CA

/**
 * MultiC MPPT power limit - maximum power level (internal) {un32 = Power
 * [0.001W], 0xFFFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT_POWER_MAX 0xD4CB

/**
 * MultiC MPPT low temperature limit - uses maximum power limit (internal) {sn32
 * = Temperature [0.001°C], 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT_TEMP_LOW 0xD4CC

/**
 * MultiC MPPT high temperature limit - uses high temperature dim level
 * (internal) {sn32 = Temperature [0.001°C], 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT_TEMP_HIGH 0xD4CD

/** MultiC MPPT PI control Kp parameter (continuous mode) (internal) {un16 = data} */
#define VE_REG_MULTIC_MPPT_CTRL_KP_CONT 0xD4CE

/** MultiC MPPT PI control Ki parameter (continuous mode) (internal) {un16 = data} */
#define VE_REG_MULTIC_MPPT_CTRL_KI_CONT 0xD4CF

/**
 * MultiC MPPT DC bus voltage control MPP tracker activation time (internal)
 * {un16 = Time [0.001s], 0xFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT_VBUS_TIME 0xD4D0

/** MultiC MPPT DC bus voltage control gain parameter (internal) {un16 = data} */
#define VE_REG_MULTIC_MPPT_VBUS_GAIN 0xD4D1

/** MultiC MPPT panel power control gain parameter (internal) {un16 = data} */
#define VE_REG_MULTIC_MPPT_PPV_GAIN 0xD4D2

/** MultiC MPPT panel current control gain parameter (internal) {un16 = data} */
#define VE_REG_MULTIC_MPPT_IPV_GAIN 0xD4D3

/**
 * MultiC MPPT panel voltage maximum (internal) {un32 = Voltage [0.001V],
 * 0xFFFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT_VPV_MAX 0xD4D4

/**
 * MultiC MPPT PI control Kp parameter (discontinuous mode) (internal) {un16 =
 * data}
 */
#define VE_REG_MULTIC_MPPT_CTRL_KP_DISC 0xD4D5

/**
 * MultiC MPPT PI control Ki parameter (discontinuous mode) (internal) {un16 =
 * data}
 */
#define VE_REG_MULTIC_MPPT_CTRL_KI_DISC 0xD4D6

/**
 * MultiC MPPT panel current release pv short protection (internal) {un32 =
 * Current [0.001A], 0xFFFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT_PV_SHORT_RELEASE 0xD4D9

/**
 * MultiC MPPT temperature shutdown (internal) {sn32 = Temperature [0.001°C],
 * 0x7FFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_MPPT_TEMP_SHUTDOWN 0xD4DA

/** MultiC GFCI DC BIAS (internal) {un16 = bias} */
#define VE_REG_MULTIC_MPPT_GFCI_DC_BIAS 0xD4DB

/**
 * Battery chemistry 0: Shutdown On Low Voltage (internal) {un16 = Battery
 * chemistry 0: Shutdown On Low Voltage [0.01V]}
 */
#define VE_REG_BAT0_SHUTDOWN_LOW_VOLTAGE_SET 0xD501

/**
 * Battery chemistry 0: Low voltage lower threshold (internal) {un16 = Battery
 * chemistry 0: Low voltage lower threshold [0.01V]}
 */
#define VE_REG_BAT0_ALARM_LOW_VOLTAGE_SET 0xD502

/**
 * Battery chemistry 0: Low voltage upper threshold (internal) {un16 = Battery
 * chemistry 0: Low voltage upper threshold [0.01V]}
 */
#define VE_REG_BAT0_ALARM_LOW_VOLTAGE_CLEAR 0xD503

/**
 * Battery chemistry 0: Remote input connector operation mode (internal) {un8 =
 * data, 0 = Remote on/off, 1 = Mini-BMS}
 */
#define VE_REG_BAT0_MULTIC_REMOTE_MODE 0xD504

/**
 * Battery chemistry 0: pv inverter presense detection time (internal) {un32 =
 * Time [1s], 0xFFFFFFFF = Not Available}
 */
#define VE_REG_BAT0_MULTIC_PV_INVERTER_DETECT_TIME 0xD505

/**
 * Battery chemistry 0: pv inverter ac frequency control Kp parameter (internal)
 * {un16 = data}
 */
#define VE_REG_BAT0_MULTIC_PV_INVERTER_FREQ_KP 0xD506

/**
 * Battery chemistry 0: pv inverter ac frequency control Ki parameter (internal)
 * {un16 = data}
 */
#define VE_REG_BAT0_MULTIC_PV_INVERTER_FREQ_KI 0xD507

/**
 * Battery chemistry 0: pv inverter ac frequency control gain for battery current
 * (internal) {un16 = data}
 */
#define VE_REG_BAT0_MULTIC_PV_INVERTER_IBAT_GAIN 0xD508

/**
 * Battery chemistry 0: pv inverter re-bulk voltage (internal) {un16 = Voltage
 * [0.01V], 0xFFFF = Not Available}
 */
#define VE_REG_BAT0_MULTIC_PV_INVERTER_RE_BULK_VOLTAGE 0xD509

/**
 * Battery chemistry 0: inverter dynamic-cutoff Factor 5 (mV) (internal) {un16 =
 * Voltage [0.001V], 0xFFFF = Not Available}
 */
#define VE_REG_BAT0_DYN_CUTOFF_FACTOR5 0xD50A

/**
 * Battery chemistry 0: inverter dynamic-cutoff Factor 250 (mV) (internal) {un16
 * = Voltage [0.001V], 0xFFFF = Not Available}
 */
#define VE_REG_BAT0_DYN_CUTOFF_FACTOR250 0xD50B

/**
 * Battery chemistry 0: inverter dynamic-cutoff Factor 700 (mV) (internal) {un16
 * = Voltage [0.001V], 0xFFFF = Not Available}
 */
#define VE_REG_BAT0_DYN_CUTOFF_FACTOR700 0xD50C

/**
 * Battery chemistry 0: inverter dynamic-cutoff Factor 2000 (mV) (internal) {un16
 * = Voltage [0.001V], 0xFFFF = Not Available}
 */
#define VE_REG_BAT0_DYN_CUTOFF_FACTOR2000 0xD50D

/**
 * Battery chemistry 1: Shutdown On Low Voltage (internal) {un16 = Battery
 * chemistry 1: Shutdown On Low Voltage [0.01V]}
 */
#define VE_REG_BAT1_SHUTDOWN_LOW_VOLTAGE_SET 0xD521

/**
 * Battery chemistry 1: Low voltage lower threshold (internal) {un16 = Battery
 * chemistry 1: Low voltage lower threshold [0.01V]}
 */
#define VE_REG_BAT1_ALARM_LOW_VOLTAGE_SET 0xD522

/**
 * Battery chemistry 1: Low voltage upper threshold (internal) {un16 = Battery
 * chemistry 1: Low voltage upper threshold [0.01V]}
 */
#define VE_REG_BAT1_ALARM_LOW_VOLTAGE_CLEAR 0xD523

/**
 * Battery chemistry 1: Remote input connector operation mode (internal) {un8 =
 * data, 0 = Remote on/off, 1 = Mini-BMS}
 */
#define VE_REG_BAT1_MULTIC_REMOTE_MODE 0xD524

/**
 * Battery chemistry 1: pv inverter presense detection time (internal) {un32 =
 * Time [1s], 0xFFFFFFFF = Not Available}
 */
#define VE_REG_BAT1_MULTIC_PV_INVERTER_DETECT_TIME 0xD525

/**
 * Battery chemistry 1: pv inverter ac frequency control Kp parameter (internal)
 * {un16 = data}
 */
#define VE_REG_BAT1_MULTIC_PV_INVERTER_FREQ_KP 0xD526

/**
 * Battery chemistry 1: pv inverter ac frequency control Ki parameter (internal)
 * {un16 = data}
 */
#define VE_REG_BAT1_MULTIC_PV_INVERTER_FREQ_KI 0xD527

/**
 * Battery chemistry 1: pv inverter ac frequency control gain for battery current
 * (internal) {un16 = data}
 */
#define VE_REG_BAT1_MULTIC_PV_INVERTER_IBAT_GAIN 0xD528

/**
 * Battery chemistry 1: pv inverter re-bulk voltage (internal) {un16 = Voltage
 * [0.01V], 0xFFFF = Not Available}
 */
#define VE_REG_BAT1_MULTIC_PV_INVERTER_RE_BULK_VOLTAGE 0xD529

/**
 * Battery chemistry 1: inverter dynamic-cutoff Factor 5 (mV) (internal) {un16 =
 * Voltage [0.001V], 0xFFFF = Not Available}
 */
#define VE_REG_BAT1_DYN_CUTOFF_FACTOR5 0xD52A

/**
 * Battery chemistry 1: inverter dynamic-cutoff Factor 250 (mV) (internal) {un16
 * = Voltage [0.001V], 0xFFFF = Not Available}
 */
#define VE_REG_BAT1_DYN_CUTOFF_FACTOR250 0xD52B

/**
 * Battery chemistry 1: inverter dynamic-cutoff Factor 700 (mV) (internal) {un16
 * = Voltage [0.001V], 0xFFFF = Not Available}
 */
#define VE_REG_BAT1_DYN_CUTOFF_FACTOR700 0xD52C

/**
 * Battery chemistry 1: inverter dynamic-cutoff Factor 2000 (mV) (internal) {un16
 * = Voltage [0.001V], 0xFFFF = Not Available}
 */
#define VE_REG_BAT1_DYN_CUTOFF_FACTOR2000 0xD52D

/**
 * Battery chemistry 2: Shutdown On Low Voltage (internal) {un16 = Battery
 * chemistry 2: Shutdown On Low Voltage [0.01V]}
 */
#define VE_REG_BAT2_SHUTDOWN_LOW_VOLTAGE_SET 0xD541

/**
 * Battery chemistry 2: Low voltage lower threshold (internal) {un16 = Battery
 * chemistry 2: Low voltage lower threshold [0.01V]}
 */
#define VE_REG_BAT2_ALARM_LOW_VOLTAGE_SET 0xD542

/**
 * Battery chemistry 2: Low voltage upper threshold (internal) {un16 = Battery
 * chemistry 2: Low voltage upper threshold [0.01V]}
 */
#define VE_REG_BAT2_ALARM_LOW_VOLTAGE_CLEAR 0xD543

/**
 * Battery chemistry 2: Remote input connector operation mode (internal) {un8 =
 * data, 0 = Remote on/off, 1 = Mini-BMS}
 */
#define VE_REG_BAT2_MULTIC_REMOTE_MODE 0xD544

/**
 * Battery chemistry 2: pv inverter presense detection time (internal) {un32 =
 * Time [1s], 0xFFFFFFFF = Not Available}
 */
#define VE_REG_BAT2_MULTIC_PV_INVERTER_DETECT_TIME 0xD545

/**
 * Battery chemistry 2: pv inverter ac frequency control Kp parameter (internal)
 * {un16 = data}
 */
#define VE_REG_BAT2_MULTIC_PV_INVERTER_FREQ_KP 0xD546

/**
 * Battery chemistry 2: pv inverter ac frequency control Ki parameter (internal)
 * {un16 = data}
 */
#define VE_REG_BAT2_MULTIC_PV_INVERTER_FREQ_KI 0xD547

/**
 * Battery chemistry 2: pv inverter ac frequency control gain for battery current
 * (internal) {un16 = data}
 */
#define VE_REG_BAT2_MULTIC_PV_INVERTER_IBAT_GAIN 0xD548

/**
 * Battery chemistry 2: pv inverter re-bulk voltage (internal) {un16 = Voltage
 * [0.01V], 0xFFFF = Not Available}
 */
#define VE_REG_BAT2_MULTIC_PV_INVERTER_RE_BULK_VOLTAGE 0xD549

/**
 * Battery chemistry 2: inverter dynamic-cutoff Factor 5 (mV) (internal) {un16 =
 * Voltage [0.001V], 0xFFFF = Not Available}
 */
#define VE_REG_BAT2_DYN_CUTOFF_FACTOR5 0xD54A

/**
 * Battery chemistry 2: inverter dynamic-cutoff Factor 250 (mV) (internal) {un16
 * = Voltage [0.001V], 0xFFFF = Not Available}
 */
#define VE_REG_BAT2_DYN_CUTOFF_FACTOR250 0xD54B

/**
 * Battery chemistry 2: inverter dynamic-cutoff Factor 700 (mV) (internal) {un16
 * = Voltage [0.001V], 0xFFFF = Not Available}
 */
#define VE_REG_BAT2_DYN_CUTOFF_FACTOR700 0xD54C

/**
 * Battery chemistry 2: inverter dynamic-cutoff Factor 2000 (mV) (internal) {un16
 * = Voltage [0.001V], 0xFFFF = Not Available}
 */
#define VE_REG_BAT2_DYN_CUTOFF_FACTOR2000 0xD54D

/**
 * (internal) {un32 = Energy from Inverter to AC-Out [0.01kWh], 0xFFFFFFFF = Not
 * Available}
 */
#define VE_REG_MULTIC_ENERGY_FROM_INVERTER_TO_ACOUT 0xD5C8

/**
 * MultiC TFS Calibration Metrics: instance 1 number of bytes used (internal)
 * {un32 = bytes}
 */
#define VE_REG_MULTIC_TFS_CALIBRATION_USED_1 0xD710

/**
 * MultiC TFS Calibration Metrics: instance 1 saved with firmware version
 * (internal) {un8 = Identifier : un24 = Firmware Version}
 */
#define VE_REG_MULTIC_TFS_CALIBRATION_SAVED_FW_1 0xD711

/**
 * MultiC TFS Calibration Metrics: instance 1 number of times saved (internal)
 * {un32 = count}
 */
#define VE_REG_MULTIC_TFS_CALIBRATION_SAVE_CNT_1 0xD712

/**
 * MultiC TFS Settings Metrics: instance 1 number of bytes used (internal) {un32
 * = bytes}
 */
#define VE_REG_MULTIC_TFS_SETTINGS_USED_1 0xD713

/**
 * MultiC TFS Settings Metrics: instance 1 saved with firmware version (internal)
 * {un8 = Identifier : un24 = Firmware Version}
 */
#define VE_REG_MULTIC_TFS_SETTINGS_SAVED_FW_1 0xD714

/**
 * MultiC TFS Settings Metrics: instance 1 number of times saved (internal) {un32
 * = count}
 */
#define VE_REG_MULTIC_TFS_SETTINGS_SAVE_CNT_1 0xD715

/**
 * MultiC TFS Extra Metrics: instance 1 number of bytes used (internal) {un32 =
 * bytes}
 */
#define VE_REG_MULTIC_TFS_EXTRA_USED_1 0xD716

/**
 * MultiC TFS Extra Metrics: instance 1 saved with firmware version (internal)
 * {un8 = Identifier : un24 = Firmware Version}
 */
#define VE_REG_MULTIC_TFS_EXTRA_SAVED_FW_1 0xD717

/**
 * MultiC TFS Extra Metrics: instance 1 number of times saved (internal) {un32 =
 * count}
 */
#define VE_REG_MULTIC_TFS_EXTRA_SAVE_CNT_1 0xD718

/**
 * MultiC TFS Calibration Metrics: instance 1 init result (internal) {un32 =
 * result}
 */
#define VE_REG_MULTIC_TFS_CALIBRATION_INIT_RESULT_1 0xD719

/** MultiC TFS Setting Metrics: instance 1 init result (internal) {un32 = result} */
#define VE_REG_MULTIC_TFS_SETTINGS_INIT_RESULT_1 0xD71A

/** MultiC TFS Extra Metrics: instance 1 init result (internal) {un32 = result} */
#define VE_REG_MULTIC_TFS_EXTRA_INIT_RESULT_1 0xD71B

/**
 * MultiC TFS Calibration Metrics: instance 3 init result (internal) {un32 =
 * result}
 */
#define VE_REG_MULTIC_TFS_CALIBRATION_INIT_RESULT_3 0xD739

/** MultiC TFS Setting Metrics: instance 3 init result (internal) {un32 = result} */
#define VE_REG_MULTIC_TFS_SETTINGS_INIT_RESULT_3 0xD73A

/**
 * MultiC TFS Calibration Metrics: instance 4 init result (internal) {un32 =
 * result}
 */
#define VE_REG_MULTIC_TFS_CALIBRATION_INIT_RESULT_4 0xD749

/** MultiC TFS Setting Metrics: instance 4 init result (internal) {un32 = result} */
#define VE_REG_MULTIC_TFS_SETTINGS_INIT_RESULT_4 0xD74A

/**
 * MultiC TFS Calibration Metrics: instance 3 number of bytes used (internal)
 * {un32 = bytes}
 */
#define VE_REG_MULTIC_TFS_CALIBRATION_USED_3 0xD730

/**
 * MultiC TFS Calibration Metrics: instance 3 saved with firmware version
 * (internal) {un8 = Identifier : un24 = Firmware Version}
 */
#define VE_REG_MULTIC_TFS_CALIBRATION_SAVED_FW_3 0xD731

/**
 * MultiC TFS Calibration Metrics: instance 3 number of times saved (internal)
 * {un32 = count}
 */
#define VE_REG_MULTIC_TFS_CALIBRATION_SAVE_CNT_3 0xD732

/**
 * MultiC TFS Settings Metrics: instance 3 number of bytes used (internal) {un32
 * = bytes}
 */
#define VE_REG_MULTIC_TFS_SETTINGS_USED_3 0xD733

/**
 * MultiC TFS Settings Metrics: instance 3 saved with firmware version (internal)
 * {un8 = Identifier : un24 = Firmware Version}
 */
#define VE_REG_MULTIC_TFS_SETTINGS_SAVED_FW_3 0xD734

/**
 * MultiC TFS Settings Metrics: instance 3 number of times saved (internal) {un32
 * = count}
 */
#define VE_REG_MULTIC_TFS_SETTINGS_SAVE_CNT_3 0xD735

/**
 * MultiC TFS Calibration Metrics: instance 4 number of bytes used (internal)
 * {un32 = bytes}
 */
#define VE_REG_MULTIC_TFS_CALIBRATION_USED_4 0xD740

/**
 * MultiC TFS Calibration Metrics: instance 4 saved with firmware version
 * (internal) {un8 = Identifier : un24 = Firmware Version}
 */
#define VE_REG_MULTIC_TFS_CALIBRATION_SAVED_FW_4 0xD741

/**
 * MultiC TFS Calibration Metrics: instance 4 number of times saved (internal)
 * {un32 = count}
 */
#define VE_REG_MULTIC_TFS_CALIBRATION_SAVE_CNT_4 0xD742

/**
 * MultiC TFS Settings Metrics: instance 4 number of bytes used (internal) {un32
 * = bytes}
 */
#define VE_REG_MULTIC_TFS_SETTINGS_USED_4 0xD743

/**
 * MultiC TFS Settings Metrics: instance 4 saved with firmware version (internal)
 * {un8 = Identifier : un24 = Firmware Version}
 */
#define VE_REG_MULTIC_TFS_SETTINGS_SAVED_FW_4 0xD744

/**
 * MultiC TFS Settings Metrics: instance 4 number of times saved (internal) {un32
 * = count}
 */
#define VE_REG_MULTIC_TFS_SETTINGS_SAVE_CNT_4 0xD745

/** MultiC DCDC tester control (internal) {un8 = data} */
#define VE_REG_MULTIC_TST_DCDC_CMD 0xEE70

/** MultiC MPPT tester control (internal) {un8 = data} */
#define VE_REG_MULTIC_TST_MPPT_CMD 0xEE71

/**
 * Microcontroller reset detection (internal) {un8 = reset flag, 0 = reset value,
 * 1 = written by tester}
 * @remark Tester writes 1 at start of test sequence, at end of test sequence
 * check if flag is still 1.
 */
#define VE_REG_MULTIC_TST_RESET_DETECTION_DCDC 0xEE72

/**
 * Microcontroller reset detection (internal) {un8 = reset flag, 0 = reset value,
 * 1 = written by tester}
 * @remark Tester writes 1 at start of test sequence, at end of test sequence
 * check if flag is still 1.
 */
#define VE_REG_MULTIC_TST_RESET_DETECTION_DCAC 0xEE73

/**
 * Microcontroller reset detection (internal) {un8 = reset flag, 0 = reset value,
 * 1 = written by tester}
 * @remark Tester writes 1 at start of test sequence, at end of test sequence
 * check if flag is still 1.
 */
#define VE_REG_MULTIC_TST_RESET_DETECTION_MPPT 0xEE74

/** (internal) {sn32 = Current [0.001A], 0x7FFFFFFF = Not Available} */
#define VE_REG_MULTIC_TST_MEAS_GET_DCDC_IBAT 0xEE80

/** (internal) {sn32 = Voltage [0.001V], 0x7FFFFFFF = Not Available} */
#define VE_REG_MULTIC_TST_MEAS_GET_DCDC_VBAT 0xEE81

/** (internal) {sn32 = Voltage [0.001V], 0x7FFFFFFF = Not Available} */
#define VE_REG_MULTIC_TST_MEAS_GET_DCDC_VSENSEP 0xEE82

/** (internal) {sn32 = Voltage [0.001V], 0x7FFFFFFF = Not Available} */
#define VE_REG_MULTIC_TST_MEAS_GET_DCDC_VSENSEM 0xEE83

/** (internal) {sn32 = Voltage [0.001V], 0x7FFFFFFF = Not Available} */
#define VE_REG_MULTIC_TST_MEAS_GET_MPPT_VPV1 0xEE84

/** (internal) {sn32 = Current [0.001A], 0x7FFFFFFF = Not Available} */
#define VE_REG_MULTIC_TST_MEAS_GET_MPPT_IPV1 0xEE85

/** (internal) {sn32 = Voltage [0.001V], 0x7FFFFFFF = Not Available} */
#define VE_REG_MULTIC_TST_MEAS_GET_MPPT_VPV2 0xEE86

/** (internal) {sn32 = Current [0.001A], 0x7FFFFFFF = Not Available} */
#define VE_REG_MULTIC_TST_MEAS_GET_MPPT_IPV2 0xEE87

/** (internal) {sn32 = Voltage [0.001V], 0x7FFFFFFF = Not Available} */
#define VE_REG_MULTIC_TST_MEAS_GET_MPPT_VPV3 0xEE88

/** (internal) {sn32 = Current [0.001A], 0x7FFFFFFF = Not Available} */
#define VE_REG_MULTIC_TST_MEAS_GET_MPPT_IPV3 0xEE89

/** (internal) {sn32 = Voltage [0.001V], 0x7FFFFFFF = Not Available} */
#define VE_REG_MULTIC_TST_MEAS_GET_MPPT_VPV4 0xEE8A

/** (internal) {sn32 = Current [0.001A], 0x7FFFFFFF = Not Available} */
#define VE_REG_MULTIC_TST_MEAS_GET_MPPT_IPV4 0xEE8B

/** (internal) {sn32 = Voltage [0.001V], 0x7FFFFFFF = Not Available} */
#define VE_REG_MULTIC_TST_MEAS_GET_MPPT_VBUS 0xEE8C

/** (internal) {sn32 = Voltage [0.001V], 0x7FFFFFFF = Not Available} */
#define VE_REG_MULTIC_TST_MEAS_GET_MPPT_VACIN 0xEE8D

/** (internal) {un16 = data} */
#define VE_REG_MULTIC_TST_CAL_OFFSET_DCDC_VSENSEM 0xEEA3

/** (internal) {un16 = data} */
#define VE_REG_MULTIC_TST_CAL_OFFSET_MPPT_IPV1 0xEEA5

/** (internal) {un16 = data} */
#define VE_REG_MULTIC_TST_CAL_OFFSET_MPPT_IPV2 0xEEA7

/** (internal) {un16 = data} */
#define VE_REG_MULTIC_TST_CAL_OFFSET_MPPT_IPV3 0xEEA9

/** (internal) {un16 = data} */
#define VE_REG_MULTIC_TST_CAL_OFFSET_MPPT_IPV4 0xEEAB

/** (internal) {un32 = data} */
#define VE_REG_MULTIC_TST_CAL_GAIN_DCDC_IBAT 0xEEC0

/** (internal) {un32 = data} */
#define VE_REG_MULTIC_TST_CAL_GAIN_DCDC_VBAT 0xEEC1

/** (internal) {un32 = data} */
#define VE_REG_MULTIC_TST_CAL_GAIN_DCDC_VSENSEP 0xEEC2

/** (internal) {un32 = data} */
#define VE_REG_MULTIC_TST_CAL_GAIN_DCDC_VSENSEM 0xEEC3

/** (internal) {un32 = data} */
#define VE_REG_MULTIC_TST_CAL_GAIN_MPPT_VPV1 0xEEC4

/** (internal) {un32 = data} */
#define VE_REG_MULTIC_TST_CAL_GAIN_MPPT_IPV1 0xEEC5

/** (internal) {un32 = data} */
#define VE_REG_MULTIC_TST_CAL_GAIN_MPPT_VPV2 0xEEC6

/** (internal) {un32 = data} */
#define VE_REG_MULTIC_TST_CAL_GAIN_MPPT_IPV2 0xEEC7

/** (internal) {un32 = data} */
#define VE_REG_MULTIC_TST_CAL_GAIN_MPPT_VPV3 0xEEC8

/** (internal) {un32 = data} */
#define VE_REG_MULTIC_TST_CAL_GAIN_MPPT_IPV3 0xEEC9

/** (internal) {un32 = data} */
#define VE_REG_MULTIC_TST_CAL_GAIN_MPPT_VPV4 0xEECA

/** (internal) {un32 = data} */
#define VE_REG_MULTIC_TST_CAL_GAIN_MPPT_IPV4 0xEECB

/** (internal) {un32 = data} */
#define VE_REG_MULTIC_TST_CAL_GAIN_MPPT_VBUS 0xEECC

/** (internal) {un32 = data} */
#define VE_REG_MULTIC_TST_CAL_GAIN_MPPT_VACIN 0xEECD

/**
 * MultiC Time-of-day (debug) {un16 = Time on [1minutes], 0xFFFF = Not Available
 * : un16 = Time on (-1) [1minutes], 0xFFFF = Not Available : un16 = Time on (-2)
 * [1minutes], 0xFFFF = Not Available : un16 = Time on (-3) [1minutes], 0xFFFF =
 * Not Available : un16 = Time on (-4) [1minutes], 0xFFFF = Not Available : un16
 * = Time on (-5) [1minutes], 0xFFFF = Not Available : un16 = Day sequence number
 * : un16 = Time off [1minutes], 0xFFFF = Not Available : un8 = Cold start flag :
 * un8 = Padding}
 */
#define VE_REG_MULTIC_TOD_DEBUG 0xD02F

/**
 * ACIN Grid Code Password {stringZeroEnded[32] = Model : un8 = padding, 0 =
 * zeropadding}
 */
#define VE_REG_MULTIC_ACIN_GRID_CODE_PASSWORD 0xD03F

/**
 * MultiC fast disconnect limits {un32 = acinVoltageHigh [0.001V], 0xFFFFFFFF =
 * Not Available : un32 = acinVoltageLow [0.001V], 0xFFFFFFFF = Not Available :
 * un16 = acinPeriodLow [1e-06s], 0xFFFF = Not Available : un16 = acinPeriodHigh
 * [1e-06s], 0xFFFF = Not Available : un8 = delayVoltageHighPeriods : un8 =
 * delayVoltageLowPeriods : un8 = delayPeriodHighPeriods : un8 =
 * delayPeriodLowPeriods}
 */
#define VE_REG_MULTIC_ACIN_FAST_DISCONNECT_LIMITS 0xD04F

/**
 * MultiC managed battery (debug) {un32 = batteryVoltage [0.001V], 0xFFFFFFFF =
 * Not Available : sn32 = batteryCurrent [0.001A], 0x7FFFFFFF = Not Available :
 * sn32 = batteryTemperature [0.001°C], 0x7FFFFFFF = Not Available : un32 =
 * chargeVoltageLimit [0.001V], 0xFFFFFFFF = Not Available : un32 =
 * chargeCurrentLimit [0.001A], 0x7FFFFFFF = Not Available : sn32 =
 * dischargeCurrentLimit [0.001A], 0x7FFFFFFF = Not Available : sn32 =
 * dischargeVoltageLimit [0.001V], 0xFFFFFFFF = Not Available : un16 = soc
 * [0.01%], 0xFFFF = Not Available : un8 = dischargeEnable : un8 = chargeEnable :
 * un8 = fullCharge : un8 = forceCharge}
 */
#define VE_REG_MANAGED_BATTERY_DEBUG 0xD1BF

/**
 * MultiC dcdc power (debug) {un32 = lv [0.001W], 0xFFFFFFFF = Not Available :
 * un32 = igbt [0.001W], 0xFFFFFFFF = Not Available : un32 = core [0.001W],
 * 0xFFFFFFFF = Not Available}
 */
#define VE_REG_MULTIC_DCDC_POWER_DEBUG 0xD122

/**
 * MultiC protections 0 (debug) {un16 = restart [1s], 0xFFFF = Not Available :
 * un16 = warn [1s], 0xFFFF = Not Available : un16 = error [1s], 0xFFFF = Not
 * Available : un8 = effective (see xml for meanings) : un8 = count : un8 = warn,
 * 0 = No, 1 = Yes : un8 = error, 0 = No, 1 = Yes}
 */
#define VE_REG_MULTIC_PROTECTIONS_0 0xD140

/**
 * MultiC protections 1 (debug) {un16 = restart [1s], 0xFFFF = Not Available :
 * un16 = warn [1s], 0xFFFF = Not Available : un16 = error [1s], 0xFFFF = Not
 * Available : un8 = effective (see xml for meanings) : un8 = count : un8 = warn,
 * 0 = No, 1 = Yes : un8 = error, 0 = No, 1 = Yes}
 */
#define VE_REG_MULTIC_PROTECTIONS_1 0xD141

/**
 * MultiC protections 2 (debug) {un16 = restart [1s], 0xFFFF = Not Available :
 * un16 = warn [1s], 0xFFFF = Not Available : un16 = error [1s], 0xFFFF = Not
 * Available : un8 = effective (see xml for meanings) : un8 = count : un8 = warn,
 * 0 = No, 1 = Yes : un8 = error, 0 = No, 1 = Yes}
 */
#define VE_REG_MULTIC_PROTECTIONS_2 0xD142

/**
 * MultiC protections 3 (debug) {un16 = restart [1s], 0xFFFF = Not Available :
 * un16 = warn [1s], 0xFFFF = Not Available : un16 = error [1s], 0xFFFF = Not
 * Available : un8 = effective (see xml for meanings) : un8 = count : un8 = warn,
 * 0 = No, 1 = Yes : un8 = error, 0 = No, 1 = Yes}
 */
#define VE_REG_MULTIC_PROTECTIONS_3 0xD143

/**
 * MultiC protections 4 (debug) {un16 = restart [1s], 0xFFFF = Not Available :
 * un16 = warn [1s], 0xFFFF = Not Available : un16 = error [1s], 0xFFFF = Not
 * Available : un8 = effective (see xml for meanings) : un8 = count : un8 = warn,
 * 0 = No, 1 = Yes : un8 = error, 0 = No, 1 = Yes}
 */
#define VE_REG_MULTIC_PROTECTIONS_4 0xD144

/**
 * MultiC protections 5 (debug) {un16 = restart [1s], 0xFFFF = Not Available :
 * un16 = warn [1s], 0xFFFF = Not Available : un16 = error [1s], 0xFFFF = Not
 * Available : un8 = effective (see xml for meanings) : un8 = count : un8 = warn,
 * 0 = No, 1 = Yes : un8 = error, 0 = No, 1 = Yes}
 */
#define VE_REG_MULTIC_PROTECTIONS_5 0xD145

/**
 * MultiC protections 6 (debug) {un16 = restart [1s], 0xFFFF = Not Available :
 * un16 = warn [1s], 0xFFFF = Not Available : un16 = error [1s], 0xFFFF = Not
 * Available : un8 = effective (see xml for meanings) : un8 = count : un8 = warn,
 * 0 = No, 1 = Yes : un8 = error, 0 = No, 1 = Yes}
 */
#define VE_REG_MULTIC_PROTECTIONS_6 0xD146

/**
 * MultiC protections 7 (debug) {un16 = restart [1s], 0xFFFF = Not Available :
 * un16 = warn [1s], 0xFFFF = Not Available : un16 = error [1s], 0xFFFF = Not
 * Available : un8 = effective (see xml for meanings) : un8 = count : un8 = warn,
 * 0 = No, 1 = Yes : un8 = error, 0 = No, 1 = Yes}
 */
#define VE_REG_MULTIC_PROTECTIONS_7 0xD147

/**
 * MultiC protections 8 (debug) {un16 = restart [1s], 0xFFFF = Not Available :
 * un16 = warn [1s], 0xFFFF = Not Available : un16 = error [1s], 0xFFFF = Not
 * Available : un8 = effective (see xml for meanings) : un8 = count : un8 = warn,
 * 0 = No, 1 = Yes : un8 = error, 0 = No, 1 = Yes}
 */
#define VE_REG_MULTIC_PROTECTIONS_8 0xD148

/**
 * MultiC protections 9 (debug) {un16 = restart [1s], 0xFFFF = Not Available :
 * un16 = warn [1s], 0xFFFF = Not Available : un16 = error [1s], 0xFFFF = Not
 * Available : un8 = effective (see xml for meanings) : un8 = count : un8 = warn,
 * 0 = No, 1 = Yes : un8 = error, 0 = No, 1 = Yes}
 */
#define VE_REG_MULTIC_PROTECTIONS_9 0xD149

/**
 * MultiC protections 10 (debug) {un16 = restart [1s], 0xFFFF = Not Available :
 * un16 = warn [1s], 0xFFFF = Not Available : un16 = error [1s], 0xFFFF = Not
 * Available : un8 = effective (see xml for meanings) : un8 = count : un8 = warn,
 * 0 = No, 1 = Yes : un8 = error, 0 = No, 1 = Yes}
 */
#define VE_REG_MULTIC_PROTECTIONS_10 0xD14A

/**
 * MultiC protections 11 (debug) {un16 = restart [1s], 0xFFFF = Not Available :
 * un16 = warn [1s], 0xFFFF = Not Available : un16 = error [1s], 0xFFFF = Not
 * Available : un8 = effective (see xml for meanings) : un8 = count : un8 = warn,
 * 0 = No, 1 = Yes : un8 = error, 0 = No, 1 = Yes}
 */
#define VE_REG_MULTIC_PROTECTIONS_11 0xD14B

/**
 * MultiC protections 12 (debug) {un16 = restart [1s], 0xFFFF = Not Available :
 * un16 = warn [1s], 0xFFFF = Not Available : un16 = error [1s], 0xFFFF = Not
 * Available : un8 = effective (see xml for meanings) : un8 = count : un8 = warn,
 * 0 = No, 1 = Yes : un8 = error, 0 = No, 1 = Yes}
 */
#define VE_REG_MULTIC_PROTECTIONS_12 0xD14C

/**
 * MultiC protections 13 (debug) {un16 = restart [1s], 0xFFFF = Not Available :
 * un16 = warn [1s], 0xFFFF = Not Available : un16 = error [1s], 0xFFFF = Not
 * Available : un8 = effective (see xml for meanings) : un8 = count : un8 = warn,
 * 0 = No, 1 = Yes : un8 = error, 0 = No, 1 = Yes}
 */
#define VE_REG_MULTIC_PROTECTIONS_13 0xD14D

/**
 * MultiC protections 14 (debug) {un16 = restart [1s], 0xFFFF = Not Available :
 * un16 = warn [1s], 0xFFFF = Not Available : un16 = error [1s], 0xFFFF = Not
 * Available : un8 = effective (see xml for meanings) : un8 = count : un8 = warn,
 * 0 = No, 1 = Yes : un8 = error, 0 = No, 1 = Yes}
 */
#define VE_REG_MULTIC_PROTECTIONS_14 0xD14E

/**
 * MultiC protections 15 (debug) {un16 = restart [1s], 0xFFFF = Not Available :
 * un16 = warn [1s], 0xFFFF = Not Available : un16 = error [1s], 0xFFFF = Not
 * Available : un8 = effective (see xml for meanings) : un8 = count : un8 = warn,
 * 0 = No, 1 = Yes : un8 = error, 0 = No, 1 = Yes}
 */
#define VE_REG_MULTIC_PROTECTIONS_15 0xD14F

/**
 * MultiC protections 16 (debug) {un16 = restart [1s], 0xFFFF = Not Available :
 * un16 = warn [1s], 0xFFFF = Not Available : un16 = error [1s], 0xFFFF = Not
 * Available : un8 = effective (see xml for meanings) : un8 = count : un8 = warn,
 * 0 = No, 1 = Yes : un8 = error, 0 = No, 1 = Yes}
 */
#define VE_REG_MULTIC_PROTECTIONS_16 0xD150

/**
 * MultiC protections 17 (debug) {un16 = restart [1s], 0xFFFF = Not Available :
 * un16 = warn [1s], 0xFFFF = Not Available : un16 = error [1s], 0xFFFF = Not
 * Available : un8 = effective (see xml for meanings) : un8 = count : un8 = warn,
 * 0 = No, 1 = Yes : un8 = error, 0 = No, 1 = Yes}
 */
#define VE_REG_MULTIC_PROTECTIONS_17 0xD151

/**
 * MultiC protections 18 (debug) {un16 = restart [1s], 0xFFFF = Not Available :
 * un16 = warn [1s], 0xFFFF = Not Available : un16 = error [1s], 0xFFFF = Not
 * Available : un8 = effective (see xml for meanings) : un8 = count : un8 = warn,
 * 0 = No, 1 = Yes : un8 = error, 0 = No, 1 = Yes}
 */
#define VE_REG_MULTIC_PROTECTIONS_18 0xD152

/**
 * MultiC protections 19 (debug) {un16 = restart [1s], 0xFFFF = Not Available :
 * un16 = warn [1s], 0xFFFF = Not Available : un16 = error [1s], 0xFFFF = Not
 * Available : un8 = effective (see xml for meanings) : un8 = count : un8 = warn,
 * 0 = No, 1 = Yes : un8 = error, 0 = No, 1 = Yes}
 */
#define VE_REG_MULTIC_PROTECTIONS_19 0xD153

/**
 * MultiC protections 20 (debug) {un16 = restart [1s], 0xFFFF = Not Available :
 * un16 = warn [1s], 0xFFFF = Not Available : un16 = error [1s], 0xFFFF = Not
 * Available : un8 = effective (see xml for meanings) : un8 = count : un8 = warn,
 * 0 = No, 1 = Yes : un8 = error, 0 = No, 1 = Yes}
 */
#define VE_REG_MULTIC_PROTECTIONS_20 0xD154

/**
 * MultiC protections 21 (debug) {un16 = restart [1s], 0xFFFF = Not Available :
 * un16 = warn [1s], 0xFFFF = Not Available : un16 = error [1s], 0xFFFF = Not
 * Available : un8 = effective (see xml for meanings) : un8 = count : un8 = warn,
 * 0 = No, 1 = Yes : un8 = error, 0 = No, 1 = Yes}
 */
#define VE_REG_MULTIC_PROTECTIONS_21 0xD155

/**
 * MultiC protections 22 (debug) {un16 = restart [1s], 0xFFFF = Not Available :
 * un16 = warn [1s], 0xFFFF = Not Available : un16 = error [1s], 0xFFFF = Not
 * Available : un8 = effective (see xml for meanings) : un8 = count : un8 = warn,
 * 0 = No, 1 = Yes : un8 = error, 0 = No, 1 = Yes}
 */
#define VE_REG_MULTIC_PROTECTIONS_22 0xD156

/**
 * MultiC protections 23 (debug) {un16 = restart [1s], 0xFFFF = Not Available :
 * un16 = warn [1s], 0xFFFF = Not Available : un16 = error [1s], 0xFFFF = Not
 * Available : un8 = effective (see xml for meanings) : un8 = count : un8 = warn,
 * 0 = No, 1 = Yes : un8 = error, 0 = No, 1 = Yes}
 */
#define VE_REG_MULTIC_PROTECTIONS_23 0xD157

/**
 * MultiC protections 24 (debug) {un16 = restart [1s], 0xFFFF = Not Available :
 * un16 = warn [1s], 0xFFFF = Not Available : un16 = error [1s], 0xFFFF = Not
 * Available : un8 = effective (see xml for meanings) : un8 = count : un8 = warn,
 * 0 = No, 1 = Yes : un8 = error, 0 = No, 1 = Yes}
 */
#define VE_REG_MULTIC_PROTECTIONS_24 0xD158

/**
 * MultiC protections 25 (debug) {un16 = restart [1s], 0xFFFF = Not Available :
 * un16 = warn [1s], 0xFFFF = Not Available : un16 = error [1s], 0xFFFF = Not
 * Available : un8 = effective (see xml for meanings) : un8 = count : un8 = warn,
 * 0 = No, 1 = Yes : un8 = error, 0 = No, 1 = Yes}
 */
#define VE_REG_MULTIC_PROTECTIONS_25 0xD159

/**
 * MultiC protections 26 (debug) {un16 = restart [1s], 0xFFFF = Not Available :
 * un16 = warn [1s], 0xFFFF = Not Available : un16 = error [1s], 0xFFFF = Not
 * Available : un8 = effective (see xml for meanings) : un8 = count : un8 = warn,
 * 0 = No, 1 = Yes : un8 = error, 0 = No, 1 = Yes}
 */
#define VE_REG_MULTIC_PROTECTIONS_26 0xD15A

/**
 * MultiC protections 27 (debug) {un16 = restart [1s], 0xFFFF = Not Available :
 * un16 = warn [1s], 0xFFFF = Not Available : un16 = error [1s], 0xFFFF = Not
 * Available : un8 = effective (see xml for meanings) : un8 = count : un8 = warn,
 * 0 = No, 1 = Yes : un8 = error, 0 = No, 1 = Yes}
 */
#define VE_REG_MULTIC_PROTECTIONS_27 0xD15B

/**
 * MultiC protections 28 (debug) {un16 = restart [1s], 0xFFFF = Not Available :
 * un16 = warn [1s], 0xFFFF = Not Available : un16 = error [1s], 0xFFFF = Not
 * Available : un8 = effective (see xml for meanings) : un8 = count : un8 = warn,
 * 0 = No, 1 = Yes : un8 = error, 0 = No, 1 = Yes}
 */
#define VE_REG_MULTIC_PROTECTIONS_28 0xD15C

/**
 * MultiC protections 29 (debug) {un16 = restart [1s], 0xFFFF = Not Available :
 * un16 = warn [1s], 0xFFFF = Not Available : un16 = error [1s], 0xFFFF = Not
 * Available : un8 = effective (see xml for meanings) : un8 = count : un8 = warn,
 * 0 = No, 1 = Yes : un8 = error, 0 = No, 1 = Yes}
 */
#define VE_REG_MULTIC_PROTECTIONS_29 0xD15D

/**
 * MultiC protections 30 (debug) {un16 = restart [1s], 0xFFFF = Not Available :
 * un16 = warn [1s], 0xFFFF = Not Available : un16 = error [1s], 0xFFFF = Not
 * Available : un8 = effective (see xml for meanings) : un8 = count : un8 = warn,
 * 0 = No, 1 = Yes : un8 = error, 0 = No, 1 = Yes}
 */
#define VE_REG_MULTIC_PROTECTIONS_30 0xD15E

/**
 * MultiC protections 31 (debug) {un16 = restart [1s], 0xFFFF = Not Available :
 * un16 = warn [1s], 0xFFFF = Not Available : un16 = error [1s], 0xFFFF = Not
 * Available : un8 = effective (see xml for meanings) : un8 = count : un8 = warn,
 * 0 = No, 1 = Yes : un8 = error, 0 = No, 1 = Yes}
 */
#define VE_REG_MULTIC_PROTECTIONS_31 0xD15F

/**
 * MultiC inverter CONTROL_VECTOR {sn32 = uFbMin [0.001V], 0x7FFFFFFF = Not
 * Available : sn32 = uFbMax [0.001V], 0x7FFFFFFF = Not Available : sn32 =
 * iAcinMin [0.001A], 0x7FFFFFFF = Not Available : sn32 = iAcinMax [0.001A],
 * 0x7FFFFFFF = Not Available : sn32 = iAcinLow [0.001A], 0x7FFFFFFF = Not
 * Available : sn32 = iAcinHigh [0.001A], 0x7FFFFFFF = Not Available : sn32 =
 * pInvLow [0.001W], 0x7FFFFFFF = Not Available : sn32 = pInv0 [0.001W],
 * 0x7FFFFFFF = Not Available : sn32 = pInvHigh [0.001W], 0x7FFFFFFF = Not
 * Available : sn32 = uBusHigh [0.001V], 0x7FFFFFFF = Not Available}
 */
#define VE_REG_INV_CONTROL_VECTOR 0xD379

/**
 * MultiC inverter TIMED_CONTROL_ACIN {un32 = PresentControlAcinCommand : un32 =
 * NextControlAcinCommand : un32 = timeStamp}
 */
#define VE_REG_INV_TIMED_CONTROL_ACIN 0xD39E

/**
 * MultiC inverter TIMED_CONTROL_VAC_OUT {un16 = PresentVAcOut : un16 =
 * NextVAcOut : un32 = timeStamp}
 */
#define VE_REG_INV_TIMED_CONTROL_VAC_OUT 0xD3A0

/**
 * MultiC MPPT1 partial shading(debug) {un32 = active [1s], 0xFFFFFFFF = Not
 * Available : un32 = shading [1s], 0xFFFFFFFF = Not Available : un16 = pv
 * current slow average [0.1A], 0xFFFF = Not Available : un16 = pv current no
 * shade [0.1A], 0xFFFF = Not Available : un16 = pv voltage slow average [0.01V],
 * 0xFFFF = Not Available : un16 = pv voltage no shade [0.01V], 0xFFFF = Not
 * Available : un16 = pv voltage before scan [0.01V], 0xFFFF = Not Available :
 * un32 = pv power before scan [1W], 0xFFFFFFFF = Not Available : un8 = scan
 * mode, 0 = normal operation, 1 = scanning, 2 = restart tracker}
 */
#define VE_REG_MULTIC_MPPT1_PARTIAL_SHADING 0xD454

/**
 * MultiC MPPT1 power (debug) {un32 = core [0.001W], 0xFFFFFFFF = Not Available :
 * un32 = rloss [0.001W], 0xFFFFFFFF = Not Available : un32 = switching [0.001W],
 * 0xFFFFFFFF = Not Available : un32 = conduction [0.001W], 0xFFFFFFFF = Not
 * Available}
 */
#define VE_REG_MULTIC_MPPT1_POWER_DEBUG 0xD455

/**
 * MultiC MPPT2 partial shading(debug) {un32 = active [1s], 0xFFFFFFFF = Not
 * Available : un32 = shading [1s], 0xFFFFFFFF = Not Available : un16 = pv
 * current slow average [0.1A], 0xFFFF = Not Available : un16 = pv current no
 * shade [0.1A], 0xFFFF = Not Available : un16 = pv voltage slow average [0.01V],
 * 0xFFFF = Not Available : un16 = pv voltage no shade [0.01V], 0xFFFF = Not
 * Available : un16 = pv voltage before scan [0.01V], 0xFFFF = Not Available :
 * un32 = pv power before scan [1W], 0xFFFFFFFF = Not Available : un8 = scan
 * mode, 0 = normal operation, 1 = scanning, 2 = restart tracker}
 */
#define VE_REG_MULTIC_MPPT2_PARTIAL_SHADING 0xD474

/**
 * MultiC MPPT2 power (debug) {un32 = core [0.001W], 0xFFFFFFFF = Not Available :
 * un32 = rloss [0.001W], 0xFFFFFFFF = Not Available : un32 = switching [0.001W],
 * 0xFFFFFFFF = Not Available : un32 = conduction [0.001W], 0xFFFFFFFF = Not
 * Available}
 */
#define VE_REG_MULTIC_MPPT2_POWER_DEBUG 0xD475

/**
 * MultiC MPPT3 partial shading(debug) {un32 = active [1s], 0xFFFFFFFF = Not
 * Available : un32 = shading [1s], 0xFFFFFFFF = Not Available : un16 = pv
 * current slow average [0.1A], 0xFFFF = Not Available : un16 = pv current no
 * shade [0.1A], 0xFFFF = Not Available : un16 = pv voltage slow average [0.01V],
 * 0xFFFF = Not Available : un16 = pv voltage no shade [0.01V], 0xFFFF = Not
 * Available : un16 = pv voltage before scan [0.01V], 0xFFFF = Not Available :
 * un32 = pv power before scan [1W], 0xFFFFFFFF = Not Available : un8 = scan
 * mode, 0 = normal operation, 1 = scanning, 2 = restart tracker}
 */
#define VE_REG_MULTIC_MPPT3_PARTIAL_SHADING 0xD494

/**
 * MultiC MPPT3 power (debug) {un32 = core [0.001W], 0xFFFFFFFF = Not Available :
 * un32 = rloss [0.001W], 0xFFFFFFFF = Not Available : un32 = switching [0.001W],
 * 0xFFFFFFFF = Not Available : un32 = conduction [0.001W], 0xFFFFFFFF = Not
 * Available}
 */
#define VE_REG_MULTIC_MPPT3_POWER_DEBUG 0xD495

/**
 * MultiC MPPT4 partial shading(debug) {un32 = active [1s], 0xFFFFFFFF = Not
 * Available : un32 = shading [1s], 0xFFFFFFFF = Not Available : un16 = pv
 * current slow average [0.1A], 0xFFFF = Not Available : un16 = pv current no
 * shade [0.1A], 0xFFFF = Not Available : un16 = pv voltage slow average [0.01V],
 * 0xFFFF = Not Available : un16 = pv voltage no shade [0.01V], 0xFFFF = Not
 * Available : un16 = pv voltage before scan [0.01V], 0xFFFF = Not Available :
 * un32 = pv power before scan [1W], 0xFFFFFFFF = Not Available : un8 = scan
 * mode, 0 = normal operation, 1 = scanning, 2 = restart tracker}
 */
#define VE_REG_MULTIC_MPPT4_PARTIAL_SHADING 0xD4B4

/**
 * MultiC MPPT4 power (debug) {un32 = core [0.001W], 0xFFFFFFFF = Not Available :
 * un32 = rloss [0.001W], 0xFFFFFFFF = Not Available : un32 = switching [0.001W],
 * 0xFFFFFFFF = Not Available : un32 = conduction [0.001W], 0xFFFFFFFF = Not
 * Available}
 */
#define VE_REG_MULTIC_MPPT4_POWER_DEBUG 0xD4B5

/**
 * NMT Entry 0 (Part A) {bits[3] = ECU instance : bits[5] = Function instance :
 * un8 = Function : bits[1] = Reserved : bits[7] = Device class (see xml for
 * meanings) : bits[4] = Device class instance : bits[3] = Industry group (see
 * xml for meanings) : bits[1] = Self-configurable address : bits[21] = Identity
 * number : bits[11] = Manufacturer code (see xml for meanings) : bits[1] = NMT
 * ACL Expected : bits[1] = NMT Poll NAD : bits[1] = NMT Retry Request : bits[1]
 * = NMT Instance Changed : bits[1] = NMT Inactive : bits[1] = NMT Disconnected :
 * bits[2] = NMT Retry Counter : un8 = NMT NAD : un8 = NMT Timer : un8 = NMT ACL
 * Timer : un16 = Product Id (see xml for meanings), Note that the ve.direct mppt
 * chargers report this field incorrectly as an un16 with the product id in big-
 * endian notation : bits[1] = DEVICE_CLASS_VEBUS : bits[1] =
 * DEVICE_CLASS_CHARGER : bits[1] = DEVICE_CLASS_INVERTER : bits[1] =
 * DEVICE_CLASS_BATTERY : bits[1] = DEVICE_CLASS_GX_DEVICE : bits[3] =
 * DEVICE_CLASS_RESERVED : bits[1] = DEVICE_FLAGS_ACTIVE : bits[1] =
 * DEVICE_FLAGS_RESERVED1 : bits[1] = DEVICE_FLAGS_SYNC_CHARGING : bits[1] =
 * DEVICE_FLAGS_BMS : bits[1] = DEVICE_FLAGS_GROUP_MEMBER : bits[1] =
 * DEVICE_FLAGS_ACIN_LINK : bits[1] = DEVICE_FLAGS_EXT_CONTROL : bits[1] =
 * DEVICE_FLAGS_RESERVED7 : un8 = Timer : un8 = Group Id (see xml for meanings) :
 * un16 = Request Mask : un32 = DC Input Power [0.01W], 0xFFFFFFFF = Not
 * Available : sn16 = DC Current 1 [0.1A], 0x7FFF = Not Available : sn16 = DC
 * Current 2 [0.1A], 0x7FFF = Not Available : sn16 = DC Current 3 [0.1A], 0x7FFF
 * = Not Available : un8 = Device State (see xml for meanings) : un16 = Charge
 * Voltage Setpoint [0.01V], 0xFFFF = Not Available : un16 = Charge Current Limit
 * [0.1A], 0xFFFF = Not Available : un16 = Discharge Current Limit [0.1A], 0xFFFF
 * = Not Available : un16 = Discharge Voltage Limit [0.01V], 0xFFFF = Not
 * Available : un8 = System Voltage [1V] (see xml for meanings) : un8 = Charger
 * Algorithm Version (see xml for meanings) : un16 = State of Charge [0.01%] :
 * sn32 = Extra Battery Current [0.001A], 0x7FFFFFFF = Not Available : sn32 =
 * Battery Current [0.001A], 0x7FFFFFFF = Not Available : un16 = Battery Voltage
 * [0.01V], 0xFFFF = Not Available : sn16 = Battery Temperature [0.01°C], 0x7FFF
 * = Not Available : bits[5] = DEVICE_FLAGS2_RESERVED : bits[1] =
 * DEVICE_FLAGS2_HAS_ISENSE : bits[1] = DEVICE_FLAGS2_HAS_TSENSE : bits[1] =
 * DEVICE_FLAGS2_HAS_VSENSE}
 */
#define VE_REG_NMT_ENTRY0_A 0xD600

/**
 * NMT Entry 1 (Part A) {bits[3] = ECU instance : bits[5] = Function instance :
 * un8 = Function : bits[1] = Reserved : bits[7] = Device class (see xml for
 * meanings) : bits[4] = Device class instance : bits[3] = Industry group (see
 * xml for meanings) : bits[1] = Self-configurable address : bits[21] = Identity
 * number : bits[11] = Manufacturer code (see xml for meanings) : bits[1] = NMT
 * ACL Expected : bits[1] = NMT Poll NAD : bits[1] = NMT Retry Request : bits[1]
 * = NMT Instance Changed : bits[1] = NMT Inactive : bits[1] = NMT Disconnected :
 * bits[2] = NMT Retry Counter : un8 = NMT NAD : un8 = NMT Timer : un8 = NMT ACL
 * Timer : un16 = Product Id (see xml for meanings), Note that the ve.direct mppt
 * chargers report this field incorrectly as an un16 with the product id in big-
 * endian notation : bits[1] = DEVICE_CLASS_VEBUS : bits[1] =
 * DEVICE_CLASS_CHARGER : bits[1] = DEVICE_CLASS_INVERTER : bits[1] =
 * DEVICE_CLASS_BATTERY : bits[1] = DEVICE_CLASS_GX_DEVICE : bits[3] =
 * DEVICE_CLASS_RESERVED : bits[1] = DEVICE_FLAGS_ACTIVE : bits[1] =
 * DEVICE_FLAGS_RESERVED1 : bits[1] = DEVICE_FLAGS_SYNC_CHARGING : bits[1] =
 * DEVICE_FLAGS_BMS : bits[1] = DEVICE_FLAGS_GROUP_MEMBER : bits[1] =
 * DEVICE_FLAGS_ACIN_LINK : bits[1] = DEVICE_FLAGS_EXT_CONTROL : bits[1] =
 * DEVICE_FLAGS_RESERVED7 : un8 = Timer : un8 = Group Id (see xml for meanings) :
 * un16 = Request Mask : un32 = DC Input Power [0.01W], 0xFFFFFFFF = Not
 * Available : sn16 = DC Current 1 [0.1A], 0x7FFF = Not Available : sn16 = DC
 * Current 2 [0.1A], 0x7FFF = Not Available : sn16 = DC Current 3 [0.1A], 0x7FFF
 * = Not Available : un8 = Device State (see xml for meanings) : un16 = Charge
 * Voltage Setpoint [0.01V], 0xFFFF = Not Available : un16 = Charge Current Limit
 * [0.1A], 0xFFFF = Not Available : un16 = Discharge Current Limit [0.1A], 0xFFFF
 * = Not Available : un16 = Discharge Voltage Limit [0.01V], 0xFFFF = Not
 * Available : un8 = System Voltage [1V] (see xml for meanings) : un8 = Charger
 * Algorithm Version (see xml for meanings) : un16 = State of Charge [0.01%] :
 * sn32 = Extra Battery Current [0.001A], 0x7FFFFFFF = Not Available : sn32 =
 * Battery Current [0.001A], 0x7FFFFFFF = Not Available : un16 = Battery Voltage
 * [0.01V], 0xFFFF = Not Available : sn16 = Battery Temperature [0.01°C], 0x7FFF
 * = Not Available : bits[5] = DEVICE_FLAGS2_RESERVED : bits[1] =
 * DEVICE_FLAGS2_HAS_ISENSE : bits[1] = DEVICE_FLAGS2_HAS_TSENSE : bits[1] =
 * DEVICE_FLAGS2_HAS_VSENSE}
 */
#define VE_REG_NMT_ENTRY1_A 0xD601

/**
 * NMT Entry 2 (Part A) {bits[3] = ECU instance : bits[5] = Function instance :
 * un8 = Function : bits[1] = Reserved : bits[7] = Device class (see xml for
 * meanings) : bits[4] = Device class instance : bits[3] = Industry group (see
 * xml for meanings) : bits[1] = Self-configurable address : bits[21] = Identity
 * number : bits[11] = Manufacturer code (see xml for meanings) : bits[1] = NMT
 * ACL Expected : bits[1] = NMT Poll NAD : bits[1] = NMT Retry Request : bits[1]
 * = NMT Instance Changed : bits[1] = NMT Inactive : bits[1] = NMT Disconnected :
 * bits[2] = NMT Retry Counter : un8 = NMT NAD : un8 = NMT Timer : un8 = NMT ACL
 * Timer : un16 = Product Id (see xml for meanings), Note that the ve.direct mppt
 * chargers report this field incorrectly as an un16 with the product id in big-
 * endian notation : bits[1] = DEVICE_CLASS_VEBUS : bits[1] =
 * DEVICE_CLASS_CHARGER : bits[1] = DEVICE_CLASS_INVERTER : bits[1] =
 * DEVICE_CLASS_BATTERY : bits[1] = DEVICE_CLASS_GX_DEVICE : bits[3] =
 * DEVICE_CLASS_RESERVED : bits[1] = DEVICE_FLAGS_ACTIVE : bits[1] =
 * DEVICE_FLAGS_RESERVED1 : bits[1] = DEVICE_FLAGS_SYNC_CHARGING : bits[1] =
 * DEVICE_FLAGS_BMS : bits[1] = DEVICE_FLAGS_GROUP_MEMBER : bits[1] =
 * DEVICE_FLAGS_ACIN_LINK : bits[1] = DEVICE_FLAGS_EXT_CONTROL : bits[1] =
 * DEVICE_FLAGS_RESERVED7 : un8 = Timer : un8 = Group Id (see xml for meanings) :
 * un16 = Request Mask : un32 = DC Input Power [0.01W], 0xFFFFFFFF = Not
 * Available : sn16 = DC Current 1 [0.1A], 0x7FFF = Not Available : sn16 = DC
 * Current 2 [0.1A], 0x7FFF = Not Available : sn16 = DC Current 3 [0.1A], 0x7FFF
 * = Not Available : un8 = Device State (see xml for meanings) : un16 = Charge
 * Voltage Setpoint [0.01V], 0xFFFF = Not Available : un16 = Charge Current Limit
 * [0.1A], 0xFFFF = Not Available : un16 = Discharge Current Limit [0.1A], 0xFFFF
 * = Not Available : un16 = Discharge Voltage Limit [0.01V], 0xFFFF = Not
 * Available : un8 = System Voltage [1V] (see xml for meanings) : un8 = Charger
 * Algorithm Version (see xml for meanings) : un16 = State of Charge [0.01%] :
 * sn32 = Extra Battery Current [0.001A], 0x7FFFFFFF = Not Available : sn32 =
 * Battery Current [0.001A], 0x7FFFFFFF = Not Available : un16 = Battery Voltage
 * [0.01V], 0xFFFF = Not Available : sn16 = Battery Temperature [0.01°C], 0x7FFF
 * = Not Available : bits[5] = DEVICE_FLAGS2_RESERVED : bits[1] =
 * DEVICE_FLAGS2_HAS_ISENSE : bits[1] = DEVICE_FLAGS2_HAS_TSENSE : bits[1] =
 * DEVICE_FLAGS2_HAS_VSENSE}
 */
#define VE_REG_NMT_ENTRY2_A 0xD602

/**
 * NMT Entry 3 (Part A) {bits[3] = ECU instance : bits[5] = Function instance :
 * un8 = Function : bits[1] = Reserved : bits[7] = Device class (see xml for
 * meanings) : bits[4] = Device class instance : bits[3] = Industry group (see
 * xml for meanings) : bits[1] = Self-configurable address : bits[21] = Identity
 * number : bits[11] = Manufacturer code (see xml for meanings) : bits[1] = NMT
 * ACL Expected : bits[1] = NMT Poll NAD : bits[1] = NMT Retry Request : bits[1]
 * = NMT Instance Changed : bits[1] = NMT Inactive : bits[1] = NMT Disconnected :
 * bits[2] = NMT Retry Counter : un8 = NMT NAD : un8 = NMT Timer : un8 = NMT ACL
 * Timer : un16 = Product Id (see xml for meanings), Note that the ve.direct mppt
 * chargers report this field incorrectly as an un16 with the product id in big-
 * endian notation : bits[1] = DEVICE_CLASS_VEBUS : bits[1] =
 * DEVICE_CLASS_CHARGER : bits[1] = DEVICE_CLASS_INVERTER : bits[1] =
 * DEVICE_CLASS_BATTERY : bits[1] = DEVICE_CLASS_GX_DEVICE : bits[3] =
 * DEVICE_CLASS_RESERVED : bits[1] = DEVICE_FLAGS_ACTIVE : bits[1] =
 * DEVICE_FLAGS_RESERVED1 : bits[1] = DEVICE_FLAGS_SYNC_CHARGING : bits[1] =
 * DEVICE_FLAGS_BMS : bits[1] = DEVICE_FLAGS_GROUP_MEMBER : bits[1] =
 * DEVICE_FLAGS_ACIN_LINK : bits[1] = DEVICE_FLAGS_EXT_CONTROL : bits[1] =
 * DEVICE_FLAGS_RESERVED7 : un8 = Timer : un8 = Group Id (see xml for meanings) :
 * un16 = Request Mask : un32 = DC Input Power [0.01W], 0xFFFFFFFF = Not
 * Available : sn16 = DC Current 1 [0.1A], 0x7FFF = Not Available : sn16 = DC
 * Current 2 [0.1A], 0x7FFF = Not Available : sn16 = DC Current 3 [0.1A], 0x7FFF
 * = Not Available : un8 = Device State (see xml for meanings) : un16 = Charge
 * Voltage Setpoint [0.01V], 0xFFFF = Not Available : un16 = Charge Current Limit
 * [0.1A], 0xFFFF = Not Available : un16 = Discharge Current Limit [0.1A], 0xFFFF
 * = Not Available : un16 = Discharge Voltage Limit [0.01V], 0xFFFF = Not
 * Available : un8 = System Voltage [1V] (see xml for meanings) : un8 = Charger
 * Algorithm Version (see xml for meanings) : un16 = State of Charge [0.01%] :
 * sn32 = Extra Battery Current [0.001A], 0x7FFFFFFF = Not Available : sn32 =
 * Battery Current [0.001A], 0x7FFFFFFF = Not Available : un16 = Battery Voltage
 * [0.01V], 0xFFFF = Not Available : sn16 = Battery Temperature [0.01°C], 0x7FFF
 * = Not Available : bits[5] = DEVICE_FLAGS2_RESERVED : bits[1] =
 * DEVICE_FLAGS2_HAS_ISENSE : bits[1] = DEVICE_FLAGS2_HAS_TSENSE : bits[1] =
 * DEVICE_FLAGS2_HAS_VSENSE}
 */
#define VE_REG_NMT_ENTRY3_A 0xD603

/**
 * NMT Entry 4 (Part A) {bits[3] = ECU instance : bits[5] = Function instance :
 * un8 = Function : bits[1] = Reserved : bits[7] = Device class (see xml for
 * meanings) : bits[4] = Device class instance : bits[3] = Industry group (see
 * xml for meanings) : bits[1] = Self-configurable address : bits[21] = Identity
 * number : bits[11] = Manufacturer code (see xml for meanings) : bits[1] = NMT
 * ACL Expected : bits[1] = NMT Poll NAD : bits[1] = NMT Retry Request : bits[1]
 * = NMT Instance Changed : bits[1] = NMT Inactive : bits[1] = NMT Disconnected :
 * bits[2] = NMT Retry Counter : un8 = NMT NAD : un8 = NMT Timer : un8 = NMT ACL
 * Timer : un16 = Product Id (see xml for meanings), Note that the ve.direct mppt
 * chargers report this field incorrectly as an un16 with the product id in big-
 * endian notation : bits[1] = DEVICE_CLASS_VEBUS : bits[1] =
 * DEVICE_CLASS_CHARGER : bits[1] = DEVICE_CLASS_INVERTER : bits[1] =
 * DEVICE_CLASS_BATTERY : bits[1] = DEVICE_CLASS_GX_DEVICE : bits[3] =
 * DEVICE_CLASS_RESERVED : bits[1] = DEVICE_FLAGS_ACTIVE : bits[1] =
 * DEVICE_FLAGS_RESERVED1 : bits[1] = DEVICE_FLAGS_SYNC_CHARGING : bits[1] =
 * DEVICE_FLAGS_BMS : bits[1] = DEVICE_FLAGS_GROUP_MEMBER : bits[1] =
 * DEVICE_FLAGS_ACIN_LINK : bits[1] = DEVICE_FLAGS_EXT_CONTROL : bits[1] =
 * DEVICE_FLAGS_RESERVED7 : un8 = Timer : un8 = Group Id (see xml for meanings) :
 * un16 = Request Mask : un32 = DC Input Power [0.01W], 0xFFFFFFFF = Not
 * Available : sn16 = DC Current 1 [0.1A], 0x7FFF = Not Available : sn16 = DC
 * Current 2 [0.1A], 0x7FFF = Not Available : sn16 = DC Current 3 [0.1A], 0x7FFF
 * = Not Available : un8 = Device State (see xml for meanings) : un16 = Charge
 * Voltage Setpoint [0.01V], 0xFFFF = Not Available : un16 = Charge Current Limit
 * [0.1A], 0xFFFF = Not Available : un16 = Discharge Current Limit [0.1A], 0xFFFF
 * = Not Available : un16 = Discharge Voltage Limit [0.01V], 0xFFFF = Not
 * Available : un8 = System Voltage [1V] (see xml for meanings) : un8 = Charger
 * Algorithm Version (see xml for meanings) : un16 = State of Charge [0.01%] :
 * sn32 = Extra Battery Current [0.001A], 0x7FFFFFFF = Not Available : sn32 =
 * Battery Current [0.001A], 0x7FFFFFFF = Not Available : un16 = Battery Voltage
 * [0.01V], 0xFFFF = Not Available : sn16 = Battery Temperature [0.01°C], 0x7FFF
 * = Not Available : bits[5] = DEVICE_FLAGS2_RESERVED : bits[1] =
 * DEVICE_FLAGS2_HAS_ISENSE : bits[1] = DEVICE_FLAGS2_HAS_TSENSE : bits[1] =
 * DEVICE_FLAGS2_HAS_VSENSE}
 */
#define VE_REG_NMT_ENTRY4_A 0xD604

/**
 * NMT Entry 5 (Part A) {bits[3] = ECU instance : bits[5] = Function instance :
 * un8 = Function : bits[1] = Reserved : bits[7] = Device class (see xml for
 * meanings) : bits[4] = Device class instance : bits[3] = Industry group (see
 * xml for meanings) : bits[1] = Self-configurable address : bits[21] = Identity
 * number : bits[11] = Manufacturer code (see xml for meanings) : bits[1] = NMT
 * ACL Expected : bits[1] = NMT Poll NAD : bits[1] = NMT Retry Request : bits[1]
 * = NMT Instance Changed : bits[1] = NMT Inactive : bits[1] = NMT Disconnected :
 * bits[2] = NMT Retry Counter : un8 = NMT NAD : un8 = NMT Timer : un8 = NMT ACL
 * Timer : un16 = Product Id (see xml for meanings), Note that the ve.direct mppt
 * chargers report this field incorrectly as an un16 with the product id in big-
 * endian notation : bits[1] = DEVICE_CLASS_VEBUS : bits[1] =
 * DEVICE_CLASS_CHARGER : bits[1] = DEVICE_CLASS_INVERTER : bits[1] =
 * DEVICE_CLASS_BATTERY : bits[1] = DEVICE_CLASS_GX_DEVICE : bits[3] =
 * DEVICE_CLASS_RESERVED : bits[1] = DEVICE_FLAGS_ACTIVE : bits[1] =
 * DEVICE_FLAGS_RESERVED1 : bits[1] = DEVICE_FLAGS_SYNC_CHARGING : bits[1] =
 * DEVICE_FLAGS_BMS : bits[1] = DEVICE_FLAGS_GROUP_MEMBER : bits[1] =
 * DEVICE_FLAGS_ACIN_LINK : bits[1] = DEVICE_FLAGS_EXT_CONTROL : bits[1] =
 * DEVICE_FLAGS_RESERVED7 : un8 = Timer : un8 = Group Id (see xml for meanings) :
 * un16 = Request Mask : un32 = DC Input Power [0.01W], 0xFFFFFFFF = Not
 * Available : sn16 = DC Current 1 [0.1A], 0x7FFF = Not Available : sn16 = DC
 * Current 2 [0.1A], 0x7FFF = Not Available : sn16 = DC Current 3 [0.1A], 0x7FFF
 * = Not Available : un8 = Device State (see xml for meanings) : un16 = Charge
 * Voltage Setpoint [0.01V], 0xFFFF = Not Available : un16 = Charge Current Limit
 * [0.1A], 0xFFFF = Not Available : un16 = Discharge Current Limit [0.1A], 0xFFFF
 * = Not Available : un16 = Discharge Voltage Limit [0.01V], 0xFFFF = Not
 * Available : un8 = System Voltage [1V] (see xml for meanings) : un8 = Charger
 * Algorithm Version (see xml for meanings) : un16 = State of Charge [0.01%] :
 * sn32 = Extra Battery Current [0.001A], 0x7FFFFFFF = Not Available : sn32 =
 * Battery Current [0.001A], 0x7FFFFFFF = Not Available : un16 = Battery Voltage
 * [0.01V], 0xFFFF = Not Available : sn16 = Battery Temperature [0.01°C], 0x7FFF
 * = Not Available : bits[5] = DEVICE_FLAGS2_RESERVED : bits[1] =
 * DEVICE_FLAGS2_HAS_ISENSE : bits[1] = DEVICE_FLAGS2_HAS_TSENSE : bits[1] =
 * DEVICE_FLAGS2_HAS_VSENSE}
 */
#define VE_REG_NMT_ENTRY5_A 0xD605

/**
 * NMT Entry 6 (Part A) {bits[3] = ECU instance : bits[5] = Function instance :
 * un8 = Function : bits[1] = Reserved : bits[7] = Device class (see xml for
 * meanings) : bits[4] = Device class instance : bits[3] = Industry group (see
 * xml for meanings) : bits[1] = Self-configurable address : bits[21] = Identity
 * number : bits[11] = Manufacturer code (see xml for meanings) : bits[1] = NMT
 * ACL Expected : bits[1] = NMT Poll NAD : bits[1] = NMT Retry Request : bits[1]
 * = NMT Instance Changed : bits[1] = NMT Inactive : bits[1] = NMT Disconnected :
 * bits[2] = NMT Retry Counter : un8 = NMT NAD : un8 = NMT Timer : un8 = NMT ACL
 * Timer : un16 = Product Id (see xml for meanings), Note that the ve.direct mppt
 * chargers report this field incorrectly as an un16 with the product id in big-
 * endian notation : bits[1] = DEVICE_CLASS_VEBUS : bits[1] =
 * DEVICE_CLASS_CHARGER : bits[1] = DEVICE_CLASS_INVERTER : bits[1] =
 * DEVICE_CLASS_BATTERY : bits[1] = DEVICE_CLASS_GX_DEVICE : bits[3] =
 * DEVICE_CLASS_RESERVED : bits[1] = DEVICE_FLAGS_ACTIVE : bits[1] =
 * DEVICE_FLAGS_RESERVED1 : bits[1] = DEVICE_FLAGS_SYNC_CHARGING : bits[1] =
 * DEVICE_FLAGS_BMS : bits[1] = DEVICE_FLAGS_GROUP_MEMBER : bits[1] =
 * DEVICE_FLAGS_ACIN_LINK : bits[1] = DEVICE_FLAGS_EXT_CONTROL : bits[1] =
 * DEVICE_FLAGS_RESERVED7 : un8 = Timer : un8 = Group Id (see xml for meanings) :
 * un16 = Request Mask : un32 = DC Input Power [0.01W], 0xFFFFFFFF = Not
 * Available : sn16 = DC Current 1 [0.1A], 0x7FFF = Not Available : sn16 = DC
 * Current 2 [0.1A], 0x7FFF = Not Available : sn16 = DC Current 3 [0.1A], 0x7FFF
 * = Not Available : un8 = Device State (see xml for meanings) : un16 = Charge
 * Voltage Setpoint [0.01V], 0xFFFF = Not Available : un16 = Charge Current Limit
 * [0.1A], 0xFFFF = Not Available : un16 = Discharge Current Limit [0.1A], 0xFFFF
 * = Not Available : un16 = Discharge Voltage Limit [0.01V], 0xFFFF = Not
 * Available : un8 = System Voltage [1V] (see xml for meanings) : un8 = Charger
 * Algorithm Version (see xml for meanings) : un16 = State of Charge [0.01%] :
 * sn32 = Extra Battery Current [0.001A], 0x7FFFFFFF = Not Available : sn32 =
 * Battery Current [0.001A], 0x7FFFFFFF = Not Available : un16 = Battery Voltage
 * [0.01V], 0xFFFF = Not Available : sn16 = Battery Temperature [0.01°C], 0x7FFF
 * = Not Available : bits[5] = DEVICE_FLAGS2_RESERVED : bits[1] =
 * DEVICE_FLAGS2_HAS_ISENSE : bits[1] = DEVICE_FLAGS2_HAS_TSENSE : bits[1] =
 * DEVICE_FLAGS2_HAS_VSENSE}
 */
#define VE_REG_NMT_ENTRY6_A 0xD606

/**
 * NMT Entry 7 (Part A) {bits[3] = ECU instance : bits[5] = Function instance :
 * un8 = Function : bits[1] = Reserved : bits[7] = Device class (see xml for
 * meanings) : bits[4] = Device class instance : bits[3] = Industry group (see
 * xml for meanings) : bits[1] = Self-configurable address : bits[21] = Identity
 * number : bits[11] = Manufacturer code (see xml for meanings) : bits[1] = NMT
 * ACL Expected : bits[1] = NMT Poll NAD : bits[1] = NMT Retry Request : bits[1]
 * = NMT Instance Changed : bits[1] = NMT Inactive : bits[1] = NMT Disconnected :
 * bits[2] = NMT Retry Counter : un8 = NMT NAD : un8 = NMT Timer : un8 = NMT ACL
 * Timer : un16 = Product Id (see xml for meanings), Note that the ve.direct mppt
 * chargers report this field incorrectly as an un16 with the product id in big-
 * endian notation : bits[1] = DEVICE_CLASS_VEBUS : bits[1] =
 * DEVICE_CLASS_CHARGER : bits[1] = DEVICE_CLASS_INVERTER : bits[1] =
 * DEVICE_CLASS_BATTERY : bits[1] = DEVICE_CLASS_GX_DEVICE : bits[3] =
 * DEVICE_CLASS_RESERVED : bits[1] = DEVICE_FLAGS_ACTIVE : bits[1] =
 * DEVICE_FLAGS_RESERVED1 : bits[1] = DEVICE_FLAGS_SYNC_CHARGING : bits[1] =
 * DEVICE_FLAGS_BMS : bits[1] = DEVICE_FLAGS_GROUP_MEMBER : bits[1] =
 * DEVICE_FLAGS_ACIN_LINK : bits[1] = DEVICE_FLAGS_EXT_CONTROL : bits[1] =
 * DEVICE_FLAGS_RESERVED7 : un8 = Timer : un8 = Group Id (see xml for meanings) :
 * un16 = Request Mask : un32 = DC Input Power [0.01W], 0xFFFFFFFF = Not
 * Available : sn16 = DC Current 1 [0.1A], 0x7FFF = Not Available : sn16 = DC
 * Current 2 [0.1A], 0x7FFF = Not Available : sn16 = DC Current 3 [0.1A], 0x7FFF
 * = Not Available : un8 = Device State (see xml for meanings) : un16 = Charge
 * Voltage Setpoint [0.01V], 0xFFFF = Not Available : un16 = Charge Current Limit
 * [0.1A], 0xFFFF = Not Available : un16 = Discharge Current Limit [0.1A], 0xFFFF
 * = Not Available : un16 = Discharge Voltage Limit [0.01V], 0xFFFF = Not
 * Available : un8 = System Voltage [1V] (see xml for meanings) : un8 = Charger
 * Algorithm Version (see xml for meanings) : un16 = State of Charge [0.01%] :
 * sn32 = Extra Battery Current [0.001A], 0x7FFFFFFF = Not Available : sn32 =
 * Battery Current [0.001A], 0x7FFFFFFF = Not Available : un16 = Battery Voltage
 * [0.01V], 0xFFFF = Not Available : sn16 = Battery Temperature [0.01°C], 0x7FFF
 * = Not Available : bits[5] = DEVICE_FLAGS2_RESERVED : bits[1] =
 * DEVICE_FLAGS2_HAS_ISENSE : bits[1] = DEVICE_FLAGS2_HAS_TSENSE : bits[1] =
 * DEVICE_FLAGS2_HAS_VSENSE}
 */
#define VE_REG_NMT_ENTRY7_A 0xD607

/**
 * NMT Entry 8 (Part A) {bits[3] = ECU instance : bits[5] = Function instance :
 * un8 = Function : bits[1] = Reserved : bits[7] = Device class (see xml for
 * meanings) : bits[4] = Device class instance : bits[3] = Industry group (see
 * xml for meanings) : bits[1] = Self-configurable address : bits[21] = Identity
 * number : bits[11] = Manufacturer code (see xml for meanings) : bits[1] = NMT
 * ACL Expected : bits[1] = NMT Poll NAD : bits[1] = NMT Retry Request : bits[1]
 * = NMT Instance Changed : bits[1] = NMT Inactive : bits[1] = NMT Disconnected :
 * bits[2] = NMT Retry Counter : un8 = NMT NAD : un8 = NMT Timer : un8 = NMT ACL
 * Timer : un16 = Product Id (see xml for meanings), Note that the ve.direct mppt
 * chargers report this field incorrectly as an un16 with the product id in big-
 * endian notation : bits[1] = DEVICE_CLASS_VEBUS : bits[1] =
 * DEVICE_CLASS_CHARGER : bits[1] = DEVICE_CLASS_INVERTER : bits[1] =
 * DEVICE_CLASS_BATTERY : bits[1] = DEVICE_CLASS_GX_DEVICE : bits[3] =
 * DEVICE_CLASS_RESERVED : bits[1] = DEVICE_FLAGS_ACTIVE : bits[1] =
 * DEVICE_FLAGS_RESERVED1 : bits[1] = DEVICE_FLAGS_SYNC_CHARGING : bits[1] =
 * DEVICE_FLAGS_BMS : bits[1] = DEVICE_FLAGS_GROUP_MEMBER : bits[1] =
 * DEVICE_FLAGS_ACIN_LINK : bits[1] = DEVICE_FLAGS_EXT_CONTROL : bits[1] =
 * DEVICE_FLAGS_RESERVED7 : un8 = Timer : un8 = Group Id (see xml for meanings) :
 * un16 = Request Mask : un32 = DC Input Power [0.01W], 0xFFFFFFFF = Not
 * Available : sn16 = DC Current 1 [0.1A], 0x7FFF = Not Available : sn16 = DC
 * Current 2 [0.1A], 0x7FFF = Not Available : sn16 = DC Current 3 [0.1A], 0x7FFF
 * = Not Available : un8 = Device State (see xml for meanings) : un16 = Charge
 * Voltage Setpoint [0.01V], 0xFFFF = Not Available : un16 = Charge Current Limit
 * [0.1A], 0xFFFF = Not Available : un16 = Discharge Current Limit [0.1A], 0xFFFF
 * = Not Available : un16 = Discharge Voltage Limit [0.01V], 0xFFFF = Not
 * Available : un8 = System Voltage [1V] (see xml for meanings) : un8 = Charger
 * Algorithm Version (see xml for meanings) : un16 = State of Charge [0.01%] :
 * sn32 = Extra Battery Current [0.001A], 0x7FFFFFFF = Not Available : sn32 =
 * Battery Current [0.001A], 0x7FFFFFFF = Not Available : un16 = Battery Voltage
 * [0.01V], 0xFFFF = Not Available : sn16 = Battery Temperature [0.01°C], 0x7FFF
 * = Not Available : bits[5] = DEVICE_FLAGS2_RESERVED : bits[1] =
 * DEVICE_FLAGS2_HAS_ISENSE : bits[1] = DEVICE_FLAGS2_HAS_TSENSE : bits[1] =
 * DEVICE_FLAGS2_HAS_VSENSE}
 */
#define VE_REG_NMT_ENTRY8_A 0xD608

/**
 * NMT Entry 9 (Part A) {bits[3] = ECU instance : bits[5] = Function instance :
 * un8 = Function : bits[1] = Reserved : bits[7] = Device class (see xml for
 * meanings) : bits[4] = Device class instance : bits[3] = Industry group (see
 * xml for meanings) : bits[1] = Self-configurable address : bits[21] = Identity
 * number : bits[11] = Manufacturer code (see xml for meanings) : bits[1] = NMT
 * ACL Expected : bits[1] = NMT Poll NAD : bits[1] = NMT Retry Request : bits[1]
 * = NMT Instance Changed : bits[1] = NMT Inactive : bits[1] = NMT Disconnected :
 * bits[2] = NMT Retry Counter : un8 = NMT NAD : un8 = NMT Timer : un8 = NMT ACL
 * Timer : un16 = Product Id (see xml for meanings), Note that the ve.direct mppt
 * chargers report this field incorrectly as an un16 with the product id in big-
 * endian notation : bits[1] = DEVICE_CLASS_VEBUS : bits[1] =
 * DEVICE_CLASS_CHARGER : bits[1] = DEVICE_CLASS_INVERTER : bits[1] =
 * DEVICE_CLASS_BATTERY : bits[1] = DEVICE_CLASS_GX_DEVICE : bits[3] =
 * DEVICE_CLASS_RESERVED : bits[1] = DEVICE_FLAGS_ACTIVE : bits[1] =
 * DEVICE_FLAGS_RESERVED1 : bits[1] = DEVICE_FLAGS_SYNC_CHARGING : bits[1] =
 * DEVICE_FLAGS_BMS : bits[1] = DEVICE_FLAGS_GROUP_MEMBER : bits[1] =
 * DEVICE_FLAGS_ACIN_LINK : bits[1] = DEVICE_FLAGS_EXT_CONTROL : bits[1] =
 * DEVICE_FLAGS_RESERVED7 : un8 = Timer : un8 = Group Id (see xml for meanings) :
 * un16 = Request Mask : un32 = DC Input Power [0.01W], 0xFFFFFFFF = Not
 * Available : sn16 = DC Current 1 [0.1A], 0x7FFF = Not Available : sn16 = DC
 * Current 2 [0.1A], 0x7FFF = Not Available : sn16 = DC Current 3 [0.1A], 0x7FFF
 * = Not Available : un8 = Device State (see xml for meanings) : un16 = Charge
 * Voltage Setpoint [0.01V], 0xFFFF = Not Available : un16 = Charge Current Limit
 * [0.1A], 0xFFFF = Not Available : un16 = Discharge Current Limit [0.1A], 0xFFFF
 * = Not Available : un16 = Discharge Voltage Limit [0.01V], 0xFFFF = Not
 * Available : un8 = System Voltage [1V] (see xml for meanings) : un8 = Charger
 * Algorithm Version (see xml for meanings) : un16 = State of Charge [0.01%] :
 * sn32 = Extra Battery Current [0.001A], 0x7FFFFFFF = Not Available : sn32 =
 * Battery Current [0.001A], 0x7FFFFFFF = Not Available : un16 = Battery Voltage
 * [0.01V], 0xFFFF = Not Available : sn16 = Battery Temperature [0.01°C], 0x7FFF
 * = Not Available : bits[5] = DEVICE_FLAGS2_RESERVED : bits[1] =
 * DEVICE_FLAGS2_HAS_ISENSE : bits[1] = DEVICE_FLAGS2_HAS_TSENSE : bits[1] =
 * DEVICE_FLAGS2_HAS_VSENSE}
 */
#define VE_REG_NMT_ENTRY9_A 0xD609

/**
 * NMT Entry 10 (Part A) {bits[3] = ECU instance : bits[5] = Function instance :
 * un8 = Function : bits[1] = Reserved : bits[7] = Device class (see xml for
 * meanings) : bits[4] = Device class instance : bits[3] = Industry group (see
 * xml for meanings) : bits[1] = Self-configurable address : bits[21] = Identity
 * number : bits[11] = Manufacturer code (see xml for meanings) : bits[1] = NMT
 * ACL Expected : bits[1] = NMT Poll NAD : bits[1] = NMT Retry Request : bits[1]
 * = NMT Instance Changed : bits[1] = NMT Inactive : bits[1] = NMT Disconnected :
 * bits[2] = NMT Retry Counter : un8 = NMT NAD : un8 = NMT Timer : un8 = NMT ACL
 * Timer : un16 = Product Id (see xml for meanings), Note that the ve.direct mppt
 * chargers report this field incorrectly as an un16 with the product id in big-
 * endian notation : bits[1] = DEVICE_CLASS_VEBUS : bits[1] =
 * DEVICE_CLASS_CHARGER : bits[1] = DEVICE_CLASS_INVERTER : bits[1] =
 * DEVICE_CLASS_BATTERY : bits[1] = DEVICE_CLASS_GX_DEVICE : bits[3] =
 * DEVICE_CLASS_RESERVED : bits[1] = DEVICE_FLAGS_ACTIVE : bits[1] =
 * DEVICE_FLAGS_RESERVED1 : bits[1] = DEVICE_FLAGS_SYNC_CHARGING : bits[1] =
 * DEVICE_FLAGS_BMS : bits[1] = DEVICE_FLAGS_GROUP_MEMBER : bits[1] =
 * DEVICE_FLAGS_ACIN_LINK : bits[1] = DEVICE_FLAGS_EXT_CONTROL : bits[1] =
 * DEVICE_FLAGS_RESERVED7 : un8 = Timer : un8 = Group Id (see xml for meanings) :
 * un16 = Request Mask : un32 = DC Input Power [0.01W], 0xFFFFFFFF = Not
 * Available : sn16 = DC Current 1 [0.1A], 0x7FFF = Not Available : sn16 = DC
 * Current 2 [0.1A], 0x7FFF = Not Available : sn16 = DC Current 3 [0.1A], 0x7FFF
 * = Not Available : un8 = Device State (see xml for meanings) : un16 = Charge
 * Voltage Setpoint [0.01V], 0xFFFF = Not Available : un16 = Charge Current Limit
 * [0.1A], 0xFFFF = Not Available : un16 = Discharge Current Limit [0.1A], 0xFFFF
 * = Not Available : un16 = Discharge Voltage Limit [0.01V], 0xFFFF = Not
 * Available : un8 = System Voltage [1V] (see xml for meanings) : un8 = Charger
 * Algorithm Version (see xml for meanings) : un16 = State of Charge [0.01%] :
 * sn32 = Extra Battery Current [0.001A], 0x7FFFFFFF = Not Available : sn32 =
 * Battery Current [0.001A], 0x7FFFFFFF = Not Available : un16 = Battery Voltage
 * [0.01V], 0xFFFF = Not Available : sn16 = Battery Temperature [0.01°C], 0x7FFF
 * = Not Available : bits[5] = DEVICE_FLAGS2_RESERVED : bits[1] =
 * DEVICE_FLAGS2_HAS_ISENSE : bits[1] = DEVICE_FLAGS2_HAS_TSENSE : bits[1] =
 * DEVICE_FLAGS2_HAS_VSENSE}
 */
#define VE_REG_NMT_ENTRY10_A 0xD60A

/**
 * NMT Entry 11 (Part A) {bits[3] = ECU instance : bits[5] = Function instance :
 * un8 = Function : bits[1] = Reserved : bits[7] = Device class (see xml for
 * meanings) : bits[4] = Device class instance : bits[3] = Industry group (see
 * xml for meanings) : bits[1] = Self-configurable address : bits[21] = Identity
 * number : bits[11] = Manufacturer code (see xml for meanings) : bits[1] = NMT
 * ACL Expected : bits[1] = NMT Poll NAD : bits[1] = NMT Retry Request : bits[1]
 * = NMT Instance Changed : bits[1] = NMT Inactive : bits[1] = NMT Disconnected :
 * bits[2] = NMT Retry Counter : un8 = NMT NAD : un8 = NMT Timer : un8 = NMT ACL
 * Timer : un16 = Product Id (see xml for meanings), Note that the ve.direct mppt
 * chargers report this field incorrectly as an un16 with the product id in big-
 * endian notation : bits[1] = DEVICE_CLASS_VEBUS : bits[1] =
 * DEVICE_CLASS_CHARGER : bits[1] = DEVICE_CLASS_INVERTER : bits[1] =
 * DEVICE_CLASS_BATTERY : bits[1] = DEVICE_CLASS_GX_DEVICE : bits[3] =
 * DEVICE_CLASS_RESERVED : bits[1] = DEVICE_FLAGS_ACTIVE : bits[1] =
 * DEVICE_FLAGS_RESERVED1 : bits[1] = DEVICE_FLAGS_SYNC_CHARGING : bits[1] =
 * DEVICE_FLAGS_BMS : bits[1] = DEVICE_FLAGS_GROUP_MEMBER : bits[1] =
 * DEVICE_FLAGS_ACIN_LINK : bits[1] = DEVICE_FLAGS_EXT_CONTROL : bits[1] =
 * DEVICE_FLAGS_RESERVED7 : un8 = Timer : un8 = Group Id (see xml for meanings) :
 * un16 = Request Mask : un32 = DC Input Power [0.01W], 0xFFFFFFFF = Not
 * Available : sn16 = DC Current 1 [0.1A], 0x7FFF = Not Available : sn16 = DC
 * Current 2 [0.1A], 0x7FFF = Not Available : sn16 = DC Current 3 [0.1A], 0x7FFF
 * = Not Available : un8 = Device State (see xml for meanings) : un16 = Charge
 * Voltage Setpoint [0.01V], 0xFFFF = Not Available : un16 = Charge Current Limit
 * [0.1A], 0xFFFF = Not Available : un16 = Discharge Current Limit [0.1A], 0xFFFF
 * = Not Available : un16 = Discharge Voltage Limit [0.01V], 0xFFFF = Not
 * Available : un8 = System Voltage [1V] (see xml for meanings) : un8 = Charger
 * Algorithm Version (see xml for meanings) : un16 = State of Charge [0.01%] :
 * sn32 = Extra Battery Current [0.001A], 0x7FFFFFFF = Not Available : sn32 =
 * Battery Current [0.001A], 0x7FFFFFFF = Not Available : un16 = Battery Voltage
 * [0.01V], 0xFFFF = Not Available : sn16 = Battery Temperature [0.01°C], 0x7FFF
 * = Not Available : bits[5] = DEVICE_FLAGS2_RESERVED : bits[1] =
 * DEVICE_FLAGS2_HAS_ISENSE : bits[1] = DEVICE_FLAGS2_HAS_TSENSE : bits[1] =
 * DEVICE_FLAGS2_HAS_VSENSE}
 */
#define VE_REG_NMT_ENTRY11_A 0xD60B

/**
 * NMT Entry 12 (Part A) {bits[3] = ECU instance : bits[5] = Function instance :
 * un8 = Function : bits[1] = Reserved : bits[7] = Device class (see xml for
 * meanings) : bits[4] = Device class instance : bits[3] = Industry group (see
 * xml for meanings) : bits[1] = Self-configurable address : bits[21] = Identity
 * number : bits[11] = Manufacturer code (see xml for meanings) : bits[1] = NMT
 * ACL Expected : bits[1] = NMT Poll NAD : bits[1] = NMT Retry Request : bits[1]
 * = NMT Instance Changed : bits[1] = NMT Inactive : bits[1] = NMT Disconnected :
 * bits[2] = NMT Retry Counter : un8 = NMT NAD : un8 = NMT Timer : un8 = NMT ACL
 * Timer : un16 = Product Id (see xml for meanings), Note that the ve.direct mppt
 * chargers report this field incorrectly as an un16 with the product id in big-
 * endian notation : bits[1] = DEVICE_CLASS_VEBUS : bits[1] =
 * DEVICE_CLASS_CHARGER : bits[1] = DEVICE_CLASS_INVERTER : bits[1] =
 * DEVICE_CLASS_BATTERY : bits[1] = DEVICE_CLASS_GX_DEVICE : bits[3] =
 * DEVICE_CLASS_RESERVED : bits[1] = DEVICE_FLAGS_ACTIVE : bits[1] =
 * DEVICE_FLAGS_RESERVED1 : bits[1] = DEVICE_FLAGS_SYNC_CHARGING : bits[1] =
 * DEVICE_FLAGS_BMS : bits[1] = DEVICE_FLAGS_GROUP_MEMBER : bits[1] =
 * DEVICE_FLAGS_ACIN_LINK : bits[1] = DEVICE_FLAGS_EXT_CONTROL : bits[1] =
 * DEVICE_FLAGS_RESERVED7 : un8 = Timer : un8 = Group Id (see xml for meanings) :
 * un16 = Request Mask : un32 = DC Input Power [0.01W], 0xFFFFFFFF = Not
 * Available : sn16 = DC Current 1 [0.1A], 0x7FFF = Not Available : sn16 = DC
 * Current 2 [0.1A], 0x7FFF = Not Available : sn16 = DC Current 3 [0.1A], 0x7FFF
 * = Not Available : un8 = Device State (see xml for meanings) : un16 = Charge
 * Voltage Setpoint [0.01V], 0xFFFF = Not Available : un16 = Charge Current Limit
 * [0.1A], 0xFFFF = Not Available : un16 = Discharge Current Limit [0.1A], 0xFFFF
 * = Not Available : un16 = Discharge Voltage Limit [0.01V], 0xFFFF = Not
 * Available : un8 = System Voltage [1V] (see xml for meanings) : un8 = Charger
 * Algorithm Version (see xml for meanings) : un16 = State of Charge [0.01%] :
 * sn32 = Extra Battery Current [0.001A], 0x7FFFFFFF = Not Available : sn32 =
 * Battery Current [0.001A], 0x7FFFFFFF = Not Available : un16 = Battery Voltage
 * [0.01V], 0xFFFF = Not Available : sn16 = Battery Temperature [0.01°C], 0x7FFF
 * = Not Available : bits[5] = DEVICE_FLAGS2_RESERVED : bits[1] =
 * DEVICE_FLAGS2_HAS_ISENSE : bits[1] = DEVICE_FLAGS2_HAS_TSENSE : bits[1] =
 * DEVICE_FLAGS2_HAS_VSENSE}
 */
#define VE_REG_NMT_ENTRY12_A 0xD60C

/**
 * NMT Entry 13 (Part A) {bits[3] = ECU instance : bits[5] = Function instance :
 * un8 = Function : bits[1] = Reserved : bits[7] = Device class (see xml for
 * meanings) : bits[4] = Device class instance : bits[3] = Industry group (see
 * xml for meanings) : bits[1] = Self-configurable address : bits[21] = Identity
 * number : bits[11] = Manufacturer code (see xml for meanings) : bits[1] = NMT
 * ACL Expected : bits[1] = NMT Poll NAD : bits[1] = NMT Retry Request : bits[1]
 * = NMT Instance Changed : bits[1] = NMT Inactive : bits[1] = NMT Disconnected :
 * bits[2] = NMT Retry Counter : un8 = NMT NAD : un8 = NMT Timer : un8 = NMT ACL
 * Timer : un16 = Product Id (see xml for meanings), Note that the ve.direct mppt
 * chargers report this field incorrectly as an un16 with the product id in big-
 * endian notation : bits[1] = DEVICE_CLASS_VEBUS : bits[1] =
 * DEVICE_CLASS_CHARGER : bits[1] = DEVICE_CLASS_INVERTER : bits[1] =
 * DEVICE_CLASS_BATTERY : bits[1] = DEVICE_CLASS_GX_DEVICE : bits[3] =
 * DEVICE_CLASS_RESERVED : bits[1] = DEVICE_FLAGS_ACTIVE : bits[1] =
 * DEVICE_FLAGS_RESERVED1 : bits[1] = DEVICE_FLAGS_SYNC_CHARGING : bits[1] =
 * DEVICE_FLAGS_BMS : bits[1] = DEVICE_FLAGS_GROUP_MEMBER : bits[1] =
 * DEVICE_FLAGS_ACIN_LINK : bits[1] = DEVICE_FLAGS_EXT_CONTROL : bits[1] =
 * DEVICE_FLAGS_RESERVED7 : un8 = Timer : un8 = Group Id (see xml for meanings) :
 * un16 = Request Mask : un32 = DC Input Power [0.01W], 0xFFFFFFFF = Not
 * Available : sn16 = DC Current 1 [0.1A], 0x7FFF = Not Available : sn16 = DC
 * Current 2 [0.1A], 0x7FFF = Not Available : sn16 = DC Current 3 [0.1A], 0x7FFF
 * = Not Available : un8 = Device State (see xml for meanings) : un16 = Charge
 * Voltage Setpoint [0.01V], 0xFFFF = Not Available : un16 = Charge Current Limit
 * [0.1A], 0xFFFF = Not Available : un16 = Discharge Current Limit [0.1A], 0xFFFF
 * = Not Available : un16 = Discharge Voltage Limit [0.01V], 0xFFFF = Not
 * Available : un8 = System Voltage [1V] (see xml for meanings) : un8 = Charger
 * Algorithm Version (see xml for meanings) : un16 = State of Charge [0.01%] :
 * sn32 = Extra Battery Current [0.001A], 0x7FFFFFFF = Not Available : sn32 =
 * Battery Current [0.001A], 0x7FFFFFFF = Not Available : un16 = Battery Voltage
 * [0.01V], 0xFFFF = Not Available : sn16 = Battery Temperature [0.01°C], 0x7FFF
 * = Not Available : bits[5] = DEVICE_FLAGS2_RESERVED : bits[1] =
 * DEVICE_FLAGS2_HAS_ISENSE : bits[1] = DEVICE_FLAGS2_HAS_TSENSE : bits[1] =
 * DEVICE_FLAGS2_HAS_VSENSE}
 */
#define VE_REG_NMT_ENTRY13_A 0xD60D

/**
 * NMT Entry 14 (Part A) {bits[3] = ECU instance : bits[5] = Function instance :
 * un8 = Function : bits[1] = Reserved : bits[7] = Device class (see xml for
 * meanings) : bits[4] = Device class instance : bits[3] = Industry group (see
 * xml for meanings) : bits[1] = Self-configurable address : bits[21] = Identity
 * number : bits[11] = Manufacturer code (see xml for meanings) : bits[1] = NMT
 * ACL Expected : bits[1] = NMT Poll NAD : bits[1] = NMT Retry Request : bits[1]
 * = NMT Instance Changed : bits[1] = NMT Inactive : bits[1] = NMT Disconnected :
 * bits[2] = NMT Retry Counter : un8 = NMT NAD : un8 = NMT Timer : un8 = NMT ACL
 * Timer : un16 = Product Id (see xml for meanings), Note that the ve.direct mppt
 * chargers report this field incorrectly as an un16 with the product id in big-
 * endian notation : bits[1] = DEVICE_CLASS_VEBUS : bits[1] =
 * DEVICE_CLASS_CHARGER : bits[1] = DEVICE_CLASS_INVERTER : bits[1] =
 * DEVICE_CLASS_BATTERY : bits[1] = DEVICE_CLASS_GX_DEVICE : bits[3] =
 * DEVICE_CLASS_RESERVED : bits[1] = DEVICE_FLAGS_ACTIVE : bits[1] =
 * DEVICE_FLAGS_RESERVED1 : bits[1] = DEVICE_FLAGS_SYNC_CHARGING : bits[1] =
 * DEVICE_FLAGS_BMS : bits[1] = DEVICE_FLAGS_GROUP_MEMBER : bits[1] =
 * DEVICE_FLAGS_ACIN_LINK : bits[1] = DEVICE_FLAGS_EXT_CONTROL : bits[1] =
 * DEVICE_FLAGS_RESERVED7 : un8 = Timer : un8 = Group Id (see xml for meanings) :
 * un16 = Request Mask : un32 = DC Input Power [0.01W], 0xFFFFFFFF = Not
 * Available : sn16 = DC Current 1 [0.1A], 0x7FFF = Not Available : sn16 = DC
 * Current 2 [0.1A], 0x7FFF = Not Available : sn16 = DC Current 3 [0.1A], 0x7FFF
 * = Not Available : un8 = Device State (see xml for meanings) : un16 = Charge
 * Voltage Setpoint [0.01V], 0xFFFF = Not Available : un16 = Charge Current Limit
 * [0.1A], 0xFFFF = Not Available : un16 = Discharge Current Limit [0.1A], 0xFFFF
 * = Not Available : un16 = Discharge Voltage Limit [0.01V], 0xFFFF = Not
 * Available : un8 = System Voltage [1V] (see xml for meanings) : un8 = Charger
 * Algorithm Version (see xml for meanings) : un16 = State of Charge [0.01%] :
 * sn32 = Extra Battery Current [0.001A], 0x7FFFFFFF = Not Available : sn32 =
 * Battery Current [0.001A], 0x7FFFFFFF = Not Available : un16 = Battery Voltage
 * [0.01V], 0xFFFF = Not Available : sn16 = Battery Temperature [0.01°C], 0x7FFF
 * = Not Available : bits[5] = DEVICE_FLAGS2_RESERVED : bits[1] =
 * DEVICE_FLAGS2_HAS_ISENSE : bits[1] = DEVICE_FLAGS2_HAS_TSENSE : bits[1] =
 * DEVICE_FLAGS2_HAS_VSENSE}
 */
#define VE_REG_NMT_ENTRY14_A 0xD60E

/**
 * NMT Entry 15 (Part A) {bits[3] = ECU instance : bits[5] = Function instance :
 * un8 = Function : bits[1] = Reserved : bits[7] = Device class (see xml for
 * meanings) : bits[4] = Device class instance : bits[3] = Industry group (see
 * xml for meanings) : bits[1] = Self-configurable address : bits[21] = Identity
 * number : bits[11] = Manufacturer code (see xml for meanings) : bits[1] = NMT
 * ACL Expected : bits[1] = NMT Poll NAD : bits[1] = NMT Retry Request : bits[1]
 * = NMT Instance Changed : bits[1] = NMT Inactive : bits[1] = NMT Disconnected :
 * bits[2] = NMT Retry Counter : un8 = NMT NAD : un8 = NMT Timer : un8 = NMT ACL
 * Timer : un16 = Product Id (see xml for meanings), Note that the ve.direct mppt
 * chargers report this field incorrectly as an un16 with the product id in big-
 * endian notation : bits[1] = DEVICE_CLASS_VEBUS : bits[1] =
 * DEVICE_CLASS_CHARGER : bits[1] = DEVICE_CLASS_INVERTER : bits[1] =
 * DEVICE_CLASS_BATTERY : bits[1] = DEVICE_CLASS_GX_DEVICE : bits[3] =
 * DEVICE_CLASS_RESERVED : bits[1] = DEVICE_FLAGS_ACTIVE : bits[1] =
 * DEVICE_FLAGS_RESERVED1 : bits[1] = DEVICE_FLAGS_SYNC_CHARGING : bits[1] =
 * DEVICE_FLAGS_BMS : bits[1] = DEVICE_FLAGS_GROUP_MEMBER : bits[1] =
 * DEVICE_FLAGS_ACIN_LINK : bits[1] = DEVICE_FLAGS_EXT_CONTROL : bits[1] =
 * DEVICE_FLAGS_RESERVED7 : un8 = Timer : un8 = Group Id (see xml for meanings) :
 * un16 = Request Mask : un32 = DC Input Power [0.01W], 0xFFFFFFFF = Not
 * Available : sn16 = DC Current 1 [0.1A], 0x7FFF = Not Available : sn16 = DC
 * Current 2 [0.1A], 0x7FFF = Not Available : sn16 = DC Current 3 [0.1A], 0x7FFF
 * = Not Available : un8 = Device State (see xml for meanings) : un16 = Charge
 * Voltage Setpoint [0.01V], 0xFFFF = Not Available : un16 = Charge Current Limit
 * [0.1A], 0xFFFF = Not Available : un16 = Discharge Current Limit [0.1A], 0xFFFF
 * = Not Available : un16 = Discharge Voltage Limit [0.01V], 0xFFFF = Not
 * Available : un8 = System Voltage [1V] (see xml for meanings) : un8 = Charger
 * Algorithm Version (see xml for meanings) : un16 = State of Charge [0.01%] :
 * sn32 = Extra Battery Current [0.001A], 0x7FFFFFFF = Not Available : sn32 =
 * Battery Current [0.001A], 0x7FFFFFFF = Not Available : un16 = Battery Voltage
 * [0.01V], 0xFFFF = Not Available : sn16 = Battery Temperature [0.01°C], 0x7FFF
 * = Not Available : bits[5] = DEVICE_FLAGS2_RESERVED : bits[1] =
 * DEVICE_FLAGS2_HAS_ISENSE : bits[1] = DEVICE_FLAGS2_HAS_TSENSE : bits[1] =
 * DEVICE_FLAGS2_HAS_VSENSE}
 */
#define VE_REG_NMT_ENTRY15_A 0xD60F

/**
 * NMT Entry 16 (Part A) {bits[3] = ECU instance : bits[5] = Function instance :
 * un8 = Function : bits[1] = Reserved : bits[7] = Device class (see xml for
 * meanings) : bits[4] = Device class instance : bits[3] = Industry group (see
 * xml for meanings) : bits[1] = Self-configurable address : bits[21] = Identity
 * number : bits[11] = Manufacturer code (see xml for meanings) : bits[1] = NMT
 * ACL Expected : bits[1] = NMT Poll NAD : bits[1] = NMT Retry Request : bits[1]
 * = NMT Instance Changed : bits[1] = NMT Inactive : bits[1] = NMT Disconnected :
 * bits[2] = NMT Retry Counter : un8 = NMT NAD : un8 = NMT Timer : un8 = NMT ACL
 * Timer : un16 = Product Id (see xml for meanings), Note that the ve.direct mppt
 * chargers report this field incorrectly as an un16 with the product id in big-
 * endian notation : bits[1] = DEVICE_CLASS_VEBUS : bits[1] =
 * DEVICE_CLASS_CHARGER : bits[1] = DEVICE_CLASS_INVERTER : bits[1] =
 * DEVICE_CLASS_BATTERY : bits[1] = DEVICE_CLASS_GX_DEVICE : bits[3] =
 * DEVICE_CLASS_RESERVED : bits[1] = DEVICE_FLAGS_ACTIVE : bits[1] =
 * DEVICE_FLAGS_RESERVED1 : bits[1] = DEVICE_FLAGS_SYNC_CHARGING : bits[1] =
 * DEVICE_FLAGS_BMS : bits[1] = DEVICE_FLAGS_GROUP_MEMBER : bits[1] =
 * DEVICE_FLAGS_ACIN_LINK : bits[1] = DEVICE_FLAGS_EXT_CONTROL : bits[1] =
 * DEVICE_FLAGS_RESERVED7 : un8 = Timer : un8 = Group Id (see xml for meanings) :
 * un16 = Request Mask : un32 = DC Input Power [0.01W], 0xFFFFFFFF = Not
 * Available : sn16 = DC Current 1 [0.1A], 0x7FFF = Not Available : sn16 = DC
 * Current 2 [0.1A], 0x7FFF = Not Available : sn16 = DC Current 3 [0.1A], 0x7FFF
 * = Not Available : un8 = Device State (see xml for meanings) : un16 = Charge
 * Voltage Setpoint [0.01V], 0xFFFF = Not Available : un16 = Charge Current Limit
 * [0.1A], 0xFFFF = Not Available : un16 = Discharge Current Limit [0.1A], 0xFFFF
 * = Not Available : un16 = Discharge Voltage Limit [0.01V], 0xFFFF = Not
 * Available : un8 = System Voltage [1V] (see xml for meanings) : un8 = Charger
 * Algorithm Version (see xml for meanings) : un16 = State of Charge [0.01%] :
 * sn32 = Extra Battery Current [0.001A], 0x7FFFFFFF = Not Available : sn32 =
 * Battery Current [0.001A], 0x7FFFFFFF = Not Available : un16 = Battery Voltage
 * [0.01V], 0xFFFF = Not Available : sn16 = Battery Temperature [0.01°C], 0x7FFF
 * = Not Available : bits[5] = DEVICE_FLAGS2_RESERVED : bits[1] =
 * DEVICE_FLAGS2_HAS_ISENSE : bits[1] = DEVICE_FLAGS2_HAS_TSENSE : bits[1] =
 * DEVICE_FLAGS2_HAS_VSENSE}
 */
#define VE_REG_NMT_ENTRY16_A 0xD610

/**
 * NMT Entry 17 (Part A) {bits[3] = ECU instance : bits[5] = Function instance :
 * un8 = Function : bits[1] = Reserved : bits[7] = Device class (see xml for
 * meanings) : bits[4] = Device class instance : bits[3] = Industry group (see
 * xml for meanings) : bits[1] = Self-configurable address : bits[21] = Identity
 * number : bits[11] = Manufacturer code (see xml for meanings) : bits[1] = NMT
 * ACL Expected : bits[1] = NMT Poll NAD : bits[1] = NMT Retry Request : bits[1]
 * = NMT Instance Changed : bits[1] = NMT Inactive : bits[1] = NMT Disconnected :
 * bits[2] = NMT Retry Counter : un8 = NMT NAD : un8 = NMT Timer : un8 = NMT ACL
 * Timer : un16 = Product Id (see xml for meanings), Note that the ve.direct mppt
 * chargers report this field incorrectly as an un16 with the product id in big-
 * endian notation : bits[1] = DEVICE_CLASS_VEBUS : bits[1] =
 * DEVICE_CLASS_CHARGER : bits[1] = DEVICE_CLASS_INVERTER : bits[1] =
 * DEVICE_CLASS_BATTERY : bits[1] = DEVICE_CLASS_GX_DEVICE : bits[3] =
 * DEVICE_CLASS_RESERVED : bits[1] = DEVICE_FLAGS_ACTIVE : bits[1] =
 * DEVICE_FLAGS_RESERVED1 : bits[1] = DEVICE_FLAGS_SYNC_CHARGING : bits[1] =
 * DEVICE_FLAGS_BMS : bits[1] = DEVICE_FLAGS_GROUP_MEMBER : bits[1] =
 * DEVICE_FLAGS_ACIN_LINK : bits[1] = DEVICE_FLAGS_EXT_CONTROL : bits[1] =
 * DEVICE_FLAGS_RESERVED7 : un8 = Timer : un8 = Group Id (see xml for meanings) :
 * un16 = Request Mask : un32 = DC Input Power [0.01W], 0xFFFFFFFF = Not
 * Available : sn16 = DC Current 1 [0.1A], 0x7FFF = Not Available : sn16 = DC
 * Current 2 [0.1A], 0x7FFF = Not Available : sn16 = DC Current 3 [0.1A], 0x7FFF
 * = Not Available : un8 = Device State (see xml for meanings) : un16 = Charge
 * Voltage Setpoint [0.01V], 0xFFFF = Not Available : un16 = Charge Current Limit
 * [0.1A], 0xFFFF = Not Available : un16 = Discharge Current Limit [0.1A], 0xFFFF
 * = Not Available : un16 = Discharge Voltage Limit [0.01V], 0xFFFF = Not
 * Available : un8 = System Voltage [1V] (see xml for meanings) : un8 = Charger
 * Algorithm Version (see xml for meanings) : un16 = State of Charge [0.01%] :
 * sn32 = Extra Battery Current [0.001A], 0x7FFFFFFF = Not Available : sn32 =
 * Battery Current [0.001A], 0x7FFFFFFF = Not Available : un16 = Battery Voltage
 * [0.01V], 0xFFFF = Not Available : sn16 = Battery Temperature [0.01°C], 0x7FFF
 * = Not Available : bits[5] = DEVICE_FLAGS2_RESERVED : bits[1] =
 * DEVICE_FLAGS2_HAS_ISENSE : bits[1] = DEVICE_FLAGS2_HAS_TSENSE : bits[1] =
 * DEVICE_FLAGS2_HAS_VSENSE}
 */
#define VE_REG_NMT_ENTRY17_A 0xD611

/**
 * NMT Entry 18 (Part A) {bits[3] = ECU instance : bits[5] = Function instance :
 * un8 = Function : bits[1] = Reserved : bits[7] = Device class (see xml for
 * meanings) : bits[4] = Device class instance : bits[3] = Industry group (see
 * xml for meanings) : bits[1] = Self-configurable address : bits[21] = Identity
 * number : bits[11] = Manufacturer code (see xml for meanings) : bits[1] = NMT
 * ACL Expected : bits[1] = NMT Poll NAD : bits[1] = NMT Retry Request : bits[1]
 * = NMT Instance Changed : bits[1] = NMT Inactive : bits[1] = NMT Disconnected :
 * bits[2] = NMT Retry Counter : un8 = NMT NAD : un8 = NMT Timer : un8 = NMT ACL
 * Timer : un16 = Product Id (see xml for meanings), Note that the ve.direct mppt
 * chargers report this field incorrectly as an un16 with the product id in big-
 * endian notation : bits[1] = DEVICE_CLASS_VEBUS : bits[1] =
 * DEVICE_CLASS_CHARGER : bits[1] = DEVICE_CLASS_INVERTER : bits[1] =
 * DEVICE_CLASS_BATTERY : bits[1] = DEVICE_CLASS_GX_DEVICE : bits[3] =
 * DEVICE_CLASS_RESERVED : bits[1] = DEVICE_FLAGS_ACTIVE : bits[1] =
 * DEVICE_FLAGS_RESERVED1 : bits[1] = DEVICE_FLAGS_SYNC_CHARGING : bits[1] =
 * DEVICE_FLAGS_BMS : bits[1] = DEVICE_FLAGS_GROUP_MEMBER : bits[1] =
 * DEVICE_FLAGS_ACIN_LINK : bits[1] = DEVICE_FLAGS_EXT_CONTROL : bits[1] =
 * DEVICE_FLAGS_RESERVED7 : un8 = Timer : un8 = Group Id (see xml for meanings) :
 * un16 = Request Mask : un32 = DC Input Power [0.01W], 0xFFFFFFFF = Not
 * Available : sn16 = DC Current 1 [0.1A], 0x7FFF = Not Available : sn16 = DC
 * Current 2 [0.1A], 0x7FFF = Not Available : sn16 = DC Current 3 [0.1A], 0x7FFF
 * = Not Available : un8 = Device State (see xml for meanings) : un16 = Charge
 * Voltage Setpoint [0.01V], 0xFFFF = Not Available : un16 = Charge Current Limit
 * [0.1A], 0xFFFF = Not Available : un16 = Discharge Current Limit [0.1A], 0xFFFF
 * = Not Available : un16 = Discharge Voltage Limit [0.01V], 0xFFFF = Not
 * Available : un8 = System Voltage [1V] (see xml for meanings) : un8 = Charger
 * Algorithm Version (see xml for meanings) : un16 = State of Charge [0.01%] :
 * sn32 = Extra Battery Current [0.001A], 0x7FFFFFFF = Not Available : sn32 =
 * Battery Current [0.001A], 0x7FFFFFFF = Not Available : un16 = Battery Voltage
 * [0.01V], 0xFFFF = Not Available : sn16 = Battery Temperature [0.01°C], 0x7FFF
 * = Not Available : bits[5] = DEVICE_FLAGS2_RESERVED : bits[1] =
 * DEVICE_FLAGS2_HAS_ISENSE : bits[1] = DEVICE_FLAGS2_HAS_TSENSE : bits[1] =
 * DEVICE_FLAGS2_HAS_VSENSE}
 */
#define VE_REG_NMT_ENTRY18_A 0xD612

/**
 * NMT Entry 19 (Part A) {bits[3] = ECU instance : bits[5] = Function instance :
 * un8 = Function : bits[1] = Reserved : bits[7] = Device class (see xml for
 * meanings) : bits[4] = Device class instance : bits[3] = Industry group (see
 * xml for meanings) : bits[1] = Self-configurable address : bits[21] = Identity
 * number : bits[11] = Manufacturer code (see xml for meanings) : bits[1] = NMT
 * ACL Expected : bits[1] = NMT Poll NAD : bits[1] = NMT Retry Request : bits[1]
 * = NMT Instance Changed : bits[1] = NMT Inactive : bits[1] = NMT Disconnected :
 * bits[2] = NMT Retry Counter : un8 = NMT NAD : un8 = NMT Timer : un8 = NMT ACL
 * Timer : un16 = Product Id (see xml for meanings), Note that the ve.direct mppt
 * chargers report this field incorrectly as an un16 with the product id in big-
 * endian notation : bits[1] = DEVICE_CLASS_VEBUS : bits[1] =
 * DEVICE_CLASS_CHARGER : bits[1] = DEVICE_CLASS_INVERTER : bits[1] =
 * DEVICE_CLASS_BATTERY : bits[1] = DEVICE_CLASS_GX_DEVICE : bits[3] =
 * DEVICE_CLASS_RESERVED : bits[1] = DEVICE_FLAGS_ACTIVE : bits[1] =
 * DEVICE_FLAGS_RESERVED1 : bits[1] = DEVICE_FLAGS_SYNC_CHARGING : bits[1] =
 * DEVICE_FLAGS_BMS : bits[1] = DEVICE_FLAGS_GROUP_MEMBER : bits[1] =
 * DEVICE_FLAGS_ACIN_LINK : bits[1] = DEVICE_FLAGS_EXT_CONTROL : bits[1] =
 * DEVICE_FLAGS_RESERVED7 : un8 = Timer : un8 = Group Id (see xml for meanings) :
 * un16 = Request Mask : un32 = DC Input Power [0.01W], 0xFFFFFFFF = Not
 * Available : sn16 = DC Current 1 [0.1A], 0x7FFF = Not Available : sn16 = DC
 * Current 2 [0.1A], 0x7FFF = Not Available : sn16 = DC Current 3 [0.1A], 0x7FFF
 * = Not Available : un8 = Device State (see xml for meanings) : un16 = Charge
 * Voltage Setpoint [0.01V], 0xFFFF = Not Available : un16 = Charge Current Limit
 * [0.1A], 0xFFFF = Not Available : un16 = Discharge Current Limit [0.1A], 0xFFFF
 * = Not Available : un16 = Discharge Voltage Limit [0.01V], 0xFFFF = Not
 * Available : un8 = System Voltage [1V] (see xml for meanings) : un8 = Charger
 * Algorithm Version (see xml for meanings) : un16 = State of Charge [0.01%] :
 * sn32 = Extra Battery Current [0.001A], 0x7FFFFFFF = Not Available : sn32 =
 * Battery Current [0.001A], 0x7FFFFFFF = Not Available : un16 = Battery Voltage
 * [0.01V], 0xFFFF = Not Available : sn16 = Battery Temperature [0.01°C], 0x7FFF
 * = Not Available : bits[5] = DEVICE_FLAGS2_RESERVED : bits[1] =
 * DEVICE_FLAGS2_HAS_ISENSE : bits[1] = DEVICE_FLAGS2_HAS_TSENSE : bits[1] =
 * DEVICE_FLAGS2_HAS_VSENSE}
 */
#define VE_REG_NMT_ENTRY19_A 0xD613

/**
 * NMT Entry 20 (Part A) {bits[3] = ECU instance : bits[5] = Function instance :
 * un8 = Function : bits[1] = Reserved : bits[7] = Device class (see xml for
 * meanings) : bits[4] = Device class instance : bits[3] = Industry group (see
 * xml for meanings) : bits[1] = Self-configurable address : bits[21] = Identity
 * number : bits[11] = Manufacturer code (see xml for meanings) : bits[1] = NMT
 * ACL Expected : bits[1] = NMT Poll NAD : bits[1] = NMT Retry Request : bits[1]
 * = NMT Instance Changed : bits[1] = NMT Inactive : bits[1] = NMT Disconnected :
 * bits[2] = NMT Retry Counter : un8 = NMT NAD : un8 = NMT Timer : un8 = NMT ACL
 * Timer : un16 = Product Id (see xml for meanings), Note that the ve.direct mppt
 * chargers report this field incorrectly as an un16 with the product id in big-
 * endian notation : bits[1] = DEVICE_CLASS_VEBUS : bits[1] =
 * DEVICE_CLASS_CHARGER : bits[1] = DEVICE_CLASS_INVERTER : bits[1] =
 * DEVICE_CLASS_BATTERY : bits[1] = DEVICE_CLASS_GX_DEVICE : bits[3] =
 * DEVICE_CLASS_RESERVED : bits[1] = DEVICE_FLAGS_ACTIVE : bits[1] =
 * DEVICE_FLAGS_RESERVED1 : bits[1] = DEVICE_FLAGS_SYNC_CHARGING : bits[1] =
 * DEVICE_FLAGS_BMS : bits[1] = DEVICE_FLAGS_GROUP_MEMBER : bits[1] =
 * DEVICE_FLAGS_ACIN_LINK : bits[1] = DEVICE_FLAGS_EXT_CONTROL : bits[1] =
 * DEVICE_FLAGS_RESERVED7 : un8 = Timer : un8 = Group Id (see xml for meanings) :
 * un16 = Request Mask : un32 = DC Input Power [0.01W], 0xFFFFFFFF = Not
 * Available : sn16 = DC Current 1 [0.1A], 0x7FFF = Not Available : sn16 = DC
 * Current 2 [0.1A], 0x7FFF = Not Available : sn16 = DC Current 3 [0.1A], 0x7FFF
 * = Not Available : un8 = Device State (see xml for meanings) : un16 = Charge
 * Voltage Setpoint [0.01V], 0xFFFF = Not Available : un16 = Charge Current Limit
 * [0.1A], 0xFFFF = Not Available : un16 = Discharge Current Limit [0.1A], 0xFFFF
 * = Not Available : un16 = Discharge Voltage Limit [0.01V], 0xFFFF = Not
 * Available : un8 = System Voltage [1V] (see xml for meanings) : un8 = Charger
 * Algorithm Version (see xml for meanings) : un16 = State of Charge [0.01%] :
 * sn32 = Extra Battery Current [0.001A], 0x7FFFFFFF = Not Available : sn32 =
 * Battery Current [0.001A], 0x7FFFFFFF = Not Available : un16 = Battery Voltage
 * [0.01V], 0xFFFF = Not Available : sn16 = Battery Temperature [0.01°C], 0x7FFF
 * = Not Available : bits[5] = DEVICE_FLAGS2_RESERVED : bits[1] =
 * DEVICE_FLAGS2_HAS_ISENSE : bits[1] = DEVICE_FLAGS2_HAS_TSENSE : bits[1] =
 * DEVICE_FLAGS2_HAS_VSENSE}
 */
#define VE_REG_NMT_ENTRY20_A 0xD614

/**
 * NMT Entry 21 (Part A) {bits[3] = ECU instance : bits[5] = Function instance :
 * un8 = Function : bits[1] = Reserved : bits[7] = Device class (see xml for
 * meanings) : bits[4] = Device class instance : bits[3] = Industry group (see
 * xml for meanings) : bits[1] = Self-configurable address : bits[21] = Identity
 * number : bits[11] = Manufacturer code (see xml for meanings) : bits[1] = NMT
 * ACL Expected : bits[1] = NMT Poll NAD : bits[1] = NMT Retry Request : bits[1]
 * = NMT Instance Changed : bits[1] = NMT Inactive : bits[1] = NMT Disconnected :
 * bits[2] = NMT Retry Counter : un8 = NMT NAD : un8 = NMT Timer : un8 = NMT ACL
 * Timer : un16 = Product Id (see xml for meanings), Note that the ve.direct mppt
 * chargers report this field incorrectly as an un16 with the product id in big-
 * endian notation : bits[1] = DEVICE_CLASS_VEBUS : bits[1] =
 * DEVICE_CLASS_CHARGER : bits[1] = DEVICE_CLASS_INVERTER : bits[1] =
 * DEVICE_CLASS_BATTERY : bits[1] = DEVICE_CLASS_GX_DEVICE : bits[3] =
 * DEVICE_CLASS_RESERVED : bits[1] = DEVICE_FLAGS_ACTIVE : bits[1] =
 * DEVICE_FLAGS_RESERVED1 : bits[1] = DEVICE_FLAGS_SYNC_CHARGING : bits[1] =
 * DEVICE_FLAGS_BMS : bits[1] = DEVICE_FLAGS_GROUP_MEMBER : bits[1] =
 * DEVICE_FLAGS_ACIN_LINK : bits[1] = DEVICE_FLAGS_EXT_CONTROL : bits[1] =
 * DEVICE_FLAGS_RESERVED7 : un8 = Timer : un8 = Group Id (see xml for meanings) :
 * un16 = Request Mask : un32 = DC Input Power [0.01W], 0xFFFFFFFF = Not
 * Available : sn16 = DC Current 1 [0.1A], 0x7FFF = Not Available : sn16 = DC
 * Current 2 [0.1A], 0x7FFF = Not Available : sn16 = DC Current 3 [0.1A], 0x7FFF
 * = Not Available : un8 = Device State (see xml for meanings) : un16 = Charge
 * Voltage Setpoint [0.01V], 0xFFFF = Not Available : un16 = Charge Current Limit
 * [0.1A], 0xFFFF = Not Available : un16 = Discharge Current Limit [0.1A], 0xFFFF
 * = Not Available : un16 = Discharge Voltage Limit [0.01V], 0xFFFF = Not
 * Available : un8 = System Voltage [1V] (see xml for meanings) : un8 = Charger
 * Algorithm Version (see xml for meanings) : un16 = State of Charge [0.01%] :
 * sn32 = Extra Battery Current [0.001A], 0x7FFFFFFF = Not Available : sn32 =
 * Battery Current [0.001A], 0x7FFFFFFF = Not Available : un16 = Battery Voltage
 * [0.01V], 0xFFFF = Not Available : sn16 = Battery Temperature [0.01°C], 0x7FFF
 * = Not Available : bits[5] = DEVICE_FLAGS2_RESERVED : bits[1] =
 * DEVICE_FLAGS2_HAS_ISENSE : bits[1] = DEVICE_FLAGS2_HAS_TSENSE : bits[1] =
 * DEVICE_FLAGS2_HAS_VSENSE}
 */
#define VE_REG_NMT_ENTRY21_A 0xD615

/**
 * NMT Entry 22 (Part A) {bits[3] = ECU instance : bits[5] = Function instance :
 * un8 = Function : bits[1] = Reserved : bits[7] = Device class (see xml for
 * meanings) : bits[4] = Device class instance : bits[3] = Industry group (see
 * xml for meanings) : bits[1] = Self-configurable address : bits[21] = Identity
 * number : bits[11] = Manufacturer code (see xml for meanings) : bits[1] = NMT
 * ACL Expected : bits[1] = NMT Poll NAD : bits[1] = NMT Retry Request : bits[1]
 * = NMT Instance Changed : bits[1] = NMT Inactive : bits[1] = NMT Disconnected :
 * bits[2] = NMT Retry Counter : un8 = NMT NAD : un8 = NMT Timer : un8 = NMT ACL
 * Timer : un16 = Product Id (see xml for meanings), Note that the ve.direct mppt
 * chargers report this field incorrectly as an un16 with the product id in big-
 * endian notation : bits[1] = DEVICE_CLASS_VEBUS : bits[1] =
 * DEVICE_CLASS_CHARGER : bits[1] = DEVICE_CLASS_INVERTER : bits[1] =
 * DEVICE_CLASS_BATTERY : bits[1] = DEVICE_CLASS_GX_DEVICE : bits[3] =
 * DEVICE_CLASS_RESERVED : bits[1] = DEVICE_FLAGS_ACTIVE : bits[1] =
 * DEVICE_FLAGS_RESERVED1 : bits[1] = DEVICE_FLAGS_SYNC_CHARGING : bits[1] =
 * DEVICE_FLAGS_BMS : bits[1] = DEVICE_FLAGS_GROUP_MEMBER : bits[1] =
 * DEVICE_FLAGS_ACIN_LINK : bits[1] = DEVICE_FLAGS_EXT_CONTROL : bits[1] =
 * DEVICE_FLAGS_RESERVED7 : un8 = Timer : un8 = Group Id (see xml for meanings) :
 * un16 = Request Mask : un32 = DC Input Power [0.01W], 0xFFFFFFFF = Not
 * Available : sn16 = DC Current 1 [0.1A], 0x7FFF = Not Available : sn16 = DC
 * Current 2 [0.1A], 0x7FFF = Not Available : sn16 = DC Current 3 [0.1A], 0x7FFF
 * = Not Available : un8 = Device State (see xml for meanings) : un16 = Charge
 * Voltage Setpoint [0.01V], 0xFFFF = Not Available : un16 = Charge Current Limit
 * [0.1A], 0xFFFF = Not Available : un16 = Discharge Current Limit [0.1A], 0xFFFF
 * = Not Available : un16 = Discharge Voltage Limit [0.01V], 0xFFFF = Not
 * Available : un8 = System Voltage [1V] (see xml for meanings) : un8 = Charger
 * Algorithm Version (see xml for meanings) : un16 = State of Charge [0.01%] :
 * sn32 = Extra Battery Current [0.001A], 0x7FFFFFFF = Not Available : sn32 =
 * Battery Current [0.001A], 0x7FFFFFFF = Not Available : un16 = Battery Voltage
 * [0.01V], 0xFFFF = Not Available : sn16 = Battery Temperature [0.01°C], 0x7FFF
 * = Not Available : bits[5] = DEVICE_FLAGS2_RESERVED : bits[1] =
 * DEVICE_FLAGS2_HAS_ISENSE : bits[1] = DEVICE_FLAGS2_HAS_TSENSE : bits[1] =
 * DEVICE_FLAGS2_HAS_VSENSE}
 */
#define VE_REG_NMT_ENTRY22_A 0xD616

/**
 * NMT Entry 23 (Part A) {bits[3] = ECU instance : bits[5] = Function instance :
 * un8 = Function : bits[1] = Reserved : bits[7] = Device class (see xml for
 * meanings) : bits[4] = Device class instance : bits[3] = Industry group (see
 * xml for meanings) : bits[1] = Self-configurable address : bits[21] = Identity
 * number : bits[11] = Manufacturer code (see xml for meanings) : bits[1] = NMT
 * ACL Expected : bits[1] = NMT Poll NAD : bits[1] = NMT Retry Request : bits[1]
 * = NMT Instance Changed : bits[1] = NMT Inactive : bits[1] = NMT Disconnected :
 * bits[2] = NMT Retry Counter : un8 = NMT NAD : un8 = NMT Timer : un8 = NMT ACL
 * Timer : un16 = Product Id (see xml for meanings), Note that the ve.direct mppt
 * chargers report this field incorrectly as an un16 with the product id in big-
 * endian notation : bits[1] = DEVICE_CLASS_VEBUS : bits[1] =
 * DEVICE_CLASS_CHARGER : bits[1] = DEVICE_CLASS_INVERTER : bits[1] =
 * DEVICE_CLASS_BATTERY : bits[1] = DEVICE_CLASS_GX_DEVICE : bits[3] =
 * DEVICE_CLASS_RESERVED : bits[1] = DEVICE_FLAGS_ACTIVE : bits[1] =
 * DEVICE_FLAGS_RESERVED1 : bits[1] = DEVICE_FLAGS_SYNC_CHARGING : bits[1] =
 * DEVICE_FLAGS_BMS : bits[1] = DEVICE_FLAGS_GROUP_MEMBER : bits[1] =
 * DEVICE_FLAGS_ACIN_LINK : bits[1] = DEVICE_FLAGS_EXT_CONTROL : bits[1] =
 * DEVICE_FLAGS_RESERVED7 : un8 = Timer : un8 = Group Id (see xml for meanings) :
 * un16 = Request Mask : un32 = DC Input Power [0.01W], 0xFFFFFFFF = Not
 * Available : sn16 = DC Current 1 [0.1A], 0x7FFF = Not Available : sn16 = DC
 * Current 2 [0.1A], 0x7FFF = Not Available : sn16 = DC Current 3 [0.1A], 0x7FFF
 * = Not Available : un8 = Device State (see xml for meanings) : un16 = Charge
 * Voltage Setpoint [0.01V], 0xFFFF = Not Available : un16 = Charge Current Limit
 * [0.1A], 0xFFFF = Not Available : un16 = Discharge Current Limit [0.1A], 0xFFFF
 * = Not Available : un16 = Discharge Voltage Limit [0.01V], 0xFFFF = Not
 * Available : un8 = System Voltage [1V] (see xml for meanings) : un8 = Charger
 * Algorithm Version (see xml for meanings) : un16 = State of Charge [0.01%] :
 * sn32 = Extra Battery Current [0.001A], 0x7FFFFFFF = Not Available : sn32 =
 * Battery Current [0.001A], 0x7FFFFFFF = Not Available : un16 = Battery Voltage
 * [0.01V], 0xFFFF = Not Available : sn16 = Battery Temperature [0.01°C], 0x7FFF
 * = Not Available : bits[5] = DEVICE_FLAGS2_RESERVED : bits[1] =
 * DEVICE_FLAGS2_HAS_ISENSE : bits[1] = DEVICE_FLAGS2_HAS_TSENSE : bits[1] =
 * DEVICE_FLAGS2_HAS_VSENSE}
 */
#define VE_REG_NMT_ENTRY23_A 0xD617

/**
 * NMT Entry 24 (Part A) {bits[3] = ECU instance : bits[5] = Function instance :
 * un8 = Function : bits[1] = Reserved : bits[7] = Device class (see xml for
 * meanings) : bits[4] = Device class instance : bits[3] = Industry group (see
 * xml for meanings) : bits[1] = Self-configurable address : bits[21] = Identity
 * number : bits[11] = Manufacturer code (see xml for meanings) : bits[1] = NMT
 * ACL Expected : bits[1] = NMT Poll NAD : bits[1] = NMT Retry Request : bits[1]
 * = NMT Instance Changed : bits[1] = NMT Inactive : bits[1] = NMT Disconnected :
 * bits[2] = NMT Retry Counter : un8 = NMT NAD : un8 = NMT Timer : un8 = NMT ACL
 * Timer : un16 = Product Id (see xml for meanings), Note that the ve.direct mppt
 * chargers report this field incorrectly as an un16 with the product id in big-
 * endian notation : bits[1] = DEVICE_CLASS_VEBUS : bits[1] =
 * DEVICE_CLASS_CHARGER : bits[1] = DEVICE_CLASS_INVERTER : bits[1] =
 * DEVICE_CLASS_BATTERY : bits[1] = DEVICE_CLASS_GX_DEVICE : bits[3] =
 * DEVICE_CLASS_RESERVED : bits[1] = DEVICE_FLAGS_ACTIVE : bits[1] =
 * DEVICE_FLAGS_RESERVED1 : bits[1] = DEVICE_FLAGS_SYNC_CHARGING : bits[1] =
 * DEVICE_FLAGS_BMS : bits[1] = DEVICE_FLAGS_GROUP_MEMBER : bits[1] =
 * DEVICE_FLAGS_ACIN_LINK : bits[1] = DEVICE_FLAGS_EXT_CONTROL : bits[1] =
 * DEVICE_FLAGS_RESERVED7 : un8 = Timer : un8 = Group Id (see xml for meanings) :
 * un16 = Request Mask : un32 = DC Input Power [0.01W], 0xFFFFFFFF = Not
 * Available : sn16 = DC Current 1 [0.1A], 0x7FFF = Not Available : sn16 = DC
 * Current 2 [0.1A], 0x7FFF = Not Available : sn16 = DC Current 3 [0.1A], 0x7FFF
 * = Not Available : un8 = Device State (see xml for meanings) : un16 = Charge
 * Voltage Setpoint [0.01V], 0xFFFF = Not Available : un16 = Charge Current Limit
 * [0.1A], 0xFFFF = Not Available : un16 = Discharge Current Limit [0.1A], 0xFFFF
 * = Not Available : un16 = Discharge Voltage Limit [0.01V], 0xFFFF = Not
 * Available : un8 = System Voltage [1V] (see xml for meanings) : un8 = Charger
 * Algorithm Version (see xml for meanings) : un16 = State of Charge [0.01%] :
 * sn32 = Extra Battery Current [0.001A], 0x7FFFFFFF = Not Available : sn32 =
 * Battery Current [0.001A], 0x7FFFFFFF = Not Available : un16 = Battery Voltage
 * [0.01V], 0xFFFF = Not Available : sn16 = Battery Temperature [0.01°C], 0x7FFF
 * = Not Available : bits[5] = DEVICE_FLAGS2_RESERVED : bits[1] =
 * DEVICE_FLAGS2_HAS_ISENSE : bits[1] = DEVICE_FLAGS2_HAS_TSENSE : bits[1] =
 * DEVICE_FLAGS2_HAS_VSENSE}
 */
#define VE_REG_NMT_ENTRY24_A 0xD618

/**
 * NMT Entry 25 (Part A) {bits[3] = ECU instance : bits[5] = Function instance :
 * un8 = Function : bits[1] = Reserved : bits[7] = Device class (see xml for
 * meanings) : bits[4] = Device class instance : bits[3] = Industry group (see
 * xml for meanings) : bits[1] = Self-configurable address : bits[21] = Identity
 * number : bits[11] = Manufacturer code (see xml for meanings) : bits[1] = NMT
 * ACL Expected : bits[1] = NMT Poll NAD : bits[1] = NMT Retry Request : bits[1]
 * = NMT Instance Changed : bits[1] = NMT Inactive : bits[1] = NMT Disconnected :
 * bits[2] = NMT Retry Counter : un8 = NMT NAD : un8 = NMT Timer : un8 = NMT ACL
 * Timer : un16 = Product Id (see xml for meanings), Note that the ve.direct mppt
 * chargers report this field incorrectly as an un16 with the product id in big-
 * endian notation : bits[1] = DEVICE_CLASS_VEBUS : bits[1] =
 * DEVICE_CLASS_CHARGER : bits[1] = DEVICE_CLASS_INVERTER : bits[1] =
 * DEVICE_CLASS_BATTERY : bits[1] = DEVICE_CLASS_GX_DEVICE : bits[3] =
 * DEVICE_CLASS_RESERVED : bits[1] = DEVICE_FLAGS_ACTIVE : bits[1] =
 * DEVICE_FLAGS_RESERVED1 : bits[1] = DEVICE_FLAGS_SYNC_CHARGING : bits[1] =
 * DEVICE_FLAGS_BMS : bits[1] = DEVICE_FLAGS_GROUP_MEMBER : bits[1] =
 * DEVICE_FLAGS_ACIN_LINK : bits[1] = DEVICE_FLAGS_EXT_CONTROL : bits[1] =
 * DEVICE_FLAGS_RESERVED7 : un8 = Timer : un8 = Group Id (see xml for meanings) :
 * un16 = Request Mask : un32 = DC Input Power [0.01W], 0xFFFFFFFF = Not
 * Available : sn16 = DC Current 1 [0.1A], 0x7FFF = Not Available : sn16 = DC
 * Current 2 [0.1A], 0x7FFF = Not Available : sn16 = DC Current 3 [0.1A], 0x7FFF
 * = Not Available : un8 = Device State (see xml for meanings) : un16 = Charge
 * Voltage Setpoint [0.01V], 0xFFFF = Not Available : un16 = Charge Current Limit
 * [0.1A], 0xFFFF = Not Available : un16 = Discharge Current Limit [0.1A], 0xFFFF
 * = Not Available : un16 = Discharge Voltage Limit [0.01V], 0xFFFF = Not
 * Available : un8 = System Voltage [1V] (see xml for meanings) : un8 = Charger
 * Algorithm Version (see xml for meanings) : un16 = State of Charge [0.01%] :
 * sn32 = Extra Battery Current [0.001A], 0x7FFFFFFF = Not Available : sn32 =
 * Battery Current [0.001A], 0x7FFFFFFF = Not Available : un16 = Battery Voltage
 * [0.01V], 0xFFFF = Not Available : sn16 = Battery Temperature [0.01°C], 0x7FFF
 * = Not Available : bits[5] = DEVICE_FLAGS2_RESERVED : bits[1] =
 * DEVICE_FLAGS2_HAS_ISENSE : bits[1] = DEVICE_FLAGS2_HAS_TSENSE : bits[1] =
 * DEVICE_FLAGS2_HAS_VSENSE}
 */
#define VE_REG_NMT_ENTRY25_A 0xD619

/**
 * NMT Entry 26 (Part A) {bits[3] = ECU instance : bits[5] = Function instance :
 * un8 = Function : bits[1] = Reserved : bits[7] = Device class (see xml for
 * meanings) : bits[4] = Device class instance : bits[3] = Industry group (see
 * xml for meanings) : bits[1] = Self-configurable address : bits[21] = Identity
 * number : bits[11] = Manufacturer code (see xml for meanings) : bits[1] = NMT
 * ACL Expected : bits[1] = NMT Poll NAD : bits[1] = NMT Retry Request : bits[1]
 * = NMT Instance Changed : bits[1] = NMT Inactive : bits[1] = NMT Disconnected :
 * bits[2] = NMT Retry Counter : un8 = NMT NAD : un8 = NMT Timer : un8 = NMT ACL
 * Timer : un16 = Product Id (see xml for meanings), Note that the ve.direct mppt
 * chargers report this field incorrectly as an un16 with the product id in big-
 * endian notation : bits[1] = DEVICE_CLASS_VEBUS : bits[1] =
 * DEVICE_CLASS_CHARGER : bits[1] = DEVICE_CLASS_INVERTER : bits[1] =
 * DEVICE_CLASS_BATTERY : bits[1] = DEVICE_CLASS_GX_DEVICE : bits[3] =
 * DEVICE_CLASS_RESERVED : bits[1] = DEVICE_FLAGS_ACTIVE : bits[1] =
 * DEVICE_FLAGS_RESERVED1 : bits[1] = DEVICE_FLAGS_SYNC_CHARGING : bits[1] =
 * DEVICE_FLAGS_BMS : bits[1] = DEVICE_FLAGS_GROUP_MEMBER : bits[1] =
 * DEVICE_FLAGS_ACIN_LINK : bits[1] = DEVICE_FLAGS_EXT_CONTROL : bits[1] =
 * DEVICE_FLAGS_RESERVED7 : un8 = Timer : un8 = Group Id (see xml for meanings) :
 * un16 = Request Mask : un32 = DC Input Power [0.01W], 0xFFFFFFFF = Not
 * Available : sn16 = DC Current 1 [0.1A], 0x7FFF = Not Available : sn16 = DC
 * Current 2 [0.1A], 0x7FFF = Not Available : sn16 = DC Current 3 [0.1A], 0x7FFF
 * = Not Available : un8 = Device State (see xml for meanings) : un16 = Charge
 * Voltage Setpoint [0.01V], 0xFFFF = Not Available : un16 = Charge Current Limit
 * [0.1A], 0xFFFF = Not Available : un16 = Discharge Current Limit [0.1A], 0xFFFF
 * = Not Available : un16 = Discharge Voltage Limit [0.01V], 0xFFFF = Not
 * Available : un8 = System Voltage [1V] (see xml for meanings) : un8 = Charger
 * Algorithm Version (see xml for meanings) : un16 = State of Charge [0.01%] :
 * sn32 = Extra Battery Current [0.001A], 0x7FFFFFFF = Not Available : sn32 =
 * Battery Current [0.001A], 0x7FFFFFFF = Not Available : un16 = Battery Voltage
 * [0.01V], 0xFFFF = Not Available : sn16 = Battery Temperature [0.01°C], 0x7FFF
 * = Not Available : bits[5] = DEVICE_FLAGS2_RESERVED : bits[1] =
 * DEVICE_FLAGS2_HAS_ISENSE : bits[1] = DEVICE_FLAGS2_HAS_TSENSE : bits[1] =
 * DEVICE_FLAGS2_HAS_VSENSE}
 */
#define VE_REG_NMT_ENTRY26_A 0xD61A

/**
 * NMT Entry 27 (Part A) {bits[3] = ECU instance : bits[5] = Function instance :
 * un8 = Function : bits[1] = Reserved : bits[7] = Device class (see xml for
 * meanings) : bits[4] = Device class instance : bits[3] = Industry group (see
 * xml for meanings) : bits[1] = Self-configurable address : bits[21] = Identity
 * number : bits[11] = Manufacturer code (see xml for meanings) : bits[1] = NMT
 * ACL Expected : bits[1] = NMT Poll NAD : bits[1] = NMT Retry Request : bits[1]
 * = NMT Instance Changed : bits[1] = NMT Inactive : bits[1] = NMT Disconnected :
 * bits[2] = NMT Retry Counter : un8 = NMT NAD : un8 = NMT Timer : un8 = NMT ACL
 * Timer : un16 = Product Id (see xml for meanings), Note that the ve.direct mppt
 * chargers report this field incorrectly as an un16 with the product id in big-
 * endian notation : bits[1] = DEVICE_CLASS_VEBUS : bits[1] =
 * DEVICE_CLASS_CHARGER : bits[1] = DEVICE_CLASS_INVERTER : bits[1] =
 * DEVICE_CLASS_BATTERY : bits[1] = DEVICE_CLASS_GX_DEVICE : bits[3] =
 * DEVICE_CLASS_RESERVED : bits[1] = DEVICE_FLAGS_ACTIVE : bits[1] =
 * DEVICE_FLAGS_RESERVED1 : bits[1] = DEVICE_FLAGS_SYNC_CHARGING : bits[1] =
 * DEVICE_FLAGS_BMS : bits[1] = DEVICE_FLAGS_GROUP_MEMBER : bits[1] =
 * DEVICE_FLAGS_ACIN_LINK : bits[1] = DEVICE_FLAGS_EXT_CONTROL : bits[1] =
 * DEVICE_FLAGS_RESERVED7 : un8 = Timer : un8 = Group Id (see xml for meanings) :
 * un16 = Request Mask : un32 = DC Input Power [0.01W], 0xFFFFFFFF = Not
 * Available : sn16 = DC Current 1 [0.1A], 0x7FFF = Not Available : sn16 = DC
 * Current 2 [0.1A], 0x7FFF = Not Available : sn16 = DC Current 3 [0.1A], 0x7FFF
 * = Not Available : un8 = Device State (see xml for meanings) : un16 = Charge
 * Voltage Setpoint [0.01V], 0xFFFF = Not Available : un16 = Charge Current Limit
 * [0.1A], 0xFFFF = Not Available : un16 = Discharge Current Limit [0.1A], 0xFFFF
 * = Not Available : un16 = Discharge Voltage Limit [0.01V], 0xFFFF = Not
 * Available : un8 = System Voltage [1V] (see xml for meanings) : un8 = Charger
 * Algorithm Version (see xml for meanings) : un16 = State of Charge [0.01%] :
 * sn32 = Extra Battery Current [0.001A], 0x7FFFFFFF = Not Available : sn32 =
 * Battery Current [0.001A], 0x7FFFFFFF = Not Available : un16 = Battery Voltage
 * [0.01V], 0xFFFF = Not Available : sn16 = Battery Temperature [0.01°C], 0x7FFF
 * = Not Available : bits[5] = DEVICE_FLAGS2_RESERVED : bits[1] =
 * DEVICE_FLAGS2_HAS_ISENSE : bits[1] = DEVICE_FLAGS2_HAS_TSENSE : bits[1] =
 * DEVICE_FLAGS2_HAS_VSENSE}
 */
#define VE_REG_NMT_ENTRY27_A 0xD61B

/**
 * NMT Entry 28 (Part A) {bits[3] = ECU instance : bits[5] = Function instance :
 * un8 = Function : bits[1] = Reserved : bits[7] = Device class (see xml for
 * meanings) : bits[4] = Device class instance : bits[3] = Industry group (see
 * xml for meanings) : bits[1] = Self-configurable address : bits[21] = Identity
 * number : bits[11] = Manufacturer code (see xml for meanings) : bits[1] = NMT
 * ACL Expected : bits[1] = NMT Poll NAD : bits[1] = NMT Retry Request : bits[1]
 * = NMT Instance Changed : bits[1] = NMT Inactive : bits[1] = NMT Disconnected :
 * bits[2] = NMT Retry Counter : un8 = NMT NAD : un8 = NMT Timer : un8 = NMT ACL
 * Timer : un16 = Product Id (see xml for meanings), Note that the ve.direct mppt
 * chargers report this field incorrectly as an un16 with the product id in big-
 * endian notation : bits[1] = DEVICE_CLASS_VEBUS : bits[1] =
 * DEVICE_CLASS_CHARGER : bits[1] = DEVICE_CLASS_INVERTER : bits[1] =
 * DEVICE_CLASS_BATTERY : bits[1] = DEVICE_CLASS_GX_DEVICE : bits[3] =
 * DEVICE_CLASS_RESERVED : bits[1] = DEVICE_FLAGS_ACTIVE : bits[1] =
 * DEVICE_FLAGS_RESERVED1 : bits[1] = DEVICE_FLAGS_SYNC_CHARGING : bits[1] =
 * DEVICE_FLAGS_BMS : bits[1] = DEVICE_FLAGS_GROUP_MEMBER : bits[1] =
 * DEVICE_FLAGS_ACIN_LINK : bits[1] = DEVICE_FLAGS_EXT_CONTROL : bits[1] =
 * DEVICE_FLAGS_RESERVED7 : un8 = Timer : un8 = Group Id (see xml for meanings) :
 * un16 = Request Mask : un32 = DC Input Power [0.01W], 0xFFFFFFFF = Not
 * Available : sn16 = DC Current 1 [0.1A], 0x7FFF = Not Available : sn16 = DC
 * Current 2 [0.1A], 0x7FFF = Not Available : sn16 = DC Current 3 [0.1A], 0x7FFF
 * = Not Available : un8 = Device State (see xml for meanings) : un16 = Charge
 * Voltage Setpoint [0.01V], 0xFFFF = Not Available : un16 = Charge Current Limit
 * [0.1A], 0xFFFF = Not Available : un16 = Discharge Current Limit [0.1A], 0xFFFF
 * = Not Available : un16 = Discharge Voltage Limit [0.01V], 0xFFFF = Not
 * Available : un8 = System Voltage [1V] (see xml for meanings) : un8 = Charger
 * Algorithm Version (see xml for meanings) : un16 = State of Charge [0.01%] :
 * sn32 = Extra Battery Current [0.001A], 0x7FFFFFFF = Not Available : sn32 =
 * Battery Current [0.001A], 0x7FFFFFFF = Not Available : un16 = Battery Voltage
 * [0.01V], 0xFFFF = Not Available : sn16 = Battery Temperature [0.01°C], 0x7FFF
 * = Not Available : bits[5] = DEVICE_FLAGS2_RESERVED : bits[1] =
 * DEVICE_FLAGS2_HAS_ISENSE : bits[1] = DEVICE_FLAGS2_HAS_TSENSE : bits[1] =
 * DEVICE_FLAGS2_HAS_VSENSE}
 */
#define VE_REG_NMT_ENTRY28_A 0xD61C

/**
 * NMT Entry 29 (Part A) {bits[3] = ECU instance : bits[5] = Function instance :
 * un8 = Function : bits[1] = Reserved : bits[7] = Device class (see xml for
 * meanings) : bits[4] = Device class instance : bits[3] = Industry group (see
 * xml for meanings) : bits[1] = Self-configurable address : bits[21] = Identity
 * number : bits[11] = Manufacturer code (see xml for meanings) : bits[1] = NMT
 * ACL Expected : bits[1] = NMT Poll NAD : bits[1] = NMT Retry Request : bits[1]
 * = NMT Instance Changed : bits[1] = NMT Inactive : bits[1] = NMT Disconnected :
 * bits[2] = NMT Retry Counter : un8 = NMT NAD : un8 = NMT Timer : un8 = NMT ACL
 * Timer : un16 = Product Id (see xml for meanings), Note that the ve.direct mppt
 * chargers report this field incorrectly as an un16 with the product id in big-
 * endian notation : bits[1] = DEVICE_CLASS_VEBUS : bits[1] =
 * DEVICE_CLASS_CHARGER : bits[1] = DEVICE_CLASS_INVERTER : bits[1] =
 * DEVICE_CLASS_BATTERY : bits[1] = DEVICE_CLASS_GX_DEVICE : bits[3] =
 * DEVICE_CLASS_RESERVED : bits[1] = DEVICE_FLAGS_ACTIVE : bits[1] =
 * DEVICE_FLAGS_RESERVED1 : bits[1] = DEVICE_FLAGS_SYNC_CHARGING : bits[1] =
 * DEVICE_FLAGS_BMS : bits[1] = DEVICE_FLAGS_GROUP_MEMBER : bits[1] =
 * DEVICE_FLAGS_ACIN_LINK : bits[1] = DEVICE_FLAGS_EXT_CONTROL : bits[1] =
 * DEVICE_FLAGS_RESERVED7 : un8 = Timer : un8 = Group Id (see xml for meanings) :
 * un16 = Request Mask : un32 = DC Input Power [0.01W], 0xFFFFFFFF = Not
 * Available : sn16 = DC Current 1 [0.1A], 0x7FFF = Not Available : sn16 = DC
 * Current 2 [0.1A], 0x7FFF = Not Available : sn16 = DC Current 3 [0.1A], 0x7FFF
 * = Not Available : un8 = Device State (see xml for meanings) : un16 = Charge
 * Voltage Setpoint [0.01V], 0xFFFF = Not Available : un16 = Charge Current Limit
 * [0.1A], 0xFFFF = Not Available : un16 = Discharge Current Limit [0.1A], 0xFFFF
 * = Not Available : un16 = Discharge Voltage Limit [0.01V], 0xFFFF = Not
 * Available : un8 = System Voltage [1V] (see xml for meanings) : un8 = Charger
 * Algorithm Version (see xml for meanings) : un16 = State of Charge [0.01%] :
 * sn32 = Extra Battery Current [0.001A], 0x7FFFFFFF = Not Available : sn32 =
 * Battery Current [0.001A], 0x7FFFFFFF = Not Available : un16 = Battery Voltage
 * [0.01V], 0xFFFF = Not Available : sn16 = Battery Temperature [0.01°C], 0x7FFF
 * = Not Available : bits[5] = DEVICE_FLAGS2_RESERVED : bits[1] =
 * DEVICE_FLAGS2_HAS_ISENSE : bits[1] = DEVICE_FLAGS2_HAS_TSENSE : bits[1] =
 * DEVICE_FLAGS2_HAS_VSENSE}
 */
#define VE_REG_NMT_ENTRY29_A 0xD61D

/**
 * NMT Entry 30 (Part A) {bits[3] = ECU instance : bits[5] = Function instance :
 * un8 = Function : bits[1] = Reserved : bits[7] = Device class (see xml for
 * meanings) : bits[4] = Device class instance : bits[3] = Industry group (see
 * xml for meanings) : bits[1] = Self-configurable address : bits[21] = Identity
 * number : bits[11] = Manufacturer code (see xml for meanings) : bits[1] = NMT
 * ACL Expected : bits[1] = NMT Poll NAD : bits[1] = NMT Retry Request : bits[1]
 * = NMT Instance Changed : bits[1] = NMT Inactive : bits[1] = NMT Disconnected :
 * bits[2] = NMT Retry Counter : un8 = NMT NAD : un8 = NMT Timer : un8 = NMT ACL
 * Timer : un16 = Product Id (see xml for meanings), Note that the ve.direct mppt
 * chargers report this field incorrectly as an un16 with the product id in big-
 * endian notation : bits[1] = DEVICE_CLASS_VEBUS : bits[1] =
 * DEVICE_CLASS_CHARGER : bits[1] = DEVICE_CLASS_INVERTER : bits[1] =
 * DEVICE_CLASS_BATTERY : bits[1] = DEVICE_CLASS_GX_DEVICE : bits[3] =
 * DEVICE_CLASS_RESERVED : bits[1] = DEVICE_FLAGS_ACTIVE : bits[1] =
 * DEVICE_FLAGS_RESERVED1 : bits[1] = DEVICE_FLAGS_SYNC_CHARGING : bits[1] =
 * DEVICE_FLAGS_BMS : bits[1] = DEVICE_FLAGS_GROUP_MEMBER : bits[1] =
 * DEVICE_FLAGS_ACIN_LINK : bits[1] = DEVICE_FLAGS_EXT_CONTROL : bits[1] =
 * DEVICE_FLAGS_RESERVED7 : un8 = Timer : un8 = Group Id (see xml for meanings) :
 * un16 = Request Mask : un32 = DC Input Power [0.01W], 0xFFFFFFFF = Not
 * Available : sn16 = DC Current 1 [0.1A], 0x7FFF = Not Available : sn16 = DC
 * Current 2 [0.1A], 0x7FFF = Not Available : sn16 = DC Current 3 [0.1A], 0x7FFF
 * = Not Available : un8 = Device State (see xml for meanings) : un16 = Charge
 * Voltage Setpoint [0.01V], 0xFFFF = Not Available : un16 = Charge Current Limit
 * [0.1A], 0xFFFF = Not Available : un16 = Discharge Current Limit [0.1A], 0xFFFF
 * = Not Available : un16 = Discharge Voltage Limit [0.01V], 0xFFFF = Not
 * Available : un8 = System Voltage [1V] (see xml for meanings) : un8 = Charger
 * Algorithm Version (see xml for meanings) : un16 = State of Charge [0.01%] :
 * sn32 = Extra Battery Current [0.001A], 0x7FFFFFFF = Not Available : sn32 =
 * Battery Current [0.001A], 0x7FFFFFFF = Not Available : un16 = Battery Voltage
 * [0.01V], 0xFFFF = Not Available : sn16 = Battery Temperature [0.01°C], 0x7FFF
 * = Not Available : bits[5] = DEVICE_FLAGS2_RESERVED : bits[1] =
 * DEVICE_FLAGS2_HAS_ISENSE : bits[1] = DEVICE_FLAGS2_HAS_TSENSE : bits[1] =
 * DEVICE_FLAGS2_HAS_VSENSE}
 */
#define VE_REG_NMT_ENTRY30_A 0xD61E

/**
 * NMT Entry 31 (Part A) {bits[3] = ECU instance : bits[5] = Function instance :
 * un8 = Function : bits[1] = Reserved : bits[7] = Device class (see xml for
 * meanings) : bits[4] = Device class instance : bits[3] = Industry group (see
 * xml for meanings) : bits[1] = Self-configurable address : bits[21] = Identity
 * number : bits[11] = Manufacturer code (see xml for meanings) : bits[1] = NMT
 * ACL Expected : bits[1] = NMT Poll NAD : bits[1] = NMT Retry Request : bits[1]
 * = NMT Instance Changed : bits[1] = NMT Inactive : bits[1] = NMT Disconnected :
 * bits[2] = NMT Retry Counter : un8 = NMT NAD : un8 = NMT Timer : un8 = NMT ACL
 * Timer : un16 = Product Id (see xml for meanings), Note that the ve.direct mppt
 * chargers report this field incorrectly as an un16 with the product id in big-
 * endian notation : bits[1] = DEVICE_CLASS_VEBUS : bits[1] =
 * DEVICE_CLASS_CHARGER : bits[1] = DEVICE_CLASS_INVERTER : bits[1] =
 * DEVICE_CLASS_BATTERY : bits[1] = DEVICE_CLASS_GX_DEVICE : bits[3] =
 * DEVICE_CLASS_RESERVED : bits[1] = DEVICE_FLAGS_ACTIVE : bits[1] =
 * DEVICE_FLAGS_RESERVED1 : bits[1] = DEVICE_FLAGS_SYNC_CHARGING : bits[1] =
 * DEVICE_FLAGS_BMS : bits[1] = DEVICE_FLAGS_GROUP_MEMBER : bits[1] =
 * DEVICE_FLAGS_ACIN_LINK : bits[1] = DEVICE_FLAGS_EXT_CONTROL : bits[1] =
 * DEVICE_FLAGS_RESERVED7 : un8 = Timer : un8 = Group Id (see xml for meanings) :
 * un16 = Request Mask : un32 = DC Input Power [0.01W], 0xFFFFFFFF = Not
 * Available : sn16 = DC Current 1 [0.1A], 0x7FFF = Not Available : sn16 = DC
 * Current 2 [0.1A], 0x7FFF = Not Available : sn16 = DC Current 3 [0.1A], 0x7FFF
 * = Not Available : un8 = Device State (see xml for meanings) : un16 = Charge
 * Voltage Setpoint [0.01V], 0xFFFF = Not Available : un16 = Charge Current Limit
 * [0.1A], 0xFFFF = Not Available : un16 = Discharge Current Limit [0.1A], 0xFFFF
 * = Not Available : un16 = Discharge Voltage Limit [0.01V], 0xFFFF = Not
 * Available : un8 = System Voltage [1V] (see xml for meanings) : un8 = Charger
 * Algorithm Version (see xml for meanings) : un16 = State of Charge [0.01%] :
 * sn32 = Extra Battery Current [0.001A], 0x7FFFFFFF = Not Available : sn32 =
 * Battery Current [0.001A], 0x7FFFFFFF = Not Available : un16 = Battery Voltage
 * [0.01V], 0xFFFF = Not Available : sn16 = Battery Temperature [0.01°C], 0x7FFF
 * = Not Available : bits[5] = DEVICE_FLAGS2_RESERVED : bits[1] =
 * DEVICE_FLAGS2_HAS_ISENSE : bits[1] = DEVICE_FLAGS2_HAS_TSENSE : bits[1] =
 * DEVICE_FLAGS2_HAS_VSENSE}
 */
#define VE_REG_NMT_ENTRY31_A 0xD61F

/**
 * NMT Entry 0 (Part B) {un32 = sync_device_status : un32 = si_ac_inv_current_re
 * : un16 = ac_rated_power : un8 = sync_priority}
 */
#define VE_REG_NMT_ENTRY0_B 0xD620

/**
 * NMT Entry 1 (Part B) {un32 = sync_device_status : un32 = si_ac_inv_current_re
 * : un16 = ac_rated_power : un8 = sync_priority}
 */
#define VE_REG_NMT_ENTRY1_B 0xD621

/**
 * NMT Entry 2 (Part B) {un32 = sync_device_status : un32 = si_ac_inv_current_re
 * : un16 = ac_rated_power : un8 = sync_priority}
 */
#define VE_REG_NMT_ENTRY2_B 0xD622

/**
 * NMT Entry 3 (Part B) {un32 = sync_device_status : un32 = si_ac_inv_current_re
 * : un16 = ac_rated_power : un8 = sync_priority}
 */
#define VE_REG_NMT_ENTRY3_B 0xD623

/**
 * NMT Entry 4 (Part B) {un32 = sync_device_status : un32 = si_ac_inv_current_re
 * : un16 = ac_rated_power : un8 = sync_priority}
 */
#define VE_REG_NMT_ENTRY4_B 0xD624

/**
 * NMT Entry 5 (Part B) {un32 = sync_device_status : un32 = si_ac_inv_current_re
 * : un16 = ac_rated_power : un8 = sync_priority}
 */
#define VE_REG_NMT_ENTRY5_B 0xD625

/**
 * NMT Entry 6 (Part B) {un32 = sync_device_status : un32 = si_ac_inv_current_re
 * : un16 = ac_rated_power : un8 = sync_priority}
 */
#define VE_REG_NMT_ENTRY6_B 0xD626

/**
 * NMT Entry 7 (Part B) {un32 = sync_device_status : un32 = si_ac_inv_current_re
 * : un16 = ac_rated_power : un8 = sync_priority}
 */
#define VE_REG_NMT_ENTRY7_B 0xD627

/**
 * NMT Entry 8 (Part B) {un32 = sync_device_status : un32 = si_ac_inv_current_re
 * : un16 = ac_rated_power : un8 = sync_priority}
 */
#define VE_REG_NMT_ENTRY8_B 0xD628

/**
 * NMT Entry 9 (Part B) {un32 = sync_device_status : un32 = si_ac_inv_current_re
 * : un16 = ac_rated_power : un8 = sync_priority}
 */
#define VE_REG_NMT_ENTRY9_B 0xD629

/**
 * NMT Entry 10 (Part B) {un32 = sync_device_status : un32 = si_ac_inv_current_re
 * : un16 = ac_rated_power : un8 = sync_priority}
 */
#define VE_REG_NMT_ENTRY10_B 0xD62A

/**
 * NMT Entry 11 (Part B) {un32 = sync_device_status : un32 = si_ac_inv_current_re
 * : un16 = ac_rated_power : un8 = sync_priority}
 */
#define VE_REG_NMT_ENTRY11_B 0xD62B

/**
 * NMT Entry 12 (Part B) {un32 = sync_device_status : un32 = si_ac_inv_current_re
 * : un16 = ac_rated_power : un8 = sync_priority}
 */
#define VE_REG_NMT_ENTRY12_B 0xD62C

/**
 * NMT Entry 13 (Part B) {un32 = sync_device_status : un32 = si_ac_inv_current_re
 * : un16 = ac_rated_power : un8 = sync_priority}
 */
#define VE_REG_NMT_ENTRY13_B 0xD62D

/**
 * NMT Entry 14 (Part B) {un32 = sync_device_status : un32 = si_ac_inv_current_re
 * : un16 = ac_rated_power : un8 = sync_priority}
 */
#define VE_REG_NMT_ENTRY14_B 0xD62E

/**
 * NMT Entry 15 (Part B) {un32 = sync_device_status : un32 = si_ac_inv_current_re
 * : un16 = ac_rated_power : un8 = sync_priority}
 */
#define VE_REG_NMT_ENTRY15_B 0xD62F

/**
 * NMT Entry 16 (Part B) {un32 = sync_device_status : un32 = si_ac_inv_current_re
 * : un16 = ac_rated_power : un8 = sync_priority}
 */
#define VE_REG_NMT_ENTRY16_B 0xD630

/**
 * NMT Entry 17 (Part B) {un32 = sync_device_status : un32 = si_ac_inv_current_re
 * : un16 = ac_rated_power : un8 = sync_priority}
 */
#define VE_REG_NMT_ENTRY17_B 0xD631

/**
 * NMT Entry 18 (Part B) {un32 = sync_device_status : un32 = si_ac_inv_current_re
 * : un16 = ac_rated_power : un8 = sync_priority}
 */
#define VE_REG_NMT_ENTRY18_B 0xD632

/**
 * NMT Entry 19 (Part B) {un32 = sync_device_status : un32 = si_ac_inv_current_re
 * : un16 = ac_rated_power : un8 = sync_priority}
 */
#define VE_REG_NMT_ENTRY19_B 0xD633

/**
 * NMT Entry 20 (Part B) {un32 = sync_device_status : un32 = si_ac_inv_current_re
 * : un16 = ac_rated_power : un8 = sync_priority}
 */
#define VE_REG_NMT_ENTRY20_B 0xD634

/**
 * NMT Entry 21 (Part B) {un32 = sync_device_status : un32 = si_ac_inv_current_re
 * : un16 = ac_rated_power : un8 = sync_priority}
 */
#define VE_REG_NMT_ENTRY21_B 0xD635

/**
 * NMT Entry 22 (Part B) {un32 = sync_device_status : un32 = si_ac_inv_current_re
 * : un16 = ac_rated_power : un8 = sync_priority}
 */
#define VE_REG_NMT_ENTRY22_B 0xD636

/**
 * NMT Entry 23 (Part B) {un32 = sync_device_status : un32 = si_ac_inv_current_re
 * : un16 = ac_rated_power : un8 = sync_priority}
 */
#define VE_REG_NMT_ENTRY23_B 0xD637

/**
 * NMT Entry 24 (Part B) {un32 = sync_device_status : un32 = si_ac_inv_current_re
 * : un16 = ac_rated_power : un8 = sync_priority}
 */
#define VE_REG_NMT_ENTRY24_B 0xD638

/**
 * NMT Entry 25 (Part B) {un32 = sync_device_status : un32 = si_ac_inv_current_re
 * : un16 = ac_rated_power : un8 = sync_priority}
 */
#define VE_REG_NMT_ENTRY25_B 0xD639

/**
 * NMT Entry 26 (Part B) {un32 = sync_device_status : un32 = si_ac_inv_current_re
 * : un16 = ac_rated_power : un8 = sync_priority}
 */
#define VE_REG_NMT_ENTRY26_B 0xD63A

/**
 * NMT Entry 27 (Part B) {un32 = sync_device_status : un32 = si_ac_inv_current_re
 * : un16 = ac_rated_power : un8 = sync_priority}
 */
#define VE_REG_NMT_ENTRY27_B 0xD63B

/**
 * NMT Entry 28 (Part B) {un32 = sync_device_status : un32 = si_ac_inv_current_re
 * : un16 = ac_rated_power : un8 = sync_priority}
 */
#define VE_REG_NMT_ENTRY28_B 0xD63C

/**
 * NMT Entry 29 (Part B) {un32 = sync_device_status : un32 = si_ac_inv_current_re
 * : un16 = ac_rated_power : un8 = sync_priority}
 */
#define VE_REG_NMT_ENTRY29_B 0xD63D

/**
 * NMT Entry 30 (Part B) {un32 = sync_device_status : un32 = si_ac_inv_current_re
 * : un16 = ac_rated_power : un8 = sync_priority}
 */
#define VE_REG_NMT_ENTRY30_B 0xD63E

/**
 * NMT Entry 31 (Part B) {un32 = sync_device_status : un32 = si_ac_inv_current_re
 * : un16 = ac_rated_power : un8 = sync_priority}
 */
#define VE_REG_NMT_ENTRY31_B 0xD63F

/** Grid NS Protection Log Entry 0 {un32 = timestamp : un32 = event} */
#define VE_REG_GRID_NS_PROTECTION_LOG_ENTRY_0 0xD8E0

/** Grid NS Protection Log Entry 1 {un32 = timestamp : un32 = event} */
#define VE_REG_GRID_NS_PROTECTION_LOG_ENTRY_1 0xD8E1

/** Grid NS Protection Log Entry 2 {un32 = timestamp : un32 = event} */
#define VE_REG_GRID_NS_PROTECTION_LOG_ENTRY_2 0xD8E2

/** Grid NS Protection Log Entry 3 {un32 = timestamp : un32 = event} */
#define VE_REG_GRID_NS_PROTECTION_LOG_ENTRY_3 0xD8E3

/** Grid NS Protection Log Entry 4 {un32 = timestamp : un32 = event} */
#define VE_REG_GRID_NS_PROTECTION_LOG_ENTRY_4 0xD8E4

/**
 * MultiC DCAC Serial number (instance 3) {stringZeroEnded[16] = Serial : un8 =
 * padding, 0 = 0x00 padding}
 */
#define VE_REG_MULTIC_TST_DCAC_SERIAL_NUMBER 0xEE78

/**
 * MultiC MPPT Serial number (instance 4) {stringZeroEnded[16] = Serial : un8 =
 * padding, 0 = 0x00 padding}
 */
#define VE_REG_MULTIC_TST_MPPT_SERIAL_NUMBER 0xEE79

/** Debug value 0 */
#define VE_REG_DEBUG_0 0xDB00

/** Debug value 1 */
#define VE_REG_DEBUG_1 0xDB01

/** Debug value 2 */
#define VE_REG_DEBUG_2 0xDB02

/** Debug value 3 */
#define VE_REG_DEBUG_3 0xDB03

/** Debug value 4 */
#define VE_REG_DEBUG_4 0xDB04

/** Debug value 5 */
#define VE_REG_DEBUG_5 0xDB05

/** Debug value 6 */
#define VE_REG_DEBUG_6 0xDB06

/** Debug value 7 */
#define VE_REG_DEBUG_7 0xDB07

/** Debug value 8 */
#define VE_REG_DEBUG_8 0xDB08

/** Debug value 9 */
#define VE_REG_DEBUG_9 0xDB09

/** Debug value 10 */
#define VE_REG_DEBUG_10 0xDB0A

/** Debug value 11 */
#define VE_REG_DEBUG_11 0xDB0B

/** Debug value 12 */
#define VE_REG_DEBUG_12 0xDB0C

/** Debug value 13 */
#define VE_REG_DEBUG_13 0xDB0D

/** Debug value 14 */
#define VE_REG_DEBUG_14 0xDB0E

/** Debug value 15 */
#define VE_REG_DEBUG_15 0xDB0F

/** Debug value 16 */
#define VE_REG_DEBUG_16 0xDB10

/** Debug value 17 */
#define VE_REG_DEBUG_17 0xDB11

/** Debug value 18 */
#define VE_REG_DEBUG_18 0xDB12

/** Debug value 19 */
#define VE_REG_DEBUG_19 0xDB13

/** Debug value 20 */
#define VE_REG_DEBUG_20 0xDB14

/** Debug value 21 */
#define VE_REG_DEBUG_21 0xDB15

/** Debug value 22 */
#define VE_REG_DEBUG_22 0xDB16

/** Debug value 23 */
#define VE_REG_DEBUG_23 0xDB17

/** Debug value 24 */
#define VE_REG_DEBUG_24 0xDB18

/** Debug value 25 */
#define VE_REG_DEBUG_25 0xDB19

/** Debug value 26 */
#define VE_REG_DEBUG_26 0xDB1A

/** Debug value 27 */
#define VE_REG_DEBUG_27 0xDB1B

/** Debug value 28 */
#define VE_REG_DEBUG_28 0xDB1C

/** Debug value 29 */
#define VE_REG_DEBUG_29 0xDB1D

/** Debug value 30 */
#define VE_REG_DEBUG_30 0xDB1E

/** Debug value 31 */
#define VE_REG_DEBUG_31 0xDB1F

//[[[end]]]

/* Aliases for compatibility with existing code */
#define VE_REG_BAT_TRACTION_CURVE VE_REG_BAT_AUTO_EQUALISE_MODE
#define VE_REG_INDENTIFY VE_REG_IDENTIFY

/// @}
#endif
