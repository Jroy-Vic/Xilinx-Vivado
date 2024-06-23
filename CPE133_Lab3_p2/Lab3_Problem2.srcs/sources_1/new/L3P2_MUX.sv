`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Roy Vicerra
// 
// Create Date: 05/03/2023 03:55:39 PM
// Module Name: L3P2_MUX
// Project Name: Lab 3
// Target Devices: Basys3
// Description: MUX Circuit for Problem 2 of Lab 3
//////////////////////////////////////////////////////////////////////////////////


module L3P2_MUX(
    input logic [3:0] D0,
    input logic [3:0] D1,
    input logic SEL,
    output logic [3:0] MUXout
    );
    
    always_comb
    begin
        
    if(SEL == 0)
        MUXout = D0;
    else
        MUXout = D1;
    end
    
endmodule
