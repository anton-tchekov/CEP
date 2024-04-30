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
use ieee.std_logic_unsigned.all;

-- entity
entity increment is
	port
	(
		clk    : in  std_logic;
		rstn   : in  std_logic;
		addend : in  std_logic_vector(7 downto 0);
		result : out std_logic_vector(7 downto 0);
	);
end increment;

------------------------------------------------------
-- architecture
architecture Behavioral of increment is

-- signal/constant declaration
signal counter_cs, counter_ns : std_logic_vector(7 downto 0);

------------------------------------------------------
-- implementation
begin
-- output assignments

result <= counter_cs;

-- synchronous process

-- Fehler 1: Nur clk sollte in der Sensitivity List stehen
-- sync: process(counter_ns)
sync: process(clk)
begin
	if (clk'event and clk = '1') then
		if (rstn = '0') then
			counter_cs <= (others => '0');
		else
			counter_cs <= counter_ns;
		end if;
	end if;
	-- Fehler 2: Nur bei steigender flanke von clk sollte zugewiesen werden
	-- result <= counter_cs;
end process sync;

-- combinatorial process
comb: process(counter_cs, addend)
variable counter_v : std_logic_vector(7 downto 0);
begin
	-- Read input signals into variables
	counter_v := counter_cs;

	-- Calculate using variables
	counter_v := counter_v + addend;

	-- Write variables to signals
	counter_ns <= counter_v;

	-- increase counter
	-- Fehler 4: counter_ns wird benutzt statt counter_cs
	-- counter_ns <= counter_ns + addend;
end process comb;

end Behavioral;
