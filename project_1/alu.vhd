------------------------------------------------------------------
-- @name:   alu.vhd
-- @author: Haron Nazari, Anton Tchekov
-- @description: ALU design file 
--		 (summer term 2024, WP_CEP, excercise 1)
------------------------------------------------------------------
 
-- libraries
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all; -- Caution: this lib must be handled with care 

-- entity
entity alu is
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
end alu;
 
------------------------------------------------------------------
-- architecture
architecture Behavioral of alu is
 
-- signal declaration
signal sreg_ns, sreg_cs: std_logic_vector(3 downto 0);
signal dst_ns, dst_cs: std_logic_vector(DWIDTH-1 downto 0);

-- constant declaration
constant OPCODE_ADD : std_logic_vector(2 downto 0) := "000";
constant OPCODE_SUB : std_logic_vector(2 downto 0) := "001";
constant OPCODE_SHL : std_logic_vector(2 downto 0) := "010";
constant OPCODE_SHR : std_logic_vector(2 downto 0) := "011";
constant OPCODE_AND : std_logic_vector(2 downto 0) := "100";
constant OPCODE_OR  : std_logic_vector(2 downto 0) := "101";
constant OPCODE_NOT : std_logic_vector(2 downto 0) := "110";
constant OPCODE_XOR : std_logic_vector(2 downto 0) := "111";

constant ALL_ZERO   : std_logic_vector(dst'range) := (others => '0');

------------------------------------------------------------------
-- implementation
begin

-- output assignments
dst <= dst_cs;
sreg <= sreg_cs;

-- synchronous process
sync: process(clk)
begin
    if rising_edge(clk) then
        if rstn = '0' then
            dst_cs <= (others => '0');
            sreg_cs <= (others => '0');
        else
            dst_cs <= dst_ns;
            sreg_cs <= sreg_ns;
        end if;
    end if;
end process sync;

-- combinatorial process
comb: process(src0, src1, opcode, sreg_cs)
    variable opcode_v: std_logic_vector(2 downto 0);
    variable src0_v: std_logic_vector(DWIDTH-1 downto 0);
    variable src1_v: std_logic_vector(DWIDTH-1 downto 0);

    variable srcw0_v: std_logic_vector(DWIDTH downto 0);
    variable srcw1_v: std_logic_vector(DWIDTH downto 0);
    variable dstw_v: std_logic_vector(DWIDTH downto 0);

    variable dst_v: std_logic_vector(DWIDTH-1 downto 0);
    variable negative_v, carry_v, overflow_v, zero_v: std_logic;
    variable sreg_v: std_logic_vector(3 downto 0);
begin
    -- Read inputs
    src0_v := src0;
    src1_v := src1;
    opcode_v := opcode;
    sreg_v := sreg_cs;

    -- Calulations
    zero_v := sreg_v(3);
    negative_v := sreg_v(2);
    carry_v := sreg_v(1);
    overflow_v := sreg_v(0);

    case opcode_v is
        when OPCODE_ADD =>
            srcw0_v := '0' & src0_v;
            srcw1_v := '0' & src1_v;
            dstw_v := srcw0_v + srcw1_v;
            dst_v := dstw_v(dst_v'range);
            carry_v := dstw_v(dstw_v'high);
        when OPCODE_SUB =>
            srcw0_v := '0' & src0_v;
            srcw1_v := '0' & src1_v;
            dstw_v := srcw0_v - srcw1_v;
            dst_v := dstw_v(dst_v'range);
            carry_v := dstw_v(dstw_v'high);
        when OPCODE_SHL =>
            dst_v := src0_v(src0_v'high-1 downto 0) & '0';
            carry_v := src0_v(src0_v'high);
        when OPCODE_SHR =>
            dst_v := '0' & src0_v(src0'high downto 1);
            carry_v := src0_v(src0_v'low);
        when OPCODE_AND =>
            dst_v := src0 AND src1;
        when OPCODE_OR =>
            dst_v := src0 OR src1;
        when OPCODE_NOT =>
            dst_v := NOT src0;
        when OPCODE_XOR =>
            dst_v := src0 XOR src1;
        when others =>
            null;
    end case;

    negative_v := dst_v(dst_v'high);
    if dst_v = ALL_ZERO then
        zero_v := '1';
    else
        zero_v := '0';
    end if;
    overflow_v := '0';
    sreg_v := zero_v & negative_v & carry_v & overflow_v;
    
    -- Write outputs
    sreg_ns <= sreg_v;
    dst_ns <= dst_v;
end process comb;

end Behavioral;