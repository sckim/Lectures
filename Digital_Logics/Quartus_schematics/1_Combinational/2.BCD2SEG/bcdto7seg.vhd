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
-- CREATED		"Thu Jul 10 15:19:06 2025"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY bcdto7seg IS 
	PORT
	(
		SW :  IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
		HEX :  OUT  STD_LOGIC_VECTOR(6 DOWNTO 0)
	);
END bcdto7seg;

ARCHITECTURE bdf_type OF bcdto7seg IS 

ATTRIBUTE black_box : BOOLEAN;
ATTRIBUTE noopt : BOOLEAN;

COMPONENT \7447_0\
	PORT(LTN : IN STD_LOGIC;
		 B : IN STD_LOGIC;
		 C : IN STD_LOGIC;
		 D : IN STD_LOGIC;
		 RBIN : IN STD_LOGIC;
		 BIN : IN STD_LOGIC;
		 A : IN STD_LOGIC;
		 OB : OUT STD_LOGIC;
		 OC : OUT STD_LOGIC;
		 OE : OUT STD_LOGIC;
		 OD : OUT STD_LOGIC;
		 OF : OUT STD_LOGIC;
		 OG : OUT STD_LOGIC;
		 OA : OUT STD_LOGIC);
END COMPONENT;
ATTRIBUTE black_box OF \7447_0\: COMPONENT IS true;
ATTRIBUTE noopt OF \7447_0\: COMPONENT IS true;

SIGNAL	SYNTHESIZED_WIRE_3 :  STD_LOGIC;


BEGIN 
SYNTHESIZED_WIRE_3 <= '1';



b2v_inst : 7447_0
PORT MAP(LTN => SYNTHESIZED_WIRE_3,
		 B => SW(1),
		 C => SW(2),
		 D => SW(3),
		 RBIN => SYNTHESIZED_WIRE_3,
		 BIN => SYNTHESIZED_WIRE_3,
		 A => SW(0),
		 OB => HEX(1),
		 OC => HEX(2),
		 OE => HEX(4),
		 OD => HEX(3),
		 OF => HEX(5),
		 OG => HEX(6),
		 OA => HEX(0));



END bdf_type;