checkForCPUID:
	mov si, CheckingCPUIDMsg
	call prints

	pushfd ; save EFLAGS

	; move EFLAGS into eax
	pushfd
	pop eax
	
	push eax ; store the EFLAGS for later comparison
	xor eax, 0x00200000 ; flip the ID bit
	
	; pop the modified EFLAGS into the EFLAGS register
	push eax
	popfd
	
	pop eax ; restore the original EFLAGS to eax
	
	; move the EFLAGS to ebx
	pushfd
	pop ebx

	; check if the ID bit was modified in the EFLAGS register
	; if yes, then the CPUID instruction is supported, otherwise CPUID is not available
	xor eax, ebx
	cmp eax, 0
	je .no_CPUID

	popfd ; restore original EFLAGS
	mov si, SuccessMsg
	call prints
	ret

.no_CPUID:
	mov si, FailedMsg
	call prints
	mov si, NoCPUIDErr
	call prints
	jmp $
