module Add_Sub (
	input  ibex_pkg::fp_alu_op_e operator_i,
  	input  logic [15:0]       A,
  	input  logic [15:0]       B,
	output logic [15:0]       C
);
import ibex_pkg::*;

reg add_sub;
reg [15:0] a, b;
reg [7:0] shift, shift_c;
reg [3:0] shift_sub;
reg  sign, sign_flip; 
reg [7:0] exp_a, exp_b, exp_c;
reg [9:0] sig_a, sig_b, sig_c;
reg [6:0] sig_cc;

wire Inf, Inf_B;
wire Neg_Inf, Neg_Inf_B;
wire NaN, NaN_B;
wire Normal, Normal_B;
wire Sub_Norm, Sub_Norm_B;

	FP_Class class_A(.Num(A), .Inf(Inf), .Neg_Inf(Neg_Inf), .NaN(NaN), .Normal(Normal), .Sub_Norm(Sub_Norm));
	FP_Class class_B(.Num(B), .Inf(Inf_B), .Neg_Inf(Neg_Inf_B), .NaN(NaN_B), .Normal(Normal_B), .Sub_Norm(Sub_Norm_B));

always @(*) begin

	if(operator_i == (FP_ALU_ADD || FP_ALU_SUB)) begin
		//////////// Add or Sub //////////	
			add_sub = (operator_i == FP_ALU_ADD)? 1:0;
		//////////// Edge Cases //////////	
		if (NaN || NaN_B) 
			C = 16'b 0111111111000000;
		else if (Inf || Inf_B || Neg_Inf || Neg_Inf_B) begin
			if((Inf & Inf_B & ~add_sub) || (Neg_Inf & Neg_Inf_B & ~add_sub) || (Neg_Inf & Inf_B & add_sub) || (Inf & Neg_Inf_B & add_sub))
				C = 16'b 0111111111000000;
			else begin
				if(Inf || Inf_B)
					C = 16'b 0111_1111_1000_0000;
				if(Neg_Inf || Neg_Inf_B)
					C = 16'b 1111_1111_1000_0000;
			end
		end
		//////////// Normal & Sub_Normal Cases //////////
		else begin
			//////////// Assign bigger number to a //////////
			{a, b, sign_flip} = (A[14:0] >= B[14:0])? {A, B, 1'b 0}: {B, A,  1'b 1};
			exp_a = a[14:7];
			sig_a = (Sub_Norm)? {2'b 00,a[6:0], 1'b 0}:{2'b 01,a[6:0], 1'b 0};

			exp_b = b[14:7];
			sig_b = (Sub_Norm_B)? {2'b 00,b[6:0], 1'b 0}:{2'b 01,b[6:0], 1'b 0};
			shift = (a[14:7] == b[14:7])? 0: (a[14:7] - b[14:7]);
			sig_b = sig_b >> shift;
			//////////// Reassing operation based on sign //////////
			case ({add_sub, A[15], B[15]}) 
				3'b 000:    begin
							add_sub = 0;
							sign = sign_flip;
							end
				3'b 001:    begin
							add_sub = 1;
							sign = 0;
							end
				3'b 010:    begin
							add_sub = 1;
							sign = 1;
							end
				3'b 011:    begin
							add_sub = 0;
							sign = !sign_flip;
							end
				3'b 100:    begin
							add_sub = 1;
							sign = 0;
							end
				3'b 101:    begin
							add_sub = 0;
							sign = sign_flip;
							end
				3'b 110:    begin
							add_sub = 0;
							sign = !sign_flip;
							end
				3'b 111:    begin
							add_sub = 1;
							sign = 1;
							end
			endcase
			//////////// Add //////////
			if (add_sub == 1) begin 
				if (b == 15'b 000000000000000)
					C = a;
				else begin
					sig_c = sig_a + sig_b;
					shift_c = (sig_c[9] == 1)? 1:0;
					sig_c = sig_c >> (shift_c);
					sig_cc = (sig_c[0] == 1)? ((sig_c[1] == 1)? sig_c[7:1] + 1:sig_c[7:1]) : sig_c[7:1];
					exp_c = exp_a + shift_c;
					C = {sign, exp_c, sig_cc};
				end
			end 
			//////////// Sub //////////
			else begin 
				if (b == 15'b 000000000000000)
					C = {sign, a[14:0]};
				else begin
					sig_c = sig_a - sig_b;
				if (sig_c[8] == 1'b 1) shift_sub = 0;
				else if (sig_c[7:1] == 7'b 0000000) shift_sub = 7;
				else if (sig_c[7:1] == 7'b 0000001) shift_sub = 6;
				else if (sig_c[7:2] == 6'b 000001) shift_sub = 5;
				else if (sig_c[7:3] == 5'b 00001) shift_sub = 4;
				else if (sig_c[7:4] == 4'b 0001) shift_sub = 3;
				else if (sig_c[7:5] == 3'b 001) shift_sub = 2;
				else if (sig_c[7:6] == 2'b 01) shift_sub = 1;
				else if (sig_c[7] == 1'b 1) shift_sub = 0;
				else shift_sub = 0;
					/*case (sig_c[7:1])
						7'b 0000000 : shift_sub = 7;
						7'b 0000001 : shift_sub = 6;
						7'b 000001x : shift_sub = 5;
						7'b 00001xx : shift_sub = 4;
						7'b 0001xxx : shift_sub = 3;
						7'b 001xxxx : shift_sub = 2;
						7'b 01xxxxx : shift_sub = 1;
						7'b 1xxxxxx : shift_sub = 0;
						default : shift_sub = 0; 
					endcase*/
					shift_sub = (sig_c[8] == 0)? shift_sub + 1: shift_sub;
					sig_c = sig_c << shift_sub;
					sig_cc = (sig_c[0] == 1)? ((sig_c[1] == 1)? sig_c[7:1] + 1:sig_c[7:1]) : sig_c[7:1];
					exp_c = exp_a - shift_sub;
					C = {sign, exp_c, sig_cc};
				end
			end
		end
	end
  //$display("sig_a = %b, sig_b = %b, C = %b, shift = %d, shift_c = %d, shift_sub = %d", sig_a, sig_b, C, shift, shift_c, shift_sub);
end
  
endmodule 