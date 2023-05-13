module Mult(
  	input  logic [15:0]       A,
  	input  logic [15:0]       B,
	output logic [15:0]       C

);
import ibex_pkg::*;

logic sign_c; 
logic [7:0] exp_a, exp_b, exp_c, exp_norm;
logic [7:0] sig_a, sig_b;
logic [15:0] sig_c_mul;
logic [13:0] sig_c;
logic [6:0] sig_cc;
logic [15:0] C_norm;

wire Inf, Inf_B;
wire Neg_Inf, Neg_Inf_B;
wire NaN, NaN_B;

	FP_Class class_A(.Num(A), .Inf(Inf), .Neg_Inf(Neg_Inf), .NaN(NaN), .Normal(), .Sub_Norm());
	FP_Class class_B(.Num(B), .Inf(Inf_B), .Neg_Inf(Neg_Inf_B), .NaN(NaN_B), .Normal(), .Sub_Norm());

assign sign_c = (A[15] ^ B[15]);

always_comb begin : normal_mult
	exp_a = A[14:7];
	sig_a = {1'b 1, A[6:0]};
	exp_b = B[14:7];
	sig_b =  {1'b 1, B[6:0]};
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
	if (NaN || NaN_B)
		C = 16'b 0111111111000000; 
	else if (Inf || Neg_Inf || Inf_B || Neg_Inf_B) begin
		if (A[14:0] == 15'b000_0000_0000_0000 || B[14:0]== 15'b000_0000_0000_0000)
			C = 16'b 0111111111000000;
		else
			C = {sign_c, 15'b 111_1111_1000_0000};
	end
	else if (A[14:0] == 15'b 000000000000000 || B[14:0] == 15'b 000000000000000)
		C = 16'b0000_0000_0000_0000;
	//////////// Normal Case ////////// 
	else 
		C = C_norm;
end
    
endmodule
