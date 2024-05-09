--------
--by EB
--------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.type_def.all;

entity filter is 
    
    generic (g_ORDER : natural := 3);
    
    port (
            clk : in std_logic;
            i_signal : in signed(15 downto 0);
            i_coeff_input  : in t_coeff_arr(0 to g_order-1);
            o_filtered_signal : out signed(31 downto 0);
            o_filter_rdy : out boolean := false  
    );
end filter;

architecture rtl of filter is
    component partial is
        port( i_signal_2partial : signed(15 downto 0);
              i_coeff_2partial  : signed(15 downto 0);
           --   o_signal_2next    : signed(15 downto 0);
              o_rolling_sum     : out signed(31 downto 0)   
        );
    end component partial;
    
   -- signal r_part_filtered_signal : signed(31 downto 0);
  --  signal r_part_filtered_sig2 : signed(31 downto 0);

    signal r_inputs : t_coeff_arr(0 to g_order-1);                --DODAC ZBIERANIE WARTOSCI SYGNALU
    signal r_outputs: t_coeff_arr32(0 to g_order-1);
    signal w_counter_ready: natural := 0;
    signal w_ready : boolean := false;                           --DAWAC WYNIK DOPIERO KIEDY WYPELNIONY PRAWDZIWYMI DANYMI
begin

    
    GEN_PARTIALS : for ii in 0 to g_ORDER-1 generate
        PARTIAL_INST : partial
            port map(
                        i_signal_2partial => r_inputs(ii) ,
                        i_coeff_2partial => i_coeff_input(ii) ,
                    --    o_signal_2next => r_inputs(ii+1),        -- NIE WIEM CZY ZADZIALA TRZEBA TESTOW!!!
                        o_rolling_sum =>  r_outputs(ii)          --JESZCZE ZSUMOWAC W KAZDYM CYKLU 
                    );
    end generate GEN_PARTIALS;

    process(clk)
        variable r_part_filtered_signal : signed(31 downto 0);
        variable v_inputs_temp : t_coeff_arr(0 to g_order-1);
    begin 
        if rising_edge(clk) then
            --zbieranie do r_inputs (UZYC FIFO)
           -- if w_counter_ready<g_order-1 then
          --      w_counter_ready<=w_counter_ready+1;
          --  else
           --     w_ready <= not w_ready;
           --     w_counter_ready <= w_counter_ready
           -- end if; 
           
           
           if not w_ready then
                if w_counter_ready < g_order+1 then
                    w_counter_ready <= w_counter_ready +1;
                else
                    w_ready <= not w_ready;
                end if;
                
           end if;
           
           v_inputs_temp(1 to g_order-1) := r_inputs(0 to g_order-2);
           v_inputs_temp(0) := i_signal;
           
           r_inputs <= v_inputs_temp;
         --  r_inputs(1 to g_order-1) <= r_inputs(0 to g_order-2);
           --bledna proba
             --  r_inputs(0 to g_order-2) <= r_inputs(1 to g_order-1);
          --  r_inputs(0) <= i_signal;
                       
            --flaga w_ready
            --sumowanie do ostatecznego wyniku
            
            if w_ready then
            
                    O_filter_rdy <= true;
                  
                   r_part_filtered_signal :=to_signed(0,32);
                   for jj in 0 to g_order-1 loop
                        r_part_filtered_signal := r_part_filtered_signal + r_outputs(jj); --cos tu jest zle
                   end loop;
                 --   r_part_filtered_signal <= r_outputs(1)+r_outputs(2);
                   o_filtered_signal <= r_part_filtered_signal;
                  
            end if;
            
            

            
            
        end if;    
    end process;
end rtl;