ARCHITECTURE studentVersion OF sineTable IS

  signal phaseTableAddress : unsigned(tableAddressBitNb-1 downto 0);
  signal quarterSine : signed(sine'range);

BEGIN

  phaseTableAddress <= phase(phase'high-2 downto phase'high-2-tableAddressBitNb+1);

  quarterTable: process(phaseTableAddress)
  begin
    case to_integer(phaseTableAddress) is
      when 0 => quarterSine <= to_signed(16#0000#, quarterSine'length);
      when 1 => quarterSine <= to_signed(16#18F9#, quarterSine'length);
      when 2 => quarterSine <= to_signed(16#30FB#, quarterSine'length);
      when 3 => quarterSine <= to_signed(16#471C#, quarterSine'length);
      when 4 => quarterSine <= to_signed(16#5A82#, quarterSine'length);
      when 5 => quarterSine <= to_signed(16#6A6D#, quarterSine'length);
      when 6 => quarterSine <= to_signed(16#7641#, quarterSine'length);
      when 7 => quarterSine <= to_signed(16#7D89#, quarterSine'length);
      when others => quarterSine <= (others => '-');
    end case;
  end process quarterTable;

  sine <= (others => '0');

END ARCHITECTURE studentVersion;
