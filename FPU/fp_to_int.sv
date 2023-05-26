module fp_to_int (
    input  logic [15:0]         fp_i,
    output logic [31:0]         int_o,
    input  logic                mode_i,
    input ibex_pkg::Classif_e   Classif_op_a,
    output logic [2:0]          flag
);

import ibex_pkg::*;
 
logic [6:0]     fp_sig;
logic [7:0]     fp_exp;
logic [7:0]     shift;
logic [30:0]    int_s;
logic [31:0]    int_rd; //Before rounding
logic [31:0]    int_o_norm;    

always_comb begin
    fp_exp = fp_i[14:7];
    fp_sig = fp_i[6:0];
    int_s = 31'd 0;
    if(mode_i) begin  
        shift  = 8'd 158 - fp_exp;
        int_rd[31:0] = (fp_i[15])? 32'd 0 : (shift > 32)? 32'd 4294967295: {1'd 1, fp_sig, 24'd 0} >> shift;
    end
    else begin 
        shift  = 8'd 157 - fp_exp;
        int_s = (shift > 32)? 31'd 2147483647 : {1'd 1, fp_sig, 23'd 0} >> shift;
        int_rd = (fp_i[15])? {fp_i[15], ~int_s + 31'd 1} : {fp_i[15], int_s};
    end
    case (fp_exp)
        8'd 127 : int_o_norm = (fp_sig[6])? int_rd + 1 : int_rd;
        8'd 128 : int_o_norm = (fp_sig[5])? int_rd + 1 : int_rd;
        8'd 129 : int_o_norm = (fp_sig[4])? int_rd + 1 : int_rd;
        8'd 130 : int_o_norm = (fp_sig[3])? int_rd + 1 : int_rd;
        8'd 131 : int_o_norm = (fp_sig[2])? int_rd + 1 : int_rd;
        8'd 132 : int_o_norm = (fp_sig[1])? int_rd + 1 : int_rd;
        8'd 133 : int_o_norm = (fp_sig[0])? int_rd + 1 : int_rd;
        default: int_o_norm = int_rd;
    endcase
    
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
