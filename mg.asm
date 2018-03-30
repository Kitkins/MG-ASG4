   .model tiny
    .data
row      	db 80 dup(0) 
tempChar 	db 80 dup(0)
temp 		dw ?       
delayCount 	dw ?
seed 		dw ?
tempCol 	db 80 dup(0)

    .code
    org 0100h           ; for creating .com file
main:
                        ; Set text mode 80x25
    mov ah, 00h         ; Set video mode
    mov al, 03h         ; desired video mode
    int 10h

initVal:
    mov ah, 00h				; get system time 
    int 1Ah					; and it would be keep in cx:dx	

stayChar:
	call randChar
	
beginRain:
	call setColumnValue
	xor bx, bx
	call checkToPrint
	mov delayCount,15000
	call delayF
	
	xor ax, ax
	call getKB
	call deleteChecker
	call clearBuff
	
	jmp beginRain

rain:

	call setCursor      	; 'Dark grey' tail
	mov al,tempChar[bx]		; character
	mov bl, 08h         
	call printChar

	call setCursor      	; 'White' head
	mov bl, 0Fh    
	call printChar
	
	call setCursor      	; White head
	mov bl, 0Fh    
	call printChar
	
	call setCursor      	; 'Light green' body
	mov bl, 0Ah         
	call printChar

	call setCursor      	; Light green body
	mov bl, 0Ah         
	call printChar

	call setCursor      	; Light green tail
	mov bl, 0Ah         
	call printChar
	
	mov al, ' '
	mov bl, 00h 
	call printChar
	
	call setCursor      	
	mov al, ' '   
	mov bl, 00h 
	call printChar
	
	mov bx, temp
	add row[bx], 8
	cmp row[bx], 35 	; Discard characters junk, 50 is screen position
	jne return
	
	mov row[bx], 0 
	mov tempChar[bx],0
	jmp stayChar		; go to next randomChar
	
return:
	ret

plusplus:
	inc bx
	
checkToPrint:
	cmp bx,70          		; check bx must not over 80  
	je return				; if bx is 80, it would go to 'begin function' and set bx to 0
	cmp row[bx], 0
	je plusplus	
	
	mov temp, bx
	call rain
	jmp plusplus	

setColumnValue:
	call randCol
	;cmp row[bx], 0   	; Check row
	;jne setColumnValue
	inc row[bx]			; row++
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
	
	mov bx, temp
	mov tempChar[bx], al
	
	ret

randCol:
	mov ax, seed			; keep seed value from 'init function' to ax in the first time
	add seed, 50			; and the next time, using seed from the last seed of each random function
	
	xor dx, dx				; set dx to default
	mov cx, 70		
	div cx              	; divide ax(kept seed) by cx(range 0-79) and keep remainder to dx
	add dl, 10				; random 0-80
	
	mov bx, dx
	;call delayF
	ret
	
printChar:  
	mov ah, 09h
	mov cx, 1
	int 10h
	ret

delayF:
							; Delay function 
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
	mov bx,temp		    
	mov dx,temp
	
	mov tempCol[bx],dl		; keep col value to delete
	
	mov dh,row[bx]  		; dh for row
	
	dec row[bx]
	mov bh, 00h
	mov ah, 02h         	; Set cursor position       
	int 10h
	ret
	
deleteChecker:
	xor bx,bx
	loopChecker:
		cmp al,tempChar[bx]
		je setToNull
		@next:
		inc bx
		cmp bx, 70
		jne loopChecker
	mov bx, temp
	ret
	
setToNull:
	xor tempChar[bx],al
	jmp @next

getKB:
	mov ah,01h
	int 16h
	
	mov ah, 2h
	mov dh, 0
	mov dl, 79
	int 10h
	
	mov ah, 09h     	; Show a Char
	mov bh, 0h
	mov bl, 4h
	mov cx, 1			; times for showing
	int 10h
	
	ret
	
clearBuff:
	mov ah, 0Ch
	int 21h
	ret
	
    end main
