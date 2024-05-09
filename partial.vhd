--------
--by EB
--------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity partial is

        port( i_signal_2partial : in signed(15 downto 0);
              i_coeff_2partial  : in signed(15 downto 0);
              o_rolling_sum     : out signed(31 downto 0)   
        );

end partial;

architecture rtl of partial is

begin
o_rolling_sum <= i_signal_2partial  * i_coeff_2partial;

end rtl;