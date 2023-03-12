module FPU ( 
	input           inst,
	input  [15:0]	add_op_a,
	input  [15:0]	add_op_b,
	input  [15:0]	mult_op_a,
	input  [15:0]	mult_op_b,
//	input  [2:0]	round_mode,
//	input  [5:0]	cmd,
//	input  [1:0]	fmt,
//	output [5:0]	exc,
	output [15:0]	add_out,
	output [15:0]	mult_out	
);

	Add_Sub Add(.inst(inst), .A(add_op_a), .B(add_op_b), .C(add_out));
	Mult Mult(.inst(inst), .A(mult_op_a), .B(mult_op_b), .C(mult_out));
endmodule 