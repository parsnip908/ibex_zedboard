module Add_Sub (
	input  ibex_pkg::fp_alu_op_e operator_i,
  	input  logic [15:0]       A,
  	input  logic [15:0]       B,
	output logic [15:0]       C
);
import ibex_pkg::*;

logic add_sub, add_sub_tmp;
logic [15:0] a, C_norm;
logic [14:0] b;
logic [7:0] shift, shift_c;
logic [3:0] shift_sub;
logic  sign, sign_flip; 
logic [7:0] exp_a, exp_c;
logic [24:0] sig_a, sig_b, sig_c;
logic [6:0] sig_cc;

wire Inf, Inf_B;
wire Neg_Inf, Neg_Inf_B;
wire NaN, NaN_B;
wire Sub_Norm, Sub_Norm_B;

	FP_Class class_A(.Num(A), .Inf(Inf), .Neg_Inf(Neg_Inf), .NaN(NaN), .Normal(), .Sub_Norm(Sub_Norm));
	FP_Class class_B(.Num(B), .Inf(Inf_B), .Neg_Inf(Neg_Inf_B), .NaN(NaN_B), .Normal(), .Sub_Norm(Sub_Norm_B));

always_comb begin
	//////////// Add or Sub //////////	
	add_sub_tmp = (operator_i == FP_ALU_ADD || operator_i == FP_ALU_FMADD)? 1:0;
	//////////// Assign bigger number to a //////////
	{a, b, sign_flip} = (A[14:0] >= B[14:0])? {A, B[14:0], 1'b 0}: {B, A[14:0],  1'b 1};
	exp_a = a[14:7];
	sig_a = (Sub_Norm)? {2'b 00,a[6:0], 16'b 0000_0000_0000_0000}:{2'b 01,a[6:0], 16'b 0000_0000_0000_0000};

	sig_b = (Sub_Norm_B)? {2'b 00,b[6:0], 16'b 0000_0000_0000_0000}:{2'b 01,b[6:0], 16'b 0000_0000_0000_0000};
	shift = (a[14:7] == b[14:7])? 0: (a[14:7] - b[14:7]);
	sig_b = sig_b >> shift;
	//////////// Reassign operation based on sign //////////
	case ({add_sub_tmp, A[15], B[15]}) 
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
		if (b[14:0] == 15'b 000000000000000)
			C_norm = a;
		else begin
			sig_c = sig_a + sig_b;
			shift_c = (sig_c[24] == 1)? 1:0;
			sig_c = sig_c >> (shift_c);
			case (sig_c[15:0])
				16'b 0000_0000_0000_0000 :	sig_cc = sig_c[22:16];
				16'b 1000_0000_0000_0000 :	sig_cc = (sig_c[16] == 1)? sig_c[22:16] + 1 : sig_c[22:16];
				default: sig_cc = (sig_c[15])? sig_c[22:16] + 1 : sig_c[22:16];
			endcase 
			exp_c = exp_a + shift_c;
			C_norm = {sign, exp_c, sig_cc};
		end
	end 
	//////////// Sub //////////
	else begin 
		if (b[14:0] == 15'b 000000000000000)
			C_norm = {sign, a[14:0]};
		else if (a[14:0] == b[14:0])
			C_norm = 16'b 0000_0000_0000_0000;
		else begin
			sig_c = sig_a - sig_b;
			casez (sig_c[23:16])
				8'b 0000_0000 : shift_sub = 7;
				8'b 0000_0001 : shift_sub = 6;
				8'b 0000_001? : shift_sub = 5;
				8'b 0000_01?? : shift_sub = 4;
				8'b 0000_1??? : shift_sub = 3;
				8'b 0001_???? : shift_sub = 2;
				8'b 001?_???? : shift_sub = 1;
				8'b 01??_???? : shift_sub = 0;
				8'b 1???_???? : shift_sub = 0;
				default: shift_sub = 0;
			endcase
			/*if (sig_c[23] == 1'b 1) shift_sub = 0;
			else if (sig_c[22:16] == 7'b 0000000) shift_sub = 7;
			else if (sig_c[22:16] == 7'b 0000001) shift_sub = 6;
			else if (sig_c[22:17] == 6'b 000001) shift_sub = 5;
			else if (sig_c[22:18] == 5'b 00001) shift_sub = 4;
			else if (sig_c[22:19] == 4'b 0001) shift_sub = 3;
			else if (sig_c[22:20] == 3'b 001) shift_sub = 2;
			else if (sig_c[22:21] == 2'b 01) shift_sub = 1;
			else if (sig_c[22] == 1'b 1) shift_sub = 0;
			else shift_sub = 0;
			*/
			shift_sub = (sig_c[23] == 0)? shift_sub + 1: shift_sub;
			sig_c = sig_c << shift_sub;
			case (sig_c[15:0])
				16'b 0000_0000_0000_0000 :	sig_cc = sig_c[22:16];
				16'b 1000_0000_0000_0000 :	sig_cc = (sig_c[16] == 1)? sig_c[22:16] + 1 : sig_c[22:16];
				default: sig_cc = (sig_c[15])? sig_c[22:16] + 1 : sig_c[22:16];
			endcase 
			exp_c = exp_a - {4'b 0000, shift_sub};
			C_norm = {sign, exp_c, sig_cc};
		end
	end
  //$display("sig_a = %b, sig_b = %b, C_norm = %b, shift = %d, shift_c = %d, shift_sub = %d", sig_a, sig_b, C_norm, shift, shift_c, shift_sub);
end 

always_comb begin
	//////////// Edge Cases //////////	
	if (NaN || NaN_B) 
		C = 16'b 0111111111000000;
	else if (Inf || Inf_B || Neg_Inf || Neg_Inf_B) begin
		if((Inf & Inf_B & ~add_sub) || (Neg_Inf & Neg_Inf_B & ~add_sub) || (Neg_Inf & Inf_B & add_sub) || (Inf & Neg_Inf_B & add_sub))
			C = 16'b 0111111111000000;
		else begin
			if(Inf || Inf_B)
				C = 16'b 0111_1111_1000_0000;
			else
				C = 16'b 1111_1111_1000_0000;
		end
	end
	else 
		C = C_norm;
end
endmodule
