main.bin:src/bootloader/main.asm src/bootloader/print.asm src/bootloader/disk.asm src/bootloader/a20.asm
	mkdir -p bin
	nasm -fbin src/bootloader/main.asm -o bin/main.bin

clean:
	rm -rf bin

run:
	qemu-system-x86_64 -drive file=bin/main.bin,format=raw
