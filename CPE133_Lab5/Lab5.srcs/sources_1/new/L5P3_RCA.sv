`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Roy Vicerra
// 
// Create Date: 05/18/2023 08:02:32 PM
// Module Name: L5P3_RCA
// Project Name: Lab 5
// Target Devices: Basys3
// Description: RCA Circuit for Problem 3 of Lab 5
//////////////////////////////////////////////////////////////////////////////////


module L5P3_RCA(
    input logic [3:0] A,
    input logic [3:0] B,
    input logic Sub,
    output logic [4:0] Sum
    );
    
    always_comb
    begin
        if(Sub == 1)
            Sum = A - B;
        else
            Sum = A + B;
    end
endmodule
