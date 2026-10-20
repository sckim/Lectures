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

if { ! [ file exists $myProjectFile ] } {
    # Create new project
    puts "### Create new $myTool project <a href=\"matlab:downstream.handle('Model','Simulink_HDL').openTargetTool;\">hdl_prj\\quartus_prj\\Simulink_HDL_quartus.qpf</a>"
    load_package flow
    project_new $myProject

} else {
    # Open existing project
    puts "### Open existing $myTool project <a href=\"matlab:downstream.handle('Model','Simulink_HDL').openTargetTool;\">hdl_prj\\quartus_prj\\Simulink_HDL_quartus.qpf</a>"
    load_package flow
    project_open -current_revision $myProject

    # Remove Old HDL source files
    remove_all_global_assignments -name VHDL_FILE
    remove_all_global_assignments -name VERILOG_FILE
    remove_all_global_assignments -name SDC_FILE
    remove_all_instance_assignments -name LOCATION

}

# Set project properties
puts "### Set $myTool project properties"
set_global_assignment -name FAMILY $Family
set_global_assignment -name DEVICE $Device
set_global_assignment -name USE_TIMEQUEST_TIMING_ANALYZER $UseTimeQuest

# Add HDL source files
puts "### Update $myTool project with HDL source files"
 
set_global_assignment -name VHDL_FILE "../hdlsrc/Simulink_HDL/Simulink_HDL.vhd"
set_global_assignment -name TOP_LEVEL_ENTITY Simulink_HDL

# Close project
puts "### Close $myTool project."
project_close

