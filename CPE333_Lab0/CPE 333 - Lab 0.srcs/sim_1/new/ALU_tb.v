`timescale 1ns / 1ps

module ALU_tb(
    );
    
    reg [31:0] A, B;
    reg [2:0] ALUOp;
    wire [31:0] Result;
    wire Zero;
    
    ALU_32b UUT(.A(A),.B(B),.ALUOp(ALUOp),.Result(Result),.Zero(Zero));
    
    initial begin
    A = 32'h00000001;       // AND Test #1
    B = 32'h00000001;       // Result: 'b1
    ALUOp = 3'b000;
    #10;
    
     A = 32'h00000001;      // AND Test #2
     B = 32'h00000002;      // Result: 'b0
     ALUOp = 3'b000;
    #10;
    
     A = 32'h00000001;      // OR Test #1
     B = 32'h00000001;      // Result: 'b1
     ALUOp = 3'b001;
    #10;
    
     A = 32'h00000001;      // OR Test #2
     B = 32'h00000002;      // Result: 2'b11
     ALUOp = 3'b001;
    #10;
    
     A = 32'h00000001;      // ADD Test
     B = 32'h00000001;      // Result: 2'b10
     ALUOp = 3'b010;
    #10;
    
     A = 32'h00000001;      // SUB Test
     B = 32'h00000001;      // Result: 'b0
     ALUOp = 3'b110;
    #10;
    
     A = 32'h00000001;      // SLT Test #1
     B = 32'h00000001;      // Result: 'b0
     ALUOp = 3'b111;
    #10;
    
     A = 32'h00000001;      // SLT Test #2
     B = 32'h00000002;      // Result: 'b1
     ALUOp = 3'b111;
    #10;
    
    end
endmodule
