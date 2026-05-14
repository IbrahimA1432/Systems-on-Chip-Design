library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity md5_core_wrapper is
    port (
        clk                : in  std_logic;
        reset              : in  std_logic;

        -- Control signals from QSys conduit
        md5_start          : in  std_logic_vector(31 downto 0);
        md5_reset          : in  std_logic_vector(31 downto 0);
        md5_done           : out std_logic_vector(31 downto 0);

        -- Data signals from QSys conduit
        md5_writedata      : in  std_logic_vector(31 downto 0);
        md5_writeaddr      : in  std_logic_vector(8 downto 0);
        md5_wr             : in  std_logic;
        md5_readaddr       : in  std_logic_vector(6 downto 0);
        md5_readdata       : out std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of md5_core_wrapper is
begin

    u_md5_group : entity work.md5_group
        port map (
            clk       => clk,
            wr        => md5_wr,
            reset     => md5_reset,
            start     => md5_start,
            writedata => md5_writedata,
            writeaddr => md5_writeaddr,
            readaddr  => md5_readaddr,
            done      => md5_done,
            readdata  => md5_readdata
        );

end architecture;