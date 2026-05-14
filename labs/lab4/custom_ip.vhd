-----------------------------
-- Interfacing Custom IP Cores to HPS/FPGA SOC Platform
-- Ibrahim Ali
-- Lab 4
-- COE838 Systems-on-Chip Design
-----------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity custom_ip is
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
end custom_ip;

architecture Behaviour of custom_ip is

    component soc_system is
        port (
            clk_clk                           : in    std_logic                     := 'X';
            hps_0_h2f_reset_reset_n           : out   std_logic;
            hps_io_hps_io_emac1_inst_TX_CLK   : out   std_logic;
            hps_io_hps_io_emac1_inst_TXD0     : out   std_logic;
            hps_io_hps_io_emac1_inst_TXD1     : out   std_logic;
            hps_io_hps_io_emac1_inst_TXD2     : out   std_logic;
            hps_io_hps_io_emac1_inst_TXD3     : out   std_logic;
            hps_io_hps_io_emac1_inst_RXD0     : in    std_logic                     := 'X';
            hps_io_hps_io_emac1_inst_MDIO     : inout std_logic                     := 'X';
            hps_io_hps_io_emac1_inst_MDC      : out   std_logic;
            hps_io_hps_io_emac1_inst_RX_CTL   : in    std_logic                     := 'X';
            hps_io_hps_io_emac1_inst_TX_CTL   : out   std_logic;
            hps_io_hps_io_emac1_inst_RX_CLK   : in    std_logic                     := 'X';
            hps_io_hps_io_emac1_inst_RXD1     : in    std_logic                     := 'X';
            hps_io_hps_io_emac1_inst_RXD2     : in    std_logic                     := 'X';
            hps_io_hps_io_emac1_inst_RXD3     : in    std_logic                     := 'X';
            hps_io_hps_io_sdio_inst_CMD       : inout std_logic                     := 'X';
            hps_io_hps_io_sdio_inst_D0        : inout std_logic                     := 'X';
            hps_io_hps_io_sdio_inst_D1        : inout std_logic                     := 'X';
            hps_io_hps_io_sdio_inst_CLK       : out   std_logic;
            hps_io_hps_io_sdio_inst_D2        : inout std_logic                     := 'X';
            hps_io_hps_io_sdio_inst_D3        : inout std_logic                     := 'X';
            hps_io_hps_io_usb1_inst_D0        : inout std_logic                     := 'X';
            hps_io_hps_io_usb1_inst_D1        : inout std_logic                     := 'X';
            hps_io_hps_io_usb1_inst_D2        : inout std_logic                     := 'X';
            hps_io_hps_io_usb1_inst_D3        : inout std_logic                     := 'X';
            hps_io_hps_io_usb1_inst_D4        : inout std_logic                     := 'X';
            hps_io_hps_io_usb1_inst_D5        : inout std_logic                     := 'X';
            hps_io_hps_io_usb1_inst_D6        : inout std_logic                     := 'X';
            hps_io_hps_io_usb1_inst_D7        : inout std_logic                     := 'X';
            hps_io_hps_io_usb1_inst_CLK       : in    std_logic                     := 'X';
            hps_io_hps_io_usb1_inst_STP       : out   std_logic;
            hps_io_hps_io_usb1_inst_DIR       : in    std_logic                     := 'X';
            hps_io_hps_io_usb1_inst_NXT       : in    std_logic                     := 'X';
            memory_mem_a                      : out   std_logic_vector(14 downto 0);
            memory_mem_ba                     : out   std_logic_vector(2 downto 0);
            memory_mem_ck                     : out   std_logic;
            memory_mem_ck_n                   : out   std_logic;
            memory_mem_cke                    : out   std_logic;
            memory_mem_cs_n                   : out   std_logic;
            memory_mem_ras_n                  : out   std_logic;
            memory_mem_cas_n                  : out   std_logic;
            memory_mem_we_n                   : out   std_logic;
            memory_mem_reset_n                : out   std_logic;
            memory_mem_dq                     : inout std_logic_vector(31 downto 0) := (others => 'X');
            memory_mem_dqs                    : inout std_logic_vector(3 downto 0)  := (others => 'X');
            memory_mem_dqs_n                  : inout std_logic_vector(3 downto 0)  := (others => 'X');
            memory_mem_odt                    : out   std_logic;
            memory_mem_dm                     : out   std_logic_vector(3 downto 0);
            memory_oct_rzqin                  : in    std_logic                     := 'X';
            reset_reset_n                     : in    std_logic                     := 'X';
            alu_control_0_alu_control_a_start : out   std_logic_vector(31 downto 0);
            alu_control_0_alu_control_a_reset : out   std_logic_vector(31 downto 0);
            alu_control_0_alu_control_a_done  : in    std_logic_vector(31 downto 0) := (others => 'X');
            alu_data_0_alu_data_a_in1         : out   std_logic_vector(31 downto 0);
            alu_data_0_alu_data_a_in2         : out   std_logic_vector(31 downto 0);
            alu_data_0_alu_data_a_cfg         : out   std_logic_vector(31 downto 0);
            alu_data_0_alu_data_a_result      : in    std_logic_vector(31 downto 0) := (others => 'X')
        );
    end component;
   
	component alu_unit is
        port(
            clk         : in  std_logic;
            reset       : in  std_logic;
            enable      : in  std_logic;
            alu_a       : in  std_logic_vector(15 downto 0);
            alu_b       : in  std_logic_vector(15 downto 0);
            alu_op      : in  std_logic;
            shift_en    : in  std_logic;
            shift_dir   : in  std_logic;
            shift_amt   : in  std_logic_vector(3 downto 0);
            alu_done    : out std_logic;
            alu_result  : out std_logic_vector(31 downto 0)
        );
    end component;
	
	--SIGNALS instantiated here
	signal h2f_reset_n   : std_logic;

   signal alu_start_sig  : std_logic_vector(31 downto 0);
   signal alu_reset_sig  : std_logic_vector(31 downto 0);
   signal alu_done_sig   : std_logic_vector(31 downto 0);

   signal alu_in1_sig    : std_logic_vector(31 downto 0);
   signal alu_in2_sig    : std_logic_vector(31 downto 0);
   signal alu_cfg_sig    : std_logic_vector(31 downto 0);

   signal alu_result_sig : std_logic_vector(31 downto 0);
	
	BEGIN

	--port map soc_system here

    u0 : soc_system
        port map (
            clk_clk                           => CLOCK_50,
            hps_0_h2f_reset_reset_n           => h2f_reset_n,

            hps_io_hps_io_emac1_inst_TX_CLK   => HPS_ENET_GTX_CLK,
            hps_io_hps_io_emac1_inst_TXD0     => HPS_ENET_TX_DATA(0),
            hps_io_hps_io_emac1_inst_TXD1     => HPS_ENET_TX_DATA(1),
            hps_io_hps_io_emac1_inst_TXD2     => HPS_ENET_TX_DATA(2),
            hps_io_hps_io_emac1_inst_TXD3     => HPS_ENET_TX_DATA(3),
            hps_io_hps_io_emac1_inst_RXD0     => HPS_ENET_RX_DATA(0),
            hps_io_hps_io_emac1_inst_MDIO     => HPS_ENET_MDIO,
            hps_io_hps_io_emac1_inst_MDC      => HPS_ENET_MDC,
            hps_io_hps_io_emac1_inst_RX_CTL   => HPS_ENET_RX_DV,
            hps_io_hps_io_emac1_inst_TX_CTL   => HPS_ENET_TX_EN,
            hps_io_hps_io_emac1_inst_RX_CLK   => HPS_ENET_RX_CLK,
            hps_io_hps_io_emac1_inst_RXD1     => HPS_ENET_RX_DATA(1),
            hps_io_hps_io_emac1_inst_RXD2     => HPS_ENET_RX_DATA(2),
            hps_io_hps_io_emac1_inst_RXD3     => HPS_ENET_RX_DATA(3),

            hps_io_hps_io_sdio_inst_CMD       => HPS_SD_CMD,
            hps_io_hps_io_sdio_inst_D0        => HPS_SD_DATA(0),
            hps_io_hps_io_sdio_inst_D1        => HPS_SD_DATA(1),
            hps_io_hps_io_sdio_inst_CLK       => HPS_SD_CLK,
            hps_io_hps_io_sdio_inst_D2        => HPS_SD_DATA(2),
            hps_io_hps_io_sdio_inst_D3        => HPS_SD_DATA(3),

            hps_io_hps_io_usb1_inst_D0        => HPS_USB_DATA(0),
            hps_io_hps_io_usb1_inst_D1        => HPS_USB_DATA(1),
            hps_io_hps_io_usb1_inst_D2        => HPS_USB_DATA(2),
            hps_io_hps_io_usb1_inst_D3        => HPS_USB_DATA(3),
            hps_io_hps_io_usb1_inst_D4        => HPS_USB_DATA(4),
            hps_io_hps_io_usb1_inst_D5        => HPS_USB_DATA(5),
            hps_io_hps_io_usb1_inst_D6        => HPS_USB_DATA(6),
            hps_io_hps_io_usb1_inst_D7        => HPS_USB_DATA(7),
            hps_io_hps_io_usb1_inst_CLK       => HPS_USB_CLKOUT,
            hps_io_hps_io_usb1_inst_STP       => HPS_USB_STP,
            hps_io_hps_io_usb1_inst_DIR       => HPS_USB_DIR,
            hps_io_hps_io_usb1_inst_NXT       => HPS_USB_NXT,

            memory_mem_a                      => HPS_DDR3_ADDR,
            memory_mem_ba                     => HPS_DDR3_BA,
            memory_mem_ck                     => HPS_DDR3_CK_P,
            memory_mem_ck_n                   => HPS_DDR3_CK_N,
            memory_mem_cke                    => HPS_DDR3_CKE,
            memory_mem_cs_n                   => HPS_DDR3_CS_N,
            memory_mem_ras_n                  => HPS_DDR3_RAS_N,
            memory_mem_cas_n                  => HPS_DDR3_CAS_N,
            memory_mem_we_n                   => HPS_DDR3_WE_N,
            memory_mem_reset_n                => HPS_DDR3_RESET_N,
            memory_mem_dq                     => HPS_DDR3_DQ,
            memory_mem_dqs                    => HPS_DDR3_DQS_P,
            memory_mem_dqs_n                  => HPS_DDR3_DQS_N,
            memory_mem_odt                    => HPS_DDR3_ODT,
            memory_mem_dm                     => HPS_DDR3_DM,
            memory_oct_rzqin                  => HPS_DDR3_RZQ,

            reset_reset_n                     => '1',

            alu_control_0_alu_control_a_start => alu_start_sig,
            alu_control_0_alu_control_a_reset => alu_reset_sig,
            alu_control_0_alu_control_a_done  => alu_done_sig,

            alu_data_0_alu_data_a_in1         => alu_in1_sig,
            alu_data_0_alu_data_a_in2         => alu_in2_sig,
            alu_data_0_alu_data_a_cfg         => alu_cfg_sig,
            alu_data_0_alu_data_a_result      => alu_result_sig
        );
		  
	 a0 : alu_unit
        port map (
            clk        => CLOCK_50,
            reset      => alu_reset_sig(0),
            enable     => alu_start_sig(0),
            alu_a      => alu_in1_sig(15 downto 0),
            alu_b      => alu_in2_sig(15 downto 0),
            alu_op     => alu_cfg_sig(0),
            shift_en   => alu_cfg_sig(1),
            shift_dir  => alu_cfg_sig(2),
            shift_amt  => alu_cfg_sig(6 downto 3),
            alu_done   => alu_done_sig(0),
            alu_result => alu_result_sig
        );
		  
    alu_done_sig(31 downto 1) <= (others => '0');

end Behaviour;