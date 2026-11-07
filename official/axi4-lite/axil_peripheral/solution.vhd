library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axil_peripheral is
  generic (
    C_DATA_WIDTH : positive := 32;
    C_ADDR_WIDTH : positive := 8
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
    irq           : out std_logic
  );
end entity axil_peripheral;

architecture rtl of axil_peripheral is
  constant W : positive := C_DATA_WIDTH;
  constant R_CTRL   : natural := 0;
  constant R_LOAD   : natural := 1;
  constant R_COUNT  : natural := 2;
  constant R_STATUS : natural := 3;

  signal reg_q     : std_logic_vector(4*W-1 downto 0);
  signal reg_rd    : std_logic_vector(4*W-1 downto 0);
  signal reg_wr    : std_logic_vector(3 downto 0);
  signal reg_wdata : std_logic_vector(W-1 downto 0);
  signal reg_wstrb : std_logic_vector(W/8-1 downto 0);

  signal ctrl    : std_logic_vector(W-1 downto 0);
  signal load    : std_logic_vector(W-1 downto 0);
  signal count   : unsigned(W-1 downto 0) := (others => '0');
  signal expired : std_logic := '0';
  signal overrun : std_logic := '0';
  signal status  : std_logic_vector(W-1 downto 0);
begin

  u_rf : entity work.axil_regfile
    generic map (C_DATA_WIDTH => W, C_ADDR_WIDTH => C_ADDR_WIDTH, C_NUM_REGS => 4)
    port map (
      aclk => aclk, aresetn => aresetn,
      s_axi_awaddr => s_axi_awaddr, s_axi_awvalid => s_axi_awvalid, s_axi_awready => s_axi_awready,
      s_axi_wdata => s_axi_wdata, s_axi_wstrb => s_axi_wstrb, s_axi_wvalid => s_axi_wvalid,
      s_axi_wready => s_axi_wready,
      s_axi_bresp => s_axi_bresp, s_axi_bvalid => s_axi_bvalid, s_axi_bready => s_axi_bready,
      s_axi_araddr => s_axi_araddr, s_axi_arvalid => s_axi_arvalid, s_axi_arready => s_axi_arready,
      s_axi_rdata => s_axi_rdata, s_axi_rresp => s_axi_rresp, s_axi_rvalid => s_axi_rvalid,
      s_axi_rready => s_axi_rready,
      reg_q => reg_q, reg_rd => reg_rd, reg_wr => reg_wr, reg_wdata => reg_wdata, reg_wstrb => reg_wstrb);

  ctrl <= reg_q((R_CTRL+1)*W-1 downto R_CTRL*W);
  load <= reg_q((R_LOAD+1)*W-1 downto R_LOAD*W);

  -- what reads return: CTRL masked (START and reserved bits read 0), LOAD as stored,
  -- COUNT and STATUS from the timer
  reg_rd(R_CTRL*W+2 downto R_CTRL*W)         <= ctrl(2 downto 0);
  reg_rd((R_CTRL+1)*W-1 downto R_CTRL*W+3)   <= (others => '0');
  reg_rd((R_LOAD+1)*W-1 downto R_LOAD*W)     <= load;
  reg_rd((R_COUNT+1)*W-1 downto R_COUNT*W)   <= std_logic_vector(count);
  status <= (1 => overrun, 0 => expired, others => '0');
  reg_rd((R_STATUS+1)*W-1 downto R_STATUS*W) <= status;

  timer : process (aclk)
    variable start, expire, clr_exp, clr_ovr : boolean;
  begin
    if rising_edge(aclk) then
      -- self-clearing START: a pulse derived from the write event, never stored
      start   := reg_wr(R_CTRL) = '1' and reg_wstrb(0) = '1' and reg_wdata(3) = '1';
      -- write-1-to-clear
      clr_exp := reg_wr(R_STATUS) = '1' and reg_wstrb(0) = '1' and reg_wdata(0) = '1';
      clr_ovr := reg_wr(R_STATUS) = '1' and reg_wstrb(0) = '1' and reg_wdata(1) = '1';
      expire  := false;

      if start then
        count <= unsigned(load);
      elsif ctrl(0) = '1' and count /= 0 then
        if count = 1 then
          expire := true;
          if ctrl(1) = '1' then
            count <= unsigned(load);
          else
            count <= (others => '0');
          end if;
        else
          count <= count - 1;
        end if;
      end if;

      -- flags: setting wins over clearing
      if expire then
        expired <= '1';
        if expired = '1' then
          overrun <= '1';
        elsif clr_ovr then
          overrun <= '0';
        end if;
      else
        if clr_exp then expired <= '0'; end if;
        if clr_ovr then overrun <= '0'; end if;
      end if;

      if aresetn = '0' then
        count   <= (others => '0');
        expired <= '0';
        overrun <= '0';
      end if;
    end if;
  end process timer;

  irq <= expired and ctrl(2);
end architecture rtl;
