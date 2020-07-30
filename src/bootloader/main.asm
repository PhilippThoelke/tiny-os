org 0x7c00
bits 16

; read the second sector from the drive to the address after the bootloader
mov cl, 2
mov bx, 0x7c00 + 512
call readSector

; continue execution in the second sector
jmp Sector2

; includes
%include "src/bootloader/print.asm"
%include "src/bootloader/disk.asm"
%include "src/bootloader/a20.asm"

; strings
ReadingSectorMsg: db "Reading sector from a drive...", 0
ReadSectorErr: db "Failed to read a sector from the drive. Halting...", 0

SuccessMsg: db "success", 0x0d, 0x0a, 0
FailedMsg: db "failed", 0x0d, 0x0a, 0

; padding and magic number
times 510-($-$$) db 0
dw 0xaa55

Sector2:

call enableA20 ; enable the A20 line to access more then 1MB of memory

call checkForCPUID ; check if the CPUID instruction is available, halt otherwise

jmp $

%include "src/bootloader/cpuid.asm"

; strings
EnablingA20Msg: db "Checking if the A20 line is enabled...", 0
biosEnableA20Msg: db "Trying to enable the A20 line using a BIOS interrupt...", 0
keyboardEnableA20Msg: db "Trying to enable the A20 line using the keyboard controller...", 0
fastEnableA20Msg: db "Trying to enable the A20 line using the FastA20 chipset method...", 0
noA20Err: db "Failed to enable the A20 line. Halting...", 0

CheckingCPUIDMsg: db "Checking if the CPUID instruction is available...", 0
NoCPUIDErr: db "The CPUID instruction is not available. Halting...", 0

; pad the second sector to 512 bytes
times 512-($-$$)+512 db 0
