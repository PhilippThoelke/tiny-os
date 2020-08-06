readSector:
	; reads one sector from a drive and writes it to memory address 0000:bx
	; assumes bx (address offset) and cl (sector index) to be set
	mov si, ReadingSectorMsg
	call prints

	mov al, 1 ; number of sectors to read
	mov ch, 0 ; cylinder
	mov dh, 0 ; head
	mov dl, 0x0 ; drive type (0x0 for floppy)
	
	; set the es register to 0
	push bx
	xor bx, bx
	mov es, bx
	pop bx

	mov ah, 0x02 ; set flag for reading from a drive
	int 0x13 ; call interrupt to read from the drive

	jc .fail
	mov si, SuccessMsg
	call prints
	ret

	.fail:
		; failed to read from the drive and halt forever
		mov si, FailedMsg
		call prints
		mov si, ReadSectorErr
		call prints
		jmp halt
