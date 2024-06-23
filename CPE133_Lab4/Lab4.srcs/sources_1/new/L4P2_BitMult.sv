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


module L4P2_BitMult(
    input logic [3:0] A,
    input logic [3:0] B,
    output logic [3:0] ANDout1,
    output logic [3:0] ANDout2,
    output logic [3:0] ANDout3,
    output logic [3:0] ANDout4
    );
    
    
    always_comb
    begin
        ANDout1[0] = B[0] && A[0];
        ANDout1[1] = B[0] && A[1];
        ANDout1[2] = B[0] && A[2];
        ANDout1[3] = B[0] && A[3];
       
        ANDout2[0] = B[1] && A[0];
        ANDout2[1] = B[1] && A[1];
        ANDout2[2] = B[1] && A[2];
        ANDout2[3] = B[1] && A[3];
        
        ANDout3[0] = B[2] && A[0];
        ANDout3[1] = B[2] && A[1];
        ANDout3[2] = B[2] && A[2];
        ANDout3[3] = B[2] && A[3];
        
        ANDout4[0] = B[3] && A[0];
        ANDout4[1] = B[3] && A[1];
        ANDout4[2] = B[3] && A[2];
        ANDout4[3] = B[3] && A[3];
    end
endmodule
