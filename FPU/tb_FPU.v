`timescale 1ns/1ns

module tb_FPU;

reg inst;
reg [15:0] A_Add, B_Add, A_Mult, B_Mult;
wire [15:0] C_Add, C_Mult;


reg comparison_Add, comparison_Mult;
reg [4:0] counter_Add, counter_Mult;

reg [15:0] Array1_Add[26:0];
reg [15:0] Array2_Add[26:0];
reg [15:0] Ref_Add[26:0];
reg [15:0] Output_Add[26:0];

reg [15:0] Array1_Mult[19:0];
reg [15:0] Array2_Mult[19:0];
reg [15:0] Ref_Mult[19:0];
reg [15:0] Output_Mult[19:0];

reg clk;
integer i, k;

	FPU FPU(.inst(inst), .rs1(A_Add), .rs2(B_Add), .rd1(C_Add), .rs3(A_Mult), .rs4(B_Mult), .rd2(C_Mult));


initial begin
	counter_Add = 0;
	counter_Mult = 0;
	comparison_Add = 0;
	comparison_Mult = 0;
	clk = 0; 
	inst = 1;
	
	$readmemb("Array1.txt", Array1_Add);
	$readmemb("Array2.txt", Array2_Add);
	$readmemb("Sum.txt", Ref_Add);
	
	$readmemb("A.txt", Array1_Mult);
	$readmemb("B.txt", Array2_Mult);
	$readmemb("Mul.txt", Ref_Mult);
	A_Mult <= Array1_Mult[0];
	B_Mult <= Array2_Mult[0];
	A_Add <= Array1_Add[0];
	B_Add <= Array2_Add[0];
	
	
end

	
always begin
	#10
	clk = ~clk;
end

	
	
always @(posedge clk) begin

	if (counter_Add == 27) begin
		comparison_Add = 1'b0;
		for(i=0;i<27;i=i+1) begin
			if (Ref_Add[i] != Output_Add[i]) begin
				$display("Mismatch at number %d", i);
				comparison_Add = 1'b1;
			end  
		end
		
		if (comparison_Add == 1'b0) begin
			$display("\nsuccess :)");
		end
		$stop;
	end
	A_Add <= Array1_Add[counter_Add + 1];
	B_Add <= Array2_Add[counter_Add + 1];
	counter_Add <= counter_Add + 1;
	Output_Add[counter_Add] <= C_Add;
	$display("C_Add = %b, Ref_Add = %b", C_Add, Ref_Add[counter_Add]);
	
end

always @(posedge clk) begin
	if (counter_Add <= 19) begin
		if (counter_Mult == 20) begin
			comparison_Mult = 1'b0;
			for(k=0;k<20;k=k+1) begin
				if (Ref_Mult[k] != Output_Mult[k]) begin
					$display("Mismatch at number %d", k);
					comparison_Mult = 1'b1;
				end  
			end
			
			if (comparison_Mult == 1'b0) begin
				$display("\nsuccess :)");
			end
		end
		A_Mult <= Array1_Mult[counter_Mult + 1];
		B_Mult <= Array2_Mult[counter_Mult + 1];
		counter_Mult <= counter_Mult + 1;
		Output_Mult[counter_Mult] <= C_Mult;
		$display("C_Mult = %b, Ref_Mult = %b", C_Mult, Ref_Mult[counter_Mult]);
	end
		
end


endmodule 