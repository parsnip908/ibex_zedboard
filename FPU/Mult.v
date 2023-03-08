`timescale 1ns/1ns
module Mult;

reg [15:0] A, B, C;
reg sign_a, sign_b, sign_c, sign; 
reg [7:0] exp_a, exp_b, exp_c;
reg [7:0] sig_a, sig_b;
reg [15:0] sig_c;
reg [6:0] sig_cc;


reg comparison;
reg [15:0] Array1[19:0];
reg [15:0] Array2[19:0];
reg [15:0] Output_ref[19:0];
reg [15:0] Output[19:0];
reg [4:0] counter;

wire Inf;
wire Neg_Inf;
wire NaN;
wire Normal;
wire Sub_Norm;

wire  Inf_B;
wire Neg_Inf_B;
wire NaN_B;
wire Normal_B;
wire Sub_Norm_B;


reg clk;
integer i;

 initial begin 
	$readmemb("A.txt",Array1);
	$readmemb("B.txt",Array2);
	$readmemb("Mul.txt",Output_ref);
	A <= Array1[0];
	B <= Array2[0];
	counter = 0;
	comparison = 0;
	clk = 0; 
end

always begin
	#10
	clk = ~clk;
end

	class class_A(.Num(A), .Inf(Inf), .Neg_Inf(Neg_Inf), .NaN(NaN), .Normal(Normal), .Sub_Norm(Sub_Norm));
	class class_B(.Num(B), .Inf(Inf_B), .Neg_Inf(Neg_Inf_B), .NaN(NaN_B), .Normal(Normal_B), .Sub_Norm(Sub_Norm_B));
	
always @(posedge clk) begin

	if (counter == 20) begin
		comparison = 1'b0;
		for(i=0;i<20;i=i+1) begin
			if (Output_ref[i] != Output[i]) begin
				$display("Mismatch at number %d", i);
				comparison = 1'b1;
			end  
		end
		
		if (comparison == 1'b0) begin
			$display("\nsuccess :)");
		end
		$stop;
	end
	A <= Array1[counter+1];
	B <= Array2[counter+1];
	counter <= counter + 1;
	Output[counter] <= C;
	$display("C = %b, C_ref = %b", C, Output_ref[counter]);
	
end
    
always @(*) begin

	sign_c = (A[15] ^ B[15]);
	if (NaN || NaN_B)
		C = 16'b 0111111111000000; 
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
		sig_b = (Sub_Norm)? {1'b 0, B[6:0]} : {1'b 1, B[6:0]};
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
