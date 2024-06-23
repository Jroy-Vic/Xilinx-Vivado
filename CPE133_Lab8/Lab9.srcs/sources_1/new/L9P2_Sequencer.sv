`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Roy Vicerra
// 
// Create Date: 05/25/2023 10:07:01 AM
// Module Name: L9P1_ProfFSM
// Project Name: Lab 9
// Target Devices: Basys3
// Description: FSM Sequencer Circuit for Problem 1 of Lab 9
//////////////////////////////////////////////////////////////////////////////////
typedef enum {ONE1,SEVEN,ZERO,ONE2} states;

module L9P2_Sequencer(
    input logic Clk,
    input logic RST,
    input logic EIN,
    output logic [7:0] SQNCE,
    output logic [3:0] AN
    );
    
    assign AN = 4'b1110;
    states PS, NS;
    
    logic [26:0] Clk_div;
    
    always_ff @(posedge Clk)
    begin
    if(Clk_div == 27'b111111111111111111111111111)
        Clk_div <= 0;
    else
        Clk_div <= Clk_div + 'b1;
    end
    
    always_ff @(posedge Clk_div[25])
    begin
    if(RST)
        PS <= ONE1;
    else
        PS <= NS; 
    end
    
    always_comb
    begin
    
    case(PS)
    ONE1:
    begin
    SQNCE = 8'b10011111;
    if(!EIN)
        NS = PS;
    else
        NS = SEVEN;
    end
    
    SEVEN:
    begin
    SQNCE = 8'b00011111;
    if(!EIN)
        NS = PS;
    else
        NS = ZERO;
    end
    
    ZERO:
    begin
    SQNCE = 8'b00000011;
    if(!EIN)
        NS = PS;
    else
        NS = ONE2;
    end
    
    ONE2:
    begin
    SQNCE = 8'b10011111;
    if(!EIN)
        NS = PS;
    else
        NS = ONE1;
    end
    
    default:
    begin
    NS = ONE1;
    SQNCE = 8'b10011111;
    end
    
    
    endcase
    end
endmodule

