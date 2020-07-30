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
	mov al, [HEX_CHARS + bx]
	int 0x10
	ret

HEX_CHARS: db "0123456789abcdef" 

printb:
	mov ah, 0x0e ; set flag for printing
	mov cl, 16 ; start the counter at 16 (dx has 16 bits)
	.print_loop:
		push dx ; save the number for the next iterations

		dec cl ; decrement loop counter

		shr dx, cl ; shift the current bit to the rightmost position
		and dx, 1 ; set all other bits to 0

		mov al, dl
		add al, '0' ; '0' + 0 = '0' and '0' + 1 = '1'
		int 0x10

		pop dx ; reload the stored number for the next iteration

		; check loop condition
		cmp cl, 0
		jne .print_loop

	; print carriage return and new line
	mov al, 0x0d
	int 0x10
	mov al, 0x0a
	int 0x10

	ret
