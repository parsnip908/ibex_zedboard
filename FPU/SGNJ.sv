module SGNJ (
    input  logic [15:0]       rs1,
	input  logic              rs2,
    input  logic [1:0]        mode_i,
    output logic [15:0]       rd
);

always_comb begin
    priority case (mode_i)
       2'b 00 : rd = {rs2, rs1[14:0]};
       2'b 01 : rd = {~rs2, rs1[14:0]};
       2'b 10 : rd = {rs2 ^ rs1[15], rs1[14:0]}; 
    endcase    
end 

endmodule
