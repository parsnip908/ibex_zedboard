module Class(
	input [15:0] Num,
	output Inf,
	output Neg_Inf,
	output NaN,
	output Sub_Norm,
	output Normal
	);

	assign Inf = (Num == 16'b0111_1111_1000_0000);
	assign Neg_Inf = (Num == 16'b1111_1111_1000_0000);
	assign NaN = (Num[14:7] == 8'b1111_1111 && Num[6:0]);
	assign Sub_Norm = (Num[14:7] == 8'b0000_0000);
	assign Normal = ~(Inf || Neg_Inf || NaN || Sub_Norm);
	
endmodule
