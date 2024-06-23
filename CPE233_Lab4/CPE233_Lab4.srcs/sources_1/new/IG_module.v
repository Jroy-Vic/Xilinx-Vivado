`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/15/2023 07:21:41 AM
// Design Name: 
// Module Name: IG_module
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


module IG_module(
    input [31:7] ir,
    output [31:0] Utype, Itype, Stype, Jtype, Btype
    );
    
    assign Utype = {ir[31:12], 12'b000000000000};
    assign Itype = {{21{ir[31]}}, ir[30:25], ir[24:20]};
    assign Stype = {{21{ir[31]}}, ir[30:25], ir[11:7]};
    assign Jtype = {{12{ir[31]}}, ir[19:12], ir[20], ir[30:21], 1'b0};
    assign Btype = {{20{ir[31]}}, ir[7], ir[30:25], ir[11:8], 1'b0};
endmodule
