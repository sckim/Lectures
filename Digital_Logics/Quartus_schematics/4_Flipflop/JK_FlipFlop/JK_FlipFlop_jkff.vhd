-- Copyright (C) 2018  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel FPGA IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Intel and sold by Intel or its authorized distributors.  Please
-- refer to the applicable agreement for further details.

-- PROGRAM		"Quartus Prime"
-- VERSION		"Version 18.1.0 Build 625 09/12/2018 SJ Lite Edition"
-- CREATED		"Thu Jul 10 15:32:14 2025"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY JK_FlipFlop_jkff IS 
	PORT
	(
		J :  IN  STD_LOGIC;
		K :  IN  STD_LOGIC;
		CP :  IN  STD_LOGIC;
		/Clr :  IN  STD_LOGIC;
		Q :  OUT  STD_LOGIC
	);
END JK_FlipFlop_jkff;

ARCHITECTURE bdf_type OF JK_FlipFlop_jkff IS 

SIGNAL	SYNTHESIZED_WIRE_0 :  STD_LOGIC;


BEGIN 
SYNTHESIZED_WIRE_0 <= '1';



PROCESS(CP,/Clr,SYNTHESIZED_WIRE_0)
VARIABLE synthesized_var_for_Q : STD_LOGIC;
BEGIN
IF (/Clr = '0') THEN
	synthesized_var_for_Q := '0';
ELSIF (SYNTHESIZED_WIRE_0 = '0') THEN
	synthesized_var_for_Q := '1';
ELSIF (RISING_EDGE(CP)) THEN
	synthesized_var_for_Q := (NOT(synthesized_var_for_Q) AND J) OR (synthesized_var_for_Q AND (NOT(K)));
END IF;
	Q <= synthesized_var_for_Q;
END PROCESS;



END bdf_type;