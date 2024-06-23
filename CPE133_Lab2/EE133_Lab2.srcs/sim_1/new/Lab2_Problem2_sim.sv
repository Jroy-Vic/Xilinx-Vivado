`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/20/2023 08:51:33 PM
// Design Name: 
// Module Name: Lab2_Problem2_sim
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


module Lab2_Problem2_sim();
    logic sJ1, sJ2, sJ3, sJ4, sJ5, sMotion_Passed, sMotion_Failed;
    
    Lab2_Problem2_JudgePanel UUT (
        .J1(sJ1), .J2(sJ2), .J3(sJ3), .J4(sJ4), .J5(sJ5), .Motion_Passed(sMotion_Passed), .Motion_Failed(sMotion_Failed));
        
    initial begin
        sJ1 = 1;
        sJ2 = 1;
        sJ3 = 1;
        sJ4 = 1;
        sJ5 = 1;
        #10;
        
        sJ1 = 1;
        sJ2 = 1;
        sJ3 = 1;
        sJ4 = 1;
        sJ5 = 0;
        #10;
        
        sJ1 = 1;
        sJ2 = 1;
        sJ3 = 1;
        sJ4 = 0;
        sJ5 = 0;
        #10;
        
        sJ1 = 1;
        sJ2 = 1;
        sJ3 = 0;
        sJ4 = 0;
        sJ5 = 0;
        #10;
        
        sJ1 = 1;
        sJ2 = 0;
        sJ3 = 0;
        sJ4 = 0;
        sJ5 = 0;
        #10;
        
        sJ1 = 0;
        sJ2 = 0;
        sJ3 = 0;
        sJ4 = 0;
        sJ5 = 1;
        #10;
        
        sJ1 = 0;
        sJ2 = 0;
        sJ3 = 0;
        sJ4 = 1;
        sJ5 = 1;
        #10;
        
        sJ1 = 0;
        sJ2 = 0;
        sJ3 = 1;
        sJ4 = 1;
        sJ5 = 1;
        #10;
        
        sJ1 = 0;
        sJ2 = 1;
        sJ3 = 1;
        sJ4 = 1;
        sJ5 = 1;
        #10;
        
        sJ1 = 0;
        sJ2 = 0;
        sJ3 = 0;
        sJ4 = 0;
        sJ5 = 0;
        #10;
        
        sJ1 = 1;
        sJ2 = 0;
        sJ3 = 1;
        sJ4 = 0;
        sJ5 = 1;
        #10;
        
        sJ1 = 1;
        sJ2 = 0;
        sJ3 = 1;
        sJ4 = 0;
        sJ5 = 0;
        #10;
        
        sJ1 = 1;
        sJ2 = 0;
        sJ3 = 0;
        sJ4 = 0;
        sJ5 = 1;
        #10;
        
        sJ1 = 1;
        sJ2 = 1;
        sJ3 = 0;
        sJ4 = 0;
        sJ5 = 0;
        #10;
        
        sJ1 = 1;
        sJ2 = 0;
        sJ3 = 1;
        sJ4 = 1;
        sJ5 = 0;
        #10;
        
        sJ1 = 0;
        sJ2 = 1;
        sJ3 = 0;
        sJ4 = 0;
        sJ5 = 1;
        #10;
        
        sJ1 = 0;
        sJ2 = 1;
        sJ3 = 1;
        sJ4 = 1;
        sJ5 = 0;
        #10;
    end
endmodule
