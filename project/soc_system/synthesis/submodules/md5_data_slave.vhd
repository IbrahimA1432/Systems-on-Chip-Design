library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity md5_data_slave is
    port (
        clk              : in  std_logic;
        reset            : in  std_logic;

        -- Avalon-MM slave interface
        avs_s0_address   : in  std_logic_vector(2 downto 0);
        avs_s0_read      : in  std_logic;
        avs_s0_write     : in  std_logic;
        avs_s0_writedata : in  std_logic_vector(31 downto 0);
        avs_s0_readdata  : out std_logic_vector(31 downto 0);

        -- Conduit signals to MD5 core
        md5_writedata    : out std_logic_vector(31 downto 0);
        md5_writeaddr    : out std_logic_vector(8 downto 0);
        md5_wr           : out std_logic;
        md5_readaddr     : out std_logic_vector(6 downto 0);
        md5_readdata     : in  std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of md5_data_slave is

    signal writedata_reg : std_logic_vector(31 downto 0) := (others => '0');
    signal writeaddr_reg : std_logic_vector(8 downto 0)  := (others => '0');
    signal wr_pulse      : std_logic := '0';
    signal readaddr_reg  : std_logic_vector(6 downto 0)  := (others => '0');
    signal readdata_i    : std_logic_vector(31 downto 0) := (others => '0');

begin

    md5_writedata <= writedata_reg;
    md5_writeaddr <= writeaddr_reg;
    md5_wr        <= wr_pulse;
    md5_readaddr  <= readaddr_reg;

    process(clk, reset)
    begin
        if reset = '1' then
            writedata_reg <= (others => '0');
            writeaddr_reg <= (others => '0');
            wr_pulse      <= '0';
            readaddr_reg  <= (others => '0');
        elsif rising_edge(clk) then
            -- default: pulse low every cycle
            wr_pulse <= '0';

            if avs_s0_write = '1' then
                case avs_s0_address is
                    when "000" =>
                        writedata_reg <= avs_s0_writedata;              -- 0x00
                    when "001" =>
                        writeaddr_reg <= avs_s0_writedata(8 downto 0);  -- 0x04
                    when "010" =>
                        wr_pulse <= avs_s0_writedata(0);                -- 0x08 one-cycle pulse
                    when "011" =>
                        readaddr_reg <= avs_s0_writedata(6 downto 0);   -- 0x0C
                    when others =>
                        null;
                end case;
            end if;
        end if;
    end process;

    process(avs_s0_read, avs_s0_address, writedata_reg, writeaddr_reg, readaddr_reg, md5_readdata)
    begin
        readdata_i <= (others => '0');

        if avs_s0_read = '1' then
            case avs_s0_address is
                when "000" =>
                    readdata_i <= writedata_reg;
                when "001" =>
                    readdata_i(8 downto 0) <= writeaddr_reg;
                when "010" =>
                    readdata_i <= (others => '0'); -- do not read back pulse
                when "011" =>
                    readdata_i(6 downto 0) <= readaddr_reg;
                when "100" =>
                    readdata_i <= md5_readdata;
                when others =>
                    readdata_i <= (others => '0');
            end case;
        end if;
    end process;

    avs_s0_readdata <= readdata_i;

end architecture;
