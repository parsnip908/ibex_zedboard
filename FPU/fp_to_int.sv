module fp_to_int (
    //input  logic [15:0]         fp_i,
    output logic [31:0]         int_o,
    //input  logic                mode_i,
    input ibex_pkg::Classif_e   Classif_op_a,
    output logic [2:0]          flag
);

import ibex_pkg::*;
logic [15:0]         fp_i; 
logic mode_i; 
logic [6:0]     fp_sig;
logic [7:0]     fp_exp;
logic [7:0]     shift;
logic [30:0]    int_mag;
logic [31:0]    int_s;
logic [31:0]    int_u;
logic [31:0]    int_o_norm;

initial begin
    fp_i = 16'b 0100000011000000;
    mode_i = 1;
end        

always_comb begin
    fp_exp = fp_i[14:7];
    fp_sig = fp_i[6:0];
    int_u = {1'b 1, fp_sig, 24'b 0000_0000_0000_0000_0000_0000};
    int_mag = {1'b 1, fp_sig, 23'b 0000_0000_0000_0000_0000_000};
    int_s = 32'd 0;
    if(mode_i) begin  
        shift  = 8'd 158 - fp_exp;
        int_o_norm[31:0] = (fp_i[15])? 32'd 0 : (shift > 32)? 32'd 4294967295: int_u >> shift;
    end
    else begin 
        shift  = 8'd 157 - fp_exp;
        int_s[30:0] = (shift > 32)? 31'd 2147483647 : int_mag >> shift;
        int_s[31] = fp_i[15];
        int_o_norm = (int_s[31])? ~int_s[30:0] + 1 : int_s;
    end
end

always_comb begin
    flag = 3'b 000;
    if(Classif_op_a == Inf || Classif_op_a == NaN) begin
        int_o = (mode_i)? 32'd 4294967295 : 2147483647;
        flag = 3'b 001; //overflow
    end
    else if(Classif_op_a == Neg_Inf || Classif_op_a == Sub_Norm) begin
        int_o = (mode_i)? 32'd 0 : 32'd 4294967295;
        flag = 3'b 010; //unerflow
    end
    else int_o = int_o_norm;
end
endmodule
