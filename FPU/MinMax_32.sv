module MinMax_32 (
  input  logic [31:0]   rs1,
  input  logic [31:0]   rs2,
  input  logic          mode,
  output logic [31:0]   rd
);
  logic lt, out_sel;

  always_comb begin
    lt = (rs1[30:0] < rs2[30:0]);

    // selection for the minimum
    unique case ({rs1[31], rs2[31]})
      2'b00: out_sel = ~lt;
      2'b01: out_sel = 1'b1;
      2'b10: out_sel = 1'b0;
      2'b11: out_sel = lt;
    endcase

    // if mode = 1, then the selection is switched to get the maximum
    rd = (mode ^ out_sel) ? rs1 : rs2;
  end

endmodule
