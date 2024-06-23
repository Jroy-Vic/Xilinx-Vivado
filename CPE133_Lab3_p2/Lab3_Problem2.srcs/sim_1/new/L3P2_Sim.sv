`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/03/2023 07:25:25 PM
// Design Name: 
// Module Name: L3P2_Sim
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


module L3P2_Sim();
    logic sA, sB, sRESULT;
    logic [1:0] sSEL;
    
    L3P2_MUX_Circuit UUT (
        .A(sA), .B(sB), .SEL(sSEL), .RESULT(sRESULT));
        
    initial begin
        sA = 1;
        sB = 0;
        sSEL = 2'b00;
        #10;
        sSEL = 2'b01;
        #10;
        sSEL = 2'b10;
        #10;
        sSEL = 2'b11;
        #10;
        
        sA = 1;
        sB = 1;
        sSEL = 2'b00;
        #10;
        sSEL = 2'b01;
        #10;
        sSEL = 2'b10;
        #10;
        sSEL = 2'b11;
        #10;
        
        sA = 0;
        sB = 0;
        sSEL = 2'b00;
        #10;
        sSEL = 2'b01;
        #10;
        sSEL = 2'b10;
        #10;
        sSEL = 2'b11;
        #10;
        $finish;
    end
        
endmodule
