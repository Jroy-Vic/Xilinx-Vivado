`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/15/2023 07:21:41 AM
// Design Name: 
// Module Name: BAG_module
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


module BAG_module(
    input [31:0] PC_out, Jtype, Btype, Itype, rs,
    output [31:0] jal, branch, jalr
    );
    
    assign branch = PC_out + Btype;
    assign jal = PC_out + Jtype;
    assign jalr = rs + Itype;
    
   
    
endmodule
