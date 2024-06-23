`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/08/2023 04:25:36 PM
// Design Name: 
// Module Name: Clock_Divider
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


module Clock_Divider(
    input Clk,
    output Clk_new
    );
    
    reg [24:0] Clk_refresh;
    
    always @(posedge Clk)
    begin
    if(Clk_refresh == (25'b1111111111111111111111111))
        Clk_refresh <= 0;
    else
        Clk_refresh <= Clk_refresh + 'b1;
    end
    
    assign Clk_new = Clk_refresh[24];
    
endmodule
