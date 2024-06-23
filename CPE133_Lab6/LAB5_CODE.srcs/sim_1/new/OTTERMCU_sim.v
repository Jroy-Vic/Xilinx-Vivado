`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/15/2023 07:58:45 PM
// Design Name: 
// Module Name: OTTERMCU_sim
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


module OTTERMCU_sim(
    );
    
    reg rst, intr, clk;
    reg [31:0] iobus_in;
    wire [31:0] iobus_out, iobus_addr;
    wire iobus_wr;
    
    OTTER_MCU my_MCU (
        .RST         (rst),
        .intr        (intr),
        .clk         (clk),
        .iobus_in    (iobus_in),
        .iobus_out   (iobus_out), 
        .iobus_addr  (iobus_addr), 
        .iobus_wr    (iobus_wr)   );
        
    //- Generate periodic clock signal    
   initial    
      begin       
         clk = 0;   //- init signal        
         forever  #10 clk = ~clk;    
      end         
      
    initial begin
    rst = 'b1;
    intr = 'b0;
    iobus_in = 'h0000FEED;
    #20;
    
    rst = 'b1;
    intr = 'b0;
    iobus_in = 'h0000FEED;
    #20;
    
    rst = 'b0;
    intr = 'b0;
    iobus_in = 'h0000FEED;
    #100;
    end

endmodule


