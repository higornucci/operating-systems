.code16 # avisa o assembler que usaremos o modo 16 bit
.global _start # coloca a variável _start disponível fora do programa

_start:
  mov $0x0e41, %ax # atribui AH para 0xe (função teletype) e al para 0x41 (ASCII "A")
  int $0x10 # chama a função em ah da interrupção 0x10
  hlt # para a execução

.fill 510-(.-_start), 1, 0 # adiciona zeros para deixar o arquivo com tamanho de 510 bytes
.word 0xaa55 # bytes que avisam a BIOS que esse código é bootável that tell BIOS that this is bootable

