	.file	"mnist_file.c"
	.option nopic
	.attribute arch, "rv32i2p0_m2p0_f2p0_c2p0_zfh"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.align	1
	.globl	map_uint32
	.type	map_uint32, @function
map_uint32:
	addi	sp,sp,-32
	sw	s0,28(sp)
	addi	s0,sp,32
	sw	a0,-20(s0)
	lw	a5,-20(s0)
	srli	a4,a5,24
	lw	a5,-20(s0)
	srli	a3,a5,8
	li	a5,65536
	addi	a5,a5,-256
	and	a5,a3,a5
	or	a4,a4,a5
	lw	a5,-20(s0)
	slli	a3,a5,8
	li	a5,16711680
	and	a5,a3,a5
	or	a4,a4,a5
	lw	a5,-20(s0)
	slli	a5,a5,24
	or	a5,a4,a5
	mv	a0,a5
	lw	s0,28(sp)
	addi	sp,sp,32
	jr	ra
	.size	map_uint32, .-map_uint32
	.section	.rodata
	.align	2
.LC0:
	.string	"rb"
	.align	2
.LC1:
	.string	"Could not open file: %s\n"
	.align	2
.LC2:
	.string	"Could not read label file header from: %s\n"
	.align	2
.LC3:
	.string	"Invalid header read from label file: %s (%08X not %08X)\n"
	.align	2
.LC4:
	.string	"Could not allocated memory for %d labels\n"
	.align	2
.LC5:
	.string	"Could not read %d labels from: %s\n"
	.text
	.align	1
	.globl	get_labels
	.type	get_labels, @function
get_labels:
	addi	sp,sp,-48
	sw	ra,44(sp)
	sw	s0,40(sp)
	sw	s1,36(sp)
	addi	s0,sp,48
	sw	a0,-36(s0)
	sw	a1,-40(s0)
	lui	a5,%hi(.LC0)
	addi	a1,a5,%lo(.LC0)
	lw	a0,-36(s0)
	call	fopen
	sw	a0,-20(s0)
	lw	a5,-20(s0)
	bne	a5,zero,.L4
	lui	a5,%hi(_impure_ptr)
	lw	a5,%lo(_impure_ptr)(a5)
	lw	a4,12(a5)
	lw	a2,-36(s0)
	lui	a5,%hi(.LC1)
	addi	a1,a5,%lo(.LC1)
	mv	a0,a4
	call	fprintf
	li	a5,0
	j	.L10
.L4:
	addi	a5,s0,-32
	lw	a3,-20(s0)
	li	a2,1
	li	a1,8
	mv	a0,a5
	call	fread
	mv	a4,a0
	li	a5,1
	beq	a4,a5,.L6
	lui	a5,%hi(_impure_ptr)
	lw	a5,%lo(_impure_ptr)(a5)
	lw	a4,12(a5)
	lw	a2,-36(s0)
	lui	a5,%hi(.LC2)
	addi	a1,a5,%lo(.LC2)
	mv	a0,a4
	call	fprintf
	lw	a0,-20(s0)
	call	fclose
	li	a5,0
	j	.L10
.L6:
	lw	a5,-32(s0)
	mv	a0,a5
	call	map_uint32
	mv	a5,a0
	sw	a5,-32(s0)
	lw	a5,-28(s0)
	mv	a0,a5
	call	map_uint32
	mv	a5,a0
	sw	a5,-28(s0)
	lw	a4,-32(s0)
	li	a5,4096
	addi	a5,a5,-2047
	beq	a4,a5,.L7
	lui	a5,%hi(_impure_ptr)
	lw	a5,%lo(_impure_ptr)(a5)
	lw	a0,12(a5)
	lw	a3,-32(s0)
	li	a5,4096
	addi	a4,a5,-2047
	lw	a2,-36(s0)
	lui	a5,%hi(.LC3)
	addi	a1,a5,%lo(.LC3)
	call	fprintf
	lw	a0,-20(s0)
	call	fclose
	li	a5,0
	j	.L10
.L7:
	lw	a4,-28(s0)
	lw	a5,-40(s0)
	sw	a4,0(a5)
	lw	a5,-40(s0)
	lw	a5,0(a5)
	mv	a0,a5
	call	malloc
	mv	a5,a0
	sw	a5,-24(s0)
	lw	a5,-24(s0)
	bne	a5,zero,.L8
	lui	a5,%hi(_impure_ptr)
	lw	a5,%lo(_impure_ptr)(a5)
	lw	a4,12(a5)
	lw	a5,-40(s0)
	lw	a5,0(a5)
	mv	a2,a5
	lui	a5,%hi(.LC4)
	addi	a1,a5,%lo(.LC4)
	mv	a0,a4
	call	fprintf
	lw	a0,-20(s0)
	call	fclose
	li	a5,0
	j	.L10
.L8:
	lw	a5,-40(s0)
	lw	s1,0(a5)
	lw	a5,-40(s0)
	lw	a5,0(a5)
	lw	a3,-20(s0)
	mv	a2,a5
	li	a1,1
	lw	a0,-24(s0)
	call	fread
	mv	a5,a0
	beq	s1,a5,.L9
	lui	a5,%hi(_impure_ptr)
	lw	a5,%lo(_impure_ptr)(a5)
	lw	a4,12(a5)
	lw	a5,-40(s0)
	lw	a5,0(a5)
	lw	a3,-36(s0)
	mv	a2,a5
	lui	a5,%hi(.LC5)
	addi	a1,a5,%lo(.LC5)
	mv	a0,a4
	call	fprintf
	lw	a0,-24(s0)
	call	free
	lw	a0,-20(s0)
	call	fclose
	li	a5,0
	j	.L10
.L9:
	lw	a0,-20(s0)
	call	fclose
	lw	a5,-24(s0)
.L10:
	mv	a0,a5
	lw	ra,44(sp)
	lw	s0,40(sp)
	lw	s1,36(sp)
	addi	sp,sp,48
	jr	ra
	.size	get_labels, .-get_labels
	.section	.rodata
	.align	2
.LC6:
	.string	"Could not read image file header from: %s\n"
	.align	2
.LC7:
	.string	"Invalid header read from image file: %s (%08X not %08X)\n"
	.align	2
.LC8:
	.string	"Invalid number of image rows in image file %s (%d not %d)\n"
	.align	2
.LC9:
	.string	"Invalid number of image columns in image file %s (%d not %d)\n"
	.align	2
.LC10:
	.string	"Could not allocated memory for %d images\n"
	.align	2
.LC11:
	.string	"Could not read %d images from: %s\n"
	.text
	.align	1
	.globl	get_images
	.type	get_images, @function
get_images:
	addi	sp,sp,-64
	sw	ra,60(sp)
	sw	s0,56(sp)
	sw	s1,52(sp)
	addi	s0,sp,64
	sw	a0,-52(s0)
	sw	a1,-56(s0)
	lui	a5,%hi(.LC0)
	addi	a1,a5,%lo(.LC0)
	lw	a0,-52(s0)
	call	fopen
	sw	a0,-20(s0)
	lw	a5,-20(s0)
	bne	a5,zero,.L12
	lui	a5,%hi(_impure_ptr)
	lw	a5,%lo(_impure_ptr)(a5)
	lw	a4,12(a5)
	lw	a2,-52(s0)
	lui	a5,%hi(.LC1)
	addi	a1,a5,%lo(.LC1)
	mv	a0,a4
	call	fprintf
	li	a5,0
	j	.L20
.L12:
	addi	a5,s0,-40
	lw	a3,-20(s0)
	li	a2,1
	li	a1,16
	mv	a0,a5
	call	fread
	mv	a4,a0
	li	a5,1
	beq	a4,a5,.L14
	lui	a5,%hi(_impure_ptr)
	lw	a5,%lo(_impure_ptr)(a5)
	lw	a4,12(a5)
	lw	a2,-52(s0)
	lui	a5,%hi(.LC6)
	addi	a1,a5,%lo(.LC6)
	mv	a0,a4
	call	fprintf
	lw	a0,-20(s0)
	call	fclose
	li	a5,0
	j	.L20
.L14:
	lw	a5,-40(s0)
	mv	a0,a5
	call	map_uint32
	mv	a5,a0
	sw	a5,-40(s0)
	lw	a5,-36(s0)
	mv	a0,a5
	call	map_uint32
	mv	a5,a0
	sw	a5,-36(s0)
	lw	a5,-32(s0)
	mv	a0,a5
	call	map_uint32
	mv	a5,a0
	sw	a5,-32(s0)
	lw	a5,-28(s0)
	mv	a0,a5
	call	map_uint32
	mv	a5,a0
	sw	a5,-28(s0)
	lw	a4,-40(s0)
	li	a5,4096
	addi	a5,a5,-2045
	beq	a4,a5,.L15
	lui	a5,%hi(_impure_ptr)
	lw	a5,%lo(_impure_ptr)(a5)
	lw	a0,12(a5)
	lw	a3,-40(s0)
	li	a5,4096
	addi	a4,a5,-2045
	lw	a2,-52(s0)
	lui	a5,%hi(.LC7)
	addi	a1,a5,%lo(.LC7)
	call	fprintf
	lw	a0,-20(s0)
	call	fclose
	li	a5,0
	j	.L20
.L15:
	lw	a4,-32(s0)
	li	a5,28
	beq	a4,a5,.L16
	lui	a5,%hi(_impure_ptr)
	lw	a5,%lo(_impure_ptr)(a5)
	lw	a0,12(a5)
	lw	a5,-32(s0)
	li	a4,28
	mv	a3,a5
	lw	a2,-52(s0)
	lui	a5,%hi(.LC8)
	addi	a1,a5,%lo(.LC8)
	call	fprintf
.L16:
	lw	a4,-28(s0)
	li	a5,28
	beq	a4,a5,.L17
	lui	a5,%hi(_impure_ptr)
	lw	a5,%lo(_impure_ptr)(a5)
	lw	a0,12(a5)
	lw	a5,-28(s0)
	li	a4,28
	mv	a3,a5
	lw	a2,-52(s0)
	lui	a5,%hi(.LC9)
	addi	a1,a5,%lo(.LC9)
	call	fprintf
.L17:
	lw	a4,-36(s0)
	lw	a5,-56(s0)
	sw	a4,0(a5)
	lw	a5,-56(s0)
	lw	a4,0(a5)
	li	a5,784
	mul	a5,a4,a5
	mv	a0,a5
	call	malloc
	mv	a5,a0
	sw	a5,-24(s0)
	lw	a5,-24(s0)
	bne	a5,zero,.L18
	lui	a5,%hi(_impure_ptr)
	lw	a5,%lo(_impure_ptr)(a5)
	lw	a4,12(a5)
	lw	a5,-56(s0)
	lw	a5,0(a5)
	mv	a2,a5
	lui	a5,%hi(.LC10)
	addi	a1,a5,%lo(.LC10)
	mv	a0,a4
	call	fprintf
	lw	a0,-20(s0)
	call	fclose
	li	a5,0
	j	.L20
.L18:
	lw	a5,-56(s0)
	lw	s1,0(a5)
	lw	a5,-56(s0)
	lw	a5,0(a5)
	lw	a3,-20(s0)
	mv	a2,a5
	li	a1,784
	lw	a0,-24(s0)
	call	fread
	mv	a5,a0
	beq	s1,a5,.L19
	lui	a5,%hi(_impure_ptr)
	lw	a5,%lo(_impure_ptr)(a5)
	lw	a4,12(a5)
	lw	a5,-56(s0)
	lw	a5,0(a5)
	lw	a3,-52(s0)
	mv	a2,a5
	lui	a5,%hi(.LC11)
	addi	a1,a5,%lo(.LC11)
	mv	a0,a4
	call	fprintf
	lw	a0,-24(s0)
	call	free
	lw	a0,-20(s0)
	call	fclose
	li	a5,0
	j	.L20
.L19:
	lw	a0,-20(s0)
	call	fclose
	lw	a5,-24(s0)
.L20:
	mv	a0,a5
	lw	ra,60(sp)
	lw	s0,56(sp)
	lw	s1,52(sp)
	addi	sp,sp,64
	jr	ra
	.size	get_images, .-get_images
	.section	.rodata
	.align	2
.LC12:
	.string	"Number of images does not match number of labels (%d != %d)\n"
	.text
	.align	1
	.globl	mnist_get_dataset
	.type	mnist_get_dataset, @function
mnist_get_dataset:
	addi	sp,sp,-48
	sw	ra,44(sp)
	sw	s0,40(sp)
	addi	s0,sp,48
	sw	a0,-36(s0)
	sw	a1,-40(s0)
	li	a1,12
	li	a0,1
	call	calloc
	mv	a5,a0
	sw	a5,-20(s0)
	lw	a5,-20(s0)
	bne	a5,zero,.L22
	li	a5,0
	j	.L27
.L22:
	addi	a5,s0,-24
	mv	a1,a5
	lw	a0,-36(s0)
	call	get_images
	mv	a4,a0
	lw	a5,-20(s0)
	sw	a4,0(a5)
	lw	a5,-20(s0)
	lw	a5,0(a5)
	bne	a5,zero,.L24
	lw	a0,-20(s0)
	call	mnist_free_dataset
	li	a5,0
	j	.L27
.L24:
	addi	a5,s0,-28
	mv	a1,a5
	lw	a0,-40(s0)
	call	get_labels
	mv	a4,a0
	lw	a5,-20(s0)
	sw	a4,4(a5)
	lw	a5,-20(s0)
	lw	a5,4(a5)
	bne	a5,zero,.L25
	lw	a0,-20(s0)
	call	mnist_free_dataset
	li	a5,0
	j	.L27
.L25:
	lw	a4,-24(s0)
	lw	a5,-28(s0)
	beq	a4,a5,.L26
	lui	a5,%hi(_impure_ptr)
	lw	a5,%lo(_impure_ptr)(a5)
	lw	a4,12(a5)
	lw	a5,-24(s0)
	lw	a3,-28(s0)
	mv	a2,a5
	lui	a5,%hi(.LC12)
	addi	a1,a5,%lo(.LC12)
	mv	a0,a4
	call	fprintf
	lw	a0,-20(s0)
	call	mnist_free_dataset
	li	a5,0
	j	.L27
.L26:
	lw	a4,-24(s0)
	lw	a5,-20(s0)
	sw	a4,8(a5)
	lw	a5,-20(s0)
.L27:
	mv	a0,a5
	lw	ra,44(sp)
	lw	s0,40(sp)
	addi	sp,sp,48
	jr	ra
	.size	mnist_get_dataset, .-mnist_get_dataset
	.align	1
	.globl	mnist_free_dataset
	.type	mnist_free_dataset, @function
mnist_free_dataset:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	addi	s0,sp,32
	sw	a0,-20(s0)
	lw	a5,-20(s0)
	lw	a5,0(a5)
	mv	a0,a5
	call	free
	lw	a5,-20(s0)
	lw	a5,4(a5)
	mv	a0,a5
	call	free
	lw	a0,-20(s0)
	call	free
	nop
	lw	ra,28(sp)
	lw	s0,24(sp)
	addi	sp,sp,32
	jr	ra
	.size	mnist_free_dataset, .-mnist_free_dataset
	.align	1
	.globl	mnist_batch
	.type	mnist_batch, @function
mnist_batch:
	addi	sp,sp,-48
	sw	s0,44(sp)
	addi	s0,sp,48
	sw	a0,-36(s0)
	sw	a1,-40(s0)
	sw	a2,-44(s0)
	sw	a3,-48(s0)
	lw	a4,-44(s0)
	lw	a5,-48(s0)
	mul	a5,a4,a5
	sw	a5,-20(s0)
	lw	a5,-36(s0)
	lw	a4,8(a5)
	lw	a5,-20(s0)
	bgtu	a4,a5,.L30
	li	a5,0
	j	.L31
.L30:
	lw	a5,-36(s0)
	lw	a4,0(a5)
	lw	a3,-20(s0)
	li	a5,784
	mul	a5,a3,a5
	add	a4,a4,a5
	lw	a5,-40(s0)
	sw	a4,0(a5)
	lw	a5,-36(s0)
	lw	a4,4(a5)
	lw	a5,-20(s0)
	add	a4,a4,a5
	lw	a5,-40(s0)
	sw	a4,4(a5)
	lw	a4,-44(s0)
	lw	a5,-40(s0)
	sw	a4,8(a5)
	lw	a5,-40(s0)
	lw	a4,8(a5)
	lw	a5,-20(s0)
	add	a4,a4,a5
	lw	a5,-36(s0)
	lw	a5,8(a5)
	bleu	a4,a5,.L32
	lw	a5,-36(s0)
	lw	a4,8(a5)
	lw	a5,-20(s0)
	sub	a4,a4,a5
	lw	a5,-40(s0)
	sw	a4,8(a5)
.L32:
	li	a5,1
.L31:
	mv	a0,a5
	lw	s0,44(sp)
	addi	sp,sp,48
	jr	ra
	.size	mnist_batch, .-mnist_batch
	.ident	"GCC: (g2ee5e430018) 12.2.0"
