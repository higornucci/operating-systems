# operating-systems
Códigos dos trabalhos da disciplina de doutorado de Sistemas Operacionais

1. BootLoader;

> $ as -o boot.o boot.s

> $ ld -o boot.bin --oformat binary -e _iniciar -Ttext 0x7c00 -o boot.bin boot.o

> $ qemu-system-x86_64 boot.bin


2. non-preemptive kernel;
3. preemptive kernel;
4. interprocess communication and device driver;
5. virtual memory;
6. file system.
