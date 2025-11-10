library ieee;
use ieee.std_logic_1164.all;

entity fig5_1 is
	port 
	(
		k, d, h	   : in std_logic;
		b : out std_logic
	);
end fig5_1;

architecture arc of fig5_1 is
begin

	b <= (k and d) or (h and d);

end arc;
