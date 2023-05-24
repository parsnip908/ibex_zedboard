module Mult(
  	input  logic [15:0]       rs1,
  	input  logic [15:0]       rs2,
	input ibex_pkg::Classif_e Classif_op_a,
	input ibex_pkg::Classif_e Classif_op_b,
	output logic [15:0]       rd

);
import ibex_pkg::*;

logic 		 sign_c;

logic [15:0] sig_c_mul;
logic [13:0] sig_c;
logic [7:0]  sig_a, sig_b;
logic [6:0]  sig_cc;

logic [7:0]  exp_a, exp_b, exp_c, exp_norm;

logic [15:0] C_norm;

assign sign_c = (rs1[15] ^ rs2[15]);

always_comb begin
	exp_a = rs1[14:7];
	sig_a = {1'b 1, rs1[6:0]};
	exp_b = rs2[14:7];
	sig_b =  {1'b 1, rs2[6:0]};
	sig_c_mul = sig_a * sig_b;
	exp_norm = (sig_c_mul[15])? 126: 127;
	exp_c = exp_a + exp_b - exp_norm;
	sig_c = sig_c_mul[15]? sig_c_mul[14:1]: sig_c_mul[13:0];
	casez (sig_c[7:0])
		8'b ?0??_???? : sig_cc = sig_c[13:7];
		8'b 0100_0000 : sig_cc = sig_c[13:7];
		default: sig_cc = sig_c[13:7] + 1;
	endcase
	C_norm = {sign_c, exp_c, sig_cc};
end

always_comb begin
	//////////// Edge Cases //////////
	if (Classif_op_a == NaN || Classif_op_b == NaN)
		rd = 16'b 0111111111000000; 
	else if (Classif_op_a == Inf || Classif_op_a == Neg_Inf || Classif_op_b == Inf || Classif_op_b == Neg_Inf) begin
		if (rs1[14:0] == 15'b000_0000_0000_0000 || rs2[14:0]== 15'b000_0000_0000_0000)
			rd = 16'b 0111111111000000;
		else
			rd = {sign_c, 15'b 111_1111_1000_0000};
	end
	else if (rs1[14:0] == 15'b 000000000000000 || rs2[14:0] == 15'b 000000000000000)
		rd = 16'b0000_0000_0000_0000;
	//////////// Normal Case ////////// 
	else 
		rd = C_norm;
end
    
endmodule
