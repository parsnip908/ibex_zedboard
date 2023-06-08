`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Digilent Inc.
// Engineer: Arthur Brown
// 
// Create Date: 10/1/2016
// Module Name: top
// Project Name: OLED Demo
// Tool Versions: Vivado 2016.4
// Description: creates OLED Demo, handles user inputs to operate OLED control module
// 
// Dependencies: OLEDCtrl.v, debouncer.v
// 
// Revision 0.01 - File Created
//
//////////////////////////////////////////////////////////////////////////////////

module OLEDFSM(
    input clk,
    input btnR,// CPU Reset Button turns the display on and off
    input btnC,// Center DPad Button turns every pixel on the display on or resets to previous state
    // input btnD,// Upper DPad Button updates the delay to the contents of the local memory
    // input btnU,// Bottom DPad Button clears the display
    output oled_sdin,
    output oled_sclk,
    output oled_dc,
    output oled_res,
    output oled_vbat,
    output oled_vdd,

    input [7:0] write_ascii_data,
    output reg [5:0] RAM_addr
);
    //state machine codes
    localparam Idle       = 0;
    localparam Init       = 1;
    localparam Active     = 2;
    localparam Done       = 3;
    localparam FullDisp   = 4;
    localparam Write      = 5;
    localparam WriteWait  = 6;
    localparam UpdateWait = 7;
        
    localparam AUTO_START = 1; // determines whether the OLED will be automatically initialized when the board is programmed
        
    //state machine registers.
    reg [2:0] state = (AUTO_START == 1) ? Init : Idle;
    reg [5:0] count = 0;//loop index variable
    reg       write_active = 0;//bool to see if we have set up local pixel memory in this session
        
    //oled control signals
    //command start signals, assert high to start command
    reg        update_start = 0;        //update oled display over spi
    reg        disp_on_start = AUTO_START;       //turn the oled display on
    reg        disp_off_start = 0;      //turn the oled display off
    reg        toggle_disp_start = 0;   //turns on every pixel on the oled, or returns the display to before each pixel was turned on
    reg        write_start = 0;         //writes a character bitmap into local memory
    //data signals for oled controls
    reg        update_clear = 0;        //when asserted high, an update command clears the display, instead of filling from memory
    reg  [8:0] write_base_addr = 0;     //location to write character to, two most significant bits are row position, 0 is topmost. bottom seven bits are X position, addressed by pixel x position.
    // wire [7:0] write_ascii_data;    //ascii value of character to write to memory
    // reg  [5:0] RAM_addr = 0;     //location to write character to, two most significant bits are row position, 0 is topmost. bottom seven bits are X position, addressed by pixel x position.
    //active high command ready signals, appropriate start commands are ignored when these are not asserted high
    wire       disp_on_ready;
    wire       disp_off_ready;
    wire       toggle_disp_ready;
    wire       update_ready;
    wire       write_ready;
    
    //debounced button signals used for state transitions
    wire       rst;     // CPU RESET BUTTON turns the display on and off, on display_on, local memory is filled from string parameters
    wire       dBtnC;   // Center DPad Button tied to toggle_disp command 
    // wire       dBtnU;   // Upper DPad Button tied to update without clear
    // wire       dBtnD;   // Bottom DPad Button tied to update with clear


    //instantiate OLED controller
    OLEDCtrl m_OLEDCtrl (
        .clk                (clk),              
        .write_start        (write_start),      
        .write_ascii_data   (write_ascii_data), 
        .write_base_addr    (write_base_addr),  
        .write_ready        (write_ready),      
        .update_start       (update_start),     
        .update_ready       (update_ready),     
        .update_clear       (update_clear),    
        .disp_on_start      (disp_on_start),    
        .disp_on_ready      (disp_on_ready),    
        .disp_off_start     (disp_off_start),   
        .disp_off_ready     (disp_off_ready),   
        .toggle_disp_start  (toggle_disp_start),
        .toggle_disp_ready  (toggle_disp_ready),
        .SDIN               (oled_sdin),        
        .SCLK               (oled_sclk),        
        .DC                 (oled_dc  ),        
        .RES                (oled_res ),        
        .VBAT               (oled_vbat),        
        .VDD                (oled_vdd )
    );
//    assign oled_cs = 1'b0;
        
    //debouncers ensure single state machine loop per button press. noisy signals cause possibility of multiple "positive edges" per press.
    debouncer #(
        .COUNT_MAX(65535),
        .COUNT_WIDTH(16)
    ) get_dBtnC (
        .clk(clk),
        .A(btnC),
        .B(dBtnC)
    );
    // debouncer #(
    //     .COUNT_MAX(65535),
    //     .COUNT_WIDTH(16)
    // ) get_dBtnU (
    //     .clk(clk),
    //     .A(btnU),
    //     .B(dBtnU)
    // );
    // debouncer #(
    //     .COUNT_MAX(65535),
    //     .COUNT_WIDTH(16)
    // ) get_dBtnD (
    //     .clk(clk),
    //     .A(btnD),
    //     .B(dBtnD)
    // );
    debouncer #(
        .COUNT_MAX(65535),
        .COUNT_WIDTH(16)
    )  get_rst (
        .clk(clk),
        .A(btnR),
        .B(rst)
    );
    
    // assign led[0] = update_ready;//display whether btnU, BtnD controls are available..
    // assign led[1] = write_active;
    assign init_done = disp_off_ready | toggle_disp_ready | write_ready | update_ready;//parse ready signals for clarity
    assign init_ready = disp_on_ready;
    always@(posedge clk)
        case (state)
            Idle: begin
                if (rst == 1'b1 && init_ready == 1'b1) begin
                    disp_on_start <= 1'b1;
                    state <= Init;
                end
                write_active <= 0;
            end
            Init: begin
                disp_on_start <= 1'b0;
                if (rst == 1'b0 && init_done == 1'b1)
                    state <= Active;
            end
            Active: begin // hold until ready, then accept input
                if (rst && disp_off_ready) begin
                    disp_off_start <= 1'b1;
                    state <= Done;
                end else if (dBtnC == 1'b1 && toggle_disp_ready == 1'b1) begin
                    toggle_disp_start <= 1'b1;
                    state <= FullDisp;
                end else if (write_active == 0 && write_ready) begin
                    write_active <= 1;
                    write_start <= 1'b1;
                    write_base_addr <= {RAM_addr, 3'b000};
                    state <= WriteWait;
                // end else if (write_active == 1 && dBtnU == 1) begin
                //     write_active <= 0;
                //     // update_start <= 1'b1;
                //     update_clear <= 1'b0;
                //     // state <= UpdateWait;
                // end else if (write_active == 1 && dBtnD == 1) begin
                //     write_active <= 0;
                //     // update_start <= 1'b1;
                //     update_clear <= 1'b1;
                //     // state <= UpdateWait;
                end
            end
            Write: begin
                write_start <= 1'b1;
                write_base_addr <= {RAM_addr, 3'b000};
                //write_ascii_data updated with write_base_addr
                state <= WriteWait;
            end
            WriteWait: begin
                write_start <= 1'b0;
                if (write_ready == 1'b1)
                    if (write_base_addr == 9'h1f8) begin
                        update_start <= 1'b1;
                        RAM_addr <= 6'd0;
                        state <= UpdateWait;
                    end else begin
                        state <= Write;
                        RAM_addr <= RAM_addr + 1;
                    end
            end
            UpdateWait: begin
                update_start <= 0;
                if (/*dBtnU == 0 &&*/ init_done == 1'b1) begin
                    state <= Active;
                    write_active <= 0;
                end
            end
            Done: begin
                disp_off_start <= 1'b0;
                if (rst == 1'b0 && init_ready == 1'b1)
                    state <= Idle;
            end
            FullDisp: begin
                toggle_disp_start <= 1'b0;
                if (dBtnC == 1'b0 && init_done == 1'b1)
                    state <= Active;
            end
            default: state <= Idle;
        endcase
endmodule

module charRAM (
    input clk,
    input wr_en,
    input [5:0] read_addr,
    input [5:0] write_addr,
    input [7:0] write_data,
    output reg [7:0] read_data
);

    reg [7:0] mem [63:0];

    always @(posedge clk) begin
        if(wr_en)
            mem[write_addr] <= write_data;
        else
            read_data <= mem[read_addr];
    end

    initial begin
        $readmemb("RAMinit.txt", mem);
    end
endmodule