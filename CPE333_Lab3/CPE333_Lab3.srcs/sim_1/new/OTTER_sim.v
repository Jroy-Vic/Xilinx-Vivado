`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/19/2024 12:20:01 AM
// Design Name: 
// Module Name: OTTER_sim
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


module OTTER_sim(
    );
    reg sCLK, sRESET;
    reg [31:0] sIOBUS_IN;
    wire sIOBUS_WR;
    wire [31:0] sIOBUS_OUT, sIOBUS_ADDR;
    
    OTTER_MCU UUT(.CLK(sCLK), .INTR(), .RESET(sRESET),
                .IOBUS_IN(sIOBUS_IN), .IOBUS_OUT(sIOBUS_OUT),
                .IOBUS_ADDR(sIOBUS_ADDR), .IOBUS_WR(sIOBUS_WR));
                
               
    //- Generate periodic clock signal    
   initial    
      begin       
         sCLK = 0;   //- init signal        
         forever  #10 sCLK = ~sCLK;    
      end            
      
      
   initial begin
   sIOBUS_IN = 32'h00000000;
   sRESET = 'b1;
   #20;
   sRESET = 'b0;
   
   end
endmodule
