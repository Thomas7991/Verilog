`timescale 1ns / 1ps

//8bit serial adder
module serial_adder(input rst, clock, load, input [7:0] a,b, output [7:0] out);
wire [7:0] a_in, b_in;
wire cout,cin, s;

shift_reg a1(rst, clock, load, 1'b0, a, a_in);
shift_reg a2(rst, clock, load, 1'b0, b, b_in);
register_1 a3(rst, clock, cout, cin);
full_adder a4(a_in[0], b_in[0], cin, sum, cout);
sipo a5(sum, rst, clock, out);
endmodule

//8bit serial in, parallel out register
//right shift register
module sipo(input a, rst, clock, output reg[7:0] out);
always @(posedge clock) begin
if (rst)
out <= 8'b0;
else
 out <= {a, out[7:1]}; //right shifting with input a at msb
end
endmodule


//parallel in, serial out 8bit right shift register
module shift_reg(input rst, clock, mode, sin, input [7:0] a, output reg [7:0] out);
always @(posedge clock) begin
if (rst)
out <= 8'b0;
else if (mode)  //if mode is 1, parallel output (no shifting)
out <= a;
else
out <= {sin, a[7:1]};
end
endmodule

//1bit register (for cin and cout in full adder)
module register_1(input rst, clock, a, output reg out);
always @(posedge clock)
if (rst)
out <= 1'b0;
else
out <= a;
endmodule

//1bit full adder
module full_adder(input a, b, cin, output sum, cout);
assign cout = a&b | b&cin | cin&a;
assign sum = a ^ b ^ cin;
endmodule
