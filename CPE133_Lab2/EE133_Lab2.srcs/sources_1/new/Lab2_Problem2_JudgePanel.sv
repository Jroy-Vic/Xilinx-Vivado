`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Roy Vicerra
// 
// Create Date: 04/20/2023 09:54:21 AM
// Module Name: Lab2_Problem2_JudgePanel
// Project Name: Lab 2
// Target Devices: Basys3
// Description: Judge Panel Logic Circuit for Problem 2 of Lab 2
//////////////////////////////////////////////////////////////////////////////////


module Lab2_Problem2_JudgePanel(
    input J1,
    input J2,
    input J3,
    input J4,
    input J5,
    output Motion_Passed,
    output Motion_Failed
    );
    
    assign Motion_Passed = ((J1 & J2) & (J4 | J5 | J3)) | ((J1 & J3) & (J4 | J5)) |
        (((!J1) & J2 & J3) & (J4 | J5)) | ((J4 & J5) & (J1 | J2 | ((!J1) & J3)));
        
    assign Motion_Failed = !(((J1 & J2) & (J4 | J5 | J3)) | ((J1 & J3) & (J4 | J5)) |
        (((!J1) & J2 & J3) & (J4 | J5)) | ((J4 & J5) & (J1 | J2 | ((!J1) & J3))));
endmodule
