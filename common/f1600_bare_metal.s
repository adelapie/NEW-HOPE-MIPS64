
#Keccak f-1600 for MIPS64, big-endian, barebone (k0,k1)
 
.text
.globl f1600
.ent f1600

.macro CHI_BLOCK VAL_0 VAL_1 VAL_2 VAL_3 VAL_4
  /* scratch: a0, a1 */

  move $a0, \VAL_0 
  move $k0, \VAL_1

  not $a1, \VAL_1
  and $a1, $a1, \VAL_2
  xor \VAL_0, \VAL_0, $a1

  not $a1, \VAL_2
  and $a1, $a1, \VAL_3
  xor \VAL_1, \VAL_1, $a1

  not $a1, \VAL_3
  and $a1, $a1, \VAL_4
  xor \VAL_2, \VAL_2, $a1

  not $a1, \VAL_4
  and $a1, $a1, $a0
  xor \VAL_3, \VAL_3, $a1

  not $a0, $a0
  and $a0, $a0, $k0 
  xor \VAL_4, \VAL_4, $a0
.endm

.macro APPLY_ROUND_CONSTANT TMP DST CONSTANT
  ld \TMP, \CONSTANT 
  xor \DST, \DST, \TMP
.endm

.macro GEN_D DST REG_0 REG_1
  drol \DST,\REG_0,1
  xor \DST,\DST,\REG_1
.endm

.macro DO_BC DST REG_0 REG_1 REG_2 REG_3 REG_4
  xor \DST,\REG_0,\REG_1
  xor \DST,\DST,\REG_2
  xor \DST,\DST,\REG_3
  xor \DST,\DST,\REG_4
.endm

.macro PREPARE_STACK
  daddiu $sp,$sp,-160
  sd $s0,72($sp)
  sd $s1,80($sp)
  sd $s2,88($sp)
  sd $s3,96($sp)
  sd $s4,104($sp)
  sd $s5,112($sp)
  sd $s6,120($sp)
  sd $s7,128($sp)
  sd $s8,136($sp)
  sd $ra,144($sp)
  sd $gp,152($sp)
.endm

.macro RESTORE_STACK
  ld $gp,152($sp)
  ld $ra,144($sp)
  ld $s8,136($sp)
  ld $s7,128($sp)
  ld $s6,120($sp)
  ld $s5,112($sp)
  ld $s4,104($sp)
  ld $s3,96($sp)
  ld $s2,88($sp)
  ld $s1,80($sp)
  ld $s0,72($sp)
  daddiu $sp,$sp,160
.endm

.macro LOAD_STATE
  ld $s0,0($a0) #Aba, 1
  ld $t4,8($a0) #Abe, 2
  ld $v0,16($a0) #Abi, 3
  ld $s6,24($a0) #Abo, 4
  ld $t0,32($a0) #Abu, 5
  ld $a3,40($a0) #Aga, 6
  ld $s2,48($a0) #Age, 7
  ld $t7,56($a0) #Agi, 8
  ld $v1,64($a0) #Ago, 9 /* was v1 */
  ld $s5,72($a0) #Agu, 10
  ld $t8,80($a0) #Aka, 11
  ld $gp,88($a0) #Ake, 12
  ld $s1,96($a0) #Aki, 13
  ld $t6,104($a0) #Ako, 14
  ld $t2,112($a0) #Aku, 15
  ld $t1,120($a0) #Ama, 16
  ld $s7,128($a0) #Ame, 17
  ld $a2,136($a0) #Ami, 18
  ld $t9,144($a0) #Amo, 19
  ld $t3,152($a0) #Amu, 20
  ld $t5,160($a0) #Asa, 21
  ld $s3,168($a0) #Ase, 22
  ld $s4,176($a0) #Asi, 23
  ld $s8,184($a0) #Aso, 24
  ld $ra,192($a0) #Asu, 25
.endm

  .macro SAVE_STATE
  sd $s0,0($a0)
  sd $t4,8($a0)
  sd $v0,16($a0)
  sd $s6,24($a0)
  sd $t0,32($a0)
  sd $a3,40($a0)
  sd $s2,48($a0)
  sd $t7,56($a0)
  sd $v1,64($a0) /* was k1 */
  sd $s5,72($a0)
  sd $t8,80($a0)
  sd $gp,88($a0)
  sd $s1,96($a0)
  sd $t6,104($a0)
  sd $t2,112($a0)
  sd $t1,120($a0)
  sd $s7,128($a0)
  sd $a2,136($a0)
  sd $t9,144($a0)
  sd $t3,152($a0)
  sd $t5,160($a0)
  sd $s3,168($a0)
  sd $s4,176($a0)
  sd $s8,184($a0)
  sd $ra,192($a0)
.endm

.macro ROUND

  /* scratch: a1 */

  sd $s8,16($sp)  /* Aso */
  sd $a2,32($sp) /* Ami */

  DO_BC $k1 $v1 $s6 $t6 $t9 $s8 /* v1 = bco = Ago, Abo, Ako, Amo, Aso */
  DO_BC $a1 $a3 $s0 $t8 $t1 $t5 /* a1 = bca = Aga, Aba, Aka, Ama, Asa */
  DO_BC $s8 $t7 $v0 $s1 $a2 $s4 /* s8 = bci = Agi, Abi, Aki, Ami, Asi */
  DO_BC $a2 $s2 $t4 $gp $s7 $s3 /* a2 = bce = Age, Abe, Ake, Ame, Ase */
  DO_BC $k0 $s5 $t0 $t2 $t3 $ra /* v0 = bcu = Agu, Abu, Aku, Amu, Asu */

  GEN_D $a0 $a2 $k0 /* da */
  GEN_D $k0,$k0,$s8 /* do */
  GEN_D $s8,$s8,$a1 /* de */
  GEN_D $a1,$a1,$k1 /* du */
  GEN_D $k1,$k1,$a2 /* di */

  /* APPLY THETA, scratch: a2 */

  xor $s0,$a0,$s0 #bca0
  xor $t1,$a0,$t1 #bco04
  sd $t1,40($sp) #s8 = bco4
  xor $t1,$a1,$t0 #bca3
  xor $t0,$a1,$ra #bcu0
  xor $ra,$s8,$s3  #ra = t1(s3) bcu4 
  xor $s3,$k0,$v1 #bce4 #was s3
  xor $v1,$s8,$s7 #bco1
  xor $s7,$a0,$a3 #bce3 a2 = a3
  xor $a3,$k0,$s6 #bca1 
  xor $s6,$k0,$t9 #bco0
  ld $a2,32($sp)    /* Ami */
  xor $t9,$k1,$a2
  xor $a2,$s8,$gp
  xor $gp,$k1,$t7 #bce2, v0 = t7 
  xor $t7,$a0,$t8 #bci1
  xor $t8,$s8,$t4 # bca2
  xor $t4,$s8,$s2 # bce0
  xor $s2,$a1,$s5  #bce1
  xor $s5,$k1,$s4 #bcu1 
  xor $s4,$a1,$t2 # BCI4 a2 = t2
  xor $t2,$a0,$t5 #bcu2
  xor $t5,$k1,$v0 #bca4 /* was t5 */
  xor $v0,$k1,$s1 #bci0  
  xor $s1,$k0,$t6 #bci2 
  xor $t6,$a1,$t3 #bco2
  ld $t3,16($sp) /* aso */
  xor $t3,$k0,$t3 /* t3 = s8 */
  ld $s8,40($sp) #s8 = bco4

  /* RHO - CHI */

                       /* aba, bca_0 s0 */
  drol $t4,$t4,44      /* age, bce_0  */
  drol $v0,$v0,43     /* aki, bci_0 */
  drol $s6,$s6,21      /* amo, bco_0 */
  drol $t0,$t0,14      /* asu, bcu_0 */

  CHI_BLOCK $s0 $t4 $v0 $s6 $t0

  drol $a3,$a3,28      /* abo, bca_1 */
  drol $s2,$s2,20      /* agu, bce_1 */
  drol $t7,$t7,3     /* aka, bci_1 */
  drol $v1,$v1,45      /* ame, bco_1 */
  drol $s5,$s5,61      /* asi, bcu_1 */

  CHI_BLOCK $a3 $s2 $t7 $v1 $s5

  drol $t8,$t8,1       /* abe, bca_2 */
  drol $gp,$gp,6      /* agi, bce_2 */
  drol $s1,$s1,25      /* ako, bci_2 */
  drol $t6,$t6,8       /* amu, bco_2 */
  drol $t2,$t2,18    /* asa, bcu_2 */

  CHI_BLOCK $t8 $gp $s1 $t6 $t2

  drol $t1,$t1,27      /* abu, bca_3 */
  drol $s7, $s7, 36    /* aga, bce_3 */
  drol $a2,$a2,10      /* ake, bci_3 */
  drol $t9,$t9,15      /* ami, bco_3 */
  drol $t3,$t3,56      /* aso, bcu_3 */

  CHI_BLOCK $t1 $s7 $a2 $t9 $t3

  drol $t5,$t5,62      /* abi, bca_4 */
  drol $s3,$s3,55      /* ago, bce_4  */
  drol $s4,$s4,39     /* aku, bci_4 */
  drol $s8,$s8,41    /* ama, bco_4 */
  drol $ra,$ra,2       /* ase, bcu_4 */

  CHI_BLOCK $t5 $s3 $s4 $s8 $ra

.endm

f1600:

  PREPARE_STACK
  LOAD_STATE

  sd $a0,64($sp)   /* save state */

  ROUND
  xori $s0, $s0, 0x1
  ROUND
  xori $s0, $s0, 0x8082
  ROUND
  APPLY_ROUND_CONSTANT $a1 $s0 round_constant_3
  ROUND
  APPLY_ROUND_CONSTANT $a1 $s0 round_constant_4
  ROUND
  xori $s0, $s0, 0x808b
  ROUND
  APPLY_ROUND_CONSTANT $a1 $s0 round_constant_6
  ROUND
  APPLY_ROUND_CONSTANT $a1 $s0 round_constant_7
  ROUND
  APPLY_ROUND_CONSTANT $a1 $s0 round_constant_8
  ROUND
  xori $s0, $s0, 0x8a
  ROUND
  xori $s0, $s0, 0x88
  ROUND
  APPLY_ROUND_CONSTANT $a1 $s0 round_constant_11
  ROUND
  APPLY_ROUND_CONSTANT $a1 $s0 round_constant_12
  ROUND
  APPLY_ROUND_CONSTANT $a1 $s0 round_constant_13
  ROUND
  APPLY_ROUND_CONSTANT $a1 $s0 round_constant_14
  ROUND
  APPLY_ROUND_CONSTANT $a1 $s0 round_constant_15
  ROUND
  APPLY_ROUND_CONSTANT $a1 $s0 round_constant_16
  ROUND
  APPLY_ROUND_CONSTANT $a1 $s0 round_constant_17
  ROUND
  APPLY_ROUND_CONSTANT $a1 $s0 round_constant_18
  ROUND
  xori $s0, $s0, 0x800a
  ROUND
  APPLY_ROUND_CONSTANT $a1 $s0 round_constant_20
  ROUND
  APPLY_ROUND_CONSTANT $a1 $s0 round_constant_21
  ROUND
  APPLY_ROUND_CONSTANT $a1 $s0 round_constant_22
  ROUND
  APPLY_ROUND_CONSTANT $a1 $s0 round_constant_23
  ROUND
  APPLY_ROUND_CONSTANT $a1 $s0 round_constant_24

  ld $a0,64($sp)  /* state */
 
  SAVE_STATE
  RESTORE_STACK

  jr $ra
.end f1600

.align 8
round_constant_3:
    .quad   0x800000000000808a
round_constant_4:
    .quad   0x8000000080008000
round_constant_6:
    .quad   0x0000000080000001
round_constant_7:
    .quad   0x8000000080008081
round_constant_8:
    .quad   0x8000000000008009
round_constant_10:
    .quad   0x0000000000000088
round_constant_11:
    .quad   0x0000000080008009
round_constant_12:
    .quad   0x000000008000000a
round_constant_13:
    .quad   0x000000008000808b
round_constant_14:
    .quad   0x800000000000008b
round_constant_15:
    .quad   0x8000000000008089
round_constant_16:
    .quad   0x8000000000008003
round_constant_17:
    .quad   0x8000000000008002
round_constant_18:
    .quad   0x8000000000000080
round_constant_19:
    .quad   0x000000000000800a
round_constant_20:
    .quad   0x800000008000000a
round_constant_21:
    .quad   0x8000000080008081
round_constant_22:
    .quad   0x8000000000008080
round_constant_23:
    .quad   0x0000000080000001
round_constant_24:
    .quad   0x8000000080008008
