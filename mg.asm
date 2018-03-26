   .model tiny
    .data
row      	db 80 dup(0) 
tempChar 	db ?
temp 		dw 0h       
delayCount 	dw ?
seed 		dw ?
ending		dw ?
    .code
    org 0100h           ; for creating .com file
main:
                        ; Set text mode 80x25
    mov ah, 00h         ; Set video mode
    mov al, 03h         ; desired video mode
    int 10h

stayChar:
	call randChar
begin:
	;call randCol
	call checkToPrint
	call delayF
	jmp begin

rain:
	;call randChar
	mov al,tempChar
	call setCursor
    call printChar

	call setCursor
    call printChar

	call setCursor
    call printChar

	call setCursor
    call printChar
	
    mov al, ' '
	call printChar
    
	add row[bx], 5
	cmp row[bx], 29  	; Discard characters junk, 50 is screen position
    jne return
	
    mov row[bx], 0  
	jmp stayChar
	
return:
	ret

plusplus:
	inc bx
	
checkToPrint:
    cmp row[bx], 0
	je plusplus	
	call rain
	
	ret

randChar:
	mov ax, seed			; keep seed from the last seed of each random function
    add seed, 35			; and add it by appropriate value that make random char is not too close in ascii order
	
    xor dx, dx				; set dx to default
    mov cx, 94		
    div cx              	; divide ax(kept seed) by cx(range 33-126) and keep remainder to dx
    add dl, '!'        	 	; make begining value to random
	
    mov ax,dx				; keep dx(random value) to ax(using to print char) 	
	mov seed,ax				; keep ax to seed for using to be init value in the next random function
	mov tempChar, al
	ret

randCol:
	mov ax, seed			; keep seed value from 'init function' to ax in the first time
	add seed, 23			; and the next time, using seed from the last seed of each random function
	
	xor dx, dx				; set dx to default
	mov cx, 80		
	div cx              	; divide ax(kept seed) by cx(range 0-79) and keep remainder to dx
							; random 0-80	
	mov temp, dx
	mov bx, dx
	
	;call delayF
	
	ret
	
printChar:  
    mov ah, 09h
    mov bl, 0Ah
    mov cx, 1
    int 10h
	ret

delayF:
    mov delayCount, 5000	; Delay function 
    mov cx, 1500
delay:
    nop
    dec cx
    loop delay
    mov cx, 50
    dec delayCount
    cmp delayCount, 0
    jne delay
    ret 

setCursor:
	mov ah, 02h         	; Set cursor position       
	mov dh, row[bx]  		; dh for row
    mov dl, byte ptr temp 	; dl for column
	dec row[bx]
	;mov bh, 00h
    int 10h
	ret

doExit:
	ret
	
    end main