// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module top_zedboard (
  input         IO_CLK,
  input         IO_RST_N,
  output [7:0]  LED,
  input         btnR,// CPU Reset Button turns the display on and off
  input         btnC,// Center DPad Button turns every pixel on the display on or resets to previous state
  // input btnD,// Upper DPad Button updates the delay to the contents of the local memory
  // input btnU,// Bottom DPad Button clears the display
  output        oled_sdin,
  output        oled_sclk,
  output        oled_dc,
  output        oled_res,
  output        oled_vbat,
  output        oled_vdd
);

  parameter int          FPGAPowerAnalysis = 0;
  // Choose 64kb memory for normal builds and 256kb for FPGAPowerAnalysis builds.
  parameter int          MEM_SIZE          = FPGAPowerAnalysis == 0 ? 64 * 1024 : 256 * 1024;
  parameter logic [31:0] MEM_START         = 32'h00000000;
  parameter logic [31:0] MEM_MASK          = MEM_SIZE-1;
  parameter              SRAMInitFile      = "";

  logic clk_sys, rst_sys_n;

  // Instruction connection to SRAM
  logic        instr_req;
  logic        instr_gnt;
  logic        instr_rvalid;
  logic [31:0] instr_addr;
  logic [31:0] instr_rdata;

  // Data connection to SRAM
  logic        data_req;
  logic        data_gnt;
  logic        data_rvalid;
  logic        data_we;
  logic  [3:0] data_be;
  logic [31:0] data_addr;
  logic [31:0] data_wdata;
  logic [31:0] data_rdata;

  ibex_top #(
     .RegFile(ibex_pkg::RegFileFPGA),
     .DmHaltAddr(32'h00000000),
     .DmExceptionAddr(32'h00000000)
  ) u_top (
     .clk_i                 (clk_sys),
     .rst_ni                (rst_sys_n),

     .test_en_i             ('b0),
     .scan_rst_ni           (1'b1),
     .ram_cfg_i             ('b0),

     .hart_id_i             (32'b0),
     // First instruction executed is at 0x0 + 0x80
     .boot_addr_i           (32'h00000000),

     .instr_req_o           (instr_req),
     .instr_gnt_i           (instr_gnt),
     .instr_rvalid_i        (instr_rvalid),
     .instr_addr_o          (instr_addr),
     .instr_rdata_i         (instr_rdata),
     .instr_rdata_intg_i    ('0),
     .instr_err_i           ('b0),

     .data_req_o            (data_req),
     .data_gnt_i            (data_gnt),
     .data_rvalid_i         (data_rvalid),
     .data_we_o             (data_we),
     .data_be_o             (data_be),
     .data_addr_o           (data_addr),
     .data_wdata_o          (data_wdata),
     .data_wdata_intg_o     (),
     .data_rdata_i          (data_rdata),
     .data_rdata_intg_i     ('0),
     .data_err_i            ('b0),

     .irq_software_i        (1'b0),
     .irq_timer_i           (1'b0),
     .irq_external_i        (1'b0),
     .irq_fast_i            (15'b0),
     .irq_nm_i              (1'b0),

     .debug_req_i           ('b0),
     .crash_dump_o          (),

     .fetch_enable_i        ('b1),
     .alert_minor_o         (),
     .alert_major_internal_o(),
     .alert_major_bus_o     (),
     .core_sleep_o          ()
  );

  // SRAM block for instruction and data storage
  ram_2p #(
    .Depth(MEM_SIZE / 4),
    .MemInitFile(SRAMInitFile)
  ) u_ram (
    .clk_i (clk_sys),
    .rst_ni(rst_sys_n),

    .a_req_i   (data_req),
    .a_we_i    (data_we),
    .a_be_i    (data_be),
    .a_addr_i  (data_addr),
    .a_wdata_i (data_wdata),
    .a_rvalid_o(data_rvalid),
    .a_rdata_o (data_rdata),

    .b_req_i   (instr_req),
    .b_we_i    (1'b0),
    .b_be_i    (4'b0),
    .b_addr_i  (instr_addr),
    .b_wdata_i (32'b0),
    .b_rvalid_o(instr_rvalid),
    .b_rdata_o (instr_rdata)
  );

  assign instr_gnt = instr_req;
  assign data_gnt  = data_req;

  logic [7:0] leds;

  logic OLED_wr_en;
  wire  [5:0] OLED_read_addr;
  logic [5:0] OLED_write_addr;
  logic [7:0] OLED_write_data;
  wire  [7:0] OLED_read_data;

  charRAM charRAM(
    clk_sys, 
    OLED_wr_en,
    OLED_read_addr,
    OLED_write_addr,
    OLED_write_data,
    OLED_read_data
  );

  always @(posedge clk_sys) begin
    if (!rst_sys_n) begin
      leds <= 8'b0;
      OLED_wr_en <= 0;
    end else if (data_req && data_we && data_be[0]) begin
      if(data_addr == 32'h0000c010) begin
        leds <= data_wdata[7:0];
        OLED_wr_en <= 0;
      end 
      if (data_addr[31:6] == 26'h0000300) begin
        OLED_wr_en <= 1;
        OLED_write_addr <= data_addr[5:0];
        OLED_write_data <= data_wdata[7:0];
      end
    end else
      OLED_wr_en <= 0;
  end

  assign LED = leds;

  OLEDFSM OLEDFSM(
    .clk        (clk_sys),
    .btnR       (btnR),
    .btnC       (btnC),
    .oled_sdin  (oled_sdin),
    .oled_sclk  (oled_sclk),
    .oled_dc    (oled_dc),
    .oled_res   (oled_res),
    .oled_vbat  (oled_vbat),
    .oled_vdd   (oled_vdd),
    // .led        (led),
    .RAM_addr   (OLED_read_addr),
    .write_ascii_data   (OLED_read_data)
  );


  // Clock and reset
  clkgen_xil7series
    clkgen(
      .IO_CLK,
      .IO_RST_N,
      .clk_sys,
      .rst_sys_n
    );

endmodule
