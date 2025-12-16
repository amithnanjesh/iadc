-------------------------------------------------------------------------------
-- Title      : analog_simple_err
-- Project    : iadc
-------------------------------------------------------------------------------
-- File       : analog_simple_err.vhd
-- Company    : FH-Kaernten
-- Last update: 07.02.2024
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: simple simulation vhdl model for analog part of iadc,
-- single model voltage vin = real differential voltage
--
-- #### Model behavior is assumption, FIT TO ANALOG DESIGN !!! ####
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2021/02/01  1.0	M. Ley	initial model template
-- 2024/02/07  2.0	M. Ley	model comparator adapted for error simulation
-------------------------------------------------------------------------------
library ieee,std;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;           -- conv_std_logic_vector
use ieee.numeric_std.all;		 -- data type real
use ieee.math_real.all;			 -- math operations


ENTITY an_analog_simple_err IS -- simulation top level analog block with seterror
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
	seterror : 	in std_logic; --set wrong comparator output
	vinp	:	in real;	-- real type voltage input
	Vcomp	: 	out std_logic
	);
END an_analog_simple_err;

ARCHITECTURE behavior OF an_analog_simple_err IS -- simulation architecture

	signal cnt_ints1	: integer:=0; -- switch clk cycle counters
	signal cnt_ints2a	: integer:=0;	-- used for debugging
	signal cnt_ints2b	: integer:=0;

	signal ts1	        : std_logic:='0';
	signal ts2		: std_logic:='0';
	signal ts3		: std_logic:='0';

	signal vcomp_int	: std_logic; -- comparator internals
	signal vcomp_prev	: std_logic;

	signal vint		: real;	-- integrator output voltage

	constant integration 	: real := 1024.0; -- integration steps
	constant Vin_max	: real := 0.5; -- maximum input voltage
	constant Vref		: real := 0.5; -- reference voltage
	constant lsb_in		: real := vin_max/integration; -- lsb voltage	
	constant lsb_ref	: real := vref/integration;	
	constant offset		: real := 0.0; -- offset in lsb_in

BEGIN

	ts1 <= ts1_ana; ts2 <= ts2_ana; ts3 <= ts3_ana; -- feed connection

-- the integrator model integrates in lsb-steps on falling edge clk, so each
-- clock period of integration time adds one lsb voltage step
-- integration is done on Vinp pos/neg input voltage 
-- #### CHECK THIS ASSUMPTIONS ####
-- de-integration on Vref, pos/neg depends on s2 switch
-- positive vinp - s2a neg deinteg, negative vinp - s2b pos deinteg

  integrator : process (clk_ana, pwrdn_ana, s1, s2a, s2b, s3)
  begin
	if pwrdn_ana = '1' then 		-- power down active
		vint <= 0.0;			-- vint assumed zero

	elsif s1='0'and s2a='0' and s2b='0' and s3='0' then -- all switch open
		vint <= 0.0 after 100 ns;	-- capacitor discharge 

	elsif s3='1' then 		-- s3 close, integrator zero
		vint <= 0.0 after 60 ns; --discharging in 60ns
		cnt_ints1  <= 0;	-- reset switch time counters	
		cnt_ints2a <= 0;
		cnt_ints2b <= 0;

	elsif s1='1'and s2a='0' and s2b='0' and s3='0' then -- s1 close
		if clk_ana'event and clk_ana = '0' then
			vint <= vint + (lsb_in*(vinp/vin_max));
			cnt_ints1 <= cnt_ints1 + 1; -- count s1 time
		end if;

	elsif s1='0'and s2a='1' and s2b='0' and s3='0' then -- s2a close
		if clk_ana'event and clk_ana = '0' then
		vint <= vint + (lsb_ref);	-- positive deinteration
		cnt_ints2a <= cnt_ints2a + 1;  -- count s2a time
		end if;

	elsif s1='0'and s2a='0' and s2b='1' and s3='0' then -- s2b close
		if clk_ana'event and clk_ana = '0' then
		vint <= vint - (lsb_ref);	-- negative deintegration
		cnt_ints2b <= cnt_ints2b + 1;  -- count s2b time
		end if;
	
	else	-- all else switch states are maybe wrong?
		vint <= 0.0;
	assert false report "*** INTEGRATOR-Switch Problem ***" severity warning;
	end if;
  end process integrator;

-- the comparator evaluates on rising edge clock 
-- Vint has to be greater than a offset voltage around zero for evaluation
-- if Vint is smaller than offset voltage, output keeps last value
-- ####  CHECK VINT <-> VCOMP POLARITY AND OFFSET BEHAVIOR  ####, 
-- ####  !!! FIT TO YOUR ANALOG DESIGN !!!                  ####
	
  comparator : process (resetn_out, clk_ana)

  begin
 if resetn_out = '0' then  --resetn is active
 vcomp_int <= '0';  -- reset output flipflop, if any? --set the comparator to 0
 vcomp_prev <= '0'; -- reset previous value
  elsif clk_ana'event and clk_ana = '1' then --for a rising edge, deliver a o/p voltage
 if vint >= lsb_ref*offset then --set the comparator to 0 for a positive integrating voltage. If an offset is set to 0, that means vint >=0, this is an ideal integrator's working
 vcomp_int <= '0'; -- The output is 0 cosidering it's a ideal comparator. Offset is not a real offset, it's a shift in threshold in terms of LSB.
     vcomp_prev <= '0';
      elsif vint < -(lsb_ref*offset) then --Opposite of the above case.
     vcomp_int <= '1';
     vcomp_prev <= '1'; -- store vcomp for next compare cycle
 else
     vcomp_int <= vcomp_prev;
   assert false report "*** ERROR analogmodel: no vcomp decission ****"
 severity warning;
 end if;
end if;
  end process comparator;

vcomp <= vcomp_int when seterror = '0' else
	 not vcomp_int; -- set vcomp output port depending on seterror

-----------------------------------------------------------------
  check_switch : process (s1, s2a, s2b, s3)
  begin
	assert not(s2a='1' and  s2b='1') 
	report "*** ERROR analogmodel: s2a-s2b overlap ****" severity warning;
	assert not(s2a='1' and s1='1') 
	report "*** ERROR analogmodel: s2a-s1 overlap ****" severity warning;
	assert not(s2b='1' and s1='1') 
	report "*** ERROR analogmodel: s2b-s1 overlap ****" severity warning;

  end process check_switch;

END;
