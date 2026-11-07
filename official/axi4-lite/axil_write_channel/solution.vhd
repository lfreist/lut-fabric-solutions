library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axil_write_channel is
  generic (
    C_ADDR_WIDTH : positive := 8;
    C_DATA_WIDTH : positive := 32
  );
  port (
    aclk          : in  std_logic;
    aresetn       : in  std_logic;
    s_axi_awaddr  : in  std_logic_vector(C_ADDR_WIDTH-1 downto 0);
    s_axi_awvalid : in  std_logic;
    s_axi_awready : out std_logic;
    s_axi_wdata   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    s_axi_wstrb   : in  std_logic_vector(C_DATA_WIDTH/8-1 downto 0);
    s_axi_wvalid  : in  std_logic;
    s_axi_wready  : out std_logic;
    s_axi_bresp   : out std_logic_vector(1 downto 0);
    s_axi_bvalid  : out std_logic;
    s_axi_bready  : in  std_logic;
    wr_en         : out std_logic;
    wr_addr       : out std_logic_vector(C_ADDR_WIDTH-1 downto 0);
    wr_data       : out std_logic_vector(C_DATA_WIDTH-1 downto 0);
    wr_strb       : out std_logic_vector(C_DATA_WIDTH/8-1 downto 0);
    wr_err        : in  std_logic
  );
end entity axil_write_channel;

architecture rtl of axil_write_channel is
  constant DATA_WSTRB_WIDTH : positive := C_DATA_WIDTH+C_DATA_WIDTH/8;
  signal awaddr_valid : std_logic := '0';
  signal fire : std_logic := '0';
  signal awaddr : std_logic_vector(C_ADDR_WIDTH-1 downto 0) := (others => '0');
  signal wdata_valid : std_logic := '0';
  signal s_wdata_wstrb : std_logic_vector(DATA_WSTRB_WIDTH-1 downto 0) := (others => '0');
  signal wdata_wstrb : std_logic_vector(DATA_WSTRB_WIDTH-1 downto 0) := (others => '0');
  signal resp : std_logic_vector(1 downto 0) := (others => '0');
  signal rst : std_logic := '0';
  signal b_free : std_logic := '0';
begin
  rst <= not aresetn;
  s_wdata_wstrb <= s_axi_wdata & s_axi_wstrb;

  u_aw : entity work.vr_register
    generic map (
      DATA_WIDTH => C_ADDR_WIDTH
    )
    port map (
      clk => aclk,
      rst => rst,
      s_valid => s_axi_awvalid,
      s_ready => s_axi_awready,
      s_data => s_axi_awaddr,
      m_valid => awaddr_valid,
      m_ready => fire,
      m_data => awaddr
    );

  u_w : entity work.vr_register
    generic map (
      DATA_WIDTH => DATA_WSTRB_WIDTH
    )
    port map (
      clk => aclk,
      rst => rst,
      s_valid => s_axi_wvalid,
      s_ready => s_axi_wready,
      s_data => s_wdata_wstrb,
      m_valid => wdata_valid,
      m_ready => fire,
      m_data => wdata_wstrb
    );
  
  u_b : entity work.vr_register
    generic map (
      DATA_WIDTH => 2
    )
    port map (
      clk => aclk,
      rst => rst,
      s_valid => fire,
      s_ready => b_free,
      s_data => resp,
      m_valid => s_axi_bvalid,
      m_ready => s_axi_bready,
      m_data => s_axi_bresp
    );

  fire <= awaddr_valid and wdata_valid and b_free;
  resp <= "10" when wr_err = '1' else "00";
  wr_en <= fire;
  wr_addr <= awaddr;
  wr_data <= wdata_wstrb(DATA_WSTRB_WIDTH-1 downto C_DATA_WIDTH/8);
  wr_strb <= wdata_wstrb(C_DATA_WIDTH/8-1 downto 0);
end architecture rtl;
