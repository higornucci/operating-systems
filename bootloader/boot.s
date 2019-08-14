.code16
.global _start

_start:
  ljmpw $0xFFFF, $0

.fill 510-(.-_start), 1, 0
.word 0xaa55
