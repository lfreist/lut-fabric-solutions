library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axil_read_channel is
  generic (
    C_ADDR_WIDTH : positive := 8;
    C_DATA_WIDTH : positive := 32
  );
  port (
    aclk          : in  std_logic;
    aresetn       : in  std_logic;
    s_axi_araddr  : in  std_logic_vector(C_ADDR_WIDTH-1 downto 0);
    s_axi_arvalid : in  std_logic;
    s_axi_arready : out std_logic;
    s_axi_rdata   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);
    s_axi_rresp   : out std_logic_vector(1 downto 0);
    s_axi_rvalid  : out std_logic;
    s_axi_rready  : in  std_logic;
    rd_en         : out std_logic;
    rd_addr       : out std_logic_vector(C_ADDR_WIDTH-1 downto 0);
    rd_data       : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    rd_err        : in  std_logic
  );
end entity axil_read_channel;

architecture rtl of axil_read_channel is
  signal rst : std_logic := '0';
  signal arready : std_logic := '0';
  signal resp : std_logic_vector(1 downto 0) := (others => '0');
  signal r_in : std_logic_vector(C_DATA_WIDTH + 1 downto 0);
  signal r_out : std_logic_vector(C_DATA_WIDTH + 1 downto 0);
begin
  rst <= not aresetn;

  u_r : entity work.vr_register
    generic map (
      DATA_WIDTH => C_DATA_WIDTH + 2
    )
    port map(
      clk => aclk,
      rst => rst,
      s_valid => s_axi_arvalid,
      s_ready => arready,
      s_data => r_in,
      m_valid => s_axi_rvalid,
      m_ready => s_axi_rready,
      m_data => r_out
    );
  
  s_axi_arready <= arready;
  s_axi_rdata <= r_out(C_DATA_WIDTH-1 downto 0);
  s_axi_rresp <= r_out(C_DATA_WIDTH+1 downto C_DATA_WIDTH);
  r_in <= resp & rd_data;
  rd_addr <= s_axi_araddr;
  rd_en <= s_axi_arvalid and arready;
  resp <= "10" when rd_err = '1' else "00";

end architecture rtl;
