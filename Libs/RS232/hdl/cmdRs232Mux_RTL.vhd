ARCHITECTURE RTL OF rs232Mux IS

  signal passThrough: std_ulogic;

BEGIN

  passThrough <= not selOther;

  multiplexer: process(passThrough, txData, txFullF, TxWr, otherData, otherWr)
  begin
    if passThrough = '1' then
      txDataF <= txData;
      txWrF <= TxWr;
      txFull <= txFullF;
      otherFull <= '1';
    else
      txDataF <= otherData;
      txWrF <= otherWr;
      otherFull <= txFullF;
      txFull <= '1';
    end if;
  end process multiplexer;

END ARCHITECTURE RTL;
