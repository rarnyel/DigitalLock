#include P16F84A.INC    
    __config _XT_OSC & _WDT_OFF & _PWRTE_ON

;###############################################################################
;
; ToDo List:
;
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
    
locked:				; Locked loop
    movlw   B'00000000'
    movwf   num
    call    buttoncheckL	; Checks whether hash has been pressed
    movlw   B'00001100'
    subwf   num,0
    btfsc   STATUS,Z
    call    unlocking		; If hash has been pressed, go to unlocking
    movlw   B'00001011'
    subwf   num,0
    btfsc   STATUS,Z
    call    unlock
    goto    locked
    
unlocking:			; Unlocking loop
    call    buttoncheck1	; Basically adapt in the other buttoncheckX subroutines
    movfw   test1
    subwf   num,0
    btfsc   STATUS,Z		; Ideally it doesn't move beyond this point until first button pressed
    goto    unlocking		; Also ideally it doesn't use gotos but I'm not sure how else you'd do it
    call    buttoncheck2
    movfw   test2		; Repeating this bit for all the button checks
    subwf   num,0
    btfsc   STATUS,Z
    goto    unlocking
    call    buttoncheck3
    movfw   test3
    subwf   num,0
    btfsc   STATUS,Z
    goto    unlocking
    call    buttoncheck4
    movfw   test4
    subwf   num,0
    btfsc   STATUS,Z
    goto    unlocking
    call    unlockcheck
    movlw   B'00000000'
    movwf   num
    call    delay
    return

unlock:				; Subroutine for actual unlock
    movlw   B'11000111'
    movwf   PORTB
    call    delay_5sec
    return

unlockcheck:
    movfw   passcode1		; Moves actual digit to working register
    subwf   test1,0		; Subtracts saved corresponding digit from actual digit
    btsfc   STATUS,Z		; If they're the same (ie: correct) it will skip return
    call    locked		; If they're not, it locks and the whole thing starts from the beginning
    movfw   passcode2		; Repeats for the other digits
    subwf   test2,0
    btsfc   STATUS,Z
    call    locked
    movfw   passcode3
    subwf   test3,0
    btsfc   STATUS,Z
    call    locked
    movwf   passcode4
    subwf   test4
    btsfc   STATUS,Z
    call    locked
    call    unlock		; Moved from unlocking loop so that it only gets called once all number checked
    return			; Don't think this return actually needs to be here but convention and that
    
buttoncheckL:			; Checks to start unlocking loop
    movlw   B'10001111'		; Displays L for locked
    movwf   PORTB
    call    delay
    movlw   B'00000000'		; Clears num
    movwf   num
    call    doesitwork		; Checks to see what button is pressed
    movlw   B'11111111'		; Can't figure out what this line DOES
    andwf   num,0
    btfsc   STATUS,Z
    goto    buttoncheckL
    return

buttoncheckmaster:
    movlw   B'10001111'		; Should display something to signify master
    movwf   PORTB
    call    delay
    movlw   B'00000000'
    movwf   num
    call    doesitwork
    movlw   B'11111111'		; Probably need to change tbh
    andwf   num,0
    btfsc   STATUS,Z
    goto    buttoncheckmaster
    return
    
buttoncheck1:			; Subroutine for checking first button
    movlw   B'01111111'
    movwf   PORTB
    call    delay
    movlw   B'00000000'
    movwf   test1		; I dunno if these two lines are needed anymore
    call    doesitwork
    movfw   num
    movwf   test1
    movlw   B'11111111'
    andwf   test1,0
    btfsc   STATUS,Z
    goto    buttoncheck1
    return  

buttoncheck2:			; Subroutine for checking second button
    movlw   B'01111111'		;	NEEDS to be edited, as do others
    movwf   PORTB
    call    delay
    movlw   B'00000000'
    movwf   test2
    call    doesitwork
    movfw   num
    movwf   test2
    movlw   B'11111111'
    andwf   test2,0
    btfsc   STATUS,Z
    goto    buttoncheck1
    return  

buttoncheck3:
    movlw   B'01111111'
    movwf   PORTB
    call    delay
    movlw   B'00000000'
    movwf   test3
    call    doesitwork
    movfw   num
    movwf   test3  
    movlw   B'11111111'
    andwf   test3,0
    btfsc   STATUS,Z
    goto    buttoncheck1
    return  

buttoncheck4:
    movlw   B'01111111'
    movwf   PORTB
    call    delay
    movlw   B'00000000'
    movwf   test4
    call    doesitwork
    movfw   num
    movwf   test4
    movlw   B'11111111'
    andwf   test4,0
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
    call    delay
    movlw   B'00000001'
    movwf   num
    return
    
two:
    call    delay
    movlw   B'00000010'
    movwf   num
    return
    
three:
    call    delay
    movlw   B'00000011'
    movwf   num
    return
    
four:
    call    delay
    movlw   B'00000100'
    movwf   num
    return
    
five:
    call    delay
    movlw   B'00000101'
    movwf   num
    return
    
six:
    call    delay
    movlw   B'00000110'
    movwf   num
    return
    
seven:
    call    delay
    movlw   B'00000111'
    movwf   num
    return
    
eight:
    call    delay
    movlw   B'00001000'
    movwf   num
    return
    
nine:
    call    delay
    movlw   B'00001001'
    movwf   num
    return
    
zero:
    call    delay
    movlw   B'00001010'
    movwf   num
    return
    
star:
    call    delay
    movlw   B'00001011'
    movwf   num
    return
    
hash:
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
