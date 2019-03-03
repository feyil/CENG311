library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

package uP is


component LE16 is port(
	S: in std_logic_vector(2 downto 0);
	A, B: in std_logic_vector(15 downto 0);
	x: out std_logic_vector(15 downto 0));

	end component;

component AE16 is port(
	S: in std_logic_vector(2 downto 0);
	A, B: in std_logic_vector(15 downto 0);
	Y: out std_logic_vector(15 downto 0));
	
	end component;

component FA16 is port(
	A : in std_logic_vector(15 downto 0);
	B : in std_logic_vector(15 downto 0);
	F : out std_logic_vector(15 downto 0);
	cIn : in std_logic;
	unsigned_overflow: out std_logic;
	signed_overflow: out std_logic);
	
	end component;


component shifter16 is port(
	S: in std_logic_vector(1 downto 0);
	A: in std_logic_vector(15 downto 0);
	Y: out std_logic_vector(15 downto 0);
	carryOut: out std_logic);

	end component;

component reg16 is port(
	d: in std_logic_vector(15 downto 0);
	ld: in std_logic;
	clr: in std_logic;
	clk: in std_logic;
	q: out std_logic_vector(15 downto 0));
	
	end component;

component mux4x16 is port(
	S: in std_logic_vector(1 downto 0);
	x0, x1, x2, x3: in std_logic_vector(15 downto 0);
	y: out std_logic_vector(15 downto 0));

	end component;
	
component mux2 is port(
	s: in std_logic;
	x0, x1: in std_logic_vector(15 downto 0);
	y: out std_logic_vector(15 downto 0));
	end component;

component regfile is port(
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
	end component;

component buf is port(
	enable: in std_logic;
	input: in std_logic_vector(15 downto 0);
	output: out std_logic_vector(15 downto 0));
end component;


component buf2 is port(
	enable: in std_logic;
	direction: in std_logic;
	input: inout std_logic_vector(15 downto 0);
	output: inout std_logic_vector(15 downto 0));
	end component;

component addsub16 is port(
	sub: in std_logic;
	in1, in2: in std_logic_vector(15 downto 0);
	output: out std_logic_vector(15 downto 0));
end component;

component ALU is port(
	S: in std_logic_vector(4 downto 0);
	A, B: in std_logic_vector(15 downto 0);
	F: out std_logic_vector(15 downto 0);
	unsigned_overflow: out std_logic;
	signed_overflow: out std_logic;
	carry: out std_logic);
end component;

component controller is port(
	clk: in std_logic;
	reset: in std_logic;
	pcen, den, dir, aen: out std_logic;
	SPload, PCload, IRload: out std_logic;
	Psel, Ssel, Rsel, Osel: out std_logic_vector(1 downto 0);
	sub2: out std_logic;
	jmpMux: out std_logic;
	opfetch: out std_logic;
	IR: in std_logic_vector(4 downto 0);
	zero: in std_logic;
	ALUsel: out std_logic_vector(4 downto 0);
	we, rae, rbe: out std_logic;
	int: in std_logic;
	inta, wr, rd: out std_logic);
end component;

component datapath is port(
	clk: in std_logic;
	reset: in std_logic;
	pcen, den, dir, aen: in std_logic;
	SPload, PCload, IRload: in std_logic;
	Pse1, Ssel, Rse1, Osel: in std_logic_vector(1 downto 0);
	sub2: in std_logic;
	jmpMux: in std_logic;
	IR: out std_logic_vector(4 downto 0);
	zero: out std_logic;
	ALUse1: in std_logic_vector(4 downto 0);
	we, rae, rbe: in std_logic;
	Buf2_out: out std_logic_vector(15 downto 0);
	Buf3_out: inout std_logic_vector(15 downto 0));
end component;

component clk_gen is port(
	clk: out std_logic);
end component;

component rst_gen is port(
	reset: out std_logic);
end component;

component u311_1 is port(
	clk: in std_logic;
	reset: in std_logic;

	opfetch: out std_logic;
	INT: in std_logic;
	INTA: out std_logic;
	WR: out std_logic;
	RD: out std_logic;
	A: out std_logic_vector(15 downto 0);
	D: inout std_logic_vector(15 downto 0));
end component;

component rom1024 is port(
	cs : in std_logic;
	oe : in std_logic;
	addr : in std_logic_vector(9 downto 0);
	data : out std_logic_vector(15 downto 0));
end component;

component ram1024 is port(
	rst: in std_logic;
	cs: in std_logic;
	wr: in std_logic;
	rd: in std_logic;
	addr: in std_logic_vector(9 downto 0);
	data: inout std_logic_vector(15 downto 0));
end component;
			
end uP;