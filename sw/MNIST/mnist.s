	.file	"mnist.c"
	.option nopic
	.attribute arch, "rv32i2p0_m2p0_f2p0_c2p0_zfh"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.globl	train_images_file
	.section	.rodata
	.align	2
.LC0:
	.string	"data/train-images-idx3-ubyte"
	.section	.sdata,"aw"
	.align	2
	.type	train_images_file, @object
	.size	train_images_file, 4
train_images_file:
	.word	.LC0
	.globl	train_labels_file
	.section	.rodata
	.align	2
.LC1:
	.string	"data/train-labels-idx1-ubyte"
	.section	.sdata
	.align	2
	.type	train_labels_file, @object
	.size	train_labels_file, 4
train_labels_file:
	.word	.LC1
	.globl	test_images_file
	.section	.rodata
	.align	2
.LC2:
	.string	"data/t10k-images-idx3-ubyte"
	.section	.sdata
	.align	2
	.type	test_images_file, @object
	.size	test_images_file, 4
test_images_file:
	.word	.LC2
	.globl	test_labels_file
	.section	.rodata
	.align	2
.LC3:
	.string	"data/t10k-labels-idx1-ubyte"
	.section	.sdata
	.align	2
	.type	test_labels_file, @object
	.size	test_labels_file, 4
test_labels_file:
	.word	.LC3
	.globl	__divsf3
	.text
	.align	1
	.globl	calculate_accuracy
	.type	calculate_accuracy, @function
calculate_accuracy:
	addi	sp,sp,-96
	sw	ra,92(sp)
	sw	s0,88(sp)
	addi	s0,sp,96
	sw	a0,-84(s0)
	sw	a1,-88(s0)
	sw	zero,-24(s0)
	sw	zero,-32(s0)
	j	.L2
.L8:
	lw	a5,-84(s0)
	lw	a4,0(a5)
	lw	a3,-24(s0)
	li	a5,784
	mul	a5,a3,a5
	add	a5,a4,a5
	addi	a4,s0,-76
	mv	a2,a4
	lw	a1,-88(s0)
	mv	a0,a5
	call	neural_network_hypothesis
	sw	zero,-28(s0)
	sw	zero,-36(s0)
	flw	fa5,-76(s0)
	fsw	fa5,-20(s0)
	j	.L3
.L6:
	lw	a5,-28(s0)
	slli	a5,a5,2
	addi	a5,a5,-16
	add	a5,a5,s0
	flw	fa5,-60(a5)
	flw	fa4,-20(s0)
	flt.s	a5,fa4,fa5
	beq	a5,zero,.L4
	lw	a5,-28(s0)
	slli	a5,a5,2
	addi	a5,a5,-16
	add	a5,a5,s0
	flw	fa5,-60(a5)
	fsw	fa5,-20(s0)
	lw	a5,-28(s0)
	sw	a5,-36(s0)
.L4:
	lw	a5,-28(s0)
	addi	a5,a5,1
	sw	a5,-28(s0)
.L3:
	lw	a4,-28(s0)
	li	a5,9
	ble	a4,a5,.L6
	lw	a5,-84(s0)
	lw	a4,4(a5)
	lw	a5,-24(s0)
	add	a5,a4,a5
	lbu	a5,0(a5)
	mv	a4,a5
	lw	a5,-36(s0)
	bne	a5,a4,.L7
	lw	a5,-32(s0)
	addi	a5,a5,1
	sw	a5,-32(s0)
.L7:
	lw	a5,-24(s0)
	addi	a5,a5,1
	sw	a5,-24(s0)
.L2:
	lw	a5,-84(s0)
	lw	a4,8(a5)
	lw	a5,-24(s0)
	bgtu	a4,a5,.L8
	lw	a5,-32(s0)
	fcvt.s.w	fa5,a5
	lw	a5,-84(s0)
	lw	a5,8(a5)
	fcvt.s.wu	fa4,a5
	fmv.x.w	a1,fa4
	fmv.x.w	a0,fa5
	call	__divsf3
	fmv.w.x	fa5,a0
	fmv.x.w	a0,fa5
	lw	ra,92(sp)
	lw	s0,88(sp)
	addi	sp,sp,96
	jr	ra
	.size	calculate_accuracy, .-calculate_accuracy
	.globl	__extendsfdf2
	.section	.rodata
	.align	2
.LC5:
	.string	"Step %04d\tAverage Loss: %.2f\tAccuracy: %.3f\n"
	.text
	.align	1
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	sw	s2,20(sp)
	sw	s3,16(sp)
	addi	s0,sp,32
	li	t0,-32768
	addi	t0,t0,1328
	add	sp,sp,t0
	li	a5,-32768
	addi	a5,a5,-16
	add	a5,a5,s0
	sw	a0,1324(a5)
	li	a5,-32768
	addi	a5,a5,-16
	add	a5,a5,s0
	sw	a1,1320(a5)
	lui	a5,%hi(train_images_file)
	lw	a4,%lo(train_images_file)(a5)
	lui	a5,%hi(train_labels_file)
	lw	a5,%lo(train_labels_file)(a5)
	mv	a1,a5
	mv	a0,a4
	call	mnist_get_dataset
	sw	a0,-24(s0)
	lui	a5,%hi(test_images_file)
	lw	a4,%lo(test_images_file)(a5)
	lui	a5,%hi(test_labels_file)
	lw	a5,%lo(test_labels_file)(a5)
	mv	a1,a5
	mv	a0,a4
	call	mnist_get_dataset
	sw	a0,-28(s0)
	li	a5,-32768
	addi	a5,a5,1332
	addi	a5,a5,-16
	add	a5,a5,s0
	mv	a0,a5
	call	neural_network_random_weights
	lw	a5,-24(s0)
	lw	a4,8(a5)
	li	a5,100
	divu	a5,a4,a5
	sw	a5,-32(s0)
	sw	zero,-20(s0)
	j	.L12
.L13:
	lw	a4,-20(s0)
	lw	a5,-32(s0)
	rem	a4,a4,a5
	addi	a5,s0,-52
	mv	a3,a4
	li	a2,100
	mv	a1,a5
	lw	a0,-24(s0)
	call	mnist_batch
	lui	a5,%hi(.LC4)
	flw	fa5,%lo(.LC4)(a5)
	li	a5,-32768
	addi	a5,a5,1332
	addi	a5,a5,-16
	add	a4,a5,s0
	addi	a5,s0,-52
	fmv.x.w	a2,fa5
	mv	a1,a4
	mv	a0,a5
	call	neural_network_training_step
	sw	a0,-36(s0)
	li	a5,-32768
	addi	a5,a5,1332
	addi	a5,a5,-16
	add	a5,a5,s0
	mv	a1,a5
	lw	a0,-28(s0)
	call	calculate_accuracy
	sw	a0,-40(s0)
	lw	a5,-44(s0)
	fcvt.s.wu	fa5,a5
	fmv.x.w	a1,fa5
	lw	a0,-36(s0)
	call	__divsf3
	fmv.w.x	fa5,a0
	fmv.x.w	a0,fa5
	call	__extendsfdf2
	mv	s2,a0
	mv	s3,a1
	lw	a0,-40(s0)
	call	__extendsfdf2
	mv	a4,a0
	mv	a5,a1
	mv	a2,s2
	mv	a3,s3
	lw	a1,-20(s0)
	lui	a0,%hi(.LC5)
	addi	a0,a0,%lo(.LC5)
	call	printf
	lw	a5,-20(s0)
	addi	a5,a5,1
	sw	a5,-20(s0)
.L12:
	lw	a4,-20(s0)
	li	a5,999
	ble	a4,a5,.L13
	lw	a0,-24(s0)
	call	mnist_free_dataset
	lw	a0,-28(s0)
	call	mnist_free_dataset
	li	a5,0
	mv	a0,a5
	li	t0,32768
	addi	t0,t0,-1328
	add	sp,sp,t0
	lw	ra,28(sp)
	lw	s0,24(sp)
	lw	s2,20(sp)
	lw	s3,16(sp)
	addi	sp,sp,32
	jr	ra
	.size	main, .-main
	.section	.rodata
	.align	2
.LC4:
	.word	1056964608
	.ident	"GCC: (g2ee5e430018) 12.2.0"
