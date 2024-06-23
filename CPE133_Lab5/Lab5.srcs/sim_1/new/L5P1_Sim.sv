`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Roy Vicerra 
// 
// Create Date: 05/16/2023 09:50:59 AM
// Module Name: L5P1_SSD
// Project Name: Lab 5
// Target Devices: Basys3 
// Description: Seven Segment Decoder Circuit for Problem 1 of Lab 5
//////////////////////////////////////////////////////////////////////////////////


module L5P1_Sim(
    );
    
    logic [3:0] sB;
    logic [7:0] sCAT;
    logic [3:0] sAN;
    
    L5P1_SSD UUT(.B(sB), .AN(sAN), .CAT(sCAT));
    
    initial begin
        sAN = 4'b1110;
        sB = 4'b0000;
        #10;
        
        sAN = 4'b1110;
        sB = 4'b0001;
        #10;
        
        sAN = 4'b1110;
        sB = 4'b0010;
        #10;
        
        sAN = 4'b1110;
        sB = 4'b0011;
        #10;
        
        sAN = 4'b1110;
        sB = 4'b0100;
        #10;
        
        sAN = 4'b1110;
        sB = 4'b0101;
        #10;
        
        sAN = 4'b1110;
        sB = 4'b0110;
        #10;
        
        sAN = 4'b1110;
        sB = 4'b0111;
        #10;
        
        sAN = 4'b1110;
        sB = 4'b1000;
        #10;
        
        sAN = 4'b1110;
        sB = 4'b1001;
        #10;
        
        sAN = 4'b1110;
        sB = 4'b1010;
        #10;
        
        sAN = 4'b1110;
        sB = 4'b1011;
        #10;
        
        sAN = 4'b1110;
        sB = 4'b1100;
        #10;
        
        sAN = 4'b1110;
        sB = 4'b1101;
        #10;
        
        sAN = 4'b1110;
        sB = 4'b1110;
        #10;
        
        sAN = 4'b1110;
        sB = 4'b1111;
        #10;
        
    end
endmodule
