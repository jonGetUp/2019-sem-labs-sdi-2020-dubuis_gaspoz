--==============================================================================
--
-- AHB UART
--
-- Implements a serial port.
--
--------------------------------------------------------------------------------
--
-- Write registers
--
-- 00, data register receives the word to be sent to the serial port.
-- 01, control register is used to control the peripheral.
-- 02, scaler register is used to set the baud rate.
--
--------------------------------------------------------------------------------
--
-- Read registers
-- 00, data register provides the last word received by the serial port.
-- 01, status register is used to get the peripheral's state.
--     bit 0: data ready for read
--     bit 1: sending in progress
--     bit 2: receiving in progress
--
ARCHITECTURE studentVersion OF ahbUart IS
BEGIN

  -- AHB-Lite
  hRData  <=	(OTHERS => '0');
  hReady  <=	'0';	
  hResp	  <=	'0';	

  -- Serial
  TxD <= '0';

END ARCHITECTURE studentVersion;

