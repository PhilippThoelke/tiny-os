# Tiny OS
A tiny operating system and bootloader for learning purposes. Currently, only a bootloader exists, which transitions the CPU to long mode and sets everything up for loading the kernel.

The bootloader code can be found in [src/bootloader/](https://github.com/PhilippThoelke/tiny-os/tree/master/src/bootloader) while the kernel is located at [src/kernel/](https://github.com/PhilippThoelke/tiny-os/tree/master/src/kernel).

## Bootloader
The bootloader starts off by loading the second and third sector from disk into memory in order to have all of the code in memory. This is done via the `readSector` function, which loads the sector with the index (index starts counting at 1) given by the cl register into the address stored in bx. The second sector (index 2) is loaded to address `0x7c00+512`, which is right behind the first bootloader sector, since the BIOS loads the first sector of a bootable disk (a disk where the last two bytes in the first sector are `0xaa` and `0x55`) to address `0x7c00`. The third sector is stored at address `0x7c00+1024`, right behind the second sector.

After loading the whole bootloader into memory, it continues by enabling the A20 line via the `enableA20` function. The A20 line is the 21st bit in the address bus of the computer's memory. In some BIOSes the A20 line is disabled when execution is passed to the bootloader. Therefore `enableA20` checks if the A20 line is already enabled by accessing bytes 1MiB apart and checking if their values are the same. If the bytes are the same, this suggests that the A20 line is disabled and we accessed the same byte twice. When the A20 line is disabled, addresses larger than `0xFFFFF` (20 enabled bits) are wrapped around back to 0. This is done to keep backwards compatibility to the older 8086 processor. The `enabledA20` function goes through three different approaches to enable the A20 line and checks for success after each approach. Depending on the system, some approaches might not work. First, it tries to enable the A20 line using a BIOS interrupt, after that using the keyboard controller and finally with the FastA20 method, which uses the chipset port. If none of the methods work, the bootloader halts and displays an error message.

As soon as the A20 line is enabled, the bootloader will start the process of switching to protected mode and then long mode. In order to switch to these modes, CPUID instructions are necessary. Therefore, the bootloader first checks if CPUID instructions are available. If not, the system does not support long mode and the bootloader halts and displays an error message. If CPUID instructions are available, the bootloader similarly checks if long mode is available on the CPU. After verifying that the CPU supports long mode, the bootloader enables it by setting 9th bit of the model-specific register to 1. After enabling long mode, protected mode is set up by first enabling paging and mapping some memory pages using a series of tables. Then, the global descriptor table is loaded into the global descriptor table register, which defines how the memory is organized and for example determines executability and writability. Finally, the CPU is switched to protected mode by setting the first bit of control register 0 to 1.

As a last step, the bootloader performs a jump to the `LongMode` label where it should look for the kernel on disk, load it into memory and pass execution to it.

The bootloader can be compiled with NASM:
```bash
nasm -fbin src/bootloader/main.asm -o main.bin
```
We can then use QEMU to emulate a system and run the bootloader code:
```bash
qemu-system-x86_64 -drive file=main.bin,format=raw,if=floppy
```
The Makefile additionally supports generating an ISO image file, creating and running a ready-to-use VirtualBox virtual machine with this bootloader and linking the the kernel with the GRUB bootloader instead of the custom one.
