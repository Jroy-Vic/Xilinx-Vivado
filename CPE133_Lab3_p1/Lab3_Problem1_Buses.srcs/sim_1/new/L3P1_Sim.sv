`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/03/2023 01:08:42 PM
// Design Name: 
// Module Name: L3P1_Sim
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


module L3P1_Sim();
    logic [3:0] sA, sB;
    logic [1:0] sC, sX;
    logic [3:0] sY;
    logic [9:0] count;

    L3P1_Buses UUT (
        .A(sA), .B(sB), .C(sC), .X(sX), .Y(sY));
     
    initial begin   
        count = 'b0;
        
        forever begin
            sA = count[3:0];
            sB = count[7:4];
            sC = count[9:8];
            #10;
            
            if(count == 'd1023)
                $finish;
                
            count = count + 'b1;
        end
        
    end

endmodule
        

