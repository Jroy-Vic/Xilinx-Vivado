`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/15/2023 06:49:44 PM
// Design Name: 
// Module Name: OTTER_MCU
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


module OTTER_MCU(
    input RST,
    input intr,
    input clk,
    input [31:0] iobus_in,
    output [31:0] iobus_out, iobus_addr,
    output iobus_wr
    );
    
    wire ALU_srcA, PCWrite, regWrite, memWE2, memRDEN1, memRDEN2, rst;
    wire [1:0] rf_wr_sel, pcSource, ALU_srcB;    
    wire [3:0] ALU_func;   
    wire [31:0] PC_MUX, PC_out, ir, Utype, Stype, Btype, Itype, Jtype, jalr, jal, branch, dout2, reg_MUX, rs1, rs2, ALU_result, srcA, srcB;
    
    // IG Module
    assign Utype = {ir[31:12], 12'h000};
    assign Itype = {{21{ir[31]}}, ir[30:25], ir[24:20]};
    assign Stype = {{21{ir[31]}}, ir[30:25], ir[11:7]};
    assign Jtype = {{12{ir[31]}}, ir[19:12], ir[20], ir[30:21], 1'b0};
    assign Btype = {{20{ir[31]}}, ir[7], ir[30:25], ir[11:8], 1'b0};
    
    // BAG Module
    assign branch = PC_out + Btype;
    assign jal = PC_out + Jtype;
    assign jalr = 'h0000000C + Itype;
    
    assign u_type_imm = Utype;
    assign s_type_imm = Stype;
    
    // Output Connections
    assign iobus_out = rs2;
    assign iobus_addr =  ALU_result;
    
    // PC Module
    PC_module my_PC (
    .rst (RST),
    .ld (PCWrite),
    .src (pcSource),
    .clk (clk),
    .jal (jal), 
    .branch (branch), 
    .jalr (jalr),
    .memrdEN1 (memRDEN1), 
    .memrdEN2 (memRDEN2), 
    .memWE2 (memWE2), 
    .iobus_wr (iobus_wr),
    .dout2 (dout2), 
    .rs2 (rs2), 
    .iobus_in (iobus_in), 
    .ALU_result (ALU_result),
    .ir (ir),
    .PC (PC_out) 
    );
    
    // RegFile Module
    RegFile my_regFile (
        .wd   (reg_MUX), 
        .clk  (clk), 
        .en   (regWrite), 
        .adr1 (ir[19:15]), 
        .adr2 (ir[24:20]),
        .wa   (ir[11:7]),
        .rs1  (rs1), 
        .rs2  (rs2)  
    );   

    // MUX for RegFile
    mux_4t1_nb #(.n(32)) regFile_MUX (
        .SEL(rf_wr_sel), 
        .D0(PC_out + 'h4),      
	    .D1(0), 
	    .D2(dout2), 
	    .D3(ALU_result),  
        .D_OUT(reg_MUX) 
    );     
    
    // ALU Module
    ALU_module my_ALU (
    .OP1 (srcA),
    .OP2 (srcB),
    .ALU_func (ALU_func),
    .RESULT (ALU_result) 
    );

    // MUX for OP1 of ALU
    mux_2t1_nb #(.n(32)) scrA_MUX(
        .SEL(ALU_srcA), 
        .D0(rs1), 
        .D1(Utype), 
        .D_OUT(srcA)
    );          
    
    // MUX for OP2 of ALU
    mux_4t1_nb #(.n(32)) scrB_MUX(
         .SEL(ALU_srcB), 
         .D0(rs2),      
	       .D1(Itype),       
	       .D2(Stype), 
	       .D3(PC_out),  
         .D_OUT(srcB) 
    );
    
    // CU_FSM Module
    CU_FSM my_CU_FSM (
        .intr     (intr),
        .clk      (clk),
        .RST      (RST),
        .opcode   (ir[6:0]),   // ir[6:0]
        .pcWrite  (PCWrite),
        .regWrite (regWrite),
        .memWE2   (memWE2),
        .memRDEN1 (memRDEN1),
        .memRDEN2 (memRDEN2),
        .reset    (rst)   
    );
    
    // CU_DCDR Module
    CU_DCDR my_CU_DCDR(
        .br_eq     (), //branch cond gen not made yet
        .br_lt     (), 
        .br_ltu    (),
        .opcode    (ir[6:0]),    
        .func7     (ir[30]),    
        .func3     (ir[14:12]),    
        .alu_fun   (ALU_func),
        .pcSource  (pcSource),
        .alu_srcA  (ALU_srcA),
        .alu_srcB  (ALU_srcB), 
        .rf_wr_sel (rf_wr_sel)   
    );   

            
endmodule

