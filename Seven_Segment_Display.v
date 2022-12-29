//clock divider equation
//divison_value = (input clock / (2*desired frequency)) - 1
//input clock has frequency 100Hz (period 0.01s)
//we want output clock to be period 1 second and 50% duty cycle clock
//so we want a clock that is in one state for 50 clock cycle and switch state
module one_second_clock(input rst, clock, output reg out);
reg [49:0] count;

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

//4 seven segment display
module display(input wire rst, clock, input [3:0] digit1, digit2, digit3, digit4, output reg [3:0] anode, output reg [7:0] cathode);
wire desire_clock;
wire [1:0] refresh_counter1;
wire [3:0] one_digit;

//set 100MHz input clock to desired clock
one_second_clock a1(rst, clock, desire_clock);
refresh_counter a2(desire_clock, refresh_counter1); 
anode_control a3(refresh_counter1, anode);
BCD_control a4(digit1, digit2, digit3, digit4, refresh_counter1, one_digit);
BCD_to_Cathodes a5(one_digit, cathode);
endmodule

//pick which digit out of 4 to be displayed (updated every clock cycle)
module refresh_counter(input clock, output reg [1:0] out = 0);
always @ (posedge clock)
out <= out + 1;
endmodule

//each anode(display) is turned on based on the value of the resfresh_counter
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

//decide which digit value to be passed on based on refresh_counter value
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

//convert BCD to 8 digits (to know which of the a ~ g to turn on)
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
