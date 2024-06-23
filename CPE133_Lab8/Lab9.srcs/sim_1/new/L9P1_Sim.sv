`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/25/2023 11:05:17 AM
// Design Name: 
// Module Name: L9P1_Sim
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


module L9P1_Sim(
    );
    
    logic sClk, sReset, sCoffee, sExams, sGrades, sHousework;
    
    L9P1_ProfFSM UUT (.Clk(sClk), .Reset(sReset), .Coffee(sCoffee), .Exams(sExams), .Grades(sGrades), .Housework(sHousework));
    
    initial begin
    sClk = 1;
    
    sReset = 1;
    sCoffee = 0;
    sExams = 0;
    #10;
    
    sReset = 0;
    sCoffee = 0;
    sExams = 0;
    #10;
    
    sReset = 0;
    sCoffee = 1;
    sExams = 0;
    #10;
    
    sReset = 0;
    sCoffee = 1;
    sExams = 0;
    #10;
    
    sReset = 0;
    sCoffee = 1;
    sExams = 1;
    #10;
    
    sReset = 0;
    sCoffee = 1;
    sExams = 1;
    #10;
    
    sReset = 0;
    sCoffee = 1;
    sExams = 1;
    #10;
    
    sReset = 0;
    sCoffee = 1;
    sExams = 1;
    #10;
    
    sReset = 0;
    sCoffee = 0;
    sExams = 1;
    #10;
    
    sReset = 0;
    sCoffee = 0;
    sExams = 1;
    #10;
    
    sReset = 0;
    sCoffee = 0;
    sExams = 1;
    #10;
    
    sReset = 0;
    sCoffee = 0;
    sExams = 1;
    #10;
    
    sReset = 0;
    sCoffee = 0;
    sExams = 0;
    #10;
    
    sReset = 0;
    sCoffee = 0;
    sExams = 0;
    #10;
    end
    
    always begin
    #10;
    sClk = ~sClk;
    end
endmodule
