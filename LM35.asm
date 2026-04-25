.include "m16def.inc"      ; Include definition file for ATmega16

; LCD control pins (adjust if necessary)
.equ LCD_RS = 0           ; LCD RS pin on PortD bit 0
.equ LCD_RW = 1           ; LCD RW pin on PortD bit 1
.equ LCD_EN = 2           ; LCD EN pin on PortD bit 2
.equ LCD_D4 = 4           ; LCD D4 pin on PortD bit 4
.equ LCD_D5 = 5           ; LCD D5 pin on PortD bit 5
.equ LCD_D6 = 6           ; LCD D6 pin on PortD bit 6
.equ LCD_D7 = 7           ; LCD D7 pin on PortD bit 7

; ADC reference voltage type
.equ ADC_VREF_TYPE = (1<<REFS1) | (1<<REFS0)  ; 2.56V internal reference

; Start program
.org 0x00                ; Reset vector
    rjmp INIT            ; Jump to initialization

; ADC Interrupt Service Routine (ISR)
.org 0x1E               ; ISR vector for ADC
ADC_ISR:
    ; Read ADC result (ADCW = ADCL + ADCH)
    in R16, ADCL         ; Read low byte (ADCL)
    in R17, ADCH         ; Read high byte (ADCH)
    
    ; Combine ADCL and ADCH into adc_data (16-bit value)
    ; adc_data = (ADCH << 8) | ADCL
    ; adc_data is now in R16 (low byte) and R17 (high byte)
    
    ; Calculate temp = (adc_data * 2.56 / 1024) / 0.01
    ; Simplified approach (no floating point math):
    ; We calculate (adc_data * 256) / 1024 = adc_data / 4
    ; Assuming R16:R17 is adc_data

	lsr R17				 ; 0000 0011   0000 0000
						 ; 0000 0001   0000 0000  Carry = 1	
						 ; 0000 0001   1000 0000  Carry = 0		
	ror R16              ; Divide by 2
    lsr R17
	ror R16              ; Divide by 4  0000 0000 1100 0000

	mov R20, R16
    ; After 2 left shifts, we have adc_data / 4 in R20

    ; Store result in temp (R20) (simulating float by using integer math)
    ; Convert R20 to ASCII to display on LCD (R20 is temp)

    ; LCD Display (simulating sprintf)
    ; Clear LCD
    call LCD_Clear

    ; Convert R20 to ASCII and display it (this is a simplified approach)
    call LCD_Print

    ; Re-enable ADC interrupt for next conversion
    sei                  ; Enable global interrupts
	sbi ADCSRA, ADSC	 ; start next convertion
    reti                 ; Return from interrupt

; Main Program Setup
INIT:
    ; Set up ADC
    ldi R16, ADC_VREF_TYPE  ; Load ADC reference type
    out ADMUX, R16           ; Set the ADC reference to 2.56V internal
    ldi R16, (1<<ADEN) | (1<<ADIE)  ; Enable ADC and interrupt 
    out ADCSRA, R16          ; Enable ADC with interrupt ;1011 0100
														 ;0000 1000
    
    ; Set up LCD (you need a suitable initialization procedure)
    ; For now, assume it’s initialized elsewhere or a placeholder function call
    call LCD_Init            ; Call LCD initialization function
    
    ; Start ADC conversion
    sbi ADCSRA, ADSC          ; Start the ADC conversion
    
    ; Enable global interrupts
    sei                      ; Enable global interrupts
    
    ; Infinite loop (after setup, continue with ADC interrupt-driven updates)
loop:
    rjmp loop                ; Infinite loop (ISR will handle updates)

; LCD Functions
LCD_Init:
    ; Set PORTD(of atmega16) as output
    ldi R16, 0xFF
    out DDRD, R16

    ; Initial delay after power-up
    rcall LCD_LongDelay

    ; Function set (send 0x30 three times in 8-bit mode first)
    ldi R16, 0x03  
    rcall LCD_SendNibble
    rcall LCD_LongDelay

    rcall LCD_SendNibble
    rcall LCD_LongDelay

    rcall LCD_SendNibble
    rcall LCD_LongDelay

    ; Switch to 4-bit mode
    ldi R16, 0x02
    rcall LCD_SendNibble
    rcall LCD_LongDelay

    ; Function set: 4-bit, 2-line, 5x8 dots
    ldi R16, 0x28			; 0010 1000
    rcall LCD_SendCommand

    ; Display ON, Cursor OFF, Blink OFF
    ldi R16, 0x0C			;0000 1100
    rcall LCD_SendCommand

    ; Entry mode: Increment cursor, no shift
    ldi R16, 0x06
    rcall LCD_SendCommand

    ; Clear display
    rcall LCD_Clear
    ret

LCD_Clear:
    ldi R16, 0x01
    rcall LCD_SendCommand
    rcall LCD_LongDelay     ; Clearing takes time
    ret

LCD_Print:
    ; --- Step 1: Print "TEMP = " ---
    ldi ZH, high(TEMP_STR << 1)
    ldi ZL, low(TEMP_STR << 1)

PrintLoop:
    lpm R16, Z+            ; Load one character from flash into R16
    cpi R16, 0             ; If it's 0 (null terminator)...
    breq PrintNumber       ; ...stop and go print the number
    rcall LCD_SendChar     ; Send char to LCD
    rjmp PrintLoop

; --- Step 2: Convert R20 (value) to ASCII and print it ---	; 234
PrintNumber:
    mov R21, R20         ; Copy temp value
    clr R22              ; Hundreds
    clr R23              ; Tens
    clr R24              ; Units

    ; Divide by 100
HundredsLoop:		;R21 = 234 --> 134 --> 34
    cpi R21, 100
    brlo TensLoop
    subi R21, 100
    inc R22  ; 1 --> 2
    rjmp HundredsLoop

TensLoop:       ;R21 = 34 24 14 4
    cpi R21, 10
    brlo UnitsDone
    subi R21, 10
    inc R23 ; 1  2  3 
    rjmp TensLoop

UnitsDone:
    mov R24, R21         ; R24 = units

    ; Convert digits to ASCII
    ldi R30, '0'
    add R22, R30
    add R23, R30
    add R24, R30

    ; Send digits
    mov R16, R22
    rcall LCD_SendChar
    mov R16, R23
    rcall LCD_SendChar
    mov R16, R24
    rcall LCD_SendChar
    ret

LCD_SendChar:
    sbi PORTD, LCD_RS       ; RS = 1 (data)
    cbi PORTD, LCD_RW       ; RW = 0 (write)
    mov R17, R16            ; Copy char to R17

    ; Send high nibble
	swap R16
    rcall LCD_SendNibble

    ; Send low nibble
    mov R16, R17
    rcall LCD_SendNibble

    rcall LCD_Delay
    ret

LCD_SendCommand:
    cbi PORTD, LCD_RS       ; RS = 0 (command)
    cbi PORTD, LCD_RW       ; RW = 0 (write)
    mov R17, R16            ; Copy command to R17

    ; Send high nibble
	swap R16
    rcall LCD_SendNibble

    ; Send low nibble
    mov R16, R17
    rcall LCD_SendNibble

    rcall LCD_LongDelay
    ret

LCD_SendNibble:
    ; R16 = nibble (lower 4 bits), shift to upper bits (D4-D7)
    swap R16                ; 0000 1011 --> 1011 0000
    andi R16, 0xF0          ; Clear lower 4 bits  ; 1111 0000
    
    ; Clear upper nibble in PORTD
    in R17, PORTD
    andi R17, 0x0F			; 0000 1111
    or R17, R16             ; Merge new nibble
    out PORTD, R17

    rcall LCD_PulseEN
    ret

LCD_PulseEN:
    sbi PORTD, LCD_EN       ; EN = 1
    rcall LCD_Delay
    cbi PORTD, LCD_EN       ; EN = 0
    rcall LCD_Delay
    ret

LCD_Delay:
    ldi R18, 50
DelayLoop:
    dec R18
    brne DelayLoop
    ret

LCD_LongDelay:
    ldi R19, 100
DelayLongLoop:
    dec R19
    brne DelayLongLoop
    rcall LCD_Delay
    ret

.org 0x200
TEMP_STR:
    .db "TEMP = ", 0

; End of Program