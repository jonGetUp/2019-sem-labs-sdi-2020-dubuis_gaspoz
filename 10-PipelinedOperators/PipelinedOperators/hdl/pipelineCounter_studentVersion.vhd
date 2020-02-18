ARCHITECTURE studentVersion OF pipelineCounter IS

  signal b : signed(countOut'range);
  signal sum : signed(countOut'range);

  COMPONENT pipelineAdder
  GENERIC (
    bitNb   : positive := 32;
    stageNb : positive := 4
  );
  PORT (
    reset : IN     std_ulogic;
    clock : IN     std_ulogic;
    cIn   : IN     std_ulogic;
    a     : IN     signed (bitNb-1 DOWNTO 0);
    b     : IN     signed (bitNb-1 DOWNTO 0);
    sum   : OUT    signed (bitNb-1 DOWNTO 0);
    cOut  : OUT    std_ulogic
  );
  END COMPONENT;

BEGIN

  b <= to_signed(1, b'length);

  adder: pipelineAdder
    GENERIC MAP (
      bitNb => countOut'length,
      stageNb => stageNb
      )
    PORT MAP (
       reset => reset,
       clock => clock,
       cIn   => '0',
       a     => sum,
       b     => b,
       sum   => sum,
       cOut  => open
    );

  countOut <= unsigned(sum);

END ARCHITECTURE studentVersion;
