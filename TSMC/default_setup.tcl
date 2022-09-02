# this file works for default setup base on your metal scheme:
# The Metal Scheme : 15M_1X1Xb1Xe1Ya1Yb5Y2Yy2Z > The metal scheme description is from M2-M15, Cause the M0 - M1 belong to BASE LAYER 


# Default for PV run overall
set pv_calibre(layout_system) "oasis"
set pv_calibre(precision) 2000
set pv_calibre(layoutinput_errorout) "1"

# Default for dummy target #########################################################
####################################################################################
set pv_calibre(dummy,dfmdb) "OASIS"
set pv_calibre(dummy,exclude_cell_file) ""
set pv_calibre(dummy,maximum_results) "ALL"
set pv_calibre(dummy,rule_select) ""
set pv_calibre(dummy,rule_select_bylayer) ""

set pv_calibre(dummy,user_include_file) ""
set pv_calibre(dummy,lsf_remote_file) "./PV_flow/lsf_remote/lsf_remote_control_file.temp"

# Default for dummy target > block_level ###########################################
set pv_calibre(dummy,default,nonbooleanswitches,block_level) "" 
set pv_calibre(dummy,default,booleanswitches,block_level) "OUTPUT_GDS 0 WITH_SEALRING 0 UseprBoundary 1 ChipWindowUsed 0 FILL_DUMMY_TCD 1 ENGINE_OPT_BY_ADV_FEATURE 1"
set pv_calibre(dummy,default,stringvariables,block_level) ""
set pv_calibre(dummy,default,nonstringvariables,block_level) "xLB 0 yLB 0 xRT 1000 yRT 1000 Cell_CHIP 0.068"

# Default for dummy target > feol block_level
set pv_calibre(dummy,feol,default,nonbooleanswitches,block_level) ""
set pv_calibre(dummy,feol,default,booleanswitches,block_level) ""
set pv_calibre(dummy,feol,default,stringvariables,block_level) ""
set pv_calibre(dummy,feol,default,nonstringvariables,block_level) ""
# Default for dummy target > beol block_level
set pv_calibre(dummy.beol,default,nonbooleanswitches,block_level) ""
set pv_calibre(dummy,beol,default,booleanswitches,block_level) "
TOP_M15 1 \
FILL_DM0  1 FILL_M0_BTCD  1 FILL_DmyVIA0  1 FILL_VIA0_BTCD  1 \
FILL_DM1  1 FILL_M1_BTCD  1 FILL_DmyVIA1  1 FILL_VIA1_BTCD  1				VERTICAL_M1 1 \
FILL_DM2  1 FILL_M2_BTCD  1 FILL_DmyVIA2  1 FILL_VIA2_BTCD  1 \
FILL_DM3  1 FILL_M3_BTCD  1 FILL_DmyVIA3  1 FILL_VIA3_BTCD  1 METAL_XB_M3 1 VERTICAL_M3 1 \
FILL_DM4  1 FILL_M4_BTCD  1 FILL_DmyVIA4  1 FILL_VIA4_BTCD  1 METAL_XE_M4 1 \
FILL_DM5  1 FILL_M5_BTCD  1 FILL_DmyVIA5  1 FILL_VIA5_BTCD  1 METAL_YA_M5 1 VERTICAL_M5 1 \
FILL_DM6  1 FILL_M6_BTCD  1 FILL_DmyVIA6  1 FILL_VIA6_BTCD  1 METAL_YB_M6 1 \
FILL_DM7  1 FILL_M7_BTCD  1 FILL_DmyVIA7  1 FILL_VIA7_BTCD  1 METAL_Y_M7  1 VERTICAL_M7 1 \
FILL_DM8  1 FILL_M8_BTCD  1 FILL_DmyVIA8  1 FILL_VIA8_BTCD  1 METAL_Y_M8  1 \
FILL_DM9  1 FILL_M9_BTCD  1 FILL_DmyVIA9  1 FILL_VIA9_BTCD  1 METAL_Y_M9  1 VERTICAL_M9 1 \
FILL_DM10 1 FILL_M10_BTCD 1 FILL_DmyVIA10 1 FILL_VIA10_BTCD 1 METAL_Y_M10 1 \
FILL_DM11 1	FILL_M11_BTCD 1 FILL_DmyVIA11 1 FILL_VIA11_BTCD 1 METAL_Y_M11 1 VERTICAL_M11 1 \
FILL_DM12 1 FILL_M12_BTCD 1 FILL_DmyVIA12 1 FILL_VIA12_BTCD 1 METAL_Y_M12 1 \
FILL_DM13 1	FILL_M13_BTCD 1 FILL_DmyVIA13 1 FILL_VIA13_BTCD 1 METAL_Y_M13 1 VERTICAL_M13 1 \
FILL_DM14 1 FILL_M14_BTCD 1 FILL_DmyVIA14 1 FILL_VIA14_BTCD 1 METAL_Y_M14 1 \
FILL_DM15 1 FILL_M15_BTCD 1									  METAL_Z_M15 1 VERTICAL_M15 1 \
"
set pv_calibre(dummy,beol,default,stringvariables,block_level) ""
set pv_calibre(dummy,beol,default,nonstringvariables,block_level) ""

# Default for dummy target > full_chip ###########################################
set pv_calibre(dummy,default,nonbooleanswitches,full_chip) "" 
set pv_calibre(dummy,default,booleanswitches,full_chip) "FULL_CHIP 1 OUTPUT_GDS 0 WITH_SEALRING 0 UseprBoundary 1 ChipWindowUsed 0 FILL_DUMMY_TCD 1 ENGINE_OPT_BY_ADV_FEATURE 1"
set pv_calibre(dummy,default,stringvariables,full_chip) ""
set pv_calibre(dummy,default,nonstringvariables,full_chip) "xLB 0 yLB 0 xRT 1000 yRT 1000"

# Default for dummy target > feol full_chip
set pv_calibre(dummy,feol,default,nonbooleanswitches,full_chip) ""
set pv_calibre(dummy,feol,default,booleanswitches,full_chip) ""
set pv_calibre(dummy,feol,default,stringvariables,full_chip) ""
set pv_calibre(dummy,feol,default,nonstringvariables,full_chip) ""
# Default for dummy target > beol full_chip
set pv_calibre(dummy.beol,default,nonbooleanswitches,full_chip) ""
set pv_calibre(dummy,beol,default,booleanswitches,full_chip) "
TOP_M15 1 \
FILL_DM0  1 FILL_M0_BTCD  1 FILL_DmyVIA0  1 FILL_VIA0_BTCD  1 \
FILL_DM1  1 FILL_M1_BTCD  1 FILL_DmyVIA1  1 FILL_VIA1_BTCD  1				VERTICAL_M1 1 \
FILL_DM2  1 FILL_M2_BTCD  1 FILL_DmyVIA2  1 FILL_VIA2_BTCD  1 \
FILL_DM3  1 FILL_M3_BTCD  1 FILL_DmyVIA3  1 FILL_VIA3_BTCD  1 METAL_XB_M3 1 VERTICAL_M3 1 \
FILL_DM4  1 FILL_M4_BTCD  1 FILL_DmyVIA4  1 FILL_VIA4_BTCD  1 METAL_XE_M4 1 \
FILL_DM5  1 FILL_M5_BTCD  1 FILL_DmyVIA5  1 FILL_VIA5_BTCD  1 METAL_YA_M5 1 VERTICAL_M5 1 \
FILL_DM6  1 FILL_M6_BTCD  1 FILL_DmyVIA6  1 FILL_VIA6_BTCD  1 METAL_YB_M6 1 \
FILL_DM7  1 FILL_M7_BTCD  1 FILL_DmyVIA7  1 FILL_VIA7_BTCD  1 METAL_Y_M7  1 VERTICAL_M7 1 \
FILL_DM8  1 FILL_M8_BTCD  1 FILL_DmyVIA8  1 FILL_VIA8_BTCD  1 METAL_Y_M8  1 \
FILL_DM9  1 FILL_M9_BTCD  1 FILL_DmyVIA9  1 FILL_VIA9_BTCD  1 METAL_Y_M9  1 VERTICAL_M9 1 \
FILL_DM10 1 FILL_M10_BTCD 1 FILL_DmyVIA10 1 FILL_VIA10_BTCD 1 METAL_Y_M10 1 \
FILL_DM11 1	FILL_M11_BTCD 1 FILL_DmyVIA11 1 FILL_VIA11_BTCD 1 METAL_Y_M11 1 VERTICAL_M11 1 \
FILL_DM12 1 FILL_M12_BTCD 1 FILL_DmyVIA12 1 FILL_VIA12_BTCD 1 METAL_Y_M12 1 \
FILL_DM13 1	FILL_M13_BTCD 1 FILL_DmyVIA13 1 FILL_VIA13_BTCD 1 METAL_Y_M13 1 VERTICAL_M13 1 \
FILL_DM14 1 FILL_M14_BTCD 1 FILL_DmyVIA14 1 FILL_VIA14_BTCD 1 METAL_Y_M14 1 \
FILL_DM15 1 FILL_M15_BTCD 1									  METAL_Z_M15 1 VERTICAL_M15 1 \
"
set pv_calibre(dummy,beol,default,stringvariables,full_chip) ""
set pv_calibre(dummy,beol,default,nonstringvariables,full_chip) ""
set pv_calibre(drc,dfmdb) "OASIS"
set pv_calibre(drc,exclude_cell_file) ""
set pv_calibre(drc,user_include_file) ""
set pv_calibre(drc,maximum_results) "10000"
set pv_calibre(drc,rule_select) ""
set pv_calibre(drc,rule_select_bylayer) ""
set pv_calibre(drc,lsf_remote_file) "set pv_calibre(drc,dfmdb) "OASIS"
set pv_calibre(drc,exclude_cell_file) ""
set pv_calibre(drc,user_include_file) ""
set pv_calibre(drc,maximum_results) "10000"
set pv_calibre(drc,rule_select) ""
set pv_calibre(drc,rule_select_bylayer) ""
set pv_calibre(drc,lsf_remote_file) "./PV_flow/lsf_remote/lsf_remote_control_file.temp"
set pv_calibre(drc,gen_header_only) ""
"
set pv_calibre(drc,gen_header_only) ""
set pv_calibre(drc,sanity_check_only) "0"
# Default for drc sanity target > block_level ###########################################
set pv_calibre(drc,sanity_check,default,nonbooleanswitches,block_level) ""
set pv_calibre(drc,sanity_check,default,booleanswitches,block_level) "	\
FULL_CHIP 0 WITH_SEALRING 0												\
IP_TIGHTEN_DENSITY 1													\
G0_MASK_HINT 0															\
USE_IO_VOLTAGE_ON_CORE_TO_IO_NET 0										\
USE_SD_VOLTAGE_ON_CORE_TO_IO_NET 0										\
DEFINE_IOPAD_BY_IODMY 0 DVIAxR3_For_NonFlipChip 1						\
VOLTAGE_RULE_CHECK 1 ESD_LUP_RULE_CHECK 1								\
UseprBoundary 1 ChipWindowUsed 0										\
"		
set pv_calibre(drc,sanity_check,default,stringvariables,block_level) ""
set pv_calibre(drc,sanity_check,default,nonstringvariables,block_level) "	\
xLB 0 yLB 0 xRT 1000 yRT 1000												\
ScribeLineX 179.76 ScribeLineY 179.76										\
"
# Default for drc sanity target > full_chip ###########################################
set pv_calibre(drc,sanity_check,default,nonbooleanswitches,full_chip) ""
set pv_calibre(drc,sanity_check,default,booleanswitches,full_chip) "	\
FULL_CHIP 1 WITH_SEALRING 0												\
IP_TIGHTEN_DENSITY 1													\
G0_MASK_HINT 0															\
USE_IO_VOLTAGE_ON_CORE_TO_IO_NET 0										\
USE_SD_VOLTAGE_ON_CORE_TO_IO_NET 0										\
DEFINE_IOPAD_BY_IODMY 0 DVIAxR3_For_NonFlipChip 1						\
VOLTAGE_RULE_CHECK 1 ESD_LUP_RULE_CHECK 1								\
UseprBoundary 1 ChipWindowUsed 0										\
"		
set pv_calibre(drc,sanity_check,default,stringvariables,full_chip) ""
set pv_calibre(drc,sanity_check,default,nonstringvariables,full_chip) "		\
xLB 0 yLB 0 xRT 1000 yRT 1000												\
ScribeLineX 179.76 ScribeLineY 179.76										\
"
# Default for drc target > block_level ###########################################
set pv_calibre(drc,default,nonbooleanswitches,block_level) ""
# Discriptions:
# > KOZ_High_subst_layer is 8, not 15-20, turn off
# Because the tlef with the info of SHDMIM, here setup SHDMIM AS 1, but this one do also need recheck for more infomation
set pv_calibre(drc,default,booleanswitches,block_level) "			\
FULL_CHIP 0 WITH_SEALRING 0											\
DEFINE_PAD_BY_TEXT 1												\
CHECK_LOW_DENSITY 1 CHECK_HIGH_DENSITY 1 PT_CHECK 1					\ 
CHECK_FLOATING_GATE_BY_TEXT 0 CHECK_FLOATING_GATE_BY_PRIMARY_TEXT 0 \
COD_RULE_CHECK 1 COD_MASK_HINT 0 COD_RULE_CHECK_ONLY 0				\
FRONT_END 1 BACK_END 1												\
G0_RULE_CHECK 1 G0_RULE_CHECK_ONLY 0								\
VOLTAGE_RULE_CHECK 1 VOLTAGE_RULE_CHECK_ONLY 0						\
ESD_LUP_RULE_CHECK 1 ESD_LUP_RULE_CHECK_ONLY 0						\
DENSITY_RULE_CHECK_ONLY 0											\
SRAM_SANITY_DRC 1 SRAM_SANITY_DRC_ONLY 0							\
DUMMY_PRE_CHECK 1 DUMMY_PRE_CHECK_TIGHTEN 1							\
IP_TIGHTEN_DENSITY 1 IP_TIGHTEN_BOUNDARY 1							\
WITH_APRDL 0														\
SHDMIM 1 FHDMIM 0													\
UseprBoundary 1 ChipWindowUsed 0									\
																	\
DFM 0 DFM_ONLY 0 Recommended 1 Guideline 1							\
WITH_POLYIMIDE 1 DBOC 0												\
G0_MASK_HINT 0														\
USE_IO_VOLTAGE_ON_CORE_TO_IO_NET 0									\
USE_SD_VOLTAGE_ON_CORE_TO_IO_NET 0									\
SKIP_CELL_BOUNDARY 0 LUP_FILTER 0									\
DEFINE_IOPAD_BY_IODMY 1 ALL_AREA_IO 1								\
DISCONNECT_ALL_RESISTOR 0 CONNECT_ALL_RESISTOR 0					\
GUIDELINE_ESD_CDM7A 0 GUIDELINE_ESD_CDM9A 0							\
IP_LEVEL_LUP_CHECK 1 LUP_MASK_HINT 1 LUP_SANITY_CHECK 0				\
ESDLU_IP_TIGHTEN_DENSITY 1 BOOST_VT_OP 1							\

NO_INDICATOR_OF_OFFGRID_DIRECTIONAL 0								\
KOZ_High_subst_layer 0												\
SHDMIM_KOZ_AP_SPACE_5um 1 SHDMIM_KOZ_AP_SPACE_5um_IP 1				\
FHDMIM_KOZ_AP_SPACE_5um 0 FHDMIM_KOZ_AP_SPACE_5um_IP 0				\
Multi_VOLTAGE_BIN_WITHIN_CHIP 0 SINGLE_VOLTAGE_BIN_WITHIN_CHIP 0	\
SINGLE_VOLTAGE_BIN_0D96 1											\ 
SINGLE_VOLTAGE_BIN_1D32 0 SINGLE_VOLTAGE_BIN_1D65 0					\
USER_DEFINED_DELTA_VOLTAGE 0										\
Flip_Chip 1 Flip_Chip_SUB_wi_presolder 1 Flip_Chip_Thin_Die 1		\
prBoundary_GRID 1 DVIAxR3_For_NonFlipChip 1							\
GUIDELINE_ESD 1 GUIDELINE_ANALOG 1									\
First_priority 1 Manufacturing_concern 1 Device_performance 1		\
"

set pv_calibre(drc,default,stringvariables,block_level) "			\
PAD_TEXT \"?\"									\
VDD_TEXT \"VDD?\"								\
VSS_TEXT \"VSS?\"								\
PoP_PAD_TEXT \"POP?\"							\
IP_PIN_TEXT \"?\"								\
ULTRA_LOW_NOISE_PAD_TEXT \"_NULL_TEXT_NAME_\"	\
LOW_NOISE_PAD_TEXT \"_NULL_TEXT_NAME1_\"		\
MED_LOW_NOISE_PAD_TEXT \"_NULL_TEXT_NAME2_\"	\
MED_NOISE_PAD_TEXT \"_NULL_TEXT_NAME3_\"		\
HIGH_NOISE_PAD_TEXT \"_NULL_TEXT_NAME4_\"		\
DUMMY_PAD_TEXT \"_NULL_TEXT_NAME7_\"			\
"
set pv_calibre(drc,default,nonstringvariables,block_level) "	\
xLB 0 yLB 0 xRT 1000 yRT 1000									\
ScribeLineX 179.76 ScribeLineY 179.76							\
"
# Default for drc target > full_chip ###########################################
set pv_calibre(drc,default,nonbooleanswitches,full_chip) ""

# Because the tlef with the info of SHDMIM, here setup SHDMIM AS 1, but this one do also need recheck for more infomation
set pv_calibre(drc,default,booleanswitches,full_chip) "				\
FULL_CHIP 1 WITH_SEALRING 0											\
DEFINE_PAD_BY_TEXT 1												\
CHECK_LOW_DENSITY 1 CHECK_HIGH_DENSITY 1 PT_CHECK 1					\ 
CHECK_FLOATING_GATE_BY_TEXT 0 CHECK_FLOATING_GATE_BY_PRIMARY_TEXT 0 \
COD_RULE_CHECK 1 COD_MASK_HINT 0 COD_RULE_CHECK_ONLY 0				\
FRONT_END 1 BACK_END 1												\
G0_RULE_CHECK 1 G0_RULE_CHECK_ONLY 0								\
VOLTAGE_RULE_CHECK 1 VOLTAGE_RULE_CHECK_ONLY 0						\
ESD_LUP_RULE_CHECK 1 ESD_LUP_RULE_CHECK_ONLY 0						\
DENSITY_RULE_CHECK_ONLY 0											\
SRAM_SANITY_DRC 1 SRAM_SANITY_DRC_ONLY 0							\
DUMMY_PRE_CHECK 0 DUMMY_PRE_CHECK_TIGHTEN 0							\
IP_TIGHTEN_DENSITY 0 IP_TIGHTEN_BOUNDARY 0							\
WITH_APRDL 0														\
SHDMIM 1 FHDMIM 0													\
UseprBoundary 1 ChipWindowUsed 0									\
																	\
DFM 0 DFM_ONLY 0 Recommended 1 Guideline 1							\
WITH_POLYIMIDE 1 DBOC 0												\
G0_MASK_HINT 0														\
USE_IO_VOLTAGE_ON_CORE_TO_IO_NET 0									\
USE_SD_VOLTAGE_ON_CORE_TO_IO_NET 0									\
SKIP_CELL_BOUNDARY 0 LUP_FILTER 0									\
DEFINE_IOPAD_BY_IODMY 1 ALL_AREA_IO 1								\
DISCONNECT_ALL_RESISTOR 0 CONNECT_ALL_RESISTOR 0					\
GUIDELINE_ESD_CDM7A 0 GUIDELINE_ESD_CDM9A 0							\
IP_LEVEL_LUP_CHECK 1 LUP_MASK_HINT 1 LUP_SANITY_CHECK 0				\
ESDLU_IP_TIGHTEN_DENSITY 1 BOOST_VT_OP 1							\
NO_INDICATOR_OF_OFFGRID_DIRECTIONAL 0								\
KOZ_High_subst_layer 0												\
SHDMIM_KOZ_AP_SPACE_5um 1 SHDMIM_KOZ_AP_SPACE_5um_IP 1				\
FHDMIM_KOZ_AP_SPACE_5um 0 FHDMIM_KOZ_AP_SPACE_5um_IP 0				\
Multi_VOLTAGE_BIN_WITHIN_CHIP 0 SINGLE_VOLTAGE_BIN_WITHIN_CHIP 0	\
SINGLE_VOLTAGE_BIN_0D96 1											\ 
SINGLE_VOLTAGE_BIN_1D32 0 SINGLE_VOLTAGE_BIN_1D65 0					\
USER_DEFINED_DELTA_VOLTAGE 0										\
Flip_Chip 1 Flip_Chip_SUB_wi_presolder 1 Flip_Chip_Thin_Die 1		\
prBoundary_GRID 1 DVIAxR3_For_NonFlipChip 1							\
GUIDELINE_ESD 1 GUIDELINE_ANALOG 1									\
First_priority 1 Manufacturing_concern 1 Device_performance 1		\
"
set pv_calibre(drc,default,stringvariables,full_chip) "				\
PAD_TEXT \"?\"									\
VDD_TEXT \"VDD?\"								\
VSS_TEXT \"VSS?\"								\
PoP_PAD_TEXT \"POP?\"							\
IP_PIN_TEXT \"?\"								\
ULTRA_LOW_NOISE_PAD_TEXT \"_NULL_TEXT_NAME_\"	\
LOW_NOISE_PAD_TEXT \"_NULL_TEXT_NAME1_\"		\
MED_LOW_NOISE_PAD_TEXT \"_NULL_TEXT_NAME2_\"	\
MED_NOISE_PAD_TEXT \"_NULL_TEXT_NAME3_\"		\
HIGH_NOISE_PAD_TEXT \"_NULL_TEXT_NAME4_\"		\
DUMMY_PAD_TEXT \"_NULL_TEXT_NAME7_\"			\
"
set pv_calibre(drc,default,nonstringvariables,full_chip) "	\
xLB 0 yLB 0 xRT 1000 yRT 1000								\
ScribeLineX 179.76 ScribeLineY 179.76						\
"

####################################################################################

# Default for bump target #########################################################
####################################################################################
set pv_calibre(bump,dfmdb) "OASIS"
set pv_calibre(bump,user_include_file) ""
set pv_calibre(bump,maximum_results) "10000"
set pv_calibre(bump,exclude_cell_file) ""
set pv_calibre(bump,rule_select) ""
set pv_calibre(bump,rule_select_bylayer) ""
set pv_calibre(bump,lsf_remote_file) "PV_flow/lsf_remote/lsf_remote_control_file.temp"

# Default for bump target > block_level ###########################################
set pv_calibre(bump,default,nonbooleanswitches,block_level) ""
set pv_calibre(bump,default,booleanswitches,block_level) ""
set pv_calibre(bump,default,stringvariables,block_level) ""
set pv_calibre(bump,default,nonstringvariables,block_level) ""

# Default for bump target > full_chip ###########################################
set pv_calibre(bump,default,nonbooleanswitches,full_chip) ""
set pv_calibre(bump,default,booleanswitches,full_chip) ""
set pv_calibre(bump,default,stringvariables,full_chip) ""
set pv_calibre(bump,default,nonstringvariables,full_chip) ""

####################################################################################

# Default for ant target #########################################################
####################################################################################
set pv_calibre(ant,dfmdb) "OASIS"
set pv_calibre(ant,user_include_file) "/home/apchen1/user_include.svrf"
# turn on 1 to check_mimcap
set pv_calibre(ant,check_mimcap) "1"
set pv_calibre(ant,check_mimcap_only) ""
set pv_calibre(ant,exclude_cell_file) ""
set pv_calibre(ant,maximum_results) "10000"
set pv_calibre(ant,rule_select) ""
set pv_calibre(ant,rule_select_bylayer) ""
set pv_calibre(ant,lsf_remote_file) "PV_flow/lsf_remote/lsf_remote_control_file.temp"

# Default for ant target > block_level ###########################################
set pv_calibre(ant,default,nonbooleanswitches,block_level) ""
set pv_calibre(ant,default,booleanswitches,block_level) "WITH_4MZ 0 DEBUG_MX 0 DEBUG_VIA 0 ACC_DEBUG 0 FHDMIM 0"
set pv_calibre(ant,default,stringvariables,block_level) ""
set pv_calibre(ant,default,nonstringvariables,block_level) "AP_THICKNESS 2.8"

# Default for ant target > full_chip ###########################################
set pv_calibre(ant,default,nonbooleanswitches,full_chip) ""
set pv_calibre(ant,default,booleanswitches,full_chip) "WITH_4MZ 0 DEBUG_MX 0 DEBUG_VIA 0 ACC_DEBUG 0 FHDMIM 0"
set pv_calibre(ant,default,stringvariables,full_chip) ""
set pv_calibre(ant,default,nonstringvariables,full_chip) "AP_THICKNESS 2.8"
####################################################################################

# Default for lvs target #########################################################
####################################################################################
set pv_calibre(lvs,dfmdb) "OASIS"
set pv_calibre(lvs,skip_v2lvs) ""
set pv_calibre(lvs,user_include_file) ""
set pv_calibre(lvs,maximum_results) "10000"
set pv_calibre(lvs,rule_select) ""
set pv_calibre(lvs,rule_select_bylayer) ""
set pv_calibre(lvs,exclude_cell_file) ""
set pv_calibre(lvs,input_verilog) ""
set pv_calibre(lvs,ignore_layouttext) ""

set pv_calibre(lvs,empty_subcket_file) ""
set pv_calibre(lvs,addlibs) "/projdata/synpd01/tn5/pioneer/RULEDECK_PV/TARGETS_CMD/spi.list"
set pv_calibre(lvs,spice_files) ""
set pv_calibre(lvs,lsf_remote_file) "PV_flow/lsf_remote/lsf_remote_control_file.temp"
set pv_calibre(lvs,report_option) ""
set pv_calibre(lvs,abort_on_supply_error) ""
set pv_calibre(lvs,isolate_shorts) ""
set pv_calibre(lvs,input_netlist) ""
set pv_calibre(lvs,gen_header_only) ""
set pv_calibre(lvs,pad_text_file) ""
# For lvs erc related
set pv_calibre(lvs,execute_erc) "1"
set pv_calibre(lvs,erc,maximum_results) ""
# For lvs setup exec options
set pv_calibre(lvs,hcell_list) "/home/apchen1/hcell.text"
set pv_calibre(lvs,localcpu_usage) "8"
set pv_calibre(lvs,exec_options) "-hier -turbo $pv_calibre(lvs,localcpu_usage)"
# For lvs just compare
set pv_calibre(lvs,layout_netlist) ""
# For lvs just extract spice
set pv_calibre(lvs,skip_comparison) ""
# For lvs recon
set pv_calibre(lvs,recon_enable) ""
set pv_calibre(lvs,recon,layers) "ALL"
set pv_calibre(lvs,recon,svdb) ""
set pv_calibre(lvs,recon,mode) ""
# For lvs box
set pv_calibre(lvs,box,cellnames) ""
set pv_calibre(lvs,box,cell_file) ""
set pv_calibre(lvs,box,black_box) "1"
set pv_calibre(lvs,black_box_port_mappings) " \
M1_Ai M1_TEXT M1_A	\
M1_Bi M1_TEXT M1_B	\
M2_Ai M2_TEXT M1_A	\
M2_Bi M2_TEXT M1_B	\
M3_Ai M3_TEXT M3_A	\
M3_Bi M3_TEXT M3_B	\
M4i M4_TEXT M4		\
M5i M5_TEXT M5		\
M6i M6_TEXT M6		\
M7i M7_TEXT M7		\
M8i M8_TEXT M8		\
M9i M9_TEXT M9		\
M10i M10_TEXT M10	\
M11i M11_TEXT M11	\
M12i M12_TEXT M12	\
M13i M13_TEXT M13	\
M14i M14_TEXT M14	\
M15i M15_TEXT M15	\
APi AP_TEXT AP		\
"
set pv_calibre(lvs,v2lvs,verilog_lib_file) ""
set pv_calibre(lvs,v2lvs,spice_lib_file_pinmode) ""
set pv_calibre(lvs,v2lvs,spice_lib_file_rangemode) ""
# Virtual connect
set pv_calibre(vconnect,nets,net_names) ""
set pv_calibre(vconnect,cells,cell_names) ""

set pv_calibre(lvs,virtual_connect_colon) ""
set pv_calibre(lvs,virtual_connect_depth_all) ""

# Default for lvs target > block_level ###########################################
set pv_calibre(lvs,default,nonbooleanswitches,block_level) ""
set pv_calibre(lvs,default,booleanswitches,block_level) "	\
WELL_TO_PG_CHECK 1 DS_TO_PG_CHECK 1		\
FLOATING_WELL_CHECK 1 LVSDMY4_CHECK 1	\
"
set pv_calibre(lvs,default,stringvariables,block_level) "	\
POWER_NAME \"?VDD? ?VDDA?\"		\	 
GROUND_NAME \"?VSS? ?VSSA?\"	\
"
set pv_calibre(lvs,default,nonstringvariables,block_level) ""

# Default for lvs target > full_chip ###########################################
set pv_calibre(lvs,default,nonbooleanswitches,full_chip) ""
set pv_calibre(lvs,default,booleanswitches,full_chip) "		\
WELL_TO_PG_CHECK 1 DS_TO_PG_CHECK 1		\
FLOATING_WELL_CHECK 1 LVSDMY4_CHECK 1	\
"
set pv_calibre(lvs,default,stringvariables,full_chip) "		\
POWER_NAME \"?VDD? ?VDDA?\"		\	 
GROUND_NAME \"?VSS? ?VSSA?\"	\
"
set pv_calibre(lvs,default,nonstringvariables,full_chip) ""

####################################################################################
# Default for perc target #########################################################
####################################################################################
#
set pv_calibre(fpperc,run_types) "topo p2p cd" 
set pv_calibre(finalperc,run_types) "topo p2p cd ldl" 
set pv_calibre(perc,version) "1.2b" 
set pv_calibre(perc,ignore_layouttext) ""


set pv_calibre(perc,gen_header_only) ""
set pv_calibre(perc,cnod,gen_header_only) ""
set pv_calibre(perc,skip_cnod) ""
set pv_calibre(perc,cnod,black_box_enable) ""
# if pv_calibre(perc,cnod,black_box_enable) enable, pv_calibre(perc,cnod,black_box_cell) is required
set pv_calibre(perc,cnod,black_box_cell) "CELL1 CELL2"
set pv_calibre(perc,topo,source_type) ""
set pv_calibre(perc,pad_text_file) "/home/apchen1/flow_test_files/pad_info.svrf"
#set pv_calibre(perc,lsf_remote_file) ""
set pv_calibre(perc,lsf_remote_file) "./PV_flow/lsf_remote/lsf_remote_control_file.temp"

# Default for perc target > block_level ###########################################
set pv_calibre(perc,default,nonbooleanswitches,block_level) ""
set pv_calibre(perc,default,booleanswitches,block_level) ""
set pv_calibre(perc,default,stringvariables,block_level) " \
POWER_NAME	\"?VDD? ?vdd?\"	\	 
GROUND_NAME \"?VSS? ?vss?\"	\
SIGNAL_NAME	\"?\"			\
"
set pv_calibre(perc,default,nonstringvariables,block_level) ""

# topo
set pv_calibre(perc,topo,default,nonbooleanswitches,block_level) ""
set pv_calibre(perc,topo,default,booleanswitches,block_level) "TOPO 1 LDL 1 Hi_CDM 1 CREATE_PAD_BY_TEXT 1"
set pv_calibre(perc,topo,default,stringvariables,block_level) ""
set pv_calibre(perc,topo,default,nonstringvariables,block_level) ""

# ldl
set pv_calibre(perc,ldl,default,nonbooleanswitches,block_level) ""
set pv_calibre(perc,ldl,default,booleanswitches,block_level) "TOPO 1 LDL 1 Hi_CDM 1 CREATE_PAD_BY_TEXT 1"
set pv_calibre(perc,ldl,default,stringvariables,block_level) ""
set pv_calibre(perc,ldl,default,nonstringvariables,block_level) ""

# cd
set pv_calibre(perc,cd,default,nonbooleanswitches,block_level) ""
set pv_calibre(perc,cd,default,booleanswitches,block_level) "CD 1 Hi_CDM 1 IN_DIE_MODE 0 GROUP_PWR_CLAMP 1 SET_PWR_CLAMP_RON 1 CREATE_PAD_BY_TEXT 1"
set pv_calibre(perc,cd,default,stringvariables,block_level) ""
set pv_calibre(perc,cd,default,nonstringvariables,block_level) ""

# p2p
set pv_calibre(perc,p2p,default,nonbooleanswitches,block_level) ""
set pv_calibre(perc,p2p,default,booleanswitches,block_level) "P2P 1 Hi_CDM 1 IN_DIE_MODE 0 GROUP_PWR_CLAMP 1 SET_PWR_CLAMP_RON 1 CREATE_PAD_BY_TEXT 1 ENABLE_R0_CHECK 1"
set pv_calibre(perc,p2p,default,stringvariables,block_level) ""
set pv_calibre(perc,p2p,default,nonstringvariables,block_level) ""

# cnod
set pv_calibre(perc,cnod,default,nonbooleanswitches,block_level) ""
set pv_calibre(perc,cnod,default,booleanswitches,block_level) ""
set pv_calibre(perc,cnod,default,stringvariables,block_level) " \
POWER_NAME	\"?VDD? ?vdd?\"	\	 
GROUND_NAME \"?VSS? ?vss?\"	\
SIGNAL_NAME	\"?\"			\
"
set pv_calibre(perc,cnod,default,nonstringvariables,block_level) ""

# Default for perc target > full_chip ###########################################
set pv_calibre(perc,default,nonbooleanswitches,full_chip) ""
set pv_calibre(perc,default,booleanswitches,full_chip) ""
set pv_calibre(perc,default,stringvariables,full_chip) " \
POWER_NAME	\"?VDD? ?vdd?\"	\	 
GROUND_NAME \"?VSS? ?vss?\"	\
SIGNAL_NAME	\"?\"			\
"
set pv_calibre(perc,default,nonstringvariables,full_chip) ""

# topo
set pv_calibre(perc,topo,default,nonbooleanswitches,full_chip) ""
set pv_calibre(perc,topo,default,booleanswitches,full_chip) "TOPO 1 LDL 1 Hi_CDM 1 CREATE_PAD_BY_TEXT 1"
set pv_calibre(perc,topo,default,stringvariables,full_chip) ""
set pv_calibre(perc,topo,default,nonstringvariables,full_chip) ""

# ldl
set pv_calibre(perc,ldl,default,nonbooleanswitches,full_chip) ""
set pv_calibre(perc,ldl,default,booleanswitches,full_chip) "TOPO 1 LDL 1 Hi_CDM 1 CREATE_PAD_BY_TEXT 1"
set pv_calibre(perc,ldl,default,stringvariables,full_chip) ""
set pv_calibre(perc,ldl,default,nonstringvariables,full_chip) ""

# cd
set pv_calibre(perc,cd,default,nonbooleanswitches,full_chip) ""
set pv_calibre(perc,cd,default,booleanswitches,full_chip) "CD 1 Hi_CDM 1 GROUP_PWR_CLAMP 1 CREATE_PAD_BY_TEXT 1"
set pv_calibre(perc,cd,default,stringvariables,full_chip) ""
set pv_calibre(perc,cd,default,nonstringvariables,full_chip) ""

# p2p
set pv_calibre(perc,p2p,default,nonbooleanswitches,full_chip) ""
set pv_calibre(perc,p2p,default,booleanswitches,full_chip) "P2P 1 Hi_CDM 1 GROUP_PWR_CLAMP 1 CREATE_PAD_BY_TEXT 1"
set pv_calibre(perc,p2p,default,stringvariables,full_chip) ""
set pv_calibre(perc,p2p,default,nonstringvariables,full_chip) ""

# cnod
set pv_calibre(perc,cnod,default,nonbooleanswitches,full_chip) ""
set pv_calibre(perc,cnod,default,booleanswitches,full_chip) ""
set pv_calibre(perc,cnod,default,stringvariables,full_chip) " \
POWER_NAME	\"?VDD? ?vdd?\"	\	 
GROUND_NAME \"?VSS? ?vss?\"	\
SIGNAL_NAME	\"?\"			\
"
set pv_calibre(perc,cnod,default,nonstringvariables,full_chip) ""
####################################################################################











