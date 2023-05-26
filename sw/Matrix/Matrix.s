	.file	"Matrix.c"
	.option nopic
	.attribute arch, "rv32i2p0_m2p0_f2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.align	2
	.globl	main
	.hidden	main
	.type	main, @function
main:
	addi	sp,sp,-256
	lla	a7,.LANCHOR0
	lla	a3,.LANCHOR0+32
	mv	t4,sp
	lla	t3,.LANCHOR0+256
	mv	t5,t3
	fmv.w.x	fa2,zero
	lla	t1,.LANCHOR0+544
.L2:
	lla	a2,.LANCHOR0+512
	mv	a0,t3
	mv	a1,t4
.L4:
	mv	a6,a1
	mv	a4,a2
	mv	a5,a7
	fmv.w.x	fa4,zero
.L3:
	flw	fa5,0(a5)
	flw	fa3,0(a4)
	fmul.s	fa5,fa5,fa3
	fadd.s	fa4,fa4,fa5
	addi	a5,a5,4
	addi	a4,a4,32
	bne	a5,a3,.L3
	fsw	fa4,0(a6)
	flw	fa5,0(a0)
	fsub.s	fa4,fa4,fa5
	fadd.s	fa2,fa2,fa4
	addi	a1,a1,4
	addi	a0,a0,4
	addi	a2,a2,4
	bne	a2,t1,.L4
	addi	a7,a7,32
	addi	a3,a3,32
	addi	t4,t4,32
	addi	t3,t3,32
	bne	a7,t5,.L2
	li	a5,49152
	fsw	fa2,16(a5)
 #APP
# 75 "Matrix.c" 1
	fcvt.w.s t1, ft1

# 0 "" 2
 #NO_APP
.L6:
	j	.L6
	.size	main, .-main
	.hidden	matrixC
	.globl	matrixC
	.hidden	matrixB
	.globl	matrixB
	.hidden	matrixA
	.globl	matrixA
	.data
	.align	2
	.set	.LANCHOR0,. + 0
	.type	matrixA, @object
	.size	matrixA, 256
matrixA:
	.word	891551744
	.word	-704053248
	.word	2064449536
	.word	-2073755648
	.word	-486473728
	.word	-243924992
	.word	1475149824
	.word	-369557504
	.word	-2067464192
	.word	-135987200
	.word	-703463424
	.word	1777467392
	.word	2062024704
	.word	1230766080
	.word	1479344128
	.word	1650655232
	.word	578813952
	.word	1168769024
	.word	1050017792
	.word	940376064
	.word	-580190208
	.word	1241645056
	.word	-383975424
	.word	1227030528
	.word	181010432
	.word	-1108213760
	.word	-1287585792
	.word	-210239488
	.word	233504768
	.word	-104464384
	.word	45875200
	.word	-1710555136
	.word	1099235328
	.word	1614479360
	.word	847118336
	.word	-1678704640
	.word	123863040
	.word	1436483584
	.word	-1443364864
	.word	1453260800
	.word	-1067778048
	.word	843644928
	.word	-1059651584
	.word	798359552
	.word	-826146816
	.word	1517748224
	.word	-619577344
	.word	-2123563008
	.word	-1893793792
	.word	797245440
	.word	1499136000
	.word	-1371602944
	.word	1666711552
	.word	210632704
	.word	-1711669248
	.word	393412608
	.word	-1473314816
	.word	1449066496
	.word	-34144256
	.word	451280896
	.word	-1054277632
	.word	1826226176
	.word	-491454464
	.word	427360256
	.type	matrixC, @object
	.size	matrixC, 256
matrixC:
	.word	-120520704
	.word	-255328256
	.word	-104792064
	.word	-279248896
	.word	1714814976
	.word	2051014656
	.word	-315424768
	.word	-854130688
	.word	1991376896
	.word	1856569344
	.word	1678245888
	.word	-29294592
	.word	-139722752
	.word	-148766720
	.word	-556990464
	.word	-73596928
	.word	-214040576
	.word	2024013824
	.word	-57868288
	.word	-372834304
	.word	-129302528
	.word	-138412032
	.word	-22544384
	.word	-239337472
	.word	-237764608
	.word	-115277824
	.word	-388890624
	.word	-226885632
	.word	2076508160
	.word	-268238848
	.word	-9175040
	.word	-135331840
	.word	-210239488
	.word	2065956864
	.word	-61800448
	.word	-225968128
	.word	-99418112
	.word	-266076160
	.word	-107937792
	.word	-43646976
	.word	-459472896
	.word	1698824192
	.word	-121896960
	.word	-618463232
	.word	1438777344
	.word	2018770944
	.word	2020540416
	.word	-103219200
	.word	2033123328
	.word	-430178304
	.word	1861943296
	.word	-273612800
	.word	-729284608
	.word	1486159872
	.word	-321650688
	.word	2129395712
	.word	-324009984
	.word	1815150592
	.word	1989017600
	.word	1844838400
	.word	2097610752
	.word	-47710208
	.word	-287768576
	.word	-652083200
	.type	matrixB, @object
	.size	matrixB, 256
matrixB:
	.word	1585512448
	.word	1449328640
	.word	-1718812672
	.word	1376911360
	.word	-854786048
	.word	-851640320
	.word	-141819904
	.word	616955904
	.word	-760610816
	.word	1920401408
	.word	-611385344
	.word	-1764884480
	.word	1321533440
	.word	683474944
	.word	644153344
	.word	-2029387776
	.word	555745280
	.word	-862126080
	.word	-1206714368
	.word	-699203584
	.word	718602240
	.word	1051590656
	.word	1926168576
	.word	1695154176
	.word	1279000576
	.word	1636433920
	.word	886571008
	.word	310968320
	.word	1706426368
	.word	330170368
	.word	-584450048
	.word	-1099890688
	.word	1431240704
	.word	859439104
	.word	1259667456
	.word	1272512512
	.word	-78905344
	.word	-1584463872
	.word	1622605824
	.word	-1805910016
	.word	931725312
	.word	1053818880
	.word	-61800448
	.word	2131492864
	.word	-305659904
	.word	-314769408
	.word	8257536
	.word	-415694848
	.word	-153944064
	.word	-2005401600
	.word	1263075328
	.word	-1356201984
	.word	948305920
	.word	-224657408
	.word	-1138360320
	.word	-1264386048
	.word	-1833762816
	.word	222560256
	.word	919273472
	.word	-614858752
	.word	-487784448
	.word	-1234894848
	.word	-1797324800
	.word	-12320768
	.ident	"GCC: (g2ee5e430018) 12.2.0"
