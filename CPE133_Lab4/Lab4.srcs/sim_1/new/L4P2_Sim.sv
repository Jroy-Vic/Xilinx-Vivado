`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2023 09:23:09 PM
// Design Name: 
// Module Name: L4P2_Sim
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


module L4P2_Sim(
    );
    
    logic [3:0] sA, sB;
    logic [7:0] sP;
    
    L4P2_Multiplier UUT (.A(sA),.B(sB),.P(sP));
    
    initial begin
    sA = 4'b1111;
    sB = 4'b1111;
    #10;
    
    sA = 4'b0110;
    sB = 4'b0011;
    end
endmodule
