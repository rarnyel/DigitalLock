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
newcode1    EQU	0x31
newcode2    EQU 0x32
newcode3    EQU 0x33
newcode4    EQU 0x34
un	    EQU	0x35
lockout	    EQU	0x36
beepL	    EQU	0x37
	   
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
    movlw	B'00000001'
    movwf	passcode1
    movlw	B'00000010'
    movwf	passcode2
    movlw	B'00000011'
    movwf	passcode3
    movlw	B'00000100'
    movwf	passcode4
    movlw	0x03
    movwf	lockout
	    
;###############################################################################  
	
    bsf	    STATUS,5
	movlw	B'00000000'
	movwf	TRISB
	movlw	B'00011110'
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
    call    mastering
    goto    locked
    
unlocking:			; Unlocking loop
    call    buttoncheck1	; Basically adapt in the other buttoncheckX subroutines
    movfw   num
    movwf   test1		; Also ideally it doesn't use gotos but I'm not sure how else you'd do it
    call    buttoncheck2
    movfw   num
    movwf   test2		; Repeating this bit for all the button checks
    call    buttoncheck3
    movfw   num
    movwf   test3
    call    buttoncheck4
    movfw   num
    movwf   test4
    call    unlockcheck
    movlw   B'00000000'
    movwf   num
    return
    
mastering:			
    call    buttoncheck1	
    movfw   num
    movwf   test1		
    call    buttoncheck2
    movfw   num
    movwf   test2		
    call    buttoncheck3
    movfw   num
    movwf   test3
    call    buttoncheck4
    movfw   num
    movwf   test4
    call    mastercheck
    movlw   B'00000000'
    movwf   num
    call    buttoncheckmaster	; Checks whether hash has been pressed
    movlw   B'00001100'
    subwf   num,0
    btfss   STATUS,Z
    goto    not			; If hash has not been pressed, go to locked
    call    buttoncheck1	
    movfw   num
    movwf   newcode1		
    call    buttoncheck2
    movfw   num
    movwf   newcode2		
    call    buttoncheck3
    movfw   num
    movwf   newcode3
    call    buttoncheck4
    movfw   num
    movwf   newcode4
    movlw   B'00000000'
    movwf   num
    call    buttoncheckmaster	; Checks whether hash has been pressed
    movlw   B'00001100'
    subwf   num,0
    btfss   STATUS,Z
    goto    not		; If hash has not been pressed, go to locked
    call    buttoncheck1	
    movfw   num
    movwf   test1		
    call    buttoncheck2
    movfw   num
    movwf   test2		
    call    buttoncheck3
    movfw   num
    movwf   test3
    call    buttoncheck4
    movfw   num
    movwf   test4
    call    testcheck
    movlw   B'00000000'
    movwf   num
    return    

unlock:			; Subroutine for actual unlock
    movlw   B'00000011'
    movwf   lockout
    movlw   B'00001010'
    movwf   un
unlocklooop:
    movlw   B'11000111'
    movwf   PORTB
    call    delay_0.25sec
    movlw   B'11111111'
    movwf   PORTB
    call    delay_0.25sec
    decfsz  un,F
    goto    unlocklooop
    return
    
not:
    movlw   B'01010111'
    movwf   PORTB
    call    delay_1sec
    movlw   B'10000001'
    movwf   PORTB
    call    delay_1sec
    movlw   B'00001111'
    movwf   PORTB
    call    delay_1sec
    goto    locked
    return
    
s_et:
    movlw   B'00100101'
    movwf   PORTB
    call    delay_1sec
    movlw   B'00001101'
    movwf   PORTB
    call    delay_1sec
    movlw   B'00001111'
    movwf   PORTB
    call    delay_1sec
    return

lockout_func:
    decfsz  lockout,f
    goto    locked
    call    delay_20sec
    movlw   0x03
    movwf   lockout
    return
    
unlockcheck:
    movfw   passcode1		; Moves actual digit to working register
    subwf   test1,0		; Subtracts saved corresponding digit from actual digit
    btfss   STATUS,Z		; If they're the same (ie: correct) it will skip return
    goto    lockout_func	; If they're not, it locks and the whole thing starts from the beginning
    movfw   passcode2		; Repeats for the other digits
    subwf   test2,0
    btfss   STATUS,Z
    goto    lockout_func
    movfw   passcode3
    subwf   test3,0
    btfss   STATUS,Z
    goto    lockout_func
    movfw   passcode4
    subwf   test4,0
    btfss   STATUS,Z
    goto    lockout_func
    call    unlock		; Moved from unlocking loop so that it only gets called once all number checked
    return
    
mastercheck:
    movfw   master1		; Moves actual digit to working register
    subwf   test1,0		; Subtracts saved corresponding digit from actual digit
    btfss   STATUS,Z		; If they're the same (ie: correct) it will skip return
    goto    not		; If they're not, it locks and the whole thing starts from the beginning
    movfw   master2		; Repeats for the other digits
    subwf   test2,0
    btfss   STATUS,Z
    goto    not
    movfw   master3
    subwf   test3,0
    btfss   STATUS,Z
    goto    not
    movfw   master4
    subwf   test4,0
    btfss   STATUS,Z
    goto    not
    return
    
testcheck:
    movfw   newcode1		; Moves actual digit to working register
    subwf   test1,0		; Subtracts saved corresponding digit from actual digit
    btfss   STATUS,Z		; If they're the same (ie: correct) it will skip return
    goto    not			; If they're not, it locks and the whole thing starts from the beginning
    movfw   newcode2		; Repeats for the other digits
    subwf   test2,0
    btfss   STATUS,Z
    goto    not
    movfw   newcode3
    subwf   test3,0
    btfss   STATUS,Z
    goto    not
    movfw   newcode4
    subwf   test4,0
    btfss   STATUS,Z
    goto    not
    movfw   newcode1
    movwf   passcode1		
    movfw   newcode2
    movwf   passcode2		
    movfw   newcode3
    movwf   passcode3		
    movfw   newcode4
    movwf   passcode4
    call    s_et
    return
    
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
    movlw   B'10001101'		; Should display something to signify master
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
    movwf   num		; I dunno if these two lines are needed anymore
    call    doesitwork
    movlw   B'11111111'
    andwf   num,0
    btfsc   STATUS,Z
    goto    buttoncheck1
    return  

buttoncheck2:			; Subroutine for checking second button
    movlw   B'00111111'		;	NEEDS to be edited, as do others
    movwf   PORTB
    call    delay
    movlw   B'00000000'
    movwf   num
    call    doesitwork
    movlw   B'11111111'
    andwf   num,0
    btfsc   STATUS,Z
    goto    buttoncheck2
    return  

buttoncheck3:
    movlw   B'00111101'
    movwf   PORTB
    call    delay
    movlw   B'00000000'
    movwf   num
    call    doesitwork 
    movlw   B'11111111'
    andwf   num,0
    btfsc   STATUS,Z
    goto    buttoncheck3
    return  

buttoncheck4:
    movlw   B'00111001'
    movwf   PORTB
    call    delay
    movlw   B'00000000'
    movwf   num
    call    doesitwork
    movlw   B'11111111'
    andwf   num,0
    btfsc   STATUS,Z
    goto    buttoncheck4
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
    btfsc   PORTA, 1
    call    one
    btfsc   PORTA, 2
    call    four
    btfsc   PORTA, 3
    call    seven
    btfsc   PORTA, 4
    call    star
    return
    
column2:
    btfsc   PORTA, 1
    call    two
    btfsc   PORTA, 2
    call    five
    btfsc   PORTA, 3
    call    eight
    btfsc   PORTA, 4
    call    zero
    return
    
column3:
    btfsc   PORTA, 1
    call    three
    btfsc   PORTA, 2
    call    six
    btfsc   PORTA, 3
    call    nine
    btfsc   PORTA, 4
    call    hash
    return
    
one:
    call    delay
    call    beepstart
    movlw   B'00000001'
    movwf   num
    return
    
two:
    call    delay
    call    beepstart
    movlw   B'00000010'
    movwf   num
    return
    
three:
    call    delay
    call    beepstart
    movlw   B'00000011'
    movwf   num
    return
    
four:
    call    delay
    call    beepstart
    movlw   B'00000100'
    movwf   num
    return
    
five:
    call    delay
    call    beepstart
    movlw   B'00000101'
    movwf   num
    return
    
six:
    call    delay
    call    beepstart
    movlw   B'00000110'
    movwf   num
    return
    
seven:
    call    delay
    call    beepstart
    movlw   B'00000111'
    movwf   num
    return
    
eight:
    call    delay
    call    beepstart
    movlw   B'00001000'
    movwf   num
    return
    
nine:
    call    delay
    call    beepstart
    movlw   B'00001001'
    movwf   num
    return
    
zero:
    call    delay
    call    beepstart
    movlw   B'00001010'
    movwf   num
    return
    
star:
    call    delay
    call    beepstart
    movlw   B'00001011'
    movwf   num
    return
    
hash:
    call    delay
    call    beepstart
    movlw   B'00001100'
    movwf   num
    return

delay:
    movlw   H'FF'
    movwf   delay0
    movlw   H'A0'
    movwf   delay1
delay_loop:
    decfsz  delay0,F
    goto    delay_loop
    decfsz  delay1,F
    goto    delay_loop
    return

beepstart:
    movlw   H'FF'
    movwf   beepL
loop:    
    bsf	    PORTA,0
    call    delay_beep
    bcf	    PORTA,0
    call    delay_beep
    decfsz  beepL,f
    goto loop
    return
    
delay_beep:
    movlw   H'59'
    movwf   delay0
delay_beepL:
    decfsz  delay0,F
    goto    delay_beepL
    return
    
delay_0.25sec:
    movlw   H'FF'
    movwf   delay0
    movlw   H'52'
    movwf   delay1 
    movlw   H'02'
    movwf   delay2
delay_loop5:
    decfsz  delay0,F
    goto    delay_loop5
    decfsz  delay1,F
    goto    delay_loop5
    decfsz  delay2,F
    goto    delay_loop5
    return
    
delay_1sec:
    movlw   H'FF'
    movwf   delay0
    movlw   H'FF'
    movwf   delay1 
    movlw   H'02'
    movwf   delay2
delay_loop1:
    decfsz  delay0,F
    goto    delay_loop1
    decfsz  delay1,F
    goto    delay_loop1
    decfsz  delay2,F
    goto    delay_loop1
    return
    
delay_20sec:
    movlw   H'FF'
    movwf   delay0
    movlw   H'FF'
    movwf   delay1 
    movlw   H'34'
    movwf   delay2
delay_loop20:
    decfsz  delay0,F
    goto    delay_loop20
    decfsz  delay1,F
    goto    delay_loop20
    decfsz  delay2,F
    goto    delay_loop20
    return
    
    end