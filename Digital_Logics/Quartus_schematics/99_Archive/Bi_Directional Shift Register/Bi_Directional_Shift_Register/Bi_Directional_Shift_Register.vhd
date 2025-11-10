library ieee;
use ieee.std_logic_1164.all;

entity Bi_Directional_Shift_Register is
    generic (N :integer :=8);
    port(
        clk, reset  : in std_logic;
        ctrl            : in std_logic_vector(1 downto 0);              
        data            : in std_logic_vector(N-1 downto 0);
        q_reg           : out std_logic_vector(N-1 downto 0)
    );
end Bi_Directional_Shift_Register;

architecture sample of Bi_Directional_Shift_Register is
    signal s_reg, s_next : std_logic_vector(N-1 downto 0);
begin
    process(clk, reset)
    begin
        if(reset='1') then
            s_reg <= (others=>'0'); -- clear the content
        elsif (clk'event and clk='1') then
            s_reg <= s_next; -- otherwise save the next state
        end if;
    end process;

    process (ctrl, s_reg)
    begin
        case ctrl is
            when "00" =>
                s_next <= s_reg; -- no operation (to read data for serial to parallel) 
            when "01" =>
                s_next <= data(N-1) & s_reg(N-1 downto 1); -- right shift
            when "10" =>
                s_next <= s_reg(N-2 downto 0) & data(0); -- left shift
            when others =>
                s_next <= data;  -- load data (for parallel to serial)
        end case;
    end process; 
    
    q_reg <= s_reg;
end sample;
