`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/19/2024 06:54:13 PM
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
    
   reg [15:0] switches; 
   reg [4:0] buttons;
   reg clk; 
   wire [15:0] leds; 
   wire [7:0] segs; 
   wire [3:0] an; 


OTTER_Wrapper #(.SIM_MODE(1)) my_wrapper(
   .CLK    (clk),
   .BTNC  (buttons),
   .SWITCHES  (switches),
   .LEDS  (leds),
   .CATHODES  (segs),
   .ANODES  (an)  );

   
  //- Generate periodic clock signal    
   initial    
      begin       
         clk = 0;   //- init signal        
         forever  #10 clk = ~clk;    
      end                       
    
    
   initial        
   begin           
      buttons = 5'b01000;    
      #80
      buttons = 5'b00000;
      #500000
      buttons = 5'b10000;
      #3000
      buttons = 5'b00000;
      #500000
      buttons = 5'b10000;
      #3000
      buttons = 5'b00000; 
      #500000 
      buttons = 5'b10000;
      #3000

      buttons = 5'b00000;    

    end
    
endmodule
