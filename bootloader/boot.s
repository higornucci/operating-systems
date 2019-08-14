.code16 # avisa o assembler que usaremos o modo 16 bit
.global _iniciar # coloca a variável _iniciar disponível fora do programa

_iniciar:
  mov $msg, %si # carrega o endereço de $msg para si
  mov $0xe, %ah   # carrega 0xe (número da função de interrupição 0x10) para ah
imprimir_char:
  lodsb # carrega o byte do endereço em si para al e incrementa si
  cmp $0, %al # compara o conteúdo em AL com zero
  je finalizar # se al == 0, vá para "finalizar"
  int $0x10 # imprime o char em al para a tela
  jmp imprimir_char # move para o próximo byte
finalizar:
  hlt # para a execução

msg: .asciz "SO carregado!" # armazena a string (mais um byte com valor "0") e nos da acesso via $msg

.fill 510-(.-_iniciar), 1, 0 # adiciona zeros para deixar o arquivo com tamanho de 510 bytes
.word 0xaa55 # bytes que avisam a BIOS que esse código é bootável that tell BIOS that this is bootable

