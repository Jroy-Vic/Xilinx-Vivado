`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/25/2023 12:44:48 AM
// Design Name: 
// Module Name: Lab2_Problem3_Sim
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


module Lab2_Problem3_Sim();
    logic sA, sB, sC, sD, sX, sY;
    
    Lab2_Problem3_MinimalTruthTable UUT (
        .A(sA), .B(sB), .C(sC), .D(sD), .X(sX), .Y(sY));
        
    initial begin
        sA = 0;
        sB = 0;
        sC = 0;
        sD = 0;
        #10;
        
        sA = 0;
        sB = 0;
        sC = 0;
        sD = 1;
        #10;
        
        sA = 0;
        sB = 0;
        sC = 1;
        sD = 1;
        #10;
        
        sA = 0;
        sB = 0;
        sC = 1;
        sD = 0;
        #10;
        
        sA = 0;
        sB = 1;
        sC = 0;
        sD = 0;
        #10;
        
        sA = 0;
        sB = 1;
        sC = 0;
        sD = 1;
        #10;
        
        sA = 0;
        sB = 1;
        sC = 1;
        sD = 1;
        #10;
        
        sA = 0;
        sB = 1;
        sC = 1;
        sD = 0;
        #10;
        
        sA = 1;
        sB = 1;
        sC = 0;
        sD = 0;
        #10;
        
        sA = 1;
        sB = 1;
        sC = 0;
        sD = 1;
        #10;
        
        sA = 1;
        sB = 1;
        sC = 1;
        sD = 1;
        #10;
        
        sA = 1;
        sB = 1;
        sC = 1;
        sD = 0;
        #10;
        
        sA = 1;
        sB = 0;
        sC = 0;
        sD = 0;
        #10;
        
        sA = 1;
        sB = 0;
        sC = 0;
        sD = 1;
        #10;
        
        sA = 1;
        sB = 0;
        sC = 1;
        sD = 1;
        #10;
        
        sA = 1;
        sB = 0;
        sC = 1;
        sD = 0;
        #10;
        
    end
endmodule
