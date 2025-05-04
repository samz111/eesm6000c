	.file	"fir.c"
	.option nopic
	.attribute arch, "rv32i2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
.Ltext0:
	.cfi_sections	.debug_frame
	.file 0 "/home/ubuntu/Desktop/hkust-soc-lab-main/Lab4/Lab4-2/lab-caravel_fir/testbench/counter_la_fir" "fir.c"
	.align	2
	.type	flush_cpu_icache, @function
flush_cpu_icache:
.LFB21:
	.file 1 "../../firmware/system.h"
	.loc 1 15 1
	.cfi_startproc
	addi	sp,sp,-16
	.cfi_def_cfa_offset 16
	sw	s0,12(sp)
	.cfi_offset 8, -4
	addi	s0,sp,16
	.cfi_def_cfa 8, 0
	.loc 1 26 1
	nop
	lw	s0,12(sp)
	.cfi_restore 8
	.cfi_def_cfa 2, 16
	addi	sp,sp,16
	.cfi_def_cfa_offset 0
	jr	ra
	.cfi_endproc
.LFE21:
	.size	flush_cpu_icache, .-flush_cpu_icache
	.align	2
	.type	flush_cpu_dcache, @function
flush_cpu_dcache:
.LFB22:
	.loc 1 29 1
	.cfi_startproc
	addi	sp,sp,-16
	.cfi_def_cfa_offset 16
	sw	s0,12(sp)
	.cfi_offset 8, -4
	addi	s0,sp,16
	.cfi_def_cfa 8, 0
	.loc 1 33 1
	nop
	lw	s0,12(sp)
	.cfi_restore 8
	.cfi_def_cfa 2, 16
	addi	sp,sp,16
	.cfi_def_cfa_offset 0
	jr	ra
	.cfi_endproc
.LFE22:
	.size	flush_cpu_dcache, .-flush_cpu_dcache
	.globl	taps
	.data
	.align	2
	.type	taps, @object
	.size	taps, 44
taps:
	.word	0
	.word	-10
	.word	-9
	.word	23
	.word	56
	.word	63
	.word	56
	.word	23
	.word	-9
	.word	-10
	.word	0
	.globl	outputsignal
	.bss
	.align	2
	.type	outputsignal, @object
	.size	outputsignal, 256
outputsignal:
	.zero	256
	.section	.mprjram,"ax",@progbits
	.align	2
	.globl	initfir
	.type	initfir, @function
initfir:
.LFB316:
	.file 2 "fir.c"
	.loc 2 5 61
	.cfi_startproc
	addi	sp,sp,-16
	.cfi_def_cfa_offset 16
	sw	s0,12(sp)
	.cfi_offset 8, -4
	addi	s0,sp,16
	.cfi_def_cfa 8, 0
	.loc 2 8 3
	li	a5,805306368
	addi	a5,a5,16
	.loc 2 8 36
	li	a4,64
	sw	a4,0(a5)
	.loc 2 9 3
	li	a5,805306368
	addi	a5,a5,20
	.loc 2 9 36
	li	a4,11
	sw	a4,0(a5)
	.loc 2 11 42
	lui	a5,%hi(taps)
	addi	a5,a5,%lo(taps)
	lw	a4,0(a5)
	.loc 2 11 3
	li	a5,805306368
	addi	a5,a5,128
	.loc 2 11 36
	sw	a4,0(a5)
	.loc 2 12 42
	lui	a5,%hi(taps)
	addi	a5,a5,%lo(taps)
	lw	a4,4(a5)
	.loc 2 12 3
	li	a5,805306368
	addi	a5,a5,132
	.loc 2 12 36
	sw	a4,0(a5)
	.loc 2 13 42
	lui	a5,%hi(taps)
	addi	a5,a5,%lo(taps)
	lw	a4,8(a5)
	.loc 2 13 3
	li	a5,805306368
	addi	a5,a5,136
	.loc 2 13 36
	sw	a4,0(a5)
	.loc 2 14 42
	lui	a5,%hi(taps)
	addi	a5,a5,%lo(taps)
	lw	a4,12(a5)
	.loc 2 14 3
	li	a5,805306368
	addi	a5,a5,140
	.loc 2 14 36
	sw	a4,0(a5)
	.loc 2 15 42
	lui	a5,%hi(taps)
	addi	a5,a5,%lo(taps)
	lw	a4,16(a5)
	.loc 2 15 3
	li	a5,805306368
	addi	a5,a5,144
	.loc 2 15 36
	sw	a4,0(a5)
	.loc 2 16 42
	lui	a5,%hi(taps)
	addi	a5,a5,%lo(taps)
	lw	a4,20(a5)
	.loc 2 16 3
	li	a5,805306368
	addi	a5,a5,148
	.loc 2 16 36
	sw	a4,0(a5)
	.loc 2 17 42
	lui	a5,%hi(taps)
	addi	a5,a5,%lo(taps)
	lw	a4,24(a5)
	.loc 2 17 3
	li	a5,805306368
	addi	a5,a5,152
	.loc 2 17 36
	sw	a4,0(a5)
	.loc 2 18 42
	lui	a5,%hi(taps)
	addi	a5,a5,%lo(taps)
	lw	a4,28(a5)
	.loc 2 18 3
	li	a5,805306368
	addi	a5,a5,156
	.loc 2 18 36
	sw	a4,0(a5)
	.loc 2 19 42
	lui	a5,%hi(taps)
	addi	a5,a5,%lo(taps)
	lw	a4,32(a5)
	.loc 2 19 3
	li	a5,805306368
	addi	a5,a5,160
	.loc 2 19 36
	sw	a4,0(a5)
	.loc 2 20 42
	lui	a5,%hi(taps)
	addi	a5,a5,%lo(taps)
	lw	a4,36(a5)
	.loc 2 20 3
	li	a5,805306368
	addi	a5,a5,164
	.loc 2 20 36
	sw	a4,0(a5)
	.loc 2 21 42
	lui	a5,%hi(taps)
	addi	a5,a5,%lo(taps)
	lw	a4,40(a5)
	.loc 2 21 3
	li	a5,805306368
	addi	a5,a5,168
	.loc 2 21 36
	sw	a4,0(a5)
	.loc 2 23 1
	nop
	lw	s0,12(sp)
	.cfi_restore 8
	.cfi_def_cfa 2, 16
	addi	sp,sp,16
	.cfi_def_cfa_offset 0
	jr	ra
	.cfi_endproc
.LFE316:
	.size	initfir, .-initfir
	.align	2
	.globl	fir
	.type	fir, @function
fir:
.LFB317:
	.loc 2 25 56
	.cfi_startproc
	addi	sp,sp,-32
	.cfi_def_cfa_offset 32
	sw	ra,28(sp)
	sw	s0,24(sp)
	.cfi_offset 1, -4
	.cfi_offset 8, -8
	addi	s0,sp,32
	.cfi_def_cfa 8, 0
	.loc 2 27 2
	call	initfir
	.loc 2 28 6
	sw	zero,-20(s0)
	.loc 2 29 3
	li	a5,805306368
	.loc 2 29 36
	li	a4,1
	sw	a4,0(a5)
	.loc 2 31 3
	li	a5,637534208
	addi	a5,a5,12
	.loc 2 31 36
	li	a4,10813440
	sw	a4,0(a5)
	.loc 2 33 8
	sw	zero,-20(s0)
	.loc 2 33 2
	j	.L5
.L6:
	.loc 2 34 40
	lw	a5,-20(s0)
	addi	a4,a5,1
	.loc 2 34 4
	li	a5,805306368
	addi	a5,a5,64
	.loc 2 34 37
	sw	a4,0(a5)
	.loc 2 35 4
	lw	a5,-20(s0)
	addi	a5,a5,1
	sw	a5,-20(s0)
	.loc 2 36 22
	li	a5,805306368
	addi	a5,a5,68
	lw	a5,0(a5)
	mv	a3,a5
	.loc 2 36 19
	lui	a5,%hi(outputsignal)
	addi	a4,a5,%lo(outputsignal)
	lw	a5,-20(s0)
	slli	a5,a5,2
	add	a5,a4,a5
	sw	a3,0(a5)
.L5:
	.loc 2 33 13 discriminator 1
	lw	a4,-20(s0)
	li	a5,63
	ble	a4,a5,.L6
	.loc 2 41 9
	lui	a5,%hi(outputsignal)
	addi	a5,a5,%lo(outputsignal)
	.loc 2 44 1
	mv	a0,a5
	lw	ra,28(sp)
	.cfi_restore 1
	lw	s0,24(sp)
	.cfi_restore 8
	.cfi_def_cfa 2, 32
	addi	sp,sp,32
	.cfi_def_cfa_offset 0
	jr	ra
	.cfi_endproc
.LFE317:
	.size	fir, .-fir
	.text
.Letext0:
	.file 3 "fir.h"
	.file 4 "/opt/riscv/lib/gcc/riscv32-unknown-elf/12.1.0/include/stdint-gcc.h"
	.section	.debug_info,"",@progbits
.Ldebug_info0:
	.4byte	0x115
	.2byte	0x5
	.byte	0x1
	.byte	0x4
	.4byte	.Ldebug_abbrev0
	.byte	0x6
	.4byte	.LASF15
	.byte	0x1d
	.4byte	.LASF0
	.4byte	.LASF1
	.4byte	.LLRL0
	.4byte	0
	.4byte	.Ldebug_line0
	.byte	0x1
	.byte	0x1
	.byte	0x6
	.4byte	.LASF2
	.byte	0x1
	.byte	0x2
	.byte	0x5
	.4byte	.LASF3
	.byte	0x1
	.byte	0x4
	.byte	0x5
	.4byte	.LASF4
	.byte	0x1
	.byte	0x8
	.byte	0x5
	.4byte	.LASF5
	.byte	0x1
	.byte	0x1
	.byte	0x8
	.4byte	.LASF6
	.byte	0x1
	.byte	0x2
	.byte	0x7
	.4byte	.LASF7
	.byte	0x7
	.4byte	.LASF16
	.byte	0x4
	.byte	0x34
	.byte	0x1b
	.4byte	0x5c
	.byte	0x1
	.byte	0x4
	.byte	0x7
	.4byte	.LASF8
	.byte	0x1
	.byte	0x8
	.byte	0x7
	.4byte	.LASF9
	.byte	0x8
	.byte	0x4
	.byte	0x5
	.string	"int"
	.byte	0x1
	.byte	0x4
	.byte	0x7
	.4byte	.LASF10
	.byte	0x2
	.4byte	0x6a
	.4byte	0x88
	.byte	0x3
	.4byte	0x71
	.byte	0xa
	.byte	0
	.byte	0x4
	.4byte	.LASF11
	.byte	0x1a
	.4byte	0x78
	.byte	0x5
	.byte	0x3
	.4byte	taps
	.byte	0x2
	.4byte	0x6a
	.4byte	0xa8
	.byte	0x3
	.4byte	0x71
	.byte	0x3f
	.byte	0
	.byte	0x4
	.4byte	.LASF12
	.byte	0x1b
	.4byte	0x98
	.byte	0x5
	.byte	0x3
	.4byte	outputsignal
	.byte	0x9
	.string	"fir"
	.byte	0x2
	.byte	0x19
	.byte	0x33
	.4byte	0xe0
	.4byte	.LFB317
	.4byte	.LFE317-.LFB317
	.byte	0x1
	.byte	0x9c
	.4byte	0xe0
	.byte	0xa
	.string	"i"
	.byte	0x2
	.byte	0x1c
	.byte	0x6
	.4byte	0x6a
	.byte	0x2
	.byte	0x91
	.byte	0x6c
	.byte	0
	.byte	0xb
	.byte	0x4
	.4byte	0x6a
	.byte	0xc
	.4byte	.LASF17
	.byte	0x2
	.byte	0x5
	.byte	0x33
	.4byte	.LFB316
	.4byte	.LFE316-.LFB316
	.byte	0x1
	.byte	0x9c
	.byte	0x5
	.4byte	.LASF13
	.byte	0x1c
	.4byte	.LFB22
	.4byte	.LFE22-.LFB22
	.byte	0x1
	.byte	0x9c
	.byte	0x5
	.4byte	.LASF14
	.byte	0xe
	.4byte	.LFB21
	.4byte	.LFE21-.LFB21
	.byte	0x1
	.byte	0x9c
	.byte	0
	.section	.debug_abbrev,"",@progbits
.Ldebug_abbrev0:
	.byte	0x1
	.byte	0x24
	.byte	0
	.byte	0xb
	.byte	0xb
	.byte	0x3e
	.byte	0xb
	.byte	0x3
	.byte	0xe
	.byte	0
	.byte	0
	.byte	0x2
	.byte	0x1
	.byte	0x1
	.byte	0x49
	.byte	0x13
	.byte	0x1
	.byte	0x13
	.byte	0
	.byte	0
	.byte	0x3
	.byte	0x21
	.byte	0
	.byte	0x49
	.byte	0x13
	.byte	0x2f
	.byte	0xb
	.byte	0
	.byte	0
	.byte	0x4
	.byte	0x34
	.byte	0
	.byte	0x3
	.byte	0xe
	.byte	0x3a
	.byte	0x21
	.byte	0x3
	.byte	0x3b
	.byte	0xb
	.byte	0x39
	.byte	0x21
	.byte	0x5
	.byte	0x49
	.byte	0x13
	.byte	0x3f
	.byte	0x19
	.byte	0x2
	.byte	0x18
	.byte	0
	.byte	0
	.byte	0x5
	.byte	0x2e
	.byte	0
	.byte	0x3
	.byte	0xe
	.byte	0x3a
	.byte	0x21
	.byte	0x1
	.byte	0x3b
	.byte	0xb
	.byte	0x39
	.byte	0x21
	.byte	0x25
	.byte	0x27
	.byte	0x19
	.byte	0x11
	.byte	0x1
	.byte	0x12
	.byte	0x6
	.byte	0x40
	.byte	0x18
	.byte	0x7a
	.byte	0x19
	.byte	0
	.byte	0
	.byte	0x6
	.byte	0x11
	.byte	0x1
	.byte	0x25
	.byte	0xe
	.byte	0x13
	.byte	0xb
	.byte	0x3
	.byte	0x1f
	.byte	0x1b
	.byte	0x1f
	.byte	0x55
	.byte	0x17
	.byte	0x11
	.byte	0x1
	.byte	0x10
	.byte	0x17
	.byte	0
	.byte	0
	.byte	0x7
	.byte	0x16
	.byte	0
	.byte	0x3
	.byte	0xe
	.byte	0x3a
	.byte	0xb
	.byte	0x3b
	.byte	0xb
	.byte	0x39
	.byte	0xb
	.byte	0x49
	.byte	0x13
	.byte	0
	.byte	0
	.byte	0x8
	.byte	0x24
	.byte	0
	.byte	0xb
	.byte	0xb
	.byte	0x3e
	.byte	0xb
	.byte	0x3
	.byte	0x8
	.byte	0
	.byte	0
	.byte	0x9
	.byte	0x2e
	.byte	0x1
	.byte	0x3f
	.byte	0x19
	.byte	0x3
	.byte	0x8
	.byte	0x3a
	.byte	0xb
	.byte	0x3b
	.byte	0xb
	.byte	0x39
	.byte	0xb
	.byte	0x49
	.byte	0x13
	.byte	0x11
	.byte	0x1
	.byte	0x12
	.byte	0x6
	.byte	0x40
	.byte	0x18
	.byte	0x7c
	.byte	0x19
	.byte	0x1
	.byte	0x13
	.byte	0
	.byte	0
	.byte	0xa
	.byte	0x34
	.byte	0
	.byte	0x3
	.byte	0x8
	.byte	0x3a
	.byte	0xb
	.byte	0x3b
	.byte	0xb
	.byte	0x39
	.byte	0xb
	.byte	0x49
	.byte	0x13
	.byte	0x2
	.byte	0x18
	.byte	0
	.byte	0
	.byte	0xb
	.byte	0xf
	.byte	0
	.byte	0xb
	.byte	0xb
	.byte	0x49
	.byte	0x13
	.byte	0
	.byte	0
	.byte	0xc
	.byte	0x2e
	.byte	0
	.byte	0x3f
	.byte	0x19
	.byte	0x3
	.byte	0xe
	.byte	0x3a
	.byte	0xb
	.byte	0x3b
	.byte	0xb
	.byte	0x39
	.byte	0xb
	.byte	0x11
	.byte	0x1
	.byte	0x12
	.byte	0x6
	.byte	0x40
	.byte	0x18
	.byte	0x7a
	.byte	0x19
	.byte	0
	.byte	0
	.byte	0
	.section	.debug_aranges,"",@progbits
	.4byte	0x2c
	.2byte	0x2
	.4byte	.Ldebug_info0
	.byte	0x4
	.byte	0
	.2byte	0
	.2byte	0
	.4byte	.Ltext0
	.4byte	.Letext0-.Ltext0
	.4byte	.LFB316
	.4byte	.LFE316-.LFB316
	.4byte	.LFB317
	.4byte	.LFE317-.LFB317
	.4byte	0
	.4byte	0
	.section	.debug_rnglists,"",@progbits
.Ldebug_ranges0:
	.4byte	.Ldebug_ranges3-.Ldebug_ranges2
.Ldebug_ranges2:
	.2byte	0x5
	.byte	0x4
	.byte	0
	.4byte	0
.LLRL0:
	.byte	0x6
	.4byte	.Ltext0
	.4byte	.Letext0
	.byte	0x6
	.4byte	.LFB316
	.4byte	.LFE316
	.byte	0x6
	.4byte	.LFB317
	.4byte	.LFE317
	.byte	0
.Ldebug_ranges3:
	.section	.debug_line,"",@progbits
.Ldebug_line0:
	.section	.debug_str,"MS",@progbits,1
.LASF17:
	.string	"initfir"
.LASF13:
	.string	"flush_cpu_dcache"
.LASF6:
	.string	"unsigned char"
.LASF8:
	.string	"long unsigned int"
.LASF7:
	.string	"short unsigned int"
.LASF15:
	.string	"GNU C17 12.1.0 -mabi=ilp32 -mtune=rocket -misa-spec=2.2 -march=rv32i -g -ffreestanding"
.LASF10:
	.string	"unsigned int"
.LASF11:
	.string	"taps"
.LASF9:
	.string	"long long unsigned int"
.LASF14:
	.string	"flush_cpu_icache"
.LASF12:
	.string	"outputsignal"
.LASF5:
	.string	"long long int"
.LASF3:
	.string	"short int"
.LASF16:
	.string	"uint32_t"
.LASF4:
	.string	"long int"
.LASF2:
	.string	"signed char"
	.section	.debug_line_str,"MS",@progbits,1
.LASF0:
	.string	"fir.c"
.LASF1:
	.string	"/home/ubuntu/Desktop/hkust-soc-lab-main/Lab4/Lab4-2/lab-caravel_fir/testbench/counter_la_fir"
	.ident	"GCC: (g1ea978e3066) 12.1.0"
