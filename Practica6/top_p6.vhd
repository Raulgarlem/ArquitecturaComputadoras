library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_p6 is
  port(
    clk50   	: in  std_logic;
    reset_n 	: in  std_logic;
    sw      	: in  std_logic_vector(1 downto 0); -- para escoger 10h,11h,12h
    btn_irq		: in std_logic;
    btn_xirq	: in std_logic;
    btn_step	: in std_logic;
    leds		: out std_logic_vector(7 downto 0)
  );
end top_p6;

architecture Behavioral of top_p6 is

  -- reloj lento
  signal clk    : std_logic;

  -- señales CPU
  signal data_in_cpu  : unsigned(7 downto 0);
  signal data_out_cpu : unsigned(7 downto 0);
  signal dir_cpu      : unsigned(15 downto 0);
  signal nRW_cpu      : std_logic;

  -- memoria
  signal dato_mem     : unsigned(7 downto 0);

  -- depuración
  signal pc_low_s     : unsigned(7 downto 0);
  signal e_pres_s     : unsigned(7 downto 0);
  signal A_s, B_s     : unsigned(7 downto 0);
  signal Xl_s, Xh_s   : unsigned(7 downto 0);
  signal Yl_s         : unsigned(7 downto 0);
  signal flags_s      : std_logic_vector(7 downto 0);

-- ==== Señales (declarar arriba, ANTES de begin) ====
signal s0, s1      : std_logic := '1';  -- sincronizador (KEY1 activo en bajo)
signal s_prev      : std_logic := '1';  -- muestra anterior (sync)
signal step_pulse  : std_logic := '0';  -- pulso de 1 clk para la CPU (CE)
signal led_cnt     : unsigned(19 downto 0) := (others => '0');  -- ~20 ms @50MHz
signal step_led    : std_logic := '0';  -- versión "visible" del pulso (solo debug)

begin

  -- (opcional) pasar clk50 directo
  clk <= clk50;



-- ==== Sincroniza el botón al reloj de la CPU (usa el MISMO clk que tu CPU) ====
process(clk50) begin
  if rising_edge(clk50) then
    s0 <= btn_step;   -- pin KEY1 (activo en bajo)
    s1 <= s0;         -- ya sincronizado a clk50
  end if;
end process;

-- ==== Detector de flanco (1->0 porque es activo en bajo) + pulso 1 ciclo ====
process(clk50) begin
  if rising_edge(clk50) then
    s_prev <= s1;
    if (s_prev = '1' and s1 = '0') then
      step_pulse <= '1';      -- 1 ciclo (20 ns) para la CPU
    else
      step_pulse <= '0';
    end if;
  end if;
end process;

-- ==== Estirador para ver el pulso en un LED (~20 ms) ====
process(clk50) begin
  if rising_edge(clk50) then
    if step_pulse = '1' then
      led_cnt  <= to_unsigned(1_000_000, led_cnt'length); -- ~20 ms @50MHz
      step_led <= '1';
    elsif led_cnt /= 0 then
      led_cnt  <= led_cnt - 1;
      step_led <= '1';
    else
      step_led <= '0';
    end if;
  end if;
end process;



  -- instanciar CPU
  u_cpu: entity work.micro68HC11
    port map(
      clk   => clk50,
      reset => not reset_n,
      nIRQ  => btn_irq,
      nXIRQ => btn_xirq,
      ce    => step_pulse,
      Data_in  => dato_mem,
      Data_out => data_out_cpu,
      Dir      => dir_cpu,
      nRW      => nRW_cpu,
      PC_low_out      => pc_low_s,
      e_presente_out  => e_pres_s,
      A_out           => A_s,
      B_out           => B_s,
      X_low_out       => Xl_s,
      X_high_out      => Xh_s,
      Y_low_out       => Yl_s,
      flags           => flags_s
    );

  -- instanciar ROM
  u_rom: entity work.rom_p6
    port map(
      addr  => dir_cpu,
      datao => dato_mem
    );

  ------------------------------------------------------------------
  -- "espejo" de las direcciones $10, $11, $12 en los LEDs
  -- como la CPU va a escribir en RAM, pero aquí solo tengo ROM,
  -- hago un truco: si la dir es 10h/11h/12h, muestro algo.
  -- En tu diseño real, esto iría a una RAM dual o a un decoder.
  ------------------------------------------------------------------
  process(dir_cpu, A_s, B_s, Xl_s, Xh_s, sw)
    variable show : unsigned(7 downto 0);
  begin
    -- por defecto muestro el dato que viene de memoria
    show := dato_mem;

    -- selector por switches: 00 -> $10, 01 -> $11, 10 -> $12
    case sw is
      when "00" =>
        if dir_cpu = x"0010" then
          show := dato_mem;
        end if;
      when "01" =>
        if dir_cpu = x"0011" then
          show := dato_mem;
        end if;
      when others =>
        if dir_cpu = x"0012" then
          show := dato_mem;
        end if;
    end case;

	leds <= std_logic_vector(show);
    --leds <= std_logic_vector(pc_low_s);
	--leds <= std_logic_vector(e_presente);
    --leds(7) <= step_led;
	--leds(6 downto 0) <= std_logic_vector(pc_low_s(7 downto 1));
  end process;

end Behavioral;
