//d flip flop with synchronous reset
module d_flipflop(input d,rst,clock, output reg out);
always @(posedge clock)
begin
if (rst)      //have to use <= for edge senstive clock
out <= 1'b0;  //when reset is 1, output is always 0
else
out <= d;     //when reset is 0, output equals input d
end
endmodule


//4bit counter using d flipfop
module counter(input rst, clock, output reg [3:0] out);
always @(posedge clock)
begin
if (rst)      //have to use <= for edge senstive clock
out <= 4'b0000;  //when reset is 1, output is always 0
else
begin
out[0] <= ~out[0];
out[1] <= out[0] ^ out[1];
out[2] <= (out[0] & out[1]) ^ out[2];
out[3] <= ((out[0] &out[1])&out[2]) ^ out[3];
end
end
endmodule


//4bit Counter simplier version
module counter(input rst, clock, output reg [3:0] out);
always @ (posedge clock)
if (rst)
out <= 4'b0000;
else
out <= out + 1'b1;
endmodule
