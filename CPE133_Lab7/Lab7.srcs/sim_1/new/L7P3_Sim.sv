`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/23/2023 10:55:28 AM
// Design Name: 
// Module Name: L7P3_Sim
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


module L7P3_Sim(
    );
    
    logic sClk, sReset;
    logic [7:0] sD, sQ;
    
    L7P3_8BReg UUT (.Clk(sClk), .Reset(sReset), .D(sD), .Q(sQ));
    
    initial begin
        sClk = 'b1;
        sReset = 'b0;
        sD = 8'b00000001;
        #10;
        
        sClk = 'b0;
        sReset = 'b0;
        sD = 8'b00000000;
        #10;
        
        sClk = 'b1;
        sReset = 'b0;
        sD = 8'b00000000;
        #10;
        
        sClk = 'b0;
        sReset = 'b0;
        sD = 8'b10000000;
        #10;
        
        sClk = 'b1;
        sReset = 'b0;
        sD = 8'b10000000;
        #10;
        
        sClk = 'b0;
        sReset = 'b1;
        sD = 8'b10000000;
        #10;
        
        sClk = 'b1;
        sReset = 'b1;
        sD = 8'b10000000;
        #10;
    end
endmodule
