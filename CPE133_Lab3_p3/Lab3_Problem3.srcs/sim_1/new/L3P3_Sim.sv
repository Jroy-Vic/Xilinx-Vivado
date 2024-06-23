`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/03/2023 05:34:33 PM
// Design Name: 
// Module Name: L3P3_Sim
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


module L3P3_Sim();
    logic [7:0] sA, sB;
    logic sLT, sGT, sET;
    
    L3P3_Comparator UUT (
        .A(sA), .B(sB), .LT(sLT), .GT(sGT), .ET(sET));
        
    initial begin
    sA = 8'b1111;
    sB = 8'b0000;
    #10;
    
    sA = 8'b0000;
    sB = 8'b1111;
    #10;
    
    sA = 8'b1111;
    sB = 8'b1111;
    #10;
    
    end
endmodule
