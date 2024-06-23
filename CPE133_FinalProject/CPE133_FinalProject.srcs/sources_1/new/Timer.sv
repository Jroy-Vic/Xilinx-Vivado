`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Roy Vicerra
// 
// Create Date: 06/04/2023 12:44:51 AM
// Module Name: CPE133_DinosaurGame
// Project Name: Final Project
// Target Devices: Basys3
// Description: Dinosaur Game for Final Project
//////////////////////////////////////////////////////////////////////////////////

module Timer(
    input logic Clk,
    output logic [15:0] LED,
    output logic [3:0] AN,
    output logic [7:0] CAT
    );
    
    logic [23:0] digit_refresh;
    logic [1:0] LED_refresh;
    
    always_ff @(posedge Clk)
    begin
    if(digit_refresh == 24'b111111111111111111111111)
        digit_refresh <= 0;
    else
        digit_refresh <= digit_refresh + 'b1;
    end
    
    assign LED_refresh = digit_refresh[23:22];
    
    
    always_comb
    begin
    case(LED_refresh)
    
    2'b00:
    begin
        AN = 4'b0111;
        CAT = 8'b00000011;
    end
    
    2'b01:
    begin
        AN = 4'b1011;
        CAT = 8'b10000011;
    end
    
    2'b10:
    begin
        AN = 4'b1101;
        CAT = 8'b01100001;
    end
    
    2'b11:
    begin
        AN = 4'b1110;
        CAT = 8'b01110011;
    end
    
    default:
    begin
        AN = 4'b0111;
        CAT = 8'b00000011;
    end
    
    endcase
    end
    
endmodule
