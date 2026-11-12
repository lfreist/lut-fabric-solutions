library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debouncer is
  generic (
    STABLE_CYCLES : positive := 1000000
  );
  port (
    clk     : in  std_logic;
    rst     : in  std_logic;
    btn_in  : in  std_logic;
    btn_out : out std_logic
  );
end entity debouncer;

architecture rtl of debouncer is
  signal synced : std_logic;
  signal prev : std_logic;
  signal cnt : natural range 0 to STABLE_CYCLES := 0;
begin
  u_sync : entity work.sync_2ff
    generic map (STAGES => 2)
    port map (clk => clk, d => btn_in, q => synced);
  
  process (clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        cnt <= 0;
        btn_out <= '0';
      else
        prev <= synced;
        if prev = synced then
          cnt <= cnt + 1;
          if cnt = STABLE_CYCLES-1 then
            cnt <= 0;
            btn_out <= btn_in;
          end if;
        else
          cnt <= 0;
        end if;
      end if;
    end if;
  end process;

end architecture rtl;
