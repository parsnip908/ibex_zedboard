module Add_Sub (
  	input  logic [15:0]       A,
  	input  logic [15:0]       B,
	output logic [15:0]       C
);

// initial begin
// 	A = 16'b 0111111100000000;
// end
logic add_sub;
logic [15:0] a, C_norm;
logic [14:0] b;
logic [7:0] shift;
logic [3:0] shift_sub;
logic sign, sign_flip; 
logic [7:0] exp_a, exp_c;
logic [16:0] sig_a, sig_b, sig_b_tmp, sig_sum, sig_sub;
logic [14:0] sig_c;
logic [6:0] sig_cc;

wire Inf, Inf_B;
wire Neg_Inf, Neg_Inf_B;
wire NaN, NaN_B;
wire Sub_Norm, Sub_Norm_B;

	FP_Class class_A(.Num(A), .Inf(Inf), .Neg_Inf(Neg_Inf), .NaN(NaN), .Normal(), .Sub_Norm(Sub_Norm));
	FP_Class class_B(.Num(B), .Inf(Inf_B), .Neg_Inf(Neg_Inf_B), .NaN(NaN_B), .Normal(), .Sub_Norm(Sub_Norm_B));

assign add_sub = (A[15] == B[15]);

always_comb begin
	//////////// Assign bigger number to a //////////
	{a, b, sign_flip} = (A[14:0] >= B[14:0])? {A, B[14:0], 1'b 0}: {B, A[14:0],  1'b 1};
	exp_a = a[14:7];
	sig_a = (Sub_Norm)? {2'b 00, a[6:0], 8'h 00}:{2'b 01, a[6:0], 8'h 00};

	sig_b_tmp = (Sub_Norm_B)? {2'b 00, b[6:0], 8'h 00}:{2'b 01, b[6:0], 8'h 00};
	shift = (a[14:7] == b[14:7])? 0: (a[14:7] - b[14:7]);
	sig_b = (shift > 8)? 17'd 0: sig_b_tmp >> shift[3:0];
end

always_comb begin
	sig_sum = sig_a + sig_b;
	sig_sub = sig_a - sig_b;
	//////////// Calculate result sign //////////
	case ({A[15], B[15]}) 
		2'b 00: sign = 0;
		2'b 01: sign = sign_flip;
		2'b 10: sign = !sign_flip;
		2'b 11: sign = 1;
	endcase
	//////////// Add //////////
	if (add_sub == 1) begin 
		sig_c = sig_sum[16] ? sig_sum[15:1] : sig_sum[14:0];
		exp_c = exp_a + {7'd0, sig_sum[16]};	
	end 
	//////////// Sub //////////
	else begin 
		casez (sig_sub[15:8])
			8'b 0000_0000 : shift_sub = 8;
			8'b 0000_0001 : shift_sub = 7;
			8'b 0000_001? : shift_sub = 6;
			8'b 0000_01?? : shift_sub = 5;
			8'b 0000_1??? : shift_sub = 4;
			8'b 0001_???? : shift_sub = 3;
			8'b 001?_???? : shift_sub = 2;
			8'b 01??_???? : shift_sub = 1;
			8'b 1???_???? : shift_sub = 0;
			//default: shift_sub = 0;
		endcase
		/* verilator lint_off WIDTHTRUNC */
		sig_c = sig_sub << shift_sub;
		/* verilator lint_on WIDTHTRUNC */
		exp_c = exp_a - {4'b 0000, shift_sub};
	end
	//////////// Rounding //////////
	casez (sig_c[8:0])
		9'b ?0???_???? : sig_cc = sig_c[14:8];
		9'b 01000_0000 : sig_cc = sig_c[14:8];
		default: sig_cc = sig_c[14:8] + 1;
	endcase
	//////////// Output //////////
	if (b[14:0] == 15'b 000000000000000)
		C_norm = a;
	else if (a[14:0] == b[14:0] && ~add_sub)
		C_norm = 16'b 0000_0000_0000_0000;
	else
		C_norm = {sign, exp_c, sig_cc};
end 

always_comb begin
	//////////// Edge Cases //////////	
	if (NaN || NaN_B || (Neg_Inf & Inf_B) || (Inf & Neg_Inf_B)) 
		C = 16'b 0111111111000000;
	else if(Inf || Inf_B)
			C = 16'b 0111_1111_1000_0000;
	else if(Neg_Inf || Neg_Inf_B)
			C = 16'b 1111_1111_1000_0000;
	else 
		C = C_norm;
end
endmodule
