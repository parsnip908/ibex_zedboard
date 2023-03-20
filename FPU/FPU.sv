module FPU ( 
	input           operator_i,
	input  [15:0]	operand_a_i,
	input  [15:0]	operand_b_i,
	output [15:0]	out
);

wire [15:0] add_out, mult_out;

Add_Sub Add(
	.inst(operator_i), 
	.A(operand_a_i), 
	.B(operand_b_i), 
	.C(add_out)
	);
	
Mult Mult(
	.inst(operator_i), 
	.A(operand_a_i), 
	.B(operand_b_i), 
	.C(mult_out)
	);
	
assign out = (inst)? add_out:mult_out;
endmodule 