`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Roy Vicerra
// 
// Create Date: 04/18/2023 11:11:31 AM
// Module Name: Problem1_Schematic
// Project Name: Lab 1
// Target Devices: Basys3
// Description: Simple logic circuit for Problem 1 of Lab 1
//////////////////////////////////////////////////////////////////////////////////


module Problem1_Schematic(
    input A,
    input B,
    input C,
    input D,
    output X,
    output Y,
    output Z
    );
    
    assign X = ((!A) & B & C) | (!(A & C)) | (A & (!D));
    assign Y = !((A & (!D)) | (!(B & C)));
    assign Z = (!(B & C)) | (B & (!C) & D);
endmodule
