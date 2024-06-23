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


module L4P1_RCAError(
    input logic [3:0] A,
    input logic [3:0] B,
    input Sub,
    output logic [3:0] S,
    output Error
    );
    
    logic [3:0] Bbar;
    logic [3:0] MUX2Add;
    
    assign Bbar = ~B;

    L3P2_MUX mux (.D0(B), .D1(Bbar), .SEL(Sub), .MUXout(MUX2Add));
        
    logic Co1;
    logic Co2;
    logic Co3;
    
    L4P1_FullAdder FA0 (.A(A[0]),.B(MUX2Add[0]),.Cin(Sub),.Co(Co1),.S(S[0]));
    L4P1_FullAdder FA1 (.A(A[1]),.B(MUX2Add[1]),.Cin(Co1),.Co(Co2),.S(S[1]));
    L4P1_FullAdder FA2 (.A(A[2]),.B(MUX2Add[2]),.Cin(Co2),.Co(Co3),.S(S[2]));
    L4P1_FullAdder FA3 (.A(A[3]),.B(MUX2Add[3]),.Cin(Co3),.Co(Error),.S(S[3]));
    
endmodule
