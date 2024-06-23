`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ivan Li
// Create Date: 10/11/2023 09:59:03 AM
// Design Name: The RISC-V MCU Generation Units
// Module Name: Top
// Project Name: Lab 4
// Target Devices: 
// Tool Versions: 
// Description: 
// Dependencies: 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//////////////////////////////////////////////////////////////
    module Top(
    input rst,
    input PCWrite,
    input [1:0] pcSource,
    input clk,
    output [31:0] u_type_imm,
    output [31:0] s_type_imm
    );
    
    wire [31:0] pc;
    wire [31:0] Mux_Data_Out;
    wire [31:0] ir, u_type, s_type, b_type, i_type, j_type, jalr, jal, branch;
  
    mux_4t1_nb Mux(
    //input
    .SEL(pcSource),
    .D0(pc + 4),     //adding 4 to the addresses
	.D1(jalr), 
	.D2(branch), 
	.D3(jal), 
	//output
    .D_OUT(Mux_Data_Out)
    );  
    
    reg_nb_sclr PC(
    //input
    .data_in (Mux_Data_Out),
    .clk(clk),
    .clr(rst),
    .ld(PCWrite),
    //output
    .data_out(pc)
    );
    
    Memory Memory(
    //input
    .MEM_CLK(clk),
    .MEM_RDEN1(1'b1),       
    .MEM_RDEN2(1'b0),        
    .MEM_WE2(1'b0),          
    .MEM_ADDR1(pc[15:2]), // Instruction Memory word Addr (Connect to PC[15:2])
    .MEM_ADDR2(0), 
    .MEM_DIN2(0),  
    .MEM_SIZE(2'b10),  
    .MEM_SIGN(1'b0),        
    .IO_IN(1'b0),        
    .IO_WR(),     
    .MEM_DOUT1(ir),  
    .MEM_DOUT2()
    );
    
    //IG
    assign u_type = {ir[31:12], 12'b000000000000};
    assign i_type = {{21{ir[31]}}, ir[30:25], ir[24:20]};
    assign s_type = {{21{ir[31]}}, ir[30:25], ir[11:7]};
    assign b_type = {{20{ir[31]}}, ir[7], ir[30:25], ir[11:8], 1'b0};
    assign j_type = {{12{ir[31]}}, ir[19:12], ir[20], ir[30:21], 1'b0};
    
    //Bag
    assign jalr = (i_type + 4'b1100);
    assign jal = pc - 4 + j_type;
    assign branch = pc - 4 + b_type;
    
    assign u_type_imm = u_type;
    assign s_type_imm = s_type;

endmodule
