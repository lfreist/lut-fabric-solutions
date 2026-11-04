library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axis_fifo is
  generic (
    DATA_WIDTH : positive := 16;
    DEPTH      : positive := 16
  );
  port (
    clk           : in  std_logic;
    rst           : in  std_logic;
    s_axis_tvalid : in  std_logic;
    s_axis_tready : out std_logic;
    s_axis_tdata  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    s_axis_tlast  : in  std_logic;
    m_axis_tvalid : out std_logic;
    m_axis_tready : in  std_logic;
    m_axis_tdata  : out std_logic_vector(DATA_WIDTH-1 downto 0);
    m_axis_tlast  : out std_logic;
    count         : out natural range 0 to DEPTH
  );
end entity axis_fifo;

architecture rtl of axis_fifo is
  type mem_t is array (0 to DEPTH-1) of std_logic_vector(DATA_WIDTH downto 0);
  signal mem : mem_t;
  signal wr_ptr : natural range 0 to DEPTH-1 := 0;
  signal rd_ptr : natural range 0 to DEPTH-1 := 0;
  signal cnt : natural range 0 to DEPTH := 0;
  signal rd_cell : std_logic_vector(DATA_WIDTH downto 0);
begin
  count <= cnt;
  s_axis_tready <= '1' when count < DEPTH else '0';
  m_axis_tvalid <= '1' when count > 0 else '0';
  rd_cell <= std_logic_vector(mem(rd_ptr));
  m_axis_tdata <= rd_cell(DATA_WIDTH downto 1);
  m_axis_tlast <= rd_cell(0);

  process (clk)
    variable c : natural range 0 to DEPTH;
  begin
    if rising_edge(clk) then
      c := cnt;
      if rst = '1' then
        wr_ptr <= 0;
        rd_ptr <= 0;
        cnt <= 0;
      else
        if s_axis_tvalid = '1' and s_axis_tready = '1' then
          mem(wr_ptr) <= s_axis_tdata & s_axis_tlast;
          c := c + 1;
          if wr_ptr = DEPTH-1 then
            wr_ptr <= 0;
          else
            wr_ptr <= wr_ptr + 1;
          end if;
        end if;
        if m_axis_tvalid = '1' and m_axis_tready = '1' then
          c := c - 1;
          if rd_ptr = DEPTH-1 then
            rd_ptr <= 0;
          else
            rd_ptr <= rd_ptr + 1;
          end if;
        end if;
        cnt <= c;
      end if;
    end if;
  end process;
end architecture rtl;
