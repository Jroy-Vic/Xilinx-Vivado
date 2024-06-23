`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/15/2023 01:09:27 AM
// Design Name: 
// Module Name: Lab1_topModule
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Lab1_topModule(
input clk,
input BTN,
output [7:0] ssegs, 
output [3:0] AN,
output [3:0] LED
    );
    
wire RCO, UPL, UPH, WEL, WEH, SEL1, SEL2, LT, GT, GTMax, CLR;
wire [13:0] cnt1; 
wire [6:0] cnt2; 
wire [1:0] dp_sel; 
wire [1:0] mod_sel;
wire [3:0] addr;
wire [7:0] data;
wire rd_en;

    clk_2n_div_test #(.n(25)) my_DIV(
          .clockin   (clk), 
          .fclk_only (0),          
          .clockout  (clkDiv)   ); 
          
    fsm_template my_FSM(.BTN(BTN), .RCO(RCO), .LT(LT), .GT(GT), .GTmax(GTmax), .clk(clkDiv),
        .CLR  (CLR),
        .UPL  (UPL),
        .UPH  (UPH),
        .WEL  (WEL),
        .WEH  (WEH),
        .SEL1 (SEL1),
        .SEL2 (SEL2),
        .MODE (MODE) );
    
    univ_sseg my_SEG(.cnt1(cnt1), .cnt2(cnt2), .valid(1), .dp_en(), .dp_sel(), 
    .mod_sel(MODE), .sign(), .clk(clkDiv), .ssegs(ssegs), .disp_en(AN));
    
    ROM_16x8_exp1j my_ROM(.addr(CNT), .data(ROMout), .rd_en(rd_en));
    
    ram_single_port #(.n(16),.m(8)) RAML(.data_in(ROMdata), .addr(CNTL), .we(WEL), .clk(clkDiv),
    .data_out(RAMLout) );
    
    ram_single_port #(.n(16),.m(8)) RAMH(.data_in(ROMdata), .addr(CNTH), .we(WEH), .clk(clkDiv),
    .data_out(RAMHout) );
    
    mux_2t1_nb  #(.n(8)) MXDATA (
        .SEL    (SEL1),
        .D0     (RAMLdata),
        .D1     (RAMHdata),
        .D_OUT  (MXdataout)  );
        
    cntr_up_clr_nb #(.n(4)) CNTRH (
        .clk    (divclk),
        .clr    (CLR),
        .up     (UPH),
        .ld     (),
        .D      (),
        .count  (cntH),
        .rco    ()  );

    comp_nb #(.n(8)) COMPGT (
       .a  (ROMdata),
       .b  (8'b01100100),
       .eq (),
       .gt (GTMax),
       .lt ()  );


    
endmodule
