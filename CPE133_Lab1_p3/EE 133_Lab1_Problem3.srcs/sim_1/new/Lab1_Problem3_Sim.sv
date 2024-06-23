`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/19/2023 09:18:58 PM
// Design Name: 
// Module Name: Lab1_Problem3_Sim
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


module Lab1_Problem3_Sim();
    logic sA, sB, sC, sX, sY;
    
    Lab1_Problem3_TruthTables UUT (
        .A(sA), .B(sB), .C(sC), .X(sX), .Y(sY));
        
    initial begin
        sA = 0;
        sB = 0;
        sC = 0;
        #10;
        
        sA = 0;
        sB = 0;
        sC = 1;
        #10;
        
        sA = 0;
        sB = 1;
        sC = 0;
        #10;
        
        sA = 0;
        sB = 1;
        sC = 1;
        #10;
        
        sA = 1;
        sB = 0;
        sC = 0;
        #10;
        
        sA = 1;
        sB = 0;
        sC = 1;
        #10;
        
        sA = 1;
        sB = 1;
        sC = 0;
        #10;
        
        sA = 1;
        sB = 1;
        sC = 1;
        #10;
        
    end
endmodule
