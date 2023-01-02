`timescale 1ns / 1ps

//clock divider equation
//divison_value = (input clock / (2*desired frequency)) - 1
//input clock has frequency 100Hz (period 0.01s)
//we want output clock to be period 1 second and 50% duty cycle clock
//so we want a clock that is in one state for 50 clock cycle and switch state
module one_second_clock(input rst, clock, output reg out);
reg [49:0] count;

//counts up to 50
always @(posedge clock) begin
if (rst)
count <= {1'b1, {49{1'b0}}};     //1000....000
else
count <= {count[48:0], count[49]};
end

always @(posedge clock) begin
if (rst)
out <= 1'b0;
else if (count[49] == 1)   //every 50 clock cyle (0.5s), invert
out <= ~out;
end
endmodule

//input clock has frequency 100Hz (period 0.01s)
//we want period 2 second clock with 50% duty cycle
//division value = (100Hz / (2*0.5Hz)) - 1
//so we want a clock that is in one state for 100 clock cycle and swtich state
module two_second_clock(input rst, clock, output reg out);
reg [99:0] count;
always @(posedge clock) begin
if (rst)
count <= {1'b1, {99{1'b0}}};
else
count <= {count[98:0], count[99]};
end

always @(posedge clock) begin
if (rst)
out <= 1'b0;
else if (count[99] == 1)
out <= ~out; 
end
endmodule

//Seven Segment Display
//pick which digit out of 4 to be displayed
module refresh_counter(input clock, output reg [1:0] out = 0);
always @ (posedge clock)
out <= out + 1;
endmodule

module anode_control(input [1:0] refresh_counter, output reg [3:0] anode = 0);
always @(refresh_counter)
begin
case(refresh_counter)
2'b00 : anode <= 4'b1110;   //right most anode will turn on (digit 1 is on)
2'b01 : anode <= 4'b1101;   //digit 2 is on
2'b10 : anode <= 4'b1011;   //digit 3 is on
2'b11 : anode <= 4'b0111;   //digit 4 is on
endcase
end
endmodule

module BCD_control(input [3:0] digit1, digit2, digit3, digit4, input [1:0] refresh_counter, output reg [3:0] one_digit);
always @(refresh_counter) begin
case (refresh_counter)
2'b00 : one_digit = digit1;
2'b01 : one_digit = digit2;
2'b10 : one_digit = digit3;
2'b11 : one_digit = digit4;
endcase
end
endmodule

module BCD_to_Cathodes(input [3:0] one_digit, output reg [7:0] cathode = 0);
always @(one_digit) begin
case(one_digit)
4'b0 : cathode <= 8'b11111100;
4'b1 : cathode <= 8'b01100000;
4'b0010 : cathode <= 8'b11011010;
4'b0011 : cathode <= 8'b11110010;
4'b0010 : cathode <= 8'b01100110;
4'b0101 : cathode <= 8'b10110110;
4'b0110 : cathode <= 8'b10111110;
4'b0111 : cathode <= 8'b11100100;
4'b1000 : cathode <= 8'b11111110;
4'b1001 : cathode <= 8'b11110110;
endcase
end
endmodule

module Parking_Meter(
    input add60,
    input add120,
    input add180,
    input add300,
    input rst16,
    input rst150,
    input clock,
    input rst,
    output reg [7:0] led_segment,
    output reg [3:0] display_num
    );
    reg [3:0] count_time [3:0];   //0000 ~ 9999
    reg [1:0] current_state;
    reg [1:0] next_state;
    reg temp_clock;
    
    //state assignment
    parameter init = 2'b00;
    parameter greater_180 = 2'b01;
    parameter less_180 = 2'b10;
    
    //current state
    always @(posedge clock) begin
    if (rst)
    current_state <= init;
    else
    current_state <= next_state;
    end
    
    wire one_sec_clock;
    //counting down the time remaining every one second
    one_second_clock a1(rst, clock, one_sec_clock);
    always @(posedge one_sec_clock) begin
    if (count_time[0] > 0)
    count_time[0] = count_time[0] - 1;
    else if (count_time[0] == 0) begin
        if (count_time[1] > 0) begin
        count_time[1] <= count_time[1] - 1;
        count_time[0] <= 9;
        end
        else if (count_time[1] == 0) begin
            if (count_time[2] > 0) begin
            count_time[2] <= count_time[2] - 1;
            count_time[1] <= 9;
            count_time[0] <= 9; 
            end
            else if (count_time[2] == 0) begin
                if (count_time[3] > 0) begin
                count_time[3] <= count_time[3] - 1;
                count_time[2] <= 9;
                count_time[1] <= 9;
                count_time[0] <= 9;
                end
                else if (count_time[3] == 0) begin
                count_time[3] <= 0;
                count_time[2] <= 0;
                count_time[1] <= 0;
                count_time[0] <= 0;
                end
           end
        end
    end
    end
    
    //when add button is pressed
    always @(posedge one_sec_clock) begin
    //cannot add beyond 9999
    if (add60 == 1) begin
    if (count_time[1] < 4)
    count_time[1] <= count_time[1] + 6;
    else begin
    count_time[1] <= (count_time[1] + 6) % 10;
    if (count_time[2] < 9)
    count_time[2] <= count_time[2] + 1;
    else begin
    count_time[2] <= 0;
    if (count_time[3] < 9)
    count_time[3] <= count_time[3] + 1;
    else
    count_time[3] <= 9;
    end
    end
    end
    else if (add120 == 1) begin
    if (count_time[1] < 8) begin    //add 2
    count_time[1] <= count_time[1] + 2;
    if (count_time[2] < 9)         //add 1
    count_time[2] <= count_time[2] + 1;
    else begin
    count_time[2] <= 0;
    if (count_time[3] < 9)
    count_time[3] <= count_time[3] + 1;
    else
    count_time[3] <= count_time[3];
    end
    end
    else if (count_time[1] >= 8) begin    //if count_time[1] overflow when add 2
    count_time[1] <= (count_time[1] + 2) % 10;
     if (count_time[2] < 8)         //add 1 + 1
    count_time[2] <= count_time[2] + 2;
    else begin
    count_time[2] <= (count_time[2] + 2) % 10; 
    if (count_time[3] < 9)
    count_time[3] <= count_time[3] + 1;
    else
    count_time[3] <= count_time[3];
    end
    end
    end
    else if (add180 == 1) begin
     if (count_time[1] < 2) begin    //add 8
    count_time[1] <= count_time[1] + 8;
    if (count_time[2] < 9)         //add 1
    count_time[2] <= count_time[2] + 1;
    else begin
    count_time[2] <= 0;
    if (count_time[3] < 9)
    count_time[3] <= count_time[3] + 1;
    else
    count_time[3] <= count_time[3];
    end
    end
    else if (count_time[1] >= 2) begin    //if count_time[1] overflow when add 8
    count_time[1] <= (count_time[1] + 8) % 10;
     if (count_time[2] < 8)         //add 1 + 1
    count_time[2] <= count_time[2] + 2;
    else begin
    count_time[2] <= (count_time[2] + 2) % 10; 
    if (count_time[3] < 9)
    count_time[3] <= count_time[3] + 1;
    else
    count_time[3] <= count_time[3];
    end
    end
    end
    else if (add300 == 1) begin
    if (count_time[2] < 7)
    count_time[2] <= count_time[2] + 3;
    else begin
    count_time[2] <= (count_time[2] + 3) % 10;
    if (count_time[3] < 9)
    count_time[3] <= count_time[3] + 1;
    else
    count_time[3] <= count_time[3];
    end
    end
    else if (rst16 == 1) begin
    count_time[3] <= 0;
    count_time[2] <= 0;
    count_time[1] <= 1;
    count_time[0] <= 6;
    end
    else if (rst150 == 1) begin
    count_time[3] <= 0;
    count_time[2] <= 1;
    count_time[1] <= 5;
    count_time[2] <= 0;
    end
    end
    
    //defining next state
    always @(*) begin
    case (current_state)
    init: begin
    
    count_time[0] <= 0;
    count_time[1] <= 0;
    count_time[2] <= 0;
    count_time[3] <= 0;
     
    if (rst)
    next_state <= init;
    else if (add180 == 1 || add300 == 1)
    next_state <= greater_180;
    else if (add60 == 1 || add120 == 1 || rst16 == 1 || rst150 == 1)
    next_state <= less_180;
    end
    
    greater_180: begin
    if (rst)
    next_state <= init;
    else if (rst16 == 1 || rst150 == 1)
    next_state <= less_180;
    else if ((count_time[3] == 0 && count_time[2] == 0 && add120 == 0 && add180 == 0 && add300 == 0) || 
    (count_time[3] == 0 && count_time[2] == 0 && count_time[1] < 6 && add180 == 0 && add300 == 0) ||
    (count_time[3] == 0 && count_time[2] == 1 && count_time[1] < 8 && count_time[1] >= 2 && add60 == 0 && add120 == 0 && add180 == 0 && add300 ==0) ||
    (count_time[3] == 0 && count_time[2] == 1 && count_time[1] < 2 && add120 ==0 && add180 == 0 && add300 == 0))
    next_state <= less_180;
    else
    next_state <= greater_180;
    end
    
    less_180: begin
    if (rst)
    next_state <= init;
    else if (rst16 == 1 || rst150 == 1)
    next_state <= less_180;
    else if ((count_time[3] == 1) ||(add60 == 1 && count_time[2] == 1 && count_time[1] >= 2) || (add120 == 1 && count_time[2] == 1) || (add120 == 1 && count_time[1] >= 6) || (add180 == 1) || (add300 == 1))
    next_state <= greater_180;
    else
    next_state <= less_180;
    end
    endcase
    end
    
    //output display
    wire [1:0] refresh_counter1;
    wire [3:0] one_digit1;
    wire [3:0] display_num1;   //anode
    wire [7:0] led_segment1;   //cathode
    
    wire [1:0] refresh_counter2;
    wire [3:0] one_digit2;
    wire [3:0] display_num2;    //anode
    wire [7:0] led_segment2;    //cathode
    
    refresh_counter a2(one_sec_clock, refresh_counter1); 
    anode_control a3(refresh_counter1, display_num1);
    BCD_control a4(count_time[0], count_time[1], count_time[2], count_time[3], refresh_counter1, one_digit);
    BCD_to_Cathodes a5(one_digit1, led_segment1);
    
    wire two_sec_clock;
    two_second_clock a6(rst, clock, two_sec_clock);
    refresh_counter a7(two_sec_clock, refresh_counter2); 
    anode_control a8(refresh_counter2, display_num2);
    BCD_control a9(count_time[0], count_time[1], count_time[2], count_time[3], refresh_counter2, one_digit2);
    BCD_to_Cathodes a10(one_digit2, led_segment2);
    
    always @(*) begin
    case (current_state)
    init: begin
    display_num <= display_num1;
    led_segment <= led_segment1;
    end
    
    greater_180: begin
    display_num <= display_num1;
    led_segment <= led_segment1;
    end
    
    less_180: begin
    display_num <= display_num2;
    led_segment <= led_segment2;
    end
    endcase 
    end
    endmodule
