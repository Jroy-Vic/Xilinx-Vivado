`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/24/2023 12:01:52 AM
// Design Name: 
// Module Name: Lab2_Problem1_Sim
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


module Lab2_Problem1_Sim();
    logic sAmy, sBaker, sCathy, sDavid, sBuy, sDoNotBuy;
    
    Lab2_Problem1_CoffeeBuyer UUT (
        .Amy(sAmy), .Baker(sBaker), .Cathy(sCathy), .David(sDavid), .Buy(sBuy), .DoNotBuy(sDoNotBuy));
        
    initial begin
        sAmy = 1;
        sBaker = 1;
        sCathy = 1;
        sDavid = 0;
        #10;
        
        sAmy = 0;
        sBaker = 1;
        sCathy = 0;
        sDavid = 1;
        #10;
        
        sAmy = 0;
        sBaker = 1;
        sCathy = 1;
        sDavid = 1;
        #10;
        
        sAmy = 1;
        sBaker = 0;
        sCathy = 0;
        sDavid = 1;
        #10;
        
        sAmy = 0;
        sBaker = 1;
        sCathy = 0;
        sDavid = 1;
        #10;
        
        sAmy = 1;
        sBaker = 0;
        sCathy = 1;
        sDavid = 1;
        #10;
        
        sAmy = 0;
        sBaker = 1;
        sCathy = 1;
        sDavid = 1;
        #10;
        
        sAmy = 0;
        sBaker = 1;
        sCathy = 0;
        sDavid = 0;
        #10;
        
        sAmy = 0;
        sBaker = 0;
        sCathy = 0;
        sDavid = 0;
        #10;
        
        sAmy = 0;
        sBaker = 0;
        sCathy = 0;
        sDavid = 1;
        #10;
        
        
    end
endmodule
