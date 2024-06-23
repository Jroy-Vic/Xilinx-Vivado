`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Roy Vicerra
// 
// Create Date: 05/03/2023 05:27:12 PM
// Module Name: L3P3_Comparator
// Project Name: Lab 3
// Target Devices: Basys3
// Description: 8-Bit Comparator Circuit for Problem 3 of Lab 3
//////////////////////////////////////////////////////////////////////////////////


module L3P3_Comparator(
    input [7:0] A,
    input [7:0] B,
    output reg LT,
    output reg GT,
    output reg ET
    );
 
    ET = !(A ^ B) 
    always @(A, B)
    begin
        if(A < B)
            LT = 1'b1;
        else
            LT = 1'b0;
        
        if(A > B)
            GT = 1'b1;
        else
            GT = 1'b0;
            
        if(A == B)
            ET = 1'b1;
        else
            ET = 1'b0;
            
    end
    
endmodule
