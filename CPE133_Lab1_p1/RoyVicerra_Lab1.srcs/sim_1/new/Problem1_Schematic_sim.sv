`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/18/2023 11:24:13 AM
// Design Name: 
// Module Name: Problem1_Schematic_sim
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


module Problem1_Schematic_sim();
    logic sA, sB, sC, sD, sX, sY, sZ;
    
    Problem1_Schematic UUT (
        .A(sA), .B(sB), .C(sC), .D(sD), .X(sX), .Y(sY), .Z(sZ) );
        
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
