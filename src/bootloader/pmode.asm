setUpPaging:
	; clear some memory (4096 * 4 bytes) from 0x1000 on for the paging tables
	mov edi, 0x1000 ; destination address
	mov cr3, edi ; control register 3 should contain the start address of the tables
	mov ecx, 4096 ; write four zero bytes 4096 times
	xor eax, eax ; fill the memory with zeros
	rep stosd ; write the zeros
	
	; PML4T -> 0x1000
	; PDPT  -> 0x2000
	; PDT   -> 0x3000
	; PT    -> 0x4000

	; make PML4T[0] point to PDPT at 0x2000
	mov edi, cr3 ; set edi back to the start address of PML4T
	mov dword [edi], 0x2003

	; make PDPT[0] point to PDT at 0x3000
	add edi, 0x1000
	mov dword [edi], 0x3003

	; make PDT[0] point to PT at 0x4000
	add edi, 0x1000
	mov dword [edi], 0x4003

	; enable memory pages and identity map 2MB
	mov dword ebx, 3 ; enable the first two bits, meaning the page is present and read/write
	mov ecx, 512 ; repeat for 512 PT entries (512 * 4KB page size = 2MB)
	add edi, 0x1000 ; set the destination index to the first entry in PT
	
	; fill the first 512 PT entries with a loop
	.SetPage:
		mov dword [edi], ebx
		add ebx, 0x1000 ; add 4096 to the address
		add edi, 8
		loop .SetPage

	; enable PAE paging in control register 4
	mov eax, cr4
	or eax, 1 << 5 ; enable the PAE bit (bit 6)
	mov cr4, eax

	ret

switchToProtected:
	mov si, SwitchToPModeMsg
	call prints

	cli
	; set up paging for long mode
	call setUpPaging

	; load the global decriptor table
	lgdt [GDT.Pointer]

	; enable paging and switch to protected mode
	mov eax, cr0
	or eax, 1 << 31 ; enable paging
	or eax, 1 ; switch to protected mode
	mov cr0, eax

	ret
