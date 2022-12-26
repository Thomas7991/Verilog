module trunstile_FSM(
    input rst,
    input clock,
    input money,
    input turn,
    output reg is_locked
    );
    //assign state values
    parameter Locked = 1'b0;
    parameter Unlocked = 1'b1;
    
    //set current state and next state in register
    reg current_state;
    reg next_state;
    
    //use always to update the current state
    //has to be squential (triggered by clock)
    always @(posedge clock) begin
    if (rst)
    current_state <= Locked;
    else
    current_state <= next_state;
    end
    
    //use another always to dedcide next state
    //has to be combinational (always block is triggered by state/input)
    always @(*)
    case(current_state)
    Locked: begin
    if (money)
    next_state <= Unlocked;
    else
    next_state <= Locked;
    end
    Unlocked: begin
    if (money)
    next_state <= Unlocked;
    else if (turn)
    next_state <= Locked;
    else
    next_state <= Unlocked;  //to stay unlocked until turned
    end
    endcase
    
    //use another always block to decide output
    //this always block is triggered by state/input
    //this Moore Machines (output depends only on the present state)
    //can combinational or sequential
    always @(*)
    case(current_state)
    Locked : begin
    is_locked <= 1'b1;
    end
    Unlocked : begin
    is_locked <= 1'b0;
    end
    endcase
    endmodule
