library IEEE;
use IEEE.std_logic_1164.all;
 
entity bejoy_4x1 is
	port(s1,s2,d00,d01,d10,d11 : in std_logic;
		 z_out : out std_logic);
end bejoy_4x1;
 
architecture arc of bejoy_4x1 is 
	component mux
		port(sx1,sx2,d0,d1 : in std_logic;
			 z : out std_logic);
	end component;
 
	component or_2
		port(a,b : in std_logic;
			 c : out std_logic);
	end component;
 
	signal intr1, intr2, intr3, intr4 : std_logic;
	begin
		mux1 : mux port map(s1,s2,d00,d01,intr1);
		mux2 : mux port map(not s1,s2, d10,d11,intr2);
		o1 : or_2 port map(intr1, intr2, z_out);
	end arc;
 
library ieee;
use ieee.std_logic_1164.all;
 
entity mux is
	port(sx1,sx2,d0,d1 :in std_logic;
	     z: out std_logic);
end mux;
 
architecture arc of mux is
	signal z1,z2: std_logic;
begin
	z1 <= d0 and (not sx1) and (not sx2);
	z2 <= (d1 and (not sx1) and sx2);
	z<= z1 or z2;
end arc;
 
entity or_2 is
	port(a,b : in bit;
		 c : out bit);
end or_2;
architecture arc of or_2 is
begin
	c<=a or b;
end arc;