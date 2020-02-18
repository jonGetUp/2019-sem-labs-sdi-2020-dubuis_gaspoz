library Common;
  use Common.CommonLib.all;

ARCHITECTURE studentVersion OF toneGenerator IS

  constant toneCounterBitNb: positive := requiredBitNb(toneDivide-1);
  signal toneCounter: unsigned(toneCounterBitNb-1 downto 0);
  constant toneMin : natural := (2**toneCounterBitNb - toneDivide) / 2;
  constant toneMax : natural := toneMin + toneDivide;

BEGIN

  divide: process(reset, clock)
  begin
    if reset = '1' then
      toneCounter <= to_unsigned(toneMin, toneCounter'length);
    elsif rising_edge(clock) then
      if toneCounter = toneMax then
        toneCounter <= to_unsigned(toneMin, toneCounter'length);
      else
        toneCounter <= toneCounter + 1;
      end if;
    end if;
  end process divide;

  tone <= toneCounter(toneCounter'high);

END ARCHITECTURE studentVersion;
