# run_sim.do : ModelSim batch script (Lab 11)
# usage (in this folder):  vsim -c -do run_sim.do
if {[file exists work]} {vdel -lib work -all}
vlib work
vlog det101_hand.v det101_mealy.v det101_moore.v det101_fsm_top.v
vlog tb_det101.v
vsim -c -onfinish stop work.tb_det101
run -all
quit -sim
quit -f
