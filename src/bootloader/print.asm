prints:
	mov ah, 0x0e ; set flag for printing

	.loop:
	mov al, [si]
	or al, 0
	jz .exit ; found a 0 byte, exit

	int 0x10 ; call print interrupt
	inc si ; go to next byte
	jmp .loop

	.exit:
	ret

printh:
	mov ah, 0x0e ; set flag for printing

	; print '0x' prefix
	mov al, '0'
	int 0x10
	mov al, 'x'
	int 0x10

	; print first 4 bits
	mov bx, dx
	and bx, 0xf000
	shr bx, 12
	call .printbits

	; print second 4 bits
	mov bx, dx
    and bx, 0x0f00
	shr bx, 8
    call .printbits

	; print third 4 bits
	mov bx, dx
    and bx, 0x00f0
	shr bx, 4
    call .printbits

	; print fourth 4 bits
	mov bx, dx
    and bx, 0x000f
    call .printbits

	; print carriage return and new line
	mov al, 0x0d
	int 0x10
	mov al, 0x0a
	int 0x10

	ret
	
.printbits:
	; print 4 bits
	mov al, [CHARS + bx]
	int 0x10
	ret

CHARS: db "0123456789abcdef" 
