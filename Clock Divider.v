`timescale 1ns / 1ps

//d-flipflop
module flipflop(input d,rst,clock, output reg q);
always @(posedge clock, posedge rst)
begin
if (rst)
q <= 1'b0;
else
q <= d;
end
endmodule

//assuming fPGA board has a clock signal of 100MHz
//this clock divider module dives the clock signal by half per flip flop
//so to get 1Hz from 100MHz, log2(100M) = 27, need 27 flip flops
module clock_divider(input rst, clock, output clock_out);
wire [26:0] clock_div_output;  //divided clock signal (output of each filpflop
wire [26:0] d; //input of each flip flop
genvar i;

flipflop a1(d[0], rst, clock, clock_div_output[0]);
generate
for (i = 1; i < 27; i= i+1) begin
flipflop(d[i], rst, clock_div_output[i-1], clock_div_output[i]);
end
endgenerate;

//can asign the input value at the end
assign d = ~clock_div_output;   //assign all the flip flop input to inverse of previous flipflop output
assign clock_out = clock_div_output[26];  //assign clock divider output to last output from the flipflop

endmodule


//clock divider with counter and a comparator
//when counter reaches the pre-defined value, the clock divider changes value
//either from 0 to 1 or 1 to 0
//Since we have 100MHz frequency and we want signal to be 1Hz, it takes 100M clock cyles before clock divider
//turns from 0 to 1 and back to 0
//this means, it takes half the clock cycles (50M clock cyles) for clock divider to turn from 0 to 1 or 1 to 0
module clock_divider2(input rst, clock, output reg out);
localparam num = 50000000;
reg [26:0] i;

//50k counter (counts 1 to 50k and once reach 50k, change clock divider value from 0 to 1 or 1 to 0
always @(posedge clock or posedge rst)
begin
if (rst)
i <= 27'b0;
else if (i == num-1)
i <= 27'b0;          //when i reach 50M, reset the i back to 0
else
i <= i + 1;
end

//comparator
always @ (posedge clock or posedge rst)
begin
if (rst)
out <= 1'b0;
else if (i == num-1)
out = ~out;    //only if counter reaches 50k, invert the output 0 to 1 or 1 to 0
else
out = out;  //otherwise, keep same output value



end
endmodule
