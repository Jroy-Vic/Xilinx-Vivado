`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Roy Vicerra
// 
// Create Date: 04/19/2023 09:14:18 PM
// Module Name: Lab1_Problem3_TruthTables
// Project Name: Lab 1
// Target Devices: Basys3
// Description: Truth Table of Problem 3 of Lab 1
//////////////////////////////////////////////////////////////////////////////////


module Lab1_Problem3_TruthTables(
    input A,
    input B,
    input C,
    output X,
    output Y
    );
    
    assign X = !(A & B & C) | (!(A & B) & C) | ((!A) & B & C) | (A & (!B) & C) | (A & B & (!C));
    assign Y = (!(A & B) & C) | (A & !(B & C)) | (A & B & (!C)) | (A & B & C);
endmodule
