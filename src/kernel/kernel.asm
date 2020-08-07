MBALIGN equ 1 << 0
MEMINFO equ 1 << 1
FLAGS equ MBALIGN | MEMINFO
MAGIC equ 0x1BADB002
CHECKSUM equ -(MAGIC + FLAGS)

section .multiboot
align 4
dd MAGIC
dd FLAGS
dd CHECKSUM

section .bss
align 16
stack_bottom:
resb 16384 ; 16 KiB
stack_top:

section .text
global _start:function (_start.end - _start)
_start:
	mov esp, stack_top

	mov rax, 0x8f658f4b
	mov [VID_MEM], rax

	mov rax, 0x8f6c8f658f6e8f72
	mov [VID_MEM+4], rax

	cli
	.hang:
		hlt
		jmp .hang
	.end:

VID_MEM equ 0xb8000
mov edi, VID_MEM
mov rax, 0x8f208f208f208f20
mov ecx, 500
rep stosq

