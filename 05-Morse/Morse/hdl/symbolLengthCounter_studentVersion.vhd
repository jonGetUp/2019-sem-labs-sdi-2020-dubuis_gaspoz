library Common;
  use Common.CommonLib.all;

ARCHITECTURE studentVersion OF symbolLengthCounter IS
BEGIN

  symbolValid <= '0';
  symbolValue <= '0';
  symbolDuration <= (others => '0');

END ARCHITECTURE studentVersion;
