module Mult_32(
  	input  logic [31:0]       rs1,
  	input  logic [31:0]       rs2,
	input ibex_pkg::Classif_e Classif_op_a,
	input ibex_pkg::Classif_e Classif_op_b,
	output logic [31:0]       rd

);
import ibex_pkg::*;

logic 		 sign_c;

logic [47:0] sig_c_mul;
logic [45:0] sig_c;
logic [23:0]  sig_a, sig_b;
logic [22:0]  sig_cc;

logic [7:0]  exp_a, exp_b, exp_c, exp_norm;

logic [31:0] C_norm;

assign sign_c = (rs1[31] ^ rs2[31]);

always_comb begin
	exp_a = rs1[30:23];
	sig_a = {1'b 1, rs1[22:0]};
	exp_b = rs2[30:23];
	sig_b =  {1'b 1, rs2[22:0]};
	sig_c_mul = sig_a * sig_b;
	exp_norm = (sig_c_mul[47])? 126: 127;
	exp_c = exp_a + exp_b - exp_norm;
	sig_c = sig_c_mul[47]? sig_c_mul[46:1]: sig_c_mul[45:0];
	casez (sig_c[24:0])
		25'b ?0???_????_????_????_????_???? : sig_cc = sig_c[45:23];
		25'b 01000_0000_0000_0000_0000_0000 : sig_cc = sig_c[45:23];
		default: sig_cc = sig_c[45:23] + 1;
	endcase
	C_norm = {sign_c, exp_c, sig_cc};
end

always_comb begin
	//////////// Edge Cases //////////
	if (Classif_op_a == NaN || Classif_op_b == NaN)
		rd = 16'b 0111111111000000_0000_0000_0000_0000_0000; 
	else if (Classif_op_a == Inf || Classif_op_a == Neg_Inf || Classif_op_b == Inf || Classif_op_b == Neg_Inf) begin
		if (rs1[30:0] == 15'b000_0000_0000_0000 || rs2[30:0]== 15'b000_0000_0000_0000)
			rd = 16'b 0111111111000000_0000_0000_0000_0000_0000;
		else
			rd = {sign_c, 31'b 111_1111_1000_0000_0000_0000_0000_0000_0000};
	end
	else if (rs1[30:0] == 31'd0 || rs2[30:0] == 31'd0)
		rd = 32'd 0;
	//////////// Normal Case ////////// 
	else 
		rd = C_norm;
end
    
endmodule
