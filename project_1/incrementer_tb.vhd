------------------------------------------------------------------
-- @name:   increment_tb.vhd
-- @author: Jochen Rust
-- @description: Techbench for incrementer with external offset
--		 (summer term 2024, WP_CEP, excercise 1)
------------------------------------------------------------------

-- libraries
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use std.env.finish;

-- entity
entity increment_tb is
end increment_tb;

------------------------------------------------------
-- architecture
architecture Behavioral of increment_tb is

-- component declaration
component increment
    Port ( clk : in STD_LOGIC;
           rstn : in STD_LOGIC;
           addend : STD_LOGIC_VECTOR(7 downto 0);
           result : out STD_LOGIC_VECTOR (7 downto 0)
           );
end component;

-- signal declaration
signal clk_s : std_logic := '0';
signal rstn_s : std_logic := '1';
signal addend_s : std_logic_vector(7 downto 0) := (others =>'0');
signal result_s : std_logic_vector(7 downto 0);

-- constant declaration
constant PERIOD : time := 20 ns;
constant JITTER : time := 3 ns;

begin

-- clock/reset generation
clk_s <= not clk_s after PERIOD/2;
rstn_s <= '0', '1' after 3*PERIOD+JITTER;

-- component instantiation
dut : increment
    port map(
    clk => clk_s,
    addend => addend_s,
    rstn => rstn_s,
    result => result_s
    );


-- stimuli process
process
variable i : integer;
begin
    -- wait until reset has been performed
    wait for 5*PERIOD;
    -- loop 20 times 
    for i in 0 to 20 loop
        -- set addend to current loop variable with integer to std_logic_vector conversion
        addend_s <= std_logic_vector(to_unsigned(i,8));
        -- wait one cycle
        wait for PERIOD;
        -- report output with std_logic_vector to integer conversion
        report "Current value: " &integer'image(to_integer(unsigned(result_s)));  
    end loop;
	finish;
end process;

end Behavioral;
