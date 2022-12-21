`timescale 1ns / 1ps

//8 bit adder
module fulladd(input a ,b, cin, output out, cout);
assign out = (a^b) ^ cin;
assign cout = ((a^b) & cin) | (a&b);
endmodule

module full_adder_8bit(input [7:0] a,b, input rst, clock, cin, output reg [7:0] out, output reg cout);
wire [7:0] cout1;
reg [7:0] sum;
reg cout2;
integer i;

fulladd add1(a[0],b[0], cin, sum[0], cout1[0]);
fulladd add2(a[1],b[1], cout1[0], sum[1], cout1[1]);
fulladd add3(a[2],b[2], cout1[1], sum[2], cout1[2]);
fulladd add4(a[3],b[3], cout1[2], sum[3], cout1[3]);
fulladd add5(a[4],b[4], cout1[3], sum[4], cout1[4]);
fulladd add6(a[5],b[5], cout1[4], sum[5], cout1[5]);
fulladd add7(a[6],b[6], cout1[5], sum[6], cout1[6]);
fulladd add8(a[7],b[7], cout1[6], sum[7], cout2);

always @(posedge clock or posedge rst)
begin
if (rst)
out <= 8'b0;
else
for(i=0; i<8; i = i+1) begin
out[i] <= sum[i];
end
cout <= cout2;
end
endmodule
