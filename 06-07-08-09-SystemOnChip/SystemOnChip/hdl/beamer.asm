                ;===============================================================
                ; Beamer control
                ;===============================================================

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

                ;---------------------------------------------------------------
                ; GPIO definitions
                ;---------------------------------------------------------------
                CONSTANT  gpioBaseAddress,  0000
                CONSTANT  gpioDataOffset,   0000
                CONSTANT  gpioEnableOffset, 0001
                ;---------------------------------------------------------------
                ; UART definitions
                ;---------------------------------------------------------------
                CONSTANT  uartBaseAddress,  0010
                CONSTANT  uartBaudOffset,   0002
                CONSTANT  uartStatusOffset, 0001
                CONSTANT  uartDataReady,    0001
                CONSTANT  uartSending,      0002
;                CONSTANT  uartBaudCount,    023D        ; 66E6 / 115 200 = 573
                CONSTANT  uartBaudCount,    0042        ; 66E6 / 1E6 = 66
;                CONSTANT  uartpollDelay,    0100
                CONSTANT  uartpollDelay,    0040
                CONSTANT  commandNack,      0000
                CONSTANT  commandWriteMem,  0003
                CONSTANT  commandReadMem,   0004
                ;---------------------------------------------------------------
                ; beamer peripheral definitions
                ;---------------------------------------------------------------
                CONSTANT  beamerBaseAddress,0020
                CONSTANT  beamerCtlOffset,  0000
                CONSTANT  beamerSpeedOffset,0001
                CONSTANT  beamerCtlInit,    0401
;                CONSTANT  beamerCtlInit,    1001
                CONSTANT  beamerSpeedInit,  0004

                ;===============================================================
                ; initializations
                ;===============================================================

                ;---------------------------------------------------------------
                ; initialize GPIO
                ;---------------------------------------------------------------
                LOAD      s0, gpioBaseAddress
                ADD       s0, gpioDataOffset
                LOAD      s1, AA
                OUTPUT    s1, (s0)
                LOAD      s0, gpioBaseAddress
                ADD       s0, gpioEnableOffset
                LOAD      s1, 0F
                OUTPUT    s1, (s0)
                ;---------------------------------------------------------------
                ; initialize UART
                ;---------------------------------------------------------------
                LOAD      s0, uartBaseAddress
                ADD       s0, uartBaudOffset
                LOAD      s1, uartBaudCount
                OUTPUT    s1, (s0)
                ;---------------------------------------------------------------
                ; initialize beamer peripheral
                ;---------------------------------------------------------------
                LOAD      s0, beamerBaseAddress
                ADD       s0, beamerCtlOffset
                LOAD      s1, beamerCtlInit
                OUTPUT    s1, (s0)
                LOAD      s0, beamerBaseAddress
                ADD       s0, beamerSpeedOffset
                LOAD      s1, beamerSpeedInit
                OUTPUT    s1, (s0)

                ;===============================================================
                ; Main loop
                ;===============================================================

                ;---------------------------------------------------------------
                ; Process commands from serial port
                ;---------------------------------------------------------------
          main: CALL      uartGetCmd            ; get command from UART
                COMPARE   s3, 0000              ; check function return
                JUMP      nz, commandAbort
                COMPARE   s5, commandWriteMem   ; check for WRITE_MEM command
                JUMP      nz, commandRead
                OUTPUT    s7, (s6)              ; write word to memory location
                CALL      sendWriteOk           ; send write acknowledge
                JUMP      main
   commandRead: INPUT     s7, (s6)              ; write word in memory location
                CALL      sendReadData          ; send back read data
                JUMP      main
  commandAbort: CALL      sendNAck
                JUMP      main

                ;===============================================================
                ; Subroutines
                ;===============================================================

                ;---------------------------------------------------------------
                ; Get command from serial port
                ;---------------------------------------------------------------
    uartGetCmd: CALL      uartGetByte           ; get command header
                COMPARE   s2, 00AA
                JUMP      nz, uartGetCmd        ; loop until byte is AAh
                LOAD      s3, s2                ; prepare checksum
                CALL      uartGetByte           ; get packet id
                ADD       s3, s2                ; calculate checksum
                LOAD      s4, s2                ; store id for reply
                CALL      uartGetByte           ; get command
                ADD       s3, s2                ; calculate checksum
                COMPARE   s2, commandWriteMem   ; check for WRITE_MEM command
                JUMP      z , commandOk
                COMPARE   s2, commandReadMem    ; check for READ_MEM command
                JUMP      z , commandOk
                JUMP      commandKo             ; no match
     commandOk: LOAD      s5, s2                ; store command for action
                CALL      uartGetByte           ; get data length
                ADD       s3, s2                ; calculate checksum
                COMPARE   s5, commandWriteMem   ; check for WRITE_MEM command
                JUMP      z , testWrLength      ; go to test write command length
                COMPARE   s2, 0002              ; verify READ_MEM length
                JUMP      nz, commandKo
                JUMP      getAddress
  testWrLength: COMPARE   s2, 0004              ; verify WRITE_MEM length
                JUMP      nz, commandKo
    getAddress: CALL      uartGetByte           ; get address low
                ADD       s3, s2                ; calculate checksum
                LOAD      s6, s2                ; store address low
                CALL      uartGetByte           ; get address high
                ADD       s3, s2                ; calculate checksum
                CALL      shiftS2L8
                ADD       s6, s2                ; build address from low and high
                COMPARE   s5, commandReadMem    ; check for READ_MEM command
                JUMP      z , getChecksum       ; skip reading data word
                CALL      uartGetByte           ; get data low
                ADD       s3, s2                ; calculate checksum
                LOAD      s7, s2                ; store data low
                CALL      uartGetByte           ; get data high
                ADD       s3, s2                ; calculate checksum
                CALL      shiftS2L8
                ADD       s7, s2                ; build data from low and high
   getChecksum: CALL      uartGetByte           ; get checksum
                AND       s3, 00FF              ; limit calculated checksum to 8 bit
                COMPARE   s3, s2                ; test checksum
                JUMP      nz, commandKo
                LOAD      s3, 0000              ; return OK
                RETURN
     commandKo: LOAD      s3, 0001              ; return KO
                RETURN

                ;---------------------------------------------------------------
                ; send NACK reply
                ;---------------------------------------------------------------
      sendNAck: LOAD      s2, 00AA              ; send header
                LOAD      s3, s2                ; prepare checksum
                CALL      uartSendByte
                LOAD      s2, s4                ; packet id
                ADD       s3, s2                ; calculate checksum
                CALL      uartSendByte
                LOAD      s2, commandNack       ; negative Acknowledge
                ADD       s3, s2                ; calculate checksum
                CALL      uartSendByte
                LOAD      s2, 0000              ; packet length: no data
                ADD       s3, s2                ; calculate checksum
                CALL      uartSendByte
                LOAD      s2, s3                ; checksum
                CALL      uartSendByte
                RETURN

                ;---------------------------------------------------------------
                ; send WRITE_MEM reply
                ;---------------------------------------------------------------
   sendWriteOk: LOAD      s2, 00AA              ; send header
                LOAD      s3, s2                ; prepare checksum
                CALL      uartSendByte
                LOAD      s2, s4                ; packet id
                ADD       s3, s2                ; calculate checksum
                CALL      uartSendByte
                LOAD      s2, s5                ; received command
                ADD       s3, s2                ; calculate checksum
                CALL      uartSendByte
                LOAD      s2, 0000              ; packet length: no data
                ADD       s3, s2                ; calculate checksum
                CALL      uartSendByte
                LOAD      s2, s3                ; checksum
                CALL      uartSendByte
                RETURN

                ;---------------------------------------------------------------
                ; send READ_MEM reply
                ;---------------------------------------------------------------
  sendReadData: LOAD      s2, 00AA              ; send header
                LOAD      s3, s2                ; prepare checksum
                CALL      uartSendByte
                LOAD      s2, s4                ; packet id
                ADD       s3, s2                ; calculate checksum
                CALL      uartSendByte
                LOAD      s2, s5                ; received command
                ADD       s3, s2                ; calculate checksum
                CALL      uartSendByte
                LOAD      s2, 0002              ; packet length: 2 bytes
                ADD       s3, s2                ; calculate checksum
                CALL      uartSendByte
                LOAD      s2, s7                ; data low
                AND       s2, 00FF              ; keep low byte only
                ADD       s3, s2                ; calculate checksum
                CALL      uartSendByte
                LOAD      s2, s7                ; data high
                CALL      shiftS2R8             ; shift MSBs down to LSBs
                ADD       s3, s2                ; calculate checksum
                CALL      uartSendByte
                LOAD      s2, s3                ; checksum
                CALL      uartSendByte
                RETURN

                ;---------------------------------------------------------------
                ; Get byte from serial port
                ;---------------------------------------------------------------
   uartGetByte: LOAD      s0, uartBaseAddress   ; read UART satus register
                ADD       s0, 01
;load s8, 0100
     checkStat: LOAD      s2, uartpollDelay     ; add delay between bus reads
        delay0: SUB       s2, 0001
                JUMP      nz, delay0
;sub s8, 0001
;jump nz, continue
;load s2, 0035
;call uartSendByte
;load s8, 0100
continue:       INPUT     s1, (s0)
                INPUT     s1, (s0)
                TEST      s1, uartDataReady     ; check "data ready" bit
                JUMP      z , checkStat         ; loop until bit is '1'
                LOAD      s0, uartBaseAddress   ; read UART data register
                INPUT     s2, (s0)
                INPUT     s2, (s0)
;LOAD s8, s2
                RETURN

                ;---------------------------------------------------------------
                ; Send byte to serial port
                ;---------------------------------------------------------------
  uartSendByte: LOAD      s0, uartBaseAddress   ; read UART satus register
                ADD       s0, uartStatusOffset
    readStatus: INPUT     s1, (s0)
                INPUT     s1, (s0)
                TEST      s1, uartSending       ; check "sending data" bit
                JUMP      z , sendByte          ; loop until bit is '1'
                LOAD      s1, uartpollDelay     ; add delay between bus reads
        delay1: SUB       s1, 0001
                JUMP      nz, delay1
                JUMP      readStatus
      sendByte: LOAD      s0, uartBaseAddress   ; write UART data register
                OUTPUT    s2, (s0)
                RETURN

                ;---------------------------------------------------------------
                ; shift s2 8 bits to the left
                ;---------------------------------------------------------------
     shiftS2L8: LOAD      s0, 8                 ; loop count
 shiftLeftLoop: SL0       s2
                SUB       s0, 0001
                JUMP      nz, shiftLeftLoop
                RETURN

                ;---------------------------------------------------------------
                ; shift s2 8 bits to the right
                ;---------------------------------------------------------------
     shiftS2R8: LOAD      s0, 8                 ; loop count
shiftRightLoop: SR0       s2
                SUB       s0, 0001
                JUMP      nz, shiftRightLoop
                RETURN

                ;===============================================================
                ; End of instruction memory
                ;===============================================================
ADDRESS 3FF
   endOfMemory: JUMP      endOfMemory
