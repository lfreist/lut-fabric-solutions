library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity frame_tracker is
  generic (
    PIX_W   : positive := 10;
    TDATA_W : positive := 16;
    COORD_W : positive := 12
  );
  port (
    clk           : in  std_logic;
    rst           : in  std_logic;
    width         : in  std_logic_vector(COORD_W-1 downto 0);
    height        : in  std_logic_vector(COORD_W-1 downto 0);
    s_axis_tvalid : in  std_logic;
    s_axis_tdata  : in  std_logic_vector(TDATA_W-1 downto 0);
    s_axis_tuser  : in  std_logic;
    s_axis_tlast  : in  std_logic;
    out_valid     : out std_logic;
    out_data      : out std_logic_vector(PIX_W-1 downto 0);
    out_x         : out std_logic_vector(COORD_W-1 downto 0);
    out_y         : out std_logic_vector(COORD_W-1 downto 0);
    out_sof       : out std_logic;
    out_eol       : out std_logic;
    frame_done    : out std_logic;
    err           : out std_logic;
    in_frame      : out std_logic
  );
end entity frame_tracker;

architecture rtl of frame_tracker is
  signal r_in_frame : std_logic := '0';
  signal r_err : std_logic := '0';
  signal r_frame_done : std_logic := '0';
  signal r_out_eol : std_logic := '0';
  signal r_out_sof : std_logic := '0';
  signal r_out_x : unsigned(COORD_W-1 downto 0);
  signal r_out_y : unsigned(COORD_W-1 downto 0);
  signal r_out_data : std_logic_vector(PIX_W-1 downto 0);
  signal r_out_valid : std_logic := '0';
  signal r_width : unsigned(COORD_W-1 downto 0);
  signal r_height : unsigned(COORD_W-1 downto 0);
begin
  
  process (clk)
    variable v_in_frame : boolean := false;
  begin
    if rising_edge(clk) then
      r_out_valid <= '0';
      r_err <= '0';
      r_frame_done <= '0';
      r_out_sof <= '0';
      r_out_eol <= '0';
      r_in_frame <= '0';
      r_out_data <= s_axis_tdata(PIX_W-1 downto 0);
      if r_in_frame = '0' then
        r_width <= unsigned(width);
        r_height <= unsigned(height);
      end if;
      v_in_frame := r_in_frame = '1';
      if rst = '1' then
      elsif s_axis_tvalid = '1' then
        if s_axis_tuser = '1' then
          if v_in_frame then
            r_err <= '1';
          end if;
          r_out_x <= (others => '0');
          r_out_y <= (others => '0');
          v_in_frame := true;
          r_out_sof <= '1';
          r_out_valid <= '1';
        end if;
        if v_in_frame and r_frame_done = '0' then
          r_out_valid <= '1';
          if r_out_eol then
            r_out_x <= (others => '0');
            r_out_y <= r_out_y + 1;
            if r_out_y = r_height-1 then
              r_out_y <= (others => '0');
              r_frame_done <= '1';
            end if;
          elsif (s_axis_tlast = '1' and r_out_x < r_width-2) or (s_axis_tlast = '0' and r_out_x = r_width-2) then
            r_err <= '1';
            v_in_frame := false;
            r_out_valid <= '0';
          else
            if s_axis_tlast = '1' and r_out_x = r_width-2 then
              if r_out_y = r_height-1 then
                r_frame_done <= '1';
                v_in_frame := false;
              end if;
              r_out_eol <= '1';
            end if;
            r_out_valid <= '1';
            r_out_x <= r_out_x + 1;
          end if;
        end if;
        r_in_frame <= '1' when v_in_frame else '0';
      else
        r_out_x <= r_out_x;
        r_out_y <= r_out_y;
        r_out_eol <= r_out_eol;
        r_in_frame <= r_in_frame;
      end if;
    end if;
  end process;

  in_frame <= r_in_frame;
  err <= r_err;
  frame_done <= r_frame_done;
  out_data <= r_out_data;
  out_eol <= r_out_eol;
  out_sof <= r_out_sof;
  out_x <= std_logic_vector(r_out_x);
  out_y <= std_logic_vector(r_out_y);
  out_valid <= r_out_valid;

end architecture rtl;
