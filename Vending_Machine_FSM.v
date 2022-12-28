`timescale 1ns / 1ps

//vending machine
//has 20 different snacks, with each snack having two digit code (00 to 19)
//for each snack, there can be upto 10 units of snack stored in a slot
//a counter for every slot keeps track of number of snacks remaining per slot
//accepts card only

module vending_machine(input rst, clock, reload, card_in, valid_tran, key_press, door_open, input [3:0] item_code, output reg failed_tran, invalid_select, vend, output reg [2:0] cost);

//state assignment
parameter idle = 3'b000;
parameter item_select = 3'b001;
parameter transaction = 3'b010;
parameter vend1 = 3'b011;
parameter vend2 = 3'b100;
parameter vend3 = 3'b101;
parameter reload1 = 3'b110;
parameter reset = 3'b111;

reg [2:0] current_state;
reg [2:0] next_state;
integer i;

reg [3:0] item [19:0];  //20 items of 4bit register
reg [3:0] num_entered1;
reg [3:0] num_entered2;
reg num1_inputted;
reg count_val;
reg count_init;
reg [2:0] count;
reg val_input;    //indicates valid input
reg item_num;

//define current state
//this is sequential (always block triggered by the clock)
always @(posedge clock) begin
if (rst)                     //if input rst == 0, go to reset state
current_state <= reset;
else
current_state <= next_state;
end

//counting based on the clock signal to check for time limit (5 clock cyles)
always @(posedge clock) begin
if (count_init) begin
count <= 3'b000;
count_init <= 0;
end
else if (count_val)
count <= count + 3'b001;
end

//define next state
//this is combinational (always block triggered by current state)
always @(*) begin
case(current_state)

reset: begin
for (i = 0; i< 20; i=i+1) begin
item[i] <= 0;
end
next_state <= idle;
end

reload1: begin
for (i = 0; i < 20; i= i + 1) begin
item[i] <= 10;
end
next_state <= idle;
end

idle: begin   //initial state of this vending machine FSM
if (reload)
next_state <= reload;
else if (card_in) begin
count_init <= 1;  //set count to 0 before going into item_select state
next_state <= item_select;
end
else
next_state <= idle;
end

item_select: begin
if (key_press && ~num1_inputted) begin   //first time inputting a digit (out of 2 digits)
num_entered1 <= item_code;   //user input a four bit number for the first digit to vend the item
num_entered2 <= num_entered2;   //second digit has to wait for second input
num1_inputted <= 1;   //signals that first digit is inputted
next_state <= item_select;
count_init <= 1;   //set count to 0 (if user waited to enter the first digit)
count_val <= 1;   //get 5 clock cycles to enter 2nd digit before go back to init state
val_input <= 0;   //need second digit input to have valid input
end
else if (key_press && num1_inputted) begin   //user inputting second digit
num_entered1 <= num_entered1;
num_entered2 <= item_code;
count_val <= 0;
if ((num_entered1 == 4'b0000 || 4'b0001) &&(num_entered2 >= 4'b0000) && (num_entered2 <= 4'b1001)) begin       
val_input <= 1;     //tells that user input is valid
count_init <= 1;    //set count to 0 before going into transaction state
next_state <= transaction;
end
else begin
invalid_select <= 1;
next_state <= idle;
end
end
else  //if no digit is entered or if the second digit is not entered (key_press == 0)
begin
num_entered1 <= num_entered1;
num_entered2 <= num_entered2;
count_val <= 1;
if (count == 3'b101 && count_init == 0) begin   //if the counter is 5, go to idle state
count_val <= 0;
val_input <= 0;
next_state <= idle;
end
else begin    //if the counter is less than 5, go to item select state again
next_state <= item_select;
end
end
end

transaction: begin
 //if selection is valid and there are more than 0 item in the vending machine, show the cost
if ((num_entered1 == 0 && num_entered2 == 0 && item[0] > 0) ||
(num_entered1 == 0 && num_entered2 == 1 && item[1] > 0) ||
(num_entered1 == 0 && num_entered2 == 2 && item[2] > 0) ||
(num_entered1 == 0 && num_entered2 == 3 && item[3] > 0)) begin
cost <= 1;
invalid_select <= 0;
end
else if ((num_entered1 == 0 && num_entered2 == 4 && item[4] > 0) ||
(num_entered1 == 0 && num_entered2 == 5 && item[5] > 0) ||
(num_entered1 == 0 && num_entered2 == 6 && item[6] > 0) ||
(num_entered1 == 0 && num_entered2 == 7 && item[7] > 0)) begin
cost <= 2;
invalid_select <= 0;
end
else if ((num_entered1 == 0 && num_entered2 == 8 && item[8] > 0) ||
(num_entered1 == 0 && num_entered2 == 9 && item[9] > 0) ||
(num_entered1 == 1 && num_entered2 == 0 && item[10] > 0) ||
(num_entered1 == 1 && num_entered2 == 1 && item[11] > 0)) begin
cost <= 3;
invalid_select <= 0;
end
else if ((num_entered1 == 1 && num_entered1 == 2 && item[12] > 0) ||
(num_entered1 == 1 && num_entered2 == 3 && item[13] > 0) ||
(num_entered1 == 1 && num_entered2 == 4 && item[14] > 0) ||
(num_entered1 == 1 && num_entered2 == 5 && item[15] > 0)) begin
cost <= 4;
invalid_select <= 0;
end
else if ((num_entered1 == 1 && num_entered2 == 6 && item[16] > 0) ||
(num_entered1 == 1 && num_entered2 == 7 && item[17] > 0)) begin
cost <= 5;
invalid_select <= 0;
end
else if ((num_entered1 ==1 && num_entered2 == 8 && item[18] > 0) ||
(num_entered1 == 1 && num_entered2 == 9 && item[19] > 0)) begin
cost <= 6;
invalid_select <= 0;
end
else begin
invalid_select <= 1;
next_state <= idle;
end

if (valid_tran) begin
failed_tran <= 0;
next_state <= vend1;
end
else if (count == 3'b101 && count_init == 0) begin
failed_tran <= 1;
count_val <= 0;
next_state <=  idle;
end
else begin
failed_tran <= 0;
count_val <= 1;
next_state <= transaction;
end
end

vend1: begin

if (num_entered1 == 0 && num_entered2 == 0)
item[0] <= item[0] -1;
else if (num_entered1 == 0 && num_entered2 == 1)
item[1] <= item[1] -1;
else if (num_entered1 == 0 && num_entered2 == 2)
item[2] <= item[2] - 1;
else if (num_entered1 == 0 && num_entered2 == 3)
item[3] <= item[3] -1;
else if (num_entered1 == 0 && num_entered2 == 4)
item[4] <= item[4] - 1;
else if (num_entered1 == 0 && num_entered2 == 5)
item[5] <= item[5] -1;
else if (num_entered1 == 0 && num_entered2 == 6)
item[6] <= item[6] - 1;
else if (num_entered1 == 0 && num_entered2 == 7)
item[7] <= item[7] -1;
else if (num_entered1 == 0 && num_entered2 == 8)
item[8] <= item[8] - 1;
else if (num_entered1 == 0 && num_entered2 == 9)
item[9] <= item[9] -1;
else if (num_entered1 == 1 && num_entered2 == 0)
item[10] <= item[10] - 1;
else if (num_entered1 == 1 && num_entered2 == 1)
item[11] <= item[11] -1;
else if (num_entered1 == 1 && num_entered2 == 2)
item[12] <= item[12] - 1;
else if (num_entered1 == 1 && num_entered2 == 3)
item[13] <= item[13] -1;
else if (num_entered1 == 1 && num_entered2 == 4)
item[14] <= item[14] - 1;
else if (num_entered1 == 1 && num_entered2 == 5)
item[15] <= item[15] -1;
else if (num_entered1 == 1 && num_entered2 == 6)
item[16] <= item[16] - 1;
else if (num_entered1 == 1 && num_entered2 == 7)
item[17] <= item[17] -1;
else if (num_entered1 == 1 && num_entered2 == 8)
item[18] <= item[18] - 1;
else if (num_entered1 == 1 && num_entered2 == 9)
item[19] <= item[19] -1;

if (door_open)
next_state <= vend2;  //wait for door to close to get door close signal
else
begin
count_init <= 1;
next_state <= vend3;  //when door does not open
end
end

vend2: begin  //wait for door to close
if (door_open == 0)
next_state <= idle;    //door is closed
else
next_state <= vend2;  //door is still open
end

vend3: begin //when door does not open for 5 clock cyles

if (count_init == 0 && count == 3'b101) begin
count_val <= 0;
next_state <= idle;
end
else if (door_open)
next_state <= vend2;   //door open state
else begin
count_val <= 1;
next_state <= vend3;    //door not open yet
end
end

default: begin
next_state <= idle;
end
endcase
end

//output logic (can be combinational or sequential)
always @(*) begin
case (current_state)
idle: begin
failed_tran <= 0;
invalid_select <= 0;
vend <= 0;
cost <= 0;
end
item_select: begin
failed_tran <= 0;
invalid_select <= invalid_select;
vend <= 0;
cost <= 0;
end
transaction: begin
failed_tran <= failed_tran;
invalid_select <= invalid_select;
vend <= 0;
cost <= cost;
end
vend1: begin
failed_tran <= 0;
invalid_select <= 0;
vend <= 1;
cost <= cost;
end
vend2: begin
failed_tran <= 0;
invalid_select <= 0;
vend <= 1;
cost <= cost;
end
vend3: begin
failed_tran <= 0;
invalid_select <= 0;
vend <= 1;
cost <= cost;
end
reload1: begin
failed_tran <= 0;
invalid_select <= 0;
vend <= 0;
cost <=0;
end
reset: begin
failed_tran <= 0;
invalid_select <= 0;
vend <= 0;
cost <= 0;
end
endcase
end

endmodule 
