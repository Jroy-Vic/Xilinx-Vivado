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

typedef enum {JUMP, STALL, DELAY, GAME, RESET} states;

module CPE133_Rollin(
    input logic Clk,
    input logic jump,
    input logic RST,
    input logic start,
    output logic [15:0] LED,
    output logic [3:0] AN,
    output logic [7:0] CAT
    );
    
    states PS, NS;
    
    always_ff @(posedge Clk)
    begin
    if(RST)
        PS <= RESET;
    else
        PS <= NS;
    end
    
    always_comb
    begin

    case(PS)
    JUMP:
    begin
    ball = 2'b00;
    if(position == 5'b01011 || pos2 == 5'b01011)
        NS = GAME;
    else if(jump)
        begin
        NS = STALL;
        end
    else
        NS = PS;
    end
   
    STALL:
    begin
    ball = 2'b01;
    if(jump_delay[25] == 'b1)
        NS = DELAY;
    else
        NS = PS;
    end
    
    DELAY:
    begin
    ball = 2'b10;
    if(position == 5'b01011  || pos2 == 5'b01011)
        NS = GAME;
    else
        NS = PS;
    if(pause[23] == 'b1)
        NS = JUMP;
    else
        NS = PS;
    end
    
    GAME:
    begin
    pos_dif = pos_dif + 'b1;
    if(start)
        begin
        NS = JUMP;
        end
    else
        NS = PS;
    end
    
    RESET:
    begin
    ball = 2'b11;
    pos_dif = pos_dif + 'b1;
    if(start)
        begin
        NS = JUMP;
        end
    else
        NS = PS;
    end
    
    default:
    begin
        pos_dif = 2'b00;
        ball = 2'b00;
        NS = RESET;
    end
 
    endcase
   
    end
endmodule
