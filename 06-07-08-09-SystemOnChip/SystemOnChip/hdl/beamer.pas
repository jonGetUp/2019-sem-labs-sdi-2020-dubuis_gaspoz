{
  beamer.pas

  The beamer controller polls the UART to get commands and provides the
  corresponding replies.
}

program BeamerControl;

{==============================================================================}
{ Constants                                                                    }
{==============================================================================}
  const
    clockFrequency      = 66E6;
    gpioBaseAddress     = $0000;
    gpioDataOffset        = $0000;
    gpioEnableOffset      = $0001;
    uartBaseAddress     = $0010;
    uartBaudOffset        = $0002;
    uartStatusOffset      = $0001;
    uartDataReady           = $0001;
    uartSending             = $0002;
    uartBaudRate        = 1E6;
    uartBaudCount         = clockFrequency / uartBaudRate;
    uartpollDelay         = uartBaudCount / 2;
    commandHeader       = $AA;
    commandNack         = $00;
    commandWriteMem     = $03;
    commandReadMem      = $04;
    commandWriteLength  = 4;
    commandReadLength   = 2;
    beamerBaseAddress   = $0020;
    beamerCtlOffset       = $0000;
    beamerSpeedOffset     = $0001;
    beamerCtlInit         = $0401;
    beamerSpeedInit       = $0004;

{==============================================================================}
{ Variables                                                                    }
{==============================================================================}
  var
    packetId, commandId, errorId: uint8;
    memoryAddress, memoryData: word;

{==============================================================================}
{ Procedures and functions                                                     }
{==============================================================================}

  {============================================================================}
  { Register-level accesses                                                    }
  {============================================================================}

  {----------------------------------------------------------------------------}
  { Registers initializations                                                  }
  {----------------------------------------------------------------------------}
  procedure initRegisters;
  begin
                                                             { initialize GPIO }
    mem[gpioBaseAddress+gpioDataOffset] := $AA;
    mem[gpioBaseAddress+gpioEnableOffset] := $0F;
                                                             { initialize UART }
    mem[uartBaseAddress+uartBaudOffset] := uartBaudCount;
                                                { initialize beamer peripheral }
    mem[beamerBaseAddress+beamerCtlOffset] := beamerCtlInit;
    mem[beamerBaseAddress+beamerSpeedOffset] := beamerSpeedInit;
  end;

  {----------------------------------------------------------------------------}
  { Get byte from serial port                                                  }
  {----------------------------------------------------------------------------}
  procedure getSerialPortByte : uint8;
    var
      uartByte: uint8;
  begin
                                              { poll until data byte available }
    uartByte := 0;
    while uartByte = 0 do
      begin
                           { spend time in order not to overcharge the AHB bus }
        for index := 1 to uartpollDelay do
          noOperation;
                                                        { read status register }
        uartByte := mem[uartBaseAddress+uartStatusOffset] and uartDataReady;
      end;
                                            { read data register and return it }
    getSerialPortByte := mem[uartBaseAddress];
  end;

  {----------------------------------------------------------------------------}
  { Send byte to serial port                                                   }
  {----------------------------------------------------------------------------}
  procedure sendSerialPort(uartByte : uint8);
    var
      statusByte: uint8;
  begin
                                                    { poll until ready to send }
    statusByte := mem[uartBaseAddress+uartStatusOffset] and uartSending;
    while statusByte = 0 do
      begin
                           { spend time in order not to overcharge the AHB bus }
        for index := 1 to uartpollDelay do
          noOperation;
                                                        { read status register }
        statusByte := mem[uartBaseAddress+uartStatusOffset] and uartSending;
      end;
                                                         { write data register }
    mem[uartBaseAddress] := uartByte;
  end;

  {============================================================================}
  { Communication protocol                                                     }
  {============================================================================}

  {----------------------------------------------------------------------------}
  { Get command                                                                }
  {----------------------------------------------------------------------------}
  function getCommand(
    var packetId, commandId, commandLength : uint8;
    var memoryAddress, memoryData : word
  ) : uint8;
    var
      uartData: uint8;
      checksum: word;
  begin
                                                 { wait for new command header }
    uartData := 0;
    while uartData <> commandHeader do
      uartData := getSerialPortByte;
    checksum := uartData;
                                                               { get packet id }
    packetId := getSerialPortByte;
    checksum := checksum + packetId;
                                                                 { get command }
    commandId := getSerialPortByte;
    checksum := checksum + commandId;
                                                      { process known commands }
    if (commandId = commandWriteMem) or (commandId = commandReadMem) then
      begin
                                                          { get command length }
        commandLength := getSerialPortByte;
        checksum := checksum + commandLength;
                                                       { check command lengths }
        if (commandId = commandWriteMem) and (commandLength <> commandWriteLength) then
          getCommand := 1;
        else if (commandId = commandReadMem) and (commandLength <> commandReadLength) then
          getCommand := 1;
        else
          begin
                                                                 { get address }
            memoryAddress := getSerialPortByte;
            checksum := checksum + memoryAddress;
            memoryAddress := (memoryAddress shl 8) + getSerialPortByte;
            checksum := checksum + memoryAddress;
                                                                    { get data }
            if commandId = commandReadMem then
              begin
                memoryData := getSerialPortByte;
                checksum := checksum + memoryData;
                memoryData := (memoryData shl 8) + getSerialPortByte;
                checksum := checksum + memoryData;
              end;
                                                      { get and verify checksum}
            if getSerialPortByte = (checksum and $00FF) then
              getCommand := 0;
            else
              getCommand := 1;
          end;
      end;
    else
      getCommand := 1;
  end;

  {----------------------------------------------------------------------------}
  { Send NACK                                                                  }
  {----------------------------------------------------------------------------}
  function sendNegativeAcknowledge(packetId : uint8);
    var
      uartData: uint8;
      checksum: word;
  begin
                                                          { send packet header }
    uartData := $AA;
    sendSerialPort(uartData);
    checksum := uartData;
                                                              { send packet id }
    uartData := packetId;
    sendSerialPort(uartData);
    checksum := checksum + uartData;
                                                             { send command id }
    uartData := commandNack;
    sendSerialPort(uartData);
    checksum := checksum + uartData;
                                                          { send packet length }
    uartData := 0;
    sendSerialPort(uartData);
    checksum := checksum + uartData;
                                                               { send checksum }
    uartData := checksum and $00FF;
    sendSerialPort(uartData);
  end;

  {----------------------------------------------------------------------------}
  { Send ACK                                                                  }
  {----------------------------------------------------------------------------}
  function sendAcknowledge(packetId, commandId : uint8);
    var
      uartData: uint8;
      checksum: word;
  begin
                                                          { send packet header }
    uartData := $AA;
    sendSerialPort(uartData);
    checksum := uartData;
                                                              { send packet id }
    uartData := packetId;
    sendSerialPort(uartData);
    checksum := checksum + uartData;
                                                             { send command id }
    uartData := commandId;
    sendSerialPort(uartData);
    checksum := checksum + uartData;
                                                          { send packet length }
    uartData := 0;
    sendSerialPort(uartData);
    checksum := checksum + uartData;
                                                               { send checksum }
    uartData := checksum and $00FF;
    sendSerialPort(uartData);
  end;

  {----------------------------------------------------------------------------}
  { Send READ_MEM reply                                                                  }
  {----------------------------------------------------------------------------}
  function sendReadAnswer(packetId : uint8; memoryData: word);
    var
      uartData: uint8;
      checksum: word;
  begin
                                                          { send packet header }
    uartData := $AA;
    sendSerialPort(uartData);
    checksum := uartData;
                                                              { send packet id }
    uartData := packetId;
    sendSerialPort(uartData);
    checksum := checksum + uartData;
                                                             { send command id }
    uartData := commandReadMem;
    sendSerialPort(uartData);
    checksum := checksum + uartData;
                                                          { send packet length }
    uartData := 2;
    sendSerialPort(uartData);
    checksum := checksum + uartData;
                                                               { send data low }
    uartData := memoryData and $00FF;
    sendSerialPort(uartData);
    checksum := checksum + uartData;
                                                              { send data high }
    uartData := memoryData shr 8;
    sendSerialPort(uartData);
    checksum := checksum + uartData;
                                                               { send checksum }
    uartData := checksum and $00FF;
    sendSerialPort(uartData);
  end;

{==============================================================================}
{ Main program                                                                 }
{==============================================================================}
begin
                                                    { initialize SoC registers }
  initRegisters;
                                                                   { main loop }
  while true do begin
                                                           { get a new command }
    errorId := getCommand(packetId, commandId, memoryAddress, memoryData);
                                                             { process command }
    if errorId = 0 then
      begin
                                                       { process write command }
        if commandId = commandWriteMem then
          begin
            mem[memoryAddress] := memoryData;
            sendAcknowledge(packetId, commandId);
          end;
                                                        { process read command }
        else if commandId = commandReadMem then
          begin
            memoryData := mem[memoryAddress];
            sendReadAnswer(packetId, memoryData);
          end;
                                                    { reply to unknown command }
        else
          sendNegativeAcknowledge(packetId);
      end;
                                     { negative acknowledge on reception error }
    else
      sendNegativeAcknowledge(packetId);
  end;
end.

{
                ;---------------------------------------------------------------
                ; register definitions
                ;   s0, s1: used for INPUT and OUTPUT operations
                ;   S2: returns UART data byte
                ;   S3: uart protocol checksum
                ;   S4: uart protocol packet id
                ;   S5: uart protocol command id
                ;   S6: uart protocol address
                ;   S7: uart protocol data
                ;   S8: copy of UART data byte for debug
                ;---------------------------------------------------------------
}
