`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/19/2023 06:53:27 PM
// Design Name: 
// Module Name: Lab1_Problem2_Sim
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


module Lab1_Problem2_Sim();
    logic sA, sB, sC, sD, sX, sY;
    
    Lab1_Problem2_Equations UUT (
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
        sD = 0;
        #10;
        
        sA = 0;
        sB = 0;
        sC = 1;
        sD = 1;
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
        sD = 0;
        #10;
        
        sA = 0;
        sB = 1;
        sC = 1;
        sD = 1;
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
        sD = 0;
        #10;
        
        sA = 1;
        sB = 0;
        sC = 1;
        sD = 1;
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
        sD = 0;
        #10;
        
        sA = 1;
        sB = 1;
        sC = 1;
        sD = 1;
        #10;
        
     end
        
endmodule
