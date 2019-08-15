# Author(s): <Your name here>
# bootloader
# TODO: Comment on the status of your submission. Largely unimplemented

# .equ symbol, expression
# These directive set the value of the symbol to the expression
# memory constants
.equ  BOOT_SEGMENT,0x7c0
# more memory constants...
.equ  KERNEL_SEGMENT,0x100
	
# utility constants
.equ  DISK_READ,0x02
# more utility constants...

.text               #Code segment
.globl    _start    #The entry point must be global
.code16             #Real mode

#
# The first instruction to execute in a program is called the entry
# point. The linker expects to find the entry point in the "symbol" _start
# (with underscore).
#

_start:
	jmp load_kernel

# Area reserved for createimage to write the OS size
os_size:
	.word   0
	.word   0

# setup registers for kernel data and disk read	
load_kernel:
	# try to print a character on start
	movb	$0x0e,%ah
	movb	$'S',%al
	movb	$0x00,%bh
	movb	$0x02,%bl
	int	$0x10
	xchg	%bx,%bx	# this is a magic breakpoint
	
# setup the kernel stack
setup_stack:	

# switch control to kernel
switch_to_kernel:
	
end_of_boot:
	nop
