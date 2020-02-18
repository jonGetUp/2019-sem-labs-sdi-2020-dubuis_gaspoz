LIBRARY ieee;
  USE ieee.numeric_std.all;

PACKAGE BODY mti_pkg IS

    -- Convert BIT to STD_LOGIC
    FUNCTION To_StdLogic (s : BIT) RETURN STD_LOGIC IS
    BEGIN
            CASE s IS
                WHEN '0' => RETURN ('0');
                WHEN '1' => RETURN ('1');
                WHEN OTHERS => RETURN ('0');
            END CASE;
    END;

    -- Convert STD_LOGIC to INTEGER
    FUNCTION  TO_INTEGER (input : STD_LOGIC) RETURN INTEGER IS
    VARIABLE result : INTEGER := 0;
    VARIABLE weight : INTEGER := 1;
    BEGIN
        IF input = '1' THEN
            result := weight;
        ELSE
            result := 0;                                            -- if unknowns, default to logic 0
        END IF;
        RETURN result;
    END TO_INTEGER;

    -- Convert BIT_VECTOR to INTEGER
    FUNCTION  TO_INTEGER (input : BIT_VECTOR) RETURN INTEGER IS
    VARIABLE result : INTEGER := 0;
    VARIABLE weight : INTEGER := 1;
    BEGIN
        FOR i IN input'LOW TO input'HIGH LOOP
            IF input(i) = '1' THEN
                result := result + weight;
            ELSE
                result := result + 0;                               -- if unknowns, default to logic 0
            END IF;
            weight := weight * 2;
        END LOOP;
        RETURN result;
    END TO_INTEGER;

    -- Convert STD_LOGIC_VECTOR to INTEGER
    FUNCTION  TO_INTEGER (input : STD_LOGIC_VECTOR) RETURN INTEGER IS
    VARIABLE result : INTEGER := 0;
    VARIABLE weight : INTEGER := 1;
    BEGIN
        FOR i IN input'LOW TO input'HIGH LOOP
            IF input(i) = '1' THEN
                result := result + weight;
            ELSE
                result := result + 0;                               -- if unknowns, default to logic 0
            END IF;
            weight := weight * 2;
        END LOOP;
        RETURN result;
    END TO_INTEGER;

    -- Convert STD_ULOGIC_VECTOR to INTEGER
    FUNCTION  TO_INTEGER (input : STD_ULOGIC_VECTOR) RETURN INTEGER IS
    VARIABLE result : INTEGER := 0;
    VARIABLE weight : INTEGER := 1;
    BEGIN
        FOR i IN input'LOW TO input'HIGH LOOP
            IF input(i) = '1' THEN
                result := result + weight;
            ELSE
                result := result + 0;                               -- if unknowns, default to logic 0
            END IF;
            weight := weight * 2;
        END LOOP;
        RETURN result;
    END TO_INTEGER;

    -- Conver INTEGER to BIT_VECTOR
    PROCEDURE  TO_BITVECTOR (VARIABLE input : IN INTEGER; VARIABLE output : OUT BIT_VECTOR) IS
    VARIABLE work,offset,outputlen,j : INTEGER := 0;
    BEGIN
        --length of vector
        IF output'LENGTH > 32 THEN		--'
            outputlen := 32;
            offset := output'LENGTH - 32;		--'
            IF input >= 0 THEN
                FOR i IN offset-1 DOWNTO 0 LOOP
                    output(output'HIGH - i) := '0';		--'
                END LOOP;
            ELSE
                FOR i IN offset-1 DOWNTO 0 LOOP
                    output(output'HIGH - i) := '1';		--'
                END LOOP;
            END IF;
        ELSE
            outputlen := output'LENGTH; 		--'
        END IF;
        --positive value
        IF (input >= 0) THEN
            work := input;
            j := outputlen - 1;
            FOR i IN 1 to 32 LOOP
                IF j >= 0 then
                    IF (work MOD 2) = 0 THEN
                        output(output'HIGH-j-offset) := '0'; 		--'
                    ELSE
                        output(output'HIGH-j-offset) := '1'; 		--'
                    END IF;
                END IF;
                work := work / 2;
                j := j - 1;
            END LOOP;
            IF outputlen = 32 THEN
                output(output'HIGH) := '0'; 		--'
            END IF;
        --negative value
        ELSE
            work := (-input) - 1;
            j := outputlen - 1;
            FOR i IN 1 TO 32 LOOP
                IF j>= 0 THEN
                    IF (work MOD 2) = 0 THEN
                        output(output'HIGH-j-offset) := '1'; 		--'
                    ELSE
                        output(output'HIGH-j-offset) := '0'; 		--'
                    END IF;
                END IF;
                work := work / 2;
                j := j - 1;
            END LOOP;
            IF outputlen = 32 THEN
                output(output'HIGH) := '1'; 		--'
            END IF;
        END IF;
    END TO_BITVECTOR;


  function conv_std_logic_vector(i : integer; w : integer) return std_logic_vector is
  variable tmp : std_logic_vector(w-1 downto 0);
  begin
    tmp := std_logic_vector(to_unsigned(i, w));
    return(tmp);
  end;

  procedure char2hex(C: character; result: out bit_vector(3 downto 0);
            good: out boolean; report_error: in boolean) is
  begin
    good := true;
    case C is
    when '0' => result :=  x"0";
    when '1' => result :=  x"1";
    when '2' => result :=  X"2";
    when '3' => result :=  X"3";
    when '4' => result :=  X"4";
    when '5' => result :=  X"5";
    when '6' => result :=  X"6";
    when '7' => result :=  X"7";
    when '8' => result :=  X"8";
    when '9' => result :=  X"9";
    when 'A' => result :=  X"A";
    when 'B' => result :=  X"B";
    when 'C' => result :=  X"C";
    when 'D' => result :=  X"D";
    when 'E' => result :=  X"E";
    when 'F' => result :=  X"F";

    when 'a' => result :=  X"A";
    when 'b' => result :=  X"B";
    when 'c' => result :=  X"C";
    when 'd' => result :=  X"D";
    when 'e' => result :=  X"E";
    when 'f' => result :=  X"F";
    when others =>
      if report_error then
        assert false report
	  "hexread error: read a '" & C & "', expected a hex character (0-F).";
      end if;
      good := false;
    end case;
  end;

  procedure hexread(L:inout line; value:out bit_vector)  is
                variable OK: boolean;
                variable C:  character;
                constant NE: integer := value'length/4;	--'
                variable BV: bit_vector(0 to value'length-1);	--'
                variable S:  string(1 to NE-1);
  begin
    if value'length mod 4 /= 0 then	--'
      assert false report
        "hexread Error: Trying to read vector " &
        "with an odd (non multiple of 4) length";
      return;
    end if;

    loop                                    -- skip white space
      read(L,C);
      exit when ((C /= ' ') and (C /= CR) and (C /= HT));
    end loop;

    char2hex(C, BV(0 to 3), OK, false);
    if not OK then
      return;
    end if;

    read(L, S, OK);
--    if not OK then
--      assert false report "hexread Error: Failed to read the STRING";
--      return;
--    end if;

    for I in 1 to NE-1 loop
      char2hex(S(I), BV(4*I to 4*I+3), OK, false);
      if not OK then
        return;
      end if;
    end loop;
    value := BV;
  end hexread;

  procedure hexread(L:inout line; value:out std_ulogic_vector) is
    variable tmp: bit_vector(value'length-1 downto 0);	--'
  begin
    hexread(L, tmp);
    value := TO_X01(tmp);
  end hexread;

  procedure hexread(L:inout line; value:out std_logic_vector) is
    variable tmp: std_ulogic_vector(value'length-1 downto 0);	--'
  begin
    hexread(L, tmp);
    value := std_logic_vector(tmp);
  end hexread;

END mti_pkg;
