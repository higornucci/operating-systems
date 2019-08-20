# bootblock.s

# .equ symbol, expression
# These directive set the value of the symbol to the expression
    .equ    BOOT_SEGMENT,0x07c0
    .equ    DISPLAY_SEGMENT,0xb800
    #set the stack point to 0xFFFF
    #which refers to the memory map at http://wiki.osdev.org/Memory_Map_(x86)
    .equ    STACK_ADD_SP,0xffff
    .equ    STACK_ADD_SS,0x0
    .equ    KERNEL_ADD,0x1000

.text               # Code segment
.globl    _start    # The entry point must be global
.code16             # Real mode


#
# The first instruction to execute in a program is called the entry
# point. The linker expects to find the entry point in the "symbol" _start
# (with underscore).
#

_start:
    jmp     over
os_size:
    # Area reserved for createimage to write the OS size
    .word   0
    .word   0

    # This is where the bootloader goes
over:
    #set stack
    movw    $STACK_ADD_SS,%ax
    movw    %ax,%ss
    movw    $STACK_ADD_SP,%sp

    #print message
    movw    $BOOTSTRING1, %si 
    call    print_string

    movw    $BOOTSTRING2, %si 
    call    print_string

    #load kernel to 0x1000
    #accordding to the createimage's output,the kernel is at sector 2-10(1 based), the size is 9 sectors
    #more details about int 0x13: http://en.wikipedia.org/wiki/INT_13H#INT_13h_AH.3D00h:_Reset_Disk_Drive

    #reset disk drive
    movb    $0x0, %ah
    #drive number 1st hard disk
    movb    $0x80, %dl
    int     $0x13

    #read 9 sectors
    movb    $0x09, %al
    #read from 2nd sector
    movb    $0x02, %cl
    #head number
    movb    $0x0,  %dh
    #drive number
    movb    $0x80,  %dl
    #es:bx = pointer where to palce information read from disk
    movw    $0x0,  %bx
    movw    %bx,   %es
    movw    $0x1000,%bx
    
    movb    $0x2,%ah
    int $0x13

    #setup ds
    movw    $0x0, %ax
    movw    %ax, %ds
    #jump to kernel
    movw    $KERNEL_ADD,%ax
    jmp     %ax

forever: 
    # Loop forever
    hlt
    jmp     forever

print_string:
    pushw   %es
    pushw   %ax
    pushw   %bx
    pushw   %cx
    pushw   %dx

    movw    $DISPLAY_SEGMENT, %bx
    movw    %bx, %es
    movw    $BOOT_SEGMENT, %bx
    movw    %bx, %ds

    #set the color mode
    movb    $0x1f, %ah
    xorw    %bx,%bx
    cld

    
    lodsb
    cmpb    $0x0, %al
    jz      print_end
print_loop1:
    #write data to video memory
    movw    %ax, %es:(%bx)
    #see detail in reference about lodsb intruction
    lodsb
    #every item is 2 byte
    inc    %bx
    inc    %bx
    cmpb    $0x0, %al
    jnz     print_loop1 

print_end:
    popw %dx
    popw %cx
    popw %bx
    popw %ax
    popw %es
    ret

BOOTSTRING1:
.asciz "Bootloader Starting\0xA"

BOOTSTRING2:
.asciz "Kernel Loading\0xA"
