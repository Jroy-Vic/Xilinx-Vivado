`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Roy Vicerra 
// 
// Create Date: 05/16/2023 09:50:59 AM
// Module Name: L5P1_SSD
// Project Name: Lab 5
// Target Devices: Basys3 
// Description: Seven Segment Decoder Circuit for Problem 1 of Lab 5
//////////////////////////////////////////////////////////////////////////////////


module L5P1_SSD(
    input logic [3:0] B,
    output [3:0] AN,
    output logic [7:0] CAT
    );
    
    assign AN = 4'b1110;
    
    always_comb begin
        case(B)
            4'b0000: CAT = 8'b00000011;
            4'b0001: CAT = 8'b10011111;
            4'b0010: CAT = 8'b00100101;
            4'b0011: CAT = 8'b00001101;
            4'b0100: CAT = 8'b10011001;
            4'b0101: CAT = 8'b01001001;
            4'b0110: CAT = 8'b01000001;
            4'b0111: CAT = 8'b00011111;
            4'b1000: CAT = 8'b00000001;
            4'b1001: CAT = 8'b00011001;
            4'b1010: CAT = 8'b00010001;
            4'b1011: CAT = 8'b11000001;
            4'b1100: CAT = 8'b01100011;
            4'b1101: CAT = 8'b10000101;
            4'b1110: CAT = 8'b01100001;
            4'b1111: CAT = 8'b01110001;
            default: CAT = 8'b00000011;
        endcase
    end
    
endmodule
