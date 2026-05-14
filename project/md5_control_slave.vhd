library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity md5_control_slave is
    port (
        clk              : in  std_logic;
        reset            : in  std_logic;

        -- Avalon-MM slave interface
        avs_s0_address   : in  std_logic_vector(1 downto 0);
        avs_s0_read      : in  std_logic;
        avs_s0_write     : in  std_logic;
        avs_s0_writedata : in  std_logic_vector(31 downto 0);
        avs_s0_readdata  : out std_logic_vector(31 downto 0);

        -- Conduit signals to MD5 core
        md5_start        : out std_logic_vector(31 downto 0);
        md5_reset        : out std_logic_vector(31 downto 0);
        md5_done         : in  std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of md5_control_slave is
    signal start_pulse  : std_logic_vector(31 downto 0) := (others => '0');
    signal reset_pulse  : std_logic_vector(31 downto 0) := (others => '0');
    signal readdata_i   : std_logic_vector(31 downto 0) := (others => '0');
begin

    md5_start <= start_pulse;
    md5_reset <= reset_pulse;

    process(clk, reset)
    begin
        if reset = '1' then
            start_pulse <= (others => '0');
            reset_pulse <= (others => '0');
        elsif rising_edge(clk) then
            -- default: pulses go low every cycle
            start_pulse <= (others => '0');
            reset_pulse <= (others => '0');

            if avs_s0_write = '1' then
                case avs_s0_address is
                    when "00" =>
                        start_pulse <= avs_s0_writedata;  -- one-cycle pulse
                    when "01" =>
                        reset_pulse <= avs_s0_writedata;  -- one-cycle pulse
                    when others =>
                        null;
                end case;
            end if;
        end if;
    end process;

    process(avs_s0_read, avs_s0_address, md5_done)
    begin
        readdata_i <= (others => '0');

        if avs_s0_read = '1' then
            case avs_s0_address is
                when "00" =>
                    readdata_i <= (others => '0');
                when "01" =>
                    readdata_i <= (others => '0');
                when "10" =>
                    readdata_i <= md5_done;
                when others =>
                    readdata_i <= (others => '0');
            end case;
        end if;
    end process;

    avs_s0_readdata <= readdata_i;

end architecture;
