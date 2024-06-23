`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/15/2023 10:45:32 AM
// Design Name: 
// Module Name: GEN_sim
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


module GEN_sim(
    );
    
    reg srst, sld, sclk;
    reg [1:0] ssrc;
    reg [31:0] srs;
    wire [31:0] sU, sS, sjal, sbranch, sjalr;
    
    GEN_module my_GEN_sim (
    .rs (srs),
    .rst (srst),
    .ld (sld),
    .src (ssrc),
    .clk (sclk),
    .Utype_imm (sU),
    .Stype_imm (sS),
    .jal (sjal),
    .branch (sbranch),
    .jalr (sjalr) );
    
    initial begin
    sclk = 0; //- init signal
    forever #10 sclk = ~sclk;
    end
    
    initial begin
    srst = 'b1;
    srs = 'h0000000C;
    sld = 'b1;
    ssrc = 2'b00;
    #20;
    
    srst = 'b1;
    srs = 'h0000000C;
    sld = 'b1;
    ssrc = 2'b00;
    #20;
    
    srst = 'b0;
    srs = 'h0000000C;
    sld = 'b1;
    ssrc = 2'b00;
    #20;
    
    srst = 'b0;
    srs = 'h0000000C;
    sld = 'b1;
    ssrc = 2'b00;
    #20;
    
    srst = 'b0;
    srs = 'h0000000C;
    sld = 'b1;
    ssrc = 2'b00;
    #20;
    
    srst = 'b0;
    srs = 'h0000000C;
    sld = 'b1;
    ssrc = 2'b00;
    #20;
    end
    
endmodule
