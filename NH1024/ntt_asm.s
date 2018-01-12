/* Optimized implelmentation of  
   NTT1024 for MIPS64 r2 architectures */

.text
.globl ntt_layer_0
.globl ntt_layers_1_9

/* reduction macros 
   $t9, $gp, $ra: tmp */

rlog_shift_minus_1:
    .quad   262143

.macro MONTGOMERY_16 INPUT
  li 	$v0, 12287 
  mul 	$gp, \INPUT, $v0
  ld $v0, rlog_shift_minus_1
  and $gp,$gp,$v0
  addu \INPUT,\INPUT,$gp
  srl $gp,$gp,18
.endm

.macro MONTGOMERY_64 INOUT 
  dsll    $gp, $fp, 32 
  and     $t9, \INOUT, $fp 
  and     $gp, \INOUT, $gp 
  li	$v0, 12287
  dmul    $t9, $t9, $v0 
  dmul    $gp, $gp, $v0 
  dsrl    $ra, $fp, 14 
  and     $t9, $t9, $ra 
  dsll    $ra, $ra, 32 
  and     $gp, $gp, $ra 
  daddu   $t9, $t9, $gp 
  li	$v0, 12289
  dmul	$t9, $t9, $v0	 
  daddu	\INOUT, \INOUT, $t9 
  dsrl	\INOUT, \INOUT, 18
.endm

.macro BARRETT_64 OUT IN 
  dsll 	$gp,\IN,2 
  daddu	$gp,$gp,\IN 
  dsrl	$gp, $gp, 16 
  and	$gp, $gp, $a3 
  li	$v0, 12289
  dmul	$gp, $gp, $v0 	
  dsub	\OUT, \IN, $gp
.endm

/* Butterfly routines */

.macro SUBROUTINE_LAYER0 COEFF1 COEFF2 OFFSETOM OFFSETA
  lh  $t8, \OFFSETOM($a1)	
  add $t9, \COEFF1, \COEFF2	/* a[j] = a[j] + a[j + distance] */
  li  $v0, 36867
  add \COEFF1, \COEFF1, $v0	/* temp += 3q */
  sub \COEFF1, \COEFF1, \COEFF2	/* temp -= $t1 */
  mul \COEFF1, \COEFF1, $t8	/* temp *= W */
  MONTGOMERY_16 \COEFF1
  dsll	$t9, 32
  dadd 	$t9, $t9, \COEFF1
  sd   	$t9, \OFFSETA($a0)
.endm

.macro SUBROUTINE_B COEF1 COEF2 SH1 OFF_0 	/* barret */
  lh $t8, \OFF_0 + \SH1($a1) 			/* load 1st omega */
  dadd  $t9, \COEF1, \COEF2 			/* (temp + aa[j + distance]) */
  dadd \COEF1, \COEF1, $a2			/* temp += 3*NEWHOPE_Q */
  dsub \COEF2, \COEF1, \COEF2			/* -= aa[j + distance] */
  dmul \COEF2, \COEF2, $t8			/* *= W */
  BARRETT_64 \COEF1, $t9
  MONTGOMERY_64 \COEF2 
.endm

.macro SUBROUTINE COEF1 COEF2 SH1 OFF_0        /* w/o barret */
  lh $t8, \OFF_0 + \SH1($a1) 		       /* load omega */
  dadd  $t9, \COEF1, \COEF2 		       /* (temp + aa[j + distance]) */
  dadd \COEF1, \COEF1, $a2		       /* temp += 3*NEWHOPE_Q */
  dsub \COEF2, \COEF1, \COEF2		       /* -= aa[j + distance] */
  dmul \COEF2, \COEF2, $t8		       /* = W */
  and	\COEF1, $t9, $t9 
  MONTGOMERY_64 \COEF2
.endm

/* load/store macros */

.macro LOAD_SP
  addi $sp, $sp, -96
  sd $s0,  0($sp)
  sd $s1,  8($sp)
  sd $s2, 16($sp)
  sd $s3, 24($sp)
  sd $s4, 32($sp)
  sd $s5, 40($sp)
  sd $s6, 48($sp)
  sd $s7, 56($sp)
  sd $gp, 64($sp)
  sd $fp, 72($sp)
  sd $ra, 80($sp)
.endm

.macro STORE_SP
  ld 	$s0,  0($sp)
  ld 	$s1,  8($sp)
  ld 	$s2, 16($sp)
  ld 	$s3, 24($sp)
  ld 	$s4, 32($sp)
  ld 	$s5, 40($sp)
  ld 	$s6, 48($sp)
  ld 	$s7, 56($sp)
  ld 	$gp, 64($sp)
  ld 	$fp, 72($sp)
  ld 	$ra, 80($sp)
  addi	$sp, $sp, 88
.endm

/* layer iterations */

.macro LAYER_0_ITER OFF_0 OFF_1
     	lh $t0,     \OFF_0 + 0($a0)
     	lh $t1,     \OFF_0 + 2($a0)
     	lh $t2,     \OFF_0 + 4($a0)
     	lh $t3,     \OFF_0 + 6($a0)
     	lh $t4,     \OFF_0 + 8($a0)
     	lh $t5,    \OFF_0 + 10($a0)
     	lh $t6,    \OFF_0 + 12($a0)
     	lh $t7,    \OFF_0 + 14($a0)
     	lh $s0,    \OFF_0 + 16($a0)
     	lh $s1,    \OFF_0 + 18($a0)
     	lh $s2,    \OFF_0 + 20($a0)
     	lh $s3,    \OFF_0 + 22($a0)
     	lh $s4,    \OFF_0 + 24($a0)
     	lh $s5,    \OFF_0 + 26($a0)
     	lh $s6,    \OFF_0 + 28($a0)
     	lh $s7,    \OFF_0 + 30($a0)

	/* layer 0 */
  	SUBROUTINE_LAYER0 $t0, $t1,  0 + \OFF_1,  0 + 2048 + \OFF_0 + \OFF_0 
  	SUBROUTINE_LAYER0 $t2, $t3,  2 + \OFF_1,  8 + 2048 + \OFF_0 + \OFF_0 
  	SUBROUTINE_LAYER0 $t4, $t5,  4 + \OFF_1, 16 + 2048 + \OFF_0 + \OFF_0  
  	SUBROUTINE_LAYER0 $t6, $t7,  6 + \OFF_1, 24 + 2048 + \OFF_0 + \OFF_0  
  	SUBROUTINE_LAYER0 $s0, $s1,  8 + \OFF_1, 32 + 2048 + \OFF_0 + \OFF_0  
  	SUBROUTINE_LAYER0 $s2, $s3, 10 + \OFF_1, 40 + 2048 + \OFF_0 + \OFF_0 
  	SUBROUTINE_LAYER0 $s4, $s5, 12 + \OFF_1, 48 + 2048 + \OFF_0 + \OFF_0 
  	SUBROUTINE_LAYER0 $s6, $s7, 14 + \OFF_1, 56 + 2048 + \OFF_0 + \OFF_0 
.endm

.macro LAYER_1_4_ITER OFF_0 OFF_1 OFF_2 OFF_3 OFF_4
  	ld $t0,   \OFF_0 + 0($a0)
  	ld $t1,   \OFF_0 + 8($a0)
  	ld $t2,  \OFF_0 + 16($a0)
  	ld $t3,  \OFF_0 + 24($a0)
  	ld $t4,  \OFF_0 + 32($a0)
  	ld $t5,  \OFF_0 + 40($a0)
  	ld $t6,  \OFF_0 + 48($a0)
  	ld $t7,  \OFF_0 + 56($a0)
  	ld $s0,  \OFF_0 + 64($a0)
  	ld $s1,  \OFF_0 + 72($a0)
  	ld $s2,  \OFF_0 + 80($a0)
  	ld $s3,  \OFF_0 + 88($a0)
  	ld $s4,  \OFF_0 + 96($a0)
  	ld $s5, \OFF_0 + 104($a0)
  	ld $s6, \OFF_0 + 112($a0)
  	ld $s7, \OFF_0 + 120($a0)

	/* layer 1 */
        SUBROUTINE_B $t0, $t1, 0 + \OFF_1
 	SUBROUTINE_B $t2, $t3, 2 + \OFF_1
        SUBROUTINE_B $t4, $t5, 4 + \OFF_1
        SUBROUTINE_B $t6, $t7, 6 + \OFF_1
        SUBROUTINE_B $s0, $s1, 8 + \OFF_1
        SUBROUTINE_B $s2, $s3, 10 + \OFF_1
        SUBROUTINE_B $s4, $s5, 12 + \OFF_1
        SUBROUTINE_B $s6, $s7, 14 + \OFF_1

	/* layer 2  */
  	SUBROUTINE $t0, $t2, 0 + \OFF_2
  	SUBROUTINE $t1, $t3, 0 + \OFF_2
  	SUBROUTINE $t4, $t6, 2 + \OFF_2
  	SUBROUTINE $t5, $t7, 2 + \OFF_2
  	SUBROUTINE $s0, $s2, 4 + \OFF_2
 	SUBROUTINE $s1, $s3, 4 + \OFF_2
  	SUBROUTINE $s4, $s6, 6 + \OFF_2
  	SUBROUTINE $s5, $s7, 6 + \OFF_2
 
	/* layer 3 */
	SUBROUTINE_B $t0, $t4, 0 + \OFF_3
  	SUBROUTINE_B $t1, $t5, 0 + \OFF_3
  	SUBROUTINE_B $t2, $t6, 0 + \OFF_3
  	SUBROUTINE_B $t3, $t7, 0 + \OFF_3
  	SUBROUTINE_B $s0, $s4, 2 + \OFF_3
  	SUBROUTINE_B $s1, $s5, 2 + \OFF_3
  	SUBROUTINE_B $s2, $s6, 2 + \OFF_3
  	SUBROUTINE_B $s3, $s7, 2 + \OFF_3

	/* layer 4 */
  	SUBROUTINE $t0, $s0, 0 + \OFF_4
  	SUBROUTINE $t1, $s1, 0 + \OFF_4
  	SUBROUTINE $t2, $s2, 0 + \OFF_4
  	SUBROUTINE $t3, $s3, 0 + \OFF_4
  	SUBROUTINE $t4, $s4, 0 + \OFF_4
  	SUBROUTINE $t5, $s5, 0 + \OFF_4
  	SUBROUTINE $t6, $s6, 0 + \OFF_4
  	SUBROUTINE $t7, $s7, 0 + \OFF_4
 
  	/* store coeffs */
  	sd $t0,   \OFF_0 + 0($a0)
  	sd $t1,   \OFF_0 + 8($a0)
  	sd $t2,  \OFF_0 + 16($a0)
  	sd $t3,  \OFF_0 + 24($a0)
  	sd $t4,  \OFF_0 + 32($a0)
  	sd $t5,  \OFF_0 + 40($a0)
  	sd $t6,  \OFF_0 + 48($a0)
  	sd $t7,  \OFF_0 + 56($a0)
  	sd $s0,  \OFF_0 + 64($a0)
  	sd $s1,  \OFF_0 + 72($a0)
  	sd $s2,  \OFF_0 + 80($a0)
  	sd $s3,  \OFF_0 + 88($a0)
  	sd $s4,  \OFF_0 + 96($a0)
  	sd $s5, \OFF_0 + 104($a0)
  	sd $s6, \OFF_0 + 112($a0)
  	sd $s7, \OFF_0 + 120($a0)
.endm

.macro LAYER_5_8_ITER OFF_0 
  ld $t0,  \OFF_0 +   0($a0)
  ld $t1,  \OFF_0 + 128($a0)
  ld $t2,  \OFF_0 + 256($a0)
  ld $t3,  \OFF_0 + 384($a0)
  ld $t4,  \OFF_0 + 512($a0)
  ld $t5,  \OFF_0 + 640($a0)
  ld $t6,  \OFF_0 + 768($a0)
  ld $t7,  \OFF_0 + 896($a0)
  ld $s0, \OFF_0 + 1024($a0)
  ld $s1, \OFF_0 + 1152($a0)
  ld $s2, \OFF_0 + 1280($a0)
  ld $s3, \OFF_0 + 1408($a0)
  ld $s4, \OFF_0 + 1536($a0)
  ld $s5, \OFF_0 + 1664($a0)
  ld $s6, \OFF_0 + 1792($a0)
  ld $s7, \OFF_0 + 1920($a0)

  SUBROUTINE_B $t0, $t1, 0
  SUBROUTINE_B $t2, $t3, 2
  SUBROUTINE_B $t4, $t5, 4
  SUBROUTINE_B $t6, $t7, 6
  SUBROUTINE_B $s0, $s1, 8
  SUBROUTINE_B $s2, $s3, 10
  SUBROUTINE_B $s4, $s5, 12
  SUBROUTINE_B $s6, $s7, 14

  SUBROUTINE $t0, $t2, 0
  SUBROUTINE $t1, $t3, 0
  SUBROUTINE $t4, $t6, 2
  SUBROUTINE $t5, $t7, 2
  SUBROUTINE $s0, $s2, 4
  SUBROUTINE $s1, $s3, 4
  SUBROUTINE $s4, $s6, 6
  SUBROUTINE $s5, $s7, 6

  SUBROUTINE_B $t0, $t4, 0
  SUBROUTINE_B $t1, $t5, 0
  SUBROUTINE_B $t2, $t6, 0
  SUBROUTINE_B $t3, $t7, 0
  SUBROUTINE_B $s0, $s4, 2
  SUBROUTINE_B $s1, $s5, 2
  SUBROUTINE_B $s2, $s6, 2
  SUBROUTINE_B $s3, $s7, 2

  SUBROUTINE $t0, $s0, 0
  SUBROUTINE $t1, $s1, 0
  SUBROUTINE $t2, $s2, 0
  SUBROUTINE $t3, $s3, 0
  SUBROUTINE $t4, $s4, 0
  SUBROUTINE $t5, $s5, 0
  SUBROUTINE $t6, $s6, 0
  SUBROUTINE $t7, $s7, 0

  sd $t0,  \OFF_0 +   0($a0)
  sd $t1,  \OFF_0 + 128($a0)
  sd $t2,  \OFF_0 + 256($a0)
  sd $t3,  \OFF_0 + 384($a0)
  sd $t4,  \OFF_0 + 512($a0)
  sd $t5,  \OFF_0 + 640($a0)
  sd $t6,  \OFF_0 + 768($a0)
  sd $t7,  \OFF_0 + 896($a0)
  sd $s0, \OFF_0 + 1024($a0)
  sd $s1, \OFF_0 + 1152($a0)
  sd $s2, \OFF_0 + 1280($a0)
  sd $s3, \OFF_0 + 1408($a0)
  sd $s4, \OFF_0 + 1536($a0)
  sd $s5, \OFF_0 + 1664($a0)
  sd $s6, \OFF_0 + 1792($a0)
  sd $s7, \OFF_0 + 1920($a0)
.endm

.macro LAYER_5_8_ITER_B OFF_0 
  ld $t0,  1920 + 8*16 + \OFF_0 +   0($a0)
  ld $t1,  1920 + 8*16 + \OFF_0 + 128($a0)
  ld $t2,  1920 + 8*16 + \OFF_0 + 256($a0)
  ld $t3,  1920 + 8*16 + \OFF_0 + 384($a0)
  ld $t4,  1920 + 8*16 + \OFF_0 + 512($a0)
  ld $t5,  1920 + 8*16 + \OFF_0 + 640($a0)
  ld $t6,  1920 + 8*16 + \OFF_0 + 768($a0)
  ld $t7,  1920 + 8*16 + \OFF_0 + 896($a0)
  ld $s0, 1920 + 8*16 + \OFF_0 + 1024($a0)
  ld $s1, 1920 + 8*16 + \OFF_0 + 1152($a0)
  ld $s2, 1920 + 8*16 + \OFF_0 + 1280($a0)
  ld $s3, 1920 + 8*16 + \OFF_0 + 1408($a0)
  ld $s4, 1920 + 8*16 + \OFF_0 + 1536($a0)
  ld $s5, 1920 + 8*16 + \OFF_0 + 1664($a0)
  ld $s6, 1920 + 8*16 + \OFF_0 + 1792($a0)
  ld $s7, 1920 + 8*16 + \OFF_0 + 1920($a0)

  SUBROUTINE_B $t0, $t1, 0 + 16
  SUBROUTINE_B $t2, $t3, 2 + 16
  SUBROUTINE_B $t4, $t5, 4 + 16
  SUBROUTINE_B $t6, $t7, 6 + 16
  SUBROUTINE_B $s0, $s1, 8 + 16
  SUBROUTINE_B $s2, $s3, 10 + 16
  SUBROUTINE_B $s4, $s5, 12 + 16
  SUBROUTINE_B $s6, $s7, 14 + 16

  SUBROUTINE $t0, $t2, 0, -8 + 16
  SUBROUTINE $t1, $t3, 0, -8 + 16
  SUBROUTINE $t4, $t6, 2, -8 + 16
  SUBROUTINE $t5, $t7, 2, -8 + 16
  SUBROUTINE $s0, $s2, 4, -8 + 16
  SUBROUTINE $s1, $s3, 4, -8 + 16
  SUBROUTINE $s4, $s6, 6, -8 + 16
  SUBROUTINE $s5, $s7, 6, -8 + 16

  SUBROUTINE_B $t0, $t4, 0, -12 + 16
  SUBROUTINE_B $t1, $t5, 0, -12 + 16
  SUBROUTINE_B $t2, $t6, 0, -12 + 16
  SUBROUTINE_B $t3, $t7, 0, -12 + 16
  SUBROUTINE_B $s0, $s4, 2, -12 + 16
  SUBROUTINE_B $s1, $s5, 2, -12 + 16
  SUBROUTINE_B $s2, $s6, 2, -12 + 16
  SUBROUTINE_B $s3, $s7, 2, -12 + 16

  SUBROUTINE $t0, $s0, 0, -14 + 16
  SUBROUTINE $t1, $s1, 0, -14 + 16
  SUBROUTINE $t2, $s2, 0, -14 + 16
  SUBROUTINE $t3, $s3, 0, -14 + 16
  SUBROUTINE $t4, $s4, 0, -14 + 16
  SUBROUTINE $t5, $s5, 0, -14 + 16
  SUBROUTINE $t6, $s6, 0, -14 + 16
  SUBROUTINE $t7, $s7, 0, -14 + 16

  sd $t0,  1920 + 8*16 + \OFF_0 +   0($a0)
  sd $t1,  1920 + 8*16 + \OFF_0 + 128($a0)
  sd $t2,  1920 + 8*16 + \OFF_0 + 256($a0)
  sd $t3,  1920 + 8*16 + \OFF_0 + 384($a0)
  sd $t4,  1920 + 8*16 + \OFF_0 + 512($a0)
  sd $t5,  1920 + 8*16 + \OFF_0 + 640($a0)
  sd $t6,  1920 + 8*16 + \OFF_0 + 768($a0)
  sd $t7,  1920 + 8*16 + \OFF_0 + 896($a0)
  sd $s0,  1920 + 8*16 + \OFF_0 + 1024($a0)
  sd $s1,  1920 + 8*16 + \OFF_0 + 1152($a0)
  sd $s2,  1920 + 8*16 + \OFF_0 + 1280($a0)
  sd $s3,  1920 + 8*16 + \OFF_0 + 1408($a0)
  sd $s4,  1920 + 8*16 + \OFF_0 + 1536($a0)
  sd $s5,  1920 + 8*16 + \OFF_0 + 1664($a0)
  sd $s6,  1920 + 8*16 + \OFF_0 + 1792($a0)
  sd $s7,  1920 + 8*16 + \OFF_0 + 1920($a0)
.endm

.macro LAYER_9_ITER OFF_0
  ld $t0,  \OFF_0 + 0($a0)
  ld $t1,  \OFF_0 +2048($a0)
  ld $t2,  \OFF_0 +8($a0)
  ld $t3,  \OFF_0 +2056($a0)
  ld $t4,  \OFF_0 +16($a0)
  ld $t5,  \OFF_0 +2064($a0)
  ld $t6,  \OFF_0 +24($a0)
  ld $t7,  \OFF_0 +2072($a0)
  ld $s0, \OFF_0 +32($a0)
  ld $s1, \OFF_0 +2080($a0)
  ld $s2, \OFF_0 +40($a0)
  ld $s3, \OFF_0 +2088($a0)
  ld $s4, \OFF_0 +48($a0)
  ld $s5, \OFF_0 +2096($a0)
  ld $s6, \OFF_0 +56($a0)
  ld $s7, \OFF_0 +2104($a0)
  
  SUBROUTINE_B $t0, $t1, 0
  SUBROUTINE_B $t2, $t3, 0
  SUBROUTINE_B $t4, $t5, 0
  SUBROUTINE_B $t6, $t7, 0
  SUBROUTINE_B $s0, $s1, 0
  SUBROUTINE_B $s2, $s3, 0
  SUBROUTINE_B $s4, $s5, 0
  SUBROUTINE_B $s6, $s7, 0

  sd $t0,  \OFF_0 +  0($a0)
  sd $t1,  \OFF_0 +2048($a0)
  sd $t2,  \OFF_0 +8($a0)
  sd $t3,  \OFF_0 +2056($a0)
  sd $t4,  \OFF_0 +16($a0)
  sd $t5,  \OFF_0 +2064($a0)
  sd $t6,  \OFF_0 +24($a0)
  sd $t7,  \OFF_0 +2072($a0)
  sd $s0, \OFF_0 +32($a0)
  sd $s1, \OFF_0 +2080($a0)
  sd $s2, \OFF_0 +40($a0)
  sd $s3, \OFF_0 +2088($a0)
  sd $s4, \OFF_0 +48($a0)
  sd $s5, \OFF_0 +2096($a0)
  sd $s6, \OFF_0 +56($a0)
  sd $s7, \OFF_0 +2104($a0)
.endm

/* layer 0 */
.ent ntt_layer_0
ntt_layer_0:
  LOAD_SP
  LAYER_0_ITER 32*0 16*0
  LAYER_0_ITER 32*1 16*1
  LAYER_0_ITER 32*2 16*2
  LAYER_0_ITER 32*3 16*3
  LAYER_0_ITER 32*4 16*4
  LAYER_0_ITER 32*5 16*5
  LAYER_0_ITER 32*6 16*6
  LAYER_0_ITER 32*7 16*7
  LAYER_0_ITER 32*8 16*8
  LAYER_0_ITER 32*9 16*9
  LAYER_0_ITER 32*10 16*10
  LAYER_0_ITER 32*11 16*11
  LAYER_0_ITER 32*12 16*12
  LAYER_0_ITER 32*13 16*13
  LAYER_0_ITER 32*14 16*14
  LAYER_0_ITER 32*15 16*15
  LAYER_0_ITER 32*16 16*16
  LAYER_0_ITER 32*17 16*17
  LAYER_0_ITER 32*18 16*18
  LAYER_0_ITER 32*19 16*19
  LAYER_0_ITER 32*20 16*20
  LAYER_0_ITER 32*21 16*21
  LAYER_0_ITER 32*22 16*22
  LAYER_0_ITER 32*23 16*23
  LAYER_0_ITER 32*24 16*24
  LAYER_0_ITER 32*25 16*25
  LAYER_0_ITER 32*26 16*26
  LAYER_0_ITER 32*27 16*27
  LAYER_0_ITER 32*28 16*28
  LAYER_0_ITER 32*29 16*29
  LAYER_0_ITER 32*30 16*30
  LAYER_0_ITER 32*31 16*31
  LAYER_0_ITER 32*32 16*32
  LAYER_0_ITER 32*33 16*33
  LAYER_0_ITER 32*34 16*34
  LAYER_0_ITER 32*35 16*35
  LAYER_0_ITER 32*36 16*36
  LAYER_0_ITER 32*37 16*37
  LAYER_0_ITER 32*38 16*38
  LAYER_0_ITER 32*39 16*39
  LAYER_0_ITER 32*40 16*40
  LAYER_0_ITER 32*41 16*41
  LAYER_0_ITER 32*42 16*42
  LAYER_0_ITER 32*43 16*43
  LAYER_0_ITER 32*44 16*44
  LAYER_0_ITER 32*45 16*45
  LAYER_0_ITER 32*46 16*46
  LAYER_0_ITER 32*47 16*47
  LAYER_0_ITER 32*48 16*48
  LAYER_0_ITER 32*49 16*49
  LAYER_0_ITER 32*50 16*50
  LAYER_0_ITER 32*51 16*51
  LAYER_0_ITER 32*52 16*52
  LAYER_0_ITER 32*53 16*53
  LAYER_0_ITER 32*54 16*54
  LAYER_0_ITER 32*55 16*55
  LAYER_0_ITER 32*56 16*56
  LAYER_0_ITER 32*57 16*57
  LAYER_0_ITER 32*58 16*58
  LAYER_0_ITER 32*59 16*59
  LAYER_0_ITER 32*60 16*60
  LAYER_0_ITER 32*61 16*61
  LAYER_0_ITER 32*62 16*62
  LAYER_0_ITER 32*63 16*63
  STORE_SP
  jr	$ra
.end ntt_layer_0

/* layers 1-9 */
.ent ntt_layers_1_9
ntt_layers_1_9:

  LOAD_SP

  /* 0x0000900300009003 */
  li $a2, 0x9003
  dsll $ra, $a2, 32
  dadd $a2, $a2, $ra 

  /* 0x0000ffff0000ffff */
  li $a3, 0xffff
  dsll $ra, $a3, 32
  dadd $a3, $a3, $ra 

  li $fp, -1
  dsrl $fp, $fp, 32

  LAYER_1_4_ITER 128*0 16*0 8*0 4*0 2*0
  LAYER_1_4_ITER 128*1 16*1 8*1 4*1 2*1
  LAYER_1_4_ITER 128*2 16*2 8*2 4*2 2*2
  LAYER_1_4_ITER 128*3 16*3 8*3 4*3 2*3
  LAYER_1_4_ITER 128*4 16*4 8*4 4*4 2*4
  LAYER_1_4_ITER 128*5 16*5 8*5 4*5 2*5
  LAYER_1_4_ITER 128*6 16*6 8*6 4*6 2*6
  LAYER_1_4_ITER 128*7 16*7 8*7 4*7 2*7
  LAYER_1_4_ITER 128*8 16*8 8*8 4*8 2*8
  LAYER_1_4_ITER 128*9 16*9 8*9 4*9 2*9
  LAYER_1_4_ITER 128*10 16*10 8*10 4*10 2*10
  LAYER_1_4_ITER 128*11 16*11 8*11 4*11 2*11
  LAYER_1_4_ITER 128*12 16*12 8*12 4*12 2*12
  LAYER_1_4_ITER 128*13 16*13 8*13 4*13 2*13
  LAYER_1_4_ITER 128*14 16*14 8*14 4*14 2*14
  LAYER_1_4_ITER 128*15 16*15 8*15 4*15 2*15
  LAYER_1_4_ITER 128*16 16*16 8*16 4*16 2*16
  LAYER_1_4_ITER 128*17 16*17 8*17 4*17 2*17
  LAYER_1_4_ITER 128*18 16*18 8*18 4*18 2*18
  LAYER_1_4_ITER 128*19 16*19 8*19 4*19 2*19
  LAYER_1_4_ITER 128*20 16*20 8*20 4*20 2*20
  LAYER_1_4_ITER 128*21 16*21 8*21 4*21 2*21
  LAYER_1_4_ITER 128*22 16*22 8*22 4*22 2*22
  LAYER_1_4_ITER 128*23 16*23 8*23 4*23 2*23
  LAYER_1_4_ITER 128*24 16*24 8*24 4*24 2*24
  LAYER_1_4_ITER 128*25 16*25 8*25 4*25 2*25
  LAYER_1_4_ITER 128*26 16*26 8*26 4*26 2*26
  LAYER_1_4_ITER 128*27 16*27 8*27 4*27 2*27
  LAYER_1_4_ITER 128*28 16*28 8*28 4*28 2*28
  LAYER_1_4_ITER 128*29 16*29 8*29 4*29 2*29
  LAYER_1_4_ITER 128*30 16*30 8*30 4*30 2*30
  LAYER_1_4_ITER 128*31 16*31 8*31 4*31 2*31

  /* layers 5 -8 */

  LAYER_5_8_ITER  8*0
  LAYER_5_8_ITER  8*1
  LAYER_5_8_ITER  8*2
  LAYER_5_8_ITER  8*3
  LAYER_5_8_ITER  8*4
  LAYER_5_8_ITER  8*5
  LAYER_5_8_ITER  8*6
  LAYER_5_8_ITER  8*7
  LAYER_5_8_ITER  8*8
  LAYER_5_8_ITER  8*9
  LAYER_5_8_ITER  8*10
  LAYER_5_8_ITER  8*11
  LAYER_5_8_ITER  8*12
  LAYER_5_8_ITER  8*13
  LAYER_5_8_ITER  8*14
  LAYER_5_8_ITER  8*15

  LAYER_5_8_ITER_B  8*0 
  LAYER_5_8_ITER_B  8*1
  LAYER_5_8_ITER_B  8*2
  LAYER_5_8_ITER_B  8*3
  LAYER_5_8_ITER_B  8*4
  LAYER_5_8_ITER_B  8*5
  LAYER_5_8_ITER_B  8*6
  LAYER_5_8_ITER_B  8*7
  LAYER_5_8_ITER_B  8*8
  LAYER_5_8_ITER_B  8*9
  LAYER_5_8_ITER_B  8*10
  LAYER_5_8_ITER_B  8*11
  LAYER_5_8_ITER_B  8*12
  LAYER_5_8_ITER_B  8*13
  LAYER_5_8_ITER_B  8*14
  LAYER_5_8_ITER_B  8*15

  /* layer 9 */

  LAYER_9_ITER 64*0
  LAYER_9_ITER 64
  LAYER_9_ITER 64*2
  LAYER_9_ITER 64*3
  LAYER_9_ITER 64*4
  LAYER_9_ITER 64*5
  LAYER_9_ITER 64*6
  LAYER_9_ITER 64*7
  LAYER_9_ITER 64*8
  LAYER_9_ITER 64*9
  LAYER_9_ITER 64*10
  LAYER_9_ITER 64*11
  LAYER_9_ITER 64*12
  LAYER_9_ITER 64*13
  LAYER_9_ITER 64*14
  LAYER_9_ITER 64*15
  LAYER_9_ITER 64*16
  LAYER_9_ITER 64*17
  LAYER_9_ITER 64*18
  LAYER_9_ITER 64*19
  LAYER_9_ITER 64*20
  LAYER_9_ITER 64*21
  LAYER_9_ITER 64*22
  LAYER_9_ITER 64*23
  LAYER_9_ITER 64*24
  LAYER_9_ITER 64*25
  LAYER_9_ITER 64*26
  LAYER_9_ITER 64*27
  LAYER_9_ITER 64*28
  LAYER_9_ITER 64*29
  LAYER_9_ITER 64*30
  LAYER_9_ITER 64*31
  
  STORE_SP
  jr	$ra
.end ntt_layers_1_9
