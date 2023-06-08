module Add_Sub_32 (
	input  logic [31:0]       rs1,
	input  logic [31:0]       rs2,
	input ibex_pkg::Classif_e Classif_op_a,
	input ibex_pkg::Classif_e Classif_op_b,
	output logic [31:0]       rd
);

import ibex_pkg::*;

logic 		 add_sub;
logic 		 sign;
logic 		 sign_flip;

logic [4:0]  shift_sub;
logic [7:0]  shift;

logic [31:0] a;
logic [31:0] C_norm;
logic [30:0] b;

logic [48:0] sig_a, sig_b, sig_b_tmp, sig_sum;
logic [47:0] sig_sub;
logic [46:0] sig_c;
logic [7:0]  exp_a, exp_c;
logic [22:0]  sig_cc;

assign add_sub = (rs1[31] == rs2[31]);

always_comb begin
	//////////// Assign bigger number to a //////////
	{a, b, sign_flip} = (rs1[30:0] >= rs2[30:0])? {rs1, rs2[30:0], 1'b 0}: {rs2, rs1[30:0],  1'b 1};
	exp_a = a[30:23];
	sig_a = (Classif_op_a == Sub_Norm)? {2'b 00, a[22:0], 24'd 0}:{2'b 01, a[22:0], 24'd 0};

	sig_b_tmp = (Classif_op_b == Sub_Norm)? {2'b 00, b[22:0], 24'd 0}:{2'b 01, b[22:0], 24'd 0};
	shift = (a[30:23] == b[30:23])? 0: (a[30:23] - b[30:23]);
	sig_b = (shift > 24)? 32'd 0: sig_b_tmp >> shift[4:0];
end

always_comb begin
	sig_sum = sig_a + sig_b;
	sig_sub = sig_a[47:0] - sig_b[47:0];
	//////////// Calculate result sign //////////
	case ({rs1[31], rs2[31]}) 
		2'b 00: sign = 0;
		2'b 01: sign = sign_flip;
		2'b 10: sign = !sign_flip;
		2'b 11: sign = 1;
	endcase
	//////////// Add //////////
	if (add_sub == 1) begin 
		sig_c = sig_sum[48] ? sig_sum[47:1] : sig_sum[46:0];
		exp_c = sig_sum[48] ? exp_a + 7'd1  : exp_a;
	end 
	//////////// Sub //////////
	else begin 
		casez (sig_sub[47:24])
			24'b000000000000000000000000: shift_sub = 5'd24;
            24'b000000000000000000000001: shift_sub = 5'd23;
            24'b00000000000000000000001?: shift_sub = 5'd22;
            24'b0000000000000000000001??: shift_sub = 5'd21;
            24'b000000000000000000001???: shift_sub = 5'd20;
            24'b00000000000000000001????: shift_sub = 5'd19;
            24'b0000000000000000001?????: shift_sub = 5'd18;
            24'b000000000000000001??????: shift_sub = 5'd17;
            24'b00000000000000001???????: shift_sub = 5'd16;
            24'b0000000000000001????????: shift_sub = 5'd15;
            24'b000000000000001?????????: shift_sub = 5'd14;
            24'b00000000000001??????????: shift_sub = 5'd13;
            24'b0000000000001???????????: shift_sub = 5'd12;
            24'b000000000001????????????: shift_sub = 5'd11;
            24'b00000000001?????????????: shift_sub = 5'd10;
            24'b0000000001??????????????: shift_sub = 5'd9;
            24'b000000001???????????????: shift_sub = 5'd8;
            24'b00000001????????????????: shift_sub = 5'd7;
            24'b0000001?????????????????: shift_sub = 5'd6;
            24'b000001??????????????????: shift_sub = 5'd5;
            24'b00001???????????????????: shift_sub = 5'd4;
            24'b0001????????????????????: shift_sub = 5'd3;
            24'b001?????????????????????: shift_sub = 5'd2;
            24'b01??????????????????????: shift_sub = 5'd1;
            24'b1???????????????????????: shift_sub = 5'd0;
			//default: shift_sub = 0;
		endcase
		/* verilator lint_off WIDTHTRUNC */
		sig_c = sig_sub << shift_sub;
		/* verilator lint_on WIDTHTRUNC */
		exp_c = exp_a - {3'b 000, shift_sub};
	end
	//////////// Rounding //////////
	casez (sig_c[24:0])
		25'b ?0???_????_????_????_????_???? : sig_cc = sig_c[46:24];
		25'b 01000_0000_0000_0000_0000_0000 : sig_cc = sig_c[46:24];
		default: sig_cc = sig_c[46:24] + 1;
	endcase
	//////////// Output //////////
	if (b[30:0] == 31'd 0)
		C_norm = a;
	else if (a[30:0] == b[30:0] && ~add_sub)
		C_norm = 32'd 0;
	else
		C_norm = {sign, exp_c, sig_cc};
end 

always_comb begin
	//////////// Edge Cases //////////	
	if ((Classif_op_a == NaN || Classif_op_b == NaN) || (Classif_op_a == Neg_Inf && Classif_op_b == Inf) || (Classif_op_a == Inf && Classif_op_b == Neg_Inf)) 
		rd = 32'b 0111111111000000_0000_0000_0000_0000;
	else if(Classif_op_a == Inf || Classif_op_b == Inf)
			rd = 32'b 0111_1111_1000_0000_0000_0000_0000;
	else if(Classif_op_a == Neg_Inf || Classif_op_a == Neg_Inf)
			rd = 32'b 1111_1111_1000_0000_0000_0000_0000_0000;
	else 
		rd = C_norm;
end
endmodule
