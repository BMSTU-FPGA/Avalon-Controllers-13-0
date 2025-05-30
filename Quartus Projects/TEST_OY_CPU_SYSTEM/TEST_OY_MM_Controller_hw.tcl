# TCL File Generated by Component Editor 13.0sp1
# Sun Apr 27 01:07:50 MSD 2025
# DO NOT MODIFY


# 
# TEST_OY_MM_Controller "TEST_OY_MM_Controller" v1.0
#  2025.04.27.01:07:50
# 
# 

# 
# request TCL package from ACDS 13.1
# 
package require -exact qsys 13.1


# 
# module TEST_OY_MM_Controller
# 
set_module_property DESCRIPTION ""
set_module_property NAME TEST_OY_MM_Controller
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME TEST_OY_MM_Controller
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL AUTO
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL TEST_OY_Controller
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
add_fileset_file memory_map_common.vhd VHDL PATH ../TEST_OY_Controller_Working/memory_map_common.vhd
add_fileset_file TEST_OY_Controller.vhdl VHDL PATH ../TEST_OY_Controller_Working/TEST_OY_Controller.vhdl TOP_LEVEL_FILE
add_fileset_file TEST_OY_Patterned.vhd VHDL PATH ../TEST_OY_Controller_Working/TEST_OY_Patterned.vhd
add_fileset_file OperationDevice.vhdl VHDL PATH ../TEST_OY_Controller_Working/OpAut/OperationDevice.vhdl
add_fileset_file ControlUnit.vhdl VHDL PATH ../TEST_OY_Controller_Working/OpAut/operation_device/ControlUnit.vhdl
add_fileset_file OperationAutomata.vhdl VHDL PATH ../TEST_OY_Controller_Working/OpAut/operation_device/OperationAutomata.vhdl


# 
# parameters
# 
add_parameter n INTEGER 16
set_parameter_property n DEFAULT_VALUE 16
set_parameter_property n DISPLAY_NAME n
set_parameter_property n TYPE INTEGER
set_parameter_property n UNITS None
set_parameter_property n HDL_PARAMETER true


# 
# display items
# 


# 
# connection point avalon_slave_0
# 
add_interface avalon_slave_0 avalon end
set_interface_property avalon_slave_0 addressUnits WORDS
set_interface_property avalon_slave_0 associatedClock clock
set_interface_property avalon_slave_0 associatedReset reset
set_interface_property avalon_slave_0 bitsPerSymbol 8
set_interface_property avalon_slave_0 burstOnBurstBoundariesOnly false
set_interface_property avalon_slave_0 burstcountUnits WORDS
set_interface_property avalon_slave_0 explicitAddressSpan 0
set_interface_property avalon_slave_0 holdTime 0
set_interface_property avalon_slave_0 linewrapBursts false
set_interface_property avalon_slave_0 maximumPendingReadTransactions 0
set_interface_property avalon_slave_0 readLatency 0
set_interface_property avalon_slave_0 readWaitTime 1
set_interface_property avalon_slave_0 setupTime 0
set_interface_property avalon_slave_0 timingUnits Cycles
set_interface_property avalon_slave_0 writeWaitTime 0
set_interface_property avalon_slave_0 ENABLED true
set_interface_property avalon_slave_0 EXPORT_OF ""
set_interface_property avalon_slave_0 PORT_NAME_MAP ""
set_interface_property avalon_slave_0 SVD_ADDRESS_GROUP ""

add_interface_port avalon_slave_0 avs_chipselect chipselect Input 1
add_interface_port avalon_slave_0 avs_address address Input 2
add_interface_port avalon_slave_0 avs_read read Input 1
add_interface_port avalon_slave_0 avs_readdata readdata Output 32
add_interface_port avalon_slave_0 avs_write write Input 1
add_interface_port avalon_slave_0 avs_writedata writedata Input 32
add_interface_port avalon_slave_0 avs_byteenable byteenable Input 4
add_interface_port avalon_slave_0 avs_waitrequest waitrequest Output 1
set_interface_assignment avalon_slave_0 embeddedsw.configuration.isFlash 0
set_interface_assignment avalon_slave_0 embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment avalon_slave_0 embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment avalon_slave_0 embeddedsw.configuration.isPrintableDevice 0


# 
# connection point clock
# 
add_interface clock clock end
set_interface_property clock clockRate 0
set_interface_property clock ENABLED true
set_interface_property clock EXPORT_OF ""
set_interface_property clock PORT_NAME_MAP ""
set_interface_property clock SVD_ADDRESS_GROUP ""

add_interface_port clock csi_clk clk Input 1


# 
# connection point reset
# 
add_interface reset reset end
set_interface_property reset associatedClock clock
set_interface_property reset synchronousEdges DEASSERT
set_interface_property reset ENABLED true
set_interface_property reset EXPORT_OF ""
set_interface_property reset PORT_NAME_MAP ""
set_interface_property reset SVD_ADDRESS_GROUP ""

add_interface_port reset rsi_reset reset Input 1


# 
# connection point interrupt_sender_0
# 
add_interface interrupt_sender_0 interrupt end
set_interface_property interrupt_sender_0 associatedAddressablePoint avalon_slave_0
set_interface_property interrupt_sender_0 associatedClock clock
set_interface_property interrupt_sender_0 associatedReset reset
set_interface_property interrupt_sender_0 ENABLED true
set_interface_property interrupt_sender_0 EXPORT_OF ""
set_interface_property interrupt_sender_0 PORT_NAME_MAP ""
set_interface_property interrupt_sender_0 SVD_ADDRESS_GROUP ""

add_interface_port interrupt_sender_0 ins_irq irq Output 1

