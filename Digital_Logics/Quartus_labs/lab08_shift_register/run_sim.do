# run_sim.do : ModelSim batch script (Lab 08)
# usage (in this folder):  vsim -c -do run_sim.do
if {[file exists work]} {vdel -lib work -all}
vlib work
vlog siso_reg.v piso74165.v univ4.v johnson.v
vlog tb_siso.v tb_piso.v tb_univ.v tb_johnson3.v tb_johnson4.v
vsim -c -onfinish stop work.tb_siso
run -all
quit -sim
vsim -c -onfinish stop work.tb_piso
run -all
quit -sim
vsim -c -onfinish stop work.tb_univ
run -all
quit -sim
vsim -c -onfinish stop work.tb_johnson3
run -all
quit -sim
vsim -c -onfinish stop work.tb_johnson4
run -all
quit -sim
quit -f
