`timescale 1ns/1ns
module tb_MM;
//ibex_pkg::fp_alu_op_e operator_i;
import ibex_pkg::*;

logic [15:0] Matrix_A[0:7][0:7];
logic [15:0] Matrix_B[0:7][0:7];
logic [15:0] Matrix_C[0:7][0:7];
logic [15:0] Mul_tmp;
logic [15:0] Add_tmp;
reg clk;
integer i, x, k, n, m, l, j, in_1, in_2, out, counter;


initial begin 
    clk = 0;
    counter = 0;
    i = 0;
    x = 0;
    k = 0;
    in_1 = $fopen("Matrix_A.txt", "w");
    in_2 = $fopen("Matrix_B.txt", "w");
    out = $fopen("Matrix_C.txt", "w"); 
	for (n=0; n<8; n++) begin
        for (m=0; m<8; m++) begin
            Matrix_A[n][m] = $random;
            Matrix_B[n][m] = $random;
            Matrix_C[n][m] = 16'b 0000_0000_0000_0000;
        end   
   end
        /*Matrix_A[0][0] = 16'b 0100000010000000;
        Matrix_A[0][1] = 16'b 0100000000000000;
        Matrix_A[0][2] = 16'b 0100000000000000;

        Matrix_A[1][0] = 16'b 0100000001000000;
        Matrix_A[1][1] = 16'b 0100000011100000;
        Matrix_A[1][2] = 16'b 0100000011100000;

        Matrix_A[2][0] = 16'b 0100000001000000;
        Matrix_A[2][1] = 16'b 0100000011100000;
        Matrix_A[2][2] = 16'b 0100000011100000;

        Matrix_B[0][0] = 16'b 0100000100010000;
        Matrix_B[0][1] = 16'b 0100000010100000;
        Matrix_B[0][2] = 16'b 0100000010100000;

        Matrix_B[1][0] = 16'b 0100000000000000;
        Matrix_B[1][1] = 16'b 0100000001000000;
        Matrix_B[1][2] = 16'b 0100000001000000;
        
        Matrix_B[2][0] = 16'b 0100000000000000;
        Matrix_B[2][1] = 16'b 0100000001000000;
        Matrix_B[2][2] = 16'b 0100000001000000;
        */    
end

    Mult Mul(.A(Matrix_A[i][x]), .B(Matrix_B[x][k]), .C(Mul_tmp));
    Add_Sub Add(.operator_i(FP_ALU_ADD), .A(Matrix_C[i][k]), .B(Mul_tmp), .C(Add_tmp));

always begin
	#10
	clk = ~clk;
end

always @(posedge clk) begin

	if (i == 8) begin
        for (l=0; l<8; l++) begin
            for (j=0; j<8; j++) begin
                $fwrite(in_1, "%b\n", Matrix_A[l][j]);
                $fwrite(in_2, "%b\n", Matrix_B[l][j]);
                $fwrite(out, "%h\n", Matrix_C[l][j]);
                $display("%b, %b, %b",Matrix_A[l][j], Matrix_B[l][j], Matrix_C[l][j]);
            end
        end
        $fclose(in_1);
        $fclose(in_2);
        $fclose(out); 
        $stop;
    end
    else begin
        x <= (x == 7)? 0: x + 1;
        k <= (k == 7 && x == 7)? 0: (x == 7)? k + 1: k;
        i <= (k == 7 && x == 7)? i + 1: i;
        Matrix_C[i][k] <= Add_tmp;   
    end	
end

endmodule