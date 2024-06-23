`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Roy Vicerra
// 
// Create Date: 05/03/2023 03:55:39 PM
// Module Name: L3P2_MUX
// Project Name: Lab 3
// Target Devices: Basys3
// Description: MUX Circuit for Problem 2 of Lab 3
//////////////////////////////////////////////////////////////////////////////////


module L3P2_MUX_Circuit(
    input logic A,
    input logic B,
    input logic [1:0]SEL,
    output logic RESULT
    );
    
    assign NANDout = !(A & B);
    assign XORout = A ^ B;
    logic MUXout;
    
    L3P2_MUX mux1 (.in1(NANDout),.in2(XORout),.SEL(SEL[1]),.MUXout(MUXout));
    L3P2_MUX mux2 (.in1(MUXout),.in2((!MUXout)),.SEL(SEL[0]),.MUXout(RESULT));
     
    
endmodule
