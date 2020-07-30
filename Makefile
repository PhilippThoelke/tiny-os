main:src/bootloader/main.asm src/bootloader/print.asm src/bootloader/disk.asm src/bootloader/a20.asm
	mkdir -p bin
	nasm -fbin src/bootloader/main.asm -o bin/main.bin

clean:
	rm -rf bin
	rm -rf iso
	rm -f floppy.img
	rm -f tinyos.iso

iso:main
	dd if=/dev/zero of=floppy.img bs=1024 count=1440
	dd if=bin/main.bin of=floppy.img seek=0 conv=notrunc
	mkdir iso
	cp floppy.img iso/
	mkisofs -V 'TINYOS' -input-charset iso8859-1 -o tinyos.iso -b floppy.img iso/
	rm floppy.img
	rm -rf iso

run:iso
	qemu-system-x86_64 -cdrom tinyos.iso
