module FPU ( 
	input  ibex_pkg::fp_alu_op_e operator_i,
  	input  logic [31:0]			 operand_a_i,
  	input  logic [15:0]          operand_b_i,
	input  logic [1:0]           mode_i,
	output logic [31:0]          result_o
);

import ibex_pkg::*;
Classif_e Classif_a;
Classif_e Classif_b;

logic cmp_o;
logic [15:0] operand_a, operand_b, add_sub_o, mult_o, fp_o, sgnj_o; 
logic [31:0] int_o;



assign operand_a = operand_a_i[31:16];
assign operand_b = (operator_i == FP_ALU_SUB)? {~operand_b_i[15], operand_b_i[14:0]} : operand_b_i;


FP_Class class_A(
	.Num(operand_a), 
	.Classif(Classif_a)
	);

FP_Class class_B(
	.Num(operand_b), 
	.Classif(Classif_b)
	);

Add_Sub Add(
	.rs1(operand_a), 
	.rs2(operand_b), 
	.rd(add_sub_o),
	.Classif_op_a(Classif_a),
	.Classif_op_b(Classif_b)
	);
	
Mult Mult(
	.rs1(operand_a), 
	.rs2(operand_b), 
	.rd(mult_o),
	.Classif_op_a(Classif_a),
	.Classif_op_b(Classif_b)
	);

int_to_fp cvt_S_W(
	.int_i(operand_a_i),
	.mode_i(mode_i[0]),
	.fp_o(fp_o)
);

fp_to_int cvt_W_S(
	.fp_i(operand_a),
	.int_o(int_o),
	.Classif_op_a(Classif_a),
	.flag()
);

CMP CMP(
	.rs1(operand_a),
	.rs2(operand_b),
	.rd(cmp_o)
);

SGNJ SGNJ (
	.rs1(operand_a),
	.rs2(operand_b[15]),
	.mode_i(mode_i),
	.rd(sgnj_o)
);

always_comb begin
	case (operator_i)
		FP_ALU_ADD: 	result_o = {add_sub_o, 16'd0};
		FP_ALU_SUB: 	result_o = {add_sub_o, 16'd0};
		FP_ALU_MUL: 	result_o = {mult_o, 16'd0};
		// FP_ALU_MADD:
		FP_ALU_MINMAX:  result_o = 32'd0;
		FP_ALU_SGNJ:    result_o = {sgnj_o, 16'd 0};
		FP_ALU_CMP:     result_o = {31'd0, cmp_o};
		FP_ALU_CVT:		result_o = (mode_i[1])? {fp_o, 16'd0} : int_o;
		FP_ALU_CLASS:   result_o = {29'd0, Classif_a};
		default: 	result_o = 32'd0;
	endcase
end
endmodule
