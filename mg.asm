   .model tiny
    .data
row      	db 80 dup(?) 
tempChar 	db 80 dup(0)
temp 		dw ?       
delayCount 	dw ?
seed 		dw ?
nLife		db '9'
tempRow		db ?

lifeMSG	db "Life : $",0
str1 db " _____ _                            _        _       $"
str2 db "|_   _| |                          | |      (_)      $"
str3 db "  | | | |__   ___   _ __ ___   __ _| |_ _ __ _ __  __ $"
str4 db "  | | | '_ \ / _ \ | '_ ` _ \ / _` | __| '__| |\ \/ / $"
str5 db "  | | | | | |  __/ | | | | | | (_| | |_| |  | | >  <  $"
str6 db "  \_/ |_| |_|\___| |_| |_| |_|\__,_|\__|_|  |_|/_/\_\ $",0 

str7 db "select level(hold number1-3)$",0
str8 db "1.easy $",0
str9 db "2.medium $",0
str10 db "3.hard $",0

str11 db "  ________                        ________                     $"
str12 db " /  _____/_____    _____   ____   \_____  \___  __ ___________ $"
str13 db "/   \  ___\__  \  /     \_/ __ \   /   |   \  \/ // __ \_  __ \$"
str14 db "\    \_\  \/ __ \|  Y Y  \  ___/  /    |    \   /\  ___/|  | \/$"
str15 db " \______  (____  /__|_|  /\___  > \_______  /\_/  \___  >__|   $"
str16 db "        \/     \/      \/     \/          \/          \/       $",0 
str17 db ">>> Press any key to exit <<<$",0 


;key db ?

    .code
    org 0100h           ; for creating .com file
main:
                        ; Set text mode 80x25
    mov ah, 00h         ; Set video mode
    mov al, 03h         ; desired video mode
    int 10h
	
	call printstart

waitz:       
	call getKB
	
	cmp al,'1'
	je @delayEasy 
	cmp al,'2'
	je @delayMedium
	cmp al,'3'
	je @delayHard
	
	call clearBuff
	call hideBlink
	
	jmp waitz

@delayEasy:
	call clearScreen
	call printlifeMSG
	mov delayCount,12000
	jmp stayChar
	
@delayMedium:
	call clearScreen
	call printlifeMSG
	mov delayCount,8000
	jmp stayChar
	
@delayHard:
	call clearScreen
	call printlifeMSG
	mov delayCount,4000
	jmp stayChar

clearScreen:
	mov   ah, 6h
	mov   al, 0h       ; clear whole screen
	mov   bh, 7h
	mov   cx, 0h
	mov   dx, 184fh
	int   10h
	ret
	
stayChar:
	call randChar
	
beginRain:
	call setColumnValue
	xor bx, bx
	call checkToPrint
	call delayF
	
	xor ax, ax
	call getKB
	call deleteChecker
	call clearBuff
	call print_nLife
	call hideBlink
	jmp beginRain

rain:

	call setCursor      	; 'Dark grey' tail
	
	cmp tempChar[bx], 33	; check right character range?
	jl @nextRain
	cmp tempChar[bx], 126
	jg @nextRain
	
	cmp tempRow,24
	je minus_nLife
	jmp @nextRain
	
	minus_nLife:
	call print_nLife
	dec nLife
	cmp nLife,'0'
	jl @dumbJMP
	
	@nextRain:
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
	;mov tempChar[bx],0
	jmp stayChar		; go to next randomChar
	
return:
	ret

@dumbJMP:
	jmp @dumbJMP2
	
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
	mov ah, 2Ch				; get system time 
    int 21h					; ch = hour, cl = min, dh = sec , dl = 1/sec
	mov ax, dx			
	add ax, seed			
	
	xor cx, cx				
	xor dx, dx
	mov cl, 94		
	sub cl, '!'
	
	div cx              	
	add dl, '!'
	
	mov ax,dx				; keep dx(random value) to ax(using to print char) 	
	mov seed,ax				; keep ax to seed for using to be init value in the next random function
	
	mov bx, temp
	mov tempChar[bx], al
	
	ret

randCol:
	mov ah, 2Ch				; get system time 
    int 21h					; ch = hour, cl = min, dh = sec , dl = 1/sec
	mov ax, dx			
	add ax, seed			
	
	xor cx, cx				
	xor dx, dx
	mov cl, 70		
	sub cl, 10
	
	div cx              	
	add dl, 10				
	
	mov bx, dx
	;call delayF
	ret
	
printChar:  
	mov ah, 09h
	mov cx, 1
	int 10h
	ret

delayF:
	mov si, delayCount						; Delay function 
	mov cx, 1500
delay:
	nop
	dec cx
	loop delay
	mov cx, 50
	dec si
	cmp si, 0
	jne delay
	ret 

setCursor:
	mov bx,temp		    
	mov dx,temp	
	mov dh,row[bx]  		; dh for row
	
	mov tempRow,dh
	
	dec row[bx]
	mov bh, 00h
	mov ah, 02h         	; Set cursor position       
	int 10h
	ret

print_nLife:
	mov ah, 2h
	mov dh, 24
	mov dl, 79
	int 10h
	
	mov ah, 09h     	; Show a Char
	mov al, nLife
	mov bh, 0h
	mov bl, 0Fh
	mov cx, 1			; times for showing
	int 10h
	ret
	
deleteChecker:
	xor bx,bx
	loopChecker:
		cmp al,tempChar[bx]
		je setToNull
		cmp al, 27				; check press ESC?
		je @dumbJMP2
		@nextDeleteChecker:
		inc bx
		cmp bx, 70
		jne loopChecker
	mov bx, temp
	ret
	
setToNull:
	xor tempChar[bx],al
	jmp @nextDeleteChecker

getKB:
	mov ah,01h
	int 16h
	ret
	
clearBuff:
	mov ah, 0Ch
	int 21h
	ret

@dumbJMP2:
	jmp doExit
	
printstart:              ;need al as char ascii parameter
    mov ah,02h
    mov bl,0Ch
	mov bh,00h
	mov dh,4
	mov dl,12
	int 10h

	mov ah, 09h 
    mov dx, offset str1
    int 21h


    mov ah,02h
    mov bl,0Ch
	mov bh,00h
	mov dh,5
	mov dl,12
	int 10h

	mov ah, 09h
    mov dx, offset str2
    int 21h
    mov ah,02h
    mov bl,0Ch
	mov bh,00h
	mov dh,6
	mov dl,12
	int 10h

	mov ah, 09h
    mov dx, offset str3
    int 21h
    mov ah,02h
    mov bl,0Ch
	mov bh,00h
	mov dh,7
	mov dl,12
	int 10h

	mov ah, 09h
    mov dx, offset str4
    int 21h
    mov ah,02h
    mov bl,0Ch
	mov bh,00h
	mov dh,8
	mov dl,12
	int 10h

	mov ah, 09h
    mov dx, offset str5
    int 21h
    mov ah,02h
    mov bl,0Ch
	mov bh,00h
	mov dh,9
	mov dl,12
	int 10h

	mov ah, 09h
    mov dx, offset str6
    int 21h
    mov ah,02h
    mov bl,0Ch
	mov bh,00h
	mov dh,15
	mov dl,22
	int 10h

	mov ah, 09h
    mov dx, offset str7
    int 21h  
    
    mov ah,02h
    mov bl,0Ch
	mov bh,00h
	mov dh,17
	mov dl,22
	int 10h

	mov ah, 09h
    mov dx, offset str8
    int 21h
    mov ah,02h
    mov bl,0Ch
	mov bh,00h
	mov dh,19
	mov dl,22
	int 10h

	mov ah, 09h
    mov dx, offset str9
    int 21h
    mov ah,02h
    mov bl,0Ch
	mov bh,00h
	mov dh,21
	mov dl,22
	int 10h

	mov ah, 09h
    mov dx, offset str10
    int 21h   
    
    mov ah,02h
    mov bl,0Ch 
	mov bh,00h
	mov dh,22
	mov dl,22
	int 10h

	ret

doExit:
	call clearScreen
	call printending
	int 20h

printending:
	mov ah,02h
    mov bl,0Bh
	mov bh,00h
	mov dh,8
	mov dl,8
	int 10h

	mov ah, 09h 
    mov dx, offset str11
    int 21h


    mov ah,02h
    mov bl,0Bh
	mov bh,00h
	mov dh,9
	mov dl,8
	int 10h

	mov ah, 09h
    mov dx, offset str12
    int 21h
    mov ah,02h
    mov bl,0Bh
	mov bh,00h
	mov dh,10
	mov dl,8
	int 10h

	mov ah, 09h
    mov dx, offset str13
    int 21h
    mov ah,02h
    mov bl,0Bh
	mov bh,00h
	mov dh,11
	mov dl,8
	int 10h

	mov ah, 09h
    mov dx, offset str14
    int 21h
    mov ah,02h
    mov bl,0Bh
	mov bh,00h
	mov dh,12
	mov dl,8
	int 10h

	mov ah, 09h
    mov dx, offset str15
    int 21h
    mov ah,02h
    mov bl,0Bh
	mov bh,00h
	mov dh,13
	mov dl,8
	int 10h

	mov ah, 09h
    mov dx, offset str16
    int 21h
	
	mov ah,02h
    mov bl,0Bh
	mov bh,00h
	mov dh,20
	mov dl,25
	int 10h

	mov ah, 09h
    mov dx, offset str17
    int 21h
	
	call clearBuff
	
	waitPress:
	mov ah, 0Bh         ; Press any key to exit
	int 21h
	cmp al, 00h
	jz waitPress
	
	ret

hideBlink:
	mov ch, 32
    mov ah, 1
    int 10h
	ret

printlifeMSG:
	mov ah,02h
    mov bl,0Fh
	mov bh,00h
	mov dh,24
	mov dl,72
	int 10h

	mov ah, 09h
    mov dx, offset lifeMSG
    int 21h
	ret
    end main
