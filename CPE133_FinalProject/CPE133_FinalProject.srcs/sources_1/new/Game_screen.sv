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

module Game_screen(
    input logic clk,
    output logic [15:0] led,
    output logic [3:0] an,
    output logic [7:0] cat
    );
    
    logic [19:0] digit_refresh;
    logic [1:0] LED_refresh;
    
    always_ff @(posedge clk)
    begin
    if(digit_refresh == 20'b11111111111111111111)
        digit_refresh <= 0;
    else
        digit_refresh <= digit_refresh + 'b1;
    end
    
    assign LED_refresh = digit_refresh[19:18];
    
    
    always_comb
    begin
    case(LED_refresh)
    
    2'b00:
    begin
        an = 4'b0111;
        cat = 8'b01000001;
    end
    
    2'b01:
    begin
        an = 4'b1011;
        cat = 8'b00010001;
    end
    
    2'b10:
    begin
        an = 4'b1101;
        cat = 8'b10010001;
    end
    
    2'b11:
    begin
        an = 4'b1110;
        cat = 8'b01100001;
    end
    
    default:
    begin
        an = 4'b0111;
        cat = 8'b01000001;
    end
    
    endcase
    end
    
endmodule
