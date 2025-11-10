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

LIBRARY altera;
USE altera.maxplus2.all; 

LIBRARY work;

ENTITY 7447_0 IS 
PORT 
( 
	LTN	:	IN	 STD_LOGIC;
	B	:	IN	 STD_LOGIC;
	C	:	IN	 STD_LOGIC;
	D	:	IN	 STD_LOGIC;
	RBIN	:	IN	 STD_LOGIC;
	BIN	:	IN	 STD_LOGIC;
	A	:	IN	 STD_LOGIC;
	OB	:	OUT	 STD_LOGIC;
	OC	:	OUT	 STD_LOGIC;
	OE	:	OUT	 STD_LOGIC;
	OD	:	OUT	 STD_LOGIC;
	OF	:	OUT	 STD_LOGIC;
	OG	:	OUT	 STD_LOGIC;
	OA	:	OUT	 STD_LOGIC
); 
END 7447_0;

ARCHITECTURE bdf_type OF 7447_0 IS 
BEGIN 

-- instantiate macrofunction 

b2v_inst : 7447
PORT MAP(LTN => LTN,
		 B => B,
		 C => C,
		 D => D,
		 RBIN => RBIN,
		 BIN => BIN,
		 A => A,
		 OB => OB,
		 OC => OC,
		 OE => OE,
		 OD => OD,
		 OF => OF,
		 OG => OG,
		 OA => OA);

END bdf_type; 