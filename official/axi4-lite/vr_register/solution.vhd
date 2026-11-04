library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vr_register is
  generic (
    DATA_WIDTH : positive := 32
  );
  port (
    clk     : in  std_logic;
    rst     : in  std_logic;
    s_valid : in  std_logic;  -- data from upstream are valid
    s_ready : out std_logic;  -- this register will read on next valid high
    s_data  : in  std_logic_vector(DATA_WIDTH-1 downto 0);  -- in data from upstream
    m_valid : out std_logic;  -- out data are valid
    m_ready : in  std_logic;  -- downstream will read m_data on next m_valid
    m_data  : out std_logic_vector(DATA_WIDTH-1 downto 0)  -- data buffered for downstream
  );
end entity vr_register;

architecture rtl of vr_register is
  signal ready : std_logic := '0';
  signal valid : std_logic := '0';
begin
  process (clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        valid <= '0';
      elsif s_valid = '1' and ready = '1' then
        m_data <= s_data;
        valid <= '1';
      elsif valid = '1' and m_ready = '1' then
        valid <= '0';
      end if;
    end if;
  end process;
  ready <= (not valid) or m_ready;
  m_valid <= valid;
  s_ready <= ready;
end architecture rtl;
