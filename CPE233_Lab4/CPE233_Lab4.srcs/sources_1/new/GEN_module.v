`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/15/2023 07:23:54 AM
// Design Name: 
// Module Name: GEN_module
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


module GEN_module(
    input rst,
    input PCWrite,
    input [1:0] pcSource,
    input clk,
    output [31:0] u_type_imm,
    output [31:0] s_type_imm
    );
    
wire [31:0] ir, PC_out, BAG_PC, Utype, Stype, Itype, Jtype, Btype, jal, branch, jalr;
assign BAG_PC = PC_out - 'h4;


    PC_module my_PC (
    .rst (rst),
    .ld  (PCWrite),
    .src (pcSource),
    .clk (clk),
    .jal (jal),
    .branch (branch),
    .jalr (jalr),
    .ir  (ir),
    .PC  (PC_out) );
    
    // IG Module
    assign Utype = {ir[31:12], 12'b000000000000};
    assign Itype = {{21{ir[31]}}, ir[30:25], ir[24:20]};
    assign Stype = {{21{ir[31]}}, ir[30:25], ir[11:7]};
    assign Jtype = {{12{ir[31]}}, ir[19:12], ir[20], ir[30:21], 1'b0};
    assign Btype = {{20{ir[31]}}, ir[7], ir[30:25], ir[11:8], 1'b0};
    
    // BAG Module
    assign branch = BAG_PC + Btype;
    assign jal = BAG_PC + Jtype;
    assign jalr = 'h0000000C + Itype;
    
    assign u_type_imm = Utype;
    assign s_type_imm = Stype;
    
endmodule
