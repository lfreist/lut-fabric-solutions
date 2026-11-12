library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity press_counter is
  generic (
    DEBOUNCE_CYCLES : positive := 1000000;
    LED_WIDTH       : positive := 4
  );
  port (
    clk  : in  std_logic;
    rst  : in  std_logic;
    btn  : in  std_logic;
    leds : out std_logic_vector(LED_WIDTH-1 downto 0)
  );
end entity press_counter;

architecture rtl of press_counter is
  signal debounced : std_logic;
begin
  u_deb : entity work.debouncer
    generic map (STABLE_CYCLES => DEBOUNCE_CYCLES)
    port map (clk => clk, rst => rst, btn_in => btn, btn_out => debounced);

  u_cnt : entity work.counter
    generic map (WIDTH => LED_WIDTH)
    port map (clk => clk, rst => rst, en => '1', count => leds);
    
end architecture rtl;
