`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/23/2023 10:48:08 PM
// Design Name: 
// Module Name: L7P4_Sim
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


module L7P4_Sim(
    );
    
    logic [1:0] sJK;
    logic sClk, sReset, sQ;
    
    L7P4_FF UUT (.Clk(sClk), .Reset(sReset), .JK(sJK), .Q(sQ));
    
    initial begin
        sClk = 'b1;
        sReset = 'b0;
        sJK = 2'b10;
        #10;
        
        sClk = 'b0;
        sReset = 'b0;
        sJK = 2'b01;
        #10;
        
        sClk = 'b1;
        sReset = 'b0;
        sJK = 2'b01;
        #10;
        
        sClk = 'b0;
        sReset = 'b0;
        sJK = 2'b11;
        #10;
        
        sClk = 'b1;
        sReset = 'b0;
        sJK = 2'b11;
        #10;
        
        sClk = 'b0;
        sReset = 'b0;
        sJK = 2'b00;
        #10;
        
        sClk = 'b1;
        sReset = 'b0;
        sJK = 2'b00;
        #10;
        
        sClk = 'b0;
        sReset = 'b1;
        sJK = 2'b00;
        #10;
        
        sClk = 'b1;
        sReset = 'b1;
        sJK = 2'b00;
        #10;
        
    end
endmodule
