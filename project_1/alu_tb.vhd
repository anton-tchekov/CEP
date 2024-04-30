------------------------------------------------------------------
-- @name:   alu_tb.vhd
-- @author: Jochen Rust
-- @description: Techbench for ALU 
--		 (summer term 2024, WP_CEP, excercise 1)
-- @version: 1.1 (24/04/29)
-- @changelog: - minor syntax error correction concerning dst_v
-- 			   - modified read_data for VHDL'93/Modelsim compatibility
-- 			   - direct mapping of "stimuli.txt" due to VHDL'93 compatibility
------------------------------------------------------------------
 
-- libraries
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;                            -- Bibliotheken f?r TextIO / FileIO
USE STD.TEXTIO.ALL;
use std.env.finish;
use ieee.numeric_std.all;
 
-- entity
entity alu_tb is
end alu_tb;
 
------------------------------------------------------
-- architecture
architecture Behavioral of alu_tb is
 

constant BITS: integer := 17;


-- component declaration
component alu
	generic
	(
		DWIDTH : integer := 16
	);
    Port ( clk : in std_logic;
           rstn : in std_logic;
           src0 : in std_logic_vector (DWIDTH-1 downto 0);
           src1 : in std_logic_vector (DWIDTH-1 downto 0);
           opcode : in std_logic_vector(2 downto 0);
 
           dst : out std_logic_vector (DWIDTH-1 downto 0);
           sreg : out std_logic_vector (3 downto 0));
end component;
 
-- signal declaration
signal clk_s : std_logic := '0';
signal rstn_s : std_logic;
signal src0_s, src1_s, dst_s : std_logic_vector(BITS-1 downto 0);
signal opcode_s : std_logic_vector(2 downto 0);
signal sreg_s : std_logic_vector(3 downto 0);
signal counter_s : integer;

-- constant declaration
constant PERIOD : time := 20 ns;
constant JITTER : time := 3 ns;


--constant path : string := "stimuli.txt";
 
-- procedure body
-- read_data handles the read access to the stimuli.txt file
procedure read_data 
                    (variable lin : inout line;
					variable isComment : out boolean;
                    variable opcode : out std_logic_vector(2 downto 0);
                    variable src0 : out std_logic_vector(BITS-1 downto 0);
                    variable src1 : out std_logic_vector(BITS-1 downto 0);
                    variable dst : out std_logic_vector(BITS-1 downto 0);
                    variable sreg : out std_logic_vector(3 downto 0)) is
 
	-- variables 
    VARIABLE break : boolean := false;
    VARIABLE space : character;  
    VARIABLE opcode2 : std_logic_vector(1 downto 0);
    VARIABLE opcode1 : std_logic;
    begin
    --read(lin, nr, break);
	read(lin, opcode2, break);
    ASSERT break REPORT "Error reading input file!";
	-- skip if actual line is a comment (default true)
	isComment := true;
    IF(opcode2 /= "--") THEN
		-- read data otherwise
		read(lin, opcode1, break);
		opcode := opcode2 & opcode1;
        read(lin, space);
        read(lin, src0);
        read(lin, space);
        read(lin, src1);
        read(lin, space);
        read(lin, dst);
        read(lin, space);
        read(lin, sreg);
		isComment := false;
    end if;
end;
 
--    end procedure;
 
 
------------------------------------------------------
-- implementation
begin
 
-- clock/reset generation
clk_s <= not clk_s after PERIOD/2;
rstn_s <= '0', '1' after 3*PERIOD+JITTER;
 
-- component instantiation
dut : alu
    generic map (
       DWIDTH => BITS
    )
    port map(
    clk => clk_s,
    rstn => rstn_s,
    src0 => src0_s,
    src1 => src1_s,
    opcode => opcode_s,
    dst => dst_s,
    sreg => sreg_s
    );
 
-- stimuli process
process
    FILE input_f : text;
    variable status : FILE_OPEN_STATUS;
    variable lin_v    : line;
 
    variable counter_v : integer := 0;
    variable opcode_v : std_logic_vector(2 downto 0);
    variable src0_v : std_logic_vector(BITS-1 downto 0);
    variable src1_v : std_logic_vector(BITS-1 downto 0);
    variable dst_v : std_logic_vector(BITS-1 downto 0);
    variable sreg_v : std_logic_vector(3 downto 0);
	variable isComment_v : boolean;
begin
 
	-- open file
    file_open(status, input_f, "D:\Vivado\aufgabe1\project_1\stimuli.txt", READ_MODE);
    wait for 5*PERIOD;
 
	-- iterate through simuli file
    while(not endfile(input_f)) loop
		-- read entire line of file
        readline(input_f, lin_v);
		-- increase counter
        counter_v := counter_v + 1;
		-- set counter for debugging
		counter_s <= counter_v;
		-- read single data for opcode, src0, src1, dst, sreg
        read_data(lin_v, isComment_v, opcode_v, src0_v, src1_v, dst_v, sreg_v);
 
		if (isComment_v) then
			next;
         end if;

        --src0_s <= std_logic_vector(to_unsigned(4, 16));
        --src1_s <= std_logic_vector(to_unsigned(251, 16));
        --opcode_s <= "000";
        --dst_v := "0000000011111111";
        --sreg_v := "0000";
 
		-- assign data
        opcode_s <= opcode_v;
        src0_s <= src0_v;
        src1_s <= src1_v;
		-- wait for next cycle
        wait for PERIOD;
 
		-- throw assertions
        ASSERT (dst_v = dst_s) REPORT "Error result does not match in line " &integer'image(counter_v) severity ERROR;
        ASSERT (sreg_v = sreg_s) REPORT "Error status register flags do not match in line " &integer'image(counter_v) severity ERROR;
 
    end loop;
	-- close file
    file_close(input_f);
      REPORT "Testing completed";
	  WAIT;
end process;
 
 
end Behavioral;