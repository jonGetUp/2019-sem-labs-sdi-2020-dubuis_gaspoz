library Common;
  use Common.CommonLib.all;

ARCHITECTURE studentVersion OF unitCounter IS

  signal unitCounter: unsigned(requiredBitNb(unitCountDivide)-1 downto 0);
  signal unitCountDone: std_ulogic;
  signal unitNbCounter: unsigned(unitnB'range);
  signal unitNbCountDone: std_ulogic;

BEGIN
                                                       -- count unit base period
  countUnitDuration: process(reset, clock)
  begin
    if reset = '1' then
      unitCounter <= (others => '0');
    elsif rising_edge(clock) then
      if unitCounter = 0 then
        if (startCounter = '1') or (unitNbCounter > 0) then
          unitCounter <= unitCounter + 1;
        end if;
      else
        if unitCountDone = '0' then
          unitCounter <= unitCounter + 1;
        else
          unitCounter <= (others => '0');
        end if;
      end if;
    end if;
  end process countUnitDuration;

  unitCountDone <= '1' when unitCounter = unitCountDivide
    else '0';
                                                     -- count unit period number
  countPeriods: process(reset, clock)
  begin
    if reset = '1' then
      unitNbCounter <= (others => '0');
    elsif rising_edge(clock) then
      if unitNbCounter = 0 then
        if startCounter = '1' then
          unitNbCounter <= unitNbCounter + 1;
        end if;
      else
        if unitNbCountDone = '0' then
          if unitCountDone = '1' then
            unitNbCounter <= unitNbCounter + 1;
          end if;
        else
          unitNbCounter <= (others => '0');
        end if;
      end if;
    end if;
  end process countPeriods;

  unitNbCountDone <= '1' when (unitNbCounter = unitNb) and (unitCountDone = '1')
    else '0';

  done <= unitNbCountDone;

END ARCHITECTURE studentVersion;
