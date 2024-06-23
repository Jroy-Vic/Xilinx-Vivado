`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Roy Vicerra
// 
// Create Date: 05/22/2023 06:05:46 PM
// Module Name: L5P2_Priority
// Project Name: Lab 5
// Target Devices: Basys3
// Description: 8:3 Priority Encoder Circuit for Problem 2 of Lab 5
//////////////////////////////////////////////////////////////////////////////////


module L5P2_Priority(
    input logic ENin,
    input logic [7:0] P,
    output logic ENout,
    output logic [2:0] Out
    );
    
    always_comb
    begin
        if(ENin == 1)
            begin
                logic [2:0] count;
                for(count = 3'b111; count > 3'b000; count = count - 1)
                    begin
                    
                        if(P[count] == 1)
                            begin
                                Out = count;
                                ENout = 1;
                                break;
                            end
                            
                        else
                            begin
                                if(P == 8'b00000001)
                                    begin
                                        Out = 3'b000;
                                        ENout = 1;
                                    end
                                    
                                 else
                                    begin
                                        Out = 3'b000;
                                        ENout = 0;
                                    end
                            end
                            
                    end
            end
            
            
        else
            begin
                Out = 3'b000;
                ENout = 0;
            end
            
    end
endmodule

