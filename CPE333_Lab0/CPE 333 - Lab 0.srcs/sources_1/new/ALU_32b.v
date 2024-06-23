`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Roy Vicerra
// 
// Create Date: 01/09/2024 01:57:28 PM
// Design Name: 
// Module Name: ALU_32b
// Project Name: Lab 0 - ALU Xilinx
// Target Devices: 
// Tool Versions: 
// Description: 32-bit ALU Module
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ALU_32b(
    input [31:0] A, B,
    input [2:0] ALUOp,
    output reg Zero,
    output reg [31:0] Result
    );
    
    always @ (A, B, ALUOp)
    begin   
        case(ALUOp)
        3'b000: Result = A & B;     // AND
        3'b001: Result = A | B;     // OR
        3'b010: Result = A + B;     // ADD
        3'b110: Result = A - B;     // SUB
        3'b111: begin               // SLT
             if ($signed(A) < $signed(B))
                Result = 32'b1;
             else
                Result = 32'b0;
             end
        default: Result = A & B;
        endcase
        
        if (Result == 32'b0)        // Set Zero output to 'b1 if Result == 0
            Zero = 'b1;
        else
            Zero = 'b0;
    end
    
endmodule
