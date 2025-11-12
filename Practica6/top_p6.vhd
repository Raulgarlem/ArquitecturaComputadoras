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
  signal clk_counter : unsigned(25 downto 0) := (others => '0');
  signal clk_slow    : std_logic := '0';

  -- señales CPU
  signal data_in_cpu  : unsigned(7 downto 0);
  signal data_out_cpu : unsigned(7 downto 0);
  signal dir_cpu      : unsigned(15 downto 0);
  signal nRW_cpu      : std_logic;

  -- ROM/RAM
  signal data_from_rom : unsigned(7 downto 0);
  signal data_from_ram : unsigned(7 downto 0);
  signal ram_we        : std_logic;
  signal cs_ram        : std_logic;
  
  -- Puerto B de la RAM para LEDs
  signal ram_b_addr    : unsigned(7 downto 0);
  signal ram_b_dout    : unsigned(7 downto 0);

  -- depuración
  signal pc_low_s     : unsigned(7 downto 0);
  signal e_pres_s     : unsigned(7 downto 0);
  signal A_s, B_s     : unsigned(7 downto 0);
  signal Xl_s, Xh_s   : unsigned(7 downto 0);
  signal Yl_s         : unsigned(7 downto 0);
  signal flags_s      : std_logic_vector(7 downto 0);

-- ==== Señales reloj ====
signal s0, s1      : std_logic := '1';  -- sincronizador (KEY1 activo en bajo)
signal s_prev      : std_logic := '1';  -- muestra anterior (sync)
signal step_pulse  : std_logic := '0';  -- pulso de 1 clk para la CPU (CE)
signal led_cnt     : unsigned(19 downto 0) := (others => '0');  -- ~20 ms @50MHz
signal step_led    : std_logic := '0';  -- versión "visible" del pulso (solo debug)


begin

-- Divisor de reloj: 50MHz / 2^N
process(clk50)
begin
  if rising_edge(clk50) then
    clk_counter <= clk_counter + 1;
  end if;
end process;

-- Selecciona qué bit usar (más alto = más lento)
clk_slow <= clk_counter(23);  -- ~6 Hz (visible a ojo)
-- clk_counter(22) = ~12 Hz
-- clk_counter(21) = ~24 Hz
-- clk_counter(20) = ~48 Hz
-- clk_counter(15) = ~1.5 KHz (bueno para simulación)


  -- (opcional) pasar clk50 directo
  clk <= clk_slow;

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
      clk   => clk_slow,
      --clk   => clk50,
      reset => not reset_n,
      --nIRQ  => btn_irq,
      --nXIRQ => btn_xirq,
      nIRQ  => '1',
      nXIRQ  => '1',
      ce    => '1',
      --ce  => step_pulse,
      Data_in  => data_in_cpu,
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
      datao => data_from_rom
    );

-- ============ Instancia RAM dual-port ($0000–$00FF) ============
  cs_ram  <= '1' when dir_cpu(15 downto 8) = x"00" else '0';
  ram_we  <= '1' when (cs_ram='1' and nRW_cpu='0') else '0';  -- write en flanco

  u_ram: entity work.ram_dp8x256
    port map(
      clk    => clk50,
      -- Puerto A: CPU
      a_addr => dir_cpu(7 downto 0),
      a_din  => data_out_cpu,
      a_dout => data_from_ram,
      a_we   => ram_we,
      -- Puerto B: LEDs
      b_addr => ram_b_addr,
      b_dout => ram_b_dout
    );

 -- ============ MUX de lectura a la CPU ============
  -- Si la CPU lee (nRW='1') y la dirección es $00xx, servimos RAM; en otro caso ROM
  data_in_cpu <= data_from_ram when (cs_ram='1' and nRW_cpu='1') else data_from_rom;

  -- ============ Selección de direcciones para LEDs ($10/$11/$12) ============
  with sw select
    ram_b_addr <= x"10" when "00",
                  x"11" when "01",
                  x"12" when others;

  -- Muestra el byte leído por el puerto B (puedes OR con step_led si quieres)
  --leds <= std_logic_vector(pc_low_s); --Muestra direcciones PC
	      -- A (nibble alto)
	--with e_pres_s select
  --leds <= --std_logic_vector(A_s) when x"61",
			--std_logic_vector(A_s) when x"62",
		--	std_logic_vector(A_s) when x"02",
			--std_logic_vector(e_pres_s) when others;
  --leds(7) <= step_led;
  --leds(6 downto 0) <= std_logic_vector(ram_b_dout(6 downto 0));
  --leds <= std_logic_vector(e_pres_s);
  leds <= std_logic_vector(ram_b_dout);  -- muestra el contenido de esa celda
end Behavioral;