library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity md5_soc_top is
    port(
        CLOCK_50            : in    std_logic;
        HPS_DDR3_RZQ        : in    std_logic;
        HPS_ENET_RX_CLK     : in    std_logic;
        HPS_ENET_RX_DV      : in    std_logic;

        HPS_DDR3_ADDR       : out   std_logic_vector(14 downto 0);
        HPS_DDR3_BA         : out   std_logic_vector(2 downto 0);
        HPS_DDR3_CS_N       : out   std_logic;
        HPS_DDR3_CK_P       : out   std_logic;
        HPS_DDR3_CK_N       : out   std_logic;
        HPS_DDR3_CKE        : out   std_logic;

        HPS_USB_DIR         : in    std_logic;
        HPS_USB_NXT         : in    std_logic;
        HPS_USB_CLKOUT      : in    std_logic;

        HPS_ENET_RX_DATA    : in    std_logic_vector(3 downto 0);

        HPS_SD_DATA         : inout std_logic_vector(3 downto 0);
        HPS_DDR3_DQS_N      : inout std_logic_vector(3 downto 0);
        HPS_DDR3_DQS_P      : inout std_logic_vector(3 downto 0);
        HPS_ENET_MDIO       : inout std_logic;
        HPS_USB_DATA        : inout std_logic_vector(7 downto 0);
        HPS_DDR3_DQ         : inout std_logic_vector(31 downto 0);
        HPS_SD_CMD          : inout std_logic;

        HPS_ENET_TX_DATA    : out   std_logic_vector(3 downto 0);
        HPS_DDR3_DM         : out   std_logic_vector(3 downto 0);

        HPS_DDR3_ODT        : out   std_logic;
        HPS_DDR3_RAS_N      : out   std_logic;
        HPS_DDR3_RESET_N    : out   std_logic;
        HPS_DDR3_CAS_N      : out   std_logic;
        HPS_DDR3_WE_N       : out   std_logic;

        HPS_ENET_MDC        : out   std_logic;
        HPS_ENET_TX_EN      : out   std_logic;
        HPS_USB_STP         : out   std_logic;
        HPS_SD_CLK          : out   std_logic;
        HPS_ENET_GTX_CLK    : out   std_logic
    );
end md5_soc_top;

architecture Behaviour of md5_soc_top is

    component soc_system is
        port (
            clk_clk                                 : in    std_logic                     := 'X';
            hps_0_h2f_reset_reset_n                 : out   std_logic;
            hps_io_hps_io_emac1_inst_TX_CLK         : out   std_logic;
            hps_io_hps_io_emac1_inst_TXD0           : out   std_logic;
            hps_io_hps_io_emac1_inst_TXD1           : out   std_logic;
            hps_io_hps_io_emac1_inst_TXD2           : out   std_logic;
            hps_io_hps_io_emac1_inst_TXD3           : out   std_logic;
            hps_io_hps_io_emac1_inst_RXD0           : in    std_logic                     := 'X';
            hps_io_hps_io_emac1_inst_MDIO           : inout std_logic                     := 'X';
            hps_io_hps_io_emac1_inst_MDC            : out   std_logic;
            hps_io_hps_io_emac1_inst_RX_CTL         : in    std_logic                     := 'X';
            hps_io_hps_io_emac1_inst_TX_CTL         : out   std_logic;
            hps_io_hps_io_emac1_inst_RX_CLK         : in    std_logic                     := 'X';
            hps_io_hps_io_emac1_inst_RXD1           : in    std_logic                     := 'X';
            hps_io_hps_io_emac1_inst_RXD2           : in    std_logic                     := 'X';
            hps_io_hps_io_emac1_inst_RXD3           : in    std_logic                     := 'X';
            hps_io_hps_io_sdio_inst_CMD             : inout std_logic                     := 'X';
            hps_io_hps_io_sdio_inst_D0              : inout std_logic                     := 'X';
            hps_io_hps_io_sdio_inst_D1              : inout std_logic                     := 'X';
            hps_io_hps_io_sdio_inst_CLK             : out   std_logic;
            hps_io_hps_io_sdio_inst_D2              : inout std_logic                     := 'X';
            hps_io_hps_io_sdio_inst_D3              : inout std_logic                     := 'X';
            hps_io_hps_io_usb1_inst_D0              : inout std_logic                     := 'X';
            hps_io_hps_io_usb1_inst_D1              : inout std_logic                     := 'X';
            hps_io_hps_io_usb1_inst_D2              : inout std_logic                     := 'X';
            hps_io_hps_io_usb1_inst_D3              : inout std_logic                     := 'X';
            hps_io_hps_io_usb1_inst_D4              : inout std_logic                     := 'X';
            hps_io_hps_io_usb1_inst_D5              : inout std_logic                     := 'X';
            hps_io_hps_io_usb1_inst_D6              : inout std_logic                     := 'X';
            hps_io_hps_io_usb1_inst_D7              : inout std_logic                     := 'X';
            hps_io_hps_io_usb1_inst_CLK             : in    std_logic                     := 'X';
            hps_io_hps_io_usb1_inst_STP             : out   std_logic;
            hps_io_hps_io_usb1_inst_DIR             : in    std_logic                     := 'X';
            hps_io_hps_io_usb1_inst_NXT             : in    std_logic                     := 'X';
            md5_control_slave_0_md5_control_m_start : out   std_logic_vector(31 downto 0);
            md5_control_slave_0_md5_control_m_reset : out   std_logic_vector(31 downto 0);
            md5_control_slave_0_md5_control_m_done  : in    std_logic_vector(31 downto 0) := (others => 'X');
            md5_data_slave_0_md5_data_m_writedata   : out   std_logic_vector(31 downto 0);
            md5_data_slave_0_md5_data_m_writeaddr   : out   std_logic_vector(8 downto 0);
            md5_data_slave_0_md5_data_m_wr          : out   std_logic;
            md5_data_slave_0_md5_data_m_readaddr    : out   std_logic_vector(6 downto 0);
            md5_data_slave_0_md5_data_m_readdata    : in    std_logic_vector(31 downto 0) := (others => 'X');
            memory_mem_a                            : out   std_logic_vector(14 downto 0);
            memory_mem_ba                           : out   std_logic_vector(2 downto 0);
            memory_mem_ck                           : out   std_logic;
            memory_mem_ck_n                         : out   std_logic;
            memory_mem_cke                          : out   std_logic;
            memory_mem_cs_n                         : out   std_logic;
            memory_mem_ras_n                        : out   std_logic;
            memory_mem_cas_n                        : out   std_logic;
            memory_mem_we_n                         : out   std_logic;
            memory_mem_reset_n                      : out   std_logic;
            memory_mem_dq                           : inout std_logic_vector(31 downto 0) := (others => 'X');
            memory_mem_dqs                          : inout std_logic_vector(3 downto 0)  := (others => 'X');
            memory_mem_dqs_n                        : inout std_logic_vector(3 downto 0)  := (others => 'X');
            memory_mem_odt                          : out   std_logic;
            memory_mem_dm                           : out   std_logic_vector(3 downto 0);
            memory_oct_rzqin                        : in    std_logic                     := 'X';
            reset_reset_n                           : in    std_logic                     := 'X'
        );
    end component;

    component md5_core_wrapper is
        port (
            clk           : in  std_logic;
            reset         : in  std_logic;
            md5_start     : in  std_logic_vector(31 downto 0);
            md5_reset     : in  std_logic_vector(31 downto 0);
            md5_done      : out std_logic_vector(31 downto 0);
            md5_writedata : in  std_logic_vector(31 downto 0);
            md5_writeaddr : in  std_logic_vector(8 downto 0);
            md5_wr        : in  std_logic;
            md5_readaddr  : in  std_logic_vector(6 downto 0);
            md5_readdata  : out std_logic_vector(31 downto 0)
        );
    end component;

    signal h2f_reset_n      : std_logic;

    signal md5_start_sig     : std_logic_vector(31 downto 0);
    signal md5_reset_sig     : std_logic_vector(31 downto 0);
    signal md5_done_sig      : std_logic_vector(31 downto 0);

    signal md5_writedata_sig : std_logic_vector(31 downto 0);
    signal md5_writeaddr_sig : std_logic_vector(8 downto 0);
    signal md5_wr_sig        : std_logic;
    signal md5_readaddr_sig  : std_logic_vector(6 downto 0);
    signal md5_readdata_sig  : std_logic_vector(31 downto 0);

begin

    u0 : soc_system
        port map (
            clk_clk                                 => CLOCK_50,
            hps_0_h2f_reset_reset_n                 => h2f_reset_n,

            hps_io_hps_io_emac1_inst_TX_CLK         => HPS_ENET_GTX_CLK,
            hps_io_hps_io_emac1_inst_TXD0           => HPS_ENET_TX_DATA(0),
            hps_io_hps_io_emac1_inst_TXD1           => HPS_ENET_TX_DATA(1),
            hps_io_hps_io_emac1_inst_TXD2           => HPS_ENET_TX_DATA(2),
            hps_io_hps_io_emac1_inst_TXD3           => HPS_ENET_TX_DATA(3),
            hps_io_hps_io_emac1_inst_RXD0           => HPS_ENET_RX_DATA(0),
            hps_io_hps_io_emac1_inst_MDIO           => HPS_ENET_MDIO,
            hps_io_hps_io_emac1_inst_MDC            => HPS_ENET_MDC,
            hps_io_hps_io_emac1_inst_RX_CTL         => HPS_ENET_RX_DV,
            hps_io_hps_io_emac1_inst_TX_CTL         => HPS_ENET_TX_EN,
            hps_io_hps_io_emac1_inst_RX_CLK         => HPS_ENET_RX_CLK,
            hps_io_hps_io_emac1_inst_RXD1           => HPS_ENET_RX_DATA(1),
            hps_io_hps_io_emac1_inst_RXD2           => HPS_ENET_RX_DATA(2),
            hps_io_hps_io_emac1_inst_RXD3           => HPS_ENET_RX_DATA(3),

            hps_io_hps_io_sdio_inst_CMD             => HPS_SD_CMD,
            hps_io_hps_io_sdio_inst_D0              => HPS_SD_DATA(0),
            hps_io_hps_io_sdio_inst_D1              => HPS_SD_DATA(1),
            hps_io_hps_io_sdio_inst_CLK             => HPS_SD_CLK,
            hps_io_hps_io_sdio_inst_D2              => HPS_SD_DATA(2),
            hps_io_hps_io_sdio_inst_D3              => HPS_SD_DATA(3),

            hps_io_hps_io_usb1_inst_D0              => HPS_USB_DATA(0),
            hps_io_hps_io_usb1_inst_D1              => HPS_USB_DATA(1),
            hps_io_hps_io_usb1_inst_D2              => HPS_USB_DATA(2),
            hps_io_hps_io_usb1_inst_D3              => HPS_USB_DATA(3),
            hps_io_hps_io_usb1_inst_D4              => HPS_USB_DATA(4),
            hps_io_hps_io_usb1_inst_D5              => HPS_USB_DATA(5),
            hps_io_hps_io_usb1_inst_D6              => HPS_USB_DATA(6),
            hps_io_hps_io_usb1_inst_D7              => HPS_USB_DATA(7),
            hps_io_hps_io_usb1_inst_CLK             => HPS_USB_CLKOUT,
            hps_io_hps_io_usb1_inst_STP             => HPS_USB_STP,
            hps_io_hps_io_usb1_inst_DIR             => HPS_USB_DIR,
            hps_io_hps_io_usb1_inst_NXT             => HPS_USB_NXT,

            memory_mem_a                            => HPS_DDR3_ADDR,
            memory_mem_ba                           => HPS_DDR3_BA,
            memory_mem_ck                           => HPS_DDR3_CK_P,
            memory_mem_ck_n                         => HPS_DDR3_CK_N,
            memory_mem_cke                          => HPS_DDR3_CKE,
            memory_mem_cs_n                         => HPS_DDR3_CS_N,
            memory_mem_ras_n                        => HPS_DDR3_RAS_N,
            memory_mem_cas_n                        => HPS_DDR3_CAS_N,
            memory_mem_we_n                         => HPS_DDR3_WE_N,
            memory_mem_reset_n                      => HPS_DDR3_RESET_N,
            memory_mem_dq                           => HPS_DDR3_DQ,
            memory_mem_dqs                          => HPS_DDR3_DQS_P,
            memory_mem_dqs_n                        => HPS_DDR3_DQS_N,
            memory_mem_odt                          => HPS_DDR3_ODT,
            memory_mem_dm                           => HPS_DDR3_DM,
            memory_oct_rzqin                        => HPS_DDR3_RZQ,

            reset_reset_n                           => '1',

            md5_control_slave_0_md5_control_m_start => md5_start_sig,
            md5_control_slave_0_md5_control_m_reset => md5_reset_sig,
            md5_control_slave_0_md5_control_m_done  => md5_done_sig,

            md5_data_slave_0_md5_data_m_writedata   => md5_writedata_sig,
            md5_data_slave_0_md5_data_m_writeaddr   => md5_writeaddr_sig,
            md5_data_slave_0_md5_data_m_wr          => md5_wr_sig,
            md5_data_slave_0_md5_data_m_readaddr    => md5_readaddr_sig,
            md5_data_slave_0_md5_data_m_readdata    => md5_readdata_sig
        );

    u_md5 : md5_core_wrapper
        port map (
            clk           => CLOCK_50,
            reset         => not h2f_reset_n,

            md5_start     => md5_start_sig,
            md5_reset     => md5_reset_sig,
            md5_done      => md5_done_sig,

            md5_writedata => md5_writedata_sig,
            md5_writeaddr => md5_writeaddr_sig,
            md5_wr        => md5_wr_sig,
            md5_readaddr  => md5_readaddr_sig,
            md5_readdata  => md5_readdata_sig
        );

end Behaviour;