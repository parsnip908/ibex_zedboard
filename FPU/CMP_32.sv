module CMP_32 (
  input  logic [31:0]   rs1,
  input  logic [31:0]   rs2,
  input  logic [1:0]    mode,
  output logic          rd
);
logic eq, lt, le;

always_comb begin
  eq = (rs1 == rs2);
  lt = (rs1[30:0] < rs2[30:0]);
  le = lt || eq;

  casez ({mode, rs1[31], rs2[31]})
    //EQ
    4'b10_??: rd = eq; 
    //LT
    4'b01_00: rd = lt;
    4'b01_01: rd = 1'b0;
    4'b01_10: rd = 1'b1;
    4'b01_11: rd = ~le; 
    //LE
    4'b00_00: rd = le;
    4'b00_01: rd = 1'b0;
    4'b00_10: rd = 1'b1;
    4'b00_11: rd = ~lt;
    //default should never propogate past the FPU.
    default:  rd = 1'bx;
  endcase
end

endmodule
