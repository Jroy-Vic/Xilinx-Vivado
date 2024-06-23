`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Roy Vicerra
// 
// Create Date: 04/27/2023 10:27:15 AM: 
// Module Name: L3P1_Buses
// Project Name: Lab 3
// Target Devices: Basys3
// Description: Buses Circuit for Problem 1 of Lab 3
//////////////////////////////////////////////////////////////////////////////////


module L3P1_Buses(
    input [3:0] A,
    input [3:0] B,
    input [1:0] C,
    output [1:0] X,
    output [3:0] Y
    );
    
    logic [3:0] nandout;
    logic [1:0] xorout;
    logic [1:0] andout;
    
    assign nandout = ~(A & B);
    assign xorout = (nandout[1:0] ^ C);
    assign andout = (xorout & (~C));
    
    assign X = (nandout[3:2] | xorout);
    assign Y = {xorout, andout};
    
endmodule
