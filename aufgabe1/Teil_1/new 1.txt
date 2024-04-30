--------------------------------------------------------------------------------
-- @name:        alu.vhd
-- @author:      Anton Tchekov
-- @description: ALU design file (summer term 2024, WP_CEP, excercise 1)
--------------------------------------------------------------------------------

-- Libraries
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

-- Entity
entity alu is
	generic
	(
		DWIDTH : integer := 16
	);
	port
	(
		clk    : in  std_logic;
		rstn   : in  std_logic;
		src0   : in  std_logic_vector(DWIDTH - 1 downto 0);
		src1   : in  std_logic_vector(DWIDTH - 1 downto 0);
		opcode : in  std_logic_vector(2 downto 0);

		dst    : out std_logic_vector(DWIDTH - 1 downto 0);
		sreg   : out std_logic_vector(3 downto 0)
	);
end alu;

--------------------------------------------------------------------------------
-- Architecture
architecture behavioral of alu is

-- Signal declaration
signal src0 : std_logic_vector(DWIDTH - 1 downto 0);
signal src1 : std_logic_vector(DWIDTH - 1 downto 0);

-- Constant declaration
constant OPCODE_ADD : std_logic_vector(opcode'range) := "000";
constant OPCODE_SUB : std_logic_vector(opcode'range) := "001";
constant OPCODE_SHL : std_logic_vector(opcode'range) := "010";
constant OPCODE_SHR : std_logic_vector(opcode'range) := "011";
constant OPCODE_AND : std_logic_vector(opcode'range) := "100";
constant OPCODE_OR  : std_logic_vector(opcode'range) := "101";
constant OPCODE_NOT : std_logic_vector(opcode'range) := "110";
constant OPCODE_XOR : std_logic_vector(opcode'range) := "111";

constant ALL_ZERO   : std_logic_vector(dst'range) := (others => '0');

--------------------------------------------------------------------------------
-- Implementation
begin
	process_alu: process(clk)
		variable v_opcode : std_logic_vector(opcode'range);
		variable v_src0   : std_logic_vector(src0'range);
		variable v_src1   : std_logic_vector(src1'range);
		variable v_sreg   : std_logic_vector(sreg'range);
	begin
		-- Synchronous process
		if (clk'event and clk = '1') then
			-- Combinatorial process

			-- Read inputs
			v_opcode := opcode;
			v_src0 := src0;
			v_src1 := src1;

			-- Calculate
			if v_opcode = OPCODE_ADD then
				v_dst := v_src0 + v_src1;
				v_carry := v_dst(v_dst'high);
			elsif v_opcode = OPCODE_SUB then
				v_dst := v_src0 - v_src1;
				v_carry := v_dst(v_dst'high);
			elsif v_opcode = OPCODE_SHL then
				v_dst := v_src((src0'high - 1) downto 0) & '0';
				v_carry := v_src0(v_src'high);
			elsif v_opcode = OPCODE_SHR then
				v_dst := '0' & v_src(src0'high downto 1);
				v_carry := v_src0(src0'low);
			elsif v_opcode = OPCODE_AND then
				v_dst := v_src0 and v_src1;
			elsif v_opcode = OPCODE_OR then
				v_dst := v_src0 or v_src1;
			elsif v_opcode = OPCODE_XOR then
				v_dst := v_src0 xor v_src1;
			elsif v_opcode = OPCODE_NOT then
				v_dst := not v_src0;
			end if;
			v_negative := v_dst'high;
			v_zero := v_dst = ALL_ZERO;
			v_sreg := v_zero & v_negative & v_carry & v_overflow;

			-- Output assignments
			dst <= v_dst;
			sreg <= v_sreg;
		end if;
	end process process_alu;
end behavioral;
