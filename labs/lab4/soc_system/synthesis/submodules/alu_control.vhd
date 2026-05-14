library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity alu_control is
    port (
        avs_s0_address   : in  std_logic_vector(3 downto 0)  := (others => '0');
        avs_s0_write     : in  std_logic                     := '0';
        avs_s0_writedata : in  std_logic_vector(31 downto 0) := (others => '0');
        avs_s0_read      : in  std_logic                     := '0';
        avs_s0_readdata  : out std_logic_vector(31 downto 0);
        clk              : in  std_logic                     := '0';
        reset            : in  std_logic                     := '0';
        alu_start        : out std_logic_vector(31 downto 0);
        alu_reset        : out std_logic_vector(31 downto 0);
        alu_done         : in  std_logic_vector(31 downto 0) := (others => '0')
    );
end entity alu_control;

architecture rtl of alu_control is
    signal start_sig : std_logic_vector(31 downto 0) := (others => '0');
    signal reset_sig : std_logic_vector(31 downto 0) := (others => '0');
begin

    process(clk, reset)
    begin
        if reset = '1' then
            start_sig      <= (others => '0');
            reset_sig      <= (others => '0');
            avs_s0_readdata <= (others => '0');

        elsif rising_edge(clk) then
            if avs_s0_write = '1' then
                case avs_s0_address is
                    when "0000" =>
                        start_sig <= avs_s0_writedata;
                    when "0001" =>
                        reset_sig <= avs_s0_writedata;
                    when others =>
                        null;
                end case;

            elsif avs_s0_read = '1' then
                reset_sig <= (others => '0');

                case avs_s0_address is
                    when "0000" =>
                        avs_s0_readdata <= start_sig;
                    when "0001" =>
                        avs_s0_readdata <= reset_sig;
                    when "0010" =>
                        avs_s0_readdata <= alu_done;
                    when others =>
                        avs_s0_readdata <= (others => '0');
                end case;
            end if;
        end if;
    end process;

    alu_start <= start_sig;
    alu_reset <= reset_sig;

end architecture rtl;