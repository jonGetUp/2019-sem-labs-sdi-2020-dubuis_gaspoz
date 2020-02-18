LIBRARY ieee;
  USE ieee.std_logic_1164.ALL;
  USE std.textio.all;

PACKAGE mti_pkg IS

  FUNCTION  To_StdLogic (s : BIT) RETURN STD_LOGIC;
  FUNCTION  TO_INTEGER (input : STD_LOGIC) RETURN INTEGER;
  FUNCTION  TO_INTEGER (input : BIT_VECTOR) RETURN INTEGER;
  FUNCTION  TO_INTEGER (input : STD_LOGIC_VECTOR) RETURN INTEGER;
  FUNCTION  TO_INTEGER (input : STD_ULOGIC_VECTOR) RETURN INTEGER;
  PROCEDURE TO_BITVECTOR  (VARIABLE input : IN INTEGER; VARIABLE output : OUT BIT_VECTOR);

  function conv_std_logic_vector(i : integer; w : integer) return std_logic_vector;
  procedure hexread(L : inout line; value:out bit_vector);
  procedure hexread(L : inout line; value:out std_logic_vector);

END mti_pkg;
