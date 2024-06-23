`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/02/2023 04:05:03 AM
// Design Name: 
// Module Name: L9P2_Sim
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


module L9P2_Sim(
    );
    
    logic sClk, sRST, sEIN;
    logic [7:0] sSQNCE;
    
    L9P2_Sequencer UUT (.Clk(sClk), .RST(sRST), .EIN(sEIN), .SQNCE(sSQNCE));
    
    initial begin
    sClk = 0;
    
    sRST = 1;
    sEIN = 1;
    #10;
    
    sRST = 1;
    sEIN = 1;
    #10;
    
    sRST = 0;
    sEIN = 1;
    #10;
    
    sRST = 0;
    sEIN = 1;
    #10;
    
    sRST = 0;
    sEIN = 1;
    #10;
    
    sRST = 0;
    sEIN = 1;
    #10;
    
    sRST = 0;
    sEIN = 1;
    #10;
    
    sRST = 0;
    sEIN = 1;
    #10;
    
    sRST = 0;
    sEIN = 1;
    #10;
    
    sRST = 0;
    sEIN = 1;
    #10;
    
    sRST = 0;
    sEIN = 1;
    #10;
    
    sRST = 0;
    sEIN = 1;
    #10;
    
    sRST = 0;
    sEIN = 0;
    #10;
    
    
    end
    
    always begin
    #10;
    sClk = ~sClk;
    end
    
    
endmodule
