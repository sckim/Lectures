# run_sim.do : ModelSim batch script (Lab 10)
# usage (in this folder):  vsim -c -do run_sim.do
if {[file exists work]} {vdel -lib work -all}
vlib work
vlog ff_lib.v seq_d_ex14_4.v seq_sr_ex14_3.v seq_jk_ex14_6.v design15.v gray_74138.v johnson_lockout.v
vlog tb_seq_ex14_4.v tb_sr_jk_ex14.v tb_design15.v tb_gray_74138.v tb_johnson_lockout.v
vsim -c -onfinish stop work.tb_seq_ex14_4
run -all
quit -sim
vsim -c -onfinish stop work.tb_sr_jk_ex14
run -all
quit -sim
vsim -c -onfinish stop work.tb_design15
run -all
quit -sim
vsim -c -onfinish stop work.tb_gray_74138
run -all
quit -sim
vsim -c -onfinish stop work.tb_johnson_lockout
run -all
quit -sim
quit -f
