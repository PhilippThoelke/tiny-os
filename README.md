# Tiny OS
A tiny operating system and bootloader for learning purposes. Currently, only a bootloader exists, which enables the [A20 line](https://wiki.osdev.org/A20_Line) and checks for the [CPUID instruction](https://wiki.osdev.org/CPUID).

The bootloader is written in x86 assembly, which can be assembled using [nasm](https://www.nasm.us/). The bootloader can be run in the [QEMU emulator](https://www.qemu.org/).
