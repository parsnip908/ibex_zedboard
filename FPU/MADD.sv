module MADD(
    input  logic [15:0]       rs1,
    input  logic [15:0]       rs2,
    input  logic [15:0]       rs3,        
	output logic [15:0]       rd
);


logic [15:0] mul_out;

Mult Mul( 
    .A(rs1), 
    .B(rs2), 
    .C(mul_out)
    );

Add_Sub Add(
    .A(mul_out), 
    .B(rs3), 
    .C(rd)
    );

endmodule 