library ieee;
library fey;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
use IEEE.std_logic_arith.all;
use IEEE.numeric_bit.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_signed.all;
use IEEE.std_logic_unsigned.all;
use IEEE.math_real.all;
use IEEE.math_complex.all;
use fey.uP.all;

entity controller is port(
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
end controller;

architecture imp of controller is
type state_type is (
	s_strt,
	s_ftch,
	s_dcd,
	s_dcd2,
	s_mov,
	s_add,
	s_sub,
	s_and,
	s_or,
	s_not,
	s_inc,
	s_dec,
	s_sr,
	s_sl,
	s_rr,
	s_clr,
	s_jmp,
	s_call,
	s_ret,
	s_nop,
	s_halt,
	s_psh,
	s_psh2,
	s_pop,
	s_pop2,
	s_wrt,
	s_read,
	s_movi,
	s_mvspr,
	s_mvrsp,
	s_r_c1,
	s_r_c2,
	s_r_c3,
	s_w_c1,
	s_w_c2,
	s_w_c3,
	s_int_c1,
	s_int_c2,
	s_int_c3);

	signal state: state_type := s_strt;
	signal zero_flag: std_logic;

begin
	NEXT_STATE_LOGIC: process(clk, reset)
		variable int_occr: boolean := false;
	begin
		if(reset = '1') then
			state <= s_strt;
		elsif(int = '1' and int_occr=false) then
			int_occr := true;
		elsif(clk'event and clk='1') then
			case state is
				when s_strt => state <= s_ftch after 1 ns;
				when s_ftch => state <= s_dcd after 1 ns;
				when s_dcd2 =>
					case IR is
						when "00000" => state <= s_mov after 1 ns;
						when "00001" => state <= s_add after 1 ns;
						when "00010" => state <= s_sub after 1 ns;
						when "00011" => state <= s_and after 1 ns;
						when "00100" => state <= s_or after 1 ns;
						when "00101" => state <= s_not after 1 ns;
						when "00110" => state <= s_inc after 1 ns;
						when "00111" => state <= s_dec after 1 ns;
						when "01000" => state <= s_sr after 1 ns;
						when "01001" => state <= s_sl after 1 ns;
						when "01011" => state <= s_jmp after 1 ns;
						when "01100" => if(zero_flag = '0') then state <= s_jmp after 1 ns;
								elsif(zero_flag = '1') then state <= s_nop after 1 ns;
								end if;
						when "01101" => if(zero_flag = '0') then state <= s_jmp after 1 ns;
								elsif(zero_flag = '1') then state <= s_nop after 1 ns;
								end if;
						when "01110" => state <= s_call after 1 ns;
						when "01111" => state <= s_ret after 1 ns;
						when "10000" => state <= s_nop after 1 ns;
						when "10001" => state <= s_halt after 1 ns;
						when "10010" => state <= s_psh after 1 ns;
						when "10011" => state <= s_pop after 1 ns;
						when "10100" => state <= s_wrt after 1 ns;
						when "10101" => state <= s_read after 1 ns;
						when "10110" => state <= s_movi after 1 ns;
						when "10111" => state <= s_mvspr after 1 ns;
						when "11000" => state <= s_mvrsp after 1 ns;
						when others =>
							state <= s_strt after 1 us;
					end case;
				
				when s_halt => state <= s_halt after 1 ns;
				when s_wrt => state <= s_w_c1 after 1 ns;
				when s_read => state <= s_r_c1 after 1 ns;
				when s_w_c1 => state <= s_w_c2 after 1 ns;
				when s_r_c1 => state <= s_r_c2 after 1 ns;
				when s_w_c2 => state <= s_w_c3 after 1 ns;
				when s_r_c2 => state <= s_r_c3 after 1 ns;
				when s_int_c1 => state <= s_int_c2 after 1 ns;
				when s_int_c2 => state <= s_int_c3 after 1 ns;

				when others =>
					if(int_occr = true) then
						state <= s_int_c1 after 1 ns;
						inta <= '1' after 1 ns;
						int_occr := false;

					elsif(int_occr = false) then
						state <= s_ftch after 1 ns;
					end if;
			
			end case;
		end if;

	if(clk'event and clk='0') then
		case state is
			when s_psh => state <= s_psh2 after 1 ns;
			when s_pop => state <= s_pop2 after 1 ns;
			when s_dcd => state <= s_dcd2 after 1 ns;
			when others =>
		end case;
	end if;
end process;

OUTPUT_LOGIC: process(state)
begin
	case state is
		when s_strt =>
			inta <= 'Z';
			WR <= 'Z';
			RD <= 'Z';
			opfetch <= 'Z';
			pcen <= '0';
			den <= '0';
			dir <= '0';
			aen <= '0';
			SPload <= '0';
			PCload <= '0';
			IRload <= '0';
			Psel <= "XX";
			Ssel <= "XX";
			Osel <= "XX";
			ALUsel <= "XXXXX";
			Rsel <= "XX";
			sub2 <= 'X';
			jmpMux <= 'X';
			we <= '0';
			rbe <= '0';
			rae <= '0';
		
		when s_ftch =>
			case IR is
				when "00001" =>
					if(zero = '1') then zero_flag <= '1';
					else zero_flag <= '0';
					end if;
				when "00111" =>
					if(zero = '1') then zero_flag <= '1';
					else zero_flag <= '0';
					end if;
				when "00010" =>
					if(zero = '1') then zero_flag <= '1';
					else zero_flag <= '0';
					end if;
				when "00110" =>
					if(zero = '1') then zero_flag <= '1';
					else zero_flag <= '0';
					end if;
				when others => --Look what will happen
 			end case;
			inta <= 'Z';
			WR <= 'Z';
			RD <= 'Z';
			opfetch <= '1' after 2 ns;
			pcen <= '0';
			den <= '1';
			dir <= '0';
			aen <= '1';
			SPload <= '0';
			PCload <= '0';
			IRload <= '1';
			Psel <= "11";
			Ssel <= "00";
			Osel <= "00";
			ALUsel <= "XXXXX";
			Rsel <= "XX";
			sub2 <= 'X';
			jmpMux <= '0';
			we <= '0';
			rbe <= '0';
			rae <= '0';
		
		when s_dcd =>
			inta <= 'Z';
			WR <= 'Z';
			RD <= 'Z';
			opfetch <= '0';
			pcen <= '0';
			den <= '0';
			dir <= '0';
			aen <= '0';
			case IR is
				when "10011" => SPload <= '1'; --for pop inst.
						sub2 <= '0';
				when "01111" => SPload <= '1'; --for ret inst.
						sub2 <= '0';
				when others => SPload <= '0';
						sub2 <= 'X';
			end case;
			PCload <= '0';
			IRload <= '0';
			Psel <= "XX";
			Ssel <= "11";
			Osel <= "XX";
			ALUsel <= "XXXXX";
			Rsel <= "XX";
			sub2 <= '0';
			jmpMux <= '0';
			we <= '0';
			rbe <= '0';
			rae <= '0';
		
		when s_dcd2 =>
			inta <= 'Z';
			WR <= 'Z';
			RD <= 'Z';
			opfetch <= '0';
			pcen <= '0';
			den <= '0';
			dir <= '0';
			aen <= '0';
			SPload <= '0';
			PCload <= '1';
			IRload <= '0';
			Psel <= "11";
			Ssel <= "XX";
			Osel <= "XX";
			ALUsel <= "XXXXX";
			Rsel <= "XX";
			sub2 <= 'X';
			jmpMux <= '0';
			we <= '0';
			rbe <= '0';
			rae <= '0';

 when s_mov => 
       inta <= 'Z'; 
       WR <= 'Z'; 
       RD <= 'Z';
       opfetch <= '0'; 
       pcen <= '0';
       den <= '0'; 
       dir <= '0'; 
       aen <= '0'; 
       SPload <= '0'; 
       PCload <= '0';
       IRload <= '0';
       Psel <= "11"; 
       Ssel <= "00";
       Osel <= "00";  
       ALUsel <= "00000"; 
       Rsel <= "00"; 
       sub2 <= 'X'; 
       jmpMux <= 'X';
       we <= '1'; 
       rbe <= '0'; 
       rae <= '1';

   when s_add => 
       inta <= 'Z'; 
       WR <= 'Z'; 
       RD <= 'Z';
       opfetch <= '0'; 
       pcen <= '0';
       den <= '0'; 
       dir <= '0'; 
       aen <= '0'; 
       SPload <= '0'; 
       PCload <= '0';
       IRload <= '0';
       Psel <= "11"; 
       Ssel <= "00"; 
       Osel <= "00"; 
       ALUsel <= "00100"; 
       Rsel <= "00"; 
       sub2 <= 'X'; 
       jmpMux <= '0';
       we <= '1'; 
       rbe <= '1'; 
       rae <= '1'; 

  when s_sub => 
       inta <= 'Z'; 
       WR <= 'Z'; 
       RD <= 'Z';
       opfetch <= '0'; 
       pcen <= '0';
       den <= '0'; 
       dir <= '0'; 
       aen <= '0'; 
       SPload <= '0'; 
       PCload <= '0';
       IRload <= '0';
       Psel <= "11"; 
       Ssel <= "00"; 
       Osel <= "00"; 
       ALUsel <= "00101"; 
       Rsel <= "00"; 
       sub2 <= 'X'; 
       jmpMux <= '0';
       we <= '1'; 
       rbe <= '1'; 
       rae <= '1';

   when s_and => 
       inta <= 'Z'; 
       WR <= 'Z'; 
       RD <= 'Z';
       opfetch <= '0'; 
       pcen <= '0';
       den <= '0'; 
       dir <= '0'; 
       aen <= '0'; 
       SPload <= '0'; 
       PCload <= '0';
       IRload <= '0';
       Psel <= "11"; 
       Ssel <= "00"; 
       Osel <= "00"; 
       ALUsel <= "00001"; 
       Rsel <= "00"; 
       sub2 <= 'X'; 
       jmpMux <= '0';
       we <= '1'; 
       rbe <= '1'; 
       rae <= '1';

   when s_or => 
       inta <= 'Z'; 
       WR <= 'Z'; 
       RD <= 'Z';
       opfetch <= '0'; 
       pcen <= '0';
       den <= '0'; 
       dir <= '0'; 
       aen <= '0'; 
       SPload <= '0'; 
       PCload <= '0';
       IRload <= '0';
       Psel <= "11"; 
       Ssel <= "00"; 
       Osel <= "00"; 
       ALUsel <= "00010"; 
       Rsel <= "00"; 
       sub2 <= 'X'; 
       jmpMux <= '0';
       we <= '1'; 
       rbe <= '1'; 
       rae <= '1';

   when s_not => 
       inta <= 'Z'; 
       WR <= 'Z'; 
       RD <= 'Z';
       opfetch <= '0'; 
       pcen <= '0';
       den <= '1'; 
       dir <= '1'; 
       aen <= '0'; 
       SPload <= '0'; 
       PCload <= '0';
       IRload <= '0';
       Psel <= "11"; 
       Ssel <= "00"; 
       Osel <= "00"; 
       ALUsel <= "00011"; 
       Rsel <= "00"; 
       sub2 <= 'X'; 
       jmpMux <= '0';
       we <= '1'; 
       rbe <= '0'; 
       rae <= '1';

   when s_inc => 
       inta <= 'Z'; 
       WR <= 'Z'; 
       RD <= 'Z';
       opfetch <= '0'; 
       pcen <= '0';
       den <= '1'; 
       dir <= '1'; 
       aen <= '0'; 
       SPload <= '0'; 
       PCload <= '0';
       IRload <= '0';
       Psel <= "11"; 
       Ssel <= "00"; 
       Osel <= "00"; 
       ALUsel <= "00110"; 
       Rsel <= "00"; 
       sub2 <= 'X'; 
       jmpMux <= '0';
       we <= '1'; 
       rbe <= '0'; 
       rae <= '1';

   when s_dec => 
       inta <= 'Z'; 
       WR <= 'Z'; 
       RD <= 'Z';
       opfetch <= '0'; 
       pcen <= '0';
       den <= '0'; 
       dir <= '1'; 
       aen <= '0'; 
       SPload <= '0'; 
       PCload <= '0';
       IRload <= '0';
       Psel <= "11"; 
       Ssel <= "00"; 
       Osel <= "00"; 
       ALUsel <= "00111"; 
       Rsel <= "00"; 
       sub2 <= 'X'; 
       jmpMux <= '0';
       we <= '1'; 
       rbe <= '0'; 
       rae <= '1';

   when s_sr => 
       inta <= 'Z'; 
       WR <= 'Z'; 
       RD <= 'Z';
       opfetch <= '0'; 
       pcen <= '0';
       den <= '0'; 
       dir <= '1'; 
       aen <= '0'; 
       SPload <= '0'; 
       PCload <= '0';
       IRload <= '0';
       Psel <= "11"; 
       Ssel <= "00"; 
       Osel <= "00"; 
       ALUsel <= "10000"; 
       Rsel <= "00"; 
       sub2 <= 'X'; 
       jmpMux <= '0';
       we <= '1'; 
       rbe <= '0'; 
       rae <= '1';

   when s_sl => 
       inta <= 'Z'; 
       WR <= 'Z'; 
       RD <= 'Z';
       opfetch <= '0'; 
       pcen <= '0';
       den <= '1'; 
       dir <= '1'; 
       aen <= '0'; 
       SPload <= '0'; 
       PCload <= '0';
       IRload <= '0';
       Psel <= "11"; 
       Ssel <= "00"; 
       Osel <= "00"; 
       ALUsel <= "01000"; 
       Rsel <= "00"; 
       sub2 <= 'X'; 
       jmpMux <= '0';
       we <= '1'; 
       rbe <= '0'; 
       rae <= '1';

   when s_rr => 
       inta <= 'Z'; 
       WR <= 'Z'; 
       RD <= 'Z';
       opfetch <= '0'; 
       pcen <= '0';
       den <= '1'; 
       dir <= '1'; 
       aen <= '0'; 
       SPload <= '0'; 
       PCload <= '0';
       IRload <= '0';
       Psel <= "11"; 
       Ssel <= "00"; 
       Osel <= "00"; 
       ALUsel <= "11000"; 
       Rsel <= "00"; 
       sub2 <= 'X'; 
       jmpMux <= '0';
       we <= '1'; 
       rbe <= '0'; 
       rae <= '1';

   when s_jmp => 
	inta <= '0';
	WR <= '0';
	RD <= '0';
	opfetch <= '0';
	pcen <= '0';
	den <= '0';
	dir <= '0';
	aen <= '0';
	SPload <= '0';
	PCload <= '1';
	IRload <= '0';
	Psel <= "11";
	Ssel <= "XX";
	Osel <= "XX";
	ALUsel <= "XXXXX";
	Rsel <= "00";
	sub2 <= 'X';
	jmpMux <= '1';
	we <= '0';
	rbe <= '0';
	rae <= '0';

   when s_call => 
       inta <= 'Z'; 
       WR <= '1'; 
       RD <= '0';
       opfetch <= '0'; 
       pcen <= '1';
       den <= '1'; 
       dir <= '1'; 
       aen <= '1'; 
       SPload <= '0'; 
       PCload <= '0';
       IRload <= '0';
       Psel <= "11"; 
       Ssel <= "11"; 
       Osel <= "01"; 
       ALUsel <= "00000"; 
       Rsel <= "00"; 
       sub2 <= '0'; 
       jmpMux <= '0';
       we <= '0'; 
       rbe <= '0'; 
       rae <= '0';

--  when s_call2 => 
--       inta <= 'Z'; 
--       WR <= '0'; 
--       RD <= '0';
--       opfetch <= '0'; 
--       pcen <= '0';
--       den <= '0'; 
--       dir <= '0'; 
--       aen <= '0'; 
--       SPload <= '1'; 
--       PCload <= '1';
--       IRload <= '0';
--       Psel <= "11"; 
--       Ssel <= "11"; 
--       Osel <= "01"; 
--       ALUsel <= "00000"; 
--       Rsel <= "00"; 
--       sub2 <= '1'; 
--       jmpMux <= '1';
--       we <= '0'; 
--       rbe <= '0'; 
--       rae <= '0';
   when s_ret => 
       inta <= 'Z'; 
       WR <= '0'; 
       RD <= '1';
       opfetch <= '0'; 
       pcen <= '0';
       den <= '1'; 
       dir <= '0'; 
       aen <= '1'; 
       SPload <= '0'; 
       PCload <= '1';
       IRload <= '0';
       Psel <= "10"; 
       Ssel <= "11"; 
       Osel <= "01"; 
       ALUsel <= "XXXXX"; 
       Rsel <= "XX"; 
       sub2 <= '0'; 
       jmpMux <= '0';
       we <= '0'; 
       rbe <= '0'; 
       rae <= '0';

   when s_nop => 
       inta <= 'Z'; 
       WR <= 'Z'; 
       RD <= 'Z';
       opfetch <= '0'; 
       pcen <= '0';
       den <= '0'; 
       dir <= '0'; 
       aen <= '0'; 
       SPload <= '0'; 
       PCload <= '0';
       IRload <= '0';
       Psel <= "11"; 
       Ssel <= "00"; 
       Osel <= "00"; 
       ALUsel <= "00000"; 
       Rsel <= "XX"; 
       sub2 <= 'X'; 
       jmpMux <= '0';
       we <= '0'; 
       rbe <= '0'; 
       rae <= '0';

   when s_halt => 
       inta <= 'X'; 
       WR <= 'X'; 
       RD <= 'X';
       opfetch <= 'X'; 
       pcen <= 'X';
       den <= 'X'; 
       dir <= 'X'; 
       aen <= 'X'; 
       SPload <= 'X'; 
       PCload <= 'X';
       IRload <= 'X';
       Psel <= "XX"; 
       Ssel <= "XX"; 
       Osel <= "XX"; 
       ALUsel <= "XXXXX"; 
       Rsel <= "XX"; 
       sub2 <= 'X'; 
       jmpMux <= 'X';
       we <= 'X'; 
       rbe <= 'X'; 
       rae <= 'X';

   when s_psh => 
       inta <= 'Z'; 
       WR <= '1'; 
       RD <= '0';
       opfetch <= '0'; 
       pcen <= '0';
       den <= '1'; 
       dir <= '1'; 
       aen <= '1'; 
       SPload <= '0'; 
       PCload <= '0';
       IRload <= '0';
       Psel <= "11"; 
       Ssel <= "11"; 
       Osel <= "01"; 
       ALUsel <= "XXXXX"; 
       Rsel <= "XX"; -- IR 
       sub2 <= '1'; 
       jmpMux <= '0';
       we <= '0'; 
       rbe <= '1'; 
       rae <= '0';
 when s_psh2 => 
       inta <= 'Z'; 
       WR <= '0'; 
       RD <= '0';
       opfetch <= '0'; 
       pcen <= '0';
       den <= '0'; 
       dir <= '0'; 
       aen <= '0'; 
       SPload <= '1'; 
       PCload <= '0';
      IRload <= '0';
      Psel <= "11"; 
       Ssel <= "11"; 
       Osel <= "01"; 
     ALUsel <= "XXXXX"; 
       Rsel <= "XX"; -- IR 
      sub2 <= '1'; 
       jmpMux <= '0';
      we <= '0'; 
       rbe <= '0'; 
      rae <= '0';

   when s_pop => 
       inta <= 'Z'; 
       WR <= '0'; 
       RD <= '0';
       opfetch <= '0'; 
       pcen <= '0';
       den <= '0'; 
       dir <= '0'; 
       aen <= '0'; 
       SPload <= '1'; 
       PCload <= '0';
       IRload <= '0';
       Psel <= "11"; 
       Ssel <= "11"; 
       Osel <= "01"; 
       ALUsel <= "00000"; 
       Rsel <= "10"; 
       sub2 <= '0'; 
       jmpMux <= '0';
       we <= '0'; 
       rbe <= '0'; 
       rae <= '0';

   when s_pop2 => 
       inta <= 'Z'; 
       WR <= '0'; 
       RD <= '1';
       opfetch <= '0'; 
       pcen <= '0';
       den <= '1'; 
       dir <= '0'; 
       aen <= '1'; 
       SPload <= '0'; 
       PCload <= '0';
       IRload <= '0';
       Psel <= "11"; 
       Ssel <= "11"; 
       Osel <= "01"; 
       ALUsel <= "00000"; 
       Rsel <= "10"; 
       sub2 <= '0'; 
       jmpMux <= '0';
       we <= '1'; 
       rbe <= '0'; 
       rae <= '0';


   when s_wrt => 
       inta <= 'Z'; 
       WR <= '0'; 
       RD <= '0';
       opfetch <= '0'; 
       pcen <= '0';
       den <= '0'; 
       dir <= '0'; 
       aen <= '0'; 
       SPload <= '0'; 
       PCload <= '0';
       IRload <= '0';
       Psel <= "11"; 
       Ssel <= "00"; 
       Osel <= "11"; 
       ALUsel <= "ZZZZZ"; 
       Rsel <= "ZZ"; 
       sub2 <= 'Z'; 
       jmpMux <= 'Z';
       we <= '0'; 
       rbe <= '0'; 
       rae <= '0';

   when s_read => 
       inta <= 'Z'; 
       WR <= 'Z'; 
       RD <= '0';
       opfetch <= 'Z'; 
       pcen <= '0';
       den <= '0'; 
       dir <= '0'; 
       aen <= '0'; 
       SPload <= '0'; 
       PCload <= '0';
       IRload <= '0';
       Psel <= "11"; 
       Ssel <= "00"; 
       Osel <= "11"; 
       ALUsel <= "00000"; 
       Rsel <= "11"; 
       sub2 <= 'X'; 
       jmpMux <= 'X';
       we <= '0'; 
       rbe <= '0'; 
       rae <= '0';

   when s_movi => 
       inta <= 'Z'; 
       WR <= 'Z'; 
       RD <= 'Z';
       opfetch <= '0'; 
       pcen <= '0';
       den <= '0'; 
       dir <= '0'; 
       aen <= '0'; 
       SPload <= '0'; 
       PCload <= '0';
       IRload <= '0';
       Psel <= "11"; 
       Ssel <= "00"; 
       Osel <= "00"; 
       ALUsel <= "00000"; 
       Rsel <= "11"; 
       sub2 <= 'X'; 
       jmpMux <= '0';
       we <= '1'; 
       rbe <= '0'; 
       rae <= '0';


   when s_mvspr => 
       inta <= 'Z'; 
       WR <= 'Z'; 
       RD <= 'Z';
       opfetch <= '0'; 
       pcen <= '0';
       den <= '0'; 
       dir <= '0'; 
       aen <= '0'; 
       SPload <= '1'; 
       PCload <= '0';
       IRload <= '0';
       Psel <= "11"; 
       Ssel <= "10"; 
       Osel <= "ZZ"; 
       ALUsel <= "ZZZZZ"; 
       Rsel <= "ZZ"; 
       sub2 <= 'X'; 
       jmpMux <= '0';
       we <= '0'; 
       rbe <= '0'; 
       rae <= '1';
   when s_mvrsp => 
       inta <= 'Z'; 
       WR <= 'Z'; 
       RD <= 'Z';
       opfetch <= '0'; 
       pcen <= '0';
       den <= '0'; 
       dir <= '0'; 
       aen <= '0'; 
       SPload <= '0'; 
       PCload <= '0';
       IRload <= '0';
       Psel <= "11"; 
       Ssel <= "ZZ"; 
       Osel <= "ZZ"; 
       ALUsel <= "00000"; 
       Rsel <= "01"; 
       sub2 <= 'X'; 
       jmpMux <= '0';
       we <= '1'; 
       rbe <= '0'; 
       rae <= '0';

    when s_r_c1 => 
       inta <= 'Z'; 
       WR <= 'Z'; 
       RD <= '1';
       opfetch <= 'Z'; 
       pcen <= '0';
       den <= '1'; 
       dir <= '0'; 
       aen <= '1'; 
       SPload <= '0'; 
       PCload <= '0';
       IRload <= '0';
       Psel <= "11"; 
       Ssel <= "00"; 
       Osel <= "11"; 
       ALUsel <= "00000"; 
       Rsel <= "10"; 
       sub2 <= 'X'; 
       jmpMux <= 'X';
       we <= '1'; 
       rbe <= '0'; 
       rae <= '1';
    when s_r_c2 => 
       inta <= 'Z'; 
       WR <= 'Z'; 
       RD <= '1';
       opfetch <= 'Z'; 
       pcen <= '0';
       den <= '1'; 
       dir <= '0'; 
       aen <= '1'; 
       SPload <= '0'; 
       PCload <= '0';
       IRload <= '0';
       Psel <= "11"; 
       Ssel <= "00"; 
       Osel <= "11"; 
       ALUsel <= "00000"; 
       Rsel <= "10"; 
       sub2 <= 'X'; 
       jmpMux <= 'X';
       we <= '1'; 
       rbe <= '0'; 
       rae <= '1';
   when s_r_c3 => 
       inta <= 'Z'; 
       WR <= 'Z'; 
       RD <= '0';
       opfetch <= 'Z'; 
       pcen <= '0';
       den <= '0'; 
       dir <= '0'; 
       aen <= '0'; 
       SPload <= '0'; 
       PCload <= '0';
       IRload <= '0';
       Psel <= "11"; 
       Ssel <= "00"; 
       Osel <= "11"; 
       ALUsel <= "00000"; 
       Rsel <= "10"; 
       sub2 <= 'X'; 
       jmpMux <= 'X';
       we <= '0'; 
       rbe <= '0'; 
       rae <= '0';
    when s_w_c1 => 
       inta <= 'Z'; 
       WR <= '0'; 
       RD <= '0';
       opfetch <= '0'; 
       pcen <= '0';
       den <= '0'; 
       dir <= '0'; 
       aen <= '0'; 
       SPload <= '0'; 
       PCload <= '0';
       IRload <= '0';
       Psel <= "11"; 
       Ssel <= "00"; 
       Osel <= "11"; 
       ALUsel <= "ZZZZZ"; 
       Rsel <= "ZZ"; 
       sub2 <= 'Z'; 
       jmpMux <= 'Z';
       we <= '0'; 
       rbe <= '1'; 
       rae <= '1';

   when s_w_c2 => 
       inta <= 'Z'; 
       WR <= '1'; 
       RD <= '0';
       opfetch <= '0'; 
       pcen <= '0';
       den <= '1'; 
       dir <= '1'; 
       aen <= '1'; 
       SPload <= '0'; 
       PCload <= '0';
       IRload <= '0';
       Psel <= "11"; 
       Ssel <= "00"; 
       Osel <= "11"; 
       ALUsel <= "ZZZZZ"; 
       Rsel <= "ZZ"; 
       sub2 <= 'Z'; 
       jmpMux <= 'Z';
       we <= '0'; 
       rbe <= '0'; 
       rae <= '0';
    when s_w_c3 => 
       inta <= 'Z'; 
       WR <= '0'; 
       RD <= '0';
       opfetch <= '0'; 
       pcen <= '0';
       den <= '0'; 
       dir <= '0'; 
       aen <= '0'; 
       SPload <= '0'; 
       PCload <= '0';
       IRload <= '0';
       Psel <= "11"; 
       Ssel <= "00"; 
       Osel <= "11"; 
       ALUsel <= "ZZZZZ"; 
       Rsel <= "ZZ"; 
       sub2 <= 'Z'; 
       jmpMux <= 'Z';
       we <= '0'; 
       rbe <= '0'; 
       rae <= '0';

    when s_int_c1 => 
       inta <= '1'; 
       WR <= '0'; 
       RD <= '0';
       opfetch <= '0'; 
       pcen <= '1';
       den <= '0'; 
       dir <= '0'; 
       aen <= '0'; 
       SPload <= '0'; 
       PCload <= '0';
       IRload <= '0';
       Psel <= "XX"; 
       Ssel <= "XX"; 
       Osel <= "XX"; 
       ALUsel <= "ZZZZZ"; 
       Rsel <= "ZZ"; 
       sub2 <= '0'; 
       jmpMux <= 'Z';
       we <= '0'; 
       rbe <= '0'; 
       rae <= '0';
  when s_int_c2 => 
       inta <= '1'; 
       WR <= '1'; 
       RD <= '0';
       opfetch <= '0'; 
       pcen <= '1';
       den <= '0'; 
       dir <= '1'; 
       aen <= '1'; 
       SPload <= '1'; 
       PCload <= '1';
       IRload <= '0';
       Psel <= "00"; 
       Ssel <= "11"; 
       Osel <= "01"; 
       ALUsel <= "ZZZZZ"; 
       Rsel <= "ZZ"; 
       sub2 <= '1'; 
       jmpMux <= '0';
       we <= '0'; 
       rbe <= '0'; 
       rae <= '0';

    when s_int_c3 => 
       inta <= '0'; 
       WR <= '0'; 
       RD <= '0';
       opfetch <= '0'; 
       pcen <= '0';
       den <= '0'; 
       dir <= 'X'; 
       aen <= '0'; 
       SPload <= '0'; 
       PCload <= '0';
       IRload <= '0';
       Psel <= "00"; 
       Ssel <= "11"; 
       Osel <= "01"; 
       ALUsel <= "ZZZZZ"; 
       Rsel <= "ZZ"; 
       sub2 <= '0'; 
       jmpMux <= '0';
       we <= '0'; 
       rbe <= '0'; 
       rae <= '0';
 
    when others => inta <= 'X';
  end case;
 end process;
end imp;
