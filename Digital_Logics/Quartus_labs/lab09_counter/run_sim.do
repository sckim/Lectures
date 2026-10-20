# run_sim.do : ModelSim batch script (Lab 09)
# usage (in this folder):  vsim -c -do run_sim.do
if {[file exists work]} {vdel -lib work -all}
vlib work
vlog clkdiv.v clk_div.v div_top.v ripple.v sync4.v bcd2seg.v bcd_counter.v gray3.v
vlog tb_div.v tb_ripple.v tb_mod10.v tb_sync4.v tb_bcd2seg.v tb_bcd.v tb_gray.v
vsim -c -onfinish stop work.tb_div
run -all
quit -sim
vsim -c -onfinish stop work.tb_ripple
run -all
quit -sim
vsim -c -onfinish stop work.tb_mod10
run -all
quit -sim
vsim -c -onfinish stop work.tb_sync4
run -all
quit -sim
vsim -c -onfinish stop work.tb_bcd2seg
run -all
quit -sim
vsim -c -onfinish stop work.tb_bcd
run -all
quit -sim
vsim -c -onfinish stop work.tb_gray
run -all
quit -sim
quit -f
