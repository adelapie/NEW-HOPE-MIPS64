
.text
.globl montgomery_reduce
.globl barrett_reduce

.ent montgomery_reduce

montgomery_reduce:
  li $t0, 12287 /* qinv */
  mul $v0,$a0,$t0 
  ld $t0, rlog_shift_minus_1
  and $v0,$v0,$t0
  addu $a0,$a0,$v0
  srl $v0, $a0,18
  jr $ra
.end montgomery_reduce

rlog_shift_minus_1:
    .quad   262143

.ent barrett_reduce

barrett_reduce:
  li $t0,5
  mul $v0,$a0,$t0
  srl $v0,$v0,16
  li $t0, 12289 /* NEWHOPE_Q */
  mul $v0,$v0,$t0
  subu $v0,$a0,$v0
  jr $ra
.end barrett_reduce

