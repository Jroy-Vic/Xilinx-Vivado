`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/22/2023 06:28:35 PM
// Design Name: 
// Module Name: L5P2_Sim
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


module L5P2_Sim(
    );
    
    logic [7:0] sP;
    logic sENin, sENout;
    logic [2:0] sOut;
    
    L5P2_Priority UUT (.ENin(sENin), .P(sP), .Out(sOut), .ENout(sENout));
    
    initial begin
        sENin = 1;
        sP = 8'b00000000; 
        #10;
        
        sENin = 1;
        sP = 8'b10000000; 
        #10;
        
        sENin = 1;
        sP = 8'b01000000; 
        #10;
        
        sENin = 1;
        sP = 8'b00100000; 
        #10;
        
        sENin = 1;
        sP = 8'b00010000; 
        #10;
        
        sENin = 1;
        sP = 8'b00001000; 
        #10;
        
        sENin = 1;
        sP = 8'b00000100; 
        #10;
        
        sENin = 1;
        sP = 8'b00000010; 
        #10;
        
        sENin = 1;
        sP = 8'b00000001; 
        #10;
        
        sENin = 1;
        sP = 8'b00101100; 
        #10;
        
        sENin = 0;
        sP = 8'b00000000; 
        #10;
        
        sENin = 0;
        sP = 8'b01001100; 
        #10;
        
    end
endmodule
