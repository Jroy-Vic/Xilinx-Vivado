`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Roy Vicerra
// 
// Create Date: 05/23/2023 09:53:15 AM
// Module Name: L7P3_8BReg
// Project Name: Lab 7
// Target Devices: Basys3
// Description: JK Flip-Flop Circuit for Problem 4 of Lab 7
//////////////////////////////////////////////////////////////////////////////////

module L7P4_FF(
    input logic Clk,
    input logic Reset,
    input logic [1:0] JK,
    output logic Q
    );
    
    always_ff @ (posedge Clk)
    begin
        if(Reset)
            Q <= 'b0;
            
        else
        begin
            case(JK)
                2'b00: Q <= Q;
                2'b01: Q <= 'b0;
                2'b10: Q <= 'b1;
                2'b11: Q <= ~Q;
                default: Q <= Q;
            endcase
        end
    end
    
endmodule
