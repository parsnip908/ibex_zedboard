module fp_to_int (
    input  logic [15:0] fp_i,
    output logic [31:0] int_o,
    output logic [2:0]  flag
);
    wire Inf;
    wire Neg_Inf;
    wire NaN;
    wire Normal;
    wire Sub_Norm;

    reg [7:0]   fp_exp;
    reg [6:0]   fp_sig;
    reg [30:0]  int_mag;

    FP_Class FP_Class(.Num(fp_i), .Inf(Inf), .Neg_Inf(Neg_Inf), .NaN(NaN), .Normal(Normal), .Sub_Norm(Sub_Norm));

    always @(*) begin

        flag = 3'b 000;
        if(Inf || NaN) begin
            int_o = 32'b 1111_1111_1111_1111_1111_1111_1111_1111;
            flag = 3'b 001; //overflow
        end
        else if(Neg_Inf || Sub_Norm) begin
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