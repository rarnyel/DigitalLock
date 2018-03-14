#include P16F84A.INC    
    __config _XT_OSC & _WDT_OFF & _PWRTE_ON
;###############################################################################
;Interupt

    
;###############################################################################

master1	    EQU 0x21
master2	    EQU 0x22
master3	    EQU 0x23
master4	    EQU 0x24
passcode1   EQU 0x25
passcode2   EQU 0x26
passcode3   EQU 0x27
passcode4   EQU 0x28
test1	    EQU 0x29
test2	    EQU 0x2A
test3	    EQU 0x2B
test4	    EQU 0x2C
delay0	    EQU 0x2D
delay1	    EQU 0x2E
delay2	    EQU 0x2F
num	    EQU 0x30
	   
;###############################################################################
	    
RESET	CODE	0x0000 	   
	    
    movlw	0x04
    movwf	master1
    movlw	0x03
    movwf	master2
    movlw	0x02
    movwf	master3
    movlw	0x01
    movwf	master4
    movlw	0x01
    movwf	passcode1
    movlw	0x02
    movwf	passcode2
    movlw	0x03
    movwf	passcode3
    movlw	0x04
    movwf	passcode4
	    
;###############################################################################  
 
	
    bsf	    STATUS,5
	movlw	B'00000000'
	movwf	TRISB
	movlw	B'00011111'
	movwf	TRISA
    bcf	    STATUS,5
    
locked:
    movlw   B'00000000'
    movwf   num
    call    buttoncheckL
    movlw   B'00001100'
    subwf   num,0
    btfsc   STATUS,Z
    call    unlocking
    movlw   B'00001011'
    subwf   num,0
    btfsc   STATUS,Z
    call    unlock
    goto    locked
    
unlocking:
    call    buttoncheck1
    movfw   passcode1
    subwf   num,0
    btfsc   STATUS,Z
    call    unlock
    movlw   B'00000000'
    movwf   num
    call    delay
    return

unlock:
    movlw   B'11000111'
    movwf   PORTB
    call    delay_5sec
    return
    
buttoncheckL:
    movlw   B'10001111'
    movwf   PORTB
    call    delay
    movlw   B'00000000'
    movwf   num
    call    doesitwork
    movlw   B'11111111'
    andwf   num,0
    btfsc   STATUS,Z
    goto    buttoncheckL
    return
    
buttoncheck1:
    movlw   B'01111111'
    movwf   PORTB
    call    delay
    movlw   B'00000000'
    movwf   num
    call    doesitwork
    movlw   B'11111111'
    andwf   num,0
    btfsc   STATUS,Z
    goto    buttoncheck1
    return  
	    
doesitwork:
    movlw   B'00000010'
    movwf   PORTB
    call    column1
    movlw   B'00000100'
    movwf   PORTB
    call    column2
    movlw   B'00001000'
    movwf   PORTB
    call    column3
    return
    
column1:
    btfsc   PORTA, 0
    call    one
    btfsc   PORTA, 1
    call    four
    btfsc   PORTA, 2
    call    seven
    btfsc   PORTA, 3
    call    star
    return
    
column2:
    btfsc   PORTA, 0
    call    two
    btfsc   PORTA, 1
    call    five
    btfsc   PORTA, 2
    call    eight
    btfsc   PORTA, 3
    call    zero
    return
    
column3:
    btfsc   PORTA, 0
    call    three
    btfsc   PORTA, 1
    call    six
    btfsc   PORTA, 2
    call    nine
    btfsc   PORTA, 3
    call    hash
    return
    
one:
    movlw   B'11110011'
    movwf   PORTB
    call    delay
    movlw   B'00000001'
    movwf   num
    return
    
two:
    movlw   B'01001001'
    movwf   PORTB
    call    delay
    movlw   B'00000010'
    movwf   num
    return
    
three:
    movlw   B'01100001'
    movwf   PORTB
    call    delay
    movlw   B'00000011'
    movwf   num
    return
    
four:
    movlw   B'00110011'
    movwf   PORTB
    call    delay
    movlw   B'00000100'
    movwf   num
    return
    
five:
    movlw   B'00100101'
    movwf   PORTB
    call    delay
    movlw   B'00000101'
    movwf   num
    return
    
six:
    movlw   B'00000101'
    movwf   PORTB
    call    delay
    movlw   B'00000110'
    movwf   num
    return
    
seven:
    movlw   B'11110001'
    movwf   PORTB
    call    delay
    movlw   B'00000111'
    movwf   num
    return
    
eight:
    movlw   B'00000001'
    movwf   PORTB
    call    delay
    movlw   B'00001000'
    movwf   num
    return
    
nine:
    movlw   B'00110001'
    movwf   PORTB
    call    delay
    movlw   B'00001001'
    movwf   num
    return
    
zero:
    movlw   B'10000001'
    movwf   PORTB
    call    delay
    movlw   B'00001010'
    movwf   num
    return
    
star:
    movlw   B'00011111'
    movwf   PORTB
    call    delay
    movlw   B'00001011'
    movwf   num
    return
    
hash:
    movlw   B'00010011'
    movwf   PORTB
    call    delay
    movlw   B'00001100'
    movwf   num
    return

delay:
    movlw   H'FF'
    movwf   delay0
    movlw   H'FF'
    movwf   delay1
delay_loop:
    decfsz  delay0,F
    goto    delay_loop
    decfsz  delay1,F
    goto    delay_loop
    return
    
delay_5sec:
    movlw   H'FF'
    movwf   delay0
    movlw   H'FF'
    movwf   delay1 
    movlw   H'10'
    movwf   delay2
delay_loop5:
    decfsz  delay0,F
    goto    delay_loop5
    decfsz  delay1,F
    goto    delay_loop5
    decfsz  delay2,F
    goto    delay_loop5
    return
    
    
    end
