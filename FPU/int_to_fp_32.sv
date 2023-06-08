module int_to_fp_32 (
    input  logic [31:0] int_i,
    input  logic        mode_i,
    output logic [31:0] fp_o
);

import ibex_pkg::*;

logic int_sign;
logic [31:0] int_i_tmp;
logic [30:0] int_mag;
logic [31:0] fp_out_norm;
logic [7:0] fp_exp;
logic [22:0] fp_sig;
logic [4:0] pos;
int i;

always_comb begin    
    
    int_sign = (mode_i)? 1'b 0: int_i[31];
    int_i_tmp = int_sign? ~int_i + 1 : int_i; // For 2's complement
    if(int_i == 32'd0) pos = 0;
    else begin
        for(i = 0; i < 32; i++) begin
            if(int_i_tmp[i] == 1)
                pos = i[4:0];
        end
    end
    fp_exp = {2'b 00, pos} + 8'd 127;
    int_mag = int_i_tmp[30:0] << (31-pos);

    casez (int_mag[7:0])
        8'b 0000_0000 :	fp_sig = int_mag[30:8];
        8'b 1000_0000 :	fp_sig = (int_mag[8])? int_mag[30:8] + 1 : int_mag[30:8];
        8'b 1???_???? :	fp_sig = int_mag[30:8] + 1;
        default: fp_sig = int_mag[30:8];
    endcase

    fp_out_norm[31] = int_sign; 
    fp_out_norm[30:0] = {fp_exp[7:0], fp_sig[22:0]};
end

always_comb begin
    if (int_i == 32'd 0)
    fp_o = int_i[31:0];
    else
    fp_o = fp_out_norm;
end

endmodule
