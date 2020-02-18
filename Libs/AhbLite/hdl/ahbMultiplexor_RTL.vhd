ARCHITECTURE RTL OF ahbMultiplexor IS
BEGIN

  multiplexData: process(hSel, hRDataV, hReadyV, hRespV)
  begin
    hRData <= (others => '0');
    hReady <= '1';
    hResp  <= '0';
    for index in hSel'range loop
      if hSel(index) = '1' then
        hRData <= std_ulogic_vector(hRDataV(index));
        hReady <= hReadyV(index);
        hResp  <= hRespV(index);
      end if;
    end loop;
  end process multiplexData;

END ARCHITECTURE RTL;
