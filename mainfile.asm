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
   
;###############################################################################  
	    
RESET	CODE	0x0000  
	
    bsf STATUS,5
	movlw B'00000000'
	movwf TRISB
	movlw B'00011111'
	movwf TRISA
    bcf STATUS,5

	    
doesitwork:
    movlw B'00000010'
    movwf PORTB
    call column1
    movlw B'00000100'
    movwf PORTB
    call column2
    movlw B'00001000'
    movwf PORTB
    call column3
    call doesitwork
    
column1:
    btfsc PORTA, 0
    call one
    btfsc PORTA, 1
    call four
    btfsc PORTA, 2
    call seven
    btfsc PORTA, 3
    call star
    return
    
column2:
    btfsc PORTA, 0
    call two
    btfsc PORTA, 1
    call five
    btfsc PORTA, 2
    call eight
    btfsc PORTA, 3
    call zero
    return
    
column3:
    btfsc PORTA, 0
    call three
    btfsc PORTA, 1
    call six
    btfsc PORTA, 2
    call nine
    btfsc PORTA, 3
    call hash
    return
    
one:
    movlw B'11110011'
    movwf PORTB
    call delay
    return
    
two:
    movlw B'01001001'
    movwf PORTB
    call delay
    return
    
three:
    movlw B'01100001'
    movwf PORTB
    call delay
    return
    
four:
    movlw B'00110011'
    movwf PORTB
    call delay
    return
    
five:
    movlw B'00100101'
    movwf PORTB
    call delay
    return
    
six:
    movlw B'00000101'
    movwf PORTB
    call delay
    return
    
seven:
    movlw B'11110001'
    movwf PORTB
    call delay
    return
    
eight:
    movlw B'00000001'
    movwf PORTB
    call delay
    return
    
nine:
    movlw B'00110001'
    movwf PORTB
    call delay
    return
    
zero:
    movlw B'10000001'
    movwf PORTB
    call delay
    return
    
star:
    movlw B'00011111'
    movwf PORTB
    call delay
    return
    
hash:
    movlw B'00010011'
    movwf PORTB
    call delay
    return

delay:
    movlw H'FF'
    movwf delay0
    movlw H'FF'
    movwf delay1
delay_loop:
    decfsz delay0,F
    goto delay_loop
    decfsz delay1,F
    goto delay_loop
    return
    
    
    end
