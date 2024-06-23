`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer:  Roy Vicerra
// 
// Create Date: 01/04/2019 04:32:12 PM
// Design Name: 
// Module Name: PIPELINED_OTTER_CPU W/ HAZARD HANDLING
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

  typedef enum logic [6:0] {
           LUI      = 7'b0110111,
           AUIPC    = 7'b0010111,
           JAL      = 7'b1101111,
           JALR     = 7'b1100111,
           BRANCH   = 7'b1100011,
           LOAD     = 7'b0000011,
           STORE    = 7'b0100011,
           OP_IMM   = 7'b0010011,
           OP       = 7'b0110011,
           SYSTEM   = 7'b1110011,
           FLUSH    = 7'b0000000
 } opcode_t;
        
typedef struct packed{
    opcode_t opcode;
    logic [4:0] rs1_addr;
    logic [4:0] rs2_addr;
    logic [4:0] rd_addr;
    logic [3:0] alu_fun;
    logic memWrite;
    logic memRead2;
    logic regWrite;
    logic opA_sel;
    logic [1:0] opB_sel;
    logic [1:0] rf_wr_sel;
    logic [2:0] mem_type;  //sign, size
    logic [31:0] pc;
    logic [31:0] next_pc;
    logic [31:0] aluResult;
    logic [31:0] IR;
    logic [31:0] wr_data;
    logic [31:0] rd_data;
    logic [31:0] rs1;
    logic [31:0] rs2;
    logic [31:0] I_immed, S_immed, U_immed, J_immed, B_immed;
} instr_t;

typedef struct packed{
    // Inputs //
    logic [31:0] Rs1D;
    logic [31:0] Rs2D;
    logic [31:0] Rs1E;
    logic [31:0] Rs2E;
    logic [31:0] RdE;
    logic [31:0] RdM;
    logic [31:0] RdW;
    logic regWriteM;
    logic regWriteW;
    logic [1:0] ResultSrcE;
    
    // Outputs //
    logic StallF;
    logic StallD;
    logic FlushD;
    logic FlushE;
    logic [1:0] ForwardAE;
    logic [1:0] ForwardBE;
} hazard_t;

module OTTER_MCU(input CLK,
                input INTR,
                input RESET,
                input [31:0] IOBUS_IN,
                output [31:0] IOBUS_OUT,
                output [31:0] IOBUS_ADDR,
                output IOBUS_WR 
);           
    wire [6:0] opcode;
    wire [31:0] pc, next_pc, jalr_pc, branch_pc, jump_pc, int_pc, rs1, rs2,
        I_immed, S_immed, U_immed, J_immed, B_immed, aluBin, aluAin, aluResult, rfIn, mem_data;
    
    wire [31:0] IR;
    logic memRead1;
    wire memRead2;
    
    logic pcWrite;
    wire ZeroE;
    wire regWrite,memWrite, zero;
    wire [1:0] opB_sel, rf_wr_sel;
    logic [2:0] pc_sel;
    wire [3:0]alu_fun;
    wire opA_sel;
    
    logic br_lt,br_eq,br_ltu;
    logic [25:0] TAG, tag_table[0:15];
    logic [1:0] byteOffset;
    logic [4:0] ext_byteOffset;
    logic CACHE_lwStall, INSTR_lwStall;
              

//==== Instruction Fetch ===========================================

     instr_t if_de_reg;
     logic [1:0] delay_stall;
     
     // Hazard Unit Instantiation //
     hazard_t hazardUnit;
     
     assign hazardUnit.Rs1D = if_de_reg.IR[19:15];
     assign hazardUnit.Rs2D = if_de_reg.IR[24:20];
     
 
     always_ff @(posedge CLK) begin
        if (!hazardUnit.StallD && !hazardUnit.FlushD) begin
                if_de_reg.pc <= pc;
                if_de_reg.next_pc <= next_pc;
                if_de_reg.IR <= IR;
        end
        // Decode the same instruction if load instruction data dependency //
        if (hazardUnit.StallD) begin
                if_de_reg.pc <= if_de_reg.pc;
                if_de_reg.next_pc <= if_de_reg.next_pc;
                if_de_reg.IR <= if_de_reg.IR;
        end
        // Flush the instruction if control hazard //
        if (hazardUnit.FlushD || INSTR_lwStall) begin
            if_de_reg.pc <= 32'b0;
            if_de_reg.next_pc <= 32'b0;
            if_de_reg.IR <= 32'h00000000;
        end
     end
     
     // pcWrite is handled by the Hazard Unit //
     assign memRead1 = 1'b1; 	//Fetch new instruction every cycle
     
     // Instantiate the PC //
     PC OTTER_PC(.CLK(CLK), .RST(RESET), .PC_WRITE(pcWrite), .PC_SOURCE(pc_sel),
        .JALR(jalr_pc), .JAL(jump_pc), .BRANCH(branch_pc), .MTVEC(32'b0), .MEPC(32'b0),
        .PC_OUT(pc), .PC_OUT_INC(next_pc));

    
//==== Instruction Decode ===========================================

    assign opcode = if_de_reg.IR[6:0];
    opcode_t OPCODE;
    assign OPCODE = opcode_t'(opcode);
    
    
    // Instantiate Hazard Unit //
    logic lwStall;
    
    assign hazardUnit.Rs1E = de_ex_reg.IR[19:15];
    assign hazardUnit.Rs2E = de_ex_reg.IR[24:20];
    assign hazardUnit.RdE = de_ex_reg.IR[11:7];
    assign hazardUnit.ResultSrcE = de_ex_reg.rf_wr_sel;
    
    always_comb begin
    if (((hazardUnit.Rs1E == hazardUnit.RdM) && hazardUnit.regWriteM) && hazardUnit.Rs1E != 'b0) 
        hazardUnit.ForwardAE = 2'b10;
    else if (((hazardUnit.Rs1E == hazardUnit.RdW) && hazardUnit.regWriteW) && hazardUnit.Rs1E != 'b0) 
        hazardUnit.ForwardAE = 2'b01;
    else 
        hazardUnit.ForwardAE = 2'b00;
    
    if (((hazardUnit.Rs2E == hazardUnit.RdM) && hazardUnit.regWriteM) && hazardUnit.Rs2E != 'b0) 
        hazardUnit.ForwardBE = 2'b10;
    else if (((hazardUnit.Rs2E == hazardUnit.RdW) && hazardUnit.regWriteW) && hazardUnit.Rs2E != 'b0) 
        hazardUnit.ForwardBE = 2'b01;   
    else 
        hazardUnit.ForwardBE = 2'b00;
    
    // Stall Control for Load Instructions //
    if (((hazardUnit.Rs1D == hazardUnit.RdE) || (hazardUnit.Rs2D == hazardUnit.RdE)) && (hazardUnit.ResultSrcE == 2'b10)) begin
        TAG = de_ex_reg.rs1[31:6];
        lwStall = 'b1;
        for (int i = 0; i < 16; i++) begin
            if (TAG == tag_table[i] && !$isunknown(tag_table[i])) begin
                lwStall = 'b0;
                break;
            end
        end
    end  
    else if ((CACHE_lwStall || INSTR_lwStall && !$isunknown(CACHE_lwStall) && !$isunknown(INSTR_lwStall)))                                       
        lwStall = 'b1;
    else if (!CACHE_lwStall && !INSTR_lwStall || ($isunknown(CACHE_lwStall) || $isunknown(INSTR_lwStall)))
        lwStall = 'b0;
        
    hazardUnit.StallF = lwStall;
    hazardUnit.StallD = lwStall;
    hazardUnit.FlushD = pc_sel > 3'b000;
    hazardUnit.FlushE = lwStall || (pc_sel > 3'b000);
    
    // Do not advance to the next pc if load instruction data dependency //
    if (hazardUnit.StallF || (INSTR_lwStall && 
        ((de_ex_reg.opcode != JAL || de_ex_reg.opcode != JALR || de_ex_reg.opcode != BRANCH) || $isunknown(de_ex_reg.opcode)))) 
        pcWrite = 'b0;
    else
        pcWrite = 'b1; 
           
    end   
    
    
    instr_t de_ex_reg;
    always_ff @(posedge CLK) begin
        if (!hazardUnit.FlushE) begin
                de_ex_reg <= if_de_reg;
                de_ex_reg.opcode <= OPCODE;
                de_ex_reg.rs1 <= rs1;
                de_ex_reg.rs2 <= rs2;
                de_ex_reg.rd_addr <= if_de_reg.IR[11:7];
                de_ex_reg.regWrite <= regWrite;
                de_ex_reg.memRead2 <= memRead2;
                de_ex_reg.memWrite <= memWrite;
                de_ex_reg.alu_fun <= alu_fun;
                de_ex_reg.opA_sel <= opA_sel;
                de_ex_reg.opB_sel <= opB_sel;
                de_ex_reg.rf_wr_sel <= rf_wr_sel;
                de_ex_reg.I_immed <= I_immed;
                de_ex_reg.U_immed <= U_immed;
                de_ex_reg.S_immed <= S_immed;
                de_ex_reg.B_immed <= B_immed;
                de_ex_reg.J_immed <= J_immed;
        end
        else if ((CACHE_lwStall || INSTR_lwStall) && !hazardUnit.FlushE) begin
            de_ex_reg <= de_ex_reg;
        end
        else begin  // Flush current instruction //
            de_ex_reg.IR <= 32'h00000000;   // nop instruction
            de_ex_reg.regWrite <= 'b0;
            de_ex_reg.memWrite <= 'b0;
        end
     end
      
    
    // Instantiate RegFile //
    REG_FILE OTTER_REG_FILE(.CLK(CLK), .EN(mem_wb_reg.regWrite), .ADR1(if_de_reg.IR[19:15]), .ADR2(if_de_reg.IR[24:20]), .WA(mem_wb_reg.IR[11:7]), 
        .WD(rfIn), .RS1(rs1), .RS2(rs2));
    
    // Instantiate Immediate Generator //
    ImmediateGenerator OTTER_IMGEN(.IR(if_de_reg.IR[31:7]), .U_TYPE(U_immed), .I_TYPE(I_immed), .S_TYPE(S_immed),
        .B_TYPE(B_immed), .J_TYPE(J_immed));
     
    //Instantiate Decoder //
    CU_DCDR OTTER_DCDR(.CLK(CLK), .IR(if_de_reg.IR), .REG_WRITE(regWrite),
                       .MEM_WE2(memWrite), .MEM_RDEN2(memRead2), .ALU_FUN(alu_fun),
                       .ALU_SRCA(opA_sel), .ALU_SRCB(opB_sel), .RF_WR_SEL(rf_wr_sel));
      
 
//==== Execute ======================================================

    // Instantiate Hazard Unit // 
    assign hazardUnit.RdM = ex_mem_reg.IR[11:7]; 
    assign hazardUnit.regWriteM = ex_mem_reg.regWrite;
    wire [31:0] Forward_aluAin, Forward_aluBin;
    
    instr_t ex_mem_reg;
         
     always_ff @(posedge CLK) begin
        if ((!CACHE_lwStall || $isunknown(CACHE_lwStall))) begin
                ex_mem_reg <= de_ex_reg;
                ex_mem_reg.aluResult <= aluResult;
                ex_mem_reg.wr_data <= Forward_aluBin;    
        end
        else begin
                ex_mem_reg <= ex_mem_reg;
                ex_mem_reg.aluResult <= ex_mem_reg.aluResult;
                ex_mem_reg.wr_data <= ex_mem_reg.wr_data;
        end
     end
    
    // Forwarding Control //
    FourMux FORWARD_MUXA(.SEL(hazardUnit.ForwardAE), .ZERO(de_ex_reg.rs1), .ONE(rfIn), .TWO(ex_mem_reg.aluResult), .THREE('b0), .OUT(Forward_aluAin));
    FourMux FORWARD_MUXB(.SEL(hazardUnit.ForwardBE), .ZERO(de_ex_reg.rs2), .ONE(rfIn), .TWO(ex_mem_reg.aluResult), .THREE('b0), .OUT(Forward_aluBin));
      
     // Instantiate ALU two-to-one MUX and four-to-one MUX //
    TwoMux OTTER_ALU_MUXA(.ALU_SRC_A(de_ex_reg.opA_sel), .RS1(Forward_aluAin), .U_TYPE(de_ex_reg.U_immed), .SRC_A(aluAin));
    FourMux OTTER_ALU_MUXB(.SEL(de_ex_reg.opB_sel), .ZERO(Forward_aluBin), .ONE(de_ex_reg.I_immed), .TWO(de_ex_reg.S_immed), .THREE(de_ex_reg.pc), .OUT(aluBin));
    
     // Creates a RISC-V ALU
    ALU OTTER_ALU(.SRC_A(aluAin), .SRC_B(aluBin), .ALU_FUN(de_ex_reg.alu_fun), .RESULT(aluResult), .ZERO(ZeroE));
     
    // Instantiate Branch Condition Generator //
    BCG OTTER_BCG(.RS1(Forward_aluAin), .RS2(Forward_aluBin), .IR(de_ex_reg.IR), .PC_SOURCE(pc_sel));

    // Instantiate Branch Address Generator //
    BAG OTTER_BAG(.RS1(Forward_aluAin), .I_TYPE(de_ex_reg.I_immed), .J_TYPE(de_ex_reg.J_immed), .B_TYPE(de_ex_reg.B_immed), .FROM_PC(de_ex_reg.pc),
         .JAL(jump_pc), .JALR(jalr_pc), .BRANCH(branch_pc));


//==== Memory ======================================================
      
    instr_t mem_wb_reg;
    logic [31:0] aluResult_stalled;

    assign IOBUS_ADDR = mem_wb_reg.aluResult;
    assign IOBUS_OUT = mem_wb_reg.wr_data;
                
    always_ff @(posedge CLK) begin      
        if ((!CACHE_lwStall || $isunknown(CACHE_lwStall))) begin  
                mem_wb_reg <= ex_mem_reg;           
                mem_wb_reg.rd_data <= mem_data;
        end
        else begin
                mem_wb_reg <= mem_wb_reg;           
                mem_wb_reg.rd_data <= mem_wb_reg.rd_data;
        end
     end
     
    // Instantiate Hazard Unit // 
    assign hazardUnit.RdW = mem_wb_reg.IR[11:7]; 
    assign hazardUnit.regWriteW = mem_wb_reg.regWrite;
    
    always_comb begin
        if (ex_mem_reg.opcode == STORE) begin
            byteOffset = ex_mem_reg.IR[8:7];
            ext_byteOffset = ex_mem_reg.IR[11:7];
        end
        else if (ex_mem_reg.opcode == LOAD) begin
            byteOffset = ex_mem_reg.IR[21:20];
            ext_byteOffset = ex_mem_reg.IR[24:20];
        end
    end
    
    // Instantiate Cache with Main Memory //
    SA_CACHE OTTER_CACHE(.CLK(CLK), .RESET(RESET), .pcWrite(pcWrite), .OPCODE(opcode), .CACHE_ADDR(ex_mem_reg.aluResult),. CACHE_READ(ex_mem_reg.memRead2), .CACHE_WRITE(ex_mem_reg.memWrite),
                    .CACHE_DIN(ex_mem_reg.wr_data), .MEM_RDEN1(memRead1), .PC(pc[15:2]), .MEM_SIZE(ex_mem_reg.IR[13:12]), .MEM_SIGN(ex_mem_reg.IR[14]),        
                    .byteOffset(byteOffset), .ext_byteOffset(ext_byteOffset), .CACHE_IO(IOBUS_IN), .lwStall(CACHE_lwStall), .instr_lwStall(INSTR_lwStall), 
                    .IO_WR(IOBUS_WR), .INSTR_DOUT(IR), .DOUT(mem_data), .TAGS(tag_table));
                    
    // Instantiate both Instruction and Data Memory //
//    Memory OTTER_MEMORY(.MEM_CLK(CLK), .MEM_RDEN1(memRead1), .MEM_RDEN2(ex_mem_reg.memRead2), 
//                    .MEM_WE2(ex_mem_reg.memWrite), .MEM_ADDR1(pc[15:2]), .MEM_ADDR2(ex_mem_reg.aluResult),
//                    .MEM_DIN2(ex_mem_reg.wr_data), .MEM_SIZE(ex_mem_reg.IR[13:12]),
//                    .MEM_SIGN(ex_mem_reg.IR[14]), .byteOffset(2'b00), .IO_IN(IOBUS_IN), .IO_WR(IOBUS_WR), .MEM_DOUT1(IR), 
//                    .MEM_DOUT2(mem_data));
   

//==== Write Back ==================================================
         
    // Instantiate RegFile Mux //
    FourMux OTTER_REG_MUX(.SEL(mem_wb_reg.rf_wr_sel), .ZERO(mem_wb_reg.next_pc), .ONE(32'b0), .TWO(mem_data), .THREE(mem_wb_reg.aluResult),
        .OUT(rfIn));
       
        
endmodule
