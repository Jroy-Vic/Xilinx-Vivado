`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Roy Vicerra
// 
// Create Date: 05/23/2023 09:53:15 AM
// Module Name: L7P3_8BReg
// Project Name: Lab 7
// Target Devices: Basys3
// Description: 8-bit Register Circuit for Problem 3 of Lab 7
//////////////////////////////////////////////////////////////////////////////////


module L7P3_8BReg(
    input logic Clk,
    input logic Reset,
    input logic [7:0] D,
    output logic [7:0] Q
    );
    
    always_ff @ (posedge Clk)
    begin
        if(Reset)
            Q <= 8'b00000000;
            
        else
            Q <= D;
    end
    
endmodule
