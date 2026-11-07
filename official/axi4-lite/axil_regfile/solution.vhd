library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axil_regfile is
  generic (
    C_DATA_WIDTH : positive := 32;
    C_ADDR_WIDTH : positive := 8;
    C_NUM_REGS   : positive := 8
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
    s_axi_araddr  : in  std_logic_vector(C_ADDR_WIDTH-1 downto 0);
    s_axi_arvalid : in  std_logic;
    s_axi_arready : out std_logic;
    s_axi_rdata   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);
    s_axi_rresp   : out std_logic_vector(1 downto 0);
    s_axi_rvalid  : out std_logic;
    s_axi_rready  : in  std_logic;
    reg_q         : out std_logic_vector(C_NUM_REGS*C_DATA_WIDTH-1 downto 0);
    reg_rd        : in  std_logic_vector(C_NUM_REGS*C_DATA_WIDTH-1 downto 0);
    reg_wr        : out std_logic_vector(C_NUM_REGS-1 downto 0);
    reg_wdata     : out std_logic_vector(C_DATA_WIDTH-1 downto 0);
    reg_wstrb     : out std_logic_vector(C_DATA_WIDTH/8-1 downto 0)
  );
end entity axil_regfile;

architecture rtl of axil_regfile is
  function lsb_bits(dw : positive) return natural is
    variable bytes : natural := dw / 8;   -- bytes per register
    variable n     : natural := 0;
  begin
    while bytes > 1 loop
      bytes := bytes / 2;
      n     := n + 1;
    end loop;
    return n;
  end function;

  constant BPR : positive := C_DATA_WIDTH/8;
  constant ADDR_LSB : natural := lsb_bits(C_DATA_WIDTH);

  signal rst : std_logic := '0';
  -- write
  signal wr_data : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0');
  signal wstrb : std_logic_vector(C_DATA_WIDTH/8-1 downto 0) := (others => '0');
  signal wr_en : std_logic := '0';
  signal wr_err : std_logic := '0';
  signal wr_addr : std_logic_vector(C_ADDR_WIDTH-1 downto 0):= (others => '0');
  -- read
  signal rd_en : std_logic := '0';
  signal rd_addr : std_logic_vector(C_ADDR_WIDTH-1 downto 0):= (others => '0');
  signal rd_data : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0');
  signal rd_err : std_logic := '0';
  -- 
  signal wr_sel : std_logic_vector(C_NUM_REGS-1 downto 0) := (others => '0');
begin
  rst <= not aresetn;

  u_write_channel : entity work.axil_write_channel
    generic map (
      C_ADDR_WIDTH => C_ADDR_WIDTH,
      C_DATA_WIDTH => C_DATA_WIDTH
    )
    port map (
      aclk => aclk,
      aresetn => aresetn,
      s_axi_awaddr => s_axi_awaddr,
      s_axi_awvalid => s_axi_awvalid,
      s_axi_awready => s_axi_awready,
      s_axi_wdata => s_axi_wdata,
      s_axi_wstrb => s_axi_wstrb,
      s_axi_wvalid => s_axi_wvalid,
      s_axi_wready => s_axi_wready,
      s_axi_bresp => s_axi_bresp,
      s_axi_bvalid => s_axi_bvalid,
      s_axi_bready => s_axi_bready,
      wr_en => wr_en,
      wr_addr => wr_addr,
      wr_data => wr_data,
      wr_strb => wstrb,
      wr_err => wr_err
    );

  u_axil_read_channel : entity work.axil_read_channel
    generic map (
      C_ADDR_WIDTH => C_ADDR_WIDTH,
      C_DATA_WIDTH => C_DATA_WIDTH
    )
    port map (
      aclk          => aclk,
      aresetn       => aresetn,
      s_axi_araddr  => s_axi_araddr,
      s_axi_arvalid => s_axi_arvalid,
      s_axi_arready => s_axi_arready,
      s_axi_rdata   => s_axi_rdata,
      s_axi_rresp   => s_axi_rresp,
      s_axi_rvalid  => s_axi_rvalid,
      s_axi_rready  => s_axi_rready,
      rd_en         => rd_en,
      rd_addr       => rd_addr,
      rd_data       => rd_data,
      rd_err        => rd_err
    );

  strg_gen : for g in 0 to C_NUM_REGS-1 generate
    u_strb_register : entity work.strb_register
      generic map (
        DATA_WIDTH => C_DATA_WIDTH
      )
      port map (
        clk  => aclk,
        rst  => rst,
        we   => wr_sel(g),
        strb => wstrb,
        d    => wr_data,
        q    => reg_q((g+1)*C_DATA_WIDTH-1 downto g*C_DATA_WIDTH)
      );
  end generate;

  reg_wr <= wr_sel;
  reg_wdata <= wr_data;
  reg_wstrb <= wstrb;

  -- read process
  process (rd_addr, reg_rd)
  begin
    rd_data <= (others => '0');
    rd_err  <= '1';
    for i in 0 to C_NUM_REGS - 1 loop
      if unsigned(rd_addr(C_ADDR_WIDTH-1 downto ADDR_LSB)) = i then
        rd_data <= reg_rd((i+1)*C_DATA_WIDTH-1 downto i*C_DATA_WIDTH);
        rd_err <= '0';
      end if;
    end loop;
  end process;

  -- write process
  process(wr_addr, wr_en)
  begin
    wr_sel <= (others => '0');
    wr_err  <= '1';
    for i in 0 to C_NUM_REGS - 1 loop
      if unsigned(wr_addr(C_ADDR_WIDTH-1 downto ADDR_LSB)) = i then
        wr_sel(i) <= wr_en;
        wr_err <= '0';
      end if;
    end loop;
  end process;
end architecture rtl;
