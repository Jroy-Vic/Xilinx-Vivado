`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/08/2023 11:25:49 PM
// Design Name: 
// Module Name: FSM_tb
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


module FSM_tb(
    );
    
    reg sBTN, sRCO, sLT, sGT, sGTMax, sClk; 
    wire sCLR, sUPL, sUPH, sWEL, sWEH, sSEL1, sSEL2, sRe;
    wire [1:0] sMODE;
    
    fsm_template UUT(.BTN(sBTN), .RCO(sRCO), .LT(sLT), .GT(sGT), .GTMax(sGTMax), .clk(sClk),
    .CLR(sCLR), .UPL(sUPL), .UPH(sUPH), .WEL(sWEL), .WEH(sWEH), .SEL1(sSEL1), .SEL2(sSEL2),
    .re(sRe), .MODE(sMODE));
    
    initial begin
    sClk = 0; //- init signal
    forever #10 sClk = ~sClk;
    end
    
    initial begin
    sBTN = 'b0;
    sRCO = 'b0;
    sLT = 'b0;
    sGT = 'b0;
    sGTMax = 'b0;
    #10;
    
    sBTN = 'b1;
    sRCO = 'b0;
    sLT = 'b0;
    sGT = 'b1;
    sGTMax = 'b0;
    #10;
    
    sBTN = 'b0;
    sRCO = 'b0;
    sLT = 'b0;
    sGT = 'b0;
    sGTMax = 'b0;
    #10;
    
    sBTN = 'b1;
    sRCO = 'b0;
    sLT = 'b1;
    sGT = 'b0;
    sGTMax = 'b0;
    #10;
    
    sBTN = 'b0;
    sRCO = 'b0;
    sLT = 'b0;
    sGT = 'b0;
    sGTMax = 'b0;
    #10;

    sBTN = 'b0;
    sRCO = 'b0;
    sLT = 'b0;
    sGT = 'b1;
    sGTMax = 'b1;
    #10;

    sBTN = 'b0;
    sRCO = 'b0;
    sLT = 'b0;
    sGT = 'b0;
    sGTMax = 'b0;
    #10;

    sBTN = 'b0;
    sRCO = 'b0;
    sLT = 'b0;
    sGT = 'b1;
    sGTMax = 'b0;
    #10;

    sBTN = 'b0;
    sRCO = 'b0;
    sLT = 'b0;
    sGT = 'b0;
    sGTMax = 'b0;
    #10;

    sBTN = 'b0;
    sRCO = 'b1;
    sLT = 'b0;
    sGT = 'b0;
    sGTMax = 'b0;
    #10;

    sBTN = 'b0;
    sRCO = 'b0;
    sLT = 'b0;
    sGT = 'b0;
    sGTMax = 'b0;
    #10;

    sBTN = 'b0;
    sRCO = 'b1;
    sLT = 'b0;
    sGT = 'b0;
    sGTMax = 'b0;
    #10;
    end
endmodule
