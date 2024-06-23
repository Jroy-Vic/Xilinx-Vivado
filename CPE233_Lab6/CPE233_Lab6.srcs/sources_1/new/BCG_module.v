`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/15/2023 10:47:27 PM
// Design Name: 
// Module Name: BCG_module
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


module BCG_module(
    input[31:0] rs1, rs2,
    output br_eq, br_lt, br_ltu
    );
    
    reg eq, lt, ltu;
    assign br_eq = eq;
    assign br_lt = lt;
    assign br_ltu = ltu;
    
    always @ (rs1, rs2)
    begin
    
    if (rs1 == rs2)
        begin
        eq = 'b1;
        lt = 'b0;
        ltu = 'b0;
        end
        
    else if (rs1 < rs2)
        begin
            if ($signed (rs1) > $signed (rs2))
                begin
                eq = 'b0;
                lt = 'b0;
                ltu = 'b1;
                end
            else
                begin
                eq = 'b0;
                lt = 'b1;
                ltu = 'b1;
                end
        end
        
    else if ($signed (rs1) < $signed (rs2))
        begin
        eq = 'b0;
        lt = 'b1;
        ltu = 'b0;
        end
    
    else
        begin
        eq = 'b0;
        lt = 'b0;
        ltu = 'b0;
        end
    end
        
              
    
endmodule
