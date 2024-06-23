`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/08/2023 09:46:46 PM
// Design Name: 
// Module Name: TOPlvl_tb
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


module TOPlvl_tb(
    );
    
    reg sClk, sBTN;
    wire [7:0] sSeg;
    wire [3:0] sAn, sled;
    
    TOPlvl UUT(.clk(sClk), .BTN(sBTN), .seg(sSeg), .an(sAn), .led(sled));
    
    initial begin
    sClk = 0; //- init signal
    forever #10 sClk = ~sClk;
    end
    
    initial begin
    sBTN = 'b0;
    #10;
    
    sBTN = 'b0;
    #10;
    
    sBTN = 'b1;
    #10;
    
    sBTN = 'b0;
    #10;

    sBTN = 'b0;
    #10;
    
    sBTN = 'b0;
    #10;

    sBTN = 'b0;
    #10;

    sBTN = 'b0;
    #10;

    sBTN = 'b0;
    #10;
    end
    
endmodule
