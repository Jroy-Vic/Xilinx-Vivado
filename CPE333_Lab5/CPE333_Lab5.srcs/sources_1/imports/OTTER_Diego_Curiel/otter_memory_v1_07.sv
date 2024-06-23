`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: J. Callenes, P. Hummel
//
// Create Date: 01/27/2019 08:37:11 AM
// Module Name: OTTER_mem
// Project Name: Memory for OTTER RV32I RISC-V
// Tool Versions: Xilinx Vivado 2019.2
// Description: 64k Memory, dual access read single access write. Designed to
//              purposely utilize BRAM which requires synchronous reads and write
//              ADDR1 used for Program Memory Instruction. Word addressable so it
//              must be adapted from byte addresses in connection from PC
//              ADDR2 used for data access, both internal and external memory
//              mapped IO. ADDR2 is byte addressable.
//              RDEN1 and EDEN2 are read enables for ADDR1 and ADDR2. These are
//              needed due to synchronous reading
//              MEM_SIZE used to specify reads as byte (0), half (1), or word (2)
//              MEM_SIGN used to specify unsigned (1) vs signed (0) extension
//              IO_IN is data from external IO and synchronously buffered
//
// Memory OTTER_MEMORY (
//    .MEM_CLK   (),
//    .MEM_RDEN1 (),
//    .MEM_RDEN2 (),
//    .MEM_WE2   (),
//    .MEM_ADDR1 (),
//    .MEM_ADDR2 (),
//    .MEM_DIN2  (),
//    .MEM_SIZE  (),
//    .MEM_SIGN  (),
//    .IO_IN     (),
//    .IO_WR     (),
//    .MEM_DOUT1 (),
//    .MEM_DOUT2 ()  );
//
// Revision:
// Revision 0.01 - Original by J. Callenes
// Revision 1.02 - Rewrite to simplify logic by P. Hummel
// Revision 1.03 - changed signal names, added instantiation template
// Revision 1.04 - added defualt to write case statement
// Revision 1.05 - changed MEM_WD to MEM_DIN2, changed default to save nothing
// Revision 1.06 - removed typo in instantiation template
// Revision 1.07 - remove unused wordAddr1 signal
//
//////////////////////////////////////////////////////////////////////////////////
                                                                                                                             
  module Memory #(parameter n = 4, w = 2)( // words/block, wordOffset
    input MEM_CLK,
    input MEM_RDEN1,        // read enable Instruction
    input MEM_RDEN2,        // read enable data
    input MEM_WE2,          // write enable.
    input [13:0] MEM_ADDR1, // Instruction Memory word Addr (Connect to PC[15:2])
    input [31:0] MEM_ADDR2, // Data Memory Addr
    input [31:0] MEM_DIN2[0:n-1],  // Data to save
    input [1:0] MEM_SIZE,   // 0-Byte, 1-Half, 2-Word
    input MEM_SIGN,         // 1-unsigned 0-signed
    input [1:0] byteOffset,
    input [31:0] IO_IN,     // Data from IO
    input [w-1:0] WO,
    input [w-1:0] INSTR_WO,
    //output ERR,           // only used for testing
    output logic IO_WR,     // IO 1-write 0-read
    output logic [31:0] MEM_DOUT1[0:n-1],  // Instruction
    output logic [31:0] MEM_DOUT2[0:n-1],   // Data
    output logic [31:0] MEM_DOUT1_SINGLE,
    output logic [31:0] MEM_DOUT2_SINGLE,
    output logic memSig,
    output logic instr_memSig
    
    );  
    
    logic [13:0] wordAddr2;
    logic [31:0] memReadWord[0:n-1], dataHolder1, dataHolder2, dataHolder3, dataHolder4, ioBuffer, memReadSized;
    logic weAddrValid;      // active when saving (WE) to valid memory address
       
    (* rom_style="{distributed | block}" *)
    (* ram_decomp = "power" *) logic [31:0] memory [0:16383];
    
    initial begin
        $readmemh("otter_memory.mem", memory, 0, 16383);
    end
    
    assign wordAddr2 = MEM_ADDR2[15:2];
            
    // buffer the IO input for reading
    always_ff @(negedge MEM_CLK) begin
      if(MEM_RDEN2)
        ioBuffer <= IO_IN;
    end
    
    // BRAM requires all reads and writes to occur synchronously
    always_ff @(posedge MEM_CLK) begin
      
      // save data (WD) to memory (ADDR2)
      if (weAddrValid == 1) begin     // write enable and valid address space
        for (int i = 0; i < 4; i++) begin
            case({MEM_SIZE,byteOffset})
                4'b0000: memory[(wordAddr2 + (4 * i))][7:0]   <= MEM_DIN2[i][7:0];     // sb at byte offsets
                4'b0001: memory[(wordAddr2 + (4 * i))][15:8]  <= MEM_DIN2[i][7:0];
                4'b0010: memory[(wordAddr2 + (4 * i))][23:16] <= MEM_DIN2[i][7:0];
                4'b0011: memory[(wordAddr2 + (4 * i))][31:24] <= MEM_DIN2[i][7:0];
                4'b0100: memory[(wordAddr2 + (4 * i))][15:0]  <= MEM_DIN2[i][15:0];    // sh at byte offsets
                4'b0101: memory[(wordAddr2 + (4 * i))][23:8]  <= MEM_DIN2[i][15:0];
                4'b0110: memory[(wordAddr2 + (4 * i))][31:16] <= MEM_DIN2[i][15:0];
                4'b1000: memory[(wordAddr2 + (4 * i))]        <= MEM_DIN2[i];          // sw
                      //default: memory[wordAddr2]      <= 32'b0   // unsupported size, byte offset
                      // removed to avoid mistakes causing memory to be zeroed.
            endcase
        end
      end
            
      if (MEM_RDEN2) begin     
          // Account for Spatial Locality //
          if (MEM_RDEN2) begin              // Read word from memory
              if(MEM_ADDR2 >= 32'h00010000) begin  // external address range
                MEM_DOUT2 <= {ioBuffer, ioBuffer, ioBuffer, ioBuffer};            // IO read from buffer
                MEM_DOUT2_SINGLE <= ioBuffer;
              end
              else begin
                MEM_DOUT2[WO] <= memory[wordAddr2];
                MEM_DOUT2_SINGLE <= memory[wordAddr2];
                if (WO == 0) begin
                    MEM_DOUT2[1] <= memory[wordAddr2 + 4];
                    MEM_DOUT2[2] <= memory[wordAddr2 + 8];
                    MEM_DOUT2[3] <= memory[wordAddr2 + 12];
                end
                else if (WO == 1) begin
                    MEM_DOUT2[0] <= memory[wordAddr2 - 4];
                    MEM_DOUT2[2] <= memory[wordAddr2 + 4];
                    MEM_DOUT2[3] <= memory[wordAddr2 + 8];
                end
                else if (WO == 2) begin
                    MEM_DOUT2[0] <= memory[wordAddr2 - 8];
                    MEM_DOUT2[1] <= memory[wordAddr2 - 4];
                    MEM_DOUT2[3] <= memory[wordAddr2 + 4];
                end
                else if (WO == 3) begin
                    MEM_DOUT2[0] <= memory[wordAddr2 - 12];
                    MEM_DOUT2[2] <= memory[wordAddr2 - 8];
                    MEM_DOUT2[3] <= memory[wordAddr2 - 4];
                end              
              end
                memSig <= 1'b1;
          end
      end
      else 
            memSig <= 'b0;    
            
       if (MEM_RDEN1) begin                       // Read instruction from memory
          MEM_DOUT1_SINGLE <= memory[MEM_ADDR1];
          MEM_DOUT1[INSTR_WO] <= memory[MEM_ADDR1];
          instr_memSig <= 1'b1;
          case (INSTR_WO)
          // Account for Spatial Locality //
          
          2'b00: begin     
                MEM_DOUT1[1] <= memory[MEM_ADDR1 + 1];
                MEM_DOUT1[2] <= memory[MEM_ADDR1 + 2];
                MEM_DOUT1[3] <= memory[MEM_ADDR1 + 3];
           end
           
           2'b01: begin     
                MEM_DOUT1[0] <= memory[MEM_ADDR1 - 1];   // output sized and sign extended data
                MEM_DOUT1[2] <= memory[MEM_ADDR1 + 1];
                MEM_DOUT1[3] <= memory[MEM_ADDR1 + 2];
           end 
           
           2'b10: begin     
                MEM_DOUT1[0] <= memory[MEM_ADDR1 - 2];   // output sized and sign extended data
                MEM_DOUT1[1] <= memory[MEM_ADDR1 - 1];
                MEM_DOUT1[3] <= memory[MEM_ADDR1 + 1];
           end
           
           2'b11: begin     
                MEM_DOUT1[0] <= memory[MEM_ADDR1 - 3];   // output sized and sign extended data
                MEM_DOUT1[1] <= memory[MEM_ADDR1 - 2];
                MEM_DOUT1[2] <= memory[MEM_ADDR1 - 1];
           end
           
           default: begin     
                MEM_DOUT1[1] <= memory[MEM_ADDR1 + 1];
                MEM_DOUT1[2] <= memory[MEM_ADDR1 + 2];
                MEM_DOUT1[3] <= memory[MEM_ADDR1 + 3];
           end
           endcase
       end               
       else
        instr_memSig <= 'b0;
    end
       
 
    // Memory Mapped IO
    always_comb begin

        
      if (MEM_RDEN2) begin    
          if(MEM_ADDR2 >= 32'h00010000) begin  // external address range
            IO_WR = MEM_WE2;                 // IO Write
            weAddrValid = 0;                 // address beyond memory range
          end
          else begin
            IO_WR = 0;                  // not MMIO
            weAddrValid = MEM_WE2;      // address in valid memory range
          end
      end
    end
        
 endmodule
