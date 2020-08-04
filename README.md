# Tiny OS
A tiny operating system and bootloader for learning purposes. Currently, only a bootloader exists, which transitions the CPU to long mode and sets everything up for loading the kernel.

The bootloader code can be found in [src/bootloader/](https://github.com/PhilippThoelke/tiny-os/tree/master/src/bootloader).

The bootloader is written in x86 assembly, which can be assembled using [nasm](https://www.nasm.us/). The bootloader can be run in the [QEMU emulator](https://www.qemu.org/).
