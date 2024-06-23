`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Roy Vicerra
// 
// Create Date: 05/18/2023 08:02:32 PM
// Module Name: L5P3_RCA
// Project Name: Lab 5
// Target Devices: Basys3
// Description: RCA Circuit for Problem 3 of Lab 5
//////////////////////////////////////////////////////////////////////////////////


module L5P3_Sim(
    );
    
    logic [3:0] sA, sB;
    logic [4:0] sSum;
    logic sSub;
    
    L5P3_RCA UUT (.A(sA), .B(sB), .Sub(sSub), .Sum(sSum));
    
    initial begin
        sSub = 0;
        sA = 4'b0000;
        sB = 4'b0001;
        #10;
        
        sSub = 0;
        sA = 4'b0001;
        sB = 4'b0001;
        #10;
        
        sSub = 0;
        sA = 4'b1111;
        sB = 4'b1111;
        #10;
        
        sSub = 1;
        sA = 4'b0001;
        sB = 4'b0000;
        #10;
        
        sSub = 1;
        sA = 4'b0001;
        sB = 4'b0001;
        #10;
        
        sSub = 1;
        sA = 4'b0000;
        sB = 4'b0001;
        #10;
    end
endmodule
