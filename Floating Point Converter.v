`timescale 1ns / 1ps

//2's complement: n bit numbers represented between -(2^(n-1)) and 2^(n-1) - 1
//floating point representation
//value = (-1)^s * mantisa * 2^e

module sign_mag_converter(input [12:0] d, output reg [12:0] out, output reg sign_bit);
always @(d) begin
//when input is positive number, 2's complement and signed magnitude are same
sign_bit <= d[12];
if (d[12] == 0)
out = d;
//when input is 1000000000000, doing inversion and adding 1 will result same value (still =4096)
//to deal with this, set -4096 to 4095 in signed magnitude
else if (d == 13'b1000000000000)
out = 13'b0111111111111;
else
//to covert from 2's complement negatvie number to signed magnitude,
//invert the value, add 1, and set MSB to 1
//this is same for the other way
out = (~d + 13'b1);    //we don't add 13'b1000000000000 here since we want postive value
end
endmodule

module float_point_converter(input [12:0] signed_mag, output reg [2:0] e, output reg [4:0] mantisa, output reg round_bit);
//mantisa starts at the bit that has the first 1 (from the signed magnitude number)
//the number of leading zeros (before mantisa) determine the exponent value
//use 13:3 priority encoder to find number of leading zeros, exponent, mantisa, and the rounding bit


//the signed bit is always 0 (since we converted that way in 2's complement to signed magnitude converter)
always @(*) begin
if (signed_mag[11] !=0)
begin
e <= 3'b111;
mantisa = signed_mag[11:7];
round_bit = signed_mag[6];
end
else if (signed_mag[10] != 0)
begin
e <= 3'b110;
mantisa = signed_mag[10:6];
round_bit = signed_mag[5];
end
else if (signed_mag[9] != 0)
begin
e <= 3'b101;
mantisa = signed_mag[9:5];
round_bit = signed_mag[4];
end
else if (signed_mag[8] != 0)
begin
e <= 3'b100;
mantisa = signed_mag[8:4];
round_bit = signed_mag[3];
end
else if (signed_mag[7] != 0)
begin
e <= 3'b011;
mantisa = signed_mag[7:3];
round_bit = signed_mag[2];
end
else if (signed_mag[6] != 0)
begin
e <= 3'b010;
mantisa = signed_mag[6:2];
round_bit = signed_mag[1];
end
else if (signed_mag[5] != 0)
begin
e <= 3'b001;
mantisa = signed_mag[5:1];
round_bit = signed_mag[0];
end
else
begin
e <= 3'b000;
mantisa = signed_mag[4:0];
round_bit = 0;
end
end
endmodule

module rounding(input [2:0] e, input [4:0] m, input round_bit, output reg [2:0] exponent, output reg [4:0] mantisa);
//the round bit (the bit after mantisa) tells wheter to round mantisa up or down
//if round bit is 0, round down and if round bit is 1, round up mantisa by adding 1
//in case of rounding up maximum mantisa (11111), need to divide mantisa by 2(shift right by 1) and add 1 to get 10000
//and increase the exponent by 1
always @(*) begin
if (round_bit == 0)
begin
exponent <= e;
mantisa <= m;
end
else if (m == 5'b11111)
begin
exponent <= e + 1;
mantisa <= (m >> 1) + 1;   //mantisa = 10000
end
else
begin
exponent <= e;
mantisa <= m + 1;
end
end 
endmodule


module Floating_Point_Converter( input [12:0] d, output s, output [2:0] e, output [4:0] mantisa);
wire [12:0] sm_val;
wire s1;
assign s = s1;
wire [2:0] e1, e2;
wire [4:0] m1, m2;
wire round_bit1;

sign_mag_converter sm(d, sm_val, s1);   //sm_val has the signed magnitude input

//we only coinsdier the bits after the signed bit
//even if the signed magnitude value is negative,
//we don't need to worry about it

float_point_converter(sm_val, e1, m1, round_bit1);


rounding result(e1, m1, round_bit, e2, m2);

assign e = e2;
assign mantisa = m2;
 
endmodule
