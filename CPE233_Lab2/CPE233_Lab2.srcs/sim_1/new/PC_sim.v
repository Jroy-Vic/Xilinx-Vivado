`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/15/2023 03:18:56 AM
// Design Name: 
// Module Name: PC_sim
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


module PC_sim(
    );
    
    reg sClk, srst, sld;
    reg [1:0] ssrc;
    wire [31:0] sir;
    wire [31:0] sPC;
    
    PC_module UUT(.rst(srst), .ld(sld), .src(ssrc), .clk(sClk), .ir(sir), .PC(sPC));
   
    initial begin
    sClk = 0; //- init signal
    forever #10 sClk = ~sClk;
    end
    
    initial begin
    srst = 'b0;
    sld = 'b0;
    ssrc = 2'b00;
    #20;
  
    srst = 'b1;
    sld = 'b0;
    ssrc = 2'b00;
    #20;
    
    srst = 'b0;
    sld = 'b1;
    ssrc = 2'b00;
    #20;
    
    srst = 'b0;
    sld = 'b0;
    ssrc = 2'b01;
    #20;
  
    srst = 'b1;
    sld = 'b0;
    ssrc = 2'b01;
    #20;
    
    srst = 'b0;
    sld = 'b1;
    ssrc = 2'b01;
    #20;
    
    srst = 'b0;
    sld = 'b0;
    ssrc = 2'b10;
    #20;
  
    srst = 'b1;
    sld = 'b0;
    ssrc = 2'b10;
    #20;
    
    srst = 'b0;
    sld = 'b1;
    ssrc = 2'b10;
    #20;
    
    srst = 'b0;
    sld = 'b0;
    ssrc = 2'b11;
    #20;
  
    srst = 'b1;
    sld = 'b0;
    ssrc = 2'b11;
    #20;
    
    srst = 'b0;
    sld = 'b1;
    ssrc = 2'b11;
    #20;
    end
    
endmodule
