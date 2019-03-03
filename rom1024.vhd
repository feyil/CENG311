library ieee;
library fey;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use fey.u311.all;
use fey.opcodes.all;

entity rom1024 is port(
	cs : in std_logic;
	oe : in std_logic;
	addr : in std_logic_vector(9 downto 0);
	data : out std_logic_vector(15 downto 0));
end rom1024;

architecture imp of rom1024 is
subtype cell is std_logic_vector(15 downto 0);
type rom_type is array(0 to 17) of cell;


constant ROM: rom_type := (
	movi&"00011111111",
	sl&"00000000000",
	sl&"00000000000",
	sl&"00000000000",
	sl&"00000000000",
	sl&"00000000000",
	sl&"00000000000",
	sl&"00000000000",
	sl&"00000000000",
	movi&"01011111111",
	add&"00001000000",
	mov_sp_r&"00000000000",
	movi&"00100000011",
	push&"00000000100",
	push&"00000001000",
	pop&H&"00000000",
	push&"00000000100",
	halt&"00000000000"
	);
begin
	process(cs, oe, addr)
	begin
		if (cs = '0' and oe = '1') then
			data <= ROM(conv_integer(addr));
		else data <= (others => 'Z');
		end if;
	end process;
end imp;
