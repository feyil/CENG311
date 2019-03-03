library ieee;
library fey;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use fey.uP.all;

entity regfile is port(
	clk: in std_logic;
	reset: in std_logic;
	we: in std_logic;
	wa: in std_logic_vector(2 downto 0);
	d: in std_logic_vector(15 downto 0);
	rbe: in std_logic;
	rae: in std_logic;
	raa: in std_logic_vector(2 downto 0);
	rba: in std_logic_vector(2 downto 0);
	portA: out std_logic_vector(15 downto 0);
	portB: out std_logic_vector(15 downto 0)
);
end regfile;

architecture imp of regfile is
	subtype reg is std_logic_vector(15 downto 0);
	type regArray is array(0 to 7) of reg;
	signal RF: regArray;
begin

WritePort:Process(clk,reset)
begin
	if(reset='1') then
		for I in 0 to 7 loop
			RF(I) <= (others => '0');
		end loop;
	elsif(we = '1') then
			RF(conv_integer(WA)) <= D;
	end if;
end process;

ReadPortA: Process(rae, raa)
begin
	if(rae = '1') then
		PortA <= RF(conv_integer(RAA));
	else
		PortA <= (others => 'Z');
	end if;
end process;

ReadPortB: Process(rbe, rba)
begin
	if(rbe = '1') then
		PortB <= RF(conv_integer(rba));
	else
		PortB <= (others => 'Z');
	end if;
end process;

end imp;





