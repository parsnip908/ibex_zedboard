module SGNJ (
    input  logic [15:0]       rs1,
	input  logic              rs2,
    input  logic [1:0]        mode,
    output logic [15:0]       rd
);

always_comb begin
    priority case (mode)
       2'b00: rd = {rs2, rs1[14:0]};
       2'b01: rd = {~rs2, rs1[14:0]};
       2'b10: rd = {rs2 ^ rs1[15], rs1[14:0]}; 
    endcase    
end 

endmodule
