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
    uartPollDelay         = uartBaudCount / 2;
    uartTimeout         = 10;
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
    commStIdle            = $0000;
    commStGetPacketId     = $0001;
    commStGetCommandId    = $0002;
    commStGetDataLength   = $0003;
    commStGetData         = $0004;
    commStGetChecksum     = $0005;
    commStExecuteCommand  = $0006;
    commStSendHeader      = $0007;
    commStSendPacketId    = $0008;
    commStSendCommandId   = $0009;
    commStSendDataLength  = $000A;
    commStSendData        = $000B;
    commStSendChecksum    = $000C;

{==============================================================================}
{ Variables                                                                    }
{==============================================================================}
  var
    communicationState : word;
    uartByte: uint8;

{==============================================================================}
{ Procedures and functions                                                     }
{==============================================================================}

  {============================================================================}
  { Register-level functions                                                    }
  {============================================================================}

  {----------------------------------------------------------------------------}
  { Registers initializations                                                  }
  {----------------------------------------------------------------------------}
  procedure initRegisters;
    const
      gpioValue = $AA;
      gpioEnablemask = $0F;
  begin
                                                             { initialize GPIO }
    mem[gpioBaseAddress+gpioDataOffset] := gpioValue;
    mem[gpioBaseAddress+gpioEnableOffset] := gpioEnablemask;
                                                             { initialize UART }
    mem[uartBaseAddress+uartBaudOffset] := uartBaudCount;
                                                { initialize beamer peripheral }
    mem[beamerBaseAddress+beamerCtlOffset] := beamerCtlInit;
    mem[beamerBaseAddress+beamerSpeedOffset] := beamerSpeedInit;
  end;

  {----------------------------------------------------------------------------}
  { Get byte from serial port with timeout                                     }
  {----------------------------------------------------------------------------}
  function getSerialPortByte(var uartByte: uint8) : word;
    var
      dataReady: uint8;
      pollCount: word;
  begin
                            { poll until data byte available or timeout occured}
    pollCount := uartPollDelay;
    dataReady := 0;
    while dataReady = 0 do
      begin
                                                        { read status register }
        dataReady := mem[uartBaseAddress+uartStatusOffset] and uartDataReady;
                           { spend time in order not to overcharge the AHB bus }
        if dataReady = 0 then
          begin
                                                           { check for timeout }
            pollCount := pollCount -1;
            if pollCount = 0 then
              dataReady := $FF;
                        { spend time in order not to overcharge the system bus }
            for index := 1 to uartPollDelay do
              noOperation;
          end;
      end;
                                                             { function return }
    if dataReady = $FF then
                                                              { return timeout }
      getSerialPortByte := 1;
    else
                                            { read data register and return it }
      begin
        uartByte := mem[uartBaseAddress];
        getSerialPortByte := 0;
      end;
  end;

  {----------------------------------------------------------------------------}
  { Send byte to serial port with timeout                                      }
  {----------------------------------------------------------------------------}
  function sendSerialPort(var uartByte : uint8) : word;
    var
      dataReady: uint8;
      statusByte: uint8;
      pollCount: word;
  begin
                                                    { poll until ready to send }
    pollCount := uartPollDelay;
    statusByte := mem[uartBaseAddress+uartStatusOffset] and uartSending;
    while statusByte = 0 do
      begin
                                                           { check for timeout }
        pollCount := pollCount -1;
        if pollCount = 0 then
          dataReady := $FF;
                        { spend time in order not to overcharge the system bus }
        for index := 1 to uartPollDelay do
          noOperation;
                                                        { read status register }
        statusByte := mem[uartBaseAddress+uartStatusOffset] and uartSending;
      end;
                                                             { function return }
    if dataReady = $FF then
                                                              { return timeout }
      sendSerialPort := 1;
    else
                                           { write data register and return it }
      begin
        mem[uartBaseAddress] := uartByte;
        sendSerialPort := 0;
      end;
  end;

  {============================================================================}
  { Communication state machine                                                                }
  {============================================================================}
  procedure updateStateMachine(
    var communicationState : word;
    var uartByte: uint8
  );
    var
      communicationNextState : word;
      uartStatus: word;
      packetId, commandId : uint8;
      checksum : uint8;
      dataLength, dataCount, data1, data2, data3, data4 : uint8;
      memAddress, memData : word;
  begin
                                                                        { idle }
    if communicationState = commStIdle then
      begin
        uartStatus := getSerialPortByte(var uartByte: uint8);
        if (uartStatus = 0) and (uartByte = commandHeader) then
          begin
            checksum := uartByte;
            communicationNextState := commStGetPacketId;
          end;
      end;
                                                               { get packet id }
    else if communicationState = commStGetPacketId then
      begin
        uartStatus := getSerialPortByte(var uartByte: uint8);
        if uartStatus = 0 then
          begin
            packetId := uartByte;
            checksum := checksum + uartByte;
            communicationNextState := commStGetCommandId;
          end;
      end;
                                                              { get command id }
    else if communicationState = commStGetCommandId then
      begin
        uartStatus := getSerialPortByte(var uartByte: uint8);
        if uartStatus = 0 then
          begin
            commandId := uartByte;
            checksum := checksum + uartByte;
            communicationNextState := commStGetDataLength;
          end;
      end;
                                                             { get data length }
    else if communicationState = commStGetDataLength then
      begin
        uartStatus := getSerialPortByte(var uartByte: uint8);
        if uartStatus = 0 then
          begin
            dataLength := uartByte;
            checksum := checksum + uartByte;
            dataCount := dataLength;
            communicationNextState := commStGetData;
          end;
      end;
                                                                    { get data }
    else if communicationState = commStGetData then
      begin
        uartStatus := getSerialPortByte(var uartByte: uint8);
        if uartStatus = 0 then
          begin
            data1 := data2;
            data2 := data3;
            data3 := data4;
            data4 := uartByte;
            checksum := checksum + uartByte;
            dataCount := dataCount-1;
            if dataCount = 0 then
              communicationNextState := commStGetChecksum;
          end;
      end;
                                                                { get checksum }
    else if communicationState = commStGetChecksum then
      begin
        uartStatus := getSerialPortByte(var uartByte: uint8);
        if uartStatus = 0 then
          begin
            if uartByte = checksum then
              communicationState := commStExecuteCommand;
            else
              begin
                commandId := commandNack;
                dataLength := 0;
                communicationNextState := commStSendHeader;
              end;
          end;
      end;
                                                             { execute command }
    else if communicationState = commStExecuteCommand then
begin
      if (commandId = commandWriteMem) and (dataLength = commandWriteLength) then
        begin
          memAddress := data1 + (data2 shl 8);
          memData    := data3 + (data4 shl 8);
          mem[memAddress] := memData;
          dataLength := 0;
          communicationNextState := commStSendHeader;
        end;
      else if (commandId = commandReadMem) and (dataLength = commandReadLength) then
        begin
          memAddress := data3 + (data4 shl 8);
          memData := mem[memAddress];
          dataLength := 2;
          data1 := memData and $00FF;
          data2 := memData shr 8;
          communicationNextState := commStSendHeader;
        end;
      else
        begin
          commandId := commandNack;
          dataLength := 0;
          communicationNextState := commStSendHeader;
        end;
end;
                                                                 { send header }
    else if communicationState = commStSendHeader then
      begin
        uartByte := commandHeader;
        uartStatus := sendSerialPort(var uartByte: uint8);
        if uartStatus = 0 then
          begin
            checksum := uartByte;
            communicationNextState := commStSendPacketId;
          end;
      end;
                                                              { send packet id }
    else if communicationState = commStSendPacketId then
      begin
        uartByte := packetId;
        uartStatus := sendSerialPort(var uartByte: uint8);
        if uartStatus = 0 then
          begin
            checksum := checksum + uartByte;
            communicationNextState := commStSendCommandId;
          end;
      end;
                                                             { send command id }
    else if communicationState = commStSendCommandId then
      begin
        uartByte := commandId;
        uartStatus := sendSerialPort(var uartByte: uint8);
        if uartStatus = 0 then
          begin
            checksum := checksum + uartByte;
            communicationNextState := commStSendDataLength;
          end;
      end;
                                                            { send data length }
    else if communicationState = commStSendDataLength then
      begin
        uartByte := dataLength;
        dataCount := dataLength;
        uartStatus := sendSerialPort(var uartByte: uint8);
        if uartStatus = 0 then
          begin
            checksum := checksum + uartByte;
            communicationNextState := commStSendData;
          end;
      end;
                                                                   { send data }
    else if communicationState = commStSendData then
      begin
        if dataCount > 0 then
          begin
            uartByte := data1;
            data2 := data1;
            data3 := data2;
            data4 := data3;
            uartStatus := sendSerialPort(var uartByte: uint8);
            if uartStatus = 0 then
              begin
                checksum := checksum + uartByte;
                dataCount := dataCount-1;
              end;
          end;
        else
          communicationNextState := commStSendChecksum;
      end;
                                                               { send checksum }
    else if communicationState = commStSendChecksum then
      begin
        uartByte := checksum and $00FF;
        uartStatus := sendSerialPort(var uartByte: uint8);
        if uartStatus = 0 then
          communicationNextState := commStIdle;
      end;
                                                                { update state }
    communicationState := communicationNextState;
  end;

{==============================================================================}
{ Main program                                                                 }
{==============================================================================}
begin
                                                    { initialize SoC registers }
  initRegisters;
                                      { initialize communication state machine }
  communicationState := commStIdle;
                                                                   { main loop }
  while true do begin
                                          { update communication state machine }
    updateStateMachine(var communicationState : word; var uartByte : uint8);
                                                           { check for timeout }
  end;
end.
