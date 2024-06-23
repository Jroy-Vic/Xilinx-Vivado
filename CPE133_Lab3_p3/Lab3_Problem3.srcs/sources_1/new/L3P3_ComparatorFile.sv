`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/03/2023 10:21:26 PM
// Design Name: 
// Module Name: L3P3_ComparatorFile
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


module L3P3_ComparatorFile(

    input logic [7:0] A,
    input logic [7:0] B,
    output LT,
    output GT,
    output ET
    );
    
    logic [0:3] A0, B0;
    logic [7:4] A1, B1;
    logic [7:0] XNORout;
   
    assign A0 = ~(A[3:0] ^ B[3:0]);
    assign A1 = ~(A[7:4] ^ B[7:4]);
    
    assign ET = A1 & A0;
    
    assign GT = (A & ~B);
endmodule
