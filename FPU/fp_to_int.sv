module fp_to_int (
    input  logic [15:0] fp_i,
    output logic [31:0] int_o,
    input ibex_pkg::Classif_e Classif_op_a,
    output logic [2:0]  flag
);

import ibex_pkg::*;

logic [7:0]   fp_exp;
logic [6:0]   fp_sig;
logic [30:0]  int_mag;

always_comb begin

    flag = 3'b 000;
    if(Classif_op_a == Inf || Classif_op_a == NaN) begin
        int_o = 32'b 1111_1111_1111_1111_1111_1111_1111_1111;
        flag = 3'b 001; //overflow
    end
    else if(Classif_op_a == Neg_Inf || Classif_op_a == Sub_Norm) begin
        int_o = 32'b 0000_0000_0000_0000_0000_0000_0000_0000;
        flag = 3'b 010; //unerflow
    end
    else begin
        fp_exp = fp_i[14:7];
        fp_sig = fp_i[6:0];
        int_mag = {1'b 1, fp_sig, 23'b 0000_0000_0000_0000_0000_000}; 
        int_o[30:0] = int_mag >> (157 - fp_exp);
        int_o[31] = fp_i[15];
    end
end
endmodule
