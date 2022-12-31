`timescale 1ns / 1ps

//2 Hz clock divider
mdoule clock(input rst, clock, output reg out_clock);
localparam DIV_FACTOR = 25000000;
reg [31:0] counter;

always @ (posedge(clk) or posedge(rst))
begin
if(rst)
begin
counter <= 32'b0;
out_clock <= 1'b0;
end
	else if (counter == DIV_FACTOR - 1)
begin
counter <= 32'b0;
out_clock <= ~out_clock;
end
else
begin
counter <= counter + 32'b1;
out_clock <= out_clock;
end	
end


// generate 100 Hz from 50 MHz with 50% duty cycle
module clock(input rst, clock, output reg out_clock);
reg [17:0] count = 0;   //log2(50M/100) == 19

always @(posedge clock or posedge rst) begin
if (rst) begin
cout <= 0;
out <= 0;
end
else begin
if (count < 249999) //(50MHz/100Hz)/2 == 25000
begin
count <= count + 1;
end
else
begin
count <= 0;
out <= ~out;
end
end
endmodule

//4bit counter
//the LSB of the counter signal is half of the input signal
//the first bit is 4 times as slow, 2nd bit is 8 times as slow, and ...
//use this to create clock division by power of 2

module counter (input rst, clock, output reg [3:0] out);
always @(posedge clock) begin
if (rst)
out <= 4'b0000;
else
out <= out + 4'b0001;
end
endmodule

module div_by_pow2(input rst, clock, output clock_div2, clock_div4, clock_div8, clock_div16);
wire [3:0] clock_div;

counter count1(rst, clock, clock_div);

assign clock_div2 = clock_div[0];
assign clock_div4 = clock_div[1];
assign clock_div8 = clock_div[2];
assign clock_div16 = clock_div[3];
endmodule

//this is a clock that flip the output clock (from 0 to 1 or 1 to 0) everytime overflow happens
//since we have 4it counter, every 16th posedge, output clock will flip
module thirty_two_posedge_clock(input rst, clock, output reg out_clock);
reg [3:0] count;  //counts the number of posedge clock
//need to keep track of this since we need to flip output clock at 16

always @(posedge clock) begin
if (rst)
begin
out_clock <= 0;
count <= 0;
end
else if (count == 4'b1111)   
begin
out_clock <= ~out_clock;
count <= count + 4'b0001;
end
else
count <= count + 4'b0001;
end
endmodule

//output clock swithces state every 28th posedge
module twenty-eight_posedge_clock(input rst, clock, output reg out_clock);
reg [3:0] count;  //counts the number of posedge clock
//need to keep track of this since we need to flip output clock at 14

always @(posedge clock) begin
if (rst)
begin
out_clock <= 0;
count <= 4'b0000;
end
else if (count == 4'b1101)   //at count equal to 13, flip the clock since 28/2 = 14
begin
out_clock <= ~out_clock;
count <= 4'b00000;
end
else
count <= count + 4'b0001;
end
endmodule

//33% duty cycle clock : the clock is held high(1) for 33% time of the pulse (so 66% time it is at low(0))
//divide clock signal frequency by 3
module odd_division_clock(input rst, clock, output out_clock);
reg [2:0] clock_temp;

always @(posedge clock)
begin
if (rst)
clock_temp <= 3'b100; //clock_temp[0] = 0, clock_temp[1] = 0, clock_temp[2] = 1;
else
clock_temp <= {clock_temp[1:0], clock_temp[2]};
//if clock_temp[3:0] = {0,0,1}, at next state, clock_temp[3:0] = {1,0,0}, and
//the sate after, clock_temp[3:0]={0,1,0}
end
assign out_clock = clock_temp[2];
//so out_clock will be 1 33% of the time and 0 66% of the time
endmodule
  
  
//50% duty cycle divide by 3 clocks
//duty cycle = ((time clock is 1) / (one period)) * 100%
module odd_division_clock(input rst, clock, output out_clock);
reg [2:0] clock_temp1 = 0;
reg [2:0] clock_temp2 = 0;

always @(posedge clock)
begin
if (rst)
clock_temp1 <= 3'b100; //clock_temp1[0] = 0, clock_temp1[1] = 0, clock_temp1[2] = 1;
else
clock_temp1 <= {clock_temp1[1:0], clock_temp1[2]};
  //if clock_temp[3:0] = {0,0,1}, at next state, clock_temp[3:0] = {1,0,0}, and the sate after, clock_temp[3:0]={0,1,0}
end

always @(negedge clock)
begin
if (rst)
clock_temp2 <= 3'b100;
else
clock_temp2 <= {clock_temp2[1:0], clock_temp2[2]};
end
  assign out_clock = clock_temp1[2] || clock_temp2[2];
endmodule


//50% duty cycle divide by 5 clocks
module clock_div_five(input clock, rst, output out_clock);
reg [4:0] temp_clock;
  always @ (posedge clock)
begin
	if (rst)
	begin
		temp_clock <= 5'b00110;
	end
	else
    temp_clock <= {temp_clock[3:0], temp_clock[4]};
end

  reg [4:0] temp_clock2;
  always @ (negedge clock)
begin
	if (rst)
	begin
		temp_clock2 <= 5'b00110;
	end
	else
    temp_clock2 <= {temp_clock2[3:0], temp_clock2[4]};
end
  
  assign clk_div_5 = temp_clock[4] || temp_clock2[4];

endmodule


//Creating pulse of clock
//divde by 100 clocks with 1% duty cycle
module clock_100(input rst, clock, output wire out_clock);
reg [99:0] temp_clock;
always @(posedge clock) begin
if (rst)
temp_clock <= {1'b1, {99{1'b0}}};  //100...000
else
temp_clock <= {temp_clock[98:0],temp_clock[99]};
end

	assign out_clock = temp_clock[99];
endmodule

//use divide by 100 clocks with 1% duty cycle to create an output clock
//that is 50% duty cycle dvide by 200 clock running at 500kHz
//since clock is orignially running at 100MHz, (100MHz / 200) = 500kHz
module clock_(input rst, clock, output reg out_clock);
reg [99:0] temp_clock;
always @(posedge clock) begin
if (rst)
temp_clock <= {1'b1, {99{1'b0}}};  //100...000
else
temp_clock <= {temp_clock[98:0],temp_clock[99]};
end

always @(posedge clock) begin
if (rst)
out_clock <= 0;
if (temp_clock[99] == 1) //every time temp_clock[99] is 1, invert
out_clock <= ~out_clock; //this makes 50% duty cycle divide by 200 clocks
end
endmodule
