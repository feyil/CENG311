library ieee;
library fey;

use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use fey.u311.all;

entity shifter16 is port(
	S: in std_logic_vector(1 downto 0);
	A: in std_logic_vector(15 downto 0);
	Y: out std_logic_vector(15 downto 0);
	carryOut: out std_logic;
	zero: out std_logic
);
end shifter16;

architecture imp of shifter16 is
begin
	process(S)
		begin
			if(S = "01") then
				carryOut <= A(15);
			elsif(S="10") then
				carryOut <= A(0);
			end if;
	end process;

	U0: mux4 port map(S, A(0), '0', A(1), A(1), Y(0));
	U1_14: for I in 1 to 14 generate
			UX: mux4 port map(S, A(I), A(I-1), A(I+1), A(I+1), Y(I));
		end generate U1_14;
	U15: mux4 port map(S, A(15), A(14), '0', A(0), Y(15));

	process(A,S)
		begin
			if(S = "00") then
				if(A = "0000") then
					zero <= '1';
				else
					zero <= '0';
				end if;
			end if;
	end process;
end imp;













