------------------------------------------------------------------
-- @name:   increment.vhd
-- @author: Jochen Rust
-- @description: Incrementer with external offset
--		 (summer term 2024, WP_CEP, excercise 1)
------------------------------------------------------------------

-- libraries
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all; -- Achtung: Diese lib mit Vorsicht verwenden! 

-- entity
entity increment is
    Port ( clk : in STD_LOGIC;
           rstn : in STD_LOGIC;
           addend : in std_logic_vector(7 downto 0);
           result : out STD_LOGIC_VECTOR (7 downto 0) -- Hier war ein ; zu viel
           );
end increment; 

------------------------------------------------------
-- architecture
architecture Behavioral of increment is

-- signal/constant declaration
signal counter_cs, counter_ns : std_logic_vector(7 downto 0); -- signals for counter register

------------------------------------------------------
-- implementation
begin
-- output assignments
result <= counter_cs;

-- synchronous process
sync: process(clk)
begin
    if (clk'event and clk = '1') then -- Sync process hört auf clock
        if (rstn = '0') then
            counter_cs <= (others =>'0');
        else
        	-- neue wert zu aktuellem zuweisen
            counter_cs <= counter_ns;
        end if;
    end if;
end process sync;

comb: process(counter_cs, addend)
-- War kein warmduscher style
	variable counter_csv : std_logic_vector(7 downto 0);
begin
	-- Warmduscher style der addition
    -- Vorher wurde ns direkt mit ns addiert obwohl cs in sens liste
    -- counter_ns als sens liste mit altem code würde eine feedback loop erzeugen
	counter_csv := counter_cs;
    counter_csv := counter_cs + addend;
	counter_ns <= counter_csv;
end process comb;

-- Warum extra combitional bereich ?

end Behavioral;
