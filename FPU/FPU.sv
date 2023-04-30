module FPU ( 
	input  ibex_pkg::fp_alu_op_e operator_i,
  	input  logic [15:0]       operand_a_i,
  	input  logic [15:0]       operand_b_i,
	output logic [15:0]       result_o
);

import ibex_pkg::*;

wire [15:0] add_sub_out, mult_out;

Add_Sub Add(
	.operator_i(operator_i), 
	.A(operand_a_i), 
	.B(operand_b_i), 
	.C(add_sub_out)
	);
	
Mult Mult(
	.operator_i(operator_i), 
	.A(operand_a_i), 
	.B(operand_b_i), 
	.C(mult_out)
	);
	
assign result_o = (operator_i == FP_ALU_ADD || operator_i == FP_ALU_SUB)? add_sub_out : mult_out;
endmodule