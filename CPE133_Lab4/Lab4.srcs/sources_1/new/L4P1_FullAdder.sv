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


module L4P1_FullAdder(
    input logic A,
    input logic B,
    input logic Cin,
    output logic Co,
    output logic S
    );
    
    always_comb
    begin
        Co = (A & B) | (A & Cin) | (B & Cin);
        S = (Cin ^ A ^ B);
    end
    
endmodule
