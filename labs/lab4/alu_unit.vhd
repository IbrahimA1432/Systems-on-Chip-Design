library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity alu_unit is
    port(
        clk         : in  std_logic;
        reset       : in  std_logic;
        enable      : in  std_logic;
        alu_a       : in  std_logic_vector(15 downto 0);
        alu_b       : in  std_logic_vector(15 downto 0);
        alu_op      : in  std_logic;                       -- '1' = add, '0' = subtract
        shift_en    : in  std_logic;                       -- '1' = shift B before ALU
        shift_dir   : in  std_logic;                       -- '0' = left, '1' = right
        shift_amt   : in  std_logic_vector(3 downto 0);    -- 0 to 15
        alu_done    : out std_logic;
        alu_result  : out std_logic_vector(31 downto 0)
    );
end entity alu_unit;

architecture Behaviour of alu_unit is
    signal result_reg : std_logic_vector(31 downto 0) := (others => '0');
    signal done_reg   : std_logic := '0';
begin

    process(clk, reset)
        variable a_val       : unsigned(15 downto 0);
        variable b_val       : unsigned(15 downto 0);
        variable b_shifted   : unsigned(15 downto 0);
        variable res_16      : unsigned(15 downto 0);
        variable shamt_int   : integer range 0 to 15;
    begin
        if reset = '1' then
            result_reg <= (others => '0');
            done_reg   <= '0';

        elsif rising_edge(clk) then
            done_reg <= '0';

            if enable = '1' then
                a_val := unsigned(alu_a);
                b_val := unsigned(alu_b);
                shamt_int := to_integer(unsigned(shift_amt));

                if shift_en = '1' then
                    if shift_dir = '0' then
                        b_shifted := shift_left(b_val, shamt_int);
                    else
                        b_shifted := shift_right(b_val, shamt_int);
                    end if;
                else
                    b_shifted := b_val;
                end if;

                if alu_op = '1' then
                    res_16 := a_val + b_shifted;
                else
                    res_16 := a_val - b_shifted;
                end if;

                result_reg <= std_logic_vector(to_unsigned(0, 16)) & std_logic_vector(res_16);
                done_reg   <= '1';
            end if;
        end if;
    end process;

    alu_result <= result_reg;
    alu_done   <= done_reg;

end architecture Behaviour;