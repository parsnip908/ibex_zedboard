`timescale 1ns/1ns

module tb_Add_Sub_test;

reg operator_i;
reg [15:0] A, B;
wire [15:0] C;


reg comparison;
reg [15:0] Array1[19:0];
reg [15:0] Array2[19:0];
//reg [15:0] Output_ref[26:0];
reg [15:0] Output[19:0];
reg [4:0] counter;

reg clk;
integer in_1, in_2, out, i;

	Add_Sub Add(.operator_i(operator_i), .A(A), .B(B), .C(C));


initial begin
	operator_i = 1; 
    in_1 = $fopen("Array1.txt", "w");
    in_2 = $fopen("Array2.txt", "w");
    out = $fopen("Sum.txt", "w");
    counter = 0;
	for (i=0; i<20; i=i+1)
    begin
        A = $random;
        B = $random;
        Array1[counter] = A; 
        Array2[counter] = B;
        counter = counter + 1;
        $fwrite(in_1, "%b\n", A);
        $fwrite(in_2, "%b\n", B);
        $display("A = %b, B = %b", A, B);    
   end 
   
    $fclose(in_1);
    $fclose(in_2);
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
        $fclose(out);
		$stop;
	end
	A <= Array1[counter+1];
	B <= Array2[counter+1];
	counter <= counter + 1;
	Output[counter] <= C;
    $fwrite(out, "%b\n", C);
	$display("C = %b", C);
	
end



endmodule 