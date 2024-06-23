`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Roy Vicerra
// 
// Create Date: 05/08/2023 06:01:48 AM
// Module Name: L4P1_RCAError
// Project Name: Lab 4
// Target Devices: Basys3
// Description: RCA w/ Error Detection Circuit for Problem 1 of Lab 4
//////////////////////////////////////////////////////////////////////////////////


module L4P1_HalfAdder(
    input logic A,
    input logic B,
    output logic S,
    output logic Co
    );
    
    always_comb
    begin
        S = A ^ B;
        Co = A & B;
    end
    
endmodule
