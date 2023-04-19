module int_to_fp (
    input  logic [31:0] int_in,
    output logic [15:0] fp_out
);
    reg int_sign;
    reg [30:0] int_mag;
    reg [7:0] fp_exp;
    reg [6:0] fp_sig;
    reg [5:0] pos;
    integer i;

    always @(*) begin    
        
        if (int_in == 32'b 0000_0000_0000_0000_0000_0000_0000_0000) 
            fp_out = int_in[15:0];

        else begin
            
            int_sign = int_in[31];
            //int_in = int_sign? ~int_in + 1 : int_in; // For 2's complement

            for(i = 0; i <=31; i++) begin
                if(int_in[i] == 1)
                    pos = i;
            end

            fp_exp = pos + 127;
            int_mag = int_in[30:0] << (31-pos);

            casex (int_mag[23:0])
                24'b 0000_0000_0000_0000_0000_0000 :	fp_sig = int_mag[30:24];
                24'b 1000_0000_0000_0000_0000_0000 :	fp_sig = (int_mag[24])? int_mag[30:24] + 1 : int_mag[30:24];
                24'b 1xxx_xxxx_xxxx_xxxx_xxxx_xxxx :	fp_sig = int_mag[30:24] + 1;
                default: fp_sig = int_mag[30:24];
            endcase

            fp_out[15] = int_sign;  // For Signed int 
            fp_out[14:0] = {fp_exp[7:0], fp_sig[6:0]};
        end
        $display("int_in = %b, \nfp_exp = %b, fp_sig = %b, fp_out = %b, pos = %d", int_in, fp_exp, fp_sig, fp_out, pos);
    end
endmodule