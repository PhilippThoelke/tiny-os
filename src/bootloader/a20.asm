checkA20:
	; ============ check the first location ============
	; reference value of magic number 0xaa55
	mov ax, [0x7c00+510]

	; get the number in memory 1MB over
	mov bx, 0xffff
	mov es, bx
	mov dx, [es:0x7e0e]

	; compare the number to the reference
	cmp ax, dx
	je .fail

	; ============ check a second location ============
	; reference value one byte after start of magic number
	mov ax, [0x7c00+511]

	; get the number in memory one 1MB over
	mov bx, 0xffff
	mov es, bx
	mov dx, [es:0x7e0f]

	; compare the number to the reference
	cmp ax, dx
	je .fail

	; A20 most likely enabled, return 0 in ax
	mov ax, 0
	ret

	.fail:
		; A20 most likely disabled, return 1 in ax
		mov ax, 1
		ret

enableA20:
	mov si, EnablingA20Msg
	call prints

	; check if the A20 line is activated
	call checkA20
	cmp ax, 0
	je .A20Success

	; try enabling the A20 line using a BIOS interrupt
	mov si, biosEnableA20Msg
	call prints
	call biosEnableA20

	; check if the A20 line is activated
	call checkA20
	cmp ax, 0
	je .A20Success

	mov si, FailedMsg
	call prints

	; try enabling the A20 line using the keyboard controller
	mov si, keyboardEnableA20Msg
	call prints
	call keyboardEnableA20

	; check if the A20 line is activated
	call checkA20
	cmp ax, 0
	je .A20Success

	mov si, FailedMsg
	call prints

	; try enabling the A20 line using the FastA20 method
	mov si, fastEnableA20Msg
	call prints
	call fastEnableA20

	; check if the A20 line is activated
	call checkA20
	cmp ax, 0
	je .A20Success

	mov si, FailedMsg
	call prints

	; failed to enable the A20 line, halt forever
	mov si, noA20Err
	call prints
	jmp $

	.A20Success:
		mov si, SuccessMsg
		call prints
		ret ; successfuly activated the A20 line

biosEnableA20:
	mov ax, 0x2401
	int 0x15
	ret

keyboardEnableA20:
	cli

	; disable the keyboad
	call .WaitController
	mov al, 0xad
	out 0x64, al

	; set the controller into read mode
	call .WaitController
	mov al, 0xd0
	out 0x64, al

	; read data from the controller
	call .WaitData
	in al, 0x60
	push ax
	
	; set the controller into write mode
	call .WaitController
	mov al, 0xd1
	out 0x64, al

	; write the previously read data to the controller and set the second bit to 1
	call .WaitController
	pop ax
	or al, 2
	out 0x60, al

	; enable the keyboard again
	call .WaitController
	mov al, 0xae
	out 0x64, al

	sti
	ret

	.WaitController:
		; wait for the keyboard controller to accept commands
		in al, 0x64 ; get the controller's status
		test al, 2 ; bit 2 = 1 -> busy, bit 2 = 0 -> ready
		jnz .WaitController
		ret

	.WaitData:
		; wait for the keyboard controller to have data ready
		in al, 0x64 ; get the controller's status
		test al, 1 ; bit 1 = 1 -> full, bit 1 = 0 -> empty
		jz .WaitData
		ret

fastEnableA20:
	; set the second bit of the chipset port 0x92 to one
	in al, 0x92
	or al, 2
	out 0x92, al
	ret
