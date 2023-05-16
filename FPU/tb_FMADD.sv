`timescale 1ns/1ns
 
module tb_FMADD;


reg [15:0] rs1, rs2, rs3;
wire [15:0] rd;

reg comparison;
reg [15:0] Array1_FMADD[19:0];
reg [15:0] Array2_FMADD[19:0];
reg [15:0] Array3_FMADD[19:0];
//reg [15:0] Output_ref[26:0];
reg [15:0] Output[19:0];
reg [4:0] counter;

reg clk;
integer in_1, in_2, in_3, out, i;

	FMADD MADD(.rs1(rs1), .rs2(rs2), .rs3(rs3), .rd(rd));


initial begin 
    in_1 = $fopen("Array1_FMADD.txt", "w");
    in_2 = $fopen("Array2_FMADD.txt", "w");
    in_3 = $fopen("Array3_FMADD.txt", "w");
    out = $fopen("Output_FMADD.txt", "w");
    counter = 0;
	for (i=0; i<20; i=i+1)
    begin
        rs1 = $random;
        rs2 = $random;
        rs3 = $random;
        Array1_FMADD[counter] = rs1; 
        Array2_FMADD[counter] = rs2;
        Array3_FMADD[counter] = rs3;
        counter = counter + 1;
        $fwrite(in_1, "%b\n", rs1);
        $fwrite(in_2, "%b\n", rs2);
        $fwrite(in_3, "%b\n", rs3);

        $display("rs1 = %b, rs2 = %b, rs3 = %b", rs1, rs2, rs3);    
   end 
   
    $fclose(in_1);
    $fclose(in_2);
    $fclose(in_3);
	rs1 <= Array1_FMADD[0];
	rs2 <= Array2_FMADD[0];
    rs3 <= Array3_FMADD[0];
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
	rs1 <= Array1_FMADD[counter+1];
	rs2 <= Array2_FMADD[counter+1];
    rs3 <= Array3_FMADD[counter+1];
	counter <= counter + 1;
	Output[counter] <= rd;
    $fwrite(out, "%b\n", rd);
	$display("rd = %b", rd);
	
end


endmodule