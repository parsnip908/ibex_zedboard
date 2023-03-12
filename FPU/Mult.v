module Mult(
	input				 inst,
	input 	[15:0] A,
	input 	[15:0] B,
	output	reg [15:0] C

);

reg sign_c; 
reg [7:0] exp_a, exp_b, exp_c;
reg [7:0] sig_a, sig_b;
reg [15:0] sig_c;
reg [6:0] sig_cc;

wire Inf, Inf_B;
wire Neg_Inf, Neg_Inf_B;
wire NaN, NaN_B;
wire Normal, Normal_B;
wire Sub_Norm, Sub_Norm_B;

	Class class_A(.Num(A), .Inf(Inf), .Neg_Inf(Neg_Inf), .NaN(NaN), .Normal(Normal), .Sub_Norm(Sub_Norm));
	Class class_B(.Num(B), .Inf(Inf_B), .Neg_Inf(Neg_Inf_B), .NaN(NaN_B), .Normal(Normal_B), .Sub_Norm(Sub_Norm_B));

always @(*) begin

	sign_c = (A[15] ^ B[15]);
	if (NaN || NaN_B)
		C = 16'b 0111111111000000; 
	else if (A == 15'b000_0000_0000_0000 && B == 15'b000_0000_0000_0000)
        C = 16'b0000_0000_0000_0000; 
	else if (Inf || Neg_Inf || Inf_B || Neg_Inf_B) begin
		if (A == 15'b000_0000_0000_0000 || B == 15'b000_0000_0000_0000)
			C = 16'b 0111111111000000;
		else
			C = {sign_c, 15'b 111_1111_1000_0000};
	end
	
	else begin
		exp_a = A[14:7];
		sig_a = {1'b 1, A[6:0]};
		exp_b = B[14:7];
		sig_b =  {1'b 1, B[6:0]};
		sig_c = sig_a * sig_b;
		exp_c = (exp_a - 127) + (exp_b - 127) + sig_c[15] + 127;
		sig_c = sig_c >> sig_c[15];
		if (sig_c[6] == 1'b 0) 
			sig_cc = sig_c[13:7];
		else if (sig_c[6:0] == 7'b 1000000)
			sig_cc = (sig_c[7] == 1'b 0)? sig_c[13:7]: sig_c[13:7] + 1;
		else 
			sig_cc = sig_c[13:7] + 1; 
		C = {sign_c, exp_c, sig_cc};
	end
    
end
    
endmodule
