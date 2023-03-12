`timescale 1ns/1ns

module tb_Add_Sub;

reg inst;
reg [15:0] A, B;
wire [15:0] C;


reg comparison;
reg [15:0] Array1[26:0];
reg [15:0] Array2[26:0];
reg [15:0] Output_ref[26:0];
reg [15:0] Output[26:0];
reg [4:0] counter;

reg clk;
integer i;

	Add_Sub Add(.inst(inst), .A(A), .B(B), .C(C));


initial begin
	inst = 1; 
	$readmemb("Array1.txt",Array1);
	$readmemb("Array2.txt",Array2);
	$readmemb("Sum.txt",Output_ref);
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

	if (counter == 27) begin
		comparison = 1'b0;
		for(i=0;i<27;i=i+1) begin
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