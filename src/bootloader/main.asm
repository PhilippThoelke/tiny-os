org 0x7c00
bits 16

; read the second sector
mov cl, 2
mov bx, 0x7c00 + 512
call readSector

; read the third sector
mov cl, 3
mov bx, 0x7c00 + 1024 
call readSector

call enableA20 ; enable the A20 line to access more then 1MB of memory

; continue execution in the second sector
jmp Sector2

; a label where the CPU halts forever
halt:
	cli
	hlt
	jmp halt

; includes
%include "src/bootloader/print.asm"
%include "src/bootloader/disk.asm"
%include "src/bootloader/gdt.asm"

; strings
ReadingSectorMsg: db "Reading sector from drive...", 0
ReadSectorErr: db "Failed to read sector from the drive. Halting...", 0

SuccessMsg: db "success", 0x0d, 0x0a, 0
FailedMsg: db "failed", 0x0d, 0x0a, 0

EnablingA20Msg: db "Enabling the A20 line if it is disabled...", 0
noA20Err: db "Failed to enable the A20 line. Halting...", 0

EnablingLongModeMsg: db "Enabling long mode...", 0

; padding and magic number
times 510-($-$$) db 0
dw 0xaa55

Sector2:

call checkForCPUID ; check if the CPUID instruction is available, halt otherwise
call checkForLongMode ; check if long mode is available, halt otherwise
call enableLongMode ; put the CPU into long mode
call switchToProtected ; set up PAE paging and switch to protected mode

jmp GDT.Code:LongMode

; strings
CheckingCPUIDMsg: db "Checking if the CPUID instruction is available...", 0
NoCPUIDErr: db "The CPUID instruction is not available. Halting...", 0

CheckingLongModeMsg: db "Checking if long mode is available...", 0
NoLongModeErr: db "Long mode is not available. Halting...", 0
SwitchToPModeMsg: db "Setting up PAE paging and switching to protected mode.", 0x0d, 0x0a, "BIOS prints are no longer possible.", 0

; includes
%include "src/bootloader/a20.asm"

; pad the second sector to 512 bytes
times 2*512-($-$$) db 0

; includes
%include "src/bootloader/pmode.asm"
%include "src/bootloader/longmode.asm"

bits 64
LongMode:
; TODO: find the kernel and jump to its main function

call halt

; pad the third sector to 512 bytes
times 3*512-($-$$) db 0
