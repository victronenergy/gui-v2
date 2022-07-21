#ifndef _VELIB_VECAN_CHARGER_ERROR_H_
#define _VELIB_VECAN_CHARGER_ERROR_H_

#define ERROR_DB_CHARGERS	 0x00						/*!< Condition / Description */

#define CHARGER_ERROR_NONE							0	/*!< No error */
#define CHARGER_ERROR_BATTERY_TEMP_TOO_HIGH			1	/*!< Error   / Battery temperature too high */
#define CHARGER_ERROR_BATTERY_VOLTAGE_TOO_HIGH		2	/*!< Error   / Battery voltage too high */
#define CHARGER_ERROR_BATTERY_TSENSE_PLUS_HIGH		3	/*!< Error   / Battery temperature sensor miswired */
#define CHARGER_ERROR_BATTERY_TSENSE_PLUS_LOW		4	/*!< Error   / Battery temperature sensor miswired */
#define CHARGER_ERROR_BATTERY_TSENSE_CONN_LOST		5	/*!< Error   / Battery temperature sensor connection lost */
#define CHARGER_ERROR_BATTERY_VSENSE_PLUS_LOW		6	/*!< Error   / Battery voltage sense miswired */
#define CHARGER_ERROR_BATTERY_VSENSE_MIN_HIGH		7	/*!< Error   / Battery voltage sense miswired */
#define CHARGER_ERROR_BATTERY_VSENSE_CONN_LOST		8	/*!< Error   / Battery voltage sense connection lost */
#define CHARGER_ERROR_BATTERY_VSENSE_LOSSES			9	/*!< Error   / Battery voltage wire losses too high */
#define CHARGER_ERROR_BATTERY_VOLTAGE_TOO_LOW		10	/*!< Error   / Battery voltage too low */
#define CHARGER_ERROR_BATTERY_RIPPLE_VOLTAGE		11	/*!< Error   / Battery ripple voltage on terminals too high */
#define CHARGER_ERROR_BATTERY_LOW_SOC				12	/*!< Error   / Battery low state of charge */
#define CHARGER_ERROR_BATTERY_MIDPOINT_VOLTAGE		13	/*!< Error   / Battery mid-point voltage issue */
#define CHARGER_ERROR_BATTERY_TEMP_TOO_LOW			14	/*!< Error   / Battery temperature too low */
#define CHARGER_ERROR_15							15  /*!< free */
#define CHARGER_ERROR_16							16  /*!< free */
#define CHARGER_ERROR_CHARGER_TEMP_TOO_HIGH			17	/*!< Error   / Charger temperature too high */
#define CHARGER_ERROR_CHARGER_OVER_CURRENT			18	/*!< Error   / Charger excessive current */
#define CHARGER_ERROR_CHARGER_CURRENT_REVERSED		19	/*!< Error   / Changer current polarity reversed */
#define CHARGER_ERROR_CHARGER_BULKTIME_EXPIRED		20	/*!< Error   / Charger bulk time expired */
#define CHARGER_ERROR_CHARGER_CURRENT_SENSE			21	/*!< Error   / Charger current sensor issue */
#define CHARGER_ERROR_CHARGER_TSENSE_SHORT			22	/*!< Error   / Charger temperature sensor miswired */
#define CHARGER_ERROR_CHARGER_TSENSE_CONN_LOST		23	/*!< Error   / Charger temperature sensor connection lost */
#define CHARGER_ERROR_CHARGER_FAN_MISSING			24	/*!< Error   / Charger internal fan not detected */
#define CHARGER_ERROR_CHARGER_FAN_OVER_CURRENT		25	/*!< Error   / Charger internal fan over-current */
#define CHARGER_ERROR_CHARGER_TERMINAL_OVERHEAT		26	/*!< Error   / Charger terminal overheated */
#define CHARGER_ERROR_CHARGER_SHORT_CIRCUIT			27	/*!< Error   / Charger short circuit */
#define CHARGER_ERROR_CHARGER_CONVERTER_ISSUE		28	/*!< Error   / Charger issue with power stage */
#define CHARGER_ERROR_CHARGER_OVER_CHARGE			29	/*!< Error   / Over-charge protection */
#define CHARGER_ERROR_30							30  /*!< free */
#define CHARGER_ERROR_INPUT_VOLTAGE_OUT_OF_RANGE	31	/*!< Error   / Input voltage out of range (measurement clipping, i.e. 100% duty cycle) */
#define CHARGER_ERROR_INPUT_VOLTAGE_TOO_LOW			32	/*!< Error   / Input voltage too low */
#define CHARGER_ERROR_INPUT_VOLTAGE_TOO_HIGH		33	/*!< Error   / Input voltage too high */
#define CHARGER_ERROR_INPUT_OVER_CURRENT			34	/*!< Error   / Input excessive current */
#define CHARGER_ERROR_INPUT_OVER_POWER				35	/*!< Error   / Input excessive power */
#define CHARGER_ERROR_INPUT_POLARITY				36	/*!< Error   / Input polarity issue */
#define CHARGER_ERROR_INPUT_VOLTAGE_ABSENT			37  /*!< Error   / Input voltage absent (mains removed, fuse blown?) */
#define CHARGER_ERROR_INPUT_SHUTDOWN				38  /*!< Error   / Input shutdown (converter broken, short input to avoid battery overcharge) -> permanent shutdown */
#define CHARGER_ERROR_INPUT_SHUTDOWN_RETRY			39  /*!< Error   / Input shutdown (converter broken, short input to avoid battery overcharge) -> retry allowed */
#define CHARGER_ERROR_INTERNAL_FAILURE				40	/*!< Error   / Internal failure (MPPT - PV Short protection not working (converter will try to broken itself by blowing its fuses)) -> permanent shutdown */
#define CHARGER_ERROR_PVRISO_FAULT					41	/*!< Error   / Inverter shutdown (panel isolation resistance too low) */
#define CHARGER_ERROR_GFCI_FAULT					42	/*!< Error   / Inverter shutdown (ground current too high: >30mA) */
#define CHARGER_ERROR_GROUND_RELAY_FAULT			43	/*!< Error   / Inverter shutdown (voltage over L and PE too high) */
#define CHARGER_ERROR_GX_RESERVED1					44  /*!< Reserved by GX Devices */
#define CHARGER_ERROR_GX_RESERVED2					45  /*!< Reserved by GX Devices */
#define CHARGER_ERROR_GX_RESERVED3					46  /*!< Reserved by GX Devices */
#define CHARGER_ERROR_GX_RESERVED4					47  /*!< Reserved by GX Devices: Data partition issue */
#define CHARGER_ERROR_GX_RESERVED5					48  /*!< Reserved by GX Devices: DVCC with incompatible firmware */
#define CHARGER_ERROR_GX_RESERVED6					49  /*!< Reserved by GX Devices */
#define CHARGER_ERROR_INVERTER_OVERLOAD				50	/*!< Error   / Inverter overload (iit protection) */
#define CHARGER_ERROR_INVERTER_TEMP_TOO_HIGH		51	/*!< Error   / Inverter temperature too high */
#define CHARGER_ERROR_INVERTER_OVER_CURRENT			52	/*!< Error   / Inverter peak current event counter*/
#define CHARGER_ERROR_INVERTER_DC_LEVEL				53	/*!< Error   / Inverter dc level (internal dc rail voltage) */
#define CHARGER_ERROR_INVERTER_AC_LEVEL				54	/*!< Error   / Inverter ac level (output voltage not ok) */
#define CHARGER_ERROR_INVERTER_DC_FAIL				55	/*!< Error   / Inverter dc fail (dc on output) */
#define CHARGER_ERROR_INVERTER_AC_FAIL				56	/*!< Error   / Inverter ac fail (shape wrong)*/
#define CHARGER_ERROR_INVERTER_AC_ON_OUTPUT			57	/*!< Error   / Inverter ac on output (inverter only) */
#define CHARGER_ERROR_INVERTER_BRIDGE_FAULT			58	/*!< Error   / Inverter bridge fault (hardware signal) */
#define CHARGER_ERROR_ACIN1_RELAY_FAULT				59  /*!< Error   / Multi ACIN1 relay test fault */
#define CHARGER_ERROR_ACIN2_RELAY_FAULT				60  /*!< Error   / Multi ACIN2 relay test fault */
#define CHARGER_ERROR_61							61  /*!< free */
#define CHARGER_ERROR_62							62  /*!< free */
#define CHARGER_ERROR_63							63  /*!< free */
#define CHARGER_ERROR_64							64  /*!< free */
#define CHARGER_ERROR_LINK_DEVICE_MISSING			65	/*!< Warning / Device disappeared during parallel operation (broken cable?) */
#define CHARGER_ERROR_LINK_CONFIGURATION			66	/*!< Warning / Incompatible device encountered for parallel operation (e.g. old firmware/different settings) */
#define CHARGER_ERROR_LINK_BMS_MISSING				67	/*!< Error   / BMS connection lost */
#define CHARGER_ERROR_LINK_CONFIG_MISMATCH			68	/*!< Error   / Network misconfigured */
#define CHARGER_ERROR_69							69  /*!< free */
#define CHARGER_ERROR_70							70  /*!< free */
#define CHARGER_ERROR_71							71  /*!< free */
#define CHARGER_ERROR_72							72  /*!< free */
#define CHARGER_ERROR_73							73  /*!< free */
#define CHARGER_ERROR_74							74  /*!< free */
#define CHARGER_ERROR_75							75  /*!< free */
#define CHARGER_ERROR_76							76  /*!< free */
#define CHARGER_ERROR_77							77  /*!< free */
#define CHARGER_ERROR_78							78  /*!< free */
#define CHARGER_ERROR_79							79  /*!< free */
#define CHARGER_ERROR_80							80  /*!< free */
#define CHARGER_ERROR_81							81  /*!< free */
#define CHARGER_ERROR_82							82  /*!< free */
#define CHARGER_ERROR_83							83  /*!< free */
#define CHARGER_ERROR_84							84  /*!< free */
#define CHARGER_ERROR_85							85  /*!< free */
#define CHARGER_ERROR_86							86  /*!< free */
#define CHARGER_ERROR_87							87  /*!< free */
#define CHARGER_ERROR_88							88  /*!< free */
#define CHARGER_ERROR_89							89  /*!< free */
#define CHARGER_ERROR_90							90  /*!< free */
#define CHARGER_ERROR_91							91  /*!< free */
#define CHARGER_ERROR_92							92  /*!< free */
#define CHARGER_ERROR_93							93  /*!< free */
#define CHARGER_ERROR_94							94  /*!< free */
#define CHARGER_ERROR_95							95  /*!< free */
#define CHARGER_ERROR_96							96  /*!< free */
#define CHARGER_ERROR_97							97  /*!< free */
#define CHARGER_ERROR_98							98  /*!< free */
#define CHARGER_ERROR_99							99  /*!< free */
#define CHARGER_ERROR_100							100 /*!< free */
#define CHARGER_ERROR_101							101 /*!< free */
#define CHARGER_ERROR_102							102 /*!< free */
#define CHARGER_ERROR_103							103 /*!< free */
#define CHARGER_ERROR_104							104 /*!< free */
#define CHARGER_ERROR_105							105 /*!< free */
#define CHARGER_ERROR_106							106 /*!< free */
#define CHARGER_ERROR_107							107 /*!< free */
#define CHARGER_ERROR_108							108 /*!< free */
#define CHARGER_ERROR_109							109 /*!< free */
#define CHARGER_ERROR_110							110 /*!< free */
#define CHARGER_ERROR_111							111 /*!< free */
#define CHARGER_ERROR_112							112 /*!< free */
#define CHARGER_ERROR_MEMORY_WRITE_FAILURE			113	/*!< Error   / Non-volatile storage write error */
#define CHARGER_ERROR_CPU_TEMP_TOO_HIGH				114	/*!< Error   / CPU temperature too high */
#define CHARGER_ERROR_COMMUNICATION_LOST			115	/*!< Error   / CAN/SCI communication lost (when critical) */
#define CHARGER_ERROR_CALIBRATION_DATA_LOST			116	/*!< Error   / Non-volatile calibration data lost */
#define CHARGER_ERROR_INVALID_FIRMWARE				117	/*!< Error   / Incompatible firmware encountered */
#define CHARGER_ERROR_INVALID_HARDWARE				118	/*!< Error   / Incompatible hardware encountered */
#define CHARGER_ERROR_SETTINGS_DATA_INVALID			119	/*!< Error   / Non-volatile settings data invalid/corrupted */
#define CHARGER_ERROR_REFERENCE_VOLTAGE_FAILURE		120	/*!< Error   / Reference voltage failure */
#define CHARGER_ERROR_TESTER_FAIL					121	/*!< Error   / Tester fail */
#define CHARGER_ERROR_HISTORY_DATA_INVALID			122	/*!< Error   / Non-volatile history data invalid/corrupted */
#define CHARGER_ERROR_123							123 /*!< free */
#define CHARGER_ERROR_124							124 /*!< free */
#define CHARGER_ERROR_125							125 /*!< free */
#define CHARGER_ERROR_126							126 /*!< free */
#define CHARGER_ERROR_127							127 /*!< free */
#define CHARGER_ERROR_128							128 /*!< free */
#define CHARGER_ERROR_129							129 /*!< free */
#define CHARGER_ERROR_130							130 /*!< free */
#define CHARGER_ERROR_131							131 /*!< free */
#define CHARGER_ERROR_132							132 /*!< free */
#define CHARGER_ERROR_133							133 /*!< free */
#define CHARGER_ERROR_134							134 /*!< free */
#define CHARGER_ERROR_135							135 /*!< free */
#define CHARGER_ERROR_136							136 /*!< free */
#define CHARGER_ERROR_137							137 /*!< free */
#define CHARGER_ERROR_138							138 /*!< free */
#define CHARGER_ERROR_139							139 /*!< free */
#define CHARGER_ERROR_140							140 /*!< free */
#define CHARGER_ERROR_141							141 /*!< free */
#define CHARGER_ERROR_142							142 /*!< free */
#define CHARGER_ERROR_143							143 /*!< free */
#define CHARGER_ERROR_144							144 /*!< free */
#define CHARGER_ERROR_145							145 /*!< free */
#define CHARGER_ERROR_146							146 /*!< free */
#define CHARGER_ERROR_147							147 /*!< free */
#define CHARGER_ERROR_148							148 /*!< free */
#define CHARGER_ERROR_149							149 /*!< free */
#define CHARGER_ERROR_150							150 /*!< free */
#define CHARGER_ERROR_151							151 /*!< free */
#define CHARGER_ERROR_152							152 /*!< free */
#define CHARGER_ERROR_153							153 /*!< free */
#define CHARGER_ERROR_154							154 /*!< free */
#define CHARGER_ERROR_155							155 /*!< free */
#define CHARGER_ERROR_156							156 /*!< free */
#define CHARGER_ERROR_157							157 /*!< free */
#define CHARGER_ERROR_158							158 /*!< free */
#define CHARGER_ERROR_159							159 /*!< free */
#define CHARGER_ERROR_160							160 /*!< free */
#define CHARGER_ERROR_161							161 /*!< free */
#define CHARGER_ERROR_162							162 /*!< free */
#define CHARGER_ERROR_163							163 /*!< free */
#define CHARGER_ERROR_164							164 /*!< free */
#define CHARGER_ERROR_165							165 /*!< free */
#define CHARGER_ERROR_166							166 /*!< free */
#define CHARGER_ERROR_167							167 /*!< free */
#define CHARGER_ERROR_168							168 /*!< free */
#define CHARGER_ERROR_169							169 /*!< free */
#define CHARGER_ERROR_170							170 /*!< free */
#define CHARGER_ERROR_171							171 /*!< free */
#define CHARGER_ERROR_172							172 /*!< free */
#define CHARGER_ERROR_173							173 /*!< free */
#define CHARGER_ERROR_174							174 /*!< free */
#define CHARGER_ERROR_175							175 /*!< free */
#define CHARGER_ERROR_176							176 /*!< free */
#define CHARGER_ERROR_177							177 /*!< free */
#define CHARGER_ERROR_178							178 /*!< free */
#define CHARGER_ERROR_179							179 /*!< free */
#define CHARGER_ERROR_180							180 /*!< free */
#define CHARGER_ERROR_181							181 /*!< free */
#define CHARGER_ERROR_182							182 /*!< free */
#define CHARGER_ERROR_183							183 /*!< free */
#define CHARGER_ERROR_184							184 /*!< free */
#define CHARGER_ERROR_185							185 /*!< free */
#define CHARGER_ERROR_186							186 /*!< free */
#define CHARGER_ERROR_187							187 /*!< free */
#define CHARGER_ERROR_188							188 /*!< free */
#define CHARGER_ERROR_189							189 /*!< free */
#define CHARGER_ERROR_190							190 /*!< free */
#define CHARGER_ERROR_191							191 /*!< free */
#define CHARGER_ERROR_192							192 /*!< free */
#define CHARGER_ERROR_193							193 /*!< free */
#define CHARGER_ERROR_194							194 /*!< free */
#define CHARGER_ERROR_195							195 /*!< free */
#define CHARGER_ERROR_196							196 /*!< free */
#define CHARGER_ERROR_197							197 /*!< free */
#define CHARGER_ERROR_198							198 /*!< free */
#define CHARGER_ERROR_199							199 /*!< free */
#define CHARGER_ERROR_INTERNAL_UNDERVOLTAGE_HV		200	/*!< Error   / Internal error */
#define CHARGER_ERROR_INTERNAL_DCDC_FAILURE			201 /*!< Error   / Internal error */
#define CHARGER_ERROR_202							202 /*!< free */
#define CHARGER_ERROR_INTERNAL_UNDERVOLTAGE_3V3		203	/*!< Error   / Internal error */
#define CHARGER_ERROR_204							204 /*!< free */
#define CHARGER_ERROR_INTERNAL_UNDERVOLTAGE_5V		205	/*!< Error   / Internal error */
#define CHARGER_ERROR_206							206 /*!< free */
#define CHARGER_ERROR_207							207 /*!< free */
#define CHARGER_ERROR_208							208 /*!< free */
#define CHARGER_ERROR_209							209 /*!< free */
#define CHARGER_ERROR_210							210 /*!< free */
#define CHARGER_ERROR_211							211 /*!< free */
#define CHARGER_ERROR_INTERNAL_UNDERVOLTAGE_12V		212	/*!< Error   / Internal error */
#define CHARGER_ERROR_213							213 /*!< free */
#define CHARGER_ERROR_214							214 /*!< free */
#define CHARGER_ERROR_INTERNAL_UNDERVOLTAGE_15V		215	/*!< Error   / Internal error */
#define CHARGER_ERROR_216							216 /*!< free */
#define CHARGER_ERROR_217							217 /*!< free */
#define CHARGER_ERROR_218							218 /*!< free */
#define CHARGER_ERROR_219							219 /*!< free */
#define CHARGER_ERROR_220							220 /*!< free */
#define CHARGER_ERROR_221							221 /*!< free */
#define CHARGER_ERROR_222							222 /*!< free */
#define CHARGER_ERROR_223							223 /*!< free */
#define CHARGER_ERROR_224							224 /*!< free */
#define CHARGER_ERROR_225							225 /*!< free */
#define CHARGER_ERROR_226							226 /*!< free */
#define CHARGER_ERROR_227							227 /*!< free */
#define CHARGER_ERROR_228							228 /*!< free */
#define CHARGER_ERROR_229							229 /*!< free */
#define CHARGER_ERROR_230							230 /*!< free */
#define CHARGER_ERROR_231							231 /*!< free */
#define CHARGER_ERROR_232							232 /*!< free */
#define CHARGER_ERROR_233							233 /*!< free */
#define CHARGER_ERROR_234							234 /*!< free */
#define CHARGER_ERROR_235							235 /*!< free */
#define CHARGER_ERROR_236							236 /*!< free */
#define CHARGER_ERROR_237							237 /*!< free */
#define CHARGER_ERROR_238							238 /*!< free */
#define CHARGER_ERROR_239							239 /*!< free */
#define CHARGER_ERROR_240							240 /*!< free */
#define CHARGER_ERROR_241							241 /*!< free */
#define CHARGER_ERROR_242							242 /*!< free */
#define CHARGER_ERROR_243							243 /*!< free */
#define CHARGER_ERROR_244							244 /*!< free */
#define CHARGER_ERROR_245							245 /*!< free */
#define CHARGER_ERROR_246							246 /*!< free */
#define CHARGER_ERROR_247							247 /*!< free */
#define CHARGER_ERROR_248							248 /*!< free */
#define CHARGER_ERROR_249							249 /*!< free */
#define CHARGER_ERROR_250							250 /*!< free */
#define CHARGER_ERROR_251							251 /*!< free */
#define CHARGER_ERROR_252							252 /*!< free */
#define CHARGER_ERROR_253							253 /*!< free */
#define CHARGER_ERROR_254							254 /*!< free */
#define CHARGER_ERROR_UNKNOWN                       255 /*!< unknown/reserved */

#endif
