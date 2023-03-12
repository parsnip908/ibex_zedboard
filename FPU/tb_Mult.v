`timescale 1ns/1ns
module tb_Mult;


reg inst;
reg [15:0] A, B;
wire [15:0] C;



reg comparison;
reg [15:0] Array1[19:0];
reg [15:0] Array2[19:0];
reg [15:0] Output_ref[19:0];
reg [15:0] Output[19:0];
reg [4:0] counter;
reg clk;
integer i;


	Mult Mult(.inst(inst), .A(A), .B(B), .C(C));
	
 initial begin 
	inst = 1; 
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

endmodule 