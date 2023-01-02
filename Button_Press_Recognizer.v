`timescale 1ns / 1ps

//determine if the push button is pressed longer than 1 second
//or within 1 second
//there are 6 buttons (input) and 6 leds (output)
module Push_Button(
    input rst, clock, input [5:0] button_in, output [7:0] led
    );
    wire [5:0] button_out;  //tells if the 6 buttons are released or not
    
    //generate 1KHz clock
    clock_gen_1K a1(rst, clock, clock_div_1k, rstn);
    button_control a2(rstn, clock_div_1k, button_in, button_out);
    button_to_led a3(rstn, clock_div_1k, button_out, short_pressed, long_pressed, led);
    
endmodule

//clock divider (originally 25MHz, make it to be 1KHz)
//num = (25MHz / (2 * 1KHz) = 12500
//log2(12500) = 14
module clock_gen_1k (input rst, clock, output reg clock_div_1k, output rstn);
reg [15:0] count; 
assign rstn = ~rst;  //to make active low reset

always @(posedge clock or negedge rstn) begin
if (~rstn) begin
count <= 15'b0;
clock_div_1k <= 0;
end
else if (count == 12499) begin  //12500 - 1
count <= 0;
clock_div_1k <= ~clock_div_1k;
end
else
count <= count + 1;
end
endmodule

//determine if the button is short pressed or long pressed
//short pressed: button is pressed for less than 1 second
//long pressed: button is pressed for more than 1 second
module button_control (input rstn, clock, input [5:0] button_in, output reg [5:0] button_out, output short_pressed, long_pressed);
parameter init = 2'b01;
parameter short_press = 2'b10;
parameter long_press = 2'b11;

reg [1:0] current_state;
reg [1:0] next_state;
reg [5:0] button_in_1;
reg [5:0] button_in_2;
reg [9:0] count;        //counter to count 1 second (999)
wire button_pressed;    //tells wether a button is pressed
wire count_expired;     //more than 1 second has passed if count_expired is 1
wire catch_button;     //becomes 1 if button pressed in known
wire count_movement;   //has to be 1 to increase counter

//use synchonizaiton flip flops to prevent meta-stability
//so have two flip flops that take in button_in as input and outputs button_in_2
always @(posedge clock or negedge rstn) begin
if (~rstn)
button_in_1 <= 6'b0;
else
button_in_1 <= button_in;
end
always @(posedge clock or negedge rstn) begin
if (!rstn)
button_in_2 <= 6'b0;
else
button_in_2 <= button_in_1;
end

//use FSM to determine the state of the button
//assign button_pressed to 1 only when one of the button is pressed
assign button_pressed = button_in_2 != 6'b0;

//current state assignment
always @(posedge clock or negedge rstn) begin
if (!rstn)
current_state <= init;
else
current_state <= next_state;
end

//next state assignment
always @(current_state or button_pressed or count_expired) begin
next_state = init;
case(current_state)
init: begin
//when button is pressed
if (button_pressed)
next_state <= short_press;
else
next_state <= init;
end

short_press: begin
//when pressed button more than 1 second (counted up to 999)
if (count_expired)
next_state <= long_press;
else if (!button_pressed)  //when button is released
next_state <= init;
else
next_state <= short_press;
end

long_press: begin
if (!button_pressed)
next_state <= init;
else
next_state <= long_press;
end
endcase
end

//counter (counts up to 999)
//counting up to 999 is same as counting to 1 second (since clock is at 1KHz)
always @(posedge clock or negedge rstn) begin
if (!rstn)
count <= 10'h0;
else if (count_movement)
count <= count + 1;
else
count <= 0;   //if count_movement is 0, count becomes 0
end

//assign count_expired to 1 when counter reaches 999 (1 second has passed)
assign count_expired = count == 10'd999;

//button register
always @(posedge clock or negedge rstn) begin
if (!rstn)
button_out <= 6'b0;
else if (catch_button) //if saved button pressed
button_out <= button_in_2;
end


//output logic
//catch button is 1 if the button pressed is known
assign catch_button = current_state == init && button_pressed;
assign short_pressed = current_state == short_press && ~button_pressed & !count_expired;
assign long_pressed = current_state == long_press && count_expired;
//for counter
//when count_movment == 1, counter keeping increasing
assign count_movement = current_state == init;

endmodule



//take input signal (button) to led
module button_to_led(input rstn, clock, input [5:0] button_out, input short_pressed, long_pressed, output reg [7:0] led);
always @(posedge clock or negedge rstn) begin
if (!rstn)
led <= 8'b0;
else if (short_pressed)
led <= {2'b01, button_out};   //turn on in 01 and button_out tells which led to turn on
else if (long_pressed)
led <= {2'b10, button_out};
end
endmodule
