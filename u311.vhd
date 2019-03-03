
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

package u311 is

component FA is port(
	carryIn: in std_logic;
	carryOut: out std_logic;
	x, y : in std_logic;
	s : out std_logic);

	end component;

component LE is port(
	S: in std_logic_vector(2 downto 0);
	a, b: in std_logic;
	x: out std_logic);
	
	end component;

component AE is port(
	S: in std_logic_vector(2 downto 0);
	a, b: in std_logic;
	x: out std_logic);

	end component;


component mux4 is port(
	S: in std_logic_vector(1 downto 0);
	x0, x1, x2, x3: in std_logic;
	y: out std_logic);

	end component;
end u311;
	