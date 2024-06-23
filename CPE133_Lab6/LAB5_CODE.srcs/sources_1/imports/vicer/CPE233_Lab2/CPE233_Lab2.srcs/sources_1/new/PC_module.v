`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/15/2023 02:27:46 AM
// Design Name: 
// Module Name: PC_module
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


module PC_module(
    input rst,
    input ld,
    input [1:0] src,
    input clk,
    input [31:0] jal, branch, jalr,
    input memrdEN1, memrdEN2, memWE2, iobus_wr,
    input [31:0] dout2, rs2, iobus_in, ALU_result,
    output [31:0] ir,
    output [31:0] PC
    );
    
wire [31:0] MUXout;
wire [31:0] PC_out;
wire [31:0] PC_adv;
wire [15:2] ir_addr;

assign PC_adv = PC_out + 'h4;
assign ir_addr = PC_out[15:2];
assign PC = PC_out;

    reg_nb_sclr #(.n(32)) PC_reg(
        .data_in(MUXout),
        .clk (clk), 
	    .clr (rst), 
	    .ld (ld), 
        .data_out (PC_out) ); 
        
    mux_4t1_nb  #(.n(32)) PC_mux (
       .SEL (src),
       .D0 (PC_adv), 
	   .D1 (jal), 
	   .D2 (branch), 
	   .D3 (jalr), 
       .D_OUT (MUXout) );  
       
   Memory otter_memory(
    .MEM_CLK (clk),
    .MEM_RDEN1 (memrdEN1),        
    .MEM_RDEN2 (memrdEN2),     
    .MEM_WE2 (memWE2),         
    .MEM_ADDR1 (ir_addr), 
    .MEM_ADDR2 (ALU_result),
    .MEM_DIN2 (rs2),  
    .MEM_SIZE (ir[13:12]),  
    .MEM_SIGN (ir[14]),        
    .IO_IN (iobus_in),    
    .IO_WR (iobus_wr),
    .MEM_DOUT1 (ir), 
    .MEM_DOUT2 (dout2) );
    
endmodule
