library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity skid_buffer is
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
    m_axis_tvalid : out std_logic;
    m_axis_tready : in  std_logic;
    m_axis_tdata  : out std_logic_vector(DATA_WIDTH-1 downto 0);
    m_axis_tlast  : out std_logic
  );
end entity skid_buffer;

architecture rtl of skid_buffer is
  signal skid_valid : std_logic := '0';
  
  signal r_ready : std_logic;
  signal r_data : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal r_valid : std_logic := '0';
  signal r_last : std_logic := '0';
begin
  u_out : entity work.axis_register
  generic map (DATA_WIDTH => DATA_WIDTH)
  port map (clk => clk, rst => rst,
            s_axis_tvalid => r_valid, s_axis_tready => r_ready,
            s_axis_tdata  => r_data,  s_axis_tlast  => r_last,
            m_axis_tvalid => m_axis_tvalid, m_axis_tready => m_axis_tready,
            m_axis_tdata  => m_axis_tdata,  m_axis_tlast  => m_axis_tlast);

  process (clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        s_axis_tready <= '1';
        m_axis_tvalid <= '0';
      else
        
      end if;
    end if;
  end process;
end architecture rtl;
