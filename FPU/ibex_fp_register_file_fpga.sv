// Copyright lowRISC contributors.
// Copyright 2018 ETH Zurich and University of Bologna, see also CREDITS.md.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

/**
 * RISC-V register file
 *
 * Register file with 31 or 15x 32 bit wide registers. Register 0 is fixed to 0.
 *
 * This register file is designed to make FPGA synthesis tools infer RAM primitives. For Xilinx
 * FPGA architectures, it will produce RAM32M primitives. Other vendors have not yet been tested.
 */
module  ibex_fp_register_file_fpga #(
    parameter int unsigned          DataWidth         = 32,
    parameter bit                   DummyInstructions = 0,
    parameter bit                   WrenCheck         = 0,
    parameter logic [DataWidth-1:0] WordZeroVal       = '0
) (
  // Clock and Reset
  input  logic                 clk_i,
  input  logic                 rst_ni,

  //Read port R1
  input  logic [          4:0] fp_raddr_a_i,
  output logic [DataWidth-1:0] fp_rdata_a_o,
  //Read port R2
  input  logic [          4:0] fp_raddr_b_i,
  output logic [DataWidth-1:0] fp_rdata_b_o,
  // Write port W1
  input  logic [          4:0] fp_waddr_a_i,
  input  logic [DataWidth-1:0] fp_wdata_a_i,
  input  logic                 fp_we_a_i,

  // This indicates whether spurious WE are detected.
  output logic                 err_o
);

  localparam int ADDR_WIDTH = 5;
  localparam int NUM_WORDS = 2 ** ADDR_WIDTH;

  logic [DataWidth-1:0] fp_mem[NUM_WORDS];
  logic we; // write enable if writing to any register other than R0

  // async_read a
  assign fp_rdata_a_o = fp_mem[fp_raddr_a_i];

  // async_read b
  assign fp_rdata_b_o = fp_mem[fp_raddr_b_i];

  // we select
  assign we = fp_we_a_i;

  // SEC_CM: DATA_REG_SW.GLITCH_DETECT
  // This checks for spurious WE strobes on the regfile.
  if (WrenCheck) begin : gen_wren_check
    // Since the FPGA uses a memory macro, there is only one write-enable strobe to check.
    assign err_o = we && !fp_we_a_i;
  end else begin : gen_no_wren_check
    assign err_o = 1'b0;
  end

  // Note that the SystemVerilog LRM requires variables on the LHS of assignments within
  // "always_ff" to not be written to by any other process. However, to enable the initialization
  // of the inferred RAM32M primitives with non-zero values, below "initial" procedure is needed.
  // Therefore, we use "always" instead of the generally preferred "always_ff" for the synchronous
  // write procedure.
  always @(posedge clk_i) begin : sync_write
    if (we == 1'b1) begin
      fp_mem[fp_waddr_a_i] <= fp_wdata_a_i;
    end
  end : sync_write

  // Make sure we initialize the BRAM with the correct register reset value.
  initial begin
    for (int k = 0; k < NUM_WORDS; k++) begin
      fp_mem[k] = WordZeroVal;
    end
  end

  // Reset not used in this register file version
  logic unused_rst_ni;
  assign unused_rst_ni = rst_ni;

endmodule
