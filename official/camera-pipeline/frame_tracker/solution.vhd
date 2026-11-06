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
  signal r_next_x : unsigned(COORD_W-1 downto 0) := (others => '0');
  signal r_next_y : unsigned(COORD_W-1 downto 0) := (others => '0');
  signal r_out_data : std_logic_vector(PIX_W-1 downto 0);
  signal r_out_valid : std_logic := '0';
  signal r_width : unsigned(COORD_W-1 downto 0);
  signal r_height : unsigned(COORD_W-1 downto 0);
begin
  
  process (clk)
    variable v_x : natural := 0;
    variable v_y : natural := 0;
  begin
    if rising_edge(clk) then
      r_in_frame <= '0';
      r_err <= '0';
      r_frame_done <= '0';
      r_out_eol <= '0';
      r_out_sof <= '0';
      r_out_valid <= '0';
      v_x := 0;
      v_y := 0;
      if not rst then
        if s_axis_tvalid then -- new pulse received
          r_out_data <= s_axis_tdata(PIX_W-1 downto 0);
          if r_in_frame = '1' and s_axis_tuser = '1' then
            r_out_valid <= '1';
            r_err <= '1';
          elsif r_in_frame = '1' or s_axis_tuser = '1' then
            r_out_valid <= '1';
            r_in_frame <= '1';
            if s_axis_tuser = '1' then -- new frame -> sending pixel (0, 0)
              v_x := 0;
              v_y := 0;
              r_out_sof <= '1';
            elsif r_in_frame = '1' then -- keep in frame
              v_x := to_integer(r_next_x);
              v_y := to_integer(r_next_y);
            end if;
            if v_x = to_integer(r_width)-1 and s_axis_tlast = '1' then
              r_out_eol <= '1';
              r_next_y <= r_next_y + 1;
              r_next_x <= (others => '0');
              if v_y = to_integer(r_height)-1 then
                r_frame_done <= '1';
                r_in_frame <= '0';
                r_next_y <= (others => '0');
              end if;
            elsif v_x = to_integer(r_width)-1 xor s_axis_tlast = '1' then
              r_err <= '1';
              r_in_frame <= '0';
              r_out_valid <= '0';
            else
              r_next_x <= to_unsigned(v_x+1, COORD_W);
              r_next_y <= to_unsigned(v_y, COORD_W);
            end if;
            out_x <= std_logic_vector(to_unsigned(v_x, COORD_W));
            out_y <= std_logic_vector(to_unsigned(v_y, COORD_W));
          end if;
        else -- keep state
          r_in_frame <= r_in_frame;
          if r_in_frame = '0' then
            r_width <= unsigned(width);
            r_height <= unsigned(height);
          end if;
        end if;
      end if;
    end if;
  end process;

  in_frame <= r_in_frame;
  err <= r_err;
  frame_done <= r_frame_done;
  out_data <= r_out_data;
  out_eol <= r_out_eol;
  out_sof <= r_out_sof;
  out_valid <= r_out_valid;

end architecture rtl;
