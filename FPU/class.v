module class(
	input [15:0] num,
	output Inf,
	output Neg_Inf,
	output Nan,
	output Normal
	);

	assign Inf = (num == 16'b0111_1111_1000_0000);
	assign Neg_Inf = (num == 16'b1111_1111_1000_0000);
	assign Nan = (num[14:7] == 8'b1111_1111) && (num[6:0]);
	assign Normal = ~(Inf || Neg_Inf || Nan);
endmodule