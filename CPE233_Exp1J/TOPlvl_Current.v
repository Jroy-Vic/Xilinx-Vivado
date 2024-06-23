`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/08/2023 01:56:31 AM
// Design Name: 
// Module Name: TOPlvl
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


module TOPlvl(
    input clk,
    input BTN,
    output [7:0] seg,
    output [3:0] an,
    output [3:0] led
    );
    
    wire RCO, UPL, UPH, WEL, WEH, SEL1, SEL2, LT, AND, GT, GTMax, CLR, re;
    wire [7:0] ROMdata, RAMLdata, RAMHdata, MXdataout, MXROMout, MXaddr; 
    wire [3:0] cnt, cntL, cntH; 
    wire [1:0] MODE;
    
            clk_2n_div_test #(.n(25)) MY_DIV (
            .clockin  (clk),
            .fclk_only ('b1),
            .clockout (divclk) );
           
    assign AND = GT & (~GTMax);
    
       fsm_template my_fsm (
       //inputs
        .BTN  (BTN),
        .RCO  (RCO),
        .LT   (LT),
        .GT   (GT),
        .GTMax(GTMax),
        .clk  (divclk),
       //outputs
        .CLR  (CLR),
        .UPL  (UPL),
        .UPH  (UPH),
        .WEL  (WEL),
        .WEH  (WEH),
        .SEL1 (SEL1),
        .SEL2 (SEL2),
        .MODE (MODE) 
        );
        
     ROM_16x8_exp1j ROM (
        .addr  (cnt),
        .data  (ROMdata),
        .rd_en (re)
        );
        
    ram_single_port #(.n(4),.m(8)) RAML (
        .data_in  (ROMdata),
        .addr     (cntL),
        .we       (WEL),
        .clk      (divclk),
        .data_out (RAMLdata)
        );
   
   ram_single_port #(.n(4),.m(8)) RAMH (
        .data_in  (ROMdata),
        .addr     (cntH),
        .we       (WEH),
        .clk      (divclk),
        .data_out (RAMHdata)
        );
        
   mux_2t1_nb  #(.n(8)) MXDATA (
        .SEL    (SEL1),
        .D0     (RAMLdata),
        .D1     (RAMHdata),
        .D_OUT  (MXdataout)  );
    
   mux_2t1_nb  #(.n(8)) MXaddress (
        .SEL    (SEL1),
        .D0     ({4'b0000,cntL}),
        .D1     ({4'b0000,cntH}),
        .D_OUT  (MXaddr)  );
        
        assign led = MXaddr[3:0];
        
   mux_2t1_nb  #(.n(8)) MXromram (
        .SEL    (SEL2),
        .D0     (ROMdata),  //Rom data
        .D1     (MXaddr),  //the chosen ram address
        .D_OUT  (MXROMout)  );  
        
 
   cntr_up_clr_nb #(.n(4)) CNT (
        .clk    (divclk),
        .clr    (CLR),
        .up     (1'b1),
        .ld     (),
        .D      (),
        .count  (cnt),
        .rco    (RCO)  );
        
   cntr_up_clr_nb #(.n(4)) CNTL (
        .clk    (divclk),
        .clr    (CLR),
        .up     (UPL),
        .ld     (),
        .D      (),
        .count  (cntL),
        .rco    ()  );
        
   cntr_up_clr_nb #(.n(4)) CNTH (
        .clk    (divclk),
        .clr    (CLR),
        .up     (UPH),
        .ld     (),
        .D      (),
        .count  (cntH),
        .rco    ()  );
        
   comp_nb #(.n(8)) COMPLT (
       .a  (8'b00110010),
       .b  (ROMdata),
       .eq (),
       .gt (GT),
       .lt (LT)  );
       
   comp_nb #(.n(8)) COMPGT (
       .a  (8'b01100100),
       .b  (ROMdata),
       .eq (),
       .gt (GTMax),
       .lt ()  );
       
    univ_sseg my_univ_sseg (
       .cnt1   ({6'b000000,MXROMout}),
       .cnt2   (MXdataout),
       .valid  ('b1),
       .dp_en  ('b0),
       .dp_sel (2'b00),
       .mod_sel(MODE),
       .sign   ('b0),
       .clk    (div),
       .ssegs  (seg),
       .disp_en(an)  );
         
endmodule
