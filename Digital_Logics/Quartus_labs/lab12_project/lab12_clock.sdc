# lab12_clock.sdc : timing constraint for the Part B digital clock (DE1-SoC CLOCK_50 = 50 MHz, period 20 ns)
create_clock -name CLOCK_50 -period 20.000 [get_ports {CLOCK_50}]
derive_clock_uncertainty
