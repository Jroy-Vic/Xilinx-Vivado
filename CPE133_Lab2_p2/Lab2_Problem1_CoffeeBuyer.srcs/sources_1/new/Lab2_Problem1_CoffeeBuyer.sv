`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Roy Vicerra
// 
// Create Date: 04/23/2023 11:49:54 PM
// Module Name: Lab2_Problem1_CoffeeBuyer
// Project Name: Lab 2
// Target Devices: Basys3
// Description: Coffee Buyer Circuit for Problem 1 of Lab 2
//////////////////////////////////////////////////////////////////////////////////


module Lab2_Problem1_CoffeeBuyer(
    input Amy,
    input Baker,
    input Cathy,
    input David,
    output Buy,
    output DoNotBuy
    );
    
    assign Buy = (Amy & (!Baker)) | (Amy & Cathy & (!David)) | ((!Amy) & David) | ((!Amy) & Baker & (!Cathy)) | (!(Amy & Baker) & Cathy);
    assign DoNotBuy = !((Amy & (!Baker)) | (Amy & Cathy & (!David)) | ((!Amy) & David) | ((!Amy) & Baker & (!Cathy)) | (!(Amy & Baker) & Cathy));
    
endmodule
