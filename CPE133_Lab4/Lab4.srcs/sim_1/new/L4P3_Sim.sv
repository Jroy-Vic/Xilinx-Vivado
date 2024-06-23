`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Roy Vicerra
// 
// Create Date: 05/08/2023 06:01:48 AM
// Module Name: L4P1_RCAError
// Project Name: Lab 4
// Target Devices: Basys3
// Description: RCA w/ Error Detection Circuit for Problem 1 of Lab 4
//////////////////////////////////////////////////////////////////////////////////


module L4P3_Sim(
    );
    
    logic [3:0] sA, sB;
    logic [4:0] sS;
    logic sSub;
    
    L4P3_RCA5out UUT (.A(sA), .B(sB), .Sub(sSub), .S(sS));
    
    initial begin
    sA = 4'b0001;
    sB = 4'b0000;
    sSub = 0;
    #10;
    
    sA = 4'b0001;
    sB = 4'b0001;
    sSub = 0;
    #10;
    
    sA = 4'b0011;
    sB = 4'b0001;
    sSub = 0;
    #10;
    
    sA = 4'b1111;
    sB = 4'b1111;
    sSub = 0;
    #10;
    
    sA = 4'b0001;
    sB = 4'b0000;
    sSub = 1;
    #10;
    
    sA = 4'b0001;
    sB = 4'b0001;
    sSub = 1;
    #10;
    
    sA = 4'b0011;
    sB = 4'b0001;
    sSub = 1;
    #10;
    
    sA = 4'b0011;
    sB = 4'b1111;
    sSub = 1;
    #10;
    end
endmodule
