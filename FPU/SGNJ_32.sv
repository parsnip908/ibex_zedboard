module SGNJ_32 (
    input  logic [31:0]       rs1,
	input  logic              rs2,
    input  logic [1:0]        mode,
    output logic [31:0]       rd
);

always_comb begin
    priority case (mode)
       2'b00: rd = {rs2, rs1[30:0]};
       2'b01: rd = {~rs2, rs1[30:0]};
       2'b10: rd = {rs2 ^ rs1[31], rs1[30:0]}; 
    endcase    
end 

endmodule
