####################################################
####### compile the bootloader and kernel ##########
####################################################

build/main.bin : src/bootloader/main.asm src/bootloader/print.asm src/bootloader/disk.asm src/bootloader/a20.asm src/bootloader/longmode.asm src/bootloader/pmode.asm src/bootloader/gdt.asm src/kernel/kernel.asm
	mkdir -p build
	nasm -fbin src/bootloader/main.asm -o build/main.bin

build/kernel.bin : src/kernel/kernel.asm
	mkdir -p build
	nasm -fbin src/kernel/kernel.asm -o build/kernel.bin

####################################################
############### run the os #########################
####################################################

.PHONY : run
run : build/tinyos.iso
	qemu-system-x86_64 -cdrom build/tinyos.iso

.PHONY : runvm
runvm : vm
	vboxmanage startvm "TinyOS"

.PHONY : grub-runvm
grub-runvm : grub-vm
	vboxmanage startvm "TinyOS-GRUB"

####################################################
############### clean the environment ##############
####################################################

.PHONY : clean
clean :
	rm -rf build

.PHONY : cleanvm
cleanvm :
	if vboxmanage list vms | grep -q "\"TinyOS\""; then \
		vboxmanage unregistervm "TinyOS" --delete; \
	fi; \
	if vboxmanage list vms | grep -q "\"TinyOS-GRUB\""; then \
		vboxmanage unregistervm "TinyOS-GRUB" --delete; \
	fi;

.PHONY : cleanall
cleanall : clean cleanvm

####################################################
############### build an ISO file ##################
####################################################

.PHONY : iso
iso : build/tinyos.iso

build/tinyos.iso : build/main.bin
	mkdir build/iso
	dd if=/dev/zero of=build/iso/floppy.img bs=1024 count=1440
	dd if=build/main.bin of=build/iso/floppy.img seek=0 conv=notrunc
	mkisofs -V 'TINYOS' -input-charset iso8859-1 -o build/tinyos.iso -b floppy.img build/iso/
	rm -rf build/iso

.PHONY : grub-iso
grub-iso : build/tinyos-grub.iso

build/tinyos-grub.iso : build/kernel.bin
	rm -rf build/iso
	mkdir -p build/iso/boot/grub
	cp build/kernel.bin build/iso/boot/kernel.bin
	cp grub.cfg build/iso/boot/grub/grub.cfg
	grub-mkrescue -o build/tinyos-grub.iso build/iso
	rm -rf build/iso

####################################################
############### create a VirtualBox VM #############
####################################################

.PHONY : vm
vm : build/tinyos.iso
	if ! vboxmanage list vms | grep -q "\"TinyOS\""; then \
		vboxmanage createvm --name "TinyOS" --register; \
		vboxmanage storagectl "TinyOS" --name "IDE" --add ide; \
		vboxmanage storageattach "TinyOS" --storagectl "IDE" --port 0 --device 0 --type dvddrive --medium build/tinyos.iso; \
	fi

.PHONY : grub-vm
grub-vm : build/tinyos-grub.iso
	if ! vboxmanage list vms | grep -q "\"TinyOS-GRUB\""; then \
		vboxmanage createvm --name "TinyOS-GRUB" --register; \
		vboxmanage storagectl "TinyOS-GRUB" --name "IDE" --add ide; \
		vboxmanage storageattach "TinyOS-GRUB" --storagectl "IDE" --port 0 --device 0 --type dvddrive --medium build/tinyos-grub.iso; \
	fi
