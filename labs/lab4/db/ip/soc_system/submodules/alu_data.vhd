library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity alu_data is
    port (
        avs_s0_address    : in  std_logic_vector(3 downto 0)  := (others => '0');
        avs_s0_read       : in  std_logic                     := '0';
        avs_s0_write      : in  std_logic                     := '0';
        avs_s0_readdata   : out std_logic_vector(31 downto 0);
        avs_s0_writedata  : in  std_logic_vector(31 downto 0) := (others => '0');
        clk               : in  std_logic                     := '0';
        reset             : in  std_logic                     := '0';

        alu_in1           : out std_logic_vector(31 downto 0);
        alu_in2           : out std_logic_vector(31 downto 0);
        alu_cfg           : out std_logic_vector(31 downto 0);

        alu_result        : in  std_logic_vector(31 downto 0) := (others => '0')
    );
end entity alu_data;

architecture rtl of alu_data is
    signal in1_sig : std_logic_vector(31 downto 0) := (others => '0');
    signal in2_sig : std_logic_vector(31 downto 0) := (others => '0');
    signal cfg_sig : std_logic_vector(31 downto 0) := (others => '0');
begin

    process(clk, reset)
    begin
        if reset = '1' then
            avs_s0_readdata <= (others => '0');
            in1_sig         <= (others => '0');
            in2_sig         <= (others => '0');
            cfg_sig         <= (others => '0');

        elsif rising_edge(clk) then
            if avs_s0_read = '1' then
                case avs_s0_address is
                    when "0000" =>
                        avs_s0_readdata <= alu_result;
                    when "0001" =>
                        avs_s0_readdata <= in1_sig;
                    when "0010" =>
                        avs_s0_readdata <= in2_sig;
                    when "0011" =>
                        avs_s0_readdata <= cfg_sig;
                    when others =>
                        avs_s0_readdata <= (others => '0');
                end case;

            elsif avs_s0_write = '1' then
                case avs_s0_address is
                    when "0000" =>
                        in1_sig <= "0000000000000000" & avs_s0_writedata(15 downto 0);
                    when "0001" =>
                        in2_sig <= "0000000000000000" & avs_s0_writedata(15 downto 0);
                    when "0010" =>
                        cfg_sig <= avs_s0_writedata;
                    when others =>
                        null;
                end case;
            end if;
        end if;
    end process;

    alu_in1 <= in1_sig;
    alu_in2 <= in2_sig;
    alu_cfg <= cfg_sig;

end architecture rtl;