`timescale 1ns / 1ps

//8 bit parallel load shift register (serial out)
module shift_reg(input [7:0] in, input rst, clock, load, output reg [7:0] out);
always @(negedge rst or posedge clock)
begin
if (!rst)
out[7:0] <= 8'b0;
else if (load)
out[7:0]  <= in[7:0];  //parallel load (parallel input) when load = 1
else
out[7:0] <= {out[6:0], 1'b0};  //serial shift
end
endmodule
