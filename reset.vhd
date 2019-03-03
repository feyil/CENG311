library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity rst_gen is port (reset: out std_logic);
end rst_gen;

architecture behavioral of rst_gen is
	constant rst_period: time := 1 us;
begin
	reset <= '1' after 0 us, '0' after rst_period;
end behavioral;