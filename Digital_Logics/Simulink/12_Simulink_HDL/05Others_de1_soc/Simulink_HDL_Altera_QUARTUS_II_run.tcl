# HDL Coder Downstream Integration Tcl Script

set myTool "Altera QUARTUS II 18.1.0"
set myProject "Simulink_HDL_quartus"
set myProjectFile "Simulink_HDL_quartus.qpf"
set myTopLevelEntity "Simulink_HDL"
set Family "Cyclone V"
set Device "5CSEMA5F31C6"
set Package ""
set Speed ""
set UseTimeQuest "ON"

# Open existing project
puts "### Open existing $myTool project D:\\Github\\Matlab\\Logics\\de1_soc\\quartus_prj\\Simulink_HDL_quartus.qpf"
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

