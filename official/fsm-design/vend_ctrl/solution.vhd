library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vend_ctrl is
  generic (
    WIDTH : positive := 8;
    PRICE : positive := 150
  );
  port (
    clk          : in  std_logic;
    rst          : in  std_logic;
    coin_10      : in  std_logic;
    coin_20      : in  std_logic;
    coin_50      : in  std_logic;
    cancel       : in  std_logic;
    free_vend    : in  std_logic;
    vend_done    : in  std_logic;
    credit       : out std_logic_vector(WIDTH-1 downto 0);
    vend         : out std_logic;
    change       : out std_logic_vector(WIDTH-1 downto 0);
    change_valid : out std_logic
  );
end entity vend_ctrl;

architecture rtl of vend_ctrl is
  type state_t is (S_COLLECT, S_WAIT);
  signal state : state_t := S_COLLECT;
  signal r_credit : unsigned(WIDTH-1 downto 0) := (others => '0');
  signal r_change : unsigned(WIDTH-1 downto 0) := (others => '0');
begin

  process (clk)
    variable full_credit : natural := 0;
    variable inserted : natural := 0;
  begin
    if rising_edge(clk) then
      vend <= '0';
      change_valid <= '0';
      r_change <= (others => '0');
      inserted := 0;
      if coin_10 = '1' then inserted := inserted + 10; end if;
      if coin_20 = '1' then inserted := inserted + 20; end if;
      if coin_50 = '1' then inserted := inserted + 50; end if;
      full_credit := to_integer(r_credit) + inserted;
      if rst = '1' then
        r_credit <= (others => '0');
        state <= S_COLLECT;
      else
        case state is
            when S_COLLECT =>
              if cancel = '1' then
                if full_credit > 0 then
                  change_valid <= '1';
                  r_change <= to_unsigned(full_credit, change'length);
                end if;
                r_credit <= (others => '0');
              elsif full_credit >= PRICE then
                r_change <= to_unsigned(full_credit - PRICE, change'length);
                change_valid <= '1' when full_credit > PRICE else '0';
                vend <= '1';
                r_credit <= (others => '0');
              elsif free_vend = '1' then
                vend <= '1';
                r_credit <= to_unsigned(full_credit, r_credit'length);
                state <= S_WAIT;
              else
                r_credit <= to_unsigned(full_credit, r_credit'length);
              end if;

            when S_WAIT =>
              if inserted > 0 then
                r_change <= to_unsigned(inserted, change'length);
                change_valid <= '1' when full_credit > 0 else '0';
              end if;
              state <= S_COLLECT when vend_done = '1' else S_WAIT;

          end case;
      end if;
    end if;
  end process;

  credit <= std_logic_vector(r_credit);
  change <= std_logic_vector(r_change);

end architecture rtl;
