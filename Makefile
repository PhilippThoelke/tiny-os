build/main.bin : src/bootloader/main.asm src/bootloader/print.asm src/bootloader/disk.asm src/bootloader/a20.asm src/bootloader/longmode.asm src/bootloader/pmode.asm src/bootloader/gdt.asm src/kernel/kernel.asm
	mkdir -p build
	nasm -fbin src/bootloader/main.asm -o build/main.bin

.PHONY : cleanall
cleanall : clean cleanvm

.PHONY : clean
clean :
	rm -rf build

.PHONY : iso
iso : build/tinyos.iso

build/tinyos.iso : build/main.bin
	mkdir build/iso
	dd if=/dev/zero of=build/iso/floppy.img bs=1024 count=1440
	dd if=build/main.bin of=build/iso/floppy.img seek=0 conv=notrunc
	mkisofs -V 'TINYOS' -input-charset iso8859-1 -o build/tinyos.iso -b floppy.img build/iso/
	rm -rf build/iso

.PHONY : run
run : build/tinyos.iso
	qemu-system-x86_64 -cdrom build/tinyos.iso

.PHONY : vm
vm : build/tinyos.iso
	if ! vboxmanage list vms | grep -q "TinyOS"; then \
		vboxmanage createvm --name "TinyOS" --register; \
		vboxmanage storagectl "TinyOS" --name "IDE" --add ide; \
		vboxmanage storageattach "TinyOS" --storagectl "IDE" --port 0 --device 0 --type dvddrive --medium build/tinyos.iso; \
	fi

.PHONY : runvm
runvm : vm
	vboxmanage startvm "TinyOS"

.PHONY : cleanvm
cleanvm :
	if vboxmanage list vms | grep -q "TinyOS"; then \
		vboxmanage unregistervm "TinyOS" --delete; \
	fi
