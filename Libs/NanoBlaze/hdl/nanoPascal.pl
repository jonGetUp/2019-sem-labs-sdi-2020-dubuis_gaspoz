#!/usr/bin/perl

my $indent = ' ' x 2;
my $separator = '-' x 80;

################################################################################
# Input arguments
#
use Getopt::Std;
my %opts;
getopts('hva:d:r:kc', \%opts);

die("\n".
    "Usage: $0 [options] fileSpec\n".
    "\n".
    "Options:\n".
    "${indent}-h        display this help message\n".
    "${indent}-v        verbose\n".
    "${indent}-a bitNb  the number of program address bits\n".
    "${indent}-d bitNb  the number of data bits\n".
    "${indent}-r bitNb  the number of register address bits\n".
    "${indent}-k        keep intermediate files\n".
    "${indent}-c        clean temporary work files\n".
    "\n".
    "Compiles a Pascal program to assembler code for the nanoBlaze processor.\n".
    "\n".
    "More information with: perldoc $0\n".
    "\n".
    ""
   ) if ($opts{h});

my $verbose              = $opts{v};
my $keepIntermediateFiles= $opts{k};
my $cleanTempFiles       = $opts{c};
my $addressBitNb         = $opts{a} || 10;
my $registerBitNb        = $opts{d} || 8;
my $registerAddressBitNb = $opts{r} || 4;

my $pascalFileSpec = $ARGV[0] || 'nanoTest.pas';
my $asmFileSpec = $ARGV[1] || 'nanoTest.asm';

#-------------------------------------------------------------------------------
# System constants
#
my $mainProgram = 'mainProgram';
my $wordHexCharNb = 4;
my $firstRegister = 2;  # reserve 2 registers for internal calculations
my $functionReturnRegister = 's0';
my $conditionRegister = 's1';
my $memoryAccessRegister = 's1';
my $partialOperationRegister = 's1';

#-------------------------------------------------------------------------------
# Derived values
#
                                                                    # file specs
my $baseFileSpec = $pascalFileSpec;
$baseFileSpec =~ s/\..*//i;
my $temp1FileSpec = "$baseFileSpec.tmp1";
my $temp2FileSpec = "$baseFileSpec.tmp2"; 
my $registersFileSpec = "${baseFileSpec}_registers.txt";  # register assignments
my $asm1FileSpec = "$baseFileSpec.asm1";

#-------------------------------------------------------------------------------
# Assembler file formatting constants
#
my $asmFirstIndent = ' ' x 24;
my $asmLineLength = 80;
my $commentStart = $asmFirstIndent . ';';
my $separator1 = fillString($commentStart, '=', $asmLineLength);
my $separator2 = fillString($commentStart, '-', $asmLineLength);
my $opcodeLength = 10;
my $firstArgumentLength = 6;
my $constantMaxLength = 8;

#-------------------------------------------------------------------------------
# System variables
#
my $currentPass = 0;
my %constants = ();
my %variables = ();
my %registers = ();
my @routines = ();

################################################################################
# Functions
#

#-------------------------------------------------------------------------------
# Swap temporary filespecs from one pass to the other
#
sub swapTempFileSpecs {
  my ($inputFileSpec, $outputFileSpec, $temp1FileSpec, $temp2FileSpec) = @_;
                                                          # swap to tmp1 -> tmp2
  if ($outputFileSpec eq $temp1FileSpec) {
    $inputFileSpec  = $temp1FileSpec;
    $outputFileSpec = $temp2FileSpec;
  }
                                                          # swap to tmp2 -> tmp2
  else {
    $inputFileSpec  = $temp2FileSpec;
    $outputFileSpec = $temp1FileSpec;
  }

  return ($inputFileSpec, $outputFileSpec);
}

#-------------------------------------------------------------------------------
# Fill string to a fixed length with a given character
#
sub fillString {
  my ($string, $character, $length) = @_;
                                                                   # fill string
  $string .= $character x ($length - length($string));

  return ($string);
}

#-------------------------------------------------------------------------------
# Assign registers to all variables
#
sub buildConstants {
  my ($mainProgram, %constants) = @_;
                                                              # loop on routines
  foreach my $subroutine (keys(%constants)) {
#print "$subroutine:\n";
                                                                   # build array
    $constants{$subroutine} =~ s/\s*\;\Z//;
    $constants{$subroutine} =~ s/\s*=\s*/=/g;
    my @procedureConstants = split(/\;/, $constants{$subroutine});
                                                                    # build hash
    my %procedureConstants;
    for my $index (0 .. $#procedureConstants) {
      my ($name, $value) = split(/\=/, $procedureConstants[$index]);
#print "$name: $value\n";
      $value =~ s/\$([0-9A-Fa-f]+)/0x$1/g;
      foreach my $alreadyDeclared (keys(%procedureConstants)) {
        $value =~ s/$alreadyDeclared/($procedureConstants{$alreadyDeclared})/g;
      }
      $value = eval($value);
      $procedureConstants{$name} = $value;
#print "  $name = $procedureConstants{$name}\n";
    }
    $constants{$subroutine} = \%procedureConstants;
  }
                                                        # convert to hexadecimal
  foreach my $subroutine (keys(%constants)) {
    my $replacement_ref = $constants{$subroutine};
    foreach my $name (keys(%$replacement_ref)) {
      my $value = $$replacement_ref{$name};
      $value = '$' . sprintf('%X', $value);
      $$replacement_ref{$name} = $value;
    }
  }
  foreach my $subroutine (keys(%constants)) {
      $line =~ s/$name/$$replacement_ref{$name}/g;
  }

  return (%constants);
}

#-------------------------------------------------------------------------------
# Assign registers to variables within a routine
#
sub assignRegistersToRoutine {
  my ($startIndex, $variables) = @_;
                                                                   # build array
  $variables =~ s/\;\Z//;
  my @variables = split(/\;/, $variables);
                                                             # loop on variables
  my $registerIndex = $startIndex;
  for my $index (0 .. $#variables) {
    $variables[$index] =~ s/word/s$registerIndex/;
    $variables[$index] =~ s/uint8/s$registerIndex/;
    $registerIndex = $registerIndex + 1;
#print "  $variables[$index]\n";
  }
                                              # assign registers to main program

  return ($registerIndex-1, join(';', @variables));
}

#-------------------------------------------------------------------------------
# Assign registers to all variables
#
sub assignRegisters {
  my ($mainProgram, $firstRegister, %variables) = @_;
                                                              # loop on routines
  my $registerMaxNb = 0;
  foreach my $subroutine (keys(%variables)) {
                                                                 # remove spaces
      $variables{$subroutine} =~ s/\s*\:\s*/:/g;
      $variables{$subroutine} =~ s/\s*\,\s*/,/g;
                                                   # distribute type definitions
      my $type;
      do {
        $variables{$subroutine} =~ s/\,(.*?)\:(.*?)\;/:$2;$1:$2;/;
        $type = $2;
      } while ($type ne '');
                                # assign registers to routine internal variables
    if ($subroutine ne $mainProgram) {
#print "$subroutine:\n";
      my ($registerNb, $routineVariables) = assignRegistersToRoutine(
        $firstRegister,
        $variables{$subroutine}
      );
      if ($registerNb > $registerMaxNb) {
        $registerMaxNb = $registerNb;
      }
      $variables{$subroutine} = $routineVariables;
#print "    $variables{$subroutine}\n";
    }
  }
                                              # assign registers to main program
#print "$mainProgram:\n";
  my ($registerNb, $routineVariables) = assignRegistersToRoutine(
    $registerMaxNb + 1,
    $variables{$mainProgram}
  );
  $variables{$mainProgram} = $routineVariables;
#print "    $variables{$mainProgram}\n";
                                                          # build hash of hashes
  foreach my $subroutine (keys(%variables)) {
    my @registers = split(/\;/, $variables{$subroutine});
    my %assignedRegisters;
    foreach my $variable (@registers) {
      my ($var, $register) = split(/\:/, $variable);
      $assignedRegisters{$var} = $register;
    }
    $variables{$subroutine} = \%assignedRegisters;
  }
  return (%variables);
}

#-------------------------------------------------------------------------------
# Translate Pascal second operand to assembler source operand if possible
#
sub translateArgument {
  my ($pascalOperand, $wordHexCharNb) = @_;
  my $assemblerOperand = '';
                                                                      # register
  if ($pascalOperand =~ m/\As(\d+)\Z/) {
    $assemblerOperand = "s$1";
  }
                                                      # decimal numeric constant
  elsif ($pascalOperand =~ m/\A(\d+)\Z/) {
    $assemblerOperand = sprintf("%0${wordHexCharNb}X", $pascalOperand);
  }
                                                  # hexadecimal numeric constant
  elsif ($pascalOperand =~ m/\A\$([0-9A-Fa-f]+)\Z/) {
    $assemblerOperand = sprintf("%0${wordHexCharNb}X", hex($1));
  }
                                                             # declared constant
  else {
    foreach my $routine (keys(%constants)) {
      my $constants_ref = $constants{$routine};
      foreach my $constant (sort(keys(%$constants_ref))) {
        if ($pascalOperand eq $constant) {
          $assemblerOperand = $pascalOperand;
        }
      }
    }
  }

  return ($assemblerOperand);
}

#-------------------------------------------------------------------------------
# Format assignment in ters of space characters
#
sub formatAssignment {
  my ($assignment) = @_;
                                                               # unary operators
  $assignment =~ s/\A\s*\-\s*/0 - /g;
                                                         # arithmetic operations
  $assignment =~ s/\s*\+\s*/ + /g;
  $assignment =~ s/\s*\-\s*/ - /g;
  $assignment =~ s/\s*\*\s*/ * /g;
  $assignment =~ s/\s*\/\s*/ \/ /g;
                                                              # logic operations
  $assignment =~ s/\s+and\s+/ and /ig;
  $assignment =~ s/\s+or\s+/ or /ig;
  $assignment =~ s/\s+xor\s+/ xor /ig;
  $assignment =~ s/\s+shl\s+/ shl /ig;
  $assignment =~ s/\s+shr\s+/ shr /ig;
                                                                   # parenthesis
  $assignment =~ s/\(\s+/(/g;
  $assignment =~ s/\s+\)/)/g;
  $assignment =~ s/\s*\[\s+/[/g;
  $assignment =~ s/\s+\]/]/g;

  return ($assignment);
}

#-------------------------------------------------------------------------------
# Extract first argument of an assignment
#
sub extractFirsrtArgument {
  my ($assignment) = @_;
  my $operator = '';
  my $restOfAssignment = '';
                                                       # starts with parenthesis
  if ($assignment =~ m/\A\(/) {
    my $index = 0;
    my $level = 0;
    my @characters = split(//, $assignment);
    foreach my $character (@characters) {
      if ($character eq '(') {$level = $level+1};
      if ($character eq '[') {$level = $level+1};
      if ($character eq ']') {$level = $level-1};
      if ($character eq ')') {$level = $level-1};
      if ($level == 0) {
        last;
      }
      $index = $index+1;
    }
    $firstArgument = substr($assignment, 0, $index+1);
    $restOfAssignment = substr($assignment, $index+1);
  }
                                                           # to first whitespace
  else {
    my $index = 0;
    my $level = 0;
    my @characters = split(//, $assignment);
    foreach my $character (@characters) {
      if ($character eq '(') {$level = $level+1};
      if ($character eq '[') {$level = $level+1};
      if ($character eq ']') {$level = $level-1};
      if ($character eq ')') {$level = $level-1};
      if ( ($character eq ' ') and ($level == 0) ) {
        last;
      }
      $index = $index+1;
    }
    $firstArgument = substr($assignment, 0, $index);
    $restOfAssignment = substr($assignment, $index);
  }
  $restOfAssignment =~ s/\A //;
#print "|$firstArgument|$restOfAssignment|\n";
                                                              # extract operator
  if ($restOfAssignment ne '') {
    ($operator, $restOfAssignment) = split(/ /, $restOfAssignment, 2);
  }

  return ($firstArgument, $operator, $restOfAssignment);
}

#-------------------------------------------------------------------------------
# Build expression out of argument and operator list
#
sub buildExpression {
  my ($arguments_ref, $operators_ref) = @_;
  my @arguments = @$arguments_ref;
  my @operators = @$operators_ref;
                                                         # loop on list elements
  my $expression = $arguments[0];
#print "0: $expression\n";
  for my $index (1 .. $#arguments) {
#print "$index: $operators[$index] $arguments[$index]\n";
    $expression .= " $operators[$index] $arguments[$index]";
  }
  return ($expression);
}

#-------------------------------------------------------------------------------
# Expand operation to 2 lines
#
sub expandTwo {
  my ($destinationRegister, $arguments_ref, $operators_ref) = @_;
  my @arguments = @$arguments_ref;
  my @operators = @$operators_ref;
  my $line = '';
#print "    -> ";
#for my $index (0..scalar(@arguments)-1) { print "$operators[$index]    $arguments[$index]    ";}
#print "\n";
                                                     # last argument is constant
  my $lastArgument = $arguments[$#arguments];
  my $lastOperator = $operators[$#operators];
  my $isDeclaredConstant = 0;
  foreach my $routine (keys(%constants)) {
    my $constants_ref = $constants{$routine};
    foreach my $constant (sort(keys(%$constants_ref))) {
      if ($lastArgument eq $constant) {
        $isDeclaredConstant = 1;
      }
    }
  }
  if (
    ($lastArgument =~ m/\A\d+\Z/) or
    ($lastArgument =~ m/\A\$[0-9A-Fa-f]+\Z/) or
    ($isDeclaredConstant)
  ) {
    pop(@arguments);
    pop(@operators);
    my $firstArgument = buildExpression(\@arguments, \@operators);
    if ($destinationRegister ne $firstArgument) {
      $line = "$destinationRegister := $firstArgument;\n";
    }
    $line .= "$destinationRegister := $destinationRegister $lastOperator $lastArgument;";
#print "$line\n";
  }
                                                      # last argument is compund
  elsif ($lastArgument =~ m/\A\((.+)\)\Z/)  {
    my $firstArgument = $1;
    pop(@arguments);
    pop(@operators);
    $lastArgument = buildExpression(\@arguments, \@operators);
    if ($firstArgument =~ m/ $destinationRegister /) {
      $line = "$partialOperationRegister := $firstArgument;\n";
      $line .= "$destinationRegister := $destinationRegister $lastOperator $partialOperationRegister;";
    }
    else {
      $line = "$destinationRegister := $firstArgument;\n";
      $line .= "$destinationRegister := $destinationRegister $lastOperator $lastArgument;";
    }
#print "$line\n";
  }

  return ($line);
}

#-------------------------------------------------------------------------------
# Expand assignment to multiple lines
#
sub expandAssignment {
  my ($destinationRegister, $assignment) = @_;
                                               # format assignment for treatment
  $assignment = formatAssignment($assignment);
                                                                # default result
  my $line = "$destinationRegister := $assignment;";
#print "\n$line\n";
                            # don't modify simple assignments and function calls
  my $source = translateArgument($assignment, $wordHexCharNb);
  my @arguments = ();
  my @operators = ('');
  if ( ($source eq '') and ($assignment !~ m/\Acall\s/) ){
                                                            # analyse assignment
#print "\n  $destinationRegister := $assignment\n";
    my $done = 0;
    do {
      my ($firstArgument, $operator, $restOfAssignment) = extractFirsrtArgument($assignment);
#print "    $firstArgument    $operator    $restOfAssignment\n";
      if ($operator eq '') {
        push(@arguments, $firstArgument);
        $done = 1;
      }
      else {
        push(@arguments, $firstArgument);
        push(@operators, $operator);
        $assignment = $restOfAssignment;
      }
    } until $done == 1;
#print "  -> " . join(', ', @arguments) . "\n";
                                                             # expand to 2 lines
    my $newLine = expandTwo($destinationRegister, \@arguments, \@operators);
                                                              # modify code line
    if ($newLine ne '') {
      $line = $newLine;
    }
  }

  return ($line);
}

################################################################################
# Program start
#

#-------------------------------------------------------------------------------
# Display information
#
if ($verbose > 0) {
  print "$separator\n";
  print "Compiling $pascalFileSpec to $asmFileSpec\n";
}

# ==============================================================================
# Rewrite file for easier parsing
#
$currentPass = $currentPass + 1;
my $inputFileSpec = $pascalFileSpec;
my $outputFileSpec = $temp1FileSpec;
if ($verbose > 0) {
  print "${indent}Pass $currentPass: placing line ends\n";
}
                                                               # read input file
my $singleLine = '';
open(inputFile, "<$inputFileSpec") or die "Unable to open file, $!";
while(my $line = <inputFile>) {
  chomp($line);
#print "$line\n";
                                            # remove leading and trailing spaces
  $line =~ s/\A\s+//;
  $line =~ s/\s+\Z//;
                                                   # remove single line comments
  $line =~ s/\{.*?\}//g;
                                                   # write to single line string
  if ($line ne '') {
    $singleLine .= "$line ";
  }
}
close(inputFile);
                                                           # remove extra spaces
$singleLine =~ s/\s+/ /g;
$singleLine =~ s/\s\Z//;
                                          # split constructs into multiple lines
$singleLine =~ s/\s*;\s*/;\n/g;
$singleLine =~ s/\sconst\s/\nconst\n/g;
$singleLine =~ s/\svar\s/\nvar\n/g;
$singleLine =~ s/\sprocedure\s+/\nprocedure /g;
$singleLine =~ s/\sfunction\s+/\nfunction /g;
$singleLine =~ s/\sbegin\s/\nbegin\n/g;
$singleLine =~ s/\send\s*;\s/\nend;\n/g;
$singleLine =~ s/\selse\s/\nelse\n/g;
$singleLine =~ s/\srepeat\s/\nrepeat\n/g;
$singleLine =~ s/\sif\s/\nif /g;
$singleLine =~ s/\suntil\s/\nuntil /g;
$singleLine =~ s/\sfor\s/\nfor /g;
$singleLine =~ s/\swhile\s/\nwhile /g;
$singleLine =~ s/\sthen\s/ then\n/g;
$singleLine =~ s/\sdo\s/ do\n/g;
                                        # take away new lines within parenthesis
my $parameters;
do {
  $singleLine =~ s/\(([^\)]*?)\n([^\)]*?)\)/($1 $2)/m;
  $parameters = $2;
#if ($parameters ne '') { print "--> $1 $parameters\n"; }
} while ($parameters ne '');
                                           # add begin/end to single-line blocks
my $singleLineBlock;
do {
  $singleLine =~ s/\nif (.*?) then\n(?!begin)(.*?)\;/\nif $1 then\nbegin\n$2;\nend;/;
  $singleLineBlock = $2;
#print "if $1 then begin $2; end;\n";
} while ($singleLineBlock ne '');
do {
  $singleLine =~ s/\nfor (.*?) do\n(?!begin)(.*?)\;/\nfor $1 do\nbegin\n$2;\nend;/;
  $singleLineBlock = $2;
} while ($singleLineBlock ne '');

                                                       # remove comments, part 1
$singleLine =~ s/\s*\{\s*/\n{/g;
$singleLine =~ s/\s*\}\s*/}\n/g;
                                                          # write to output file
open(outputFile, ">$outputFileSpec") or die "Unable to open file, $!";
print(outputFile "$singleLine\n");
close(outputFile);
                                                        # keep intermediate file
if ($keepIntermediateFiles) {
  my $textfile = "$baseFileSpec$currentPass.txt";
  use File::Copy;
  unlink($textfile);
  copy($outputFileSpec, $textfile) or die "File cannot be copied.";
}

# ==============================================================================
#  Finish removing comments
# 
$currentPass = $currentPass + 1;
($inputFileSpec, $outputFileSpec) = swapTempFileSpecs(
  $inputFileSpec, $outputFileSpec, $temp1FileSpec, $temp2FileSpec
);
if ($verbose > 0) {
  print "${indent}Pass $currentPass: removing comments\n";
}
                                                               # read input file
my $commentOut = 0;
open(inputFile, "<$inputFileSpec") or die "Unable to open file, $!";
open(outputFile, ">$outputFileSpec") or die "Unable to open file, $!";
while(my $line = <inputFile>) {
  chomp($line);
                                                       # remove comments, part 2
  if ($line =~ m/\{/) { $commentOut = 1; }
  if ( ($commentOut == 0) and ($line ne '') ) {
    print(outputFile "$line\n");
  }
  if ($line =~ m/\}/) { $commentOut = 0; }
}
close(outputFile);
close(inputFile);
                                                        # keep intermediate file
if ($keepIntermediateFiles) {
  my $textfile = "$baseFileSpec$currentPass.txt";
  use File::Copy;
  unlink($textfile);
  copy($outputFileSpec, $textfile) or die "File cannot be copied.";
}

# ==============================================================================
#  Get constants and variables, indent code
#
$currentPass = $currentPass + 1;
($inputFileSpec, $outputFileSpec) = swapTempFileSpecs(
  $inputFileSpec, $outputFileSpec, $temp1FileSpec, $temp2FileSpec
);
if ($verbose > 0) {
  print "${indent}Pass $currentPass: finding constants and variables\n";
}
my $currentLevel = 0;
my $currentRoutine;
my $startOfProgramDeclatation = '';
my $isStartOfProgramDeclatation = 1;
my $isConstantsDeclatation = 0;
my $isVariablesDeclatation = 0;
open(inputFile, "<$inputFileSpec") or die "Unable to open file, $!";
open(outputFile, ">$outputFileSpec") or die "Unable to open file, $!";
while(my $line = <inputFile>) {
  chomp($line);
#print "$line\n";
                                                             # find program name
  if ($line =~ m/\A\s*program\s+(.*)\s*;/i) {
    $mainProgram = $1;
#print "Program name is |$mainProgram|\n";
    $currentRoutine = $mainProgram;
    @routines = ($currentRoutine);
  }
                                                    # find current function name
  if ($line =~ m/\A(procedure|function)(\s|\Z)/i) {
    $currentRoutine = $line;
    $currentRoutine =~ s/\Aprocedure//i;
    $currentRoutine =~ s/\Afunction//i;
    $currentRoutine =~ s/\A\s+//;
    $currentRoutine =~ s/;.*//;
    $currentRoutine =~ s/\s*:.*//;
    $currentRoutine =~ s/\(.*//;
    push(@routines, $currentRoutine);
    print(outputFile "\n");
#print "$currentRoutine\n";
    $isStartOfProgramDeclatation = 0;
    $isVariablesDeclatation = 0;
    $isConstantsDeclatation = 0;
  }
                                                          # find begin/end level
  if ($line eq 'begin') {
    $currentLevel = $currentLevel + 1;
#print "-> $currentLevel\n";
    if ( ($currentLevel == 1) and ($currentRoutine eq $mainProgram) ) {
#print "$currentRoutine\n";
      $isStartOfProgramDeclatation = 0;
      print(outputFile "\n$startOfProgramDeclatation");
    }
    $isVariablesDeclatation = 0;
    $isConstantsDeclatation = 0;
  }
  if ($line eq 'end;') {
    $currentLevel = $currentLevel - 1;
#print "-> $currentLevel\n";
    if ($currentLevel == 0) {
      $currentRoutine = $mainProgram;
    }
  }
                                                                # find constants
  if ($isConstantsDeclatation) {
    if ($line ne 'var') {
#print "-> $line\n";
      $constants{$currentRoutine} .= $line;
    }
  }
  if ($line eq 'const') {
    $isConstantsDeclatation = 1;
    $isVariablesDeclatation = 0;
  }
                                                                # find variables
  if ($isVariablesDeclatation) {
#print "-> $line\n";
    $variables{$currentRoutine} .= $line;
  }
  if ($line eq 'var') {
    $isVariablesDeclatation = 1;
    $isConstantsDeclatation = 0;
  }
                                                        # determine indent level
  my $indentLevel = $currentLevel;
  if ($line eq 'begin') { $indentLevel = $indentLevel - 1; }
  if ($isConstantsDeclatation) { $indentLevel = $indentLevel + 2; }
  if ($isVariablesDeclatation) { $indentLevel = $indentLevel + 2; }
  if ($line eq 'const') { $indentLevel = $indentLevel - 1; }
  if ($line eq 'var') { $indentLevel = $indentLevel - 1; }
  if ($line eq 'end.') { $indentLevel = $indentLevel - 1; }
                                                          # write to output file
  my $indentedLine = ($indent x $indentLevel) . $line;
  $indentedLine = sprintf('%2d: ', $indentLevel) . $indentedLine;
  if ($isStartOfProgramDeclatation == 0) {
    print(outputFile "$indentedLine\n");
  } else {
    $startOfProgramDeclatation .= "$indentedLine\n";
  }
}
close(outputFile);
close(inputFile);
                                                        # keep intermediate file
if ($keepIntermediateFiles) {
  my $textfile = "$baseFileSpec$currentPass.txt";
  use File::Copy;
  unlink($textfile);
  copy($outputFileSpec, $textfile) or die "File cannot be copied.";
}

# ------------------------------------------------------------------------------
#  Process constant declarations
# 
%constants = buildConstants($mainProgram, %constants);

# ------------------------------------------------------------------------------
#  Assign registers to variables
# 
if ($verbose > 0) {
  print $indent x 2 . "Writing registers assignments in \"$registersFileSpec\"\n";
}
%variables = assignRegisters($mainProgram, $firstRegister, %variables);
open(registersFile, ">$registersFileSpec") or die "Unable to open file, $!";
foreach my $subroutine (keys(%variables)) {
  print(registersFile "$subroutine\n");
  my $registers_ref = $variables{$subroutine};
  my %registers = reverse(%$registers_ref);
  foreach my $register (sort(keys(%registers))) {
    print(registersFile "${indent}$register:$registers{$register}\n");
  }
}
close(registersFile);

# ==============================================================================
#  Process constants and variables and functions
#
$currentPass = $currentPass + 1;
($inputFileSpec, $outputFileSpec) = swapTempFileSpecs(
  $inputFileSpec, $outputFileSpec, $temp1FileSpec, $temp2FileSpec
);
if ($verbose > 0) {
  print "${indent}Pass $currentPass: replacing constants and variables\n";
}
                                             # build main program variables hash
my $variables_ref = $variables{$mainProgram};
%mainProgramVariables = %$variables_ref;
                                                          # loop on program code
my $currentRoutine;
my %localVariables;
my $printLine = 1;
open(inputFile, "<$inputFileSpec") or die "Unable to open file, $!";
open(outputFile, ">$outputFileSpec") or die "Unable to open file, $!";
                                          # write constants at beginning of file
foreach my $routine (keys(%constants)) {
  my $replacement_ref = $constants{$routine};
  foreach my $constant (sort(keys(%$replacement_ref))) {
    print(outputFile "const $constant = $$replacement_ref{$constant};\n");
  }
}
while(my $line = <inputFile>) {
  chomp($line);
#print "$line\n";
                                              # strip line nb and leading spaces
  my $strippedLine = $line;
  $strippedLine =~ s/\A\s*\d*\:*\s*//;
#print "$strippedLine\n";
                                                    # find current function name
  if (
    ($strippedLine =~ m/\Aprocedure /i) or
    ($strippedLine =~ m/\Afunction /i) or
    ($strippedLine =~ m/\Aprogram /i)
  ) {
    $currentRoutine = $strippedLine;
    $currentRoutine =~ s/\A\S+\s+//;
    $currentRoutine =~ s/\(.*//;
    $currentRoutine =~ s/\;//;
#print "$currentRoutine\n";
                                                  # build current variables hash
    my $variables_ref = $variables{$currentRoutine};
    %localVariables = %$variables_ref;
  }
                     # cut out constant and variable declarations of the program
  if ($strippedLine =~ m/\Aconst\Z/) {
    $printLine = 0;
  }
  if ($strippedLine =~ m/\Avar\Z/) {
    $printLine = 0;
  }
  if ($strippedLine eq 'begin') {
    $printLine = 1;
  }
                                                             # replace variables
  foreach my $variable (keys(%localVariables)) {
    $line =~ s/$variable/$localVariables{$variable}/g;
  }
  foreach my $variable (keys(%mainProgramVariables)) {
    $line =~ s/$variable/$mainProgramVariables{$variable}/g;
  }
                                                                  # write output
  if ($printLine) {
    print(outputFile "$line\n");
  }
}
close(outputFile);
close(inputFile);
                                                        # keep intermediate file
if ($keepIntermediateFiles) {
  my $textfile = "$baseFileSpec$currentPass.txt";
  use File::Copy;
  unlink($textfile);
  copy($outputFileSpec, $textfile) or die "File cannot be copied.";
}

# ==============================================================================
#  Label subroutines and loops
#
$currentPass = $currentPass + 1;
($inputFileSpec, $outputFileSpec) = swapTempFileSpecs(
  $inputFileSpec, $outputFileSpec, $temp1FileSpec, $temp2FileSpec
);
if ($verbose > 0) {
  print "${indent}Pass $currentPass: labelling subroutines and loops\n";
}
                                                          # loop on program code
my $previousWasElse = 0;
my $labelcount = 0;
my $blockKind;
my @labels;
open(inputFile, "<$inputFileSpec") or die "Unable to open file, $!";
open(outputFile, ">$outputFileSpec") or die "Unable to open file, $!";
while(my $line = <inputFile>) {
  chomp($line);
#print "$line\n";
                                                             # get current level
  my $currentLevel = $line;
  $currentLevel =~ s/\A\s*(\d*)\:.*/$1/;
                                          # strip level depth and leading spaces
  $line =~ s/\A\s*\d*\:\s*//;
#print "$line\n";
                                                     # remove "begin" statements
  $line =~ s/\Abegin\Z//;
                                             # assign labels to block statements
  if ($line =~ m/\Aif /) {
    if (not $previousWasElse) {
      $labelcount = $labelcount + 1;
      $labels[$currentLevel] = sprintf('if%02d', $labelcount);
    }
    $line = $labels[$currentLevel] . ': ' . $line;
  }
  if ($line =~ m/\Afor /) {
    $labelcount = $labelcount + 1;
    $labels[$currentLevel] = sprintf('for%02d', $labelcount);
    $line = $labels[$currentLevel] . ': ' . $line;
  }
  if ($line =~ m/\Awhile /) {
    $labelcount = $labelcount + 1;
    $labels[$currentLevel] = sprintf('while%02d', $labelcount);
    $line = $labels[$currentLevel] . ': ' . $line;
  }
                                      # assign labels to end of block statements
  if ($line =~ m/\Aend\s*[;\.]/) {
    if ($currentLevel == 0) {
      $line = 'return;';
    } else {
      $line = 'end ' . $labels[$currentLevel] . ';';
    }
  }
                                                       # specify procedure calls
  for my $routine (@routines) {
    $line =~ s/$routine\s*\:\=\s*/$functionReturnRegister := /g;
    $line =~ s/$routine([ \(\;])/call $routine$1/g;
  }
  $line =~ s/\A(program|procedure|function) call /$1 /g;
                                                # store "previous line was else"
  $previousWasElse = 0;
  if ($line =~ m/\Aelse\Z/) {
    $previousWasElse = 1;
  }
                                                                  # write output
  if ($line ne '') {
    if ($line =~ m/(program|procedure|function) /) {
      print(outputFile "\n");
    }
    my $indentedLine = ($indent x $currentLevel) . $line;
    $indentedLine = sprintf('%2d: ', $currentLevel) . $indentedLine;
    print(outputFile "$indentedLine\n");
  }
}
close(outputFile);
close(inputFile);
                                                        # keep intermediate file
if ($keepIntermediateFiles) {
  my $textfile = "$baseFileSpec$currentPass.txt";
  use File::Copy;
  unlink($textfile);
  copy($outputFileSpec, $textfile) or die "File cannot be copied.";
}

# ==============================================================================
#  Break compound operations
#
$currentPass = $currentPass + 1;
($inputFileSpec, $outputFileSpec) = swapTempFileSpecs(
  $inputFileSpec, $outputFileSpec, $temp1FileSpec, $temp2FileSpec
);
if ($verbose > 0) {
  print "${indent}Pass $currentPass: breaking compound operations\n";
}
                                                          # loop on program code
open(inputFile, "<$inputFileSpec") or die "Unable to open file, $!";
open(outputFile, ">$outputFileSpec") or die "Unable to open file, $!";
while(my $line = <inputFile>) {
  chomp($line);
#print "$line\n";
                                                             # get current level
  my $currentLevel = $line;
  $currentLevel =~ s/\A\s*(\d*)\:.*/$1/;
                                          # strip level depth and leading spaces
  $line =~ s/\A\s*\d*\:\s*//;
#print "$line\n";
                                                             # check assignments
  if ($line =~ m/s(\d+)\s*\:\=\s*(.+)\s*\;/) {
    my $destinationRegister = "s$1";
    my $assignment = $2;
    $line = expandAssignment($destinationRegister, $assignment);
  }
                                                                  # write output
  if ($line ne '') {
    my $indentedLine = ($indent x $currentLevel) . $line;
    $indentedLine = sprintf('%2d: ', $currentLevel) . $indentedLine;
    print(outputFile "$indentedLine\n");
  }
}
close(outputFile);
close(inputFile);
                                                        # keep intermediate file
if ($keepIntermediateFiles) {
  my $textfile = "$baseFileSpec$currentPass.txt";
  use File::Copy;
  unlink($textfile);
  copy($outputFileSpec, $textfile) or die "File cannot be copied.";
}


# ==============================================================================
#  Assembler file: constants, subroutines, memory access
#
$currentPass = $currentPass + 1;
($inputFileSpec, $outputFileSpec) = swapTempFileSpecs(
  $inputFileSpec, $outputFileSpec, $temp1FileSpec, $temp2FileSpec
);
if ($verbose > 0) {
  print "${indent}Pass $currentPass: writing assembler for constants, subroutines, mem and nop\n";
}
foreach my $routine (keys(%constants)) {
  my $constants_ref = $constants{$routine};
  foreach my $constant (sort(keys(%$constants_ref))) {
    my $length = length($constant);
    if ($length > $constantMaxLength) { $constantMaxLength = $length; }
  }
}
                                                         # assembler code header
open(outputFile, ">$outputFileSpec") or die "Unable to open file, $!";
print(outputFile "$separator1\n");
print(outputFile "$commentStart $mainProgram\n");
print(outputFile "$separator1\n");
print(outputFile "\n");
                                                          # loop on program code
open(inputFile, "<$inputFileSpec") or die "Unable to open file, $!";
while(my $line = <inputFile>) {
  chomp($line);
#print "$line\n";
                                          # strip level depth and leading spaces
  $line =~ s/\A\s*\d*\:\s*//;
#print "$line\n";
                                                             # replace constants
  if ($line =~ m/\Aconst (.*?)\s*\=\s*\$(.*?)\;/) {
    my $constantName = fillString("$1,", ' ', $constantMaxLength+1);
    my $constantValue = sprintf("%0${wordHexCharNb}X", hex($2));
    $line = "$asmFirstIndent CONSTANT  $constantName $constantValue";
  }
                                                     # replace subroutines start
  if ($line =~ m/\A(program|procedure|function) (.*?)\s*[\;\(]/) {
    my $routineKind = $1;
    my $routineName = $2;
    print(outputFile "\n");
    print(outputFile "$separator2\n");
    print(outputFile "$commentStart $routineKind $routineName\n");
    print(outputFile "$separator2\n");
    print(outputFile ' ' x (length($asmFirstIndent) - length($routineName) - 2) . "$routineName: NOP\n");
    $line = '';
  }
                                                    # replace subroutines return
  $line =~ s/\Areturn\;/${asmFirstIndent}RETURN/;
                                       # replace subroutine calls with arguments
  if ($line =~ m/call (.*?)\s*\((.*?)\s*\)\s*\;/) {
    my $routineName = $1;
    my $routineArguments = $2;
    $routineArguments =~ s/var //g;
    $routineArguments =~ s/\;/,/g;
    $argumentText = 'argument';
    if($routineArguments =~ m/\,/) {
      $argumentText .= 's';
    }
    print(
      outputFile
      "$asmFirstIndent"
        . fillString('CALL', ' ', $opcodeLength)
        . "$routineName  ; $argumentText: $routineArguments\n"
    );
    if ($line =~ m/\A(.*?)\s*\:\=\s* call/) {
      $returnRegister = $1;
      $line = "$returnRegister := s0;\n";
    } else {
      $line = '';
    }
  }
                                    # replace subroutine calls without arguments
  if ($line =~ m/\Acall (.*?)\;/) {
    $line = $asmFirstIndent . fillString('CALL', ' ', $opcodeLength) . $1;
  }
                                                                  # memory write
  if ($line =~ m/mem\[(.+?)\]\s*\:\=\s*(.+)\s*\;/) {
    my $opcode = fillString('OUTPUT', ' ', $opcodeLength);
    $line = "$memoryAccessRegister := $1;";
    $line .= "\n${asmFirstIndent}${opcode}$2, ($memoryAccessRegister)";
  }
                                                                   # memory read
  if ($line =~ m/\s*(.+)\s*\:\=\s*mem\[(.+?)\]\s*\;/) {
    my $opcode = fillString('INPUT', ' ', $opcodeLength);
    $line = "$memoryAccessRegister := $2;";
    $line .= "\n${asmFirstIndent}${opcode}$memoryAccessRegister, ($memoryAccessRegister)" x 2;
    $line .= "\n$1 := $memoryAccessRegister;";
  }
                                                                           # NOP
  if ($line =~ m/\s*noOperation\s*\;/) {
    $line = "${asmFirstIndent}NOP";
  }
                                                                  # write output
  if ($line ne '') {
    print(outputFile "$line\n");
  }
}
close(outputFile);
close(inputFile);
                                                        # keep intermediate file
if ($keepIntermediateFiles) {
  my $textfile = "$baseFileSpec$currentPass.txt";
  use File::Copy;
  unlink($textfile);
  copy($outputFileSpec, $textfile) or die "File cannot be copied.";
}

# ==============================================================================
#  Assembler file: register transfers
#
$currentPass = $currentPass + 1;
($inputFileSpec, $outputFileSpec) = swapTempFileSpecs(
  $inputFileSpec, $outputFileSpec, $temp1FileSpec, $temp2FileSpec
);
if ($verbose > 0) {
  print "${indent}Pass $currentPass: writing assembler for load, add, and sub\n";
}
                                                          # loop on program code
open(inputFile, "<$inputFileSpec") or die "Unable to open file, $!";
open(outputFile, ">$outputFileSpec") or die "Unable to open file, $!";
while(my $line = <inputFile>) {
  chomp($line);
#print "$line\n";
                                                                          # LOAD
  if ($line =~ m/s(\d+)\s*\:\=\s*(.+)\s*\;/) {
    my $destinationRegister = fillString("s$1,", ' ', $firstArgumentLength);
    my $source = translateArgument($2, $wordHexCharNb);
    my $opcode = fillString('LOAD', ' ', $opcodeLength);
    if ($source ne '') {
      $line = "${asmFirstIndent}${opcode}${destinationRegister}$source";
    }
  }
                                                                           # ADD
  if ($line =~ m/s(\d+)\s*\:\=\s*s(\d+)\s*\+\s*(.+)\s*\;/) {
    if ($1 eq $2) {
      my $destinationRegister = fillString("s$1,", ' ', $firstArgumentLength);
      my $source = translateArgument($3, $wordHexCharNb);
      my $opcode = fillString('ADD', ' ', $opcodeLength);
      if ($source ne '') {
        $line = "${asmFirstIndent}${opcode}${destinationRegister}$source";
      }
    }
  }
                                                                           # SUB
  if ($line =~ m/s(\d+)\s*\:\=\s*s(\d+)\s*\-\s*(.+)\s*\;/) {
    if ($1 eq $2) {
      my $destinationRegister = fillString("s$1,", ' ', $firstArgumentLength);
      my $source = translateArgument($3, $wordHexCharNb);
      my $opcode = fillString('SUB', ' ', $opcodeLength);
      if ($source ne '') {
        $line = "${asmFirstIndent}${opcode}${destinationRegister}$source";
      }
    }
  }
                                                                           # AND
  if ($line =~ m/s(\d+)\s*\:\=\s*s(\d+)\s*and\s*(.+)\s*\;/i) {
    if ($1 eq $2) {
      my $destinationRegister = fillString("s$1,", ' ', $firstArgumentLength);
      my $source = translateArgument($3, $wordHexCharNb);
      my $opcode = fillString('AND', ' ', $opcodeLength);
      if ($source ne '') {
        $line = "${asmFirstIndent}${opcode}${destinationRegister}$source";
      }
    }
  }
                                                                            # OR
  if ($line =~ m/s(\d+)\s*\:\=\s*s(\d+)\s*or\s*(.+)\s*\;/i) {
    if ($1 eq $2) {
      my $destinationRegister = fillString("s$1,", ' ', $firstArgumentLength);
      my $source = translateArgument($3, $wordHexCharNb);
      my $opcode = fillString('OR', ' ', $opcodeLength);
      if ($source ne '') {
        $line = "${asmFirstIndent}${opcode}${destinationRegister}$source";
      }
    }
  }
                                                                  # write output
  if ($line ne '') {
    print(outputFile "$line\n");
  }
}
close(outputFile);
close(inputFile);
                                                        # keep intermediate file
if ($keepIntermediateFiles) {
  my $textfile = "$baseFileSpec$currentPass.txt";
  use File::Copy;
  unlink($textfile);
  copy($outputFileSpec, $textfile) or die "File cannot be copied.";
}

################################################################################
# Documentation (access it with: perldoc <scriptname>)
#
__END__

=head1 NAME

nanoPascal.pl - Transforms a Pascal program into assembler code

=head1 SYNOPSIS

nanoPascal.pl [options]

=head1 DESCRIPTION

This is a simple parser which translates Pascal expressions into their assembler
code equivalents for the nanoBlaze processor.
The process doesn't optimize the code.
The expressions which couldn't be translated into assembler are left as Pascal
for the user to translate manually.

=head1 OPTIONS

=over 8

=item B<-h>

Display a help message.

=item B<-v>

Be verbose.

=item B<-k>

Makes a copy of the intermediate files between the passes.

=item B<-c>

Cleans the temporary work files at the end of the process.

Specify a username in the bridge's whitelist.

=back

=head1 Limitations

There is currently no Pascal syntax error detection.

The script doesn't distinguish between constants having the same name within
different procedures or functions.
This can be corrected in future versions.

Procedure and function calls basically don't support passing parameters.
This would require a stack mechanism.
The only possible way to pass parameters is to declare global variables
and use these as parameters for the procedure and function calls.

The Pascal C<if ... then> construct is either followed by a C<begin ... end>
block or a single expression.
The script only handles single-line expressions.
Other more complex expressions (like a nested c<if .. then> need a
C<begin ... end> structure.

=head1 AUTHOR

Francois Corthay, HEVs

=head1 VERSION

1.1, 2014

=cut
