`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Roy Vicerra
// 
// Create Date: 03/12/2024 11:09:05 AM
// Design Name: 
// Module Name: SA_CACHE
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
//typedef enum logic [6:0] {
//           LUI      = 7'b0110111,
//           AUIPC    = 7'b0010111,
//           JAL      = 7'b1101111,
//           JALR     = 7'b1100111,
//           BRANCH   = 7'b1100011,
//           LOAD     = 7'b0000011,
//           STORE    = 7'b0100011,
//           OP_IMM   = 7'b0010011,
//           OP       = 7'b0110011,
//           SYSTEM   = 7'b1110011,
//           FLUSH    = 7'b0000000
// } opcode_t;
 
 
module SA_CACHE #(parameter b = 4, c = 4, d = 4, s = 2, w = 2) ( // way/set, number of sets, words/block, set offset, word offest //
    input CLK,
    input RESET,
    input pcWrite,
    input [6:0] OPCODE,
    input [31:0] CACHE_ADDR,
    input CACHE_READ,
    input CACHE_WRITE,
    input [31:0] CACHE_DIN,
    input MEM_RDEN1,        // read enable Instruction
    input [13:0] PC, // Instruction Memory word Addr (Connect to PC[15:2])
    input [1:0] MEM_SIZE,   // 0-Byte, 1-Half, 2-Word
    input MEM_SIGN,         // 1-unsigned 0-signed
    input [1:0] byteOffset,
    input [4:0] ext_byteOffset,
    input [31:0] CACHE_IO,     // Data from IO
    output logic lwStall,
    output logic instr_lwStall,
    output logic IO_WR,     // IO 1-write 0-read
    output logic [31:0] INSTR_DOUT,  // Instruction
    output logic [31:0] DOUT,
    output logic [25:0] TAGS[0:15]
    );
    
// ~~~~~~~~~~~~~~~~~  Struct Initialization  ~~~~~~~~~~~~~~~~~~~ //
localparam int TAG_SIZE = 32-w-s-2;
 
typedef struct {
    logic [7:0] dBYTE[0:3];
} word_t;
    
typedef struct {
    logic validBit;
    logic dirtyBit;
    logic [31:0] CNT;
    logic [s-1:0] SO;
    logic [w-1:0] WO;
    logic [1:0] BO;
    logic [(TAG_SIZE - 1):0] TAG;   
    word_t WORD[0:d-1];
} block_t;
    
typedef struct {
    // One block has 65 bits in total (32 bits for address, 32 bits for count, validBit, dirtyBit //
    block_t blkArr[0:b-1];
    logic [31:0] setCNT;
} set_t;

typedef struct {
    set_t setArr [0:c-1];
} cache_t;


// ~~~~~~~~~~~~~~~~~  Function Initialization ~~~~~~~~~~~~~~~~ //
// Function for Writing Main Memory Data into Cache //   
     task wordWrite;
        input int i, b, d;
        input [31:0] MEM_DOUT[];
        input block_t inputBlk;
        inout cache_t cache;
        //output DOUT;
     begin      
        // Write data into Cache from Main Memory //
        for (int j = 0; j < d; j++) begin
            $display("\tCache Empty: Write Word #%d / Byte #%d into Block #%d\n", j, (4*j), i);
            // Retrieve word and write to cache //
            cache.setArr[inputBlk.SO].blkArr[i].WORD[j].dBYTE[3] <= MEM_DOUT[j][7:0];
            cache.setArr[inputBlk.SO].blkArr[i].WORD[j].dBYTE[2] <= MEM_DOUT[j][15:8];
            cache.setArr[inputBlk.SO].blkArr[i].WORD[j].dBYTE[1] <= MEM_DOUT[j][23:16];
            cache.setArr[inputBlk.SO].blkArr[i].WORD[j].dBYTE[0] <= MEM_DOUT[j][31:24];
            $display("\t\tWord #%d: %h\n", j, cache.setArr[inputBlk.SO].blkArr[i].WORD[j]);
        end      
                        
        $display("\t\tCache Written: Outputting Data -> %h\n", cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO]);    
        $display("// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //\n");     
     end
     endtask
      
      
      
// Function for Writing Main Memory Instructions into Cache //   
     task instrWrite;
        input int i, b, d;
        input [31:0] INSTR_MEM_DOUT[];
        input block_t instr_inputBlk;
        inout cache_t instr_cache;
        //output DOUT;
     begin      
        // Write data into Cache from Main Memory //
        for (int j = 0; j < d; j++) begin
            $display("\tCache Empty: Write Word #%d / Byte #%d into Block #%d\n", j, (4*j), i);
            // Retrieve word and write to cache //
            instr_cache.setArr[instr_inputBlk.SO].blkArr[i].WORD[j].dBYTE[3] <= INSTR_MEM_DOUT[j][7:0];
            instr_cache.setArr[instr_inputBlk.SO].blkArr[i].WORD[j].dBYTE[2] <= INSTR_MEM_DOUT[j][15:8];
            instr_cache.setArr[instr_inputBlk.SO].blkArr[i].WORD[j].dBYTE[1] <= INSTR_MEM_DOUT[j][23:16];
            instr_cache.setArr[instr_inputBlk.SO].blkArr[i].WORD[j].dBYTE[0] <= INSTR_MEM_DOUT[j][31:24];
            $display("\t\tWord #%d: %h\n", j, instr_cache.setArr[instr_inputBlk.SO].blkArr[i].WORD[j]);
        end      
                        
        $display("\t\tCache Written: Outputting Data -> %h\n", instr_cache.setArr[instr_inputBlk.SO].blkArr[i].WORD[instr_inputBlk.WO]);    
        $display("// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //\n");     
     end
     endtask
     
       
// ~~~~~~~~~~~~~~~~~  States  ~~~~~~~~~~~~~~~~~~~~~~~~ //   
    typedef enum logic [2:0] {
        CHECK = 3'b000,
        EMPTY = 3'b001,
        REPLACE = 3'b010,
        DIRTY = 3'b011,
        INSTR = 3'b100,
        INSTR_EMPTY = 3'b101,
        INSTR_REPLACE = 3'b110
    } state_t;
    state_t state = CHECK, instr_state = INSTR;
    logic delay_state = 'b0, instr_delay_state = 'b0;
    logic [1:0] instr_flushCancel = 2'b00;
    int i;
    

// ~~~~~~~~~~~~~~~~~  Initialization  ~~~~~~~~~~~~~~~~~~~~~~~~ //
    block_t inputBlk = '{default: 0}, instr_inputBlk = '{default: 0}, oldInputBlk = '{default: 'hf}, instr_oldInputBlk = '{default: 'hf};
    int refIDX = 0, exitIDX = 0, instr_refIDX = 0, cnt = 0;
    logic [3:0] wordIDX = 2'b00, byteIDX = 2'b00;
    logic wbSig = 'b0, instr_wbSig = 'b0, writtenSig = 'b0, memSig = 'b0, instr_memSig = 'b0, stallSig = 'b1, instr_stallSig = 'b0,
         MEM_RDEN2 = 'b0, MEM_WE2 = 'b0, INSTR_READ = 'b0;
    logic [13:0] INSTR_ADDR = 14'b00000000000000;
    logic [31:0] MEM_ADDR, IO_IN;
    logic [31:0] MEM_DOUT[0:d-1], INSTR_MEM_DOUT[0:d-1];
    logic [31:0] MEM_DIN2[0:d-1];
    logic [5:0] instrCNT;
    
    // Initialize DATA and INSTRUCTION Cache, set all Valid Bits to 0 and setCNT to 0 //
    cache_t cache, instr_cache;
    initial begin
        for (int i = 0; i < c; i++) begin
            cache.setArr[i].setCNT = 32'b0;
            instr_cache.setArr[i].setCNT = 32'b0;
            $display("Set CNT for Set #%d\n", i);
            for (int j = 0; j < b; j++) begin
                cache.setArr[i].blkArr[j] = '{default: 0};
                instr_cache.setArr[i].blkArr[j] = '{default: 0};
                $display("Set ValidBit for Block #%d, Set #%d\n", j, i);
            end
        end
        $display("// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //\n");
    end
        
    // Instantiate both Instruction and Data Memory //
    Memory OTTER_MEMORY (.MEM_CLK(CLK), .MEM_RDEN1(INSTR_READ), .MEM_RDEN2(MEM_RDEN2), 
        .MEM_WE2(MEM_WE2), .MEM_ADDR1(INSTR_ADDR), .MEM_ADDR2(MEM_ADDR),
        .MEM_DIN2(MEM_DIN2), .MEM_SIZE(MEM_SIZE),
        .MEM_SIGN(MEM_SIGN), .byteOffset(byteOffset), .IO_IN(IO_IN), .WO(inputBlk.WO), .INSTR_WO(instr_inputBlk.WO), .IO_WR(IO_WR), 
        .MEM_DOUT1(INSTR_MEM_DOUT), .MEM_DOUT2(MEM_DOUT), .MEM_DOUT1_SINGLE(INSTR_DOUT), .MEM_DOUT2_SINGLE(DOUT), .memSig(memSig), 
        .instr_memSig(instr_memSig));
   
    
 // ~~~~~~~~~~~~~~~~~  Read Cache  ~~~~~~~~~~~~~~~~~~~~~~~~ //  
    // Parse Data Memory Address //
    always @(CACHE_READ, CACHE_WRITE, PC) begin
        // Parse CACHE_ADDR //
        if (CACHE_READ || CACHE_WRITE) begin
            // Hash TAG if there is a byte offset //
            if (ext_byteOffset > 5'b00000)
                inputBlk.TAG <= (CACHE_ADDR[31:((31-TAG_SIZE) + 1)]) ^ (CACHE_ADDR[25:0]) ^ (CACHE_ADDR[31:5]);
            else 
                inputBlk.TAG <= (CACHE_ADDR[31:((31-TAG_SIZE) + 1)]);
            inputBlk.SO <= CACHE_ADDR[(31-TAG_SIZE):(w+2)];
            inputBlk.WO <= CACHE_ADDR[((w-1)+2):2];
            inputBlk.BO <= CACHE_ADDR[1:0];
            
            // Output Tags for Hazard Control //
            TAGS <= {cache.setArr[0].blkArr[0].TAG, cache.setArr[0].blkArr[1].TAG, cache.setArr[0].blkArr[2].TAG, cache.setArr[0].blkArr[3].TAG,
                    cache.setArr[1].blkArr[0].TAG, cache.setArr[1].blkArr[1].TAG, cache.setArr[1].blkArr[2].TAG, cache.setArr[1].blkArr[3].TAG,
                    cache.setArr[2].blkArr[0].TAG, cache.setArr[2].blkArr[1].TAG, cache.setArr[2].blkArr[2].TAG, cache.setArr[2].blkArr[3].TAG,
                    cache.setArr[3].blkArr[0].TAG, cache.setArr[3].blkArr[1].TAG, cache.setArr[3].blkArr[2].TAG, cache.setArr[3].blkArr[3].TAG};
                    
            // Get the smallest CNT (if Cache is full) //
            if ((cache.setArr[inputBlk.SO].blkArr[1].CNT < cache.setArr[inputBlk.SO].blkArr[0].CNT) &&
                (cache.setArr[inputBlk.SO].blkArr[1].CNT < cache.setArr[inputBlk.SO].blkArr[2].CNT) &&
                (cache.setArr[inputBlk.SO].blkArr[1].CNT < cache.setArr[inputBlk.SO].blkArr[3].CNT)) begin
                refIDX <= 1;
            end
            else if ((cache.setArr[inputBlk.SO].blkArr[2].CNT < cache.setArr[inputBlk.SO].blkArr[0].CNT) &&
                (cache.setArr[inputBlk.SO].blkArr[2].CNT < cache.setArr[inputBlk.SO].blkArr[1].CNT) &&
                (cache.setArr[inputBlk.SO].blkArr[2].CNT < cache.setArr[inputBlk.SO].blkArr[3].CNT)) begin
                refIDX <= 2;
            end
            else if ((cache.setArr[inputBlk.SO].blkArr[3].CNT < cache.setArr[inputBlk.SO].blkArr[0].CNT) &&
                (cache.setArr[inputBlk.SO].blkArr[3].CNT < cache.setArr[inputBlk.SO].blkArr[1].CNT) &&
                (cache.setArr[inputBlk.SO].blkArr[3].CNT < cache.setArr[inputBlk.SO].blkArr[2].CNT)) begin
                refIDX <= 3;
            end
            else begin
                refIDX <= 0;
            end   
        end
        
        // Toggle off MEM_RDEN2 and MEM_WE2 //
        else begin
            MEM_RDEN2 <= 'b0;
            MEM_WE2 <= 'b0;
        end
    end    

    
    // Parse Instruction Memory Address //
    always_comb begin
        // Parse PC //
        if (MEM_RDEN1) begin
            // Hash TAG if there is a byte offset //
            instr_inputBlk.TAG <= {{18'b0}, PC[13:4]};
            instr_inputBlk.SO <= PC[3:2];
            instr_inputBlk.WO <= PC[1:0];
            instr_inputBlk.BO <= 2'b0;    
            instr_wbSig <= 'b1;
                    
            // Get the smallest CNT (if Cache is full) //
            if ((instr_cache.setArr[instr_inputBlk.SO].blkArr[1].CNT < instr_cache.setArr[instr_inputBlk.SO].blkArr[0].CNT) &&
                (instr_cache.setArr[instr_inputBlk.SO].blkArr[1].CNT < instr_cache.setArr[instr_inputBlk.SO].blkArr[2].CNT) &&
                (instr_cache.setArr[instr_inputBlk.SO].blkArr[1].CNT < instr_cache.setArr[instr_inputBlk.SO].blkArr[3].CNT)) begin
                instr_refIDX <= 1;
            end
            else if ((instr_cache.setArr[instr_inputBlk.SO].blkArr[2].CNT < instr_cache.setArr[instr_inputBlk.SO].blkArr[0].CNT) &&
                (instr_cache.setArr[instr_inputBlk.SO].blkArr[2].CNT < instr_cache.setArr[instr_inputBlk.SO].blkArr[1].CNT) &&
                (instr_cache.setArr[instr_inputBlk.SO].blkArr[2].CNT < instr_cache.setArr[instr_inputBlk.SO].blkArr[3].CNT)) begin
                instr_refIDX <= 2;
            end
            else if ((instr_cache.setArr[instr_inputBlk.SO].blkArr[3].CNT < instr_cache.setArr[instr_inputBlk.SO].blkArr[0].CNT) &&
                (instr_cache.setArr[instr_inputBlk.SO].blkArr[3].CNT < instr_cache.setArr[instr_inputBlk.SO].blkArr[1].CNT) &&
                (instr_cache.setArr[instr_inputBlk.SO].blkArr[3].CNT < instr_cache.setArr[instr_inputBlk.SO].blkArr[2].CNT)) begin
                instr_refIDX <= 3;
            end
            else begin
                instr_refIDX <= 0;
            end   
        end
    
        // Toggle off MEM_RDEN2 and MEM_WE2 //
//        else begin
//            instr_lwStall <= 'b0;
//        end
    end   
    
    
    // Counter increment logic
    always_ff @(posedge CLK) begin
        if (state != CHECK) begin
            delay_state <= delay_state + 'b1;
        end else begin
            delay_state <= 'b0;
        end
    end
    
    always_ff @(posedge CLK) begin 
        if (instr_state != INSTR) begin
            instr_delay_state <= instr_delay_state + 'b1;
            instr_flushCancel <= 'b0;
        end
        else if (instr_lwStall) begin
            instr_flushCancel <= instr_flushCancel + 2'b01;
        end else begin
            instr_delay_state <= 'b0;
        end

        if (instr_flushCancel == 2'b10) begin
            instr_flushCancel <= 2'b00;
        end
    end
    
    
    // Combinational Logic for Data Memory //
    always_comb begin
        if (state == CHECK) begin
            if ((CACHE_READ || CACHE_WRITE) && (inputBlk != oldInputBlk)) begin
                oldInputBlk = inputBlk;   
                if (CACHE_READ/* && wbSig && !writtenSig */) begin
                    $display("Reading from Cache -> Set #%d\n", inputBlk.SO);
                    // Set stallSig (Assume Cache misses) //
                    stallSig = 'b1;
                end
                else if (CACHE_WRITE) begin
                    $display("Writing to Cache -> Set #%d\n", inputBlk.SO);
                end
                             
                for (int i = 0; i < b; i++) begin
                    // (LOAD) Check for Cache Hit: Read from Cache //
                    if (CACHE_READ) begin                         
                        $display("Checking for Cache Hits: Block #%d\n", i);
                        if (cache.setArr[inputBlk.SO].blkArr[i].validBit == 'b1) begin
                            if (cache.setArr[inputBlk.SO].blkArr[i].TAG == inputBlk.TAG) begin                                    
                                $display("\tCache Hit: Block #%d\n", i);
                                
                                // Update CNT //
                                cache.setArr[inputBlk.SO].setCNT = (cache.setArr[inputBlk.SO].setCNT + 'b1);
                                cache.setArr[inputBlk.SO].blkArr[i].CNT = cache.setArr[inputBlk.SO].setCNT;
                                
                                // Toggle Signals //
                                wbSig = 'b0;
                                writtenSig = 'b1;
                                stallSig = 'b0;
                                
                                // Output Data //
                                byteIDX = inputBlk.BO;
                                case ({MEM_SIGN, MEM_SIZE, byteOffset}) 
                                    5'b01000: DOUT = {cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[0], // Word
                                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[1],
                                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[2],
                                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[3]};
                                                   
                                    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //
                                                    
                                    5'b10000: DOUT = {24'b0, cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO]};   // Unsigned Byte                                    
                                    5'b10001: DOUT = {24'b0, cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO]};  
                                    5'b10010: DOUT = {24'b0, cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO]};
                                    5'b10011: DOUT = {24'b0, cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO]};
                                    
                                    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //
                                    
                                    5'b10100: begin
                                        wordIDX = (inputBlk.WO + 'b1);
                                        if ((byteIDX = (inputBlk.BO + 2'b01)) > 2'b11)
                                            DOUT = {16'b0, cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO], 
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[byteIDX[1:0]]};        // Unsigned Halfword
                                        else
                                            DOUT = {16'b0, cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO], 
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[byteIDX[1:0]]};
                                    end
                                    5'b10101: begin
                                        wordIDX = (inputBlk.WO + 'b1);
                                        if ((byteIDX = (inputBlk.BO + 2'b01)) > 2'b11)
                                            DOUT = {16'b0, cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[byteIDX[1:0]], 
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[(byteIDX[1:0] + 'b1)]};    
                                        else if (byteIDX == 2'b11)
                                            DOUT = {16'b0, cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[byteIDX[1:0]], 
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[2'b00]};         
                                        else
                                            DOUT = {16'b0, cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[byteIDX[1:0]], 
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[(byteIDX[1:0] + 'b1)]};                 
                                    end
                                    5'b10110: begin
                                        wordIDX = (inputBlk.WO + 'b1);
                                        if ((byteIDX = (inputBlk.BO + 2'b10)) > 2'b11)
                                            DOUT = {16'b0, cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[byteIDX[1:0]], 
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[(byteIDX[1:0] + 'b1)]};    
                                        else if (byteIDX == 2'b11)
                                            DOUT = {16'b0, cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[byteIDX[1:0]], 
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[2'b00]};         
                                        else
                                            DOUT = {16'b0, cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[byteIDX[1:0]], 
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[(byteIDX[1:0] + 'b1)]};                 
                                    end
                                    5'b10111: begin
                                        wordIDX = (inputBlk.WO + 'b1);
                                        if ((byteIDX = (inputBlk.BO + 2'b11)) > 2'b11)
                                            DOUT = {16'b0, cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[byteIDX[1:0]], 
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[(byteIDX[1:0] + 'b1)]};    
                                        else if (byteIDX == 2'b11)
                                            DOUT = {16'b0, cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[byteIDX[1:0]], 
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[2'b00]};                         
                                    end
                                     
                                    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //
                                                
                                    5'b00000: DOUT = {{24{cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO][0]}}, 
                                            cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO]};              // Signed Byte                                    
                                    5'b00001: DOUT = {{24{cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO][0]}}, 
                                            cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO]};
                                    5'b00010: DOUT = {{24{cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO][0]}}, 
                                            cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO]};
                                    5'b00011: DOUT = {{24{cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO][0]}}, 
                                            cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO]};
                                    
                                    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //
                                                
                                    5'b00100: begin
                                        wordIDX = (inputBlk.WO + 'b1);
                                        if ((byteIDX = (inputBlk.BO + 2'b01)) > 2'b11)
                                            DOUT = {{16{cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO][0]}},
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO], 
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[byteIDX[1:0]]};        // Signed Halfword
                                        else
                                            DOUT = {{16{cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO][0]}},
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO], 
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[byteIDX[1:0]]};
                                    end
                                    5'b00101: begin
                                        wordIDX = (inputBlk.WO + 'b1);
                                        if ((byteIDX = (inputBlk.BO + 2'b01)) > 2'b11)
                                            DOUT = {{16{cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[byteIDX[1:0]][0]}}, 
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[byteIDX[1:0]], 
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[(byteIDX[1:0] + 'b1)]};    
                                        else if (byteIDX == 2'b11)
                                            DOUT = {{16{cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[byteIDX[1:0]][0]}}, 
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[byteIDX[1:0]], 
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[2'b00]};         
                                        else
                                            DOUT = {{16{cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[byteIDX[1:0]][0]}}, 
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[byteIDX[1:0]], 
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[(byteIDX[1:0] + 'b1)]};                 
                                    end
                                    5'b00110: begin
                                        wordIDX = (inputBlk.WO + 'b1);
                                        if ((byteIDX = (inputBlk.BO + 2'b10)) > 2'b11)
                                            DOUT = {{16{cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[byteIDX[1:0]][0]}}, 
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[byteIDX[1:0]], 
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[(byteIDX[1:0] + 'b1)]};    
                                        else if (byteIDX == 2'b11)
                                            DOUT = {{16{cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[byteIDX[1:0]][0]}}, 
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[byteIDX[1:0]], 
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[2'b00]};         
                                        else
                                            DOUT = {{16{cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[byteIDX[1:0]][0]}}, 
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[byteIDX[1:0]], 
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[(byteIDX[1:0] + 'b1)]};                 
                                    end
                                    5'b00111: begin
                                        wordIDX = (inputBlk.WO + 'b1);
                                        if ((byteIDX = (inputBlk.BO + 2'b11)) > 2'b11)
                                            DOUT = {{16{cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[byteIDX[1:0]][0]}}, 
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[byteIDX[1:0]], 
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[(byteIDX[1:0] + 'b1)]};    
                                        else if (byteIDX == 2'b11)
                                            DOUT = {{16{cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[byteIDX[1:0]][0]}}, 
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[byteIDX[1:0]], 
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[2'b00]};                          
                                    end            
                                    
                                    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //
                                                
                                    default: DOUT = {cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[0], // Word
                                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[1],
                                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[2],
                                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[3]};
                                endcase
                                $display("\tCache Hit: Outputting Data, Word #%d / Byte #%d -> %h / %h\n", 
                                    inputBlk.WO, byteIDX, cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO],
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[byteIDX]);
                                $display("// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //\n");                                                                 
                                
                                // Exit the loop //
                                break;
                            end                         
                        end
                    end
                    
                    // (STORE) If Cache has an empty block or already exists, store data to Block with retrieved data //
                    else if (CACHE_WRITE) begin
                        $display("Checking for Empty Block or if Data is already written: Block #%d\n", i);
                        if (cache.setArr[inputBlk.SO].blkArr[i].validBit == 'b0) begin
                            // Locate first empty block //
                            $display("Empty Block Found to Store Data!\n");
                            
                            // Write TAG into cache block //
                            cache.setArr[inputBlk.SO].blkArr[i].TAG = inputBlk.TAG;
                            $display("\tCache Empty: Block #%d, TAG: %h\n", i, inputBlk.TAG);
                            
                            // Set Dirty Bit //
                            cache.setArr[inputBlk.SO].blkArr[i].dirtyBit = 'b1;
                            $display("\t(Write) Cache Replace: Dirty Bit is set\n");
                            
                            // Store external data to Cache, replacing specific word/byte only //                          
                            case({MEM_SIZE, byteOffset})
                                4'b0000: cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO] = CACHE_DIN[7:0];    // sb at byte offsets  
                                4'b0001: cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO] = CACHE_DIN[7:0];
                                4'b0010: cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO] = CACHE_DIN[7:0];
                                4'b0011: cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO] = CACHE_DIN[7:0];
                                
                                // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //
                                
                                4'b0100: begin 
                                    wordIDX = (inputBlk.WO + 'b1);
                                    if ((byteIDX = (inputBlk.BO + 2'b01)) > 2'b11) begin
                                        cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO] = CACHE_DIN[7:0];   // sh at byte offsets
                                        cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[byteIDX[1:0]] = CACHE_DIN[15:8];
                                    end
                                    else begin
                                        cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO] = CACHE_DIN[7:0];   
                                        cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[byteIDX[1:0]] = CACHE_DIN[15:8];
                                    end
                                end
                                4'b0101: begin 
                                    wordIDX = (inputBlk.WO + 'b1);
                                    if ((byteIDX = (inputBlk.BO + 2'b01)) > 2'b11) begin
                                        cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[byteIDX[1:0]] = CACHE_DIN[7:0]; 
                                        cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[(byteIDX[1:0] + 'b1)] = CACHE_DIN[15:8];
                                    end
                                    else if (byteIDX == 2'b11) begin
                                        cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[byteIDX[1:0]] = CACHE_DIN[7:0];  
                                        cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[2'b00] = CACHE_DIN[15:8];
                                    end
                                    else begin
                                        cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[byteIDX[1:0]] = CACHE_DIN[7:0];   
                                        cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[(byteIDX[1:0] + 'b1)] = CACHE_DIN[15:8];
                                    end
                                end
                                4'b0110: begin 
                                    wordIDX = (inputBlk.WO + 'b1);
                                    if ((byteIDX = (inputBlk.BO + 2'b10)) > 2'b11) begin
                                        cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[byteIDX[1:0]] = CACHE_DIN[7:0]; 
                                        cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[(byteIDX[1:0] + 'b01)] = CACHE_DIN[15:8];
                                    end
                                    else if (byteIDX == 2'b11) begin
                                        cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[byteIDX[1:0]] = CACHE_DIN[7:0];  
                                        cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[2'b00] = CACHE_DIN[15:8];
                                    end
                                    else begin
                                        cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[byteIDX[1:0]] = CACHE_DIN[7:0];   
                                        cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[(byteIDX[1:0] + 'b1)] = CACHE_DIN[15:8];
                                    end
                                end
                                4'b0111: begin 
                                    wordIDX = (inputBlk.WO + 'b1);
                                    if ((byteIDX = (inputBlk.BO + 2'b11)) > 2'b11) begin
                                        cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[byteIDX[1:0]] = CACHE_DIN[7:0];   
                                        cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[(byteIDX[1:0] + 'b01)] = CACHE_DIN[15:8];
                                    end
                                    else if (byteIDX == 2'b11) begin
                                        cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[byteIDX[1:0]] = CACHE_DIN[7:0];  
                                        cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[2'b00] = CACHE_DIN[15:8];
                                    end
                                    else begin
                                        cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[byteIDX[1:0]] = CACHE_DIN[7:0];   
                                        cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[(byteIDX[1:0] + 'b1)] = CACHE_DIN[15:8];
                                    end
                                end
                                
                                // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //
                                
                                4'b1000: begin                                                                              // sw
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[3] = CACHE_DIN[7:0];
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[2] = CACHE_DIN[15:8];
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[1] = CACHE_DIN[23:16];
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[0] = CACHE_DIN[31:24];      
                                end                  
                                    
                                // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //
                                    
                                default: begin
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[3] = CACHE_DIN[7:0];
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[2] = CACHE_DIN[15:8];
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[1] = CACHE_DIN[23:16];
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[0] = CACHE_DIN[31:24];   
                                end
                            endcase
                            $display("\t\tCache Written: Data is Stored -> %h to Word #%d / Byte #%d\n", CACHE_DIN, inputBlk.WO, inputBlk.BO);    
                            $display("// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //\n");            
                                                          
                            // Update CNT and set Valid Bit //
                            cache.setArr[inputBlk.SO].setCNT = (cache.setArr[inputBlk.SO].setCNT + 'b1);
                            cache.setArr[inputBlk.SO].blkArr[i].CNT = cache.setArr[inputBlk.SO].setCNT;
                            cache.setArr[inputBlk.SO].blkArr[i].validBit = 'b1;
                            
                            // Continue looking for LOAD/STORE instructions //
                            break;
                        end
                        
                        // (STORE) Cache Hit: data already stored // 
                        else begin
                            if ((cache.setArr[inputBlk.SO].blkArr[i].validBit == 'b1) && cache.setArr[inputBlk.SO].blkArr[i].TAG == inputBlk.TAG) begin
                                if ((MEM_SIZE == 2'b10) && (byteOffset == 2'b00) && 
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[3] == CACHE_DIN[7:0] &&
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[2] == CACHE_DIN[15:8] &&
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[1] == CACHE_DIN[23:16] &&
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[0] == CACHE_DIN[31:24]) begin             // sw
                                    $display("(Write) Data is already stored in Cache!\n");
                                    $display("\tData Stored -> %h in Word #%d / Byte #%d\n", CACHE_DIN, inputBlk.WO, inputBlk.BO);
                                    $display("// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //\n"); 
                                    
                                    // Update CNT //
                                    cache.setArr[inputBlk.SO].setCNT = (cache.setArr[inputBlk.SO].setCNT + 'b1);
                                    cache.setArr[inputBlk.SO].blkArr[i].CNT = cache.setArr[inputBlk.SO].setCNT;
                                    
                                    // Continue looking for LOAD/STORE instructions //
                                    break;
                                end
                                
                                // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //
                                
                                
                                else if ((MEM_SIZE == 2'b00) && (byteOffset == 2'b00) && 
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO] == CACHE_DIN[7:0]) begin    // sb at byte offsets
                                    $display("(Write) Data is already stored in Cache!\n");
                                    $display("\tData Stored -> %h in Word #%d / Byte #%d\n", CACHE_DIN, inputBlk.WO, inputBlk.BO);
                                    $display("// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //\n");
                                    
                                    // Update CNT //
                                    cache.setArr[inputBlk.SO].setCNT = (cache.setArr[inputBlk.SO].setCNT + 'b1);
                                    cache.setArr[inputBlk.SO].blkArr[i].CNT = cache.setArr[inputBlk.SO].setCNT;
                                    
                                    // Continue looking for LOAD/STORE instructions //
                                    break;
                                end
                                else if ((MEM_SIZE == 2'b00) && (byteOffset == 2'b01) && 
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO] == CACHE_DIN[7:0]) begin    // sb at byte offsets
                                    $display("(Write) Data is already stored in Cache!\n");
                                    $display("\tData Stored -> %h in Word #%d / Byte #%d\n", CACHE_DIN, inputBlk.WO, inputBlk.BO);
                                    $display("// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //\n");
                                    
                                    // Update CNT //
                                    cache.setArr[inputBlk.SO].setCNT = (cache.setArr[inputBlk.SO].setCNT + 'b1);
                                    cache.setArr[inputBlk.SO].blkArr[i].CNT = cache.setArr[inputBlk.SO].setCNT;
                                    
                                    // Continue looking for LOAD/STORE instructions //
                                    break;
                                end
                                else if ((MEM_SIZE == 2'b00) && (byteOffset == 2'b10) && 
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO] == CACHE_DIN[7:0]) begin    // sb at byte offsets
                                    $display("(Write) Data is already stored in Cache!\n");
                                    $display("\tData Stored -> %h in Word #%d / Byte #%d\n", CACHE_DIN, inputBlk.WO, inputBlk.BO);
                                    $display("// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //\n");
                                    
                                    // Update CNT //
                                    cache.setArr[inputBlk.SO].setCNT = (cache.setArr[inputBlk.SO].setCNT + 'b1);
                                    cache.setArr[inputBlk.SO].blkArr[i].CNT = cache.setArr[inputBlk.SO].setCNT;
                                    
                                    // Continue looking for LOAD/STORE instructions //
                                    break;
                                end
                                else if ((MEM_SIZE == 2'b00) && (byteOffset == 2'b11) && 
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO] == CACHE_DIN[7:0]) begin    // sb at byte offsets
                                    $display("(Write) Data is already stored in Cache!\n");
                                    $display("\tData Stored -> %h in Word #%d / Byte #%d\n", CACHE_DIN, inputBlk.WO, inputBlk.BO);
                                    $display("// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //\n");
                                    
                                    // Update CNT //
                                    cache.setArr[inputBlk.SO].setCNT = (cache.setArr[inputBlk.SO].setCNT + 'b1);
                                    cache.setArr[inputBlk.SO].blkArr[i].CNT = cache.setArr[inputBlk.SO].setCNT;
                                    
                                    // Continue looking for LOAD/STORE instructions //
                                    break;
                                end
                                
                                // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //
                                
                                else if ((MEM_SIZE == 2'b01) && (byteOffset == 2'b00)) begin
                                    wordIDX = (inputBlk.WO + 'b1);
                                    if ((byteIDX = (inputBlk.BO + 2'b01)) > 2'b11) begin      
                                        if ((cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO] == CACHE_DIN[7:0]) &&
                                            (cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[byteIDX[1:0]] == CACHE_DIN[15:8])) begin   // sh at byte offsets
                                            $display("(Write) Data is already stored in Cache!\n");
                                            $display("\tData Stored -> %h in Word #%d / Byte #%d\n", CACHE_DIN, inputBlk.WO, inputBlk.BO);
                                            $display("// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //\n");
                                            
                                            // Update CNT //
                                            cache.setArr[inputBlk.SO].setCNT = (cache.setArr[inputBlk.SO].setCNT + 'b1);
                                            cache.setArr[inputBlk.SO].blkArr[i].CNT = cache.setArr[inputBlk.SO].setCNT;
                                            
                                            // Continue looking for LOAD/STORE instructions //
                                            break;
                                        end
                                    end
                                    else begin
                                        if ((cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO] == CACHE_DIN[7:0]) &&
                                            (cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[byteIDX[1:0]] == CACHE_DIN[15:8])) begin   // sh at byte offsets
                                            $display("(Write) Data is already stored in Cache!\n");
                                            $display("\tData Stored -> %h in Word #%d / Byte #%d\n", CACHE_DIN, inputBlk.WO, inputBlk.BO);
                                            $display("// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //\n");
                                            
                                            // Update CNT //
                                            cache.setArr[inputBlk.SO].setCNT = (cache.setArr[inputBlk.SO].setCNT + 'b1);
                                            cache.setArr[inputBlk.SO].blkArr[i].CNT = cache.setArr[inputBlk.SO].setCNT;
                                            
                                            // Continue looking for LOAD/STORE instructions //
                                            break;
                                        end
                                    end
                                end
                                else if ((MEM_SIZE == 2'b01) && (byteOffset == 2'b01)) begin
                                    wordIDX = (inputBlk.WO + 'b1);
                                    if ((byteIDX = (inputBlk.BO + 2'b01)) > 2'b11) begin      
                                        if ((cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[byteIDX[1:0]] == CACHE_DIN[7:0]) &&
                                            (cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[(byteIDX[1:0] + 'b1)] == CACHE_DIN[15:8])) begin   // sh at byte offsets
                                            $display("(Write) Data is already stored in Cache!\n");
                                            $display("\tData Stored -> %h in Word #%d / Byte #%d\n", CACHE_DIN, inputBlk.WO, inputBlk.BO);
                                            $display("// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //\n");
                                            
                                            // Update CNT //
                                            cache.setArr[inputBlk.SO].setCNT = (cache.setArr[inputBlk.SO].setCNT + 'b1);
                                            cache.setArr[inputBlk.SO].blkArr[i].CNT = cache.setArr[inputBlk.SO].setCNT;
                                            
                                            // Continue looking for LOAD/STORE instructions //
                                            break;
                                        end
                                    end
                                    else if (byteIDX == 2'b11) begin
                                        if ((cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO] == CACHE_DIN[7:0]) &&
                                            (cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[2'b00] == CACHE_DIN[15:8])) begin   // sh at byte offsets
                                            $display("(Write) Data is already stored in Cache!\n");
                                            $display("\tData Stored -> %h in Word #%d / Byte #%d\n", CACHE_DIN, inputBlk.WO, inputBlk.BO);
                                            $display("// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //\n");
                                            
                                            // Update CNT //
                                            cache.setArr[inputBlk.SO].setCNT = (cache.setArr[inputBlk.SO].setCNT + 'b1);
                                            cache.setArr[inputBlk.SO].blkArr[i].CNT = cache.setArr[inputBlk.SO].setCNT;
                                            
                                            // Continue looking for LOAD/STORE instructions //
                                            break;
                                        end
                                    end
                                    else begin
                                        if ((cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO] == CACHE_DIN[7:0]) &&
                                            (cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[byteIDX[1:0]] == CACHE_DIN[15:8])) begin   // sh at byte offsets
                                            $display("(Write) Data is already stored in Cache!\n");
                                            $display("\tData Stored -> %h in Word #%d / Byte #%d\n", CACHE_DIN, inputBlk.WO, inputBlk.BO);
                                            $display("// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //\n");
                                            
                                            // Update CNT //
                                            cache.setArr[inputBlk.SO].setCNT = (cache.setArr[inputBlk.SO].setCNT + 'b1);
                                            cache.setArr[inputBlk.SO].blkArr[i].CNT = cache.setArr[inputBlk.SO].setCNT;
                                            
                                            // Continue looking for LOAD/STORE instructions //
                                            break;
                                        end
                                    end
                                end
                                else if ((MEM_SIZE == 2'b01) && (byteOffset == 2'b10)) begin
                                    wordIDX = (inputBlk.WO + 'b1);
                                    if ((byteIDX = (inputBlk.BO + 2'b10)) > 2'b11) begin      
                                        if ((cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[byteIDX[1:0]] == CACHE_DIN[7:0]) &&
                                            (cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[(byteIDX[1:0] + 'b1)] == CACHE_DIN[15:8])) begin   // sh at byte offsets
                                            $display("(Write) Data is already stored in Cache!\n");
                                            $display("\tData Stored -> %h in Word #%d / Byte #%d\n", CACHE_DIN, inputBlk.WO, inputBlk.BO);
                                            $display("// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //\n");
                                            
                                            // Update CNT //
                                            cache.setArr[inputBlk.SO].setCNT = (cache.setArr[inputBlk.SO].setCNT + 'b1);
                                            cache.setArr[inputBlk.SO].blkArr[i].CNT = cache.setArr[inputBlk.SO].setCNT;
                                            
                                            // Continue looking for LOAD/STORE instructions //
                                            break;
                                        end
                                    end
                                    else if (byteIDX == 2'b11) begin
                                        if ((cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO] == CACHE_DIN[7:0]) &&
                                            (cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[2'b00] == CACHE_DIN[15:8])) begin   // sh at byte offsets
                                            $display("(Write) Data is already stored in Cache!\n");
                                            $display("\tData Stored -> %h in Word #%d / Byte #%d\n", CACHE_DIN, inputBlk.WO, inputBlk.BO);
                                            $display("// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //\n");
                                            
                                            // Update CNT //
                                            cache.setArr[inputBlk.SO].setCNT = (cache.setArr[inputBlk.SO].setCNT + 'b1);
                                            cache.setArr[inputBlk.SO].blkArr[i].CNT = cache.setArr[inputBlk.SO].setCNT;
                                            
                                            // Continue looking for LOAD/STORE instructions //
                                            break;
                                        end
                                    end
                                    else begin
                                        if ((cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO] == CACHE_DIN[7:0]) &&
                                            (cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[byteIDX[1:0]] == CACHE_DIN[15:8])) begin   // sh at byte offsets
                                            $display("(Write) Data is already stored in Cache!\n");
                                            $display("\tData Stored -> %h in Word #%d / Byte #%d\n", CACHE_DIN, inputBlk.WO, inputBlk.BO);
                                            $display("// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //\n");
                                            
                                            // Update CNT //
                                            cache.setArr[inputBlk.SO].setCNT = (cache.setArr[inputBlk.SO].setCNT + 'b1);
                                            cache.setArr[inputBlk.SO].blkArr[i].CNT = cache.setArr[inputBlk.SO].setCNT;
                                            
                                            // Continue looking for LOAD/STORE instructions //
                                            break;
                                        end
                                    end
                                end
                                else if ((MEM_SIZE == 2'b01) && (byteOffset == 2'b11)) begin
                                    wordIDX = (inputBlk.WO + 'b1);
                                    if ((byteIDX = (inputBlk.BO + 2'b11)) > 2'b11) begin      
                                        if ((cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[byteIDX[1:0]] == CACHE_DIN[7:0]) &&
                                            (cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[(byteIDX[1:0] + 'b1)] == CACHE_DIN[15:8])) begin   // sh at byte offsets
                                            $display("(Write) Data is already stored in Cache!\n");
                                            $display("\tData Stored -> %h in Word #%d / Byte #%d\n", CACHE_DIN, inputBlk.WO, inputBlk.BO);
                                            $display("// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //\n");
                                            
                                            // Update CNT //
                                            cache.setArr[inputBlk.SO].setCNT = (cache.setArr[inputBlk.SO].setCNT + 'b1);
                                            cache.setArr[inputBlk.SO].blkArr[i].CNT = cache.setArr[inputBlk.SO].setCNT;
                                            
                                            // Continue looking for LOAD/STORE instructions //
                                            break;
                                        end
                                    end
                                    else if (byteIDX == 2'b11) begin
                                        if ((cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO] == CACHE_DIN[7:0]) &&
                                            (cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[2'b00] == CACHE_DIN[15:8])) begin   // sh at byte offsets
                                            $display("(Write) Data is already stored in Cache!\n");
                                            $display("\tData Stored -> %h in Word #%d / Byte #%d\n", CACHE_DIN, inputBlk.WO, inputBlk.BO);
                                            $display("// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //\n");
                                            
                                            // Update CNT //
                                            cache.setArr[inputBlk.SO].setCNT = (cache.setArr[inputBlk.SO].setCNT + 'b1);
                                            cache.setArr[inputBlk.SO].blkArr[i].CNT = cache.setArr[inputBlk.SO].setCNT;
                                            
                                            // Continue looking for LOAD/STORE instructions //
                                            break;
                                        end
                                    end
                                    else begin
                                        if ((cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO] == CACHE_DIN[7:0]) &&
                                            (cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[byteIDX[1:0]] == CACHE_DIN[15:8])) begin   // sh at byte offsets
                                            $display("(Write) Data is already stored in Cache!\n");
                                            $display("\tData Stored -> %h in Word #%d / Byte #%d\n", CACHE_DIN, inputBlk.WO, inputBlk.BO);
                                            $display("// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //\n");
                                            
                                            // Update CNT //
                                            cache.setArr[inputBlk.SO].setCNT = (cache.setArr[inputBlk.SO].setCNT + 'b1);
                                            cache.setArr[inputBlk.SO].blkArr[i].CNT = cache.setArr[inputBlk.SO].setCNT;
                                            
                                            // Continue looking for LOAD/STORE instructions //
                                            break;
                                        end
                                    end
                                end
                                
                                // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //
                                
                                else begin
                                    $display("\t(Write) Cache line already exists: Storing Word #%d into Block #%d\n", inputBlk.WO, i);
                                    case({MEM_SIZE, byteOffset})
                                        4'b0000: cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO] = CACHE_DIN[7:0];    // sb at byte offsets  
                                        4'b0001: cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO] = CACHE_DIN[7:0];
                                        4'b0010: cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO] = CACHE_DIN[7:0];
                                        4'b0011: cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO] = CACHE_DIN[7:0];
                                        
                                        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //
                                        
                                        4'b0100: begin 
                                            wordIDX = (inputBlk.WO + 'b1);
                                            if ((byteIDX = (inputBlk.BO + 2'b01)) > 2'b11) begin
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO] = CACHE_DIN[7:0];   // sh at byte offsets
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[byteIDX[1:0]] = CACHE_DIN[15:8];
                                            end
                                            else begin
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO] = CACHE_DIN[7:0];   
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[byteIDX[1:0]] = CACHE_DIN[15:8];
                                            end
                                        end
                                        4'b0101: begin 
                                            wordIDX = (inputBlk.WO + 'b1);
                                            if ((byteIDX = (inputBlk.BO + 2'b01)) > 2'b11) begin
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[byteIDX[1:0]] = CACHE_DIN[7:0]; 
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[(byteIDX[1:0] + 'b1)] = CACHE_DIN[15:8];
                                            end
                                            else if (byteIDX == 2'b11) begin
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[byteIDX[1:0]] = CACHE_DIN[7:0];  
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[2'b00] = CACHE_DIN[15:8];
                                            end
                                            else begin
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[byteIDX[1:0]] = CACHE_DIN[7:0];   
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[(byteIDX[1:0] + 'b1)] = CACHE_DIN[15:8];
                                            end
                                        end
                                        4'b0110: begin 
                                            wordIDX = (inputBlk.WO + 'b1);
                                            if ((byteIDX = (inputBlk.BO + 2'b10)) > 2'b11) begin
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[byteIDX[1:0]] = CACHE_DIN[7:0]; 
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[(byteIDX[1:0] + 'b01)] = CACHE_DIN[15:8];
                                            end
                                            else if (byteIDX == 2'b11) begin
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[byteIDX[1:0]] = CACHE_DIN[7:0];  
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[2'b00] = CACHE_DIN[15:8];
                                            end
                                            else begin
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[byteIDX[1:0]] = CACHE_DIN[7:0];   
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[(byteIDX[1:0] + 'b1)] = CACHE_DIN[15:8];
                                            end
                                        end
                                        4'b0111: begin 
                                            wordIDX = (inputBlk.WO + 'b1);
                                            if ((byteIDX = (inputBlk.BO + 2'b11)) > 2'b11) begin
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[byteIDX[1:0]] = CACHE_DIN[7:0];   
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[(byteIDX[1:0] + 'b01)] = CACHE_DIN[15:8];
                                            end
                                            else if (byteIDX == 2'b11) begin
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[byteIDX[1:0]] = CACHE_DIN[7:0];  
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[2'b00] = CACHE_DIN[15:8];
                                            end
                                            else begin
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[byteIDX[1:0]] = CACHE_DIN[7:0];   
                                                cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[(byteIDX[1:0] + 'b1)] = CACHE_DIN[15:8];
                                            end
                                        end
                                        
                                        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //
                                        
                                        4'b1000: begin                                                                              // sw
                                            cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[3] = CACHE_DIN[7:0];
                                            cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[2] = CACHE_DIN[15:8];
                                            cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[1] = CACHE_DIN[23:16];
                                            cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[0] = CACHE_DIN[31:24];      
                                        end                  
                                            
                                        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //
                                            
                                        default: begin
                                            cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[3] = CACHE_DIN[7:0];
                                            cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[2] = CACHE_DIN[15:8];
                                            cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[1] = CACHE_DIN[23:16];
                                            cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[0] = CACHE_DIN[31:24];   
                                        end
                                    endcase      
                                    $display("\t\tTAG: %h -> Word #%d / Byte #%d: %h\n", 
                                        inputBlk.TAG, inputBlk.WO, inputBlk.BO, CACHE_DIN);
                                    
                                    // Set Dirty Bit //
                                    cache.setArr[inputBlk.SO].blkArr[i].dirtyBit <= 'b1;
                                    $display("\t\t(Write) Dirty Bit remains set\n");
                                    $display("// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //\n");                                   
                                    
                                    // Toggle signals //
                                    wbSig = 'b0;
                                    writtenSig = 'b1;
                                    
                                    // Update CNT //
                                    cache.setArr[inputBlk.SO].setCNT = (cache.setArr[inputBlk.SO].setCNT + 'b1);
                                    cache.setArr[inputBlk.SO].blkArr[i].CNT = cache.setArr[inputBlk.SO].setCNT;  
                                    
                                    // Continue looking for LOAD/STORE instructions //
                                    break;
                               end
                            end
                        end
                    end
                end
                
                // (LOAD) Cache misses //
                if (CACHE_READ && stallSig) begin
                    // Stall Load Instruction //
                    lwStall = 'b1;
                end

                // (STORE) If Cache is full and misses, store data in Least Recently Used block //
                if (CACHE_WRITE && (cache.setArr[inputBlk.SO].blkArr[0].validBit == 'b1) &&
                                   (cache.setArr[inputBlk.SO].blkArr[1].validBit == 'b1) &&
                                   (cache.setArr[inputBlk.SO].blkArr[2].validBit == 'b1) &&
                                   (cache.setArr[inputBlk.SO].blkArr[3].validBit == 'b1) &&
                                   (cache.setArr[inputBlk.SO].blkArr[0].TAG != inputBlk.TAG) &&
                                   (cache.setArr[inputBlk.SO].blkArr[1].TAG != inputBlk.TAG) && 
                                   (cache.setArr[inputBlk.SO].blkArr[2].TAG != inputBlk.TAG) &&
                                   (cache.setArr[inputBlk.SO].blkArr[3].TAG != inputBlk.TAG)) begin
                    $display("Cache completely full!\n");               
                    // Check if block is dirty //
                    if (!cache.setArr[inputBlk.SO].blkArr[refIDX].dirtyBit) begin
                        // Replace least recently used //
                        // Store external data to Cache, replacing specific word/byte only //
                        case({MEM_SIZE, byteOffset})
                        4'b0000: cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO] = CACHE_DIN[7:0];    // sb at byte offsets  
                            4'b0001: cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO] = CACHE_DIN[7:0];
                            4'b0010: cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO] = CACHE_DIN[7:0];
                            4'b0011: cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO] = CACHE_DIN[7:0];
                            
                            // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //
                            
                            4'b0100: begin 
                                wordIDX = (inputBlk.WO + 'b1);
                                if ((byteIDX = (inputBlk.BO + 2'b01)) > 2'b11) begin
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO] = CACHE_DIN[7:0];   // sh at byte offsets
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[byteIDX[1:0]] = CACHE_DIN[15:8];
                                end
                                else begin
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO] = CACHE_DIN[7:0];   
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[byteIDX[1:0]] = CACHE_DIN[15:8];
                                end
                            end
                            4'b0101: begin 
                                wordIDX = (inputBlk.WO + 'b1);
                                if ((byteIDX = (inputBlk.BO + 2'b01)) > 2'b11) begin
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[byteIDX[1:0]] = CACHE_DIN[7:0]; 
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[(byteIDX[1:0] + 'b1)] = CACHE_DIN[15:8];
                                end
                                else if (byteIDX == 2'b11) begin
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[byteIDX[1:0]] = CACHE_DIN[7:0];  
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[2'b00] = CACHE_DIN[15:8];
                                end
                                else begin
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[byteIDX[1:0]] = CACHE_DIN[7:0];   
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[(byteIDX[1:0] + 'b1)] = CACHE_DIN[15:8];
                                end
                            end
                            4'b0110: begin 
                                wordIDX = (inputBlk.WO + 'b1);
                                if ((byteIDX = (inputBlk.BO + 2'b10)) > 2'b11) begin
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[byteIDX[1:0]] = CACHE_DIN[7:0]; 
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[(byteIDX[1:0] + 'b01)] = CACHE_DIN[15:8];
                                end
                                else if (byteIDX == 2'b11) begin
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[byteIDX[1:0]] = CACHE_DIN[7:0];  
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[2'b00] = CACHE_DIN[15:8];
                                end
                                else begin
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[byteIDX[1:0]] = CACHE_DIN[7:0];   
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[(byteIDX[1:0] + 'b1)] = CACHE_DIN[15:8];
                                end
                            end
                            4'b0111: begin 
                                wordIDX = (inputBlk.WO + 'b1);
                                if ((byteIDX = (inputBlk.BO + 2'b11)) > 2'b11) begin
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[byteIDX[1:0]] = CACHE_DIN[7:0];   
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[(byteIDX[1:0] + 'b01)] = CACHE_DIN[15:8];
                                end
                                else if (byteIDX == 2'b11) begin
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[byteIDX[1:0]] = CACHE_DIN[7:0];  
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[2'b00] = CACHE_DIN[15:8];
                                end
                                else begin
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[byteIDX[1:0]] = CACHE_DIN[7:0];   
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[(byteIDX[1:0] + 'b1)] = CACHE_DIN[15:8];
                                end
                            end
                            
                            // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //
                            
                            4'b1000: begin                                                                              // sw
                                cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[3] = CACHE_DIN[7:0];
                                cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[2] = CACHE_DIN[15:8];
                                cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[1] = CACHE_DIN[23:16];
                                cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[0] = CACHE_DIN[31:24];      
                            end                  
                                
                            // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //
                                
                            default: begin
                                cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[3] = CACHE_DIN[7:0];
                                cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[2] = CACHE_DIN[15:8];
                                cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[1] = CACHE_DIN[23:16];
                                cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[0] = CACHE_DIN[31:24];   
                            end
                        endcase      
                        $display("(Write) Cache full: Storing Word #%d in Least Recently Used Block #%d\n", inputBlk.WO, refIDX);
                        $display("\t\t(Write) Cache full: Word #%d / Byte #%d into Block #%d\n", inputBlk.WO, inputBlk.BO, refIDX);
                        $display("\t\tWord #%d: %h\n", inputBlk.WO, CACHE_DIN);
                        
                        // Set Dirty Bit //
                        cache.setArr[inputBlk.SO].blkArr[refIDX].dirtyBit <= 'b1;
                        $display("\t\t(Write) Cache full: Dirty Bit is set\n");
                        $display("// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //\n");                        
                        
                        // Toggle signals //
                        wbSig = 'b0;
                        writtenSig = 'b1;
                        
                        // Update CNT //
                        cache.setArr[inputBlk.SO].setCNT = (cache.setArr[inputBlk.SO].setCNT + 'b1);
                        cache.setArr[inputBlk.SO].blkArr[refIDX].CNT = cache.setArr[inputBlk.SO].setCNT;
                    end
                    else begin
                        $display("\tDirty Bit found in Least Recently Used block!\n");
                        lwStall = 'b1;
                    end
                end
            end
        end
    end
    
    
    // Combinational Logic for Instruction Memory //
    always_comb begin
        if ((instr_state == INSTR) && (!(OPCODE == 7'b1101111 || OPCODE == 7'b1100111) || $isunknown(OPCODE))) begin
            if (instr_flushCancel == 2'b10)
                instr_lwStall = 'b0;
                
            if (MEM_RDEN1 && (instr_inputBlk != instr_oldInputBlk)) begin
                instr_oldInputBlk = instr_inputBlk;   
                if (MEM_RDEN1) begin
                    $display("Reading from Cache -> Set #%d\n", instr_inputBlk.SO);
                    // Set stallSig (Assume Cache misses) //
                    instr_stallSig = 'b1;
                end
                             
                for (int i = 0; i < b; i++) begin
                    // (LOAD) Check for Cache Hit: Read from Cache //
                    if (MEM_RDEN1 && instr_wbSig) begin                         
                        $display("Checking for Cache Hits: Block #%d\n", i);
                        if (instr_cache.setArr[instr_inputBlk.SO].blkArr[i].validBit == 'b1) begin
                            if (instr_cache.setArr[instr_inputBlk.SO].blkArr[i].TAG == instr_inputBlk.TAG) begin                                    
                                $display("\tCache Hit: Block #%d\n", i);
                                
                                // Update CNT //
                                instr_cache.setArr[instr_inputBlk.SO].setCNT = (instr_cache.setArr[instr_inputBlk.SO].setCNT + 'b1);
                                instr_cache.setArr[instr_inputBlk.SO].blkArr[i].CNT = instr_cache.setArr[instr_inputBlk.SO].setCNT;
                                
                                // Toggle Signals //
                                instr_stallSig = 'b0;
                                instr_wbSig = 'b0;
                                
                                // Output Data //
                                INSTR_DOUT = {instr_cache.setArr[instr_inputBlk.SO].blkArr[i].WORD[instr_inputBlk.WO].dBYTE[0], // Word
                                                    instr_cache.setArr[instr_inputBlk.SO].blkArr[i].WORD[instr_inputBlk.WO].dBYTE[1],
                                                    instr_cache.setArr[instr_inputBlk.SO].blkArr[i].WORD[instr_inputBlk.WO].dBYTE[2],
                                                    instr_cache.setArr[instr_inputBlk.SO].blkArr[i].WORD[instr_inputBlk.WO].dBYTE[3]};
                                $display("\tCache Hit: Outputting Data, Word #%d / Byte #%d -> %h / %h\n", 
                                    instr_inputBlk.WO, instr_inputBlk.BO, instr_cache.setArr[instr_inputBlk.SO].blkArr[i].WORD[instr_inputBlk.WO],
                                    instr_cache.setArr[instr_inputBlk.SO].blkArr[i].WORD[instr_inputBlk.WO].dBYTE[instr_inputBlk.BO]);
                                $display("// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //\n");                                                                 
                                
                                // Exit the loop //
                                break;
                            end                         
                        end
                    end
                end
                
                // (LOAD) Cache misses //
                if (MEM_RDEN1 && instr_stallSig) begin
                    // Stall Load Instruction //
                    instr_lwStall = 'b1;
                end
            end
        end
    end
    
    
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //
    
    
    // CACHE FSM (DATA Memory) //
    always_ff @(posedge CLK) begin
        case (state)             
            CHECK: begin 
                MEM_RDEN2 <= 'b0;
                MEM_WE2 <= 'b0;
                if ((CACHE_READ || CACHE_WRITE)) begin    
                    for (int i = 0; i < b; i++) begin
                        // (LOAD) Check for Cache Hit: Read from Cache //
                        if (CACHE_READ) begin                         
                            if (cache.setArr[inputBlk.SO].blkArr[i].validBit == 'b0) begin
                                // (LOAD) If Cache completely misses and has an empty block, write to empty block //
                                // (DATA MEMORY) Have Main Memory ready to be read from //
                                MEM_ADDR <= CACHE_ADDR;
                                IO_IN <= CACHE_IO;
                                MEM_RDEN2 <= 'b1;
                                lwStall <= 'b0;
                                state <= EMPTY;
                            end
                        end                       
                    end
                    
                    // (STORE) If Cache completely misses and is full and is dirty, update Main Memory //
                    if (CACHE_WRITE && (cache.setArr[inputBlk.SO].blkArr[0].validBit == 'b1) &&
                                   (cache.setArr[inputBlk.SO].blkArr[1].validBit == 'b1) &&
                                   (cache.setArr[inputBlk.SO].blkArr[2].validBit == 'b1) &&
                                   (cache.setArr[inputBlk.SO].blkArr[3].validBit == 'b1) &&
                                   (cache.setArr[inputBlk.SO].blkArr[0].TAG != inputBlk.TAG) &&
                                   (cache.setArr[inputBlk.SO].blkArr[1].TAG != inputBlk.TAG) && 
                                   (cache.setArr[inputBlk.SO].blkArr[2].TAG != inputBlk.TAG) &&
                                   (cache.setArr[inputBlk.SO].blkArr[3].TAG != inputBlk.TAG) &&
                                   cache.setArr[inputBlk.SO].blkArr[refIDX].dirtyBit) begin
                        // (DATA MEMORY) Have Main Memory ready to be written to //
                        MEM_ADDR <= {cache.setArr[inputBlk.SO].blkArr[refIDX].TAG, inputBlk.SO, {2'b00}, {2'b00}};
                        MEM_WE2 <= 'b1;
                        MEM_DIN2 <= {{cache.setArr[inputBlk.SO].blkArr[refIDX].WORD[0].dBYTE[0],
                                         cache.setArr[inputBlk.SO].blkArr[refIDX].WORD[0].dBYTE[1],
                                         cache.setArr[inputBlk.SO].blkArr[refIDX].WORD[0].dBYTE[2],
                                         cache.setArr[inputBlk.SO].blkArr[refIDX].WORD[0].dBYTE[3]},
                                     {cache.setArr[inputBlk.SO].blkArr[refIDX].WORD[1].dBYTE[0],
                                         cache.setArr[inputBlk.SO].blkArr[refIDX].WORD[1].dBYTE[1],
                                         cache.setArr[inputBlk.SO].blkArr[refIDX].WORD[1].dBYTE[2],
                                         cache.setArr[inputBlk.SO].blkArr[refIDX].WORD[1].dBYTE[3]},
                                     {cache.setArr[inputBlk.SO].blkArr[refIDX].WORD[2].dBYTE[0],
                                         cache.setArr[inputBlk.SO].blkArr[refIDX].WORD[2].dBYTE[1],
                                         cache.setArr[inputBlk.SO].blkArr[refIDX].WORD[2].dBYTE[2],
                                         cache.setArr[inputBlk.SO].blkArr[refIDX].WORD[2].dBYTE[3]},
                                     {cache.setArr[inputBlk.SO].blkArr[refIDX].WORD[3].dBYTE[0],
                                         cache.setArr[inputBlk.SO].blkArr[refIDX].WORD[3].dBYTE[1],
                                         cache.setArr[inputBlk.SO].blkArr[refIDX].WORD[3].dBYTE[2],
                                         cache.setArr[inputBlk.SO].blkArr[refIDX].WORD[3].dBYTE[3]}};
                        lwStall <= 'b0;    
                        state <= CHECK;
                        
                        // Store external data to Cache, replacing specific word/byte only //
                        case({MEM_SIZE, byteOffset})
                            4'b0000: cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO] <= CACHE_DIN[7:0];    // sb at byte offsets  
                            4'b0001: cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO] <= CACHE_DIN[7:0];
                            4'b0010: cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO] <= CACHE_DIN[7:0];
                            4'b0011: cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO] <= CACHE_DIN[7:0];
                            
                            // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //
                            
                            4'b0100: begin 
                                wordIDX <= (inputBlk.WO + 'b1);
                                if ((byteIDX = (inputBlk.BO + 2'b01)) > 2'b11) begin
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO] <= CACHE_DIN[7:0];   // sh at byte offsets
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[byteIDX[1:0]] <= CACHE_DIN[15:8];
                                end
                                else begin
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[inputBlk.BO] <= CACHE_DIN[7:0];   
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[byteIDX[1:0]] <= CACHE_DIN[15:8];
                                end
                            end
                            4'b0101: begin 
                                wordIDX <= (inputBlk.WO + 'b1);
                                if ((byteIDX = (inputBlk.BO + 2'b01)) > 2'b11) begin
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[byteIDX[1:0]] <= CACHE_DIN[7:0]; 
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[(byteIDX[1:0] + 'b1)] <= CACHE_DIN[15:8];
                                end
                                else if (byteIDX == 2'b11) begin
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[byteIDX[1:0]] <= CACHE_DIN[7:0];  
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[2'b00] = CACHE_DIN[15:8];
                                end
                                else begin
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[byteIDX[1:0]] <= CACHE_DIN[7:0];   
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[(byteIDX[1:0] + 'b1)] <= CACHE_DIN[15:8];
                                end
                            end
                            4'b0110: begin 
                                wordIDX <= (inputBlk.WO + 'b1);
                                if ((byteIDX = (inputBlk.BO + 2'b10)) > 2'b11) begin
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[byteIDX[1:0]] <= CACHE_DIN[7:0]; 
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[(byteIDX[1:0] + 'b01)] <= CACHE_DIN[15:8];
                                end
                                else if (byteIDX == 2'b11) begin
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[byteIDX[1:0]] <= CACHE_DIN[7:0];  
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[2'b00] <= CACHE_DIN[15:8];
                                end
                                else begin
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[byteIDX[1:0]] <= CACHE_DIN[7:0];   
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[(byteIDX[1:0] + 'b1)] <= CACHE_DIN[15:8];
                                end
                            end
                            4'b0111: begin 
                                wordIDX <= (inputBlk.WO + 'b1);
                                if ((byteIDX = (inputBlk.BO + 2'b11)) > 2'b11) begin
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[byteIDX[1:0]] <= CACHE_DIN[7:0];   
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[(byteIDX[1:0] + 'b01)] = CACHE_DIN[15:8];
                                end
                                else if (byteIDX == 2'b11) begin
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[byteIDX[1:0]] <= CACHE_DIN[7:0];  
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[wordIDX[1:0]].dBYTE[2'b00] = CACHE_DIN[15:8];
                                end
                                else begin
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[byteIDX[1:0]] <= CACHE_DIN[7:0];   
                                    cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[(byteIDX[1:0] + 'b1)] <= CACHE_DIN[15:8];
                                end
                            end
                            
                            // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //
                            
                            4'b1000: begin                                                                              // sw
                                cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[3] <= CACHE_DIN[7:0];
                                cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[2] <= CACHE_DIN[15:8];
                                cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[1] <= CACHE_DIN[23:16];
                                cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[0] <= CACHE_DIN[31:24];      
                            end                  
                                
                            // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //
                                
                            default: begin
                                cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[3] <= CACHE_DIN[7:0];
                                cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[2] <= CACHE_DIN[15:8];
                                cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[1] <= CACHE_DIN[23:16];
                                cache.setArr[inputBlk.SO].blkArr[i].WORD[inputBlk.WO].dBYTE[0] <= CACHE_DIN[31:24];   
                            end
                        endcase      
                        $display("(Write) Cache full: Storing Word #%d in Least Recently Used Block #%d\n", inputBlk.WO, refIDX);
                        $display("\t\t(Write) Cache full: Word #%d / Byte #%d into Block #%d\n", inputBlk.WO, inputBlk.BO, refIDX);
                        $display("\t\tWord #%d: %h\n", inputBlk.WO, CACHE_DIN);
                        
                        // Replace TAG in cache block with new TAG//
                        cache.setArr[inputBlk.SO].blkArr[refIDX].TAG <= inputBlk.TAG;
                        $display("\tCache Replaced: Block #%d, Old TAG: %h -> New TAG: %h\n", 
                            refIDX, cache.setArr[inputBlk.SO].blkArr[refIDX].TAG, inputBlk.TAG);
                        
                        // Set Dirty Bit //
                        cache.setArr[inputBlk.SO].blkArr[refIDX].dirtyBit <= 'b1;
                        $display("\t\t(Write) Cache full: Dirty Bit is set\n");
                        $display("// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //\n");                        
                        
                        // Toggle signals //
                        wbSig <= 'b0;
                        writtenSig <= 'b1;
                        
                        // Update CNT //
                        cache.setArr[inputBlk.SO].setCNT <= (cache.setArr[inputBlk.SO].setCNT + 'b1);
                        cache.setArr[inputBlk.SO].blkArr[refIDX].CNT <= (cache.setArr[inputBlk.SO].setCNT + 'b1);             
                    end
                    
                    // (LOAD) If Cache completely misses and is full, replace Least Recently Used block //
                    if (CACHE_READ && (cache.setArr[inputBlk.SO].blkArr[0].validBit == 'b1) &&
                                      (cache.setArr[inputBlk.SO].blkArr[1].validBit == 'b1) &&
                                      (cache.setArr[inputBlk.SO].blkArr[2].validBit == 'b1) &&
                                      (cache.setArr[inputBlk.SO].blkArr[3].validBit == 'b1) &&
                                      (cache.setArr[inputBlk.SO].blkArr[0].TAG != inputBlk.TAG) &&
                                      (cache.setArr[inputBlk.SO].blkArr[1].TAG != inputBlk.TAG) && 
                                      (cache.setArr[inputBlk.SO].blkArr[2].TAG != inputBlk.TAG) &&
                                      (cache.setArr[inputBlk.SO].blkArr[3].TAG != inputBlk.TAG)) begin
                        // (DATA MEMORY) Have Main Memory ready to be read from //
                        MEM_ADDR <= CACHE_ADDR;
                        IO_IN <= CACHE_IO;
                        MEM_RDEN2 <= 'b1;   
                        state <= REPLACE;          
                    end
                end
                
                // Prevent state from executing again on the same instruction //
                else if (CACHE_READ || CACHE_WRITE) begin
                    state <= CHECK;
                end
                
                // Continue looking for LOAD/STORE instructions //
                else begin
                    state <= CHECK;
                    wbSig = 'b1;
                    writtenSig = 'b0;
                end 
            end 
                
                
            EMPTY: begin
                // Allow Main Memory to retrieve data //
                if (!delay_state) begin
                    state <= EMPTY;
                    // Toggle wbSig and writtenSig//
                    wbSig <= 'b0;
                    writtenSig <= 'b1; 
                end
                
                else begin
                    // Cache Misses //
                    $display("Cache completely missed!\n");
                    
                    // Look for the first empty block to store data //
                    for (int i = 0; i < b; i++) begin
                        $display("Cache Missed: Checking if empty -> Block #%d\n", i);
                        // If block is empty //
                        if (cache.setArr[inputBlk.SO].blkArr[i].validBit == 'b0) begin  
                            // Write TAG into cache block //
                            cache.setArr[inputBlk.SO].blkArr[i].TAG <= inputBlk.TAG;
                            $display("\tCache Empty: Block #%d, TAG: %h\n", i, inputBlk.TAG);
                             
                            // Write Data into block //
                            if (memSig) begin
                                wordWrite(i, b, d, MEM_DOUT, inputBlk, cache);                                  
                            end
                            state <= CHECK;                                                                  
                             
                            // Update CNT and set Valid Bit //
                            cache.setArr[inputBlk.SO].setCNT <= (cache.setArr[inputBlk.SO].setCNT + 'b1);
                            cache.setArr[inputBlk.SO].blkArr[i].CNT <= cache.setArr[inputBlk.SO].setCNT;
                            cache.setArr[inputBlk.SO].blkArr[i].validBit <= 'b1;

                            // Exit the loop //
                            break;
                        end
                    end   
                end
            end    
                
                    
            REPLACE: begin                  
                // Allow Main Memory to retrieve data //  
                 if (!delay_state) begin
                    state <= REPLACE;
                    // Toggle signals //
                    wbSig <= 'b0;
                    writtenSig <= 'b1;  
                    MEM_RDEN2 <= 'b0;                                
                 end
                 
                 else begin
                     // If entire set is full //
                     if ('b1) begin
                        $display("Cache completely missed and full: Replacing Least Recently Used Block #%d\n", refIDX);
                        // Replace least recently used //
                        
                        // Check Dirty Bit, update Main Memory if set //
                        if (cache.setArr[inputBlk.SO].blkArr[refIDX].dirtyBit) begin
                            $display("Dirty Bit found: Updating Main Memory\n");
                            MEM_WE2 <= 'b1;
                            MEM_DIN2 <= {{cache.setArr[inputBlk.SO].blkArr[refIDX].WORD[0].dBYTE[0],
                                         cache.setArr[inputBlk.SO].blkArr[refIDX].WORD[0].dBYTE[1],
                                         cache.setArr[inputBlk.SO].blkArr[refIDX].WORD[0].dBYTE[2],
                                         cache.setArr[inputBlk.SO].blkArr[refIDX].WORD[0].dBYTE[3]},
                                     {cache.setArr[inputBlk.SO].blkArr[refIDX].WORD[1].dBYTE[0],
                                         cache.setArr[inputBlk.SO].blkArr[refIDX].WORD[1].dBYTE[1],
                                         cache.setArr[inputBlk.SO].blkArr[refIDX].WORD[1].dBYTE[2],
                                         cache.setArr[inputBlk.SO].blkArr[refIDX].WORD[1].dBYTE[3]},
                                     {cache.setArr[inputBlk.SO].blkArr[refIDX].WORD[2].dBYTE[0],
                                         cache.setArr[inputBlk.SO].blkArr[refIDX].WORD[2].dBYTE[1],
                                         cache.setArr[inputBlk.SO].blkArr[refIDX].WORD[2].dBYTE[2],
                                         cache.setArr[inputBlk.SO].blkArr[refIDX].WORD[2].dBYTE[3]},
                                     {cache.setArr[inputBlk.SO].blkArr[refIDX].WORD[3].dBYTE[0],
                                         cache.setArr[inputBlk.SO].blkArr[refIDX].WORD[3].dBYTE[1],
                                         cache.setArr[inputBlk.SO].blkArr[refIDX].WORD[3].dBYTE[2],
                                         cache.setArr[inputBlk.SO].blkArr[refIDX].WORD[3].dBYTE[3]}};
                            MEM_ADDR <= CACHE_ADDR;
                            state <= DIRTY;
                        end
                        else begin
                             lwStall <= 'b0;   
                        end

                        for (int i = 0; i < d; i++) begin
                            // Retrieve word and write to cache //
                            cache.setArr[inputBlk.SO].blkArr[refIDX].WORD[i].dBYTE[3] <= MEM_DOUT[i][7:0];
                            cache.setArr[inputBlk.SO].blkArr[refIDX].WORD[i].dBYTE[2] <= MEM_DOUT[i][15:8];
                            cache.setArr[inputBlk.SO].blkArr[refIDX].WORD[i].dBYTE[1] <= MEM_DOUT[i][23:16];
                            cache.setArr[inputBlk.SO].blkArr[refIDX].WORD[i].dBYTE[0] <= MEM_DOUT[i][31:24];
                            $display("\t\tCache Replacing: Word #%d / Byte #%d into Block #%d -> %h\n", i, (4*i), refIDX, MEM_DOUT[i]);
                        end

                        // Replace TAG in cache block with new TAG//
                        cache.setArr[inputBlk.SO].blkArr[refIDX].TAG <= inputBlk.TAG;
                        $display("\tCache Replaced: Block #%d, TAG: %h\n", refIDX, inputBlk.TAG);
                        
                        $display("\t\tCache Replaced: Outputting Data -> %h\n", DOUT);
                        $display("// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //\n");
                      
                        
                        // Continue checking for LOAD/STORE instructions if Dirty Bit is off //
                        if (!cache.setArr[inputBlk.SO].blkArr[refIDX].dirtyBit)
                            state <= CHECK;               
                            
                        // Update CNT //
                        cache.setArr[inputBlk.SO].setCNT <= (cache.setArr[inputBlk.SO].setCNT + 'b1);
                        cache.setArr[inputBlk.SO].blkArr[refIDX].CNT <= (cache.setArr[inputBlk.SO].setCNT + 'b1);
                    end               
                end
            end              

                
            DIRTY: begin
                // Allow Main Memory to retrieve data //
                if (!delay_state) begin
                    state <= DIRTY;
                    lwStall <= 'b0;
                end
                
                else begin
                    // Toogle off Dirty Bit //
                    $display("\tMain Memory Updated: Block #%d -> (1)%h, (2)%h, (3)%h, (4)%h\n", 
                    refIDX, cache.setArr[inputBlk.SO].blkArr[refIDX].WORD[0], cache.setArr[inputBlk.SO].blkArr[refIDX].WORD[1],
                    cache.setArr[inputBlk.SO].blkArr[refIDX].WORD[2], cache.setArr[inputBlk.SO].blkArr[refIDX].WORD[3]);
                    $display("\tMain Memory Updated: Dirty Bit was deasserted\n");
                    cache.setArr[inputBlk.SO].blkArr[refIDX].dirtyBit <= 'b0;
                    state <= CHECK;
                end
            end                
               
                         
            default: begin
                    state <= CHECK;
                    lwStall <= 'b0;
                end
        endcase
    end
    
    
     // CACHE FSM (Instruction Memory) //
    always_ff @(posedge CLK) begin
    if (!RESET) begin
        case (instr_state)             
            INSTR: begin 
                INSTR_READ <= 'b0;
                if (MEM_RDEN1 && (!(OPCODE == 7'b1101111 || OPCODE == 7'b1100111) || $isunknown(OPCODE))) begin    
                    for (int i = 0; i < b; i++) begin
                        $display("WHAT THE HECK\n");                       
                        if (instr_cache.setArr[instr_inputBlk.SO].blkArr[i].validBit == 'b0) begin
                            // (LOAD) If Cache completely misses and has an empty block, write to empty block //
                            // (INSTRUCTION MEMORY) Have Main Memory ready to be read from //
                            INSTR_ADDR <= PC;
                            INSTR_READ <= 'b1;
                            instr_state <= INSTR_EMPTY;
                            $display("OH NAH\n");
                        end
                        else
                            if (instr_cache.setArr[instr_inputBlk.SO].blkArr[i].TAG == instr_inputBlk.TAG) begin
                                instr_state <= INSTR;
                                $display("NOT THE INSTR STATE\n");
                                break;                 
                            end
                    end
                    
                    // (LOAD) If Cache completely misses and is full, replace Least Recently Used block //
                    if (MEM_RDEN1 && (instr_cache.setArr[instr_inputBlk.SO].blkArr[0].validBit == 'b1) &&
                                      (instr_cache.setArr[instr_inputBlk.SO].blkArr[1].validBit == 'b1) &&
                                      (instr_cache.setArr[instr_inputBlk.SO].blkArr[2].validBit == 'b1) &&
                                      (instr_cache.setArr[instr_inputBlk.SO].blkArr[3].validBit == 'b1) &&
                                      (instr_cache.setArr[instr_inputBlk.SO].blkArr[0].TAG != instr_inputBlk.TAG) &&
                                      (instr_cache.setArr[instr_inputBlk.SO].blkArr[1].TAG != instr_inputBlk.TAG) && 
                                      (instr_cache.setArr[instr_inputBlk.SO].blkArr[2].TAG != instr_inputBlk.TAG) &&
                                      (instr_cache.setArr[instr_inputBlk.SO].blkArr[3].TAG != instr_inputBlk.TAG)) begin
                        // (DATA MEMORY) Have Main Memory ready to be read from //
                        INSTR_ADDR <= PC;
                        INSTR_READ <= 'b1;   
                        instr_state <= INSTR_REPLACE;          
                    end
                end
                
                // Prevent state from executing again on the same instruction //
                else if (INSTR_READ) begin
                    instr_state <= INSTR;
                end
                
                // Continue looking for LOAD/STORE instructions //
                else begin
                    instr_state <= INSTR;
                end 
            end 
                
                
            INSTR_EMPTY: begin
                // Allow Main Memory to retrieve data //
                if (!instr_delay_state) begin
                    instr_state <= INSTR_EMPTY;
                    instr_wbSig <= 'b1;
                    INSTR_READ <= 'b0;
                    instr_lwStall <= 'b0;
                end
                
                else begin
                    // Cache Misses //
                    $display("Cache completely missed!\n");
                    
                    // Look for the first empty block to store data //
                    for (int i = 0; i < b; i++) begin
                        $display("Cache Missed: Checking if empty -> Block #%d\n", i);
                        // If block is empty //
                        if (instr_cache.setArr[instr_inputBlk.SO].blkArr[i].validBit == 'b0) begin  
                            // Write TAG into cache block //
                            instr_cache.setArr[instr_inputBlk.SO].blkArr[i].TAG <= instr_inputBlk.TAG;
                            $display("\tCache Empty: Block #%d, TAG: %h\n", i, instr_inputBlk.TAG);
                             
                            // Write Data into block //
                            if (instr_memSig) begin
                                // Write data into Cache from Main Memory //
                                for (int j = 0; j < d; j++) begin
                                    $display("\tCache Empty: Write Word #%d / Byte #%d into Block #%d\n", j, (4*j), i);
                                    // Retrieve word and write to cache //
                                    instr_cache.setArr[instr_inputBlk.SO].blkArr[i].WORD[j].dBYTE[3] <= INSTR_MEM_DOUT[j][7:0];
                                    instr_cache.setArr[instr_inputBlk.SO].blkArr[i].WORD[j].dBYTE[2] <= INSTR_MEM_DOUT[j][15:8];
                                    instr_cache.setArr[instr_inputBlk.SO].blkArr[i].WORD[j].dBYTE[1] <= INSTR_MEM_DOUT[j][23:16];
                                    instr_cache.setArr[instr_inputBlk.SO].blkArr[i].WORD[j].dBYTE[0] <= INSTR_MEM_DOUT[j][31:24];
                                    $display("\t\tWord #%d: %h\n", j, instr_cache.setArr[instr_inputBlk.SO].blkArr[i].WORD[j]);
                                end      
                                                
                                $display("\t\tCache Written: Outputting Data -> %h\n", instr_cache.setArr[instr_inputBlk.SO].blkArr[i].WORD[instr_inputBlk.WO]);    
                                $display("// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //\n");                                 
                            end
                            instr_state <= INSTR;                                                                  
                             
                            // Update CNT and set Valid Bit //
                            instr_cache.setArr[instr_inputBlk.SO].setCNT <= (instr_cache.setArr[instr_inputBlk.SO].setCNT + 'b1);
                            instr_cache.setArr[instr_inputBlk.SO].blkArr[i].CNT <= instr_cache.setArr[instr_inputBlk.SO].setCNT;
                            instr_cache.setArr[instr_inputBlk.SO].blkArr[i].validBit <= 'b1;

                            // Exit the loop //
                            break;
                        end
                    end   
                end
            end    
                
                    
            INSTR_REPLACE: begin                  
                // Allow Main Memory to retrieve data //  
                 if (!instr_delay_state) begin
                    instr_state <= INSTR_REPLACE;
                    // Toggle signals //  
                    INSTR_READ <= 'b0;  
                    instr_lwStall <= 'b0;                              
                 end
                 
                 else begin
                     // If entire set is full //
                    $display("Cache completely missed and full: Replacing Least Recently Used Block #%d\n", refIDX);
                    // Replace least recently used //       

                    for (int i = 0; i < d; i++) begin
                        // Retrieve word and write to cache //
                        instr_cache.setArr[instr_inputBlk.SO].blkArr[refIDX].WORD[i].dBYTE[3] <= INSTR_MEM_DOUT[i][7:0];
                        instr_cache.setArr[instr_inputBlk.SO].blkArr[refIDX].WORD[i].dBYTE[2] <= INSTR_MEM_DOUT[i][15:8];
                        instr_cache.setArr[instr_inputBlk.SO].blkArr[refIDX].WORD[i].dBYTE[1] <= INSTR_MEM_DOUT[i][23:16];
                        instr_cache.setArr[instr_inputBlk.SO].blkArr[refIDX].WORD[i].dBYTE[0] <= INSTR_MEM_DOUT[i][31:24];
                        $display("\t\tCache Replacing: Word #%d / Byte #%d into Block #%d -> %h\n", i, (4*i), refIDX, INSTR_MEM_DOUT[i]);
                    end

                    // Replace TAG in cache block with new TAG//
                    instr_cache.setArr[instr_inputBlk.SO].blkArr[refIDX].TAG <= instr_inputBlk.TAG;
                    $display("\tCache Replaced: Block #%d, TAG: %h\n", refIDX, instr_inputBlk.TAG);
                    
                    $display("\t\tCache Replaced: Outputting Data -> %h\n", DOUT);
                    $display("// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //\n");
                  
                    
                    // Continue checking for LOAD/STORE instructions if Dirty Bit is off //
                    if (!instr_cache.setArr[instr_inputBlk.SO].blkArr[refIDX].dirtyBit)
                        instr_state <= INSTR;               
                        
                    // Update CNT //
                    instr_cache.setArr[instr_inputBlk.SO].setCNT <= (instr_cache.setArr[instr_inputBlk.SO].setCNT + 'b1);
                    instr_cache.setArr[instr_inputBlk.SO].blkArr[refIDX].CNT <= instr_cache.setArr[instr_inputBlk.SO].setCNT;
                end               
            end              
          
           
            default: begin
                    instr_state <= INSTR;
                    instr_lwStall <= 'b0;
                end
        endcase
    end
    end
    
endmodule