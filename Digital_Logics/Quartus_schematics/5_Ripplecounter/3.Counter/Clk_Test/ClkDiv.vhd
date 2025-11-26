library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity Clk_Divider is
	port (clk : in std_logic;
		clk_120Hz : out std_logic);
		--Temp : out std_logic_vector(36 downto 0));
end Clk_Divider;

architecture a of Clk_Divider is
signal cnt : std_logic_vector(12 downto 0);
signal buf : std_logic;
begin
	--Temp <= (others => 'Z');
	clk_120Hz <= buf;
	process(clk)
	begin
		if clk'event and clk = '1' then
			if cnt < "1101000001011" then
				cnt <= cnt + 1;
				buf <= buf;
			else
				cnt <= "0000000000000";
				buf <= not buf;
			end if;
		end if;
	end process;
end a;
