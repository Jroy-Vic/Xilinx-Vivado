`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/15/2023 04:11:15 AM
// Design Name: 
// Module Name: ALU_module
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ALU_module(
    input [31:0] OP1,
    input [31:0] OP2,
    input [3:0] ALU_func,
    output reg [31:0] RESULT
    );
    
    always @ (OP1, OP2, ALU_func)
    begin
        case (ALU_func)
        4'b0000: RESULT = OP1 + OP2;
        4'b1000: RESULT = OP1 - OP2;
        4'b0110: RESULT = OP1 | OP2;
        4'b0111: RESULT = OP1 & OP2;
        4'b0100: RESULT = OP1 ^ OP2;
        4'b0101: RESULT = OP1 >> OP2[4:0];
        4'b0001: RESULT = OP1 << OP2[4:0];
        4'b1101: RESULT = $signed(OP1) >>> $signed(OP2[4:0]);
        4'b0010: begin
                 if( $signed(OP1) < $signed(OP2) )
                     RESULT = 32'b1;
                 else
                     RESULT = 32'b0;
                 end
        4'b0011: begin
                 if(OP1 < OP2)
                     RESULT = 32'b1;
                 else
                     RESULT = 32'b0;
                 end
        4'b1001: RESULT = OP1;
        default: RESULT = 'hDEADBEEF;
        endcase
    end
endmodule
