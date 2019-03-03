library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;
	use ieee.numeric_std.all;

library fey;
	use fey.uP.all;

entity testbench is
end testbench;

architecture imp of testbench is
	signal clk: std_logic;
	signal reset: std_logic;
	signal opfetch: std_logic;
	signal wr, rd: std_logic;
	signal addressbus, databus: std_logic_vector(15 downto 0);

begin
	clock_gen: clk_gen port map(clk);
	reset_gen: rst_gen port map(reset);
	processor: u311_1 port map(clk, reset, opfetch, '0', open, wr, rd, addressbus, databus);
	rom: rom1024 port map('0', opfetch, addressbus(9 downto 0), databus);
	ram: ram1024 port map(reset, '0', wr, rd, addressbus(9 downto 0), databus);
end imp;