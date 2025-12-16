--*****************************************************************************
--*    Template of a Control Logic for Dual Slope ADC                   *
--*    THIS IS AN EXAMPLE FOR CIRCUIT STRUCTURE, NO WORKING VHDL CODE	*
--*                                                                     *
--*    Author :  Amith Nanjesh  	Author prefix:  an_                    *
--*    Date   :  02.05.2024 						*
--*    Revison:  0.1 template                                           *
--*    Implements 1.0 version of iadc digital control block           *
--******ISCD-INTERNAL USE ONLY*******************************************

library ieee;                            
use ieee.std_logic_1164.all;		-- Defines std_logic types
use ieee.std_logic_arith.all;		-- Defines general arithmetic operators
use ieee.std_logic_unsigned.all;	-- use unsigned arithmetic
use ieee.numeric_std.all;


 entity an_control is	-- Top level design name "Author prefix_control"
  port (clk : in std_logic;  -- Defines all in / out ports
	resetn		: in std_logic;
	pwrdn		: in std_logic;			
	vcomp		: in std_logic;
	ts1 		: in std_logic;
	ts2 		: in std_logic;
	ts3 		: in std_logic;
	s1		: out std_logic;
	s2a		: out std_logic;
	s2b		: out std_logic;
	s3		: out std_logic;
	resetn_out 	: out std_logic;
	clk_ana 	: out std_logic;
	pwrdn_ana 	: out std_logic;
	ts1_ana 	: out std_logic;
	ts2_ana 	: out std_logic;
	ts3_ana 	: out std_logic;
	clkout		: out std_logic;
	dout_sgn 	: out std_logic;
	dout 		: out std_logic_vector(9 downto 0));
end an_control;
--*****************************************************************************

architecture rtl of an_control is  -- rtl style architecture of ml_control

-- state data type and signal declaration 
-- **** define your FSM states as enumerated datatype ************************

type cntrl_states is(resetpwd, init_reset, initinteg, deintegp, deintegn, wait_toalign, recover, non_ovps1_s2, non_ovps3_s1); -- use meaningfull state names!!!

signal state	: cntrl_states;	-- state vector register

--*****************************************************************************
--*                                                                           *
--* Here fill in all your own internal signal declarations                    *
--*                                                                           *
--*****************************************************************************

signal dout_reg	: std_logic_vector(9 downto 0);	-- output register 10 bit
signal sign_reg : std_logic;			-- output register 1 bit
signal count        : std_logic_vector(9 downto 0);  -- internal 10 bit counter
--signal dout_reg_i : std_logic_vector(9 downto 0);  -- internal dout register
--signal sign_reg_i : std_logic;                     -- process internal sign register
signal vcomp_flag : std_logic;
signal count_flag : std_logic_vector(1 downto 0);
signal count_hist : std_logic_vector(1 downto 0);
--signal sign_reg_j : std_logic;
--signal error_count : integer range 0 to 5 := 0; -- Counter for error detection




begin   -- begin of architecture functional description ********************

-- feed through (signal renaming) from top level to analog block  
-- feed through (signal renaming) from top level to analog block  
Clk_Ana    <=   Clk;
Pwrdn_Ana  <=   Pwrdn;
ts1_Ana    <=   ts1;
ts2_Ana    <=   ts2;
ts3_Ana    <=   ts3;



--****************************************************************************
--********** registered state output assignment process **********************
--****************************************************************************

state_output : process (Resetn, Pwrdn, Clk)

--define ALL outputs in ALL states, complete signal assignments in each state
begin

if (Resetn = '0') or (Pwrdn = '1') then -- reset output values set
		S1         <= '0';
  		S2a        <= '0';
  		S2b        <= '0';
  		S3         <= '0';
  		ClkOut     <= '0';
		Resetn_Out <= '0';

elsif (Clk'event and Clk = '1') then -- all output signals driven from register

  case state is

	when resetpwd =>	--Reset and power down mode state

		S1         <= '0';
  		S2a        <= '0';
  		S2b        <= '0';
  		S3         <= '0';
  		ClkOut     <= '0';
		Resetn_Out <= '0';


	when init_reset =>	--initial state for capacitor to discharge

		S1         <= '0';
  		S2a        <= '0';
  		S2b        <= '0';
  		S3         <= '1';
  		ClkOut     <= '0';
		Resetn_Out <= '0';


	when non_ovps3_s1 =>                --s3 and s1 overlapping

                S1         <= '1';
                S2a        <= '0';
                S2b        <= '0';
                S3         <= '1';
                ClkOut     <= '0';
                Resetn_Out <= '1';


  	when initinteg =>	--After reset, initialize state for 1024 clk's

		S1         <= '1';
  		S2a        <= '0';
  		S2b        <= '0';
  		S3         <= '0';
  		ClkOut     <= '1';
		Resetn_Out <= '1';
 
	 when non_ovps1_s2 =>		--non overlapping between s1 and s2
                S1         <= '0';
                S2a        <= '0';
                S2b        <= '0';
                S3         <= '0';
                ClkOut     <= '0';
                Resetn_Out <= '1';

        when deintegp =>                --After integration deintegrate positive for NDE clks
                S1         <= '0';
                S2a        <= '1';
                S2b        <= '0';
                S3         <= '0';
                ClkOut     <= '0';
                Resetn_Out <= '1';

        when deintegn =>                --After integration deintegrate negative for NDE clks
               S1         <= '0';
               S2a        <= '0';
               S2b        <= '1';
               S3         <= '0';
               ClkOut     <= '0';
                Resetn_Out <= '1';

        when wait_toalign =>     --After deintegration wait for 1024-NDE clks
                S1         <= '0';
                S2a        <= '0';
                S2b        <= '0';
                S3         <= '0';
                ClkOut     <= '0';
                Resetn_Out <= '1';



        when recover =>         --After waitnalign , this is for data recovery
                S1         <= '0';
                S2a        <= '0';
                S2b        <= '0';
                S3         <= '0';
                ClkOut     <= '0';
                Resetn_Out <= '1';




  end case;

end if;

end process state_output; 


--****************************************************************************
--*****  state change conditions, time counter included   ********************
--****************************************************************************
	
set_state: process (Pwrdn, Resetn, Clk)  	

--variable count      : std_logic_vector(9 downto 0);  -- internal 10 bit counter
--variable dout_reg_i : std_logic_vector(9 downto 0);  -- internal dout register
--variable sign_reg_i : std_logic;                     -- internal sign register

begin

if (Resetn = '0') or (Pwrdn = '1') then -- reset for all registers
      state <= resetpwd;
      dout_reg <= "0000000000";
      sign_reg <= '0';
    --  sign_reg_j <= '0';
      count      <= "0000000000";
      dout   <= "0000000000";
      DOut_sgn   <= '0';
      vcomp_flag <= '0';
      count_flag <= "00";
      count_hist <= "00";

elsif (Clk'event and Clk = '1') then -- clk edge condition

  case state is
  
    when resetpwd =>		-- define state change condition 
      if (Resetn = '1') and (Pwrdn = '0') then 
	 count <= count + '1';  -- count up with each clk
          if ( count = "0000000111" ) then
                 count_flag <= "00";
                 vcomp_flag <= '0';
                 count_hist <= "00";
                 count <= "0000000000" ;
                 state <= init_reset;

          end if;
       end if;



	  when init_reset =>
	   count <= count + '1';  -- count up with each clk
	    if ( count = "0000011101" ) then
                 count_flag <= "00";
                 vcomp_flag <= '0';
                 count_hist <= "00";
                 count <= "0000000000" ;
  
        state <= non_ovps3_s1; -- Transition to the next state after 1 clock cycles

end if;

  when non_ovps3_s1 =>
	   count <= count + '1';  -- count up with each clk
	    if ( count = "00000000100" ) then
                 count <= "0000000000" ;
  
        state <= initinteg; -- Transition to the next state after 1 clock cycles
   	

end if;

      
    when initinteg => 
	 count <= count + '1';  -- count up with each clk
	     if (count = "1111111111") then -- keep state for 1024 clocks    
		 sign_reg <= Vcomp;
  	         count <= "0000000000"; -- set new count value
	         state <= non_ovps1_s2;       -- goto stateX if count=xxx
             end if;

when non_ovps1_s2 =>

                if   (sign_reg = '0' ) then
                  state <= deintegn;
                else
                  state <= deintegp;
                end if;

when deintegn | deintegp  =>

  if (count = "1111111111")  then
          --  sign_reg_j <= Vcomp;
             dout_reg <= count;
            state <= wait_toalign;

     end if;
if (count_flag < "11") then
    -- Till here count flag was in reset state and never started the counting, here I am starting it to count.
    count_flag <= count_flag + '1';
else
    if (count_hist = "00") then 
        -- Handling the comparison of Vcomp and sign_reg (initializing the count_hist to zero and checking if count is 1024, if not, we will count it further)
        if (count < "1111111111") then
            count <= count + '1';
        end if;
    end if;
end if;

-- count_hist will be zero until it sees a vcom_flag high
if (Vcomp = sign_reg) then
    if (vcomp_flag = '1') then
         vcomp_flag <= '0';
        count_hist <= "00";
    end if;
else
    vcomp_flag <= '1';  -- when vcom_flag is high, at count_hist is 1 all the vcomp, count have been assigned to internal signal.
    if (count_hist = "01") then
      --  sign_reg_j <= Vcomp;
        dout_reg <= count;
        state <= wait_toalign;
    else
        count_hist <= count_hist + '1';  -- keep the count_hist counting till vcomp is high; ideally, it will be zero
    end if;
end if;



when wait_toalign =>				--Deintegration to wait to align happens for 1030 clock

   if (count_hist = "11") then		--wait to align will wait for 2 more clock if it is not 1024 then it will reset else it will count for whole cycle ,
				      --as already the count value has been assigned to the internal signal in the previous case only so, here it just trying maintian the same TC period
        if (count = "1111111111") then
                count <="0000000000";
                state <= recover;

        else
                count <= count + '1';

        end if;
   else
      count_hist <= count_hist +'1' ;

   end if;






when recover =>
			  dout <= dout_reg;
		          DOut_sgn <= sign_reg;
 			  state <= init_reset;
		 

--******************************************************************************
--*                                                                            *
--*  Here complete in your own transition conditions for all states            *
--*                                                                            *
--*****************************************************************************

  end case;

 end if;

end process set_state;


end rtl;
--*************** end of file ml_control.vhd ********************************
