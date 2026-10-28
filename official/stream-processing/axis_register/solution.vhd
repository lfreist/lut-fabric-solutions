library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axis_register is
  generic (
    DATA_WIDTH : positive := 16
  );
  port (
    clk           : in  std_logic;
    rst           : in  std_logic;
    s_axis_tvalid : in  std_logic;
    s_axis_tready : out std_logic;
    s_axis_tdata  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    s_axis_tlast  : in  std_logic;
    -- s_axis_tuser  : in  std_logic;
    m_axis_tvalid : out std_logic;
    m_axis_tready : in  std_logic;
    m_axis_tdata  : out std_logic_vector(DATA_WIDTH-1 downto 0);
    m_axis_tlast  : out std_logic
    -- m_axis_tuser  : out std_logic
  );
end entity axis_register;

architecture rtl of axis_register is
  signal tvalid : std_logic := '0';
begin
  m_axis_tvalid <= tvalid;
  s_axis_tready <= m_axis_tready or not tvalid;

  process (clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        tvalid <= '0';
      else
        if s_axis_tready = '1' then
          m_axis_tdata <= s_axis_tdata;
          tvalid <= s_axis_tvalid;
          m_axis_tlast <= s_axis_tlast;
          -- m_axis_tuser <= s_axis_tuser;
        end if;
      end if;
    end if;
  end process;
end architecture rtl;
