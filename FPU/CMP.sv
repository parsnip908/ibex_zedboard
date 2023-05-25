module CMP (
    input  logic [15:0]       rs1,
	input  logic [15:0]       rs2,
    output logic              rd
);

always_comb begin
    case ({rs1[15], rs2[15]})
       2'b 00 : rd = (rs1[14:0] < rs2[14:0]);
       2'b 01 : rd = 1'b 0;
       2'b 10 : rd = 1'b 1;
       2'b 11 : rd = (rs1[14:0] > rs2[14:0]);
    endcase
end

endmodule
