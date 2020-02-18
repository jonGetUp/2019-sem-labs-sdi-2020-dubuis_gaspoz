LIBRARY AhbLite;
  USE AhbLite.ahbLite.all;

ARCHITECTURE RTL OF ahbDecoder IS
BEGIN

  decodeAddress: process(hAddr)
    variable mask: unsigned(hAddr'range);
  begin
    hSel <= (others => '0');
    for index in hSel'range loop
      mask := to_unsigned(ahbMemoryLocation(index).addressMask, mask'length);
      if (hAddr and mask) = ahbMemoryLocation(index).baseAddress then
        hSel(index) <= '1';
      end if;
    end loop;
  end process decodeAddress;

END ARCHITECTURE RTL;
