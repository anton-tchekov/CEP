------------------------------------------------------------------
-- @name:   alu_tb.vhd
-- @author: Jochen Rust
-- @description: Techbench for ALU 
--		 (summer term 2024, WP_CEP, excercise 1)
------------------------------------------------------------------

-- libraries
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;                            -- Bibliotheken für TextIO / FileIO
USE STD.TEXTIO.ALL;

-- entity
entity alu_tb is
end alu_tb;

------------------------------------------------------
-- architecture
architecture Behavioral of alu_tb is

-- component declaration
component alu
    Port ( clk : in STD_LOGIC;
           rstn : in STD_LOGIC;
           src0 : in STD_LOGIC_VECTOR (15 downto 0);
           src1 : in STD_LOGIC_VECTOR (15 downto 0);
           opcode : in STD_LOGIC_VECTOR (2 downto 0);
           
           dst : out STD_LOGIC_VECTOR (15 downto 0);
           sreg : out STD_LOGIC_VECTOR (3 downto 0));
end component;

-- signal declaration
signal clk_s : std_logic := '0';
signal rstn_s : std_logic;
signal src0_s, src1_s, dst_s : std_logic_vector(15 downto 0);
signal opcode_s : std_logic_vector(2 downto 0);
signal sreg_s : std_logic_vector(3 downto 0);

-- constant declaration
constant PERIOD : time := 20 ns;
constant JITTER : time := 3 ns;
constant path : string := "stimuli.txt";

-- procedure body
-- read_data handles the read access to the stimuli.txt file
-- INFO: Diese procedure müssen Sie nicht erklären können
procedure read_data 
                    (variable lin : inout line;
                    variable opcode : out std_logic_vector(2 downto 0);
                    variable src0 : out std_logic_vector(15 downto 0);
                    variable src1 : out std_logic_vector(15 downto 0);
                    variable dst : out std_logic_vector(15 downto 0);
                    variable sreg : out std_logic_vector(3 downto 0)) is
	
	-- variables 
    VARIABLE break : boolean := false;
    VARIABLE space : character;  
    VARIABLE nr    : string(1 to 2);
    begin
    read(lin, nr, break);
    ASSERT break REPORT "Error reading input file!";
	-- skip if actual line is a comment
    IF(nr(1 to 2) /= "--") THEN
		-- read data otherwise
        hread(lin, opcode);
        read(lin, space);
        read(lin, src0);
        read(lin, space);
        read(lin, src1);
        read(lin, space);
        read(lin, dst);
        read(lin, space);
        read(lin, sreg);
    end if;
    
    end procedure;
    
    
------------------------------------------------------
-- implementation
begin

-- clock/reset generation
clk_s <= not clk_s after PERIOD/2;
rstn_s <= '0', '1' after 3*PERIOD+JITTER;

-- component instantiation
dut : alu 
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
    variable src0_v : std_logic_vector(15 downto 0);
    variable src1_v : std_logic_vector(15 downto 0);
    variable dst_v : std_logic_vector(15 downto 0);
    variable sreg_v : std_logic_vector(3 downto 0);
begin

	-- open file
    file_open(status, input_f, path, READ_MODE);
    wait for 5*PERIOD;
      
	-- iterate through simuli file
    while(not endfile(input_f)) loop
		-- read entire line of file
        readline(input_f, lin_v);
		-- increase counter
        counter_v := counter_v + 1;
		-- read single data for opcode, src0, src1, dst, sreg
        read_data(lin_v, opcode_v, src0_v, src1_v, dst_v, sreg_v);
   
		-- assign data
        opcode_s <= opcode_v;
        src0_s <= src0_v;
        src1_s <= src1_v;
		-- wait for next cycle
        wait for PERIOD;

		-- throw assertions
        ASSERT (result_v = result_s) REPORT "Error result does not match in line " &integer'image(counter_v) severity ERROR;
        ASSERT (sreg_v = sreg_s) REPORT "Error status register flags do not match in line " &integer'image(counter_v) severity ERROR;
            
    end loop;
	-- close file
    file_close(input_f);
      
end process;


end Behavioral;

