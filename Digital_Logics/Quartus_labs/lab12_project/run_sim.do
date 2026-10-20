# run_sim.do : ModelSim batch script (Lab 12)
# usage (in this folder):  vsim -c -do run_sim.do
# FAST_TICK: Mod50MHz (Part C) counts 4 clocks per second. The other testbenches set N themselves.
if {[file exists work]} {vdel -lib work -all}
vlib work
vlog +define+FAST_TICK clk_div.v bcd_cnt.v cnt60.v cnt24.v btn_edge.v hex7seg.v digital_clock.v
vlog +define+FAST_TICK Mod50MHz.v ttl_parts.v ttl_clock.v traffic.v safe.v
vlog +define+FAST_TICK tb_clk_div.v tb_counters.v tb_btn_edge.v tb_digital_clock.v tb_ttl_clock.v tb_traffic.v tb_safe.v
vsim -c -onfinish stop work.tb_clk_div
run -all
quit -sim
vsim -c -onfinish stop work.tb_counters
run -all
quit -sim
vsim -c -onfinish stop work.tb_btn_edge
run -all
quit -sim
vsim -c -onfinish stop work.tb_digital_clock
run -all
quit -sim
vsim -c -onfinish stop work.tb_ttl_clock
run -all
quit -sim
vsim -c -onfinish stop work.tb_traffic
run -all
quit -sim
vsim -c -onfinish stop work.tb_safe
run -all
quit -sim
quit -f
