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
	je .NoCPUID

	popfd ; restore original EFLAGS
	mov si, SuccessMsg
	call prints
	ret

.NoCPUID:
	mov si, FailedMsg
	call prints
	mov si, NoCPUIDErr
	call prints
	jmp halt

checkForLongMode:
	mov si, CheckingLongModeMsg
	call prints

	; check if extended CPUID features (> 0x80000000) are available
	mov eax, 0x80000000
	cpuid
	cmp eax, 0x80000001
	jb .NoLongMode

	; check if the LM bit (29th) is set after calling CPUID with eax=0x80000001
	mov eax, 0x80000001
	cpuid
	test edx, 1 << 29
	jz .NoLongMode

	; long mode is available
	mov si, SuccessMsg
	call prints
	ret

.NoLongMode:
	mov si, FailedMsg
	call prints
	mov si, NoLongModeErr
	call prints
	jmp halt

enableLongMode:
	mov si, EnablingLongModeMsg
	call prints

	; enter long mode by setting the 9th bit in the model-specific register to 1
	mov ecx, 0xc0000080
	rdmsr
	or eax, 1 << 8
	wrmsr

	mov si, SuccessMsg
	call prints
	ret
