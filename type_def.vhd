--------
--by EB
--------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package type_def is 

type t_coeff_arr is array (integer range <>) of signed(15 downto 0);
type t_coeff_arr32 is array (integer range <>) of signed(31 downto 0);

end type_def;

package body type_def is

end type_def;