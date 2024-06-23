`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Roy Vicerra
// 
// Create Date: 05/08/2023 06:01:48 AM
// Module Name: L4P1_RCAError
// Project Name: Lab 4
// Target Devices: Basys3
// Description: Multiplier Circuit for Problem 2 of Lab 4
//////////////////////////////////////////////////////////////////////////////////


module L4P2_Multiplier(
    input [3:0] A,
    input [3:0] B,
    output [7:0] P
    );
    
    logic [3:0] f1;     // Products of B[0] multiplied by each bit of A
    logic [3:0] f2;     // Products of B[1] multiplied by each bit of A
    logic [3:0] f3;     // Products of B[2] multiplied by each bit of A
    logic [3:0] f4;     // Products of B[3] multiplied by each bit of A
    
    L4P2_BitMult bitmult (.A(A), .B(B), .ANDout1(f1), .ANDout2(f2), .ANDout3(f3), .ANDout4(f4));
    
    logic CoA1, CoA2, CoA3, CoA4;
    logic CoB1, CoB2, CoB3, CoB4, CoB5;
    logic CoC1, CoC2, CoC3, CoC4, CoC5, CoC6, CoC7;
    
    logic [5:0] P1;     //Sum of f1 and f2, with f2 having a single 0 place holder
    logic [6:0] P2;     //Sum of P1 and f3, with f3 having a two 0 place holder
    
    L4P1_HalfAdder AHA1 (.A(f1[0]),.B(0),.S(P1[0]),.Co(CoA1));
    L4P1_FullAdder AFA1 (.A(f1[1]),.B(f2[0]),.Cin(CoA1),.S(P1[1]),.Co(CoA2));
    L4P1_FullAdder AFA2 (.A(f1[2]),.B(f2[1]),.Cin(CoA2),.S(P1[2]),.Co(CoA3));
    L4P1_FullAdder AFA3 (.A(f1[3]),.B(f2[2]),.Cin(CoA3),.S(P1[3]),.Co(CoA4));
    L4P1_FullAdder AFA4 (.A(0),.B(f2[3]),.Cin(CoA4),.S(P1[4]),.Co(P1[5]));
    
    L4P1_HalfAdder BHA1 (.A(P1[0]),.B(0),.S(P2[0]),.Co(CoB1));
    L4P1_FullAdder BFA1 (.A(P1[1]),.B(0),.Cin(CoB1),.S(P2[1]),.Co(CoB2));
    L4P1_FullAdder BFA2 (.A(P1[2]),.B(f3[0]),.Cin(CoB2),.S(P2[2]),.Co(CoB3));
    L4P1_FullAdder BFA3 (.A(P1[3]),.B(f3[1]),.Cin(CoB3),.S(P2[3]),.Co(CoB4));
    L4P1_FullAdder BFA4 (.A(P1[4]),.B(f3[2]),.Cin(CoB4),.S(P2[4]),.Co(CoB5));
    L4P1_FullAdder BFA5 (.A(P1[5]),.B(f3[3]),.Cin(CoB5),.S(P2[5]),.Co(P2[6]));
    
    L4P1_HalfAdder CHA1 (.A(P2[0]),.B(0),.S(P[0]),.Co(CoC1));
    L4P1_FullAdder CFA1 (.A(P2[1]),.B(0),.Cin(CoC1),.S(P[1]),.Co(CoC2));
    L4P1_FullAdder CFA2 (.A(P2[2]),.B(0),.Cin(CoC2),.S(P[2]),.Co(CoC3));
    L4P1_FullAdder CFA3 (.A(P2[3]),.B(f4[0]),.Cin(CoC3),.S(P[3]),.Co(CoC4));
    L4P1_FullAdder CFA4 (.A(P2[4]),.B(f4[1]),.Cin(CoC4),.S(P[4]),.Co(CoC5));
    L4P1_FullAdder CFA5 (.A(P2[5]),.B(f4[2]),.Cin(CoC5),.S(P[5]),.Co(CoC6));
    L4P1_FullAdder CFA6 (.A(P2[6]),.B(f4[3]),.Cin(CoC6),.S(P[6]),.Co(P[7]));
 
    
endmodule
