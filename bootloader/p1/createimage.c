/* createimage.c -- create a bootable image in 16 real mode from several elf file
 */
#include <stdio.h>
#include <stdlib.h>
#include "createimage.h"

int file_process(FILE *elf_file, FILE *image, char *elf_filename);
long byte_get (unsigned char *field, int size);

int main (int argc, char ** argv)
{
    //here hasn't check the magic numbers of elf
    if (argc != 3) {
        printf("USAGE:%s bootblock kernel\n", argv[0]);
        return -1;
    } 
    FILE *bootblock, *kernel, *image;
    if ((bootblock = fopen (argv[1], "rb")) == NULL) {
        printf("can't open %s\n", argv[1]);
        return -1;
    }
    if ((image = fopen ("image", "wb")) == NULL) {
        printf("can't open image!\n");
        return -1;
    }
    if (file_process(bootblock, image, argv[1])) {
        printf("process bootblock failed\n");
        return -1;
    }
        
    if ((kernel = fopen (argv[2], "rb")) == NULL) {
        printf("can't open %s\n", argv[2]);
        return -1;
    }
    if (file_process(kernel, image, argv[2])) {
        printf("process kernel failed\n");
        return -1;
    }

    fclose(bootblock);
    fclose(kernel);
    fclose(image);

    return 0;
}

long byte_get (unsigned char *field, int size)
{
    switch (size)
    {
        case 1:
            return *field;

        case 2:
            return  ((unsigned int) (field[0])) | (((unsigned int) (field[1])) << 8);
        case 4:
            return  ((unsigned long) (field[0]))
                |    (((unsigned long) (field[1])) << 8)
                |    (((unsigned long) (field[2])) << 16)
                |    (((unsigned long) (field[3])) << 24);
        default:
            printf("byte_get error\n");
            return -1;
    }
}


/* read information from elf file, and write LOAD segment to image file 
 *
 * note: the structure in file is not aligned, we just read it from file byte
 * by byte
 */
int file_process(FILE *elf_file, FILE *image, char *elf_filename)
{
    unsigned int header_sz, pheader_sz;
    unsigned long phoff;
    unsigned int p_offset;
    unsigned int p_filesz;
    unsigned int p_memsz;
    elf_header header;
    elf_program_header pheader;

    header_sz = sizeof (elf_header);
    pheader_sz = sizeof(elf_program_header);

    printf("processing %s:\n", elf_filename);
    printf("header size is: %d\n", header_sz);
    printf("program header size is: %d\n", pheader_sz);

    if (header_sz != fread(&header, 1, header_sz, elf_file)) {
        printf("read error!\n");
        return -1;
    }

    //get program header's offset
    phoff = byte_get(header.e_phoff, sizeof(header.e_phoff));

    printf("Program header table offset in file is :\t %u\n", phoff);

    if (fseek(elf_file, phoff, SEEK_SET)) {
        printf("fseek %s failed! at line %d\n", elf_filename, __LINE__);
        return -1;
    }
    //printf("the current position: %d\n", ftell(elf_file));

    if (pheader_sz != fread(&pheader, 1, pheader_sz, elf_file)) {
        printf("read error at line %d!\n", __LINE__);
        return -1;
    }
    //get the LOAD segment's offset, filesz, mensz
    p_offset = byte_get(pheader.p_offset, sizeof(pheader.p_offset));
    p_filesz = byte_get(pheader.p_filesz, sizeof(pheader.p_filesz));
    p_memsz = byte_get(pheader.p_memsz, sizeof(pheader.p_memsz));
    printf("p_offset: 0x%x\tp_filesz: 0x%x\tp_memsz: 0x%x\t\n", p_offset, p_filesz, p_memsz);
    //write elf's LOAD segment to image, and pad to 512 bytes(1 sector)
    char *buffer;
    const unsigned int sector_sz = 512;
    const char MBR_signature[] = {0x55, 0xaa};
    unsigned int n_sector;
    unsigned int n_byte;

    if (p_memsz % sector_sz != 0)
        n_sector = p_memsz / sector_sz + 1;
    else
        n_sector = p_memsz / sector_sz;

    n_byte = n_sector * sector_sz;

    if (!(buffer = (char *)calloc(n_byte, sizeof(char)))) {
        printf("malloc buffer failed! at line %d\n", __LINE__);
        return -1;
    }
    if (fseek(elf_file, p_offset, SEEK_SET)) {
        printf("fseek %s failed! at line %d\n", elf_filename, __LINE__);
        return -1;
    }
    if (p_filesz != fread(buffer, 1, p_filesz, elf_file)) {
        printf("read error at line %d!\n", __LINE__);
        return -1;
    }
    if (n_byte != fwrite(buffer, 1, n_byte, image)) {
        printf("write error at line %d!\n", __LINE__);
        return -1;
    }
    //write MBR signature to image, which is 2 bytes
    if (fseek(image, 510, SEEK_SET)) {
        printf("fseek %s failed! at line %d\n", elf_filename, __LINE__);
        return -1;
    }
    if (2 != fwrite(MBR_signature, 1, 2, image)) {
        printf("write error at line %d!\n", __LINE__);
        return -1;
    }

    printf("write image:\n%d sectors,\t%d bytes\n", n_sector, n_byte);
     
    return 0;
}
