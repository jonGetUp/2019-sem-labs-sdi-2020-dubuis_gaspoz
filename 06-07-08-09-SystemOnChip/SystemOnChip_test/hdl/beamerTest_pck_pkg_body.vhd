PACKAGE BODY beamerTest_pck IS

  function trim_X (arg : signed) return signed is
    variable returnVal : signed(arg'range);
  begin
    for i in arg'range loop
      case arg(i) is
        when '0' | 'L' => returnVal(i) := '0';
        when '1' | 'H' => returnVal(i) := '1';
        when others    => returnVal(i) := '0';
      end case;
    end loop;
    return returnVal;
  end trim_X;

END beamerTest_pck;
