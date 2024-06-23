`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Roy Vicerra
// 
// Create Date: 04/19/2023 06:48:03 PM
// Module Name: Lab1_Problem2_Equations
// Project Name: Lab 1
// Target Devices: Basys3
// Description: 
//////////////////////////////////////////////////////////////////////////////////


module Lab1_Problem2_Equations(
    input A,
    input B,
    input C,
    input D,
    output X,
    output Y
    );
    
    assign X = ((!A) & C) | (A & (!B) & (!D)) ^ (A & C & D) ^ (A & (!B)) | (B & D);
    assign Y = (C & D) | (A & B) ^ (A & (!C)) | ((!A) & (!B)); 
endmodule
