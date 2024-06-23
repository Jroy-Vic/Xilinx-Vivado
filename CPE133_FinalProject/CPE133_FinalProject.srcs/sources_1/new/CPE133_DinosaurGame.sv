`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Roy Vicerra
// 
// Create Date: 06/04/2023 12:44:51 AM
// Module Name: CPE133_DinosaurGame
// Project Name: Final Project
// Target Devices: Basys3
// Description: Dinosaur Game for Final Project
//////////////////////////////////////////////////////////////////////////////////


typedef enum {JUMP, STALL, DELAY, GAME, RESET} states;


module CPE133_DinosaurGame(
    input logic Clk,
    input logic jump,
    input logic RST,
    input logic start,
    output logic [15:0] LED,
    output logic [3:0] AN,
    output logic [7:0] CAT
    );
    
    states PS, NS;
    
    always_ff @(posedge Clk)
    begin
    if(RST)
        PS <= RESET;
    else
        PS <= NS;
    end
    
    
// ~~~~~~~~~ Clocks ~~~~~~~~~~~~~~~


    logic [25:0] Clk_refresh;
    
    always_ff @(posedge Clk)
    begin
    if(Clk_refresh == (26'b11111111111111111111111111))
        Clk_refresh <= 0;
    else
        Clk_refresh <= Clk_refresh + 'b1;
    end
    
    
    logic [25:0] jump_delay;

    always_ff @(posedge Clk)
    begin
        if(PS == STALL)
        begin
            if(jump_delay == 26'b11111111111111111111111111)
                jump_delay <= 0;
            else
                jump_delay <= jump_delay + 'b1;
        end
        
        else
            jump_delay <= 0;
    end
    
    
    logic [23:0] pause;
    
    always_ff @(posedge Clk)
    begin
        if(PS == DELAY)
        begin
            if(pause == 24'b111111111111111111111111)
                pause <= 0;
            else
                pause <= pause + 'b1;
        end
        
        else
            pause <= 0;
    end
    
    
    logic [19:0] digit_refresh;
    logic [1:0] game_dig;
    logic [1:0] jump_dig;
    
    always_ff @(posedge Clk)
    begin
        if(digit_refresh == 20'b11111111111111111111)
            digit_refresh <= 0;      
        else
            digit_refresh <= digit_refresh + 'b1;
    end
    
    assign game_dig = digit_refresh[19:18];
    assign jump_dig = digit_refresh[19:18];
    
    
// ~~~~~~~~~ Seven Segment Display ~~~~~~


    logic [3:0] points;
    logic [3:0] points2;
    logic [7:0] points_led;
    logic [7:0] points_led2;
    logic [1:0] ball;
    logic [7:0] ball_led;
    logic [3:0] high_points;
    logic [3:0] high_points2;
    logic [7:0] high_points_led;
    logic [7:0] high_points_led2;

    always_comb
    begin
    if(PS == GAME)
    begin
        case(game_dig)
        2'b00:
            begin
            AN = 4'b0111;
            CAT = 8'b00000011;
            end
        2'b01:
            begin
            AN = 4'b1011;
            CAT = 8'b10000011;
            end
        2'b10:
            begin
            AN = 4'b1101;
            CAT = 8'b01100001;
            end
        2'b11:
            begin
            AN = 4'b1110;
            CAT = 8'b01110011;
            end
        default:
            begin
            AN = 4'b0111;
            CAT = 8'b00000011;
            end
        endcase
    end
    
    else if(PS == RESET)
    begin
        case(jump_dig)
        2'b00:
            begin
            AN = 4'b0111;
            CAT = high_points_led2;
            end
        2'b01:
            begin
            AN = 4'b1011;
            CAT = high_points_led;
            end
        2'b10:
            begin
            AN = 4'b1111;
            CAT = 8'b00000000;
            end
        2'b11:
            begin
            AN = 4'b1110;
            CAT = ball_led;
            end
        default:
            begin
            AN = 4'b0111;
            CAT = high_points_led2;
            end
        endcase
    end
    
    else
    begin
        case(jump_dig)
        2'b00:
            begin
            AN = 4'b0111;
            CAT = points_led2;
            end
        2'b01:
            begin
            AN = 4'b1011;
            CAT = points_led;
            end
        2'b10:
            begin
            AN = 4'b1111;
            CAT = 8'b00000000;
            end
        2'b11:
            begin
            AN = 4'b1110;
            CAT = ball_led;
            end
        default:
            begin
            AN = 4'b0111;
            CAT = points_led2;
            end
        endcase
    end
    end
        
    always_comb
    begin
        case(points)
        4'b0000: points_led = 8'b00000011;
        4'b0001: points_led = 8'b10011111;
        4'b0010: points_led = 8'b00100101;
        4'b0011: points_led = 8'b00001101;
        4'b0100: points_led = 8'b10011001;
        4'b0101: points_led = 8'b01001001;
        4'b0110: points_led = 8'b01000001;
        4'b0111: points_led = 8'b00011111;
        4'b1000: points_led = 8'b00000001;
        4'b1001: points_led = 8'b00001001;
        default: points_led = 8'b00000011;
        endcase
    end
    
    always_comb
    begin
        case(points2)
        4'b0000: points_led2 = 8'b00000011;
        4'b0001: points_led2 = 8'b10011111;
        4'b0010: points_led2 = 8'b00100101;
        4'b0011: points_led2 = 8'b00001101;
        4'b0100: points_led2 = 8'b10011001;
        4'b0101: points_led2 = 8'b01001001;
        4'b0110: points_led2 = 8'b01000001;
        4'b0111: points_led2 = 8'b00011111;
        4'b1000: points_led2 = 8'b00000001;
        4'b1001: points_led2 = 8'b00001001;
        default: points_led2 = 8'b00000011;
        endcase
    end
    
    always_comb
    begin
        case(high_points)
        4'b0000: high_points_led = 8'b00000011;
        4'b0001: high_points_led = 8'b10011111;
        4'b0010: high_points_led = 8'b00100101;
        4'b0011: high_points_led = 8'b00001101;
        4'b0100: high_points_led = 8'b10011001;
        4'b0101: high_points_led = 8'b01001001;
        4'b0110: high_points_led = 8'b01000001;
        4'b0111: high_points_led = 8'b00011111;
        4'b1000: high_points_led = 8'b00000001;
        4'b1001: high_points_led = 8'b00001001;
        default: high_points_led = 8'b00000011;
        endcase
    end
    
    always_comb
    begin
        case(high_points2)
        4'b0000: high_points_led2 = 8'b00000011;
        4'b0001: high_points_led2 = 8'b10011111;
        4'b0010: high_points_led2 = 8'b00100101;
        4'b0011: high_points_led2 = 8'b00001101;
        4'b0100: high_points_led2 = 8'b10011001;
        4'b0101: high_points_led2 = 8'b01001001;
        4'b0110: high_points_led2 = 8'b01000001;
        4'b0111: high_points_led2 = 8'b00011111;
        4'b1000: high_points_led2 = 8'b00000001;
        4'b1001: high_points_led2 = 8'b00001001;
        default: high_points_led2 = 8'b00000011;
        endcase
    end
    
    always_comb
    begin
        case(ball)
        2'b00: ball_led = 8'b11000101;
        2'b01: ball_led = 8'b00111001;
        2'b10: ball_led = 8'b11000101;
        2'b11: ball_led = 8'b11000101;
        default: ball_led = 8'b11000101;
        endcase
    end
    
    
// ~~~~~~~~~ LED Counter ~~~~~~~~~~~
    
    
    logic [4:0] position;
    logic [4:0] pos2;
    logic [4:0] invert_clk;
    logic invert;
    logic [7:0] speed_clk;
    logic speed;
    logic [1:0] pos_dif;

    always_ff @(posedge Clk_refresh[5'b10110 - speed])
    begin
    if(((PS != GAME) && (NS != GAME)) && ((PS != RESET) && (NS != RESET)))
        begin
        if(invert)
            begin
            LED <= 16'b0000000000000000;
            LED[position] <= 'b1;
            LED[pos2] <= 'b1;
            if(position == 5'b01111)
                begin
                if(speed == 'b1)
                    position <= (5'b01101 + pos_dif) * -1;
                else
                    position <= 5'b00000;
                if(invert_clk == 5'b10100)
                    begin
                    invert <= 'b0;
                    invert_clk <= 'b0;
                    end
                else
                    invert_clk <= invert_clk + 'b1;
                end
            
            else
                position <= position + 'b1;
                if(speed_clk == 8'b11111111)
                    begin
                    speed_clk <= 8'b00000000;
                    speed <= speed + 'b1;
                    end
                else
                    speed_clk <= speed_clk + 'b1;
                    
            if(pos2 == 5'b01111)
                pos2 <= (5'b00111 + pos_dif) * -1;
            else
                pos2 <= pos2 + 'b1;
        end   
         
        else   
        begin
            LED <= 16'b1111111111111111;
            LED[position] <= 'b0;
            LED[pos2] <= 'b0;
            if(position == 5'b01111)
                begin
                if(speed == 'b1)
                    position <= (5'b01101 + pos_dif) * -1;
                else
                    position <= 5'b00000;
                if(invert_clk == 5'b01010)
                    begin
                    invert <= 'b1;
                    invert_clk <= invert_clk + 'b1;
                    end
                else
                    invert_clk <= invert_clk + 'b1;
                end
            else
                position <= position + 'b1;
                if(speed_clk == 8'b11111111)
                    begin
                    speed_clk <= 8'b00000000;
                    speed <= speed + 'b1;
                    end
                else
                    speed_clk <= speed_clk + 'b1;
                
            if(pos2 == 5'b01111)
                pos2 <= (5'b00101 + pos_dif) * -1;
            else
                pos2 <= pos2 + 'b1;
        end   
        
            
        if(points == 4'b1010)
            begin
            points <= 4'b0000;
            high_points <= 4'b0000;
            if(points2 == 4'b1010)
                begin
                points2 <= 4'b0000;
                high_points2 <= 4'b0000;
                end
            else
                begin
                points2 <= points2 + 'b1;
                high_points2 <= points2 + 'b1;
                end
            end
        else if((pos2 != position - 'b1) && (pos2 != position + 'b1))
            begin
            if(pos2 == 5'b01011 || position == 5'b01011)
                begin
                points <= points + 'b1;
                high_points <= points + 'b1;
                high_points2 <= points2;
                end
            else
                begin
                points <= points;
                high_points <= points;
                points2 <= points2;
                high_points2 <= points2;
                end
            end
         else if((pos2 == position - 'b1) || (pos2 == position + 'b1))
            begin
            if(pos2 == 5'b01011)
                begin
                points <= points + 'b1;
                high_points <= points + 'b1;
                high_points2 <= points2;
                end    
            
             else
                begin
                points <= points;
                high_points <= points;
                points2 <= points2;
                high_points2 <= points2;
                end        
            end
        else
            begin
            points <= points;
            high_points <= points;
            points2 <= points2;
            high_points2 <= points2;
            end
           
               
        end
        
    else if((PS == GAME) && (NS == GAME))
        begin
        position <= 5'b00000;
        pos2 <= (5'b00001) * -1;
        invert_clk <= 'b0;
        invert <= 'b0;
        speed_clk <= 8'b00000000;
        speed <= 'b0;
        points <= 4'b0000;
        points2 <= 4'b0000;
        end  
        
    else
    begin
        LED <= 16'b1111111111111111;
        position <= 5'b00000;
        pos2 <= (5'b00001) * -1;
        invert_clk <= 'b0;
        invert <= 'b0;
        speed_clk <= 8'b00000000;
        speed <= 'b0;
        points <= 4'b0000;
        points2 <= 4'b0000;
    end
    end   
    
    
// ~~~~~~~~~~~ STATES ~~~~~~~~~~~~~~~~~~~~~
   
    
    always_comb
    begin

    case(PS)
    JUMP:
    begin
    ball = 2'b00;
    if(position == 5'b01011 || pos2 == 5'b01011)
        NS = GAME;
    else if(jump)
        begin
        NS = STALL;
        end
    else
        NS = PS;
    end
   
    STALL:
    begin
    ball = 2'b01;
    if(jump_delay[25] == 'b1)
        NS = DELAY;
    else
        NS = PS;
    end
    
    DELAY:
    begin
    ball = 2'b10;
    if(position == 5'b01011  || pos2 == 5'b01011)
        NS = GAME;
    else
        NS = PS;
    if(pause[23] == 'b1)
        NS = JUMP;
    else
        NS = PS;
    end
    
    GAME:
    begin
    pos_dif = pos_dif + 'b1;
    if(start)
        begin
        NS = JUMP;
        end
    else
        NS = PS;
    end
    
    RESET:
    begin
    ball = 2'b11;
    pos_dif = pos_dif + 'b1;
    if(start)
        begin
        NS = JUMP;
        end
    else
        NS = PS;
    end
    
    default:
    begin
        pos_dif = 2'b00;
        ball = 2'b00;
        NS = RESET;
    end
 
    endcase
   
    end
 
endmodule
