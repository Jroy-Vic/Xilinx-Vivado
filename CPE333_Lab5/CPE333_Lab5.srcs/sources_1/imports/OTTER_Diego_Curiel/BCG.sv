`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly San Luis Obispo
// Engineer: Diego Curiel
// Create Date: 02/09/2023 11:30:51 AM
// Module Name: BCG
//////////////////////////////////////////////////////////////////////////////////

module BCG(
    input logic [31:0] RS1,
    input logic [31:0] RS2,
    input logic [31:0] IR,
    output logic [2:0] PC_SOURCE
    );
    
    logic [6:0] opcode;
    logic [2:0] IR_FUNCT;
    logic BR_LT, BR_LTU, BR_EQ;
     
    assign opcode = IR[6:0];
    assign IR_FUNCT = IR[14:12];
    //Assign outputs using conditional logic operators.
    assign BR_LT = $signed(RS1) < $signed(RS2);
    assign BR_LTU = RS1 < RS2;
    assign BR_EQ = RS1 == RS2;
    
    always_comb begin
    case(opcode) 
        7'b1101111: begin // JAL
                PC_SOURCE = 3'b011;
            end
            
        7'b1100111: begin // JALR
                PC_SOURCE = 3'b001;
            end
            
        7'b1100011: begin // BRANCH
            case(IR_FUNCT)
                            3'b000: begin
                                if (BR_EQ == 1'b1)
                                    PC_SOURCE = 3'b010;
                                else
                                    PC_SOURCE = 3'b000; 
                            end
                            3'b001: begin 
                                if (BR_EQ == 1'b0)
                                    PC_SOURCE = 3'b010;
                                else
                                    PC_SOURCE = 3'b000; 
                            end
                            3'b100: begin 
                                if (BR_LT == 1'b1)
                                    PC_SOURCE = 3'b010;
                                else
                                    PC_SOURCE = 3'b000;
                            end
                            3'b101: begin 
                                if (BR_LT == 1'b0)
                                    PC_SOURCE = 3'b010;
                                else
                                    PC_SOURCE = 3'b000;
                            end
                            3'b110: begin 
                                if (BR_LTU == 1'b1)
                                    PC_SOURCE = 3'b010;
                                else
                                    PC_SOURCE = 3'b000;
                            end
                            3'b111: begin 
                                if (BR_LTU == 1'b0)
                                    PC_SOURCE = 3'b010;
                                else
                                    PC_SOURCE = 3'b000;
                            end
            endcase
        end
        
        default: PC_SOURCE = 3'b000;
    endcase
    end
endmodule
