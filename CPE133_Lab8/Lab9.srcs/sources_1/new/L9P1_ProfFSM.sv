`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Roy Vicerra
// 
// Create Date: 05/25/2023 10:07:01 AM
// Module Name: L9P1_ProfFSM
// Project Name: Lab 9
// Target Devices: Basys3
// Description: Prof FSM Circuit for Problem 1 of Lab 9
//////////////////////////////////////////////////////////////////////////////////

typedef enum {GRADING, HOUSEWORK, NETFLIX} states;

module L9P1_ProfFSM(
    input logic Clk,
    input logic Reset,
    input logic Coffee,
    input logic Exams,
    output logic Grades,
    output logic Housework,
    output logic [3:0] AN,
    output logic [7:0] CAT
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
    
    
    always_ff @ (posedge Clk_div[25]) 
    begin
        if(Reset)
            PS <= NETFLIX;
        else
            PS <= NS;
    end
    
    
    always_comb
    begin
    Grades = 'b0;
    Housework = 'b0;
    NS = PS;
    
    case(PS)
        GRADING: 
        begin
        Grades = 'b1;
        CAT = 8'b00100101;
        if(!Coffee)
            NS = NETFLIX;
        else if(Coffee && (!Exams))
            NS = HOUSEWORK;
        end
            
        HOUSEWORK:
            begin
            Housework = 'b1;
            CAT = 8'b00001101;
            if(Exams)
                NS = GRADING;
            else if(!(Coffee || Exams))
                NS = NETFLIX;
            end
            
        NETFLIX:
          begin
          CAT = 8'b10011111;
          if(Coffee && (!Exams))
            NS = HOUSEWORK;
          else if(Exams)
            NS = GRADING;
          end
            
        default:
            NS = NETFLIX;
            
        endcase
    end
    
endmodule
