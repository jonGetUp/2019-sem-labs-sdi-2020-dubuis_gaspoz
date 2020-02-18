ARCHITECTURE RTL OF ahbMuxConnector IS
BEGIN

  hSel <= hSelV(index);

  hRDataV(index) <= std_logic_vector(hRData);
  hReadyV(index) <= hReady;
  hRespV(index)  <= hResp;

  hRDataV <= (others => (others => 'Z'));
  hReadyV <= (others => 'Z');
  hRespV  <= (others => 'Z');

END ARCHITECTURE RTL;
