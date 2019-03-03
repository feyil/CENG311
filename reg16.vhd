library ieee;
library fey;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use fey.uP.all;

entity reg16 is port(
	d: in std_logic_vector(15 downto 0);
	ld: in std_logic;
	clr: in std_logic;
	clk: in std_logic;
	q: out std_logic_vector(15 downto 0)
);
end reg16;

architecture description of reg16 is

begin
	process(clk, clr)
	begin
		if clr = '1' then
			q <= x"0000";
		elsif rising_edge(clk) then
			if ld = '1' then
				q <= d;
			end if;
		end if;
	end process;
end description;
