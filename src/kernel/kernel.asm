; TODO: DEFINE GRUB multiboot header

KERNEL:

.done:
	cli
	hlt
	jmp .done
