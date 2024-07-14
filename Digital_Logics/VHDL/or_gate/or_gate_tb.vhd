library ieee;
use ieee.std_logic_1164.all;

entity or_gate_tb is
	port (Y : out std_logic );
end or_gate_tb;

architecture simulation of or_gate_tb is

component or_gate 
	port (a, b: in std_logic ; 
		c : out std_logic );
end component;

signal A, B :  std_logic ;
begin	
	A <= '0', '1' after 20 ns, '0' after 40 ns;
	B <= '0', '1' after 10 ns, '0' after 20 ns, '1' after 30 ns, '0' after 40 ns;
	
	--U0 : AND_gate port map (A=>A,B=>B,Y=>Y);
	U0 : or_gate port map (a=>A,b=>B,c=>Y);	
end;

