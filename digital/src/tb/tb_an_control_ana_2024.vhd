-------------------------------------------------------------------------------
-- Title      : tb_an_control_ana
-- Project    : iadc
-------------------------------------------------------------------------------
-- File       : tb_ml_control_ana_2024template.vhd
-- Company    : FH-Kaernten
-- Last update: 07.02.2024
-------------------------------------------------------------------------------
-- Description: TestBench for ml_control, digital part of iadc
-- 		includes simple vhdl model of analog part 
--		adapted to tsmc65lp
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2021/02/01  1.0	M. Ley	names, asserts, timing changes, analog
-- 2023/02/01  2.0	M. Ley	timing changes, analog
-- 2024/02/01  1.0	M. Ley	prefix "ml_control", analog model with seterror
-------------------------------------------------------------------------------
library ieee,std;
use STD.textio.all;
use ieee.std_logic_textio.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;           -- conv_std_logic_vector
use ieee.std_logic_unsigned.all;        -- unsigned arithmetic
use ieee.numeric_std.all;		-- data type real

ENTITY tb_an_control_ana IS	-- simulation top level, no IO ports
END tb_an_control_ana;

ARCHITECTURE behavior OF tb_an_control_ana IS 


	constant clkp		: time:= 20 ns; -- 50MHz

	signal Clk		: std_logic:='0';
	signal Resetn		: std_logic:='0';
	signal Pwrdn		: std_logic:='1';
	signal DOut  		: std_logic_vector(9 downto 0); 
	signal DOut_sgn		: std_logic;
	signal ClkOut		: std_logic;
	signal Resetn_Out	: std_logic;
	signal S1		: std_logic;
	signal S2a		: std_logic;
	signal S2b		: std_logic;
	signal S3		: std_logic;
	signal Clk_Ana		: std_logic;
	signal Pwrdn_Ana	: std_logic;
	signal ts1		: std_logic;
	signal ts2		: std_logic;
	signal ts3		: std_logic;
	signal ts1_Ana		: std_logic;
	signal ts2_Ana		: std_logic;
	signal ts3_Ana		: std_logic;

	signal vinput		: real:= 0.1;
	signal vcomp_model	: std_logic;
	signal clk_counter	: integer:= 0;
	signal cycle_counter	: integer:= 0;

	signal seterror		: std_logic :='0';

	signal sim_done		: boolean:= false;

component an_control		-- declaration component ml_control
  port (Clk	: 	in std_logic;   -- Define ports
	Resetn	: 	in std_logic;
	Pwrdn	: 	in std_logic;			
	Vcomp	: 	in std_logic;
	ts1 	: 	in std_logic;
	ts2 	: 	in std_logic;
	ts3 	: 	in std_logic;
	S1	: 	out std_logic;
	S2a	: 	out std_logic;
	S2b	: 	out std_logic;
	S3	: 	out std_logic;
	ClkOut	: 	out std_logic;
	Resetn_Out: 	out std_logic;
	Clk_Ana : 	out std_logic;
	Pwrdn_Ana : 	out std_logic;
	ts1_Ana : 	out std_logic;
	ts2_Ana : 	out std_logic;
	ts3_Ana : 	out std_logic;
	DOut_sgn : 	out std_logic;
	DOut 	: 	out std_logic_vector(9 downto 0));
end component;

component an_analog_simple_err 	-- simulation model for analog part
   port(
	S1	: 	in std_logic;
	S2a	: 	in std_logic;
	S2b	: 	in std_logic;
	S3	: 	in std_logic;
	Resetn_Out: 	in std_logic;
	Clk_Ana : 	in std_logic;
	Pwrdn_Ana : 	in std_logic;
	ts1_Ana : 	in std_logic;
	ts2_Ana : 	in std_logic;
	ts3_Ana : 	in std_logic;
	seterror : 	in std_logic; --set wrong comparator decission
	vinp	:	in real;
	Vcomp	: 	out std_logic);
END component;


BEGIN
u_control : an_control	-- instantiation component control
    port map (
		Clk	=>	Clk,            
   		Resetn  => 	Resetn,
		Pwrdn	=>	Pwrdn,
		Vcomp	=>	Vcomp_model,
		ts1	=>	ts1,
		ts2	=>	ts2,
		ts3	=>	ts3,
		S1	=>	S1,
		S2a	=>	S2a,
		S2b	=>	S2b,
		S3	=>	S3,
		ClkOut	=>	ClkOut,
		Resetn_Out =>	Resetn_Out,
		Clk_Ana	=>	Clk_Ana,
		Pwrdn_Ana => 	Pwrdn_Ana,
		ts1_Ana =>	ts1_Ana,
		ts2_Ana =>	ts2_Ana,
		ts3_Ana =>	ts3_Ana,
		DOut_sgn =>	DOut_sgn,
		DOut	=>	Dout
		);


an_analog : an_analog_simple_err 	-- instantiation analog simulation model
   port map(
		
		S1	=>	S1,
		S2a	=>	S2a,
		S2b	=>	S2b,
		S3	=>	S3,
		Resetn_Out =>	Resetn_Out,
		Clk_Ana	=>	Clk_Ana,
		Pwrdn_Ana => 	Pwrdn_Ana,
		ts1_Ana =>	ts1_Ana,
		ts2_Ana =>	ts2_Ana,
		ts3_Ana =>	ts3_Ana,
		seterror =>	seterror,  --set wrong comparator decission
		vinp	=>	vinput,
		Vcomp	=>	Vcomp_model
	);

----------######### clk, powerdown, reset generation processes ---------

	clock_gen : process
   	begin
		Clk <= '1';
		wait for clkp/2;
		Clk <= '0';
		clk_counter <= clk_counter+1; -- simulation time counter
		wait for clkp/2;
		if sim_done then wait;
		end if;
	end process clock_gen;

	pwrdn_gen : process	-- SPECIFY PWRDN SEQUENCE
	begin
	Pwrdn <= '1';
		wait for 10*clkp; 
		Pwrdn <= '0';
		wait for 30000*clkp;
		Pwrdn <= '1';
		wait for 10*clkp;
		wait;
	end process pwrdn_gen;

	reset_gen : process	-- SPECIFY SEVERAL RESET SEQUENCES
	begin
		Resetn <= '0';
		wait for 10*clkp;
		Resetn <= '1';
		wait for 30000*clkp;
		Resetn <= '0';
		wait for 10*clkp;
		Resetn <= '1';
		wait;
	end process reset_gen;

ts_gen : process
begin
    -- Initialize timestamp signals to '0'
    ts1 <= '0';
    ts2 <= '0';
    ts3 <= '0';

    -- Wait for a specified time interval (100 * clkp)
    wait for 100 * clkp;

    -- Set ts1 signal to '1' to indicate a timestamp event
    ts1 <= '1';

    -- Wait for another specified time interval (100 * clkp)
    wait for 100 * clkp;

    -- Reset ts1 signal to '0' after the event
    ts1 <= '0';

    -- Wait for a specified time interval (100 * clkp)
    wait for 100 * clkp;

    -- Set ts2 signal to '1' to indicate a timestamp event
    ts2 <= '1';

    -- Wait for another specified time interval (100 * clkp)
    wait for 100 * clkp;

    -- Reset ts2 signal to '0' after the event
    ts2 <= '0';

    -- Wait for a specified time interval (100 * clkp)
    wait for 100 * clkp;

    -- Set ts3 signal to '1' to indicate a timestamp event
    ts3 <= '1';

    -- Wait for another specified time interval (100 * clkp)
    wait for 100 * clkp;

    -- Reset ts3 signal to '0' after the event
    ts3 <= '0';

    -- Wait indefinitely
    wait;
end process ts_gen;

check_clockout: process(clkout) 
	variable prev_time : time := 0 ns;
	variable curr_time : time := 0 ns;
	variable T_c : time := 0 ns;
	begin
	if(clkout'event and clkout='1')then
	curr_time := now;
	if not(prev_time = 0 ns) then 
	T_c := curr_time - prev_time;
	assert (T_c = 41.82 us)
	report"*** ERROR Clkout not fixed period***" & time'image(T_c) severity error;
	end if;
	prev_time := curr_time;
	end if;
end process check_clockout;

------##### input sequences for analog model ----------------------------

vinput_gen : process	-- SPECIFY VIN SEQUENCE for analog model
	begin
		

		wait for 10*clkp; -- reset signal active
		vinput <= 0.5;	-- set input voltage (0 to 0.5 volt)
	        cycle_counter <= 1; -- debug ADC conversion cycle counter
		wait for 2091*clkp; -- ADC operation
		wait for 10*clkp;
                assert (Dout = 1023) 
		report "*** ERROR Dout 1****" severity warning;
                assert (DOut_sgn = '0') 
		report "*** ERROR Dout_sgn ****" severity warning;

		 vinput <= 0.0005;		
	         cycle_counter <= 2;
	         wait for 2091*clkp; 
                assert (Dout = 1) 
		report "*** ERROR Dout 1****" severity warning;
                assert (DOut_sgn = '0') 
		report "*** ERROR Dout_sgn ****" severity warning;
	    
		 vinput <= 0.25;		
	         cycle_counter <= 3;
	         wait for 2091*clkp; 
                assert (Dout = 512) 
		report "*** ERROR Dout 1****" severity warning;
                assert (DOut_sgn = '0') 
		report "*** ERROR Dout_sgn ****" severity warning;

		vinput <= 0.499512;		
	        cycle_counter <= 4;
	        wait for 2091*clkp; 
                assert (Dout = 1023) 
		report "*** ERROR Dout 1****" severity warning;
                assert (DOut_sgn = '0') 
		report "*** ERROR Dout_sgn ****" severity warning;

	       	vinput <= 0.50045;		
	        cycle_counter <= 5;
	        wait for 2091*clkp; 
                assert (Dout = 1023) 
		report "*** ERROR Dout 1****" severity warning;
                assert (DOut_sgn = '0') 
		report "*** ERROR Dout_sgn ****" severity warning;


		 vinput <= 0.0;		
	         cycle_counter <= 6;
	         wait for 2091*clkp; 
                assert (Dout = 0) 
		report "*** ERROR Dout 1****" severity warning;
                assert (DOut_sgn = '0') 
		report "*** ERROR Dout_sgn ****" severity warning;

		vinput <= -0.0005;		
	        cycle_counter <= 7;
	        wait for 2091*clkp;	
		assert (Dout = 1) 
		report "*** ERROR Dout 1****" severity warning;
                assert (DOut_sgn = '1') 
		report "*** ERROR Dout_sgn ****" severity warning;

		vinput <= -0.00045;		

	        cycle_counter <= 8;
	        wait for 2091*clkp;
		 assert (Dout = 0) 
		report "*** ERROR Dout 1****" severity warning;
                assert (DOut_sgn = '1') 
		report "*** ERROR Dout_sgn ****" severity warning;
	
	        vinput <= -0.25045; -- set input voltage for next conversion

	        cycle_counter <= 9;
	        wait for 2091*clkp;
                assert (Dout = 512) 
	        report "*** ERROR Dout 1****" severity warning;
                assert (DOut_sgn = '1') 
		report "*** ERROR Dout_sgn ****" severity warning;


	        vinput <= -0.15; -- set input voltage for next conversion

	        cycle_counter <= 10;
	        wait for 2091*clkp;
                assert (Dout = 307) 
	        report "*** ERROR Dout 1****" severity warning;
                assert (DOut_sgn = '1') 
		report "*** ERROR Dout_sgn ****" severity warning;

		 vinput <= -0.50045;		
 
	         cycle_counter <= 11;
	         wait for 2091*clkp;	
                 assert (Dout = 1023) 
		 report "*** ERROR Dout 1****" severity warning;
                 assert (DOut_sgn = '1') 
		 report "*** ERROR Dout_sgn ****" severity warning;

		 vinput <= -0.50045;		
 
	         cycle_counter <= 12;
	         wait for 2091*clkp;	
                 assert (Dout = 1023) 
		 report "*** ERROR Dout 1****" severity warning;
                 assert (DOut_sgn = '1') 
		 report "*** ERROR Dout_sgn ****" severity warning;

		 vinput <= -0.2505;		
 
	         cycle_counter <= 12;
	         wait for 2091*clkp;	
                 assert (Dout = 513) 
		 report "*** ERROR Dout 1****" severity warning;
                 assert (DOut_sgn = '1') 
		 report "*** ERROR Dout_sgn ****" severity warning;




--################# modelerror set ##########################
--seterror <= '1';
--assert (Dout = conv_std_logic_vector(0,10))
	--report "*** ERROR Dout ****" & integer'image(123) severity warning;
--assert (DOut_sgn = '1') 
	--report "*** ERROR Dout_sgn ****" & integer'image(1) severity warning;
--assert (false) report "*** Dout, Dout_sgn check ****" severity note;

	--	cycle_counter <= 14;
     	--	vinput <= 0.25;		-- 
       --         wait for 2091*clkp; -- ADC operation
      --          assert (Dout = 0) 
	--	report "*** ERROR Dout 1****" severity warning;
       --        assert (DOut_sgn = '1') 
		--report "*** ERROR Dout_sgn ****" severity warning;

		--cycle_counter <= 15;

--#######-------- add all additional error testcases -----#######--

		--vinput <= -0.25;		-- 
             --  wait for 2091*clkp; -- ADC operation

--################# modelerror un-set #########, 

--check if correct conversions continue
--seterror <= '0';

--assert (Dout = conv_std_logic_vector(1023,10))
--report "*** ERROR Dout ****" & integer'image(1023) severity warning;
--assert (DOut_sgn = '1') 
--report "*** ERROR Dout_sgn ****" & integer'image(1) severity warning;
--assert (false) report "*** Dout, Dout_sgn check ****" severity note;

--		cycle_counter <= 18;

--		wait for 23000*clkp;

		sim_done <= true;
		assert false report "*** SIMULATION Vinput_gen FINISHED ***" 
				severity note;
		wait;
end process vinput_gen;


--check switches
check_switch : process (s1, s2a, s2b, s3)
	begin
		assert not(s2a='1' and  s2b='1') 
		report "*** ERROR tb s2a-s2b overlap ****" severity error;
		assert not(s2a='1' and s1='1') 
		report "*** ERROR tb s2a-s1 overlap ****" severity error;
		assert not(s2b='1' and s1='1') 
		report "*** ERROR tb s2b-s1 overlap ****" severity error;

end process check_switch;

END; 
--

