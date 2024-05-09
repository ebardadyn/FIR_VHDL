--------
--by EB
--------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use work.type_def.all;

entity FIR_tb is
--nic
    constant c_order : integer := 3;
end FIR_tb;

architecture behave of FIR_tb is

signal r_coeff_arr : t_coeff_arr(0 to c_order-1);
signal r_all_inputs : t_coeff_arr(0 to 17);

constant c_FILE_SIGIN : string := "C:/Users/A/FIR_1/dat/SIGNALS.dat";
constant c_FILE_COEFF : string := "C:/Users/A/FIR_1/dat/COEFF.dat";
constant c_FILE_FILTOUT : string := "C:/Users/A/FIR_1/dat/FILTERED.dat";
constant r_line_count : natural :=18;

signal r_clock : std_logic := '0';

signal r_coeff_rdy : boolean := false;
signal r_complete_rdy : boolean := false;
signal r_filtered_rdy : boolean := false;


signal r_latest_input : signed(15 downto 0);
signal r_output_final : signed(31 downto 0);
--type UNSIGNED_FILE is file of unsigned;   ---moze nie dzialac

file f_sigin : text; 
file f_coeff : text; 
file f_filtout : text; 


component filter is 
    
    generic (g_ORDER : natural := 3);
    
    port (
            clk : in std_logic;
            i_signal : in signed(15 downto 0);
            i_coeff_input  : in t_coeff_arr(0 to g_order-1);
            o_filtered_signal : out signed(31 downto 0);
            o_filter_rdy : out boolean 
    );
end component filter;


begin


UUT: filter
    
    generic map (g_ORDER => c_order)
    
    port map (
            clk => r_clock,
            i_signal  => r_latest_input,
            i_coeff_input  => r_coeff_arr,
            o_filtered_signal => r_output_final ,
            o_filter_rdy => r_filtered_rdy
 
    );


r_clock <= not r_clock after 100 ms;

    process (r_clock) is
        variable r_files_opened : boolean := false;
        variable v_sigin_line : line;
        variable v_coeff_line : line;
        variable v_filtout_line : line;
        variable r_order_count : integer := 0;
        variable v_input_line : integer := 0;
        variable r_sig_access : boolean := true;

        variable r_read_val : std_ulogic_vector(15 downto 0);
        variable r_read_sig : std_ulogic_vector(15 downto 0);

    begin  
    
        if not r_files_opened then
            file_open(f_sigin,c_file_sigin,read_mode);
            file_open(f_coeff,c_file_coeff,read_mode);
            file_open(f_filtout,c_file_filtout,write_mode);
            r_files_opened := not r_files_opened;
        end if;

        --wczytac coeff
            if not r_coeff_rdy then
                while not endfile(f_coeff) loop
                    readline(f_coeff, v_coeff_line);
                    read(v_coeff_line, r_read_val);
                    r_coeff_arr(r_order_count) <= signed(r_read_val);
                    r_order_count := r_order_count+1;
                end loop;
            file_close(f_coeff);
            r_coeff_rdy <= true;
            r_order_count :=0;
            end if;
            
            if r_coeff_rdy and r_sig_access then
                while not endfile(f_sigin) loop
                    readline(f_sigin, v_sigin_line);
                    read(v_sigin_line, r_read_sig);
                    r_all_inputs(v_input_line) <= signed(r_read_sig);
                    v_input_line := v_input_line +1;
                end loop;
                r_sig_access := false;
            end if;
       
        if rising_edge (r_clock) and r_coeff_rdy and not r_sig_access then
            
            if r_order_count < r_line_count then
            
                r_latest_input <= r_all_inputs(r_order_count);
                r_order_count := r_order_count+1; 
                 
                if r_filtered_rdy then               
                    write(v_filtout_line,std_logic_vector(r_output_final),left,32);
                    writeline(f_filtout,v_filtout_line);
                end if;
            end if;
            
        end if;
        
     --  if endfile(f_sigin) then
       --    file_close(f_sigin);
       --    file_close(f_filtout);
      -- end if;
    end process;
    
end behave;



---dziala ale 
---przerobic flagi na maszyne stanow
---dynamiczniejsze wczytywanie sygnalow