`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Roy Vicerra
// 
// Create Date: 04/25/2023 12:41:03 AM
// Module Name: Lab2_Problem3_MinimalTruthTable
// Project Name: Lab 2
// Target Devices: Basys3: 
// Description: Minimal Truth Table Circuit for Problem 3 of Lab 2
//////////////////////////////////////////////////////////////////////////////////


module Lab2_Problem3_MinimalTruthTable(
    input A,
    input B,
    input C,
    input D,
    output X,
    output Y
    );
    
    assign X = ((!B) | (!D)) & (B | D) & (A | (!C) | D);
    assign Y = (B | D) & (A | B | C) & (A | (!C) | D) & ((!A) | C | D) & ((!A) | B | (!C));
    
endmodule
