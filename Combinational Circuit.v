`timescale 1ns / 1ps


module comb_circuit(input [4:0] switch, output led);
reg led;

always @ (switch)
begin
case (switch[4:2])  //selector for mux
3'b000 : led = ~switch[0];  //not
3'b001 : led = switch[0];   //buffer
3'b010 : led = ~(switch[0] ^ switch[1]); //xnor
3'b011 : led = switch[0] ^ switch[1];  //xor
3'b100 : led = switch[0] | switch[1];
3'b101 : led = ~(switch[0] | switch[1]);
3'b110 : led = switch[0] & switch[1];
3'b111 : led = ~(switch[0] & switch[1]);
endcase
end
endmodule 
