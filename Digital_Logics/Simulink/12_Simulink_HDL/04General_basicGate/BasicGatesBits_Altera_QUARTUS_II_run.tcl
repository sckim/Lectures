# HDL Coder Downstream Integration Tcl Script

set myTool "Altera QUARTUS II 18.1.0"
set myProject "BasicGatesBits_quartus"
set myProjectFile "BasicGatesBits_quartus.qpf"
set myTopLevelEntity "BasicGatesBits"
set Family "Cyclone V"
set Device "5CSEMA5F31C6"
set Package ""
set Speed ""
set UseTimeQuest "ON"

# Open existing project
puts "### Open existing $myTool project hdl_prj\\quartus_prj\\BasicGatesBits_quartus.qpf"
load_package flow
project_open -current_revision $myProject

# Running PAR
puts "### Running PAR in $myTool ..."
execute_module -tool fit
puts "### PAR Complete."

# Running PostPARTiming
puts "### Running PostPARTiming in $myTool ..."
create_timing_netlist
read_sdc
update_timing_netlist
report_clock_fmax_summary
report_timing -npaths 1
report_timing -npaths 3 -file ${myTopLevelEntity}_postroute.tqr
puts "### PostPARTiming Complete."

# Close project
puts "### Close $myTool project."
project_close

